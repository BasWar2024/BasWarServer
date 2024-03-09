local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local socket_proxy = require "socket_proxy"
local config = require "app.config.custom"
local HandShake = require "app.client.handshake"
local codec = require "app.codec.codec"

local tcp = {}
local mt = {__index = tcp}

function tcp.new(opts)
    local proto_type = config.proto_type
    local proto_config = assert(config[proto_type .. "_config"])
    local codecobj = codec.new(proto_type,proto_config)
    local self = {
        linktype = "tcp",
        linkid = nil,
        endpoint_linkid = nil,
        session = 0,
        sessions = {},
        wait_proto = {},
        codec = codecobj,
        handler = opts.handler,
    }
    self.handShake = HandShake.new(self)
    if not config.handshake then
        self.handShake.result = "OK"
    end
    return setmetatable(self,mt)
end

function tcp:connect(host,port)
    local linkid,err = socket.open(host,port)
    assert(linkid,err)
    self.linkid = linkid
    socket_proxy.subscribe(linkid,0)
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

function tcp:dispatch_message()
    while true do
        local ok,msg,sz = pcall(socket_proxy.read,self.linkid)
        if not ok then
            self:close()
            break
        end
        msg = skynet.tostring(msg,sz)
        xpcall(self.recv_message,skynet.error,self,msg)
    end
end
function tcp:recv_message(msg)
    self:onmessage(msg)
end

function tcp:close()
    if self.closed then
        return
    end
    self.closed = true
    if self.handler.onclose then
        self.handler.onclose(self)
    end
    socket_proxy.close(self.linkid)
end

function tcp:quite()
    self.verbose = not self.verbose
end

function tcp:say(...)
    skynet.error(string.format("[linktype=%s,linkid=%s,endpoint_linkid=%s]",self.linktype,self.linkid,self.endpoint_linkid),...)
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

function tcp:send_request(cmd,args,callback)
    local session
    if callback then
        self.session = self.session + 1
        session = self.session
        self.sessions[session] = callback
    end
    return self:send(cmd,args,false,session)
end

function tcp:send_response(cmd,args,session)
    return self:send(cmd,args,true,session)
end

function tcp:send(cmd,args,response,session,ud)
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
    self:rawSend(msg)
end

function tcp:rawSend(bin)
    local size = #bin
    assert(size <= 65535,"package too long")
    socket_proxy.write(self.linkid,bin)
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
