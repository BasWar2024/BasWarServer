--- websocket
--@script gg.service.gate.websocket
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
--  local websocket_port = skynet.getenv("websocket_port")
--  gate_conf.port = websocket_port
--  -- websocket_gate
--  local websocket_gate = skynet.uniqueservice("gg/service/gate/websocket")
--
--  
--  websocket_gate -> watchdog_address
--  1. 
--      skynet.send(watchdog_address,"lua","client","onconnect","websocket",linkid,addr,gate_node,gate_address)
--  2. 
--      skynet.send(watchdog_address,"lua","client","onclose",linkid)
--  3. watchdog_address
--      skynet.send(watchdog_address,"lua","client","onmessage",linkid,cmd,args,is_response,session,ud)
--  4. watchdog_address
--      skynet.send(watchdog_address,"lua","client","saveof",master_linkid,slave_linkid)
--  5. 
--      skynet.send(watchdog_address,"lua","client","onhandshake","websocket",linkid,addr,result)
--  watchdog_address -> websocket_gate
----1. 
--      skynet.call(websocket_gate,"lua","open",gate_conf)
--  2. 
--      skynet.send(websocket_gate,"lua","write",linkid,cmd,args,is_response,session,ud)
--      skynet.send(websocket_gate,"lua","mwrite",{linkid1,linkid2,...},cmd,args,is_response,session,ud)
--  3. 
--      skynet.send(websocket_gate,"lua","close",linkid)
--  4. 
--      skynet.send(websocket_gate,"lua","reload")
----5. (watchdog_address),nodeaddressnil,
--      skynet.send(tcp_gate,"lua","forward",linkid,proto,address,node)
--
--  : linkid: websocketID,addr: ,message: 

local skynet = require "skynet"
local cluster = require "skynet.cluster"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local websocket = require "websocket.server"
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
local send_binary
local codecobj
local handler = {}

local function sendto(node,address,...)
    if gate_node == node then
        skynet.send(address,"lua",...)
    else
        cluster.send(node,address,...)
    end
end

local function send_message(ws,data)
    if send_binary then
        return ws:send_binary(data)
    else
        return ws:send_text(data)
    end
end

function handler.check_timeout(linkid)
    local ws = connection[linkid]
    if not ws then
        return
    end
    skynet.timeout(500,function ()
        handler.check_timeout(linkid)
    end)
    local now = skynet.now()
    if now - ws.active >= timeout then
        local reason = "timeout close"
        skynet.error(string.format("op=check_timeout,gate_address=%s,linkid=%s,reason=%s",gate_address_str,ws.linkid,reason))
        ws:close(1000,reason)
    end
end

function handler.accept(linkid,addr)
    if client_number >= maxclient then
        skynet.error(string.format("op=overlimit,linktype=websocket,gate_address=%s,linkid=%s,addr=%s,client_number=%s,maxclient=%s",
            gate_address_str,linkid,addr,client_number,maxclient))
        socket.close(linkid)
        return
    end
    client_number = client_number + 1
    local slave = slaves[math.random(1,#slaves)]
    skynet.send(slave,"lua","onconnect",linkid,addr)
end

function handler.on_open(ws)
    local linkid = ws.linkid
    local addr = ws.addr
    ws.forward_protos = {}
    connection[linkid] = ws
    ws.handshake = chandshake.new()
    skynet.error(string.format("op=onconnect,linktype=websocket,gate_address=%s,linkid=%s,addr=%s",gate_address_str,linkid,addr))
    sendto(watchdog_node,watchdog_address,"client","onconnect","websocket",linkid,addr,gate_node,gate_address)
    if timeout > 0 then
        ws.active = skynet.now()
        handler.check_timeout(linkid)
    end
    if encrypt_algorithm then
        send_message(ws,ws.handshake:pack_challenge(linkid,encrypt_algorithm))
    else
        ws.handshake.result = "OK"
        handler.onhandshake(ws,ws.handshake.result)
    end
end

function handler.onhandshake(ws,result)
    sendto(watchdog_node,watchdog_address,"client","onhandshake","websocket",ws.linkid,ws.addr,result)
end

function handler._on_message(ws,msg)
    local linkid = ws.linkid
    if not ws.handshake.result then
        local ok,errmsg = ws.handshake:do_handshake(msg)
        skynet.error(string.format("op=handshake,linktype=websocket,gate_address=%s,linkid=%s,addr=%s,ok=%s,errmsg=%s,result=%s,step=%s",gate_address_str,linkid,ws.addr,ok,errmsg,ws.handshake.result,ws.handshake.step))
        if ws.handshake.result then
            send_message(ws,ws.handshake:pack_result())
            handler.onhandshake(ws,ws.handshake.result)
            if ws.handshake.result == "OK" and ws.handshake.master_linkid then
                skynet.error(string.format("op=slaveof,linktype=websocket,gate_address=%s,master=%s,slave=%s",gate_address_str,ws.handshake.master_linkid,ws.linkid))
                sendto(watchdog_node,watchdog_address,"client","slaveof",ws.handshake.master_linkid,ws.linkid)
            end
        end
        if not ok then
            -- 1000  "normal closure" status code
            ws:close(1000,"handshake fail")
        end
        return
    end
    ws.active = skynet.now()
    local cmd,args,response,session,ud
    local encrypt_key = ws.handshake.encrypt_key
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
    local router = ws.forward_protos[cmd]
    if router then
        node = router.node
        address = router.address
    elseif ws.forward_node then
        node = ws.forward_node
        address = ws.forward_address
    end
    sendto(node,address,"client","onmessage",linkid,cmd,args,response,session,ud)
end

function handler.on_message(ws,msg)
    xpcall(handler._on_message,skynet.error,ws,msg)
end

function handler.on_close(ws,code,reason)
    local linkid = ws.linkid
    if not connection[linkid] then
        return
    end
    skynet.error(string.format("op=onclose,linktype=websocket,gate_address=%s,linkid=%s,code=%s,reason=%s",gate_address_str,linkid,code,reason))
    client_number = client_number - 1
    connection[linkid] = nil
    local node = ws.forward_node or watchdog_node
    local address = ws.forward_address or watchdog_address
    sendto(node,address,"client","onclose",linkid)
end

function handler.on_ping(ws,message)
    --print("on_ping",ws.linkid,message)
    ws.active = skynet.now()
    ws:send_pong(message)
end

function handler.on_pong(ws,message)
    --print("on_pong",ws.linkid,message)
    ws.active = skynet.now()
end

local CMD = {}

function CMD.open(conf)
    -- (:1/100),
    timeout = conf.timeout or 0
    gate_node = conf.gate_node or skynet.getenv("id")
    gate_address = skynet.self()
    gate_address_str = skynet.address(gate_address)
    watchdog_node = assert(conf.watchdog_node)
    watchdog_address = assert(conf.watchdog_address)
    encrypt_algorithm = conf.encrypt_algorithm
    send_binary = conf.send_binary and true or false
    codecobj = codec.new(conf.proto_type,conf.proto_config)
    msg_max_len = assert(conf.msg_max_len)
    if not conf.is_slave then
        conf.is_slave = true
        table.insert(slaves,gate_address)
        local slave_num = conf.slave_num or 0
        for i=1,slave_num do
            local slave = skynet.newservice("gg/service/gate/websocket")
            skynet.call(slave,"lua","open",conf)
            table.insert(slaves,slave)
        end
        maxclient = assert(conf.maxclient)
        local port = assert(conf.port)
        local ip = conf.ip or "0.0.0.0"
        local id = assert(socket.listen(ip,port))
        skynet.error("Websocket Listen on",ip,port)
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
    local ws = connection[linkid]
    if not ws then
        return
    end
    if proto == "*" then
        ws.forward_node = node
        ws.forward_address = address
        return
    end
    if address and node then
        ws.forward_protos[proto] = {
            node = node,
            address = address,
        }
    else
        ws.forward_protos[proto] = nil
    end
end

function CMD.mwrite(linkids,cmd,args,response,session,ud)
    for i,linkid in ipairs(linkids) do
        CMD.write(linkid,cmd,args,response,session,ud)
    end
end

function CMD.write(linkid,cmd,args,response,session,ud)
    local ws = connection[linkid]
    if not ws then
        return
    end
    local msg
    local encrypt_key = ws.handshake.encrypt_key
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
    send_message(ws,msg)
end

function CMD.close(linkid)
    local ws = connection[linkid]
    if not ws then
        return
    end
    -- 1000  "normal closure" status code
    ws:close(1000,"server close")
end

function CMD.onconnect(linkid,addr)
    socket.start(linkid)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(linkid), 8192)
    if code == 200 then
        if header.upgrade == "websocket" then
            if header["x-real-ip"] then
                local proxy_ip,proxy_port = string.match(addr,"([^:]+):(%d+)")
                addr = string.format("%s:%s",header["x-real-ip"],proxy_port)
            end
            local ws,err = websocket:new({
                sock = linkid,
                headers = header,
                max_payload_len = msg_max_len,
                send_masked = false,
            })
            if ws then
                ws.linkid = linkid
                ws.addr = addr
                ws:start(handler)
            else
                httpd.write_response(sockethelper.writefunc(linkid),400,err)
                socket.close(linkid)
            end
        end
    else
        socket.close(linkid)
    end
end

skynet.start(function ()
    skynet.dispatch("lua",function (session,source,cmd,...)
        local func = CMD[cmd]
        func(...)
    end)
end)