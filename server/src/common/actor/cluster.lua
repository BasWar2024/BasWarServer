local queue = require "skynet.queue"
local ccluster = class("ccluster")

function ccluster:ctor()
    self.cmd = {}
    self.sessions = {}
    self.id = 0
    self.lock = queue()

    -- ""
    self.node = skynet.config.id
    self.address = skynet.self()

    -- builtin router
    self:register("exec",function (method,...)
        return gg.exec(_G,method,...)
    end)
    self:register("eval",gg.eval)
    self:register("playerexec",function (pid,method,...)
        local player = gg.playermgr:getplayer(pid)
        if player then
            return gg.exec(player,method,...)
        end
    end)
    self:register("sendx",function (source_node,source_address,sendx_session,cmd,...)
        local handler = self.cmd[cmd]
        self:sendx_return(source_node,source_address,sendx_session,xpcall(handler,gg.onerror,...))
    end)
    self:register("sendx_callback",function (sendx_session,...)
        self:sendx_callback(sendx_session,...)
    end)
    self:register("sendx_error",function (sendx_session)
        self:sendx_error(sendx_session)
    end)
    self:register("api",function (method,...)
        if not gg.api then
            return
        end
        local func = assert(gg.api[method],method)
        return func(...)
    end)
    self:register("gm",function (pid,cmd,...)
        return gg.gm:lock_docmd(table.pack(pid,cmd,...))
    end)
    self:register("ping",function (...)
        return true
    end)
end

function ccluster:open()
    self:reload()
    -- ""
    local serverid = skynet.config.id
    local cluster_port
    if skynet.config.clusterid == "master" or skynet.config.clusterid == "main" or serverid == "login" then
        cluster_port = tonumber(skynet.getenv("cluster_port")) or serverid
    else
        cluster_port = serverid
    end
    cluster.open(cluster_port)
end

function ccluster:reload()
    -- ""nodes""
    local nodes = skynet.config.nodes or {}
    local node_address = {}
    for node_name,conf in pairs(nodes) do
        node_address[node_name] = conf.address
    end
    if next(node_address) then
        cluster.reload(node_address)
    else
        cluster.reload()
    end
end

function ccluster:register(cmd,handler)
    self.cmd[cmd] = handler
end

function ccluster:gethandler(cmd)
    return self.cmd[cmd]
end

function ccluster:dispatch(...)
    if self.queue then
        self.lock(self._dispatch,self,...)
    else
        self:_dispatch(...)
    end
end

function ccluster:_dispatch(session,source,source_node,source_address,cmd,...)
    SOURCE_NODE = source_node
    SOURCE_ADDRESS = source_address
    if logger.loglevel > logger.DEBUG then
        local handler = self.cmd[cmd]
        if session ~= 0 then
            skynet.retpack(handler(...))
        elseif cmd == "sendx" then
            handler(source_node,source_address,...)
        else
            handler(...)
        end
    else
        local request = {...}
        logger.logf("debug","cluster","op=recv,session=%s,address=%s,my_node=%s,my_address=%s,source_node=%s,source_address=%s,cmd=%s,request=%s",
            session,skynet.address(source),self.node,self.address,source_node,source_address,cmd,request)
        local handler = self.cmd[cmd]
        if session ~= 0 then
            local response = {handler(...)}
            logger.logf("debug","cluster","op=resp,session=%s,address=%s,my_node=%s,my_address=%s,source_node=%s,source_address=%s,cmd=%s,response=%s",
                session,skynet.address(source),self.node,self.address,source_node,source_address,cmd,response)
            skynet.retpack(table.unpack(response))
        elseif cmd == "sendx" then
            handler(source_node,source_address,...)
        else
            handler(...)
        end
    end
end

--- cluster:call"",""
--@param[type=string] node ""
--@param[type=string|int] address ""actor""
--@param[type=string] cmd ""
--@param ... ""
--@return ""
function ccluster:call(node,address,cmd,...)
    if gg.profile.open then
        local name = ...
        gg.profile:incr("cluster_call",name)
    end
    if logger.loglevel > logger.DEBUG then
        return cluster.call(node,address,"cluster",self.node,self.address,cmd,...)
    else
        local request = {...}
        logger.logf("debug","cluster","op=call,node=%s,address=%s,my_node=%s,my_address=%s,cmd=%s,request=%s",
            node,skynet.address(address),self.node,self.address,cmd,request)
        local response = {cluster.call(node,address,"cluster",self.node,self.address,cmd,...)}
        logger.logf("debug","cluster","op=return,node=%s,address=%s,my_node=%s,my_address=%s,cmd=%s,request=%s,response=%s",
            node,skynet.address(address),self.node,self.address,cmd,request,response)
        return table.unpack(response)
    end
end

--- cluster:send"","",""
--@param[type=string] node ""
--@param[type=string|int] address ""actor""
--@param[type=string] cmd ""
--@param ... ""
function ccluster:send(node,address,cmd,...)
    if gg.profile.open then
        local name
        if cmd == "sendx_callback" or cmd == "ping" then
            name = cmd
        elseif cmd == "sendx" then
            name = select(3,...)
        else
            name = ...
        end
        gg.profile:incr("cluster_send",name)
    end
    if logger.loglevel > logger.DEBUG then
        return cluster.send(node,address,"cluster",self.node,self.address,cmd,...)
    else
        local request = {...}
        logger.logf("debug","cluster","op=send,node=%s,address=%s,my_node=%s,my_address=%s,cmd=%s,request=%s",
            node,skynet.address(address),self.node,self.address,cmd,request)
        return cluster.send(node,address,"cluster",self.node,self.address,cmd,...)
    end
end

--- cluster:sendx"","","",""callback""
--@param[type=function,opt] callback "",""nil,""send""
--@param[type=string] node ""
--@param[type=string|int] address ""actor""
--@param[type=string] cmd ""
--@param ... ""
function ccluster:sendx(callback,node,address,cmd,...)
    if not callback then
        self:send(node,address,cmd,...)
    else
        local id = self:genid()
        self.sessions[id] = callback
        self:send(node,address,"sendx",id,cmd,...)
    end
end

--- cluster:callx"",""cluster:call,""send""
--@param[type=string] node ""
--@param[type=string|int] address ""actor""
--@param[type=string] cmd ""
--@param ... ""
--@return ""
function ccluster:callx(node,address,cmd,...)
    local co = coroutine.running()
    local id = self:genid()
    local data = {
        co = co,
        result = nil,
        error = nil,
    }
    self.sessions[id] = data
    self:send(node,address,"sendx",id,cmd,...)
    skynet.wait(co)
    if data.error then
        error("callx error")
    end
    return table.unpack(data.result)
end

function ccluster:pcall(node,address,cmd,...)
    return pcall(self.call,self,node,address,cmd,...)
end

function ccluster:xpcall(node,address,cmd,...)
    return xpcall(self.call,gg.onerror,self,node,address,cmd,...)
end

function ccluster:genid()
    repeat
        self.id = self.id + 1
        if self.id == 0 then
            self.id = 1
        end
    until self.sessions[self.id] == nil
    return self.id
end

function ccluster:sendx_return(source_node,source_address,sendx_session,ok,...)
    if ok then
        self:send(source_node,source_address,"sendx_callback",sendx_session,...)
    else
        self:send(source_node,source_address,"sendx_error",sendx_session)
    end
end

function ccluster:sendx_callback(session,...)
    local callback = self.sessions[session]
    if not callback then
        return
    end
    self.sessions[session] = nil
    if type(callback) == "function" then
        callback(...)
    else
        local data = callback
        data.result = table.pack(...)
        skynet.wakeup(data.co)
    end
end

function ccluster:sendx_error(session)
    local callback = self.sessions[session]
    if not callback then
        return
    end
    self.sessions[session] = nil
    if type(callback) ~= "function" then
        local data = callback
        data.error = true
        skynet.wakeup(data.co)
    end
end


--- internal:timeout_call"",""("")""false,""true,""
--@param[type=int] ti ""("")
--@param[type=string] node ""
--@param[type=string|int] address ""actor""
--@param[type=string] cmd ""
--@param ... ""
function ccluster:timeout_call(ti,...)
    ti = math.floor(ti/10)
    local co = coroutine.running()
    local ret
    skynet.fork(function(...)
        ret = table.pack(pcall(self.call,self, ...))
        if co then
            skynet.wakeup(co)
        end
    end, ...)

    skynet.sleep(ti)
    co = nil    -- prevent wakeup after call
    if ret then
        if ret[1] then
            return table.unpack(ret, 1, ret.n)
        else
            error(ret[2])
        end
    else
        -- timeout
        return false
    end
end

return ccluster
