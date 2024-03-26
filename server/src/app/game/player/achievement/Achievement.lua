local Achievement = class("Achievement")

function Achievement.getAchievementCfg(index)
    if not index or index == 0 then
        return
    end
    local cfgMap = cfg.get("etc.cfg.achievement")
    return cfgMap[index]
end

function Achievement:ctor(param)
    self.player = param.player
    self.index = param.index or 0
    self.cfgId = param.cfgId or 0
    self.value = param.value or 0
    self.drawed = param.drawed or false
end

function Achievement:serialize()
    local data = {}
    data.index = self.index
    data.cfgId = self.cfgId
    data.value = self.value
    data.drawed = self.drawed
    return data
end

function Achievement:deserialize(data)
    self.index = data.index or 0
    self.cfgId = data.cfgId or 0
    self.value = data.value or 0
    self.drawed = data.drawed or false
end

function Achievement:pack()
    local data = {}
    data.index = self.index
    data.value = self.value
    data.drawed = self.drawed
    return data
end

function Achievement:setValue(value)
    local cfgInfo = Achievement.getAchievementCfg(self.index)
    if not cfgInfo then
        return false
    end
    if self.value >= cfgInfo.targetValue then
        return false
    end
    self.value = math.min(value, cfgInfo.targetValue)
    return true
end

function Achievement:addValue(value)
    local cfgInfo = Achievement.getAchievementCfg(self.index)
    if not cfgInfo then
        return false
    end
    if self.value >= cfgInfo.targetValue then
        return false
    end
    self.value = math.min(cfgInfo.targetValue, self.value+value)
    return true
end

return Achievement