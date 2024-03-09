local queue = require "skynet.queue"
local cinternal = class("cinternal")

function cinternal:ctor()
    self.cmd = {}
    self.sessions = {}
    self.id = 0
    self.lock = queue()

    -- 
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
    self:register("sendx",function (source_address,sendx_session,cmd,...)
        local handler = self.cmd[cmd]
        self:sendx_return(source_address,sendx_session,xpcall(handler,gg.onerror,...))
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

-- 
function cinternal:open()
end

function cinternal:register(cmd,handler)
    self.cmd[cmd] = handler
end

function cinternal:gethandler(cmd)
    return self.cmd[cmd]
end

function cinternal:dispatch(...)
    if self.queue then
        self.lock(self._dispatch,self,...)
    else
        self:_dispatch(...)
    end
end

function cinternal:_dispatch(session,source_address,cmd,...)
    SOURCE_NODE = nil
    SOURCE_ADDRESS = source_address
    if logger.loglevel > logger.DEBUG then
        local handler = self.cmd[cmd]
        if session ~= 0 then
            skynet.retpack(handler(...))
        elseif cmd == "sendx" then
            handler(source_address,...)
        else
            handler(...)
        end
    else
        local request = {...}
        logger.logf("debug","internal","op=recv,session=%s,address=%s,my_node=%s,my_address=%08x,cmd=%s,request=%s",
            session,skynet.address(source_address),self.node,self.address,cmd,request)
        local handler = self.cmd[cmd]
        if session ~= 0 then
            local response = {handler(...)}
            logger.logf("debug","internal","op=resp,session=%s,address=%s,my_node=%s,my_address=%08x,cmd=%s,response=%s",
                session,skynet.address(source_address),self.node,self.address,cmd,response)
            skynet.retpack(table.unpack(response))
        elseif cmd == "sendx" then
            handler(source_address,...)
        else
            handler(...)
        end
    end
end

--- internal:call,
--@param[type=string|int] address actor
--@param[type=string] cmd 
--@param ... 
--@return 
function cinternal:call(address,cmd,...)
    if gg.profile.open then
        local name = ...
        gg.profile:incr("internal_call",name)
    end
    if logger.loglevel > logger.DEBUG then
        return skynet.call(address,"lua","internal",cmd,...)
    else
        local request = {...}
        logger.logf("debug","internal","op=call,address=%s,my_node=%s,my_address=%08x,cmd=%s,request=%s",
            skynet.address(address),self.node,self.address,cmd,request)
        local response = {skynet.call(address,"lua","internal",cmd,...)}
        logger.logf("debug","internal","op=return,address=%s,my_node=%s,my_address=%08x,cmd=%s,request=%s,response=%s",
            skynet.address(address),self.node,self.address,cmd,request,response)
        return table.unpack(response)
    end
end

--- internal:send,,
--@param[type=string|int] address actor
--@param[type=string] cmd 
--@param ... 
function cinternal:send(address,cmd,...)
    if gg.profile.open then
        local name
        if cmd == "sendx_callback" or cmd == "ping" then
            name = cmd
        elseif cmd == "sendx" then
            name = select(3,...)
        else
            name = ...
        end
        gg.profile:incr("internal_send",name)
    end
    if logger.loglevel > logger.DEBUG then
        return skynet.send(address,"lua","internal",cmd,...)
    else
        local request = {...}
        logger.logf("debug","internal","op=send,address=%s,my_node=%s,my_address=%08x,cmd=%s,request=%s",
            skynet.address(address),self.node,self.address,cmd,request)
        return skynet.send(address,"lua","internal",cmd,...)
    end
end

--- internal:sendx,,,callback
--@param[type=function,opt] callback ,nil,send
--@param[type=string|int] address actor
--@param[type=string] cmd 
--@param ... 
function cinternal:sendx(callback,address,cmd,...)
    if not callback then
        self:send(address,cmd,...)
    else
        local id = self:genid()
        self.sessions[id] = callback
        self:send(address,"sendx",id,cmd,...)
    end
end

cinternal.callx = cinternal.call

function cinternal:pcall(address,cmd,...)
    return pcall(self.call,self,address,cmd,...)
end

function cinternal:xpcall(address,cmd,...)
    return xpcall(self.call,gg.onerror,self,address,cmd,...)
end

function cinternal:genid()
    repeat
        self.id = self.id + 1
        if self.id == 0 then
            self.id = 1
        end
    until self.sessions[self.id] == nil
    return self.id
end

function cinternal:sendx_return(source_address,sendx_session,ok,...)
    if ok then
        self:send(source_address,"sendx_callback",sendx_session,...)
    else
        self:send(source_address,"sendx_error",sendx_session)
    end
end

function cinternal:sendx_callback(session,...)
    local callback = self.sessions[session]
    if not callback then
        return
    end
    self.sessions[session] = nil
    callback(...)
end

function cinternal:sendx_error(session)
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

--- internal:timeout_call,()false,true,
--@param[type=int] ti ()
--@param[type=string|int] address actor
--@param[type=string] cmd 
--@param ... 
function cinternal:timeout_call(ti,...)
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

return cinternal