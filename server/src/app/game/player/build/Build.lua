local Build = class("Build")

function Build.randomBuildLife(quality)
    local lifeInfo = nil
    local lifeCfg = cfg.get("etc.cfg.life")
    for k,v in pairs(lifeCfg) do
        if v.cfgId == constant.LIFE_TYPE_BUILD and v.quality == quality then
            lifeInfo =  v
            break
        end
    end
    if not lifeInfo then
        return constant.DEFAULT_LIFT
    end
    local minLift = lifeInfo.minLift
    local maxLift = lifeInfo.maxLift
    return math.random(minLift, maxLift)
end

function Build.getBuildCfg(cfgId, quality, level)
    local buildCfg = cfg.get("etc.cfg.build")
    for k,v in pairs(buildCfg) do
        if v.cfgId == cfgId and v.level == level and v.quality == quality then
            return v
        end
    end
    return nil
end

function Build.create(param)
    local cfgId = param.cfgId
    local level = param.level
    local quality = param.quality
    if not cfgId then
        assert(cfgId, "cfgId is nil")
        return nil
    end
    level = level or 0
    quality = quality or 1
    local buildCfg = Build.getBuildCfg(cfgId, quality, level)
    if not buildCfg then
        --
        assert(buildCfg, "cfg("..cfgId..") is nil, cfgId="..cfgId.." quality="..quality.." level="..level)
        return nil
    end
    param.cfg = buildCfg
    return Build.new(param)
end

function Build:ctor(param)
    self.player = param.player
    self.id = param.id or snowflake.uuid()                               -- uuid
    self.cfgId = param.cfgId                                             -- id
    self.level = param.level                                             --                                                -- 
    self.quality = param.quality                                         -- 
    self.life = param.life or constant.DEFAULT_LIFT                      -- 
    self.curLife = param.curLife or constant.DEFAULT_LIFT                -- 

    self.x = param.x or 0                                                -- x
    self.z = param.z or 0                                                -- z

    self.length = param.cfg.length or 0
    self.width = param.cfg.width or 0

    self.nextTick = param.nextTick or 0                                  -- 

    self.curStarCoin = 0                                                 -- 
    self.curIce = 0                                                      -- 
    self.curCarboxyl = 0                                                 -- 
    self.curTitanium = 0                                                 -- 
    self.curGas = 0                                                      -- 
    self.lastMakeTick = 0                                                -- 

    self.soliderCfgId = 0                                                -- id
    self.soliderCount = 0                                                -- 
    self.trainCfgId = 0                                                  -- id
    self.trainCount = 0                                                  -- 
    self.trainTick = 0                                                   -- 

    self.fightTick =  param.fightTick or 0

    self:refreshConfig(param.cfg)
end

function Build:refreshConfig(cfg)
    cfg = cfg or Build.getBuildCfg(self.cfgId, self.quality, self.level)
    assert(cfg, "config not found")

    self.type = cfg.type or 0
    self.subType = cfg.subType or 0
    self.perMakeStarCoin = cfg.perMakeStarCoin or 0
    self.maxMakeStarCoin = cfg.maxMakeStarCoin or 0
    self.perMakeIce = cfg.perMakeIce or 0
    self.maxMakeIce = cfg.maxMakeIce or 0
    self.perMakeCarboxyl = cfg.perMakeCarboxyl or 0
    self.maxMakeCarboxyl = cfg.maxMakeCarboxyl or 0
    self.perMakeTitanium = cfg.perMakeTitanium or 0
    self.maxMakeTitanium = cfg.maxMakeTitanium or 0
    self.perMakeGas = cfg.perMakeGas or 0
    self.maxMakeGas = cfg.maxMakeGas or 0
    self.storeStarCoin = cfg.storeStarCoin or 0
    self.storeIce = cfg.storeIce or 0
    self.storeCarboxyl = cfg.storeCarboxyl or 0
    self.storeTitanium = cfg.storeTitanium or 0
    self.storeGas = cfg.storeGas or 0
    self.maxTrainSpace = cfg.maxTrainSpace or 0
end

function Build:serialize()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.level = self.level
    data.quality = self.quality
    data.life = self.life
    data.curLife = self.curLife
    data.x = math.floor(self.x)
    data.z = math.floor(self.z)
    data.nextTick = self.nextTick
    data.curStarCoin = self.curStarCoin
    data.curIce = self.curIce
    data.curCarboxyl = self.curCarboxyl
    data.curTitanium = self.curTitanium
    data.curGas = self.curGas
    data.lastMakeTick = self.lastMakeTick
    data.soliderCfgId = self.soliderCfgId
    data.soliderCount = self.soliderCount
    data.trainCfgId = self.trainCfgId
    data.trainCount = self.trainCount
    data.trainTick = self.trainTick
    data.fightTick = self.fightTick
    return data
end

function Build:deserialize(data)
    self.cfgId = data.cfgId
    self.level = data.level
    self.quality = data.quality or 1
    self.life = data.life or -1
    self.curLife = data.curLife or -1
    self.x = math.floor(data.x)
    self.z = math.floor(data.z)
    self.nextTick = data.nextTick or 0
    self.curStarCoin = data.curStarCoin or 0
    self.curIce = data.curIce or 0
    self.curCarboxyl = data.curCarboxyl or 0
    self.curTitanium = data.curTitanium or 0
    self.curGas = data.curGas or 0
    self.lastMakeTick = data.lastMakeTick or 0
    self.soliderCfgId = data.soliderCfgId or 0
    self.soliderCount = data.soliderCount or 0
    self.trainCfgId = data.trainCfgId or 0
    self.trainCount = data.trainCount or 0
    self.trainTick = data.trainTick or 0
    self.fightTick = data.fightTick or 0
end

function Build:pack()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.level = self.level
    data.quality = self.quality
    data.life = self.life
    data.curLife = self.curLife
    data.pos = Vector3.New(self.x, 0, self.z)
    data.lessTick = self:getLessTick()
    data.curStarCoin = self.curStarCoin
    data.curIce = self.curIce
    data.curCarboxyl = self.curCarboxyl
    data.curTitanium = self.curTitanium
    data.curGas = self.curGas
    data.soliderCfgId = self.soliderCfgId
    data.soliderCount = self.soliderCount
    data.trainCfgId = self.trainCfgId
    data.trainCount = self.trainCount
    data.lessTrainTick = self:getLessTrainTick()
    return data
end

function Build:packFightData()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.level = self.level
    data.quality = self.quality
    data.life = self.life
    data.curLife = self.curLife
    data.pos = Vector3.New(self.x, 0, self.z)
    return data
end

function Build:toItemParam()
    local buildCfg = Build.getBuildCfg(self.cfgId, self.quality, self.level)
    if not buildCfg then
        return
    end
    if not buildCfg.itemCfgId then
        return
    end
    local data = {}
    data.cfgId = buildCfg.itemCfgId
    data.targetCfgId = self.cfgId
    data.targetLevel = self.level
    data.targetQuality = self.quality
    data.life = self.life
    data.curLife = self.curLife
    data.skillLevel1 = 0
    data.skillLevel2 = 0
    data.skillLevel3 = 0
    data.skillLevel4 = 0
    data.skillLevel5 = 0
    data.num = 1
    data.ref = 0
    return data
end

function Build:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick
end

function Build:getLessTick()
    if self.nextTick <= 0 then
        return 0
    end
    local nowTick = skynet.timestamp()
    local lessTick = math.floor((self.nextTick - nowTick) / 1000)
    if lessTick <= 0 then
        return 0
    end
    return lessTick
end

function Build:setNextTrainTick(needTick)
    self.trainTick = skynet.timestamp() + needTick
end

function Build:getLessTrainTick()
    if self.trainTick <= 0 then
        return 0
    end
    local nowTick = skynet.timestamp()
    local lessTrainTick = math.floor((self.trainTick - nowTick) / 1000)
    if lessTrainTick <= 0 then
        return 0
    end
    return lessTrainTick
end

function Build:setNewPos(x, z)
    self.x = math.floor(x)
    self.z = math.floor(z)
end

function Build:checkLevelUp(notNotify)
    if self.nextTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.nextTick then
        return
    end
    self.nextTick = 0
    if self.level == 0 and self.subType == constant.BUILD_SUBTYPE_MINE then
        local curMineLevel = self.player.buildBag:getMineLevel(self.cfgId)
        self.level = curMineLevel
    else
        self.level = self.level + 1
    end
    self:refreshConfig()
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = self:pack() })
    end
    --,
    if self.cfgId == constant.BUILD_HYPERSPACERESEARCH then
        self.player.buildBag:refreshSoliderLevel()
        self.player.buildBag:refreshMineLevel()
    end
end

function Build:checkTrainFinish(notNotify)
    if self.trainTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.trainTick then
        return
    end
    self.soliderCfgId = self.trainCfgId
    self.soliderCount = self.soliderCount + self.trainCount
    self.trainCfgId = 0
    self.trainCount = 0
    self.trainTick = 0
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = self:pack() })
    end
end

function Build:setMakeTick()
    if self.perMakeStarCoin <= 0 and self.perMakeIce <= 0 and self.perMakeCarboxyl <= 0 and self.perMakeTitanium <= 0 and self.perMakeGas <= 0 then
        return
    end
    self.lastMakeTick = skynet.timestamp()
end

function Build:makeRes(notNotify)
    if self.perMakeStarCoin <= 0 and self.perMakeIce <= 0 and self.perMakeCarboxyl <= 0 and self.perMakeTitanium <= 0 and self.perMakeGas <= 0 then
        return
    end
    local perSeconds = 30 * 60
    --local perSeconds = 1 * 60

    local count = 0
    local nowTick = skynet.timestamp()
    if self.lastMakeTick > 0 then
        local tempTick = math.floor((nowTick - self.lastMakeTick) / 1000)
        count = math.floor(tempTick / perSeconds)
        self.lastMakeTick = nowTick - (tempTick % perSeconds) * 1000
    else
        self.lastMakeTick = nowTick
    end
    if count > 0 then
        local tempStarCoin = math.floor(self.perMakeStarCoin * count * self.player.pledgeBag:getRatio(constant.RES_STARCOIN))
        local tempIce = math.floor(self.perMakeIce * count * self.player.pledgeBag:getRatio(constant.RES_ICE))
        local tempCarboxyl = math.floor(self.perMakeCarboxyl * count * self.player.pledgeBag:getRatio(constant.RES_CARBOXYL))
        local tempTitanium = math.floor(self.perMakeTitanium * count * self.player.pledgeBag:getRatio(constant.RES_TITANIUM))
        local tempGas = math.floor(self.perMakeGas * count * self.player.pledgeBag:getRatio(constant.RES_GAS))

        self.curStarCoin = math.min(self.curStarCoin + tempStarCoin, self.maxMakeStarCoin)
        self.curIce = math.min(self.curIce + tempIce, self.maxMakeIce)
        self.curCarboxyl = math.min(self.curCarboxyl + tempCarboxyl, self.maxMakeCarboxyl)
        self.curTitanium = math.min(self.curTitanium + tempTitanium, self.maxMakeTitanium)
        self.curGas = math.min(self.curGas + tempGas, self.maxMakeGas)

        if not notNotify then
            gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = self:pack() })
        end
    end
end

function Build:setFightTick(tick)
    self.fightTick = tick
end

function Build:setCurLife(life)
    self.curLife = life
end

return Build