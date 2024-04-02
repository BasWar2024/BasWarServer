local ActivityMgr = class("ActivityMgr")

function ActivityMgr:ctor()
    self.activities = {}
end

function ActivityMgr:init()
    self:addNewActivitys()
end

function ActivityMgr:addNewActivitys()
    local activities = gg.getExcelCfg("activities")
    for k, v in pairs(activities or {}) do
        if not self.activities[v.cfgId] then
            skynet.fork(function(cfg)
                local activity = ggclass[cfg.actClass].new(cfg.cfgId)
                if activity:isValid() then
                    activity:init(cfg)
                    self.activities[cfg.cfgId] = activity
                    gg.savemgr:autosave(activity)
                end
            end, v)
        end
    end
end

function ActivityMgr:clearInvalidActivities()
    local invalidIds = {}
    for cfgId, v in pairs(self.activities) do
        if not v:isValid() then
            table.insert(invalidIds, cfgId)
            v:exit()
            gg.savemgr:closesave(v)
        end
    end
    for _, cfgId in pairs(invalidIds) do
        local activity = self.activities[cfgId]
        if activity then
            self.activities[cfgId] = nil
            activity = nil
        end
    end
end

function ActivityMgr:updateActivityData(cfgId, data)
    local activity = self.activities[cfgId]
    if not activity then
        return
    end
    activity:updateActivityData(data)
end

function ActivityMgr:actFirstGetGridRank(pid, cfgId)
    local activity = self.activities[cfgId]
    if not activity then
        return {}
    end
    return activity:getActRankList(pid)
end

function ActivityMgr:onSecond()
    for _, activity in pairs(self.activities) do
        skynet.fork(function()
            activity:onSecond()
        end)
    end
end

function ActivityMgr:onMinuteUpdate()
    for _, activity in pairs(self.activities) do
        skynet.fork(function()
            activity:onMinute()
        end)
    end
    self:clearInvalidActivities()
    self:addNewActivitys()
end

function ActivityMgr:onFiveMinuteUpdate()
    for _, activity in pairs(self.activities) do
        skynet.fork(function()
            activity:onFiveMinute()
        end)
    end
end

function ActivityMgr:exit()
    for _, activity in pairs(self.activities) do
        activity:exit()
        gg.savemgr:closesave(activity)
    end
end

function ActivityMgr:saveall()
    for _, activity in pairs(self.activities) do
        activity:save_to_db()
    end
end


return ActivityMgr