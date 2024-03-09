local websocket_client = require "app.client.websocket.client"
local crypt = require "crypt"
local HandShake = require "app.client.handshake"

local websocket = {}
local mt = {__index = websocket}

local websocket_linkid = 0

function websocket.new(opts)
    websocket_linkid = websocket_linkid + 1
    opts = opts or {}
    opts.timeout = opts.timeout or 0.05
    local sock = websocket_client:new(opts)
    local self = {
        linktype = "websocket",
        linkid = websocket_linkid,
        sock = sock,
        send_binary = opts.send_binary and true or false,
        session = 0,
        sessions = {},
        verbose = true,  -- default: print recv message
        last_recv = "",
        wait_proto = {},
    }
    self.handShake = HandShake.new(self)
    if not app.config.handshake then
        self.handShake.result = "OK"
    end
    return setmetatable(self,mt)
end

function websocket:connect(host,port)
    local uri = host
    if port then
        uri = string.format("ws://%s:%s",host,port)
    end
    local ok,errmsg = self.sock:connect(uri)
    assert(ok,errmsg)
    self:say("connect")
    app:attach(self.sock.sock,self)
    app:ctl("add","read",self.sock.sock)
    --app:ctl("add","write",self.sock.sock)
end

function websocket:send_request(cmd,args,callback)
    local response = false
    local session
    if callback then
        self.session = self.session + 1
        session = self.session
        self.sessions[session] = callback
    end
    if self.verbose then
        self:say(string.format("\nop=send_request,cmd=%s,args=%s",cmd,table.dump(args)))
    end
    return assert(self:send(cmd,args,response,session))
end

function websocket:send_response(cmd,args,session)
    local response = true
    if self.verbose then
        self:say(string.format("\nop=send_response,cmd=%s,args=%s",cmd,table.dump(args)))
    end
    return assert(self:send(cmd,args,response,session))
end

function websocket:send(cmd,args,response,session,ud)
    local msg
    local encrypt_key = self.handShake.encryptKey
    if encrypt_key then
        msg = app.codec:pack_message(cmd,args,response,session,ud,function (cmd)
            if type(cmd) == "number" then
                return cmd ~ encrypt_key
            else
                -- jsoncmdstring
                return crypt.xor_str(cmd,encrypt_key)
            end
        end)
    else
        msg = app.codec:pack_message(cmd,args,response,session,ud)
    end
    return self:rawSend(msg)
end

function websocket:rawSend(bin)
    if self.send_binary then
        return self.sock:send_binary(bin)
    else
        return self.sock:send_text(bin)
    end
end

function websocket:dispatch_message()
    local data,typ,err = self.sock:recv_frame()
    if not data then
        self:close()
        return
    end
    local message
    if typ == "ping" then
        self.sock:send_pong(data)
    elseif typ == "pong" then
    elseif typ == "close" then
        self:close()
    elseif typ == "text" then
        self.last_recv = self.last_recv .. data
        -- fin
        if err ~= "again" then
            message = self.last_recv
            self.last_recv = ""
        end
    elseif typ == "binary" then
        self.last_recv = self.last_recv .. data
        -- fin
        if err ~= "again" then
            message = self.last_recv
            self.last_recv = ""
        end
    end
    if message then
        local ok,err = xpcall(function ()
            self:onmessage(message)
        end,debug.traceback)
        if not ok then
            self:say(err)
        end
    end
end

function websocket:close(code,msg)
    self:say("close")
    self.sock:close(code,msg)
    app:unattach(self.sock.sock,self)
    app:ctl("del","read",self.sock.sock)
    --app:ctl("del","write",self.sock.sock)
end

function websocket:quite()
    self.verbose = not self.verbose
end

function websocket:say(...)
    print(string.format("[linktype=%s,linkid=%s,endpoint_linkid=%s]",self.linktype,self.linkid,self.endpoint_linkid),...)
end

function websocket:onmessage(msg)
    if not self.handShake.result then
        local ok,err = self.handShake:doHandShake(msg)
        if not ok then
            self:close()
        end
        self:say(string.format("op=handShaking,ok=%s,err=%s,step=%s",ok,err,self.handShake.step))
        if self.handShake.result then
           self:say(string.format("op=handShake,encryptKey=%s,result=%s",self.handShake.encryptKey,self.handShake.result))
        end
        return
    end
    local cmd,args,response,session,ud
    local encrypt_key = self.handShake.encryptKey
    if encrypt_key then
        cmd,args,response,session,ud = app.codec:unpack_message(msg,function (cmd)
            if type(cmd) == "number" then
                return cmd ~ encrypt_key
            else
                -- jsoncmdstring
                return crypt.xor_str(cmd,encrypt_key)
            end
        end)
    else
        cmd,args,response,session,ud = app.codec:unpack_message(msg)
    end
    if self.verbose then
        self:say(string.format("\nop=onmessage,cmd=%s,args=%s",cmd,table.dump(args)))
    end
    local callback = self:wakeup(cmd)
    if callback then
        callback(self,args)
    end
end

function websocket:wait(protoname,callback)
    if not self.wait_proto[protoname] then
        self.wait_proto[protoname] = {}
    end
    table.insert(self.wait_proto[protoname],callback)
end

function websocket:wakeup(protoname)
    if not self.wait_proto[protoname] then
        return nil
    end
    return table.remove(self.wait_proto[protoname],1)
end

websocket.ignore_one = websocket.wakeup

return websocket
