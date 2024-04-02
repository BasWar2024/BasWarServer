
local UnionTech = class("UnionTech")

function UnionTech.getUnionTechCfg(cfgId, level)
    local techCfgs = cfg.get("etc.cfg.unionTechConfig")
    return techCfgs[string.format("%s_%s", tostring(cfgId), tostring(level))]
end

function UnionTech.getUnionTechEffectCfg(effectCfgId)
    local effectCfgs = cfg.get("etc.cfg.unionTechEffect")
    return effectCfgs[effectCfgId]
end

function UnionTech:ctor(param)
    self.union = param.union
    self.cfgId = 0
    self.level = 0
    self.levelUpTick = 0
end

function UnionTech:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.level = self.level
    data.levelUpTick = self.levelUpTick
    return data
end

function UnionTech:deserialize(data)
    if not data then
        return
    end
    assert(data.cfgId, "union tech cfgId is nil")
    self.cfgId = data.cfgId
    self.level = data.level or 1
    self.levelUpTick = data.levelUpTick or 0
end

function UnionTech:hasNextLevel()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level + 1)
    if not techConfig then
        return false
    end
    return true
end

function UnionTech:getPresetTechs()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    return techConfig.presetTechs
end

function UnionTech:getLevelUpStarCoin()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    return techConfig.levelUpNeedStarCoin
end

function UnionTech:getLevelUpIce()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    return techConfig.levelUpNeedIce
end

function UnionTech:getLevelUpTitanium()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    return techConfig.levelUpNeedTitanium
end

function UnionTech:getLevelUpGas()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    return techConfig.levelUpNeedGas
end

function UnionTech:getLevelUpCarboxyl()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    return 0--techConfig.levelUpNeedCarboxyl
end

function UnionTech:getLevelUpMit()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    return techConfig.levelUpNeedMit
end

function UnionTech:setLevelUpTick()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    self.levelUpTick = skynet.timestamp() + techConfig.levelUpNeedTime * 1000
end

function UnionTech:checkLevelUp()
    if self.levelUpTick == 0 or skynet.timestamp() < self.levelUpTick then
        return
    end
    
    self.levelUpTick = 0
    self.level = self.level + 1
    self.union:onUnionTechLevelUp()
end

function UnionTech:getLessTick()
    if not self.levelUpTick then
        return 0
    end
    if self.levelUpTick == 0 or skynet.timestamp() > self.levelUpTick then
        self.levelUpTick = 0
        return 0
    end
    return math.floor((self.levelUpTick - skynet.timestamp()) / 1000)
end

function UnionTech:getMod()
    local techConfig = UnionTech.getUnionTechCfg(self.cfgId, self.level)
    if not techConfig then
        return
    end
    return techConfig.mod
end

function UnionTech:onSecond()
    self:checkLevelUp()
end

return UnionTech