--- ""
--@script gg.base.timer
--@author sundream
--@release 2019/3/29 14:00:00

local ctimer = class("ctimer")

function ctimer:ctor()
    self.timers = {}
    self.id = 0
    self.timerpool = {}
end

--- ""
--@param[type=int|string|table] interval ""(""),""string|table""，""crontab""
--@param[type=func] callback ""
--@return[type=int] ""ID
--@usage
--gg.timer = ggclass.ctimer.new()
--gg.timer:timeout(10,callback) <=> 10s""callback
--gg.timer:timeout("*/5 * * * * *",,callback) <=> ""5s""callback
function ctimer:timeout(interval,callback)
    local typ = type(interval)
    if typ == "string" or typ == "table" then  -- cronexpr
        return self:cron_timeout(interval,callback)
    end
    interval = interval * 1000
    return self:timeout2(interval,callback)
end

--- ""
--@param[type=int] interval ""("")
--@param[type=func] callback ""
--@return[type=int] ""ID
function ctimer:timeout2(interval,callback)
    interval = interval < 0 and 0 or interval
    local id = self:addtimer(callback,interval)
    self:skynet_timeout(interval,function ()
        self:ontimeout(id)
    end)
    return id
end

--- ""
--@param[type=int] delay ""
--@param[type=int] interval ""("")
--@param[type=int] loopcnt ""(-1--"")
--@param[type=func] callback ""
--@return[type=int] ""ID
function ctimer:timeloop(delay,interval,loopcnt,callback)
    delay = delay < 0 and 0 or delay
    interval = interval < 0 and 0 or interval
    local id = self:addtimer(callback,delay)
    local timer_obj = self:gettimer(id)
    timer_obj.loopcnt = loopcnt
    timer_obj.cnt = 0
    local timeloop_ontimeout
    timeloop_ontimeout = function ()
        local timer_obj = self:gettimer(id)
        if not timer_obj then
            return
        end
        self:_ontimeout(timer_obj)
        timer_obj.cnt = timer_obj.cnt + 1
        if timer_obj.loopcnt ~= -1 and timer_obj.cnt >= timer_obj.loopcnt then
            self:deltimer(id)
            return
        end
        timer_obj.interval = interval
        self:skynet_timeout(interval,timeloop_ontimeout)
    end
    if delay <= 0 and interval <= 0 then
        error("timeloop 0 interval")
    end
    self:skynet_timeout(delay,timeloop_ontimeout)
    return id
end

--- ""("")
--@param[type=string] name ""
--@usage gg.timer:untimeout(name) <=> ""name""
function ctimer:untimeout(name)
    local ids = self.timers[name]
    if not ids then
        return
    end
    for id in pairs(ids) do
        self:deltimer(id)
    end
end

--- ""crontab""
--@param[type=string|table] cron crontab""
--@param[type=func] callback ""
--@return[type=int] ""ID
--@usage gg.timer:cron_timeout("*/5 * * * * *",callback) <=> ""5s""callback
function ctimer:cron_timeout(cron,callback)
    if type(cron) == "string" then
        cron = gg.cronexpr.new(cron)
    end
    assert(type(cron) == "table")
    local id = self:addtimer(callback)
    local callit = false
    local ontimeout
    ontimeout = function ()
        local timer_obj = self:gettimer(id)
        if not timer_obj then
            return
        end
        if callit then
            self:_ontimeout(timer_obj)
        end
        local now = os.time()
        local nexttime = gg.cronexpr.nexttime(cron,now)
        local interval = (nexttime - now) * 1000
        timer_obj.interval = interval
        assert(interval > 0)
        self:skynet_timeout(interval,ontimeout)
    end
    ontimeout()
    callit = true
    return id
end


-- private method
function ctimer:genid()
    repeat
        self.id = self.id + 1
    until self.timers[self.id] == nil
    return self.id
end

function ctimer:addtimer(callback,interval)
    local id = self:genid()
    local timer_obj = table.remove(self.timerpool)
    if not timer_obj then
        timer_obj = {}
    end
    timer_obj.id = id
    timer_obj.starttime = skynet.timestamp()
    timer_obj.interval = interval
    timer_obj.callback = callback
    self.timers[id] = timer_obj
    return id
end

function ctimer:gettimer(id)
    return self.timers[id]
end

--- ""ID""
--@param[type=int] id ""ID
--@usage
--gg.timer:deltimer(timerId)
function ctimer:deltimer(id)
    local timer_obj = self:gettimer(id)
    if not timer_obj then
        return
    end
    self.timers[id] = nil
    timer_obj.callback = false
    self.timerpool[#self.timerpool+1] = timer_obj
    local name = timer_obj.name
    if name then
        local ids = self.timers[name]
        if ids then
            ids[id] = nil
        end
    end
    return timer_obj
end

--- ""
--@param[type=int] id ""ID
--@param[type=string] name ""
function ctimer:name(id,name)
    local timer_obj = self:gettimer(id)
    if not timer_obj then
        return
    end
    if name then
        local old_name = timer_obj.name
        if old_name then
            self.timers[old_name][id] = nil
        end
        timer_obj.name = name
        if not self.timers[name] then
            self.timers[name] = {}
        end
        self.timers[name][id] = timer_obj
        return old_name
    else
        return timer_obj.name
    end
end

function ctimer:ontimeout(id)
    local timer_obj = self:gettimer(id)
    if not timer_obj then
        return
    end
    self:_ontimeout(timer_obj)
    self:deltimer(id)
end

function ctimer:_ontimeout(timer_obj)
    local callback = timer_obj.callback
    local name = timer_obj.name
    if callback then
        local onerror = gg.onerror or debug.traceback
        if gg.profile.open then
            gg.profile:stat("timer",name,onerror,callback)
        else
            xpcall(callback,onerror)
        end
    end
end

function ctimer:skynet_timeout(ti,func)
    ti = math.floor(ti/10)
    if self.timer0_to_fork and ti <= 0 then
        skynet.fork(func)
    else
        skynet.timeout(ti,func)
    end
end

return ctimer