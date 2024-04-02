local UnionSolider = class("UnionSolider")


function UnionSolider.getSoliderCfg(cfgId, level)
    local key = string.format("%s_%s", cfgId, level)
    local soliderCfgs = cfg.get("etc.cfg.soliderConfig")
    return soliderCfgs[key]
end

function UnionSolider:ctor(param)
    self.union = param.union
    self.cfgId = 0      --""id
    self.count = 0      --""
    self.genCount = 0   --""
    self.genTick = 0
    self.level = 0
    self.hpAddRatio = 0
    self.atkAddRatio = 0
    self.atkSpeedAddRatio = 0
end

function UnionSolider:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.count = self.count
    data.genCount = self.genCount
    data.genTick = self.genTick
    data.level = self.level
    data.hpAddRatio = self.hpAddRatio
    data.atkAddRatio = self.atkAddRatio
    data.atkSpeedAddRatio = self.atkSpeedAddRatio
    return data
end

function UnionSolider:deserialize(data)
    if not data then
        return
    end
    assert(data.cfgId > 0, "UnionSolider cfgId is 0")
    self.cfgId = data.cfgId
    self.count = data.count or 0
    self.genCount = data.genCount or 0
    self.genTick = data.genTick or 0
    self.level = data.level or 0
    self.hpAddRatio = data.hpAddRatio or 0
    self.atkAddRatio = data.atkAddRatio or 0
    self.atkSpeedAddRatio = data.atkSpeedAddRatio or 0
end

function UnionSolider:setGenTick()
    local cfg = UnionSolider.getSoliderCfg(self.cfgId, self.level)
    self.genTick = skynet.timestamp() + cfg.trainNeedTick * 1000
end

function UnionSolider:canGenSolider(soliderCount)
    local soliderCfg = UnionSolider.getSoliderCfg(self.cfgId, self.level)
    if not soliderCfg then
        return false
    end
    if self.count + self.genCount + soliderCount > soliderCfg.unionLimit then
        return false
    end
    return true
end

function UnionSolider:getGenStarCoin(soliderCount)
    local cfg = UnionSolider.getSoliderCfg(self.cfgId, self.level)
    if not cfg then
        return 0
    end
    return cfg.trainNeedStarCoin * soliderCount
end

function UnionSolider:addGenSolider(num)
    if self.genCount == 0 then
        self:setGenTick()
    end
    self.genCount = self.genCount + num
end

function UnionSolider:gmAddGenSolider()
    if self.genCount > 0 then
        self.count = self.count + self.genCount
        self.genCount = 0
        self.genTick = 0
    end
end

function UnionSolider:checkGen()
    if self.genCount == 0 then
        return
    end
    if self.genTick == 0 then --""
        return
    end
    if skynet.timestamp() < self.genTick then
        return
    end
    self.genCount = self.genCount - 1
    self.count = self.count + 1
    if self.genCount > 0 then
        self:setGenTick()
    else
        self.genTick = 0
    end
    self.union:onUnionSoliderGen()
end

function UnionSolider:getLessTick()
    if not self.genTick then
        return 0
    end
    if self.genTick == 0 or skynet.timestamp() > self.genTick then
        -- self.genTick = 0
        return 0
    end
    return math.floor((self.genTick - skynet.timestamp()) / 1000)
end

function UnionSolider:onSecond()
    self:checkGen()
end

return UnionSolider