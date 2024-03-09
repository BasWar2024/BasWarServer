--- http
--@script gg.service.gate.http
--@author sundream
--@release 2020/03/24 19:30:00
--@usage
--  local gate_conf = {
--      watchdog_node = node,           -- 
--      watchdog_address = address,     -- 
--      msg_max_len = msg_max_len,      -- 
--      ip = ip,                        -- ip,0.0.0.0
--      port = port,                    -- 
--      slave_num = slave_num,          -- slave
--  }
--  local http_port = skynet.getenv("http_port")
--  gate_conf.port = http_port
--  -- http_gate
--  local http_gate = skynet.uniqueservice("gg/service/gate/http")
--
--  
--  http_gate -> watchdog_address
--  1. watchdog_address
--      skynet.send(watchdog_address,"lua","client","http_onmessage",linkobj,uri,header,query,body)
--  watchdog_address -> http_gate
----1. 
--      skynet.call(http_gate,"lua","open",gate_conf)
--  2. 
--      skynet.send(http_gate,"lua","write",linkid,status,body,header)
--
--  : linkid: ID,linkobj: (IDip)

local skynet = require "skynet"
local cluster = require "skynet.cluster"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"

local slaves = {}
local msg_max_len
local gate_node
local gate_address
local watchdog_node
local watchdog_address

local function callto(node,address,...)
    if gate_node == node then
        skynet.call(address,"lua",...)
    else
        cluster.call(node,address,...)
    end
end

local function response(linkid, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(linkid), ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        skynet.error(string.format("linktype=http,linkid=%s,err=%s",linkid,err))
    end
end

local function accept(linkid,addr)
    local slave = slaves[math.random(1,#slaves)]
    skynet.send(slave,"lua","onconnect",linkid,addr)
end


local CMD = {}

function CMD.open(conf)
    gate_node = conf.gate_node or skynet.getenv("id")
    gate_address = skynet.self()
    watchdog_node = assert(conf.watchdog_node)
    watchdog_address = assert(conf.watchdog_address)
    msg_max_len = assert(conf.msg_max_len)
    if not conf.is_slave then
        conf.is_slave = true
        table.insert(slaves,gate_address)
        local slave_num = conf.slave_num or 0
        for i=1,slave_num do
            local slave = skynet.newservice("gg/service/gate/http")
            skynet.call(slave,"lua","open",conf)
            table.insert(slaves,slave)
        end
        local port = assert(conf.port)
        local ip = conf.ip or "0.0.0.0"
        local id = assert(socket.listen(ip,port))
        skynet.error("Http Listen on",ip,port)
        socket.start(id,function (linkid,addr)
            accept(linkid,addr)
        end)
    end
    skynet.retpack()
end

function CMD.onconnect(linkid,addr)
    skynet.error(string.format("op=onconnect,linktype=http,linkid=%s,addr=%s",linkid,addr))
    socket.start(linkid)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(linkid), msg_max_len)
    if code then
        if code ~= 200 then
            response(linkid, code)
        else
            local ip,port = string.match(addr, "([^:]+):(.*)$")
            local linkobj = {
                gate_node = gate_node,
                gate_address = gate_address,
                linkid = linkid,
                ip = ip,
                port = port,
                method = method,
            }
            if header["x-real-ip"] then
                linkobj.ip = header["x-real-ip"]
            end
            local uri, query = urllib.parse(url)
            -- uri may include http://host:port ?
            if uri:sub(1,1) ~= "/" then
                uri = string.match(uri,"http[s]?://.-(/.+)")
            end
            -- callhttp!
            local ok,err = pcall(callto,watchdog_node,watchdog_address,"client","http_onmessage",linkobj,uri,header,query,body)
            if not ok then
                -- server internal error
                response(linkid,500,err)
            end
        end
    else
        if url == sockethelper.socket_error then
            skynet.error(string.format("op=socket_close,linktype=http,linkid=%s",linkid))
        else
            skynet.error(url)
        end
    end
    skynet.error(string.format("op=close,linktype=http,linkid=%s",linkid))
    socket.close(linkid)
end

function CMD.write(linkid,status,body,header)
    response(linkid,status,body,header)
end

skynet.start(function ()
    skynet.dispatch("lua",function (session,source,cmd,...)
        local func = CMD[cmd]
        func(...)
    end)
end)
