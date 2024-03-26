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
    return gg.getExcelCfgByFormat("buildConfig", cfgId, quality, level)
    -- local key = string.format("%s_%s_%s", cfgId, quality, level)
    -- local buildCfgs = cfg.get("etc.cfg.buildConfig")
    -- return buildCfgs[key]
end

function Build.getNFTBuildCfg(race, style, quality, level)
    return gg.getExcelCfgByFormat("buildNftConfig", race, style, quality, level)
    -- local key = string.format("%s_%s_%s_%s", race, style, quality, level)
    -- local buildCfgs = cfg.get("etc.cfg.buildNftConfig")
    -- return buildCfgs[key]
end

function Build.getBuildSize(buildId)
    if not buildId then
        return nil
    end
    local key = string.format("%s_%s_%s", buildId, "1", "1")
    local buildCfgs = cfg.get("etc.cfg.buildConfig")
    local buildCfg = buildCfgs[key]
    if not buildCfg then
        return nil
    end
    local buildSize = {}
    buildSize.width = buildCfg.width
    buildSize.length = buildCfg.length
    return buildSize
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
    quality = quality or 0
    local buildCfg = Build.getBuildCfg(cfgId, quality, level)
    if not buildCfg then
        --""
        return nil
    end
    param.cfg = buildCfg
    return Build.new(param)
end

function Build:ctor(param)
    self.player = param.player
    self.id = param.id or snowflake.uuid()                               -- ""uuid
    self.cfgId = param.cfgId                                             -- ""id
    self.level = param.level                                             -- ""                                               -- ""
    self.quality = param.quality                                         -- ""
    self.race = param.race                                               -- ""
    self.style = param.style                                             -- ""
    self.life = param.life or constant.DEFAULT_LIFT                      -- ""
    self.curLife = param.curLife or constant.DEFAULT_LIFT                -- ""

    self.x = param.x or 0                                                -- ""x""
    self.z = param.z or 0                                                -- ""z""

    self.length = param.cfg.length or 0
    self.width = param.cfg.width or 0

    self.nextTick = param.nextTick or 0                                  -- ""

    self.curStarCoin = 0                                                 -- ""
    self.curIce = 0                                                      -- ""
    self.curCarboxyl = 0                                                 -- ""
    self.curTitanium = 0                                                 -- ""  
    self.curGas = 0                                                      -- ""
    self.lastMakeTick = 0                                                -- ""

    self.soliderCfgId = 0                                                -- ""id
    self.soliderCount = 0                                                -- ""
    self.trainCfgId = 0                                                  -- ""id
    self.trainCount = 0                                                  -- ""
    self.trainTick = 0                                                   -- ""

    self.fightTick =  param.fightTick or 0                               --""

    self.chain = param.chain or 0                                        --NFT""id,0""
    self.ownerPid = param.ownerPid or 0                                  --""(""chain>0"")

    self.ref = param.ref or 0                                --0-"" 1-"" 2-"" 3-"" 4-"" 5-""("")
    self.refBy = param.refBy or 0                            --""ref>0"","", ""item"", ""ref=4, refBy=0, "", ""refBy>0
    self.donateTime = param.donateTime or 0
    self.mintCount = param.mintCount or 0
    self.isNormal = param.isNormal or false                                        --"",""NFT""true

    self:refreshConfig(param.cfg)
end

function Build:refreshConfig(cfg)
    if not self.cfgId or self.cfgId == 0 then
        return
    end
    self.cfg = cfg or Build.getBuildCfg(self.cfgId, self.quality or 0, self.level or 0)
    assert(self.cfg, "config not found")

    self.race = self.race or self.cfg.race
    self.style = self.style or self.cfg.style
    self.type = self.cfg.type or 0
    self.subType = self.cfg.subType or 0
end

function Build:serialize()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.level = self.level
    data.quality = self.quality
    data.race = self.race
    data.style = self.style
    data.type = self.cfg.type
    data.subType = self.subType
    data.life = self.life
    data.curLife = self.curLife
    data.x = self.x
    data.z = self.z
    data.nextTick = util.getSaveVal(self.nextTick)
    data.curStarCoin = util.getSaveVal(math.floor(self.curStarCoin))
    data.curIce = util.getSaveVal(math.floor(self.curIce))
    data.curCarboxyl = util.getSaveVal(math.floor(self.curCarboxyl))
    data.curTitanium = util.getSaveVal(math.floor(self.curTitanium))
    data.curGas = util.getSaveVal(math.floor(self.curGas))
    data.lastMakeTick = util.getSaveVal(self.lastMakeTick)
    data.soliderCfgId = util.getSaveVal(self.soliderCfgId)
    data.soliderCount = util.getSaveVal(self.soliderCount)
    data.trainCfgId = util.getSaveVal(self.trainCfgId)
    data.trainCount = util.getSaveVal(self.trainCount)
    data.trainTick = util.getSaveVal(self.trainTick)
    data.fightTick = util.getSaveVal(self.fightTick)
    data.chain = self.chain

    data.ref = util.getSaveVal(self.ref)
    data.refBy = util.getSaveVal(self.refBy)
    data.donateTime = util.getSaveVal(self.donateTime)
    data.ownerPid = util.getSaveVal(self.ownerPid)
    data.mintCount = util.getSaveVal(self.mintCount)
    data.isNormal = self.isNormal
    return data
end

function Build:deserialize(data)
    self.cfgId = data.cfgId
    self.level = data.level or 1
    self.quality = data.quality or constant.BUILD_INIT_QUALITY
    self.race = data.race
    self.style = data.style
    self.type = data.type
    self.subType = data.subType
    self.life = data.life or -1
    self.curLife = data.curLife or -1
    self.x = data.x or 0
    self.z = data.z or 0
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
    self.chain = data.chain or 0
    self:refreshConfig()

    self.ref = data.ref or 0
    self.refBy = data.refBy or 0
    self.donateTime = data.donateTime or 0
    self.ownerPid = data.ownerPid or 0
    self.mintCount = data.mintCount or 0
    self.isNormal = data.isNormal or false
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
    data.curStarCoin = math.floor(self.curStarCoin)
    data.curIce = math.floor(self.curIce)
    data.curCarboxyl = math.floor(self.curCarboxyl)
    data.curTitanium = math.floor(self.curTitanium)
    data.curGas = math.floor(self.curGas)
    data.soliderCfgId = self.soliderCfgId
    data.soliderCount = self.soliderCount
    data.trainCfgId = self.trainCfgId
    data.trainCount = self.trainCount
    data.lessTrainTick = self:getLessTrainTick()
    data.chain = self.chain

    data.ref = self.ref
    data.refBy = self.refBy
    data.donateTime = self.donateTime
    data.ownerPid = self.ownerPid
    data.mintCount = self.mintCount
    return data
end

function Build:packToLog()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.quality = self.quality
    data.race = self.race
    data.style = self.style
    data.level = self.level
    data.life = self.life
    data.curLife = self.curLife
    data.chain = self.chain
    return data
end

function Build:packToDonate()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.level = self.level
    data.quality = self.quality
    data.race = self.race
    data.style = self.style
    data.type = self.cfg.type
    data.subType = self.subType
    data.life = self.life
    data.curLife = self.curLife
    data.x = self.x
    data.z = self.z
    data.nextTick = self.nextTick
    data.curStarCoin = math.floor(self.curStarCoin)
    data.curIce = math.floor(self.curIce)
    data.curCarboxyl = math.floor(self.curCarboxyl)
    data.curTitanium = math.floor(self.curTitanium)
    data.curGas = math.floor(self.curGas)
    data.lastMakeTick = self.lastMakeTick
    data.soliderCfgId = self.soliderCfgId
    data.soliderCount = self.soliderCount
    data.trainCfgId = self.trainCfgId
    data.trainCount = self.trainCount
    data.trainTick = self.trainTick
    data.fightTick = self.fightTick
    data.chain = self.chain

    data.ref = self.ref
    data.refBy = self.refBy
    data.donateTime = self.donateTime
    data.ownerPid = self.ownerPid
    data.mintCount = self.mintCount

    data.isLevelUp = self:isLevelUp()
    data.isUpgrade = self:isUpgrade()
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

function Build:setNewPos(x, z)
    self.x = x
    self.z = z
end

function Build:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick
    --constant.setRef(self, constant.REF_LEVELUP)
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

function Build:checkLevelUp(notNotify)
    if self.nextTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.nextTick then
        return
    end
    self.nextTick = 0
    -- ""
    if constant.IsRefLevelUp(self) then
        constant.cancelRef(self, constant.REF_LEVELUP)
    end
    self.level = self.level + 1
    self:refreshConfig()
    self.player.taskBag:update(constant.TASK_BUILD_LV_COUNT, {cfgId = self.cfgId, lv = self.level, count = 1, lvup = true})
    self.player.taskBag:update(constant.TASK_BUILD_LVUP_COUNT, {cfgId = self.cfgId, lv = self.level, count = 1})
    self.player.buildBag:addConstructionCount(self.cfgId, self.quality, self.level)

    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = self:pack() })
    end
    --"",""
    if self.cfgId == constant.BUILD_HYPERSPACERESEARCH then
        -- self.player.buildBag:refreshSoliderLevel()
    elseif self.cfgId == constant.BUILD_BASE then --""
        self.player.buildBag:refreshSoliderLevel()
        gg.shareProxy:send("setPlayerBaseInfo", self.player.pid, { level = self.level })
    elseif self.cfgId == constant.BUILD_RESERVE_ARMY then --""
        self.player.buildBag:_addInitReserveArmy(self.id)
    end
    if self.cfgId == constant.BUILD_BASE and self.level == 5 then
        self.player.playerInfoBag:setPlayerUp5Level()
    end
    if self.cfgId == constant.BUILD_SANCTUARY then
        self.player.buildBag:setSanctuary(self.id)
    end
end

function Build:isLevelUp()
    local nowTick = skynet.timestamp()
    if nowTick > self.nextTick then
        return false
    end
    return true
end

function Build:isUpgrade()
    if self:isLevelUp() then
        return true
    end
    return false
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

function Build:checkTrainFinish(notNotify)
    if self.trainTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.trainTick then
        return
    end
    assert(self.trainCfgId > 0, "trainCfgId must bigger than 0")
    local trainSoliderNum = self.trainCount
    self.soliderCfgId = self.trainCfgId
    self.soliderCount = self.soliderCount + self.trainCount
    self.trainCfgId = 0
    self.trainCount = 0
    self.trainTick = 0
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = self:pack() })
    end
    self.player.taskBag:update(constant.TASK_TRAIN_SOLIDERS, {cfgId = self.soliderCfgId, count = trainSoliderNum})
end

function Build:setMakeTick()
    if self.cfg.perMakeStarCoin <= 0 and self.cfg.perMakeIce <= 0 and self.cfg.perMakeTitanium <= 0 and self.cfg.perMakeGas <= 0 then
        return
    end
    self.lastMakeTick = skynet.timestamp()
end

--""
function Build:isMakeResBuild()
    if self.cfg.perMakeStarCoin <= 0 and self.cfg.perMakeIce <= 0 and self.cfg.perMakeTitanium <= 0 and self.cfg.perMakeGas <= 0 then
        return false
    end
    return true
end

function Build:makeRes(notNotify)
    if self.cfg.perMakeStarCoin <= 0 and self.cfg.perMakeIce <= 0 and self.cfg.perMakeTitanium <= 0 and self.cfg.perMakeGas <= 0 then
        return
    end
    local perSeconds = gg.getGlobalCfgIntValue("BaseMakeResCD", 30)

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
        local tempStarCoin = self.cfg.perMakeStarCoin * count
        local tempIce = self.cfg.perMakeIce * count
        local tempTitanium = self.cfg.perMakeTitanium * count
        local tempGas = self.cfg.perMakeGas * count

        local vipStarCoinAdd = math.floor(tempStarCoin * self.player.vipBag:getRatio(constant.RES_STARCOIN))
        local vipIceAdd = math.floor(tempIce * self.player.vipBag:getRatio(constant.RES_ICE))
        local vipTitaniumAdd = math.floor(tempTitanium * self.player.vipBag:getRatio(constant.RES_TITANIUM))
        local vipGasAdd = math.floor(tempGas * self.player.vipBag:getRatio(constant.RES_GAS))

        self.curStarCoin = math.min(self.curStarCoin + tempStarCoin + vipStarCoinAdd, self.cfg.maxMakeStarCoin)
        self.curIce = math.min(self.curIce + tempIce + vipIceAdd, self.cfg.maxMakeIce)
        self.curTitanium = math.min(self.curTitanium + tempTitanium + vipTitaniumAdd, self.cfg.maxMakeTitanium)
        self.curGas = math.min(self.curGas + tempGas + vipGasAdd, self.cfg.maxMakeGas)

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

function Build:setRefBy(refBy)
    self.refBy = refBy
end

return Build