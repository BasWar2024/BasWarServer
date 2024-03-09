--  kcp: (1byte) + id(4byte,) + 
--  : 1=,2=,3=,4=(udp,)
--  id: id,,
--  : 

local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local lkcp = require "lkcp"
local config = require "app.config.custom"
local codec = require "app.codec.codec"
local datacenter = require "skynet.datacenter"

local KcpProtoType_SYN = 1
local KcpProtoType_ACK = 2
local KcpProtoType_FIN = 3
local KcpProtoType_MSG = 4

local kcp_encrypt_key = config.kcp_encrypt_key or 1314520
local kcp_wndsize = config.kcp_wndsize or 256
local kcp_mtu = config.kcp_mtu or 496
local kcp_head_size = 24

local skynet_starttime = skynet.starttime() * 1000
-- 
local function getms()
    return 10 * skynet.now() + skynet_starttime
end

local kcp = {}
local mt = {__index = kcp}


function kcp.new(opts)
    local linkid = datacenter.get("kcp_linkid") or 1
    datacenter.set("kcp_linkid",linkid+1)
    local proto_type = config.proto_type
    local proto_config = assert(config[proto_type .. "_config"])
    local codecobj = codec.new(proto_type,proto_config)
    local sock = socket.udp()
    local self = {
        linktype = "kcp",
        linkid = linkid,
        sock = sock,
        wait_proto = {},
        codec = codecobj,
        handler = opts.handler,
        heartbeatNextTime = 0,
    }
    return setmetatable(self,mt)
end

function kcp:udp_send_close()
    local buffer = string.pack("<BI4I4",KcpProtoType_FIN,kcp_encrypt_key,self.linkid)
    socket.write(self.udp_linkid,buffer)
end

function kcp:udp_send_kcpmsg(buffer)
    local buffer = string.pack("<BI4",KcpProtoType_MSG,kcp_encrypt_key) .. buffer
    socket.write(self.udp_linkid,buffer)
end

function kcp:connect(host,port)
    self.udp_linkid = socket.udp(function (msg,from)
        self:dispatch_message(from,msg)
    end)
    socket.udp_connect(self.udp_linkid,host,port)
    local buffer = string.pack("<BI4I4",KcpProtoType_SYN,kcp_encrypt_key,self.linkid)
    socket.write(self.udp_linkid,buffer)

    --local kcp_log = function (log) print(log) end
    local kcp_log = nil
    local kcpobj = lkcp.lkcp_create(self.linkid,function (buffer)
        self:udp_send_kcpmsg(buffer)
    end,kcp_log)
    --kcpobj:lkcp_logmask(0xffffffff)
    kcpobj:lkcp_nodelay(1,10,2,1)
    -- kcp_head_size = 24
    -- kcpkcp_wndsize*(kcp_mtu-kcp_head_size)/2
    kcpobj:lkcp_wndsize(kcp_wndsize,kcp_wndsize)
    kcpobj:lkcp_setmtu(kcp_mtu)
    self.kcp = kcpobj
    if self.handler.onconnect then
        self.handler.onconnect(self)
    end
    if self.handler.onhandshake then
        self.handler.onhandshake(self,"OK")
    end
    self:tick()
end

function kcp:tick()
    if not self.kcp then
        return
    end
    skynet.timeout(10,function ()
        self:tick()
    end)
    self:on_tick(getms())
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

function kcp:dispatch_message(from,msg)
    local ctrl = string.unpack("<B",msg,1)
    if ctrl == KcpProtoType_FIN then
        self:onclose(msg)
    elseif ctrl == KcpProtoType_ACK then
    elseif ctrl == KcpProtoType_MSG then
        self:recv_message(msg)
    end
end

function kcp:onclose(msg)
    self:close()
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

function kcp:say(...)
    print(string.format("[linktype=%s,linkid=%s,udp_linkid=%s]",self.linktype,self.linkid,self.udp_linkid),...)
end

function kcp:onmessage(msg)
    local cmd,args,response,session,ud = self.codec:unpack_message(msg)
    if self.handler.onmessage then
        self.handler.onmessage(self,cmd,args,response,session,ud)
    end
    local callback = self:wakeup(cmd)
    if callback then
        callback(self,args)
    end
end

function kcp:send(cmd,args,response,session,ud)
    local msg = self.codec:pack_message(cmd,args,response,session,ud)
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
    local session
    if callback then
        self.session = self.session + 1
        session = self.session
        self.sessions[session] = callback
    end
    self:send(cmd,args,false,session)
end

function kcp:send_response(cmd,args,session)
    self:send(cmd,args,true,session)
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

function kcp:close()
    if not self.kcp then
        return
    end
    self.kcp = nil
    self:udp_send_close()
    socket.close(self.udp_linkid)
    if self.handler.onclose then
        self.handler.onclose(self)
    end
end

function kcp:heartbeat()
    if not self.kcp then
        return
    end
    self.heartbeatNextTime = self.heartbeatNextTime + 5000
    local ping = string.pack("<BI4I4",KcpProtoType_MSG,kcp_encrypt_key,self.linkid)
    socket.write(self.udp_linkid,ping)
end

return kcp
