local traceback = require "traceback"
local cactor = class("cactor")

function cactor:ctor()
    if skynet.config.collectVarNames then
        for i,varname in ipairs(skynet.config.collectVarNames) do
            gg.collectVarNames[varname] = true
        end
    end
    gg.startCollectLocalVarsOnError()
    gg.client = ggclass.cclient.new()
    gg.cluster = ggclass.ccluster.new()
    gg.internal = ggclass.cinternal.new()
    gg.gm = ggclass.cgm.new()
    gg.profile = ggclass.cprofile.new()
    gg.timer = ggclass.ctimer.new()
    gg.sync = ggclass.csync.new()
    if gg.standalone then
        gg.serviceMgr = ggclass.ServiceMgr.new()
        gg.serviceMgr:register(skynet.self(),gg.serviceName)
    end
    self.time = 0
    self.deltaTime = 0
    self.heartbeatInterval = 1000   -- 1s
    self.heartbeatCount = 0

    skynet.dispatch("lua",function (...)
        self:dispatch(...)
    end)
end

function cactor:start()
    self:startHeartbeat()
    if gg.standalone then
        if gg.proxy.center then
            gg.proxy.center:send("exec","gg.nodeMgr:login",gg.status())
        end
    else
        gg.internal:send(".main","exec","gg.serviceMgr:register",skynet.self(),gg.serviceName)
    end
end

function cactor:exit()
    self:stopHeartbeat()
    if gg.standalone then
        gg.serviceMgr:unregister(skynet.self())
        if gg.proxy.center then
            gg.proxy.center:send("exec","gg.nodeMgr:logout",skynet.config.id)
        end
    else
        gg.internal:send(".main","exec","gg.serviceMgr:unregister",skynet.self())
    end
end

function cactor:dispatch(session,source,typename,...)
    local ok,err
    if gg.profile.open then
        local cmd = self:extract_cmd(typename,...)
        ok,err = gg.profile:stat(typename,cmd,gg.onerror,self._dispatch,self,session,source,typename,...)
    else
        ok,err = xpcall(self._dispatch,gg.onerror,self,session,source,typename,...)
    end
    if not ok then
        if typename == "client" and (not gg.isReleaseServer()) and (not gg.isBetaServer()) and (not gg.isAlphaServer()) and (not gg.isZksyncServer()) then
            local subcmd,linkid = ...
            if subcmd == "onmessage" then
                if gg.sayError then
                    gg.sayError(gg.client:getlinkobj(linkid),err)
                end
            end
        end
        -- "",""skynet.call""
        error(err)
    end
end

function cactor:_dispatch(session,source,typ,...)
    --skynet.trace()
    if typ == "client" then
        -- ""
        gg.client:dispatch(session,source,...)
    elseif typ == "cluster" then
        -- ""(""）""
        gg.cluster:dispatch(session,source,...)
    elseif typ == "internal" then
        -- ""actor""
        gg.internal:dispatch(session,source,...)
    elseif typ == "gm" then
        -- debug_console""gm""
        gg.gm:dispatch(session,source,...)
    end
end

function cactor:extract_cmd(typ,...)
    if typ == "client" then
        local cmd = ...
        if cmd == "onmessage" then
            local cmd2 = select(4,...)
            return cmd2
        elseif cmd == "http_onmessage" then
            local uri = select(3,...)
            return uri
        else
            return cmd
        end
        -- ""
    elseif typ == "cluster" then
        -- ""(""）""
        local protoname,cmd,cmd2 = select(3,...)
        if protoname == "sendx_callback" then
            return nil
        elseif protoname == "playerexec" then
            cmd = cmd2
        end
        if cmd == nil then
            return protoname
        end
        if not self._cache then
            self._cache = {}
        end
        if not self._cache[protoname] then
            self._cache[protoname] = {}
        end
        if not self._cache[protoname][cmd] then
            self._cache[protoname][cmd] = protoname .. "#" .. cmd
        end
        return self._cache[protoname][cmd]
    elseif typ == "internal" then
        -- ""
        local protoname,cmd,cmd2 = ...
        if protoname == "sendx_callback" then
            return nil
        elseif protoname == "playerexec" then
            cmd = cmd2
        end
        if cmd == nil then
            return protoname
        end
        if not self._cache then
            self._cache = {}
        end
        if not self._cache[protoname] then
            self._cache[protoname] = {}
        end
        if not self._cache[protoname][cmd] then
            self._cache[protoname][cmd] = protoname .. "#" .. cmd
        end
        return self._cache[protoname][cmd]
    elseif typ == "gm" then
        -- debug_console""gm""
        local cmdline = ...
        -- pid cmd arg1 arg2 ...
        local cmds = string.split(cmdline,"%s")
        return cmds[2]
    end
end

---""
---@param[type=int] topN ""topN""
---@param[type=int] sortType "": 0="",1="",2=cpu""(""),3=""(""+""),4="",5=""cpu"",6=""
---@param[type=int] interval ""("")
function cactor:startProfile(topN,sortType,interval)
    logger.print(string.format("op=startProfile,address=%s,serviceName=%s",skynet.address(skynet.self()),gg.serviceName))
    local profile = require "profile"
    self:stopProfile()
    profile.start()
    interval = interval or 10000
    self.profileTimer = gg.timer:timeloop(0,interval,-1,function ()
        local s = profile.report(topN,sortType)
        logger.logf("info","profile",s)
        logger.output(s)
    end)
end

---""
function cactor:stopProfile()
    local profile = require "profile"
    local profileTimer = self.profileTimer
    self.profileTimer = nil
    if not profileTimer then
        return
    end
    logger.print(string.format("op=stopProfile,address=%s,serviceName=%s",skynet.address(skynet.self()),gg.serviceName))
    profile.stop()
    gg.timer:deltimer(profileTimer)
end

--- ""
---@param[type=int] topN ""topN""
---@param[type=int] sortType "": 0="",1="",2=cpu""(""),3=""(""+""),4="",5=""cpu"",6=""
---@param[type=function] func ""
---@param ... ""
function cactor:watchProfile(topN,sortType,func,...)
    local profile = require "profile"
    profile.clear()
    self:stopProfile()
    profile.start()
    xpcall(func,gg.onerror,...)
    local s = profile.dump(topN,sortType)
    profile.stop()
    logger.logf("info","profile",s)
    logger.output(s)
end

function cactor:snapshot(mode,value)
    if mode == "clear" then
        self.old_snapshot = nil
        return
    end
    local starttime = skynet.time()
    local ignore = skynet.snapshot_ignore
    local snapshot = require "snapshot"
    local snapshot_utils = require "snapshot_utils"
    collectgarbage "collect"
    local new_snapshot = snapshot(ignore)
    local pretty = true
    mode = mode or "diff"
    local topN = tonumber(value) or 100
    local diff
    if mode == "refcount" then
        diff = snapshot_utils.refcount_topN(topN, new_snapshot, pretty)
    elseif mode == "tablecount" then
        diff = snapshot_utils.tablecount_topN(topN, new_snapshot, pretty)
    elseif mode == "find" then
        diff = snapshot_utils.find(value, new_snapshot) or {}
    else
        if not self.old_snapshot then
            self.old_snapshot = new_snapshot
            return
        end
        diff = snapshot_utils.diff(self.old_snapshot,new_snapshot,pretty)
    end
    self.old_snapshot = new_snapshot

    local function table_count(tbl)
        local count = 0
        for k,v in pairs(tbl) do
            count = count + 1
        end
        return count
    end
    local header = string.format("op=snapshot,costtime=%.3fms,new_snapshot_count=%d,diff_count=%d",skynet.time()-starttime,table_count(new_snapshot),table_count(diff))
    return header .. "\n" .. snapshot_utils.dump(diff)
end

--- ""
function cactor:setTracebackCollectVarNames(varnames)
    for i,key in ipairs(varnames) do
        self.collectVarNames[key] = true
    end
end

---""
---@param[type=int] interval ""("")
function cactor:startHeartbeat()
    if self.heartbeatInterval <= 0 then
        return
    end
    self:stopHeartbeat()
    self.time = skynet.timestamp()
    self.heartbeatCount = self.heartbeatCount or 0
    self.heartbeatTimer = gg.timer:timeloop(self.heartbeatInterval,self.heartbeatInterval,-1,function ()
        self.heartbeatCount = self.heartbeatCount + 1
        self.deltaTime = skynet.timestamp() - self.time
        self.time = skynet.timestamp()
        if not gg.onHeartbeat then
            return
        end
        gg.onHeartbeat()
    end)
end

function cactor:stopHeartbeat()
    local heartbeatTimer = self.heartbeatTimer
    if not heartbeatTimer then
        return
    end
    self.heartbeatTimer = nil
    gg.timer:deltimer(heartbeatTimer)
end


return cactor
