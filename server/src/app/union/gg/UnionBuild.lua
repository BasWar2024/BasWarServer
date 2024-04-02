local UnionBuild = class("UnionBuild")

function UnionBuild.getBuildCfg(buildCfgId, level)
    return gg.getExcelCfgByFormat("buildConfig", buildCfgId, 0, level)
    -- local key = string.format("%s_%s_%s", buildCfgId, 0, level)
    -- local buildCfgs = cfg.get("etc.cfg.buildConfig")
    -- return buildCfgs[key]
end

function UnionBuild:ctor(param)
    self.union = param.union
    self.cfgId = 0
    self.count = 0      --""
    self.genCount = 0 --""
    self.genTick = 0
    self.level = 0
    self.hpAddRatio = 0
    self.atkAddRatio = 0
    self.atkSpeedAddRatio = 0
end

function UnionBuild:serialize()
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

function UnionBuild:deserialize(data)
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

function UnionBuild:pack()
    local data = {}
    data.cfgId = self.cfgId
    data.count = self.count
    data.level = self.level
    return data
end


function UnionBuild:setGenTick()
    local cfg = UnionBuild.getBuildCfg(self.cfgId, self.level)
    self.genTick = skynet.timestamp() + cfg.trainNeedTick * 1000
end

--""
function UnionBuild:canGenBuilds(buildCount)
    local buildCfg = UnionBuild.getBuildCfg(self.cfgId, self.level)
    if not buildCfg then
        return false
    end
    if self.count + self.genCount + buildCount > buildCfg.unionLimit then
        return false
    end
    return true
end

function UnionBuild:getGenStarCoin(buildCount)
    local buildCfg = UnionBuild.getBuildCfg(self.cfgId, self.level)
    if not buildCfg then
        return 0
    end
    return buildCfg.levelUpNeedStarCoin * buildCount
end

function UnionBuild:getGenIce(buildCount)
    local buildCfg = UnionBuild.getBuildCfg(self.cfgId, self.level)
    if not buildCfg then
        return 0
    end
    return buildCfg.levelUpNeedIce * buildCount
end

function UnionBuild:getGenTitanium(buildCount)
    local buildCfg = UnionBuild.getBuildCfg(self.cfgId, self.level)
    if not buildCfg then
        return 0
    end
    return buildCfg.levelUpNeedTitanium * buildCount
end

function UnionBuild:getGenGas(buildCount)
    local buildCfg = UnionBuild.getBuildCfg(self.cfgId, self.level)
    if not buildCfg then
        return 0
    end
    return buildCfg.levelUpNeedGas * buildCount
end

function UnionBuild:getGenCarboxyl(buildCount)
    local buildCfg = UnionBuild.getBuildCfg(self.cfgId, self.level)
    if not buildCfg then
        return 0
    end
    return 0--buildCfg.levelUpNeedCarboxyl * buildCount
end

function UnionBuild:addGenBuilds(buildCount)
    if self.genCount == 0 then
        self:setGenTick()
    end
    self.genCount = self.genCount + buildCount
end

function UnionBuild:checkGenBuilds()
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
    self.union:onUnionBuildGen()
end

function UnionBuild:getLessTick()
    if not self.genTick then
        return 0
    end
    if self.genTick == 0 or skynet.timestamp() > self.genTick then
        self.genTick = 0
        return 0
    end
    return math.floor((self.genTick - skynet.timestamp()) / 1000)
end

function UnionBuild:onSecond()
    self:checkGenBuilds()
end

return UnionBuild