local cplayer = reload_class("cplayer")

---cplayer
--@param[type=int] pid id
function cplayer:_ctor(pid)
    self:initProperty()
end

---cplayer
function cplayer:initProperty()
    self.lang = "zh_CN"         -- : zh_CN=,en_US=,zh_TW=
    self.account = nil          -- (,openid@)
    self.openId = nil           -- openId
    self.vip = 0                -- vip
    self.level = 1              -- 
    self.name = nil             -- 
    self.heroId = 0             -- id
    self.gm = 0                 -- gm
    self.createServerId = nil   -- id
    self.createTime = nil       -- ()
    self.loginTime = nil        -- ()
    self.disconnectTime = nil   -- ()
    self.logoutTime = nil       -- ()

    self.minuteVersion = nil     -- 1
    self.fiveMinuteVersion = nil -- 5
    self.halfHourVersion = nil   -- 
    self.hourVersion = nil        -- 
    self.dayVersion = nil         -- 
    self.mondayVersion = nil      -- 
    self.sundayVersion = nil      -- 
    self.monthVersion = nil       -- 

    -- TODO: 
end

---cplayer
function cplayer:serializeProperty()
    return {
        lang = self.lang,
        account = self.account,
        openId = self.openId,
        vip = self.vip,
        level = self.level,
        name = self.name,
        heroId = self.heroId,
        gm = self.gm,
        createServerId = self.createServerId,
        createTime = self.createTime,
        loginTime = self.loginTime,
        disconnectTime = self.disconnectTime,
        logoutTime = self.logoutTime,

        minuteVersion = self.minuteVersion,
        fiveMinuteVersion = self.fiveMinuteVersion,
        halfHourVersion = self.halfHourVersion,
        hourVersion = self.hourVersion,
        dayVersion = self.dayVersion,
        mondayVersion = self.mondayVersion,
        sundayVersion = self.sundayVersion,
        monthVersion = self.monthVersion,
    }
end

---cplayer
function cplayer:deserializeProperty(data)
    assert(not table.isempty(data),"role no property:" .. tostring(self.pid))
    for k,v in pairs(data) do
        self[k] = v
    end
end

-- db
function cplayer:beforeSaveToDb()
end

---
function cplayer:onload()
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onload then
            obj:onload(self)
        elseif obj.exec then
            obj:exec("onload",self)
        end
    end
end

---
function cplayer:oncreate()
    local currentServerId = skynet.config.id
    logger.logf("info","login","op=oncreate,serverid=%s,account=%s,pid=%s,name=%s,linktype=%s,linkid=%s,ip=%s,port=%s,version=%s,name=%s,id=%s",
        currentServerId,self.account,self.pid,self.name,self.linktype,self.linkid,self.ip,self.port,self.version,self.name,self.id)
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        obj.loadstate = "loaded"
        if obj.oncreate then
            obj:oncreate(self)
        elseif obj.exec then
            obj:exec("oncreate",self)
        end
    end
end

---
---@param[type=bool] replace true=
function cplayer:onlogin(replace)
    if not replace then
        self.loginTime = os.time()
    end
    self.onlineState = ggclass.cplayer.ONLINE_STATE_ONLINE
    local currentServerId = skynet.config.id
    local fromServerId = self.fromServerId
    logger.logf("info","login","op=onlogin,serverid=%s,fromServerId=%s,account=%s,pid=%s,name=%s,linktype=%s,linkid=%s,ip=%s,port=%s,version=%s,id=%s,replace=%s",
        currentServerId,fromServerId,self.account,self.pid,self.name,self.linktype,self.linkid,self.ip,self.port,self.version,self.id,replace)
    
    local pid = self.pid
    local data = self:packBrief()
    data.currentServerId = skynet.config.id
    data.onlineState = self.onlineState
    data.pid = pid
    if not gg.briefMgr:getBrief(pid) then
        gg.proxy.center:call("api","createBrief",data)
    end
    
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onlogin then
            obj:onlogin(replace)
        elseif obj.exec then
            obj:exec("onlogin",replace)
        end
    end
    if self.kuafu_forward then
        local kuafu_forward = self.kuafu_forward
        self.kuafu_forward = nil
        if kuafu_forward.onlogin then
            local onlogin = gg.unpack_function(kuafu_forward.onlogin)
            xpcall(onlogin,gg.onerror)
        end
    end

    self:subscribeBrief()
    gg.proxy.center:send("api","setBriefAttrs",pid,data)
    self:checkTime(true)
    gg.gm:onlogin(self,replace)
    -- TODO: 

    self:syncToLoginServer(self.onlineState)

    return data
end

---
---@param[type=int] logoutType : 1=/3=/4=
function cplayer:onlogout(logoutType)
    self.logoutTime = os.time()
    self.onlineState = ggclass.cplayer.ONLINE_STATE_OFFLINE
    local currentServerId = skynet.config.id
    local fromServerId = self.fromServerId
    logger.logf("info","login","op=onlogout,serverid=%s,fromServerId=%s,account=%s,pid=%s,name=%s,linktype=%s,linkid=%s,ip=%s,port=%s,version=%s,id=%s,logoutType=%s",
        currentServerId,fromServerId,self.account,self.pid,self.name,self.linktype,self.linkid,self.ip,self.port,self.version,self.id,logoutType)
    for i=#self.ordered_component,1,-1 do
        local obj = self.ordered_component[i]
        if obj.onlogout then
            obj:onlogout(logoutType)
        elseif obj.exec then
            obj:exec("onlogout",logoutType)
        end
    end
    local pid = self.pid
    local data = self:packBrief()
    data.currentServerId = skynet.config.id
    data.onlineState = self.onlineState
    data.pid = pid
    gg.proxy.center:send("api","setBriefAttrs",pid,data)
    -- TODO: 

    self:syncToLoginServer(self.onlineState)
end

---
---@param[type=int] logoutType : 1=/2=/3=/4=
function cplayer:ondisconnect(logoutType)
    self.onlineState = ggclass.cplayer.ONLINE_STATE_DISCONNECT
    logger.logf("info","login","op=ondisconnect,pid=%s,name=%s,linktype=%s,linkid=%s,ip=%s,port=%s,logoutType=%s",
        self.pid,self.name,self.linktype,self.linkid,self.ip,self.port,logoutType)
    for i=#self.ordered_component,1,-1 do
        local obj = self.ordered_component[i]
        if obj.ondisconnect then
            obj:ondisconnect(logoutType)
        elseif obj.exec then
            obj:exec("ondisconnect",logoutType)
        end
    end
    self:unsubscribeBrief()
    local pid = self.pid
    local data = self:packBrief()
    data.currentServerId = skynet.config.id
    data.onlineState = self.onlineState
    data.pid = pid
    gg.proxy.center:send("api","setBriefAttrs",pid,data)
    -- TODO: 
end

function cplayer:packBrief()
    local linkobj = false
    if self.linkobj then
        linkobj = gg.client:clone_linkobj(self.linkobj)
    end
    return {
        node = skynet.config.id,
        address = skynet.self(),
        runId = gg.runId,
        linkobj = linkobj,

        id = self.id,
        pid = self.pid,
        account = self.account,
        name = self.name,
        heroId = self.heroId,
        level = self.level,
        vip = self.vip,

        loginTime = self.loginTime,
        disconnectTime = self.disconnectTime,
        logoutTime = self.logoutTime,
        createTime = self.createTime,
        lang = self.lang,
    }
end

---
function cplayer:beforeGoServer(goServerId)
end

---()
function cplayer:beforeBeReplace(linkobj)
    gg.client:send(self.linkobj,"S2C_BeReplace",{
        ip = linkobj.ip
    })
    -- TODO: 
end

function cplayer:canDelayExitGame()
    -- return true,
    -- 
    -- return false
    return false
end

---gm
function cplayer:sayToGmChannel(content)
    gg.client:send(self.linkobj,"S2C_Msg_GM",{
        content = content,
    })
end

---
--@param[type=table] channel 
--@param[type=bool] isQueue true=message,false=message
function cplayer:sayToChannel(channel,isQueue,message)
end

---
--@param[type=string|userdata] msg 
function cplayer:say(msg)
    gg.client:send(self.linkobj,"S2C_Msg_Say",{
        content = i18n.translateto(self.lang,msg)
    })
end

function cplayer:onSecond()
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onSecond then
            obj:onSecond()
        elseif obj.exec then
            obj:exec("onSecond")
        end
    end
end

function cplayer:onMinuteUpdate()
    local minuteVersion = gg.time.minuteno()
    if minuteVersion == self.minuteVersion then
        return
    end
    self.minuteVersion = minuteVersion
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onMinuteUpdate then
            obj:onMinuteUpdate()
        elseif obj.exec then
            obj:exec("onMinuteUpdate")
        end
    end
end

function cplayer:onFiveMinuteUpdate()
    local fiveMinuteVersion = gg.time.fiveminuteno()
    if fiveMinuteVersion == self.fiveMinuteVersion then
        return
    end
    self.fiveMinuteVersion = fiveMinuteVersion
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onFiveMinuteUpdate then
            obj:onFiveMinuteUpdate()
        elseif obj.exec then
            obj:exec("onFiveMinuteUpdate")
        end
    end
end

function cplayer:onHalfHourUpdate()
    local halfHourVersion = gg.time.halfhourno()
    if halfHourVersion == self.halfHourVersion then
        return
    end
    self.halfHourVersion = halfHourVersion
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onHalfHourUpdate then
            obj:onHalfHourUpdate()
        elseif obj.exec then
            obj:exec("onHalfHourUpdate")
        end
    end
end

function cplayer:onHourUpdate()
    local hourVersion = gg.time.hourno()
    if hourVersion == self.hourVersion then
        return
    end
    self.hourVersion = hourVersion
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onHourUpdate then
            obj:onHourUpdate()
        elseif obj.exec then
            obj:exec("onHourUpdate")
        end
    end
end

function cplayer:onDayUpdate()
    local dayVersion = gg.time.dayno()
    if dayVersion == self.dayVersion then
        return
    end
    self.dayVersion = dayVersion
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onDayUpdate then
            obj:onDayUpdate()
        elseif obj.exec then
            obj:exec("onDayUpdate")
        end
    end
end

function cplayer:onMondayUpdate()
    local mondayVersion = gg.time.weekno()
    if mondayVersion == self.mondayVersion then
        return
    end
    self.mondayVersion = mondayVersion
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onMondayUpdate then
            obj:onMondayUpdate()
        elseif obj.exec then
            obj:exec("onMondayUpdate")
        end
    end
end

function cplayer:onSundayUpdate()
    local sundayVersion = gg.time.weekno(os.time(),gg.time.STARTTIME2)
    if sundayVersion == self.sundayVersion then
        return
    end
    self.sundayVersion = sundayVersion
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onSundayUpdate then
            obj:onSundayUpdate()
        elseif obj.exec then
            obj:exec("onSundayUpdate")
        end
    end
end


function cplayer:onMonthUpdate()
    local monthVersion = gg.time.monthno()
    if monthVersion == self.monthVersion then
        return
    end
    self.monthVersion = monthVersion
    for i=1,#self.ordered_component do
        local obj = self.ordered_component[i]
        if obj.onMonthUpdate then
            obj:onMonthUpdate()
        elseif obj.exec then
            obj:exec("onMonthUpdate")
        end
    end
end

--()
function cplayer:canItemUsedInSameTime(useType, id)
    return true
end

return cplayer
