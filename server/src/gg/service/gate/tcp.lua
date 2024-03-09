--- tcp
--@script gg.service.gate.tcp
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
--  local tcp_port = skynet.getenv("tcp_port")
--  gate_conf.port = tcp_port
--  -- tcp_gate
--  local tcp_gate = skynet.uniqueservice("gg/service/gate/tcp")
--
--  
--  tcp_gate -> watchdog_address
--  1. 
--      skynet.send(watchdog_address,"lua","client","onconnect","tcp",linkid,addr,gate_node,gate_address)
--  2. 
--      skynet.send(watchdog_address,"lua","client","onclose",linkid)
--  3. watchdog_address
--      skynet.send(watchdog_address,"lua","client","onmessage",linkid,cmd,args,is_response,session,ud)
--  4. watchdog_address
--      skynet.send(watchdog_address,"lua","client","saveof",master_linkid,slave_linkid)
--  5. 
--      skynet.send(watchdog_address,"lua","client","onhandshake","tcp",linkid,addr,result)
--  watchdog_address -> tcp_gate
----1. 
--      skynet.call(tcp_gate,"lua","open",gate_conf)
--  2. 
--      skynet.send(tcp_gate,"lua","write",linkid,cmd,args,is_response,session,ud)
--      skynet.send(tcp_gate,"lua","mwrite",{linkid1,linkid2,...},cmd,args,is_response,session,ud)
--  3. 
--      skynet.send(tcp_gate,"lua","close",linkid)
--  4. 
--      skynet.send(tcp_gate,"lua","reload")
----5. (watchdog_address),nodeaddressnil,
--      skynet.send(tcp_gate,"lua","forward",linkid,proto,address,node)
--
--  : linkid: ID,addr: ,message: 
--  : 2()+(,protobuf/sproto,
--  id)
--  skynet_package,see https://github.com/cloudwu/skynet_package

local skynet = require "skynet"
local cluster = require "skynet.cluster"
local socket = require "skynet.socket"
local socket_proxy = require "socket_proxy"
local crypt = require "skynet.crypt"
local codec = require "gg.codec.codec"
local chandshake = require "gg.service.gate.handshake"

local slaves = {}
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
local handler = {}


local function sendto(node,address,...)
    if gate_node == node then
        skynet.send(address,"lua",...)
    else
        cluster.send(node,address,...)
    end
end

local socket_start = socket_proxy.subscribe
local socket_read = function (linkid)
    local ok,msg,sz = pcall(socket_proxy.read,linkid)
    if not ok then
        return false
    end
    return true,skynet.tostring(msg,sz)
end
local socket_write = socket_proxy.write

local function socket_close(linkid,reason)
    socket_proxy.close(linkid)
    local agent = connection[linkid]
    if not agent then
        return
    end
    skynet.error(string.format("op=onclose,linktype=tcp,gate_address=%s,linkid=%s,reason=%s",gate_address_str,linkid,reason))
    client_number = client_number - 1
    connection[linkid] = nil
    local node = agent.forward_node or watchdog_node
    local address = agent.forward_address or watchdog_address
    sendto(node,address,"client","onclose",linkid)
end

function handler.accept(linkid,addr)
    if client_number >= maxclient then
        skynet.error(string.format("op=overlimit,linktype=tcp,gate_address=%s,linkid=%s,addr=%s,client_number=%s,maxclient=%s",
            gate_address_str,linkid,addr,client_number,maxclient))
        socket_close(linkid)
        return
    end
    client_number = client_number + 1
    local slave = slaves[math.random(1,#slaves)]
    skynet.send(slave,"lua","onconnect",linkid,addr)
end

function handler.onconnect(linkid,addr)
    local agent = {
        addr = addr,
        linkid = linkid,
        handshake = chandshake.new(),
        forward_protos = {},
    }
    connection[linkid] = agent
    skynet.error(string.format("op=onconnect,linktype=tcp,gate_address=%s,linkid=%s,addr=%s",gate_address_str,linkid,addr))
    sendto(watchdog_node,watchdog_address,"client","onconnect","tcp",linkid,addr,gate_node,gate_address)
    if encrypt_algorithm then
        socket_write(linkid,agent.handshake:pack_challenge(linkid,encrypt_algorithm))
    else
        agent.handshake.result = "OK"
        handler.onhandshake(linkid,agent.handshake.result)
    end
end

function handler.onhandshake(linkid,result)
    local agent = connection[linkid]
    sendto(watchdog_node,watchdog_address,"client","onhandshake","tcp",linkid,agent.addr,result)
end

function handler.onclose(linkid,reason)
    socket_close(linkid,reason)
end

function handler.onmessage(linkid,msg)
    local agent = connection[linkid]
    if not agent then
        return
    end
    if not agent.handshake.result then
        local ok,errmsg = agent.handshake:do_handshake(msg)
        skynet.error(string.format("op=handshake,linktype=tcp,gate_address=%s,linkid=%s,addr=%s,ok=%s,errmsg=%s,result=%s,step=%s",gate_address_str,linkid,agent.addr,ok,errmsg,agent.handshake.result,agent.handshake.step))
        if agent.handshake.result then
            socket_write(linkid,agent.handshake:pack_result())
            handler.onhandshake(linkid,agent.handshake.result)
            if agent.handshake.result == "OK" and agent.handshake.master_linkid then
                skynet.error(string.format("op=slaveof,linktype=tcp,gate_address=%s,master=%s,slave=%s",gate_address_str,agent.handshake.master_linkid,agent.linkid))
                sendto(watchdog_node,watchdog_address,"client","slaveof",agent.handshake.master_linkid,agent.linkid)
            end
        end
        if not ok then
            socket_close(linkid,errmsg)
        end
        return
    end
    local cmd,args,response,session,ud
    local encrypt_key = agent.handshake.encrypt_key
    if encrypt_key then
        cmd,args,response,session,ud = codecobj:unpack_message(msg,function (cmd)
            if type(cmd) == "number" then
                return cmd ~ encrypt_key
            else
                -- jsoncmdstring
                return crypt.xor_str(cmd,encrypt_key)
            end
        end)
    else
        cmd,args,response,session,ud = codecobj:unpack_message(msg)
    end
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

local CMD = {}

function CMD.open(conf)
    -- (:1/100),
    timeout = conf.timeout or 0
    timeout = timeout * 10      -- skynet_package
    gate_node = conf.gate_node or skynet.getenv("id")
    gate_address = skynet.self()
    gate_address_str = skynet.address(gate_address)
    watchdog_node = assert(conf.watchdog_node)
    watchdog_address = assert(conf.watchdog_address)
    encrypt_algorithm = conf.encrypt_algorithm
    codecobj = codec.new(conf.proto_type,conf.proto_config)
    msg_max_len = assert(conf.msg_max_len)
    if not conf.is_slave then
        conf.is_slave = true
        table.insert(slaves,gate_address)
        local slave_num = conf.slave_num or 0
        for i=1,slave_num do
            local slave = skynet.newservice("gg/service/gate/tcp")
            skynet.call(slave,"lua","open",conf)
            table.insert(slaves,slave)
        end
        maxclient = assert(conf.maxclient)
        local port = assert(conf.port)
        local ip = conf.ip or "0.0.0.0"
        local id = assert(socket.listen(ip,port))
        skynet.error("Tcp Listen on",ip,port)
        socket.start(id,function (linkid,addr)
            handler.accept(linkid,addr)
        end)
    end
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
    local msg
    local encrypt_key = agent.handshake.encrypt_key
    if encrypt_key then
        msg = codecobj:pack_message(cmd,args,response,session,ud,function (cmd)
            if type(cmd) == "number" then
                return cmd ~ encrypt_key
            else
                -- jsoncmdstring
                return crypt.xor_str(cmd,encrypt_key)
            end
        end)
    else
        msg = codecobj:pack_message(cmd,args,response,session,ud)
    end
    assert(#msg <= msg_max_len,cmd)
    socket_write(linkid,msg)
end

function CMD.close(linkid)
    if not connection[linkid] then
        return
    end
    socket_close(linkid,"server close")
end

function CMD.onconnect(linkid,addr)
    socket_start(linkid,timeout)
    handler.onconnect(linkid,addr)
    local agent = connection[linkid]
    if not agent then
        return
    end
    skynet.timeout(0,function ()
        while true do
            local ok,msg = socket_read(linkid)
            if not ok then
                handler.onclose(linkid,msg)
                break
            end
            xpcall(handler.onmessage,skynet.error,linkid,msg)
        end
    end)
end

skynet.start(function ()
    skynet.dispatch("lua",function (session,source,cmd,...)
        local func = CMD[cmd]
        func(...)
    end)
end)
