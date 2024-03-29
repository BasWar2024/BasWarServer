local socket = require "socket"
local crypt = require "crypt"
local HandShake = require "app.client.handshake"

local tcp = {}
local mt = {__index = tcp}


local tcp_linkid = 0

function tcp.new()
    tcp_linkid = tcp_linkid + 1
    local sock = socket.tcp()
    local timeout = 0.05
    local self = {
        linktype = "tcp",
        linkid = tcp_linkid,
        timeout = timeout,
        sock = sock,
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

function tcp:connect(host,port)
    local ok,errmsg = self.sock:connect(host,port)
    assert(ok,errmsg)
    self:say("connect")
    if self.timeout > 0 then
        self.sock:settimeout(self.timeout) -- noblock mode
    end
    app:attach(self.sock,self)
    app:ctl("add","read",self.sock)
    --app:ctl("add","write",self.sock)
end

function tcp:send_request(cmd,args,callback)
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
    return self:send(cmd,args,response,session)
end

function tcp:send_response(cmd,args,session)
    local response = true
    if self.verbose then
        self:say(string.format("\nop=send_response,cmd=%s,args=%s",cmd,table.dump(args)))
    end
    return self:send(cmd,args,response,session)
end

function tcp:send(cmd,args,response,session,ud)
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
    self:rawSend(msg)
end

function tcp:rawSend(bin)
    local size = #bin
    assert(size <= 65535,"package too long")
    -- len field encode in big-endian
    local package = string.char(math.floor(size/256)) ..
        string.char(size%256) ..
        bin
    return self.sock:send(package)
end

function tcp:_unpack_message(text)
    local size = #text
    if size < 2 then
        return nil,text
    end
    local s = text:byte(1) * 256 + text:byte(2)
    if size < s + 2 then
        return nil,text
    end
    return text:sub(3,s+2),text:sub(s+3)
end

function tcp:dispatch_message()
    local r,err,part = self.sock:receive("*a")
    if not r then
        if err == "closed" then
            self:close()
            return
        else
            assert(err == "timeout")
            r = part or ""
        end
    end
    self.last_recv = self.last_recv .. r
    local message
    while true do
        message,self.last_recv = self:_unpack_message(self.last_recv)
        if message then
            local ok,err = xpcall(function ()
                self:onmessage(message)
            end,debug.traceback)
            if not ok then
                self:say(err)
            end
        else
            break
        end
    end
end

function tcp:close()
    self:say("close")
    self.sock:close()
    app:unattach(self.sock,self)
    app:ctl("del","read",self.sock)
    --app:ctl("del","write",self.sock)
end

function tcp:quite()
    self.verbose = not self.verbose
end

function tcp:say(...)
    print(string.format("[linktype=%s,linkid=%s,endpoint_linkid=%s]",self.linktype,self.linkid,self.endpoint_linkid),...)
end

function tcp:onmessage(msg)
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

function tcp:wait(protoname,callback)
    if not self.wait_proto[protoname] then
        self.wait_proto[protoname] = {}
    end
    table.insert(self.wait_proto[protoname],callback)
end

function tcp:wakeup(protoname)
    if not self.wait_proto[protoname] then
        return nil
    end
    return table.remove(self.wait_proto[protoname],1)
end

tcp.ignore_one = tcp.wakeup

return tcp
