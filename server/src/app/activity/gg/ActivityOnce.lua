local ActivityOnce = class("ActivityOnce", ggclass.ActivityBase)

function ActivityOnce:ctor(cfgId)
    ActivityOnce.super.ctor(self, cfgId)
    self.isReward = false
end

function ActivityOnce:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.isReward = self.isReward
    return data
end

function ActivityOnce:deserialize(data)
    if not data then
        return
    end
    self.cfgId = data.cfgId
    self.isReward = data.isReward
end

function ActivityOnce:isValid()
    local cfg = self:getActCfg()
    if not cfg then
        return false
    end
    if cfg.status == 0 then
        return false
    end
    return util.betweenCfgTime(cfg, "startTime", "endTime")
end


--""
function ActivityOnce:checkStartTimeout()
    if not self:isValid() then
        return
    end
    local cfg = self:getActCfg()
    local now = gg.time.time()
    local startTime = string.totime(cfg.startTime)
    if now < startTime then
        return
    end
    self:onStartTimeout()
    self.dirty = true
end

function ActivityOnce:onStartTimeout()
end

--""
function ActivityOnce:checkEndTimeout()
    if not self:isValid() then
        return
    end
    local cfg = self:getActCfg()
    local now = gg.time.time()
    local endTime = string.totime(cfg.endTime)
    if now < endTime then
        return
    end
    self:onEndTimeout()
    self.dirty = true
end

function ActivityOnce:onEndTimeout()
end

function ActivityOnce:getRankReward(rank)
    local cfg = self:getActCfg()
    if not cfg then
        return
    end
    if not cfg.rewardCfgId then
        return
    end
    local reward
    local activitiesReward = gg.getExcelCfg("activitiesReward")
    for k, v in pairs(activitiesReward) do
        if v.cfgId == cfg.rewardCfgId then
            if rank >= v.startRank and rank <= v.endRank then
                reward = {
                    resReward = v.resReward,
                    itemReward = v.itemReward,
                    resReward2 = v.resReward2,
                    itemReward2 = v.itemReward2,
                }
                break
            end
        end
    end
    return reward
end

function ActivityOnce:fomatMailItems(reward, itype, mailItems)
    for i, v in ipairs(reward or {}) do
        table.insert(mailItems, {
            cfgId = v[1],
            count = v[2],
            type = itype,
        })
    end
end

function ActivityOnce:onMinute()
end

return ActivityOnce
