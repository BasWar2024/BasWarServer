--  kcp: (1byte) + (4byte,) + 
--  : 1=(SYN),2=(ACK),3=(FIN),4=(MSG,udp,)
--  : udp,(1314520,)
--  : 

local socket = require "socket"
local lkcp = require "lkcp"
local config = require "app.config"

local KcpProtoType_SYN = 1
local KcpProtoType_ACK = 2
local KcpProtoType_FIN = 3
local KcpProtoType_MSG = 4

local kcp_encrypt_key = config.kcp_encrypt_key or 1314520
local kcp_wndsize = config.kcp_wndsize or 256
local kcp_mtu = config.kcp_mtu or 496
local kcp_head_size = 24

local kcp = {}
local mt = {__index = kcp}

local kcp_linkid = 0

function kcp.new(linkid)
    kcp_linkid = kcp_linkid + 1
    linkid = linkid or kcp_linkid
    local sock = socket.udp()
    local self = {
        linktype = "kcp",
        linkid = linkid,
        sock = sock,
        wait_proto = {},
        verbose = true,  -- default: print recv message
        heartbeatNextTime = 0,
    }
    return setmetatable(self,mt)
end

function kcp:connect(host,port)
    self.host = host
    self.port = port
    self.wait_proto = {}
    local ok,errmsg = self.sock:setpeername(host,port)
    assert(ok,errmsg)
    app:attach(self.sock,self)
    app:ctl("add","read",self.sock)
    self:say("connect")
    local buffer = string.pack("<BI4I4",KcpProtoType_SYN,kcp_encrypt_key,self.linkid)
    self.sock:send(buffer)

    --local kcp_log = function (log) print(log) end
    local kcp_log = nil
    local kcpobj = lkcp.lkcp_create(self.linkid,function (buffer)
        self:udp_send(buffer)
    end,kcp_log)
    --kcpobj:lkcp_logmask(0xffffffff)
    kcpobj:lkcp_nodelay(1,10,2,1)
    -- kcpkcp_wndsize*(kcp_mtu-kcp_head_size)/2
    kcpobj:lkcp_wndsize(kcp_wndsize,kcp_wndsize)
    kcpobj:lkcp_setmtu(kcp_mtu)
    self.kcp = kcpobj
end

function kcp:on_tick(ms)
    if not self.kcp then
        return
    end
    local now = ms & 0xffffffff
    if now >= self.heartbeatNextTime then
        self:heartbeat()
    end
    self.kcp:lkcp_update(now)
end

function kcp:udp_send(buffer)
    buffer = string.pack("<BI4",KcpProtoType_MSG,kcp_encrypt_key) .. buffer
    self.sock:send(buffer)
end

function kcp:send(cmd,args,response,session,ud)
    local msg = app.codec:pack_message(cmd,args,response,session,ud)
    self:rawSend(msg)
end

function kcp:rawSend(bin)
    if not self.kcp then
        return
    end
    self.kcp:lkcp_send(bin)
    self.kcp:lkcp_flush()
end

function kcp:send_request(cmd,args,callback)
    local response = false
    local session = 0
    if callback then
        self.session = self.session + 1
        session = self.session
        self.sessions[session] = callback
    end
    if self.verbose then
        self:say(string.format("\nop=send_request,cmd=%s,args=%s",cmd,table.dump(args)))
    end
    self:send(cmd,args,response,session)
end

function kcp:send_response(cmd,args,session)
    local response = true
    if self.verbose then
        self:say(string.format("\nop=send_response,cmd=%s,args=%s",cmd,table.dump(args)))
    end
    self:send(cmd,args,response,session)
end

function kcp:dispatch_message()
    local msg,err,part = self.sock:receive()
    if not msg then
        self:close(err)
        return
    end
    local ctrl = string.unpack("<B",msg,1)
    if ctrl == KcpProtoType_FIN then
        self:onclose(msg)
    elseif ctrl == KcpProtoType_ACK then
    elseif ctrl == KcpProtoType_MSG then
        self:recv_message(msg)
    end
end

function kcp:onclose(msg)
    self:close("server close")
end

function kcp:recv_message(msg)
    local len = #msg
    if len < 5 then
        return
    end
    msg = string.sub(msg,6)
    self.kcp:lkcp_input(msg)
    while true do
        local len,msg = self.kcp:lkcp_recv()
        if len > 0 then
            self:onmessage(msg)
        else
            break
        end
    end
end

function kcp:quite()
    self.verbose = not self.verbose
end

function kcp:say(...)
    print(string.format("[linktype=%s,linkid=%s]",self.linktype,self.linkid),...)
end

function kcp:onmessage(msg)
    local cmd,args,response,session,ud = app.codec:unpack_message(msg)
    if self.verbose then
        self:say(string.format("\nop=onmessage,cmd=%s,args=%s",cmd,table.dump(args)))
    end
    local callback = self:wakeup(cmd)
    if callback then
        callback(self,args)
    end
end

function kcp:wait(protoname,callback)
    if not self.wait_proto[protoname] then
        self.wait_proto[protoname] = {}
    end
    table.insert(self.wait_proto[protoname],callback)
end

function kcp:wakeup(protoname)
    if not self.wait_proto[protoname] then
        return nil
    end
    return table.remove(self.wait_proto[protoname],1)
end

kcp.ignore_one = kcp.wakeup

function kcp:close(reason)
    self:say("close,reason: ",reason)
    local buffer = string.pack("<BI4I4",KcpProtoType_FIN,kcp_encrypt_key,self.linkid)
    self.sock:send(buffer)
    self.sock:close()
    app:unattach(self.sock,self)
    app:ctl("del","read",self.sock)
    self.kcp = nil
end

function kcp:heartbeat()
    if not self.kcp then
        return
    end
    self.heartbeatNextTime = self.heartbeatNextTime + 5000
    local ping = string.pack("<BI4I4",KcpProtoType_MSG,kcp_encrypt_key,self.linkid)
    self.sock:send(ping)
end

return kcp
