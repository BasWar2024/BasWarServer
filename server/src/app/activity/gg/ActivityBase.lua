local ActivityBase = class("ActivityBase")


function ActivityBase:ctor(cfgId)
    self.dirty = false
    self.savetick = 300
    self.savename = "activity"
    self.cfgId = cfgId
end

function ActivityBase:init(cfg)
    local ok = self:load_from_db()
    if not ok then
        self.dirty = true
        self:save_to_db()
    end
end

function ActivityBase:exit()
    self.dirty = true
    self:save_to_db()
end

function ActivityBase:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    gg.mongoProxy.activity:update({cfgId = self.cfgId}, data, true, false)
    self.dirty = false
end

function ActivityBase:load_from_db()
    local data = gg.mongoProxy.activity:findOne({ cfgId = self.cfgId })
    if not data then
        return false
    end
    self:deserialize(data)
    return true
end

function ActivityBase:serialize()
    local data = {}
    data.cfgId = self.cfgId
    return data
end

function ActivityBase:deserialize(data)
    if not data then
        return
    end
    self.cfgId = data.cfgId
end

function ActivityBase:getActCfg()
    local activities = gg.getExcelCfg("activities")
    return activities[self.cfgId]
end

function ActivityBase:isValid()
    return true
end

function ActivityBase:checkStartTimeout()
end

function ActivityBase:onStartTimeout()
end

--""
function ActivityBase:checkEndTimeout()
end

function ActivityBase:onEndTimeout()
end


function ActivityBase:onSecond()
    self:checkStartTimeout()
    self:checkEndTimeout()
end

function ActivityBase:onMinute()
end

function ActivityBase:onFiveMinute()

end

return ActivityBase