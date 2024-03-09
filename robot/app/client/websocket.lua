local skynet = require "skynet"
local websocket_client = require "websocket.client"
local crypt = require "skynet.crypt"
local HandShake = require "app.client.handshake"
local config = require "app.config.custom"
local codec = require "app.codec.codec"

local websocket = {}
local mt = {__index = websocket}

function websocket.new(opts)
    local proto_type = config.proto_type
    local proto_config = assert(config[proto_type .. "_config"])
    local codecobj = codec.new(proto_type,proto_config)
    local sock = websocket_client:new(opts)
    local self = {
        linktype = "websocket",
        linkid = nil,
        endpoint_linkid = nil,
        sock = sock,
        send_binary = opts.send_binary and true or false,
        session = 0,
        sessions = {},
        last_recv = "",
        wait_proto = {},
        codec = codecobj,
        handler = opts.handler
    }
    self.handShake = HandShake.new(self)
    if not config.handshake then
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
    -- see client/websocket/client.lua
    self.linkid = self.sock.sock
    if self.handler.onconnect then
        self.handler.onconnect(self)
    end
    if self.handShake.result then
        if self.handler.onhandshake then
            self.handler.onhandshake(self,self.handShake.result)
        end
    end
    skynet.timeout(0,function ()
        self:dispatch_message()
    end)
end

function websocket:dispatch_message()
    while true do
        local ok = self:recv_message()
        if not ok then
            break
        end
    end
end

function websocket:recv_message()
    local data,typ,err = self.sock:recv_frame()
    if not data then
        self:close()
        return false
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
    return true
end

function websocket:close(code,msg)
    if self.handler.onclose then
        self.handler.onclose(self)
    end
    self.sock:close(code,msg)
end

function websocket:say(...)
    skynet.error(string.format("[linktype=%s,linkid=%s,endpoint_linkid=%s]",self.linktype,self.linkid,self.endpoint_linkid),...)
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
           if self.handler.onhandshake then
               self.handler.onhandshake(self,self.handShake.result)
           end
        end
        return
    end
    local cmd,args,response,session,ud
    local encrypt_key = self.handShake.encryptKey
    if encrypt_key then
        cmd,args,response,session,ud = self.codec:unpack_message(msg,function (cmd)
            if type(cmd) == "number" then
                return cmd ~ encrypt_key
            else
                -- jsoncmdstring
                return crypt.xor_str(cmd,encrypt_key)
            end
        end)
    else
        cmd,args,response,session,ud = self.codec:unpack_message(msg)
    end
    if self.handler.onmessage then
        self.handler.onmessage(self,cmd,args,response,session,ud)
    end
    local callback = self:wakeup(cmd)
    if callback then
        callback(self,args)
    end
end

function websocket:send_request(cmd,args,callback)
    local session
    if callback then
        self.session = self.session + 1
        session = self.session
        self.sessions[session] = callback
    end
    return assert(self:send(cmd,args,false,session))
end

function websocket:send_response(cmd,args,session)
    return assert(self:send(cmd,args,true,session))
end

function websocket:send(cmd,args,response,session,ud)
    local msg
    local encrypt_key = self.handShake.encryptKey
    if encrypt_key then
        msg = self.codec:pack_message(cmd,args,response,session,ud,function (cmd)
            if type(cmd) == "number" then
                return cmd ~ encrypt_key
            else
                -- jsoncmdstring
                return crypt.xor_str(cmd,encrypt_key)
            end
        end)
    else
        msg = self.codec:pack_message(cmd,args,response,session,ud)
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
