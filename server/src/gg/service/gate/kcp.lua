--- kcp
--@script gg.service.gate.kcp
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--  -- sproto
--  local proto_type = "sproto"
--  local proto_config = {
--      c2s = "src/etc/proto/sproto/all.spb",
--      s2c = "src/etc/proto/sproto/all.spb",
--      binary = true,
--  }
--  -- protobuf
--  local proto_type = "protobuf"
--  local proto_config = {
--      pbfile = "src/etc/proto/protobuf/all.pb",
--      idfile = "src/etc/proto/protobuf/message_define.lua",
--  }
--  -- json
--  local proto_type = "json"
--  local proto_config = {
--  }
--  -- bytestream
--  local proto_type = "bytestream"
--  local proto_config = {
--  }
--  local gate_conf = {
--      watchdog_node = node,           -- 
--      watchdog_address = address,     -- 
--      proto_type = proto_type,        -- 
--      proto_config = proto_config,    -- 
--      encrypt_algorithm = encrypt_algorithm, -- ,nil--,"nil"--,--
--      timeout = timeout,          -- (1/100),
--      msg_max_len = msg_max_len,  -- 
--      maxclient = maxclient,      -- 
--      ip = ip,                    -- ip,0.0.0.0
--      port = port,                -- 
--      slave_num = slave_num,      -- slave
--  }
--  local kcp_port = skynet.getenv("kcp_port")
--  gate_conf.port = kcp_port
--  -- kcp_gate,kcp_port
--  local kcp_gate = skynet.uniqueservice("gg/service/gate/kcp")
--
--  
--  kcp_gate -> watchdog_address
----1. 
--      skynet.send(watchdog_address,"lua","client","onconnect","kcp",linkid,addr,gate_node,gate_address)
--  2. ()
--      skynet.send(watchdog_address,"lua","client","onclose",linkid)
--  3. watchdog_address
--      skynet.send(watchdog_address,"lua","client","onmessage",linkid,cmd,args,is_response,session,ud)
--  4. watchdog_address
--      skynet.send(watchdog_address,"lua","client","saveof",master_linkid,slave_linkid)
--  5. 
--      skynet.send(watchdog_address,"lua","client","onhandshake","kcp",linkid,addr,result)
--  watchdog_address -> kcp_gate
----1. (udp)
--      skynet.call(kcp_gate,"lua","open",gate_conf)
--  2. 
--      skynet.send(kcp_gate,"lua","write",linkid,cmd,args,is_response,session,ud)
--      skynet.send(kcp_gate,"lua","mwrite",{linkid1,linkid2,...},cmd,args,is_response,session,ud)
--  3. 
--      skynet.send(kcp_gate,"lua","close",linkid)
--  4. 
--      skynet.send(kcp_gate,"lua","reload")
----5. (watchdog_address),nodeaddressnil,
--      skynet.send(kcp_gate,"lua","forward",linkid,proto,address,node)
--
--  : linkid: ID,addr: ,message: 

--  kcp: (1byte) + (4byte,) + 
--  : 1=(SYN),2=(ACK),3=(FIN),4=(MSG,udp,)
--  : udp,(1314520,),
--  : 

local skynet = require "skynet"
local cluster = require "skynet.cluster"
local socket = require "skynet.socket"
local lkcp = require "lkcp"
local crypt = require "skynet.crypt"
local codec = require "gg.codec.codec"

local slaves = {}
local bind_socket
local connection = {}
local client_number = 0
local maxclient
local msg_max_len
local gate_node
local gate_address
local gate_address_str
local watchdog_node
local watchdog_address
local timeout       -- 1/100s
local encrypt_algorithm
local codecobj
local kcp_close_timeout = tonumber(skynet.getenv("kcp_close_timeout")) or 500
local kcp_encrypt_key = tonumber(skynet.getenv("kcp_encrypt_key")) or 1314520
local kcp_wndsize = tonumber(skynet.getenv("kcp_wndsize")) or 256
local kcp_mtu = tonumber(skynet.getenv("kcp_mtu")) or 496
local kcp_head_size = 24

local KcpProtoType_SYN = 1
local KcpProtoType_ACK = 2
local KcpProtoType_FIN = 3
local KcpProtoType_MSG = 4

local function getlinkid(conv)
    -- idid,id!
    return -conv
end

local function sendto(node,address,...)
    if gate_node == node then
        skynet.send(address,"lua",...)
    else
        cluster.send(node,address,...)
    end
end

local skynet_starttime = skynet.starttime() * 1000
-- 
local function getms()
    return 10 * skynet.now() + skynet_starttime
end

local function udp_send_ack(from)
    local buffer = string.pack("<BI4I4",KcpProtoType_ACK,0,0)
    socket.sendto(bind_socket,from,buffer)
end

local function udp_send_close(from,cnt)
    cnt = cnt or 1
    local buffer = string.pack("<BI4I4",KcpProtoType_FIN,0,0)
    for i=1,cnt do
        socket.sendto(bind_socket,from,buffer)
    end
end

local function udp_send_kcpmsg(from,buffer)
    local buffer = string.pack("<BI4",KcpProtoType_MSG,0) .. buffer
    socket.sendto(bind_socket,from,buffer)
end

local function socket_close(linkid,reason)
    local agent = connection[linkid]
    if not agent then
        return
    end
    local from = agent.addr
    local kcp = agent.kcp
    kcp:lkcp_flush()
    udp_send_close(from,3)
    client_number = client_number - 1
    agent.isclose = true
    skynet.timeout(kcp_close_timeout,function()
        if not agent.isclose then
            return
        end
        connection[from] = nil
    end)
    connection[linkid] = nil
    local ip,port = socket.udp_address(from)
    skynet.error(string.format("op=onclose,linktype=kcp,gate_address=%s,linkid=%s,addr=%s:%s,reason=%s",gate_address_str,linkid,ip,port,reason))
    local node = agent.forward_node or watchdog_node
    local address = agent.forward_address or watchdog_address
    sendto(node,address,"client","onclose",linkid)
end

local handler = {}

function handler.recv_message(agent)
    local linkid = agent.linkid
    local kcp = agent.kcp
    local len,msg = kcp:lkcp_recv()
    if len > 0 then
        local cmd,args,response,session,ud = codecobj:unpack_message(msg)
        local node = watchdog_node
        local address = watchdog_address
        local router = agent.forward_protos[cmd]
        if router then
            node = router.node
            address = router.address
        elseif agent.forward_node then
            node = agent.forward_node
            address = agent.forward_address
        end
        sendto(node,address,"client","onmessage",linkid,cmd,args,response,session,ud)
    end
    return len
end

function handler.tick(now)
    local skynet_now = skynet.now()
    for linkid,agent in pairs(connection) do
        if type(linkid) == "number" then
            local kcp = agent.kcp
            if timeout > 0 and (skynet_now - agent.activetime >= timeout) then
                socket_close(linkid,"timeout close")
            else
                local nexttime = kcp:lkcp_check(now)
                if nexttime <= now then
                    kcp:lkcp_update(now)
                end
                while true do
                    local ok,len = xpcall(handler.recv_message,skynet.error,agent)
                    if not ok then
                        break
                    end
                    if len <= 0 then
                        break
                    end
                end
            end
        end
    end
end

function handler.dispatch_connection()
    skynet.fork(function ()
        while true do
            skynet.sleep(1)
            handler.tick(getms()&0xffffffff)
        end
    end)
end

function handler.dispatch_message(from,msg)
    local msglen = #msg
    if msglen < 9 then
        return
    end
    local ctrl = string.unpack("<B",msg,1)
    local encryptKey = string.unpack("<I4",msg,2)
    local conv = lkcp.lkcp_getconv(string.sub(msg,6))
    if encryptKey ~= kcp_encrypt_key then
        -- ,,encryptKey
        local ip,port = socket.udp_address(from)
        skynet.error(string.format("op=check_encrypt_key_fail(may be detect),ip=%s,port=%s,conv=%s,ctrl=%s,encryptKey=%s,kcp_encrypt_key=%s,msglen=%s",ip,port,conv,ctrl,encryptKey,kcp_encrypt_key,msglen))
        return
    end
    if ctrl == KcpProtoType_FIN then
        handler.onclose(from)
    elseif ctrl == KcpProtoType_SYN or ctrl == KcpProtoType_MSG then
        local agent = connection[from]
        if not agent then
            agent = handler.onconnect(from,conv)
            if not agent then
                return
            end
        end
        if agent.isclose then
            return
        end
        if ctrl == KcpProtoType_MSG then
            if conv ~= agent.conv then
                skynet.error(string.format("op=diff_conv,conv=%s,agent_conv=%s,linkid=%s",conv,agent.conv,agent.linkid))
                return
            end
            handler.onmessage(from,msg)
        end
    end
end

function handler.onconnect(from,conv)
    if connection[from] then
        return
    end
    local linkid = getlinkid(conv)
    if connection[linkid] then
        socket_close(linkid,"repeat connect")
    end
    local ip,port = socket.udp_address(from)
    if client_number >= maxclient then
        skynet.error(string.format("op=overlimit,linktype=kcp,gate_address=%s,addr=%s:%s,client_number=%s,maxclient=%s",gate_address_str,ip,port,client_number,maxclient))
        udp_send_close(from,1)
        return
    end

    client_number = client_number + 1
    --local kcp_log = function (log) print(log) end
    local kcp_log = nil
    local kcp = lkcp.lkcp_create(conv,function (buffer)
        local agent = connection[linkid]
        if not agent then
            return
        end
        udp_send_kcpmsg(from,buffer)
    end,kcp_log)
    --kcp:lkcp_logmask(0xffffffff)
    kcp:lkcp_nodelay(1,10,2,1)
    -- kcpkcp_wndsize*(kcp_mtu-kcp_head_size)/2
    kcp:lkcp_wndsize(kcp_wndsize,kcp_wndsize)
    kcp:lkcp_setmtu(kcp_mtu)
    skynet.error(string.format("op=onconnect,linktype=kcp,gate_address=%s,linkid=%s,conv=%s,addr=%s:%s",gate_address_str,linkid,conv,ip,port))
    local agent = {
        conv = conv,
        linkid = linkid,
        kcp = kcp,
        activetime = skynet.now(),
        addr = from,
        ip = ip,
        port = port,
        forward_protos = {},
    }
    connection[from] = agent
    connection[linkid] = agent
    -- ,kcp_encrypt_key,
    udp_send_ack(from)
    sendto(watchdog_node,watchdog_address,"client","onconnect","kcp",agent.linkid,from,gate_node,gate_address)
    handler.onhandshake(from,"OK")
    return agent
end

function handler.onhandshake(from,result)
    local agent = connection[from]
    sendto(watchdog_node,watchdog_address,"client","onhandshake","kcp",agent.linkid,from,result)
end

function handler.onclose(from)
    local agent = connection[from]
    if not agent then
        return
    end
    socket_close(agent.linkid,"client close")
end

function handler.onmessage(from,msg)
    local agent = connection[from]
    agent.activetime = skynet.now()
    if #msg == 9 then
        -- #msg == 9
        return
    end
    msg = string.sub(msg,6)
    local kcp = agent.kcp
    kcp:lkcp_input(msg)
end

local CMD = {}

function CMD.open(conf)
    timeout = conf.timeout or 30
    gate_node = conf.node or skynet.getenv("id")
    gate_address = skynet.self()
    gate_address_str = skynet.address(gate_address)
    watchdog_node = assert(conf.watchdog_node)
    watchdog_address = assert(conf.watchdog_address)
    encrypt_algorithm = conf.encrypt_algorithm
    codecobj = codec.new(conf.proto_type,conf.proto_config)
    msg_max_len = kcp_wndsize*(kcp_mtu-kcp_head_size)/2
    local ip = conf.ip or "0.0.0.0"
    local port = assert(conf.port)
    skynet.error("Kcp Listen on",ip,port)
    if not conf.is_slave then
        conf.is_slave = true
        local slave_num = conf.slave_num or 0
        table.insert(slaves,gate_address)
        for i=1,slave_num do
            conf.port = conf.port + 1000
            local slave = skynet.newservice("gg/service/gate/kcp")
            skynet.call(slave,"lua","open",conf)
            table.insert(slaves,slave)
        end
    end
    maxclient = assert(conf.maxclient)
    bind_socket = assert(socket.udp(function (msg,from)
        handler.dispatch_message(from,msg)
    end,ip,port))
    handler.dispatch_connection()
    skynet.retpack()
end

function CMD.reload(yes)
    if yes then
        codecobj:reload()
    else
        for i,slave in ipairs(slaves) do
            skynet.send(slave,"lua","reload",true)
        end
    end
end

function CMD.forward(linkid,proto,address,node)
    local agent = connection[linkid]
    if not agent then
        return
    end
    if proto == "*" then
        agent.forward_node = node
        agent.forward_address = address
        return
    end
    if address and node then
        agent.forward_protos[proto] = {
            node = node,
            address = address,
        }
    else
        agent.forward_protos[proto] = nil
    end
end

function CMD.mwrite(linkids,cmd,args,response,session,ud)
    for i,linkid in ipairs(linkids) do
        CMD.write(linkid,cmd,args,response,session,ud)
    end
end

function CMD.write(linkid,cmd,args,response,session,ud)
    local agent = connection[linkid]
    if not agent then
        return
    end
    local msg = codecobj:pack_message(cmd,args,response,session,ud)
    assert(#msg <= msg_max_len)
    local kcp = agent.kcp
    kcp:lkcp_send(msg)
end

function CMD.close(linkid,addr)
    local agent = connection[linkid]
    if agent and agent.addr ~= addr then
        -- onconnect will close repeat's connection
        return
    end
    socket_close(linkid,"server close")
end

skynet.start(function ()
    skynet.dispatch("lua",function (session,source,cmd,...)
        local func = CMD[cmd]
        func(...)
    end)
end)