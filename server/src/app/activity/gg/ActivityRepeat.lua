local ActivityRepeat = class("ActivityRepeat", ggclass.ActivityBase)

function ActivityRepeat:ctor(cfgId)
    ActivityRepeat.super.ctor(self, cfgId)
    self.startTime = 0
end

function ActivityRepeat:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.startTime = self.startTime
    return data
end

function ActivityRepeat:deserialize(data)
    if not data then
        return
    end
    self.cfgId = data.cfgId
    self.startTime = data.startTime or 0

    if self.startTime == 0 then
        local now = gg.time.time()
        local cfg = self:getActCfg()
        local startTime = string.totime(cfg.startTime)
        if startTime >= now then
            self.startTime = startTime
        else
            self.startTime = now
        end
    end
end

function ActivityRepeat:isValid()
    local cfg = self:getActCfg()
    if not cfg then
        return false
    end
    if cfg.status == 0 then
        return false
    end
    local now = gg.time.time()
    local startTime = self.startTime
    local endTime = startTime + cfg.duration * 3600
    if now < startTime or now > endTime then
        return false
    end
    return true
end


--""
function ActivityRepeat:checkStartTimeout()
    if not self:isValid() then
        return
    end
    local now = gg.time.time()
    if now < self.startTime then
        return
    end
    self:onStartTimeout()
    self.dirty = true
end

function ActivityRepeat:onStartTimeout()
end

--""
function ActivityRepeat:checkEndTimeout()
    if not self:isValid() then
        return
    end
    local now = gg.time.time()
    local cfg = self:getActCfg()
    local endTime = self.startTime + cfg.duration * 3600
    if now < endTime then
        return
    end
    self:onEndTimeout()
    self.dirty = true
end

function ActivityRepeat:onEndTimeout()
    local cfg = self:getActCfg()
    local now = gg.time.time()
    self.startTime = now + cfg.interval * 3600
end

function ActivityRepeat:onMinute()
end

return ActivityRepeat
