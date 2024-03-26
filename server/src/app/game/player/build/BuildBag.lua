local BuildBag = class("BuildBag")

function BuildBag:ctor(param)
    self.player = param.player                  -- ""
    self.builds = {}                            -- ""
    self.grids = {}                            -- ""
	self.landShipGrids = {}                    -- ""
	util.initMapGrids({
		grids = self.grids,
		builds = self.builds,
		landShipGrids = self.landShipGrids,
	})

    self.soliderLevels = {}                     -- ""

    self.soliderForgeLevels = {}                --""

    self.reserveArmy = {}                       -- ""

    self.buildMaxQueueCount = 1                 --""

    self.researchMaxQueueCount = 1              --""

    self.messMinLv = 1                          --""

    self.constructionCount = 0                  --""

    self.sanctuary = {}                         --""

    self.sanctuaryValue = {}                     --""

    self.giftBuild = nil

    self.lastFreshNftTick = 0
end

function BuildBag:newBuild(param)
    param.player = self.player
    return ggclass.Build.create(param)
end

function BuildBag:newSoliderLevel(param)
    param.player = self.player
    return ggclass.SoliderLevel.create(param)
end

function BuildBag:newSoliderForgeLevel(param)
    param.player = self.player
    return ggclass.SoliderForgeLevel.create(param)
end

function BuildBag:getBuild(id)
    if not id then
        return
    end
    return self.builds[id]
end

function BuildBag:getTotalBuild()
    local count = 0
    for _, build in pairs(self.builds) do
        if build.chain > 0 then
           count = count + 1
        end
    end
    return count
end

function BuildBag:checkBuildTotal()
    local maxCount = gg.getGlobalCfgIntValue("HQBagMax", 100)
    return maxCount < self:getTotalBuild()
end

function BuildBag:updateBuildRefBy(builds)
    for k,v in pairs(builds) do
        local build = self:getBuild(v.buildId)
        if build then
            build.refBy = v.cfgId
        end
    end
    gg.client:send(self.player.linkobj,"S2C_Player_BuildData",{ buildData = self:packBuild() })
end

function BuildBag:initialBuildNFT(param)
    logger.logf("info","ChainBridge","op=BuildBag:initialBuildNFT step1 pid=%d data=%s", self.player.pid, table.dump(param))
    local buildCfg = ggclass.Build.getNFTBuildCfg(param.race, param.style, param.quality, param.level)
    if not buildCfg then
        logger.logf("info","ChainBridge","op=BuildBag:initialBuildNFT step2 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    param.id = param.token_id
    param.cfgId = buildCfg.cfgId
    param.chain = param.mint_type
    if not param.life or param.life <= 0 then
        param.life = ggclass.Build.randomBuildLife(param.quality)
        param.curLife = param.life
    else
        param.curLife = param.life
    end
    local build = self:newBuild(param)
    if not build then
        logger.logf("info","ChainBridge","op=BuildBag:initialBuildNFT step4 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    build:deserialize(param)
    local ret = self:addBuild(build, {logType=gamelog.BRIDGE_RECHARGE_NFT})
    if not ret then
        logger.logf("info","ChainBridge","op=BuildBag:initialBuildNFT step5 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    logger.logf("info","ChainBridge","op=BuildBag:initialBuildNFT step6 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
    return build
end

function BuildBag:serialize()
    local data = {}
    data.buildMaxQueueCount = self.buildMaxQueueCount
    data.researchMaxQueueCount = self.researchMaxQueueCount
    data.messMinLv = self.messMinLv
    data.giftBuild = self.giftBuild
    data.builds = {}
    for _,build in pairs(self.builds) do
        table.insert(data.builds, build:serialize())
    end
    data.soliderLevels = {}
    for _, soliderLevel in pairs(self.soliderLevels) do
        table.insert(data.soliderLevels, soliderLevel:serialize())
    end
    data.soliderForgeLevels = {}
    for _, forgeLevel in pairs(self.soliderForgeLevels) do
        table.insert(data.soliderForgeLevels, forgeLevel:serialize())
    end
    data.reserveArmy = {}
    for k, v in pairs(self.reserveArmy) do
        data.reserveArmy[tostring(k)] = v
    end
    data.sanctuary = {}
    for k, v in pairs(self.sanctuary) do
        data.sanctuary[k] = v
    end
    return data
end

function BuildBag:deserialize(data)
    if not data then
        return
    end
    self.buildMaxQueueCount = data.buildMaxQueueCount or 1
    self.researchMaxQueueCount = data.researchMaxQueueCount or 1
    self.messMinLv = data.messMinLv or 1
    self.giftBuild = data.giftBuild
    if data.builds and next(data.builds) then
        for _, buildData in ipairs(data.builds) do
            local build = self:newBuild(buildData)
            if build then
                build:deserialize(buildData)
                self.builds[build.id] = build
            end
        end
    end
	util.initMapGrids({
		grids = self.grids,
		builds = self.builds,
		landShipGrids = self.landShipGrids,
	})
    if data.soliderLevels and next(data.soliderLevels) then
        for _, soliderLevelData in ipairs(data.soliderLevels) do
            local soliderLevel = self:newSoliderLevel(soliderLevelData)
            if soliderLevel then
                soliderLevel:deserialize(soliderLevelData)
                self.soliderLevels[soliderLevel.cfgId] = soliderLevel
            end
        end
    end
    if data.soliderForgeLevels and next(data.soliderForgeLevels) then
        for _, levelData in pairs(data.soliderForgeLevels) do
            local soliderForgeLevel = self:newSoliderForgeLevel(levelData)
            if soliderForgeLevel then
                self.soliderForgeLevels[levelData.cfgId] = soliderForgeLevel
            end
        end
    end
    for k, v in pairs(data.reserveArmy or {}) do
        self.reserveArmy[tonumber(k)] = v
    end

    if data.sanctuary and next(data.sanctuary) then
        self.sanctuary.buildId = data.sanctuary.buildId
        self.sanctuary.heros = {}
        for k, v in ipairs(data.sanctuary.heros) do
            table.insert(self.sanctuary.heros, v)
        end
    end
end

function BuildBag:packBuild()
    local buildData = {}
    for id,build in pairs(self.builds) do
        if constant.BUILD_USE_MESS_MIN_LV and build.type == constant.BUILD_TYPE_MESS then
            if build.level == self.messMinLv then
                table.insert(buildData, build:pack())
            end
        else
            table.insert(buildData, build:pack())
        end
    end
    return buildData
end

function BuildBag:packBuildToBattle()
    local buildData = {}
    for id,build in pairs(self.builds) do
        local temp = {}
        temp.id = build.id
        temp.cfgId = build.cfgId
        temp.quality = build.quality
        temp.level = build.level
        temp.x = build.x
        temp.z = build.z
        table.insert(buildData, temp)
    end
    return buildData
end

function BuildBag:packSoliderLevel()
    local soliderLevelData = {}
    for id,soliderLevel in pairs(self.soliderLevels) do
        table.insert(soliderLevelData, soliderLevel:pack())
    end
    return soliderLevelData
end

function BuildBag:packSoliderForgeLevel()
    local forgeLevelInfos = {}
    for k, forgeLevel in pairs(self.soliderForgeLevels) do
        table.insert(forgeLevelInfos, forgeLevel:pack())
    end
    return forgeLevelInfos
end

function BuildBag:packReserveArmy()
    local data = {}
    for id, val in pairs(self.reserveArmy) do
        table.insert(data, {
            buildId = val.buildId,
            trainCfgId = val.trainCfgId,
            trainCount = val.trainCount,
            trainTick = val.trainTick,
            count = val.count,
        })
    end
    return data
end

--""
function BuildBag:addSoliderLevel(soliderLevel)
    self.soliderLevels[soliderLevel.cfgId] = soliderLevel
    gg.client:send(self.player.linkobj,"S2C_Player_SoliderLevelUpdate",{soliderLevel=soliderLevel:pack()})
end

--"",""
function BuildBag:refreshSoliderLevel(notNotify)
    --""1
    local soliderCfg = cfg.get("etc.cfg.solider")
    for k,v in pairs(soliderCfg) do
        if v.isSummon ~= 1 then
            local soliderLevel = self.soliderLevels[v.cfgId]
            if not soliderLevel then --""0""
                local param = { cfgId = v.cfgId, level = 0 }
                soliderLevel = self:newSoliderLevel(param)
                self.soliderLevels[v.cfgId] = soliderLevel
            end
            -- local quality = (v.cfgId % 10)
            if soliderLevel.level <= 0 and v.level <= 0 then --""1""
                local arrive = self:preBuildLevelAndCountEnough(v.levelUpNeedBuilds)
                if arrive then
                    soliderLevel.level = 1
                    self.soliderLevels[v.cfgId] = soliderLevel
                    if not notNotify then
                        gg.client:send(self.player.linkobj,"S2C_Player_SoliderLevelUpdate",{soliderLevel = soliderLevel:pack()})
                    end
                end
            end
        end
    end
end

--"",""
function BuildBag:refreshSoliderForgeLevel(notNotify)
    local forgeCfg = cfg.get("etc.cfg.soliderForge")
    for k, v in pairs(forgeCfg) do
        local soliderForgeLevel = self.soliderForgeLevels[v.cfgId]
        if not soliderForgeLevel then
            local param = { cfgId = v.cfgId, level = 0 }
            soliderForgeLevel = self:newSoliderForgeLevel(param)
            self.soliderForgeLevels[v.cfgId] = soliderForgeLevel
        end
    end
end

function BuildBag:getInSanctuaryHeros()
    local heros = {}
    for k,v in pairs(self.sanctuary.heros or {}) do
        heros[v] = 1
    end
    return heros
end

function BuildBag:updateSanctuaryValue(newHeroId, oldHeroId)
    local buildId = self.sanctuary.buildId
    if not buildId then
        return
    end
    local build = self.builds[buildId]
    if not build then
        return
    end
    local buildCfg = ggclass.Build.getBuildCfg(build.cfgId,build.quality , build.level)
    local newHero = self.player.heroBag:getHero(newHeroId)
    if not newHero then
        return
    end
    local newHeroCfg =  ggclass.Hero.getHeroCfg(newHero.cfgId, newHero.quality, newHero.level)
    if not next(self.sanctuaryValue) then
        self.sanctuaryValue = {
            allEnableHp = 0,
            allEnableAtk = 0,
        }
    end
    if oldHeroId then
        local oldHero = self.player.heroBag:getHero(oldHeroId)
        local oldHeroCfg =  ggclass.Hero.getHeroCfg(oldHero.cfgId, oldHero.quality, oldHero.level)
        self.sanctuaryValue.allEnableHp = self.sanctuaryValue.allEnableHp + (newHeroCfg.maxHp - oldHeroCfg.maxHp) * buildCfg.translationRatio
        self.sanctuaryValue.allEnableAtk = self.sanctuaryValue.allEnableAtk + (newHeroCfg.atk - oldHeroCfg.atk) * buildCfg.translationRatio
    else
        self.sanctuaryValue.allEnableHp = self.sanctuaryValue.allEnableHp + newHeroCfg.maxHp * buildCfg.translationRatio
        self.sanctuaryValue.allEnableAtk = self.sanctuaryValue.allEnableAtk + newHeroCfg.atk  * buildCfg.translationRatio
    end
end

-- ""
function BuildBag:updateSanctuaryHero(buildId, index, heroId)
    if buildId ~= self.sanctuary.buildId then
        return
    end
    local build = self.builds[buildId]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    local buildCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
    if index > buildCfg.heroNum or index < 1 then
        self.player:say(util.i18nFormat(errors.SANCTUARY_NO_SPACE))
        return
    end
    local hero = self.player.heroBag:getHero(heroId)
    if not hero then
        self.player:say(util.i18nFormat(errors.SANCTUARY_HERO_NOT_EXIST))
        return
    end
    
    local inSanctuaryHeros = self:getInSanctuaryHeros()
    if inSanctuaryHeros[heroId] then
        self.player:say(util.i18nFormat(errors.SANCTUARY_HERO_USING))
        return
    end
    local oldHeroId = self.sanctuary.heros[index]
    self.sanctuary.heros[index] = heroId
    self:updateSanctuaryValue(heroId, oldHeroId)
    self.player.taskBag:update(constant.TASK_SANCTURARY_ADD_HERO, {count = #(self.sanctuary.heros)})
    gg.client:send(self.player.linkobj,"S2C_Player_SanctuaryHeros",{ data = self:getSanctuaryHeros(), buildId = self.sanctuary.buildId})
end

function BuildBag:delSanctuaryHero(heroId)
    local heros = self.sanctuary.heros or {}
    local newHeros = {}
    for k,v in pairs(heros) do
        if v ~= heroId then
            table.insert(newHeros, v)
        end
    end
    self.sanctuary.heros = newHeros
    self:autoAddSanctuary()
end

-- ""
function BuildBag:addSanctuaryHeros(index)
    local inSanctuaryHeros = self:getInSanctuaryHeros()
    local heros = self.player.heroBag:getSortHeros(inSanctuaryHeros)
    if heros[1] then
        self.sanctuary.heros[index] = heros[1].id
    end
    local heroId = self.sanctuary.heros[index]
    if not heroId then
        return
    end
    self:updateSanctuaryValue(heroId)
    self.player.taskBag:update(constant.TASK_SANCTURARY_ADD_HERO, {count = #(self.sanctuary.heros)})
end

function BuildBag:autoAddSanctuary()
    if not next(self.sanctuary) then
        return
    end
    local build = self.builds[self.sanctuary.buildId]
    if not build then
        return
    end

    local buildCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
    if not buildCfg then
        return
    end
    if not next(self.sanctuary) then
        self.sanctuary.heros = {}
    end
    if #self.sanctuary.heros < buildCfg.heroNum then
        for index=1,buildCfg.heroNum do
            if not self.sanctuary.heros[index] then
                self:addSanctuaryHeros(index)
            end
        end
    end
    self:calSanctuaryValue()
    gg.client:send(self.player.linkobj,"S2C_Player_SanctuaryHeros", { data = self:getSanctuaryHeros(), buildId = self.sanctuary.buildId })
    
end

--""，""
function BuildBag:setSanctuary(buildId)
    local build = self.builds[buildId]
    if not build then
        return
    end
    if not next(self.sanctuary) then
        self.sanctuary.heros = {}
    end
    if not self.sanctuary.buildId then
        self.sanctuary.buildId = buildId
    end
    local buildCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
    if not buildCfg then
        return
    end
    if #self.sanctuary.heros < buildCfg.heroNum then
        for index=1,buildCfg.heroNum do
            if not self.sanctuary.heros[index] then
                self:addSanctuaryHeros(index)
            end
        end
    end
    self:calSanctuaryValue()
    
    gg.client:send(self.player.linkobj,"S2C_Player_SanctuaryHeros", { data = self:getSanctuaryHeros(), buildId = self.sanctuary.buildId})
end

-- ""
function BuildBag:getSanctuaryHeros()
    local heros = {}
    for k,v in pairs(self.sanctuary.heros or {}) do
        local hero = self.player.heroBag:getHero(v)
        if hero then
            table.insert(heros,{
                id = hero.id,
            })
        end
    end
    return heros
end

-- "" 
function BuildBag:updateSanctuary(heroId) 
    local heros = self:getInSanctuaryHeros()
    if heros[heroId] then
        self:calSanctuaryValue()
    end
end

-- ""，""
function BuildBag:calSanctuaryValue()
    self.sanctuaryValue = {}
    for k,v in pairs(self.sanctuary.heros or {}) do
        self:updateSanctuaryValue(v)
    end
end

function BuildBag:getSanctuaryValue()
    if not next(self.sanctuaryValue) then
        self:calSanctuaryValue()
    end
    return self.sanctuaryValue
end

function BuildBag:resetSanctuary()
    local buildId = self.sanctuary.buildId
    if not buildId then
        return
    end
    local build = self.builds[buildId]
    local buildCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
    if #self.sanctuary.heros > buildCfg.heroNum then
        for index=buildCfg.heroNum + 1, #self.sanctuary.heros  do
            self.sanctuary.heros[index] = nil
        end
        self:calSanctuaryValue()
    end
    gg.client:send(self.player.linkobj,"S2C_Player_SanctuaryHeros", { data = self:getSanctuaryHeros(), buildId = self.sanctuary.buildId})
end

function BuildBag:_addInitReserveArmy(id)
    local build = self.builds[id]
    if not build then
        return
    end
    local space = build.cfg.maxTrainSpace
    if space <= 0 then
        return
    end
    local gRArmyCount = gg.getGlobalCfgIntValue("InitReserveArmy", 100)
    local count = math.min(gRArmyCount, space)
    if count == 0 then
        return
    end
    if self.reserveArmy[id] then
        return
    end
    self.reserveArmy[id] = {
        buildId = id,
        trainCfgId = 0,
        trainCount = 0,
        trainTick = 0,
        count = count,
        startTime = 0,
    }
    self:_sendReserveArmyUpdate(constant.OP_ADD, {self.reserveArmy[id]})
    return true
end

--""Id""
function BuildBag:getBuildLevelByCfgId(cfgId)
    local level = 0
    for _,build in pairs(self.builds) do
        if build.cfgId == cfgId and build.level > level then
            level = build.level
        end
    end
    return level
end

function BuildBag:getBaseBuildLevel()
    return self:getBuildLevelByCfgId(constant.BUILD_BASE)
end

function BuildBag:getResCount(key)
	local resCount = 0
    for _,build in pairs(self.builds) do
        local buildCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
        if buildCfg then
            resCount = resCount + (build.cfg[key] or 0)
        end
    end
    return resCount
end

-- ""
function BuildBag:getStoreStarCoin()
    return self:getResCount("storeStarCoin")
end

-- ""
function BuildBag:getCurStoreStarCoin()
	return self:getResCount("curStarCoin")
end

-- ""
function BuildBag:getStoreIce()
	return self:getResCount("storeIce")
end

function BuildBag:getCurStoreIce()
	return self:getResCount("curIce")
end

-- ""
function BuildBag:getStoreCarboxyl()
	return self:getResCount("storeCarboxyl")
end

function BuildBag:getCurStoreCarboxyl()
	return self:getResCount("curCarboxyl")
end

-- ""
function BuildBag:getStoreTitanium()
	return self:getResCount("storeTitanium")
end

function BuildBag:getCurStoreTitanium()
	return self:getResCount("curTitanium")
end

-- ""
function BuildBag:getStoreGas()
	return self:getResCount("storeGas")
end

function BuildBag:getCurStoreGas()
	return self:getResCount("curGas")
end

--""
function BuildBag:getSoliderLevel(cfgId)
    local soliderLevel = self.soliderLevels[cfgId]
    if not soliderLevel then
        return 0
    end
    return soliderLevel.level
end

function BuildBag:getMinLvMessCount()
    local count = 0
    for id,build in pairs(self.builds) do
        if build.type == constant.BUILD_TYPE_MESS then
            if build.level == self.messMinLv then
                count = count + 1
            end
        end
    end
    return count
end

function BuildBag:getMinLvMess()
    local ret = {}
    for id,build in pairs(self.builds) do
        if build.type == constant.BUILD_TYPE_MESS then
            if build.level == self.messMinLv then
                table.insert(ret, build)
            end
        end
    end
    return ret
end

--""
function BuildBag:getBuildWorkingQueueCount()
    local count = 0
    for _, build in pairs(self.builds) do
        if build.chain <= 0 and build:getLessTick() > 0 then
            count = count + 1
        end
    end
    return count
end

function BuildBag:_getBuildQueueLimit()
    local buildQueue = self.player.vipBag:getBuildQueue()
    local builder = self.player.rechargeActivityBag:getBuildQueue()
    return (self.buildMaxQueueCount + buildQueue + builder)
end

--""
function BuildBag:isBuildWorkingQueueFull()
    local count = self:getBuildWorkingQueueCount()
    local limit = self:_getBuildQueueLimit()
    if count >= limit then
        return true
    end
    return false
end

--""
function BuildBag:getResearchWorkingQueueCount()
    local count = 0
    for _, v in pairs(self.soliderLevels) do
        if v:getLessTick() > 0 then
            count = count + 1
        end
    end
    for _, v in pairs(self.soliderLevels) do
        if v.level <=0 and v:getLessTick() > 0 then
            count = count + 1
        end
    end
    return count
end

--""
function BuildBag:isResearchWorkingQueueFull()
    local count = self:getResearchWorkingQueueCount()
    if count >= self.researchMaxQueueCount then
        return true
    end
    return false
end

function BuildBag:canPlaceLandShip(pos)
	if pos.x > 0 and pos.z > 0 then
		return
	end
	local index
	for i, shipPos in ipairs(constant.BUILD_LIBERATORSHIPPOSLIST) do
		if shipPos[1] == pos.x and shipPos[2] == pos.z then
			if self.landShipGrids[i] then
				return
			end
			index = i
			break
		end
	end
	return index
end

function BuildBag:setLandShipGrids(pos, build)
	if pos.x > 0 and pos.z > 0 then
		return
	end
	for i, shipPos in ipairs(constant.BUILD_LIBERATORSHIPPOSLIST) do
		if shipPos[1] == pos.x and shipPos[2] == pos.z then
			self.landShipGrids[i] = build.id
			return i
		end
	end
end

function BuildBag:resetLandShipGrids(pos)
	if pos.x > 0 and pos.z > 0 then
		return
	end
	for i, shipPos in ipairs(constant.BUILD_LIBERATORSHIPPOSLIST) do
		if shipPos[1] == pos.x and shipPos[2] == pos.z then
			self.landShipGrids[i] = nil
			return i
		end
	end
end

function BuildBag:canPlaceBuild(pos, length, width, cfgId)
	if cfgId == constant.BUILD_LIBERATORSHIP then
		return self:canPlaceLandShip(pos)
	end
	return util.canPlaceMapGrids({
		pos = pos,
		length = length,
		width = width,
		grids = self.grids,
	})
end

--""
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
function BuildBag:addBuild(build, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=BuildBag:addBuild " .. debug.traceback())
        return nil
    end
    build:setMakeTick()
    self.builds[build.id] = build
	if build.cfgId == constant.BUILD_LIBERATORSHIP then
		self:setLandShipPos(build, {x = build.x, z = build.z})
	else
		self:setBuildPos(build, {x = build.x, z = build.z})
	end
    if build.cfgId == constant.BUILD_RESERVE_ARMY then
        self:_addInitReserveArmy(build.id)
    end
    if build.cfgId == constant.BUILD_SANCTUARY then
        self:setSanctuary(build.id)
    end
    if not source.notNotify then
        gg.client:send(self.player.linkobj, "S2C_Player_BuildAdd",{ build = build:pack() })
    end
    gg.internal:send(".gamelog", "api", "addEntityLog", self.player.pid, self.player.platform, "add", source.logType, gamelog[source.logType], constant.ITEM_BUILD, build:packToLog())
    self.player.taskBag:update(constant.TASK_BUILD_LV_COUNT, {cfgId = build.cfgId, lv = build.level, count = 1})
    if build.chain > 0 then
        self.player.autoPushBag:setAutoPushStatus(constant.AUTOPUSH_CFGID_NEW_BUILD)
    end
    return build
end

--- ""
--@param[type=integer] id ""id
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
function BuildBag:delBuild(id, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=HeroBag:delHero " .. debug.traceback())
        return nil
    end
    local build = self.builds[id]
    for k,v in pairs(self.reserveArmy or {}) do
        if k == id then
            self.reserveArmy[k] = nil
        end
    end
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return nil
    end
    if build.cfgId == constant.BUILD_SANCTUARY then
        self.sanctuary = {}
        self.sanctuaryValue = {}
    end
    self.builds[id] = nil
    self:updateConstructionCount()
	util.resetMapGrids({
        pos = {x = build.x, z = build.z},
        length = build.length,
        width = build.width,
        grids = self.grids,
    })
    gg.client:send(self.player.linkobj, "S2C_Player_BuildDel",{ id = id})
    gg.internal:send(".gamelog", "api", "addEntityLog", self.player.pid, self.player.platform, "del", source.logType, gamelog[source.logType], constant.ITEM_BUILD, build:packToLog())
    return build
end

--""
function BuildBag:getBuildsByCfgId(cfgId)
    local builds = {}
    for _, build in pairs(self.builds) do
        if cfgId == build.cfgId then
            table.insert(builds, build)
        end
    end
    return builds
end

--""
function BuildBag:getCannonBuilds()
    local builds = {}
    for _, build in pairs(self.builds) do
        local buildCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
        if buildCfg and buildCfg.type == constant.BUILD_TYPE_DEFEND and buildCfg.subType == constant.BUILD_SUBTYPE_CANNON then
            table.insert(builds, build)
        end
    end
    return builds
end

--""NFT""
function BuildBag:getNftBuilds()
    local builds = {}
    for _, build in pairs(self.builds) do
        if build.chain > 0 and build.chain ~= constant.BUILD_CHAIN_TOWER then
            table.insert(builds, build)
        end
    end
    return builds
end

--""
function BuildBag:getNormalBuilds()
    local builds = {}
    for _, build in pairs(self.builds) do
        if build.chain <= 0 then
            table.insert(builds, build)
        end
    end
    return builds
end

--""NFT""
function BuildBag:getNftBuild(buildId)
    local build = self.builds[buildId]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if build.chain <= 0 then
        self.player:say(util.i18nFormat(errors.GRID_NFT_BUILD_CAN_USE))
        return
    end
    -- ""nft""
    if not constant.IsRefNone(build) then
        self.player:say(util.i18nFormat(errors.BUILD_REF_BUSY))
        return
    end
    return build:serialize()
end

function BuildBag:getNftBuildList(buildIds)
    local list = {}
    for i, v in ipairs(buildIds) do
        local build = self.builds[v]
        if build then
            if build.chain > 0 and constant.IsRefNone(build) then
                table.insert(list, build:serialize())
            end
        end
    end
    return list
end

function BuildBag:getNotNftBuildList(buildIds)
    local list = {}
    for i, v in ipairs(buildIds) do
        local build = self.builds[v]
        if build then
            if build.chain <= 0 and constant.IsRefNone(build) then
                table.insert(list, build:serialize())
            end
        end
    end
    return list
end

function BuildBag:getBuildList(buildIds)
    local list = {}
    for i, v in ipairs(buildIds) do
        local build = self.builds[v]
        if build then
            if constant.IsRefNone(build) then
                table.insert(list, build:serialize())
            end
        end
    end
    return list
end

function BuildBag:useNftToGrid(buildId, cfgId)
    local build = self:getBuild(buildId)
    if not build then
        self:say(util.i18nFormat(errors.ITEM_NOT_EXIST))
        return
    end
    if build.chain <= 0 then
        self:say(util.i18nFormat(errors.GRID_NFT_BUILD_CAN_USE))
        return
    end
    
    -- nft""
    if not constant.IsRefNone(build)  then
        self:say(util.i18nFormat(errors.BUILD_REF_BUSY))
        return
    end
    constant.setRef(build, constant.REF_GRID)
    build:setRefBy(cfgId)
    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
    return build:serialize()
end

function BuildBag:useNftListToGrid(cfgId, buildIds)
    local list = {}
    for i, v in ipairs(buildIds) do
        local build = self.builds[v]
        if build then
            if build.chain > 0 and constant.IsRefNone(build) then
                constant.setRef(build, constant.REF_GRID)
                build:setRefBy(cfgId)
                gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
                table.insert(list, v)
            end
        end
    end
    return list
end

function BuildBag:notUseNftListToGrid(cfgId, buildIds)
    local list = {}
    for i, v in ipairs(buildIds) do
        local build = self.builds[v]
        if build then
            if build.chain > 0 then
                constant.setRef(build, constant.REF_NONE)
                build:setRefBy(0)
                gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
                table.insert(list, v)
            end
        end
    end
    return list
end

function BuildBag:useBuildListToGrid(cfgId, buildIds)
    local list = {}
    for i, v in ipairs(buildIds) do
        local build = self.builds[v]
        if build then
            if constant.IsRefNone(build) then
                constant.setRef(build, constant.REF_GRID)
                build:setRefBy(cfgId)
                gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
                table.insert(list, v)
            end
        end
    end
    return list
end

function BuildBag:notUseBuildListToGrid(cfgId, buildIds)
    local list = {}
    for i, v in ipairs(buildIds) do
        local build = self.builds[v]
        if build then
            constant.setRef(build, constant.REF_NONE)
            build:setRefBy(0)
            gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
            table.insert(list, v)
        end
    end
    return list
end

--""
function BuildBag:getBuildResProtectRatio()
    for _, build in pairs(self.builds) do
        if build.cfgId == constant.BUILD_BLACKHOLE_REPOSITORIE then
            local buildCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
            if buildCfg and buildCfg.resProtectRatio then
                return buildCfg.resProtectRatio
            end
            break
        end
    end
    return 0
end

--""
function BuildBag:getSameTypeBuildCount(cfgId, buildCountType)
    local num = 0
    for _, build in pairs(self.builds) do
        if buildCountType == -1 then
            if cfgId == build.cfgId then
                num = num + 1
            end
        else
            local cfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
            if cfg.buildCountType == buildCountType then
                num = num + 1
            end
        end
    end
    return num
end

--""
function BuildBag:getBuildCountLimit(buildCountType)
    if not buildCountType then
        return 0
    end
    local level = self:getBuildLevelByCfgId(constant.BUILD_BASE)
    if not level then
        return 0
    end
    local buildCountCfg = cfg.get("etc.cfg.buildCount")
    if not buildCountCfg then
        return 0
    end
    if not buildCountCfg[buildCountType] then
        return 0
    end
    if not buildCountCfg[buildCountType][level] then
        local buildLimitArrCount = #buildCountCfg[buildCountType]
        if level > buildLimitArrCount then
            return buildCountCfg[buildCountType][buildLimitArrCount]
        end
        return 0
    end
    return buildCountCfg[buildCountType][level]
end

function BuildBag:setLandShipPos(build, pos)
	self:setLandShipGrids(pos, build)
	build:setNewPos(pos.x, pos.z)
end

function BuildBag:setBuildPos(build, pos)
	util.setMapGrids({
		id = build.id,
		pos = {x = pos.x, z = pos.z},
		length = build.length,
		width = build.width,
		grids = self.grids,
	})
	build:setNewPos(pos.x, pos.z)
end

--""
function BuildBag:preBuildLevelAndCountEnough(dict)
    for _, value in pairs(dict) do
        local needCfgId = value[1]
        local needLevel = value[2]
        local needCount = value[3] or 1
        if needCfgId and needLevel and needCount then
            local count = 0
            local quality = 0
            for k, v in pairs(self.builds) do
                if v.cfgId == needCfgId and v.level >= needLevel then
                    count = count + 1
                end
            end
            if count < needCount then
                local needBuildCfg
                for quality=0, 5 do
                    needBuildCfg = ggclass.Build.getBuildCfg(needCfgId, quality, needLevel)
                    if needBuildCfg then
                        break
                    end
                end
                local buildName = assert(needBuildCfg and needBuildCfg.name, "build config not exist")
                local i18nMsg = util.i18nFormat(errors.BUILD_REQUIRE_LEVEL_AND_COUNT, buildName, needLevel)
                return false, i18nMsg
            end
        end
    end
    return true
end

function BuildBag:preBuildLevelEnough(dict)
    --""
    dict = dict or {}
	local arrive = true
	local needCfgId
    local needLevel
    for _, value in ipairs(dict) do
	    needCfgId = value[1]
	    needLevel = value[2]
        
        if needCfgId and needLevel and self:getBuildLevelByCfgId(needCfgId) < needLevel then
			arrive = false
            break
        end
    end

	if not arrive then
        local needBuildCfg = nil--ggclass.Build.getBuildCfg(needCfgId, 1, 1)
        for i = 0, 5, 1 do
            needBuildCfg = ggclass.Build.getBuildCfg(needCfgId, i, 1)
            if needBuildCfg then
                break
            end
        end
        local buildName = assert(needBuildCfg and needBuildCfg.name, "build config not exist")
        local msg = util.i18nFormat(errors.BUILD_LEVEL_NOT_ENOUGH, buildName, needLevel)
		return false, msg
	end

    return true
end

-- ""
function BuildBag:updateConstructionCount()
    local builds = self.builds or {}
    local constructionCount = 0
    for _, build in pairs(builds) do
        if build.type ~= constant.BUILD_TYPE_MESS then
            local buildCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
            constructionCount = constructionCount + buildCfg.construction
        end
    end
    self.constructionCount = constructionCount
end

function BuildBag:addConstructionCount(cfgId, quality, level)
    local newBuildCfg = ggclass.Build.getBuildCfg(cfgId, quality, level)
    local oldBuildCfg = ggclass.Build.getBuildCfg(cfgId, quality, level-1)
    self.constructionCount = self.constructionCount - oldBuildCfg.construction + newBuildCfg.construction
end

-- ""
function BuildBag:constructionCountEnough(construction)
    if self.constructionCount == 0 then
        self:updateConstructionCount()
    end
    return self.constructionCount >= construction
end

function BuildBag:_adjustPos(cfgId, pos)
    if cfgId ~= constant.BUILD_LIBERATORSHIP then
		local buildPos = Vector3.New(math.floor(pos.x), 0, math.floor(pos.z))
        pos.x = buildPos.x
        pos.z = buildPos.z
    else
        local posX = tonumber(string.format("%.2f", pos.x))
        local posZ = tonumber(string.format("%.2f", pos.z))
        local buildPos = Vector3.New(posX, 0, posZ)
        pos.x = buildPos.x
        pos.z = buildPos.z
	end
end

function BuildBag:createBuild(cfgId, pos, opType)
    local cfg = ggclass.Build.getBuildCfg(cfgId, constant.BUILD_INIT_QUALITY, 0)
    if not cfg then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end

    if cfgId == constant.BUILD_BASE then
        self.player:say(util.i18nFormat(errors.BASE_BUILD_REPEAT))
        return
    end

    self:_adjustPos(cfgId, pos)
    -- if self:isBuildWorkingQueueFull() then
    --     self.player:say(util.i18nFormat(errors.WORK_QUE_FULL))
    --     return
    -- end

    if cfg.buildCountType > 0  then
        local buildCount = self:getSameTypeBuildCount(cfgId, cfg.buildCountType)
        local buildLimitCount = self:getBuildCountLimit(cfg.buildCountType)
        if buildLimitCount and buildCount and buildCount >= buildLimitCount then
            self.player:say(util.i18nFormat(errors.BUILD_COUNT_LIMIT))
            return
        end
    end

    --""
	local ret = self:canPlaceBuild(pos, cfg.length, cfg.width, cfgId)
    if not ret then
        logger.debug("game","pos=%s, length=%s, width=%s, cfgId=%s",table.dump(pos), cfg.length, cfg.width, cfgId)
        self.player:say(util.i18nFormat(errors.POS_ERR))
        return
    end
    --""
    local arrive, msg = self:preBuildLevelAndCountEnough(cfg.levelUpNeedBuilds)
    if not arrive then
        self.player:say(msg)
        return
    end
    --""
    local result = self:constructionCountEnough(cfg.levelUpNeedConstruction)
    if not result then
        self.player:say(util.i18nFormat(errors.BUILD_DEGREE_NOT_ENOUGH))
        return
    end
    
    --""
	local resDict = {
        [constant.RES_STARCOIN] = cfg.levelUpNeedStarCoin or 0,
        [constant.RES_ICE] = cfg.levelUpNeedIce or 0,
        [constant.RES_TESSERACT] = cfg.levelUpNeedTesseract or 0,
        [constant.RES_TITANIUM] = cfg.levelUpNeedTitanium or 0,
        [constant.RES_GAS] = cfg.levelUpNeedGas or 0,
        [constant.RES_MIT] = cfg.levelUpNeedMit or 0,
    }
    local wqCostCarboxyl, minObj = self:calWorkQueResCost()
    if opType == 1 then
        return
    else--""，""Carboxyl""
        local newResDict = upgradeUtil.calResCost(self, resDict, nil)
        newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] + wqCostCarboxyl
        if not self.player.resBag:enoughResDict(newResDict) then
            return
        end
        --""
        newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] - wqCostCarboxyl
        self.player.resBag:costResDict(newResDict, {logType=gamelog.BUILD_CREATE})
        if minObj then
            local wqResDict = {[constant.RES_TESSERACT] = wqCostCarboxyl}
            self.player.resBag:costResDict(wqResDict, {logType=gamelog.SPEED_BUILD_LEVEL_UP})
            minObj:setNextTick(0)
        end
    end

    --""
    local quality = constant.BUILD_INIT_QUALITY
    local life = ggclass.Build.randomBuildLife(quality)
    local param = {
        cfgId = cfgId,
        quality = quality,
        level = 0,
        life = life,
        curLife = life,
    }
    local build = self:newBuild(param)
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_CREATE_ERR))
        return
    end

	if cfgId == constant.BUILD_LIBERATORSHIP then
		self:setLandShipPos(build, pos)
	else
		self:setBuildPos(build, pos)
	end
    build:setNextTick((cfg.levelUpNeedTick or 0) * 1000)
    self:addBuild(build, {logType=gamelog.BUILD_CREATE})
    return build
end

function BuildBag:gmCreateBuild(cfgId, pos, opType)
    if not gg.isInnerServer() then
        return
    end
    local cfg = ggclass.Build.getBuildCfg(cfgId, constant.BUILD_INIT_QUALITY, 0)
    if not cfg then
        cfg = ggclass.Build.getBuildCfg(cfgId, 1, 0)
    end
    if not cfg then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end

    if cfgId == constant.BUILD_BASE then
        local baseBuilds = self:getBuildsByCfgId(cfgId)
        if table.count(baseBuilds) > 0 then
            self.player:say(util.i18nFormat(errors.BASE_BUILD_REPEAT))
            return
        end
    end

    self:_adjustPos(cfgId, pos)

    --""
	local ret = self:canPlaceBuild(pos, cfg.length, cfg.width, cfgId)
    if not ret then
        logger.debug("game","pos=%s, length=%s, width=%s, cfgId=%s",table.dump(pos), cfg.length, cfg.width, cfgId)
        self.player:say(util.i18nFormat(errors.POS_ERR))
        return
    end

    --""
	local resDict = {
        [constant.RES_STARCOIN] = 0,
        [constant.RES_ICE] = 0,
        [constant.RES_TESSERACT] = 0,
        [constant.RES_TITANIUM] = 0,
        [constant.RES_GAS] = 0,
        [constant.RES_MIT] = 0,
    }
    local wqCostCarboxyl, minObj = self:calWorkQueResCost()
    wqCostCarboxyl = 0 --for gm
    if opType == 1 then
        return
    else--""，""Carboxyl""
        local newResDict = upgradeUtil.calResCost(self, resDict, nil)
        newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] + wqCostCarboxyl
        if not self.player.resBag:enoughResDict(newResDict) then
            return
        end
        --""
        newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] - wqCostCarboxyl
        self.player.resBag:costResDict(newResDict, {logType=gamelog.BUILD_GM_CREATE})
        if minObj then
            local wqResDict = {[constant.RES_TESSERACT] = wqCostCarboxyl}
            self.player.resBag:costResDict(wqResDict, {logType=gamelog.SPEED_BUILD_LEVEL_UP})
            minObj:setNextTick(0)
        end
    end

    --""
    local quality = constant.BUILD_INIT_QUALITY
    local life = ggclass.Build.randomBuildLife(quality)
    local param = {
        cfgId = cfgId,
        quality = quality,
        level = 0,
        life = life,
        curLife = life,
    }
	-- ""nft""
    if cfg.style >= 1 then
        param.quality = 1
    end
    local build = self:newBuild(param)
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_CREATE_ERR))
    end
	if cfgId == constant.BUILD_LIBERATORSHIP then
		self:setLandShipPos(build, pos)
	else
		self:setBuildPos(build, pos)
	end
    build:setNextTick( 0 * 1000)
    self:addBuild(build, {logType=gamelog.BUILD_GM_CREATE})
    return build
end

function BuildBag:gmBatchCreateBuild(builds)
    if not gg.isInnerServer() then
        return
    end
    if table.count(builds) == 0 then
        return
    end
    for id, build in pairs(self.builds) do
        if build.cfgId ~= constant.BUILD_LIBERATORSHIP then
            self:delBuild(id, {logType=gamelog.GM})
        end
    end
    for i, v in ipairs(builds) do
        local build = self:gmCreateBuild(v.cfgId, v.pos, 0)
        if build then
            if v.level > 1 then
                local opArgs = {
                    goType = 1,
                    id = build.id,
                    op = 1,
                    level = v.level,
                }
                self.player.editorBag:gameObjectOp(opArgs)
            end
        end
    end
end

function BuildBag:isBuildCanMove(build)
    if constant.BUILD_TYPE_CAN_MOVE[build.type] then
        if build.subType ~= constant.BUILD_SUBTYPE_LIBERATORSHIP then
            return true
        end
    end
end

function BuildBag:moveBuild(id, pos, edit)
    if edit then
        if not gg.isInnerServer() then
            return
        end
    end
    if pos.x < constant.MAP_GRID_MIN or pos.x > constant.MAP_GRID_MAX
    or pos.z < constant.MAP_GRID_MIN or pos.z > constant.MAP_GRID_MAX then
        self.player:say(util.i18nFormat(errors.POS_OUT_OF_BOUNDS))
		return
	end

    local build = self.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end

    if not self:isBuildCanMove(build) and not edit then
        self.player:say(util.i18nFormat(errors.BUILD_CANT_MOVE))
        return
    end

	local oldPos = Vector3.New(build.x, 0, build.z)
	local inData = {
		fromPos = oldPos,
		toPos = pos,
		id = id,
		grids = self.grids,
		builds = self.builds,
	}
	local isOk, errMsg = util.canMoveMapGrids(inData)
	if not isOk then
		self.player:say(util.i18nFormat(errMsg))
        return
	end
	local dstBuild = util.swapMapGrids(inData)
	if dstBuild then
		gg.client:send(self.player.linkobj,"S2C_Player_BuildMove",{ ret = 0, build = dstBuild:pack() })
	end
	gg.client:send(self.player.linkobj,"S2C_Player_BuildMove",{ ret = 0, build = build:pack() })
    
end

function BuildBag:isBuildInLevelUp(id)
    local build = self.builds[id]
    if not build then
        return
    end
    return build:getLessTick() > 0
end

function BuildBag:isBuildInFighting(id)
    local build = self.builds[id]
    if not build then
        return
    end
    return false
end

function BuildBag:isBuildInTraining(id)
    local build = self.builds[id]
    if not build then
        return
    end
    return build:getLessTrainTick() > 0
end

function BuildBag:calWorkQueResCost()
    local minBuild
    local minTick
    if self:isBuildWorkingQueueFull() then
        for _, _build in pairs(self.builds) do
            if _build.chain <= 0 then
                local lessTime = _build:getLessTick()
                if lessTime > 0 then
                    if not minTick or lessTime < minTick then
                        minTick = lessTime
                        minBuild = _build
                    end
                end
            end
        end
    end
    local needTesseract = 0
    if minTick then
        needTesseract = self.player.resBag:timeCostTesseract(minTick)
    end
    return needTesseract, minBuild
end

function BuildBag:isReserveArmyTrainning(id)
    local rsvArmy = self.reserveArmy[id]
    if not rsvArmy then
        return false
    end
    if rsvArmy.trainCount == 0 then
        return false
    end
    return true
end

function BuildBag:levelUpBuild(id, speedUp)
    local build = self.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if build.cfgId == constant.BUILD_RESERVE_ARMY then
        if self:isReserveArmyTrainning(id) then
            self.player:say(util.i18nFormat(errors.BUILD_TRAINNING_SOLIDERS))
            return
        end
    end

    -- if self:isBuildWorkingQueueFull() then
    --     self.player:say(util.i18nFormat(errors.WORK_QUE_FULL))
    --     return
    -- end

    local curLevel = build.level
    local nextLevel = curLevel + 1
    local nextCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, nextLevel)
    if not nextCfg then
        self.player:say(util.i18nFormat(errors.LEVEL_MAX))
        return
    end
    local cfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, curLevel)
    if not cfg then
        self.player:say(util.i18nFormat(errors.CUR_LEVEL_CONFIG_NIL))
        return
    end
    -- ""
    if not constant.IsRefNone(build) and not constant.IsRefGrid(build) and not constant.IsRefLevelUp(build) and not constant.IsRefUnion(build) then
        self.player:say(util.i18nFormat(errors.BUILD_REF_BUSY))
        return
    end

    --""
    if build:isLevelUp() and speedUp == 0 then
        self.player:say(util.i18nFormat(errors.LEVELINGUP))
        return
    end

    --[[
    --""
    if build:getLessTrainTick() > 0 and speedUp == 0 then
        self.player:say(util.i18nFormat(errors.BUILD_TRAINNING_SOLIDERS))
        return
    end
    ]]

    -- ""，""，""
    if build.cfgId == constant.BUILD_HYPERSPACERESEARCH then
        if self:getResearchWorkingQueueCount() > 0 then
            self.player:say(util.i18nFormat(errors.BUILD_SOLIDERS_UPGRADING))
            return
        end
    end

    --""
    local arrive, msg = self:preBuildLevelAndCountEnough(cfg.levelUpNeedBuilds)
    if not arrive then
        self.player:say(msg)
        return
    end

    -- ""
    local result = self:constructionCountEnough(cfg.levelUpNeedConstruction)
    if not result then
        self.player:say(util.i18nFormat(errors.BUILD_DEGREE_NOT_ENOUGH))
        return
    end
    
    --""
    local resDict = {
        [constant.RES_STARCOIN] = cfg.levelUpNeedStarCoin or 0,
        [constant.RES_ICE] = cfg.levelUpNeedIce or 0,
        [constant.RES_TESSERACT] = cfg.levelUpNeedTesseract or 0,
        [constant.RES_TITANIUM] = cfg.levelUpNeedTitanium or 0,
        [constant.RES_GAS] = cfg.levelUpNeedGas or 0,
        [constant.RES_MIT] = cfg.levelUpNeedMit or 0,
    }

    if build.chain > 0 then
        --nft""
        --if constant.IsRefLevelUp(build) then
        if build:isLevelUp() then
            if speedUp == 0 then
                --"",""
                self.player:say(util.i18nFormat(errors.LEVELINGUP))
                return
            else
                --"",""
                local lessTick = build:getLessTick()
                local timeTesseract = self.player.resBag:timeCostTesseract(lessTick)
                if not self.player.resBag:enoughRes(constant.RES_TESSERACT, timeTesseract) then
                    self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
                    return
                end
                self.player.resBag:costRes(constant.RES_TESSERACT, timeTesseract, {logType=gamelog.SPEED_BUILD_LEVEL_UP})
                self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
            end
        else
            if speedUp == 0 then
                --"",""
                local newResDict = upgradeUtil.calResCost(self, resDict, nil)
                if not self.player.resBag:enoughResDict(newResDict) then
                    return
                end
                self.player.resBag:costResDict(newResDict, {logType=gamelog.BUILD_LEVEL_UP})
            else
                --"",""
                local timeTesseract = self.player.resBag:timeCostTesseract(cfg.levelUpNeedTick)
                local resTesseract = self.player.resBag:resCostTesseract(resDict)
                local allTesseract = timeTesseract + resTesseract
                local newResDict = {
                    [constant.RES_MIT] = resDict[constant.RES_MIT] or 0,
                    [constant.RES_TESSERACT] = (resDict[constant.RES_TESSERACT] or 0) + allTesseract,
                }
                if not self.player.resBag:enoughResDict(newResDict) then
                    return
                end
                self.player.resBag:costResDict(newResDict, {logType=gamelog.SOON_BUILD_LEVEL_UP})
                self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
            end
        end
    else
        --"",""
        local wqCostCarboxyl, minObj = self:calWorkQueResCost()
        if speedUp == 1 then--""
            local lessTick = build:getLessTick()
            if lessTick > 0 then--""
                local timeTesseract = self.player.resBag:timeCostTesseract(lessTick)
                if not self.player.resBag:enoughRes(constant.RES_TESSERACT, timeTesseract) then
                    self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
                    return
                end
                self.player.resBag:costRes(constant.RES_TESSERACT, timeTesseract, {logType=gamelog.SPEED_BUILD_LEVEL_UP})
                self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
            else--""
                local timeTesseract = self.player.resBag:timeCostTesseract(cfg.levelUpNeedTick)
                local resTesseract = self.player.resBag:resCostTesseract(resDict)
                local allTesseract = timeTesseract + resTesseract
                local newResDict = {
                    [constant.RES_MIT] = resDict[constant.RES_MIT] or 0,
                    [constant.RES_TESSERACT] = allTesseract,
                }
                if not self.player.resBag:enoughResDict(newResDict) then
                    return
                end
                self.player.resBag:costResDict(newResDict, {logType=gamelog.SOON_BUILD_LEVEL_UP})
                self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
            end
        else--""，""Carboxyl""
            local newResDict = upgradeUtil.calResCost(self, resDict, nil)
            newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] + wqCostCarboxyl
            if not self.player.resBag:enoughResDict(newResDict) then
                return
            end
            --""
            newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] - wqCostCarboxyl
            self.player.resBag:costResDict(newResDict, {logType=gamelog.BUILD_LEVEL_UP})
            if minObj then
                local wqResDict = {[constant.RES_TESSERACT] = wqCostCarboxyl}
                self.player.resBag:costResDict(wqResDict, {logType=gamelog.SPEED_BUILD_LEVEL_UP})
                minObj:setNextTick(0)
                if minObj.checkLevelUp then
                    minObj:checkLevelUp()
                end
            end
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    build:setNextTick(levelUpNeedTick * 1000)

    gg.client:send(self.player.linkobj,"S2C_Player_BuildLevelUp",{ build = build:pack() })
end

function BuildBag:buildRepair(id)
    local build = self.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if build.chain <= 0 then
        self.player:say(util.i18nFormat(errors.REPAIR_NOT_NEED))
        return
    end
    if constant.IsRefUnion(build) or constant.IsRefGrid(build) then
        self.player:say(util.i18nFormat(errors.BUILD_REF_BUSY))
        return
    end
    local repairLife = build.life - build.curLife
    if repairLife <= 0 then
        self.player:say(util.i18nFormat(errors.REPAIR_NOT_NEED))
        return
    end
    local repairCostCfg = gg.getExcelCfg("repairCost")
    local cost = repairCostCfg[build.level].cost
    if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cost) then
        self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_STARCOIN]))
        return
    end
    self.player.resBag:costRes(constant.RES_STARCOIN, cost, { logType = gamelog.REPAIR_BUILD_LIFE })
    self.player.taskBag:update(constant.TASK_REPAIR_COUNT, {})
    build.curLife = build.life
    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
end

-- function BuildBag:exchangeBuild(fromId, toId)
--     local fromBuild = self.builds[fromId]
--     if not fromBuild then
--         self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
--         return
--     end
--     local toBuild = self.builds[toId]
--     if not toBuild then
--         self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
--         return
--     end
--     if fromBuild.cfgId ~= constant.BUILD_LIBERATORSHIP or toBuild.cfgId ~= constant.BUILD_LIBERATORSHIP then
--         self.player:say(util.i18nFormat(errors.BUILD_POS_EXCHANGE_ERR))
--         return
--     end
--     local fromPos = {x = fromBuild.x, z = fromBuild.z}
--     local toPos = {x = toBuild.x, z = toBuild.z}

-- 	self:setLandShipPos(fromBuild, {x = toPos.x, z = toPos.z})
--     gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = fromBuild:pack() })

-- 	self:setLandShipPos(toBuild, {x = fromPos.x, z = fromPos.z})
--     gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = toBuild:pack() })
-- end

function BuildBag:getBuildRes(id)
    local build = self.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
	local resDict = {
		["curStarCoin"] = {
			storeKey = "storeStarCoin",
			const = constant.RES_STARCOIN,
			updateKey = "getStarCoin",
		},
		["curIce"] = {
			storeKey = "storeIce",
			const = constant.RES_ICE,
			updateKey = "getIce",
		},
		-- ["curCarboxyl"] = {
		-- 	storeKey = "storeCarboxyl",
		-- 	const = constant.RES_CARBOXYL,
		-- 	updateKey = "getCarboxyl",
		-- },
		["curTitanium"] = {
			storeKey = "storeTitanium",
			const = constant.RES_TITANIUM,
			updateKey = "getTitanium",
		},
		["curGas"] = {
			storeKey = "storeGas",
			const = constant.RES_GAS,
			updateKey = "getGas",
		},
	}
	local update = {id = build.id}
	for key, value in pairs(resDict) do
		if build[key] > 0 then
			local storeCount = self:getResCount(value.storeKey)
			local resCount = self.player.resBag:getRes(value.const, true)
			local getCount = storeCount - resCount
			getCount = math.min(getCount, build[key])
			if getCount > 0 then
				self.player.resBag:safeAddRes(value.const, getCount, { logType=gamelog.GET_BUILD_RES}, true, {buildId = build.id})
				build[key] = build[key] - getCount
				update[value.updateKey] = getCount
                self.player.taskBag:update(constant.TASK_COLLECT_RES_COUNT, {cfgId = value.const, count = 1})
                self.player.taskBag:update(constant.TASK_COLLECT_RES_NUM, {cfgId = value.const, count = getCount})
			end
		end
	end
	gg.client:send(self.player.linkobj,"S2C_Player_BuildGetRes", update)
    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate", { build = build:pack() })
end

function BuildBag:calResearchWorkQueResCost()
    local minSolider
    local minTick
    if self:isResearchWorkingQueueFull() then
        for _, v in pairs(self.soliderLevels) do
            local lessTime = v:getLessTick()
            if lessTime > 0 then
                if not minTick or lessTime < minTick then
                    minTick = lessTime
                    minSolider = v
                end
            end
        end
    end
    local needTesseract = 0
    if minTick then
        needTesseract = self.player.resBag:timeCostTesseract(minTick)
    end
    return needTesseract, minSolider
end

--""
function BuildBag:soliderLevelUp(cfgId, speedUp)
    -- if self:isResearchWorkingQueueFull() then
    --     self.player:say(util.i18nFormat(errors.RESEARCH_WORK_QUEUE_FULL))
    --     return
    -- end

    local soliderLevel = self.soliderLevels[cfgId]
    if not soliderLevel then
        self.player:say(util.i18nFormat(errors.SOLIDER_NOT_EXIST))
        return
    end
    if soliderLevel.level <= 0 then
        self.player:say(util.i18nFormat(errors.SOLIDER_NOT_UNLOCK))
        return
    end
    -- ""，""
    local builds = self:getBuildsByCfgId(constant.BUILD_HYPERSPACERESEARCH)
    for _,build in pairs(builds) do
        if build:isLevelUp() then
            self.player:say(util.i18nFormat(errors.BUILD_BUILD_UPGRADING))
            return
        end
    end

    local nextLevel = soliderLevel.level + 1
    local nextCfg = ggclass.SoliderLevel.getSoliderCfg(soliderLevel.cfgId, nextLevel)
    if not nextCfg then
        self.player:say(util.i18nFormat(errors.LEVEL_MAX))
        return
    end
    local cfg = ggclass.SoliderLevel.getSoliderCfg(soliderLevel.cfgId, soliderLevel.level)
    if not cfg then
        self.player:say(util.i18nFormat(errors.CUR_LEVEL_CONFIG_NIL))
        return
    end
    local arrive, msg = self:preBuildLevelAndCountEnough(cfg.levelUpNeedBuilds)
    if not arrive then
        self.player:say(msg)
        return
    end

    local resDict = {
        [constant.RES_STARCOIN] = cfg.levelUpNeedStarCoin or 0,
        [constant.RES_ICE] = cfg.levelUpNeedIce or 0,
        [constant.RES_TESSERACT] = cfg.levelUpNeedTesseract or 0,
        [constant.RES_TITANIUM] = cfg.levelUpNeedTitanium or 0,
        [constant.RES_GAS] = cfg.levelUpNeedGas or 0,
        [constant.RES_MIT] = cfg.levelUpNeedMit or 0,
    }
    local wqCostMit, minObj = self:calResearchWorkQueResCost()
    if speedUp == 1 then
        local lessTick = soliderLevel:getLessTick()
        if lessTick > 0 then--""，""Carboxyl(maybe also mit)
            local timeTesseract = self.player.resBag:timeCostTesseract(lessTick)
            if not self.player.resBag:enoughRes(constant.RES_TESSERACT, timeTesseract) then
                self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
                gg.client:send(self.player.linkobj, "S2C_Player_MitNotEnoughTips", {})
                return
            end
            self.player.resBag:costRes(constant.RES_TESSERACT, timeTesseract, {logType=gamelog.SOLIDER_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        else--""，""Carboxyl(maybe also mit)
            local timeTesseract = self.player.resBag:timeCostTesseract(cfg.levelUpNeedTick)
            local resTesseract = self.player.resBag:resCostTesseract(resDict)
            local allTesseract = timeTesseract + resTesseract
            local newResDict = {
                [constant.RES_MIT] = resDict[constant.RES_MIT] or 0,
                [constant.RES_TESSERACT] = allTesseract,
            }
            if not self.player.resBag:enoughResDict(newResDict) then
                return
            end
            self.player.resBag:costResDict(newResDict, {logType=gamelog.SOON_SOLDIER_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        end
    else--""，""Carboxyl""
        local newResDict = upgradeUtil.calResCost(self, resDict, nil)
        newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] + wqCostMit
        if not self.player.resBag:enoughResDict(newResDict) then
            return
        end
        --""
        newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] - wqCostMit
        self.player.resBag:costResDict(newResDict, {logType=gamelog.SOLIDER_LEVEL_UP})
        if minObj then
            local wqResDict = {[constant.RES_TESSERACT] = wqCostMit}
            self.player.resBag:costResDict(wqResDict, {logType=gamelog.SPEED_SOLIDER_LEVEL_UP})
            minObj:setNextTick(0)
            if minObj.checkLevelUp then
                minObj:checkLevelUp()
            end
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    soliderLevel:setNextTick(levelUpNeedTick * 1000)

    gg.client:send(self.player.linkobj,"S2C_Player_SoliderLevelUpdate",{ soliderLevel = soliderLevel:pack() })
end

function BuildBag:speedUpSoliderLevelUp(cfgId)
    local soliderLevel = self.soliderLevels[cfgId]
    if not soliderLevel then
        self.player:say(util.i18nFormat(errors.SOLIDER_NOT_EXIST))
        return
    end
    --""
    local lessTick = soliderLevel:getLessTick()
    if lessTick <= 0 then
        self.player:say(util.i18nFormat(errors.SPEEDUP_ERR))
        return
    end
    local needTesseract = self.player.resBag:timeCostTesseract(lessTick)
    if not self.player.resBag:enoughRes(constant.RES_TESSERACT, needTesseract) then
        self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
        return
    end
    soliderLevel:setNextTick(0)
    self.player.resBag:costRes(constant.RES_TESSERACT, needTesseract, {logType=gamelog.SPEED_SOLIDER_LEVEL_UP})
    self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
end

--""
function BuildBag:isSoliderMaxLevel(cfgId, level)
    --""
    local nextLevelCfg = ggclass.SoliderLevel.getSoliderCfg(cfgId, level+1)
    if not nextLevelCfg then
        return true
    end
    return false
end

function BuildBag:hasSoliderQualityUpgrade()
    for cfgId, value in pairs(self.soliderLevels) do
        if value.level <=0 and value:getLessTick() > 0 then
            return true
        end
    end
end

-- --""
-- function BuildBag:soliderQualityUpgrade(cfgId, speedUp)
    
-- end

-- --""
-- function BuildBag:soliderQualityUpgradeSpeed(cfgId)
   
-- end

-- --""
-- function BuildBag:soliderForge(cfgId, addRatio)
--     local soliderForgeLevel = self.soliderForgeLevels[cfgId]
--     if not soliderForgeLevel then
--         self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
--         return
--     end
--     --""cfgId"",""
--     local soliderLevel = self.soliderLevels[cfgId]
--     if not soliderLevel then
--         return
--     end
--     if soliderLevel.level <= 0 then
--         return
--     end
--     local curCfg = ggclass.SoliderForgeLevel.getSoliderForgeLevelCfg(cfgId, soliderForgeLevel.level)
--     if not curCfg then
--         return
--     end
--     local nextLevelCfg = ggclass.SoliderForgeLevel.getSoliderForgeLevelCfg(cfgId, soliderForgeLevel.level+1)
--     if not nextLevelCfg then
--         return
--     end
--     local targetRatio = math.min(curCfg.startRatio + addRatio, curCfg.maxRatio)
--     local trueAddRatio = targetRatio - curCfg.startRatio
--     --TODO:""
--     local costMit = trueAddRatio * curCfg.mitPerRatio
--     if costMit < 0 then
--         costMit = 0
--     end

--     --""
--     local resDict = {
--         [constant.RES_STARCOIN] = curCfg.levelUpNeedStarCoin or 0,
--         [constant.RES_ICE] = curCfg.levelUpNeedIce or 0,
--         [constant.RES_TESSERACT] = curCfg.levelUpNeedTesseract or 0,
--         [constant.RES_TITANIUM] = curCfg.levelUpNeedTitanium or 0,
--         [constant.RES_GAS] = curCfg.levelUpNeedGas or 0,
--         [constant.RES_MIT] = costMit,
--     }
--     if not self.player.resBag:enoughResDict(resDict) then
--         return
--     end
--     self.player.resBag:costResDict(resDict, {logType=gamelog.FORGE_LEVEL_UP})

--     local randValue = math.random(1, 100)
--     if randValue <= targetRatio then
--         soliderForgeLevel.level = nextLevelCfg.level
--         gg.client:send(self.player.linkobj, "S2C_Player_SoliderForgeLevelUpdate",{ forgeLevelInfo = soliderForgeLevel:pack(), result = true })
--     else
--         gg.client:send(self.player.linkobj, "S2C_Player_SoliderForgeLevelUpdate",{ result = false })
--     end
-- end

--""
function BuildBag:removeMess(id)
    local build = self.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if build.type ~= constant.BUILD_TYPE_MESS then
        self.player:say(util.i18nFormat(errors.BUILD_TYPE_ERR))
        return
    end
    local cfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
    if not cfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end

    local arrive, msg = self:preBuildLevelAndCountEnough(cfg.removeNeedBuilds)
    if not arrive then
        self.player:say(msg)
        return
    end

    --""
    if cfg.removeNeedStarCoin and cfg.removeNeedStarCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cfg.removeNeedStarCoin) then
            self.player:say(util.i18nFormat(errors.STARCOIN_NOT_ENOUGH))
            return
        end
    end

    --""
    if cfg.removeNeedStarCoin and cfg.removeNeedStarCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cfg.removeNeedStarCoin, {logType=gamelog.REMOVE_MESS})
    end

    local getMit = cfg.removeGitMit or 0
    local getRes = cfg.removeGetRes or {}
    local resDict = {}
    for i, v in ipairs(getRes) do
        resDict[v[1]] = v[2]
    end
    self.player.resBag:addResDict(resDict, { logType = gamelog.REMOVE_MESS })

    --""
    gg.client:send(self.player.linkobj,"S2C_Player_RemoveMess",{ id = build.id, getMit = getMit })
    self:delBuild(build.id, {logType=gamelog.REMOVE_MESS})
    local minLvCount = self:getMinLvMessCount()
    if minLvCount == 0 and constant.BUILD_USE_MESS_MIN_LV then
        self.messMinLv = self.messMinLv + 1
        local pushMess = self:getMinLvMess()
        for i, v in ipairs(pushMess) do
            gg.client:send(self.player.linkobj, "S2C_Player_BuildAdd",{ build = v:pack() })
        end
    end
end

--""
--@param[type=int] soliderCfgId""id ""0
--@param[type=int] buildId""id "" ""
function BuildBag:getReserveArmyCount(soliderCfgId, buildId)
    soliderCfgId = soliderCfgId or 0
    local count = 0
    for id, val in pairs(self.reserveArmy) do
        if val.trainCfgId == soliderCfgId then
            if (buildId and id == buildId) or not buildId then
                count = count + val.count
            end
        end
    end
    return count
end

--""
--@param[type=int] num""
--@param[type=int] soliderCfgId""id ""0 ""
--@param[type=int] buildId""id ""
function BuildBag:costReserveArmyCount(num, soliderCfgId, buildId)
    soliderCfgId = soliderCfgId or 0
    if num == 0 then
        return false
    end
    local curCount = self:getReserveArmyCount(soliderCfgId, buildId)
    if curCount < num then
        return false
    end
    local update = {}
    for id, val in pairs(self.reserveArmy) do
        if val.trainCfgId == soliderCfgId then
            if (buildId and id == buildId) or not buildId then
                if num > val.count then
                    num = num - val.count
                    val.count = 0
                else
                    val.count = val.count - num
                    num = 0
                end
                table.insert(update, val)
            end
        end
        if num == 0 then
            break
        end
    end
    if table.count(update) > 0 then
        self:_sendReserveArmyUpdate(constant.OP_MODIFY, update)
    end
    return true
end

--""
--@param[type=int] num""
--@param[type=int] soliderCfgId""id ""0
--@param[type=int] buildId""id ""
function BuildBag:addReserveArmyCount(num, soliderCfgId, buildId)
    soliderCfgId = soliderCfgId or 0
    if num == 0 then
        return false
    end
    local update = {}
    for id, val in pairs(self.reserveArmy) do
        if val.trainCfgId == soliderCfgId then
            if (buildId and id == buildId) or not buildId then
                local build = self.builds[id]
                local tmpCfg = gg.getExcelCfgByFormat("buildConfig", build.cfgId, build.quality, build.level)
                local space = tmpCfg.maxTrainSpace - val.count
                if num > space then
                    num = num - space
                    val.count = val.count + space
                else
                    val.count = val.count + num
                    num = 0
                    
                end
                table.insert(update, val)
            end
        end
        if num == 0 then
            break
        end
    end
    if table.count(update) > 0 then
        self:_sendReserveArmyUpdate(constant.OP_MODIFY, update)
    end

    return true
end

function BuildBag:updateReserveArmy(notNotify)
    local update = {}
    local now = gg.time.time()
    local trainNeedTick = gg.getGlobalCfgIntValue("RecruitsTrainCD", 15)
    for id, val in pairs(self.reserveArmy) do
        if val.trainCount < 0 then--fix bug
            val.trainCount = 0
        end
        if val.trainTick > 0 and val.startTime > 0 and val.trainCount > 0 then
            local passTime = now - val.startTime
            local addCount = math.floor(passTime / trainNeedTick)
            if addCount > 0 then
                if addCount >= val.trainCount then
                    val.count = val.count + val.trainCount
                    val.trainCount = 0
                else
                    val.count = val.count + addCount
                    val.trainCount = val.trainCount - addCount
                end
                val.startTime = val.startTime + (addCount * trainNeedTick)
                val.trainTick = val.trainTick + (addCount * trainNeedTick)

                if val.trainCount == 0 then
                    val.trainTick = 0
                    val.startTime = 0
                end
                table.insert(update, val)
            end
        end
    end
    if not notNotify and table.count(update) > 0 then
        self:_sendReserveArmyUpdate(constant.OP_MODIFY, update)
    end
end

function BuildBag:doReserveArmyTrain(id, soliderCfgId, soliderCount, speedup)
    if soliderCount < 0 then
        return
    end
    local build = self.builds[id]
    if not build then
        return
    end
    --""
    local op = constant.OP_MODIFY
    local rsvArmy = self.reserveArmy[id]
    if not rsvArmy then
        rsvArmy = {
            buildId = id,
            trainCfgId = 0,
            trainCount = 0,
            trainTick = 0,
            count = 0,
            startTime = 0,
        }
        self.reserveArmy[id] = rsvArmy
        op = constant.OP_ADD
    end
    if rsvArmy.trainCount == 0 and soliderCount == 0 then
        return
    end
    local trainSpace = 1
    local curSoliderCount = rsvArmy.count
    local curTrainSpace = trainSpace * curSoliderCount
    local needTrainSpace = trainSpace * soliderCount
    local tmpCfg = gg.getExcelCfgByFormat("buildConfig", build.cfgId, build.quality, build.level)
    if curTrainSpace + needTrainSpace > tmpCfg.maxTrainSpace then
        self.player:say(util.i18nFormat(errors.TRAIN_SPACE_NOT_ENOUGH))
        return
    end
    local baseLevel = self:getBuildLevelByCfgId(constant.BUILD_BASE)
    local baseLevelCfg = gg.getExcelCfg("baseLevel")
    local needRes = baseLevelCfg[baseLevel].RecruitsTrainRes  --gg.getGlobalCfgTableValue("RecruitsTrainRes", {})
    local resDict = {}
    for i, v in ipairs(needRes) do
        resDict[v[1]] = v[2] * soliderCount
    end
    if speedup then
        local resTesseract = self.player.resBag:resCostTesseract(resDict)
        local count = rsvArmy.trainCount + soliderCount
        local trainNeedTick = gg.getGlobalCfgIntValue("RecruitsTrainCD", 15)
        local timeTesseract = self.player.resBag:timeCostTesseract(trainNeedTick * count)
        local newResDict = {
            [constant.RES_MIT] = resDict[constant.RES_MIT] or 0,
            [constant.RES_TESSERACT] = (resDict[constant.RES_TESSERACT] or 0) + timeTesseract + resTesseract,
        }
        resDict = newResDict
    end
    --""
    if not self.player.resBag:enoughResDict(resDict) then
        return
    end
    self.player.resBag:costResDict(resDict, {logType=gamelog.TRAIN_SOLIDER})
    local now = gg.time.time()
    rsvArmy.trainCfgId = soliderCfgId
    rsvArmy.trainCount = rsvArmy.trainCount + soliderCount
    if rsvArmy.trainTick == 0 then
        rsvArmy.trainTick = now
        rsvArmy.startTime = now
    end
    if speedup then
        rsvArmy.count = rsvArmy.count + rsvArmy.trainCount
        rsvArmy.trainCount = 0
        rsvArmy.trainTick = 0
        rsvArmy.startTime = 0
    end
    self.player.taskBag:update(constant.TASK_RESERVE_ARMY_TRAIN, {cfgId = self.cfgId, count = soliderCount})
    self.player.taskBag:update(constant.TASK_TRAIN_RESERVE_ARMY, {count = soliderCount })
    self:_sendReserveArmyUpdate(op, {rsvArmy})
    return true
end

--""
function BuildBag:reserveArmyTrain(id, soliderCfgId, soliderCount)
    if soliderCount <= 0 then
        return
    end
    local build = self.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if build.cfg.maxTrainSpace <= 0 then
        self.player:say(util.i18nFormat(errors.TRAIN_SPACE_NOT_ENOUGH))
        return
    end
    --""
    if build:getLessTick() > 0 then
        self.player:say(util.i18nFormat(errors.LEVELINGUP))
        return
    end
    return self:doReserveArmyTrain(id, soliderCfgId, soliderCount, false)
end

function BuildBag:GetReserveArmy(id)
    local build = self.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    local rsvArmy = self.reserveArmy[id]
    self:_sendReserveArmyUpdate(0, {rsvArmy})
end

--""
function BuildBag:SpeedupReserveArmy(id, soliderCfgId, soliderCount)
    if soliderCount < 0 then
        return
    end
    local build = self.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if build.cfg.maxTrainSpace <= 0 then
        self.player:say(util.i18nFormat(errors.TRAIN_SPACE_NOT_ENOUGH))
        return
    end
    --""
    if build:getLessTick() > 0 then
        self.player:say(util.i18nFormat(errors.LEVELINGUP))
        return
    end
    return self:doReserveArmyTrain(id, soliderCfgId, soliderCount, true)
end

function BuildBag:getWithdrawReduce()
    local blackMarketLevel = self:getBuildLevelByCfgId(constant.BUILD_BLACK_MARKET)
    local cfg = ggclass.Build.getBuildCfg(constant.BUILD_BLACK_MARKET, 0, blackMarketLevel)
    if not cfg then
        return 0
    end
    return cfg.withdrawReduce or 0
end

--""
function BuildBag:plunderBuildRes(resCfgId, plunderRatio)
    if not plunderRatio then
        return
    end
    if plunderRatio > 1 or plunderRatio <= 0 then
        return
    end
    for _, build in pairs(self.builds) do
        if build:isMakeResBuild() then
            if resCfgId == constant.RES_STARCOIN and build.curStarCoin > 0 then
                build.curStarCoin = math.floor((1-plunderRatio) * build.curStarCoin)
            elseif resCfgId == constant.RES_ICE and build.curIce > 0 then
                build.curIce = math.floor((1-plunderRatio) * build.curIce)
            elseif resCfgId == constant.RES_CARBOXYL and build.curCarboxyl > 0 then
                build.curCarboxyl = math.floor((1-plunderRatio) * build.curCarboxyl)
            elseif resCfgId == constant.RES_TITANIUM and build.curTitanium > 0 then
                build.curTitanium = math.floor((1-plunderRatio) * build.curTitanium)
            elseif resCfgId == constant.RES_GAS and build.curGas > 0 then
                build.curGas = math.floor((1-plunderRatio) * build.curGas)
            end
            gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
        end
    end
end

function BuildBag:_createGmRobotBuilds()
    if not gg.isGmRobotPlayer(self.player.pid) then
        return
    end
    local cfg = gg.getExcelCfg("gmRobot")
    local robotCfg =  cfg[self.player.pid]
    if not robotCfg or not robotCfg.presetLayoutId then
        return
    end
    local presetBuilds = nil
    local pblCfg = gg.getExcelCfg("presetBuildLayout")
    for k, v in pairs(pblCfg) do
        if v.cfgId == robotCfg.presetLayoutId then
            presetBuilds = v.presetBuilds
            break
        end
    end
    if not presetBuilds or not next(presetBuilds) then
        return
    end
    for _, v in pairs(presetBuilds) do
        local param = {
            cfgId = v.cfgId,
            quality = v.quality,
            level = v.level,
            x = v.x,
            z = v.z,
            life = v.life,
            curLife = v.curLife,
        }
        local build = self:newBuild(param)
        if build then
            self:addBuild(build, { logType = gamelog.CREATE_PLAYER_GIFT, notNotify = true })
        end
    end
    return true
end

function BuildBag:_clearAllBuilds()
    self.builds = {}
    self.landShipGrids = {}
    self.grids = {}
    util.initMapGrids({
		grids = self.grids,
		builds = self.builds,
		landShipGrids = self.landShipGrids,
	})
end

--""
function BuildBag:createPresetBuilds(cfgId)
    local presetBuildLayoutCfgs = cfg.get("etc.cfg.presetBuildLayout")
    local presetCfg = presetBuildLayoutCfgs[cfgId]
    if not presetCfg then
        return
    end
    self:_clearAllBuilds()
    for _, v in pairs(presetCfg.presetBuilds) do
        local param = {
            cfgId = v.cfgId,
            quality = v.quality,
            level = v.level,
            x = v.x,
            z = v.z,
            life = v.life,
            curLife = v.curLife,
        }
        local build = self:newBuild(param)
        if build then
            self:addBuild(build, { logType = gamelog.CREATE_PLAYER_GIFT, notNotify = true })
        end
    end
    self.player:save_to_db()
end

-- ""
function BuildBag:getConstructionCount()
    return self.constructionCount
end

function BuildBag:_clearGmRobotBuilds()
    if not gg.isGmRobotPlayer(self.player.pid) then
        return
    end
    self:_clearAllBuilds() 
end

function BuildBag:_recreateGmRobotBuilds()
    self:_clearGmRobotBuilds()
    self:_createGmRobotBuilds()
end

function BuildBag:_sendReserveArmyUpdate(op, list)
    gg.client:send(self.player.linkobj,"S2C_Player_ReserveArmyUpdate",{
        op_type = op,
        armys = list
    })
end

function BuildBag:returnFromUnion(idList, nftLifeDict)
    for i, id in ipairs(idList) do
        local build = self:getBuild(id)
        if build then
            build.ref = constant.REF_NONE
            build.refBy = 0
            build.donateTime = 0
            build.ownerPid = 0
            if nftLifeDict[id] then
                build.curLife = nftLifeDict[id]
            end
            gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
        end
    end
end

function BuildBag:returnFromStarmapGrid(nftBuilds)
    local ret = {}
    for _, v in pairs(nftBuilds or {}) do
        local build = self:getBuild(v.id)
        if build then
            build.curLife = v.curLife
            constant.setRef(build, constant.REF_NONE)
            build:setRefBy(0)
            gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
            table.insert(ret, v.id)
        end
    end
    return ret
end

function BuildBag:_initPresetBuilds(isAssert)
    local initLayout = gg.getGlobalCfgIntValue("InitBuildLayout", 0)
    if isAssert then
        assert(initLayout ~= 0, "BuildBag:oncreate InitBuildLayout error")
    else
        if initLayout == 0 then
            return
        end
    end
    local presetBuilds = nil
    local pblCfg = gg.getExcelCfg("presetBuildLayout")
    for k, v in pairs(pblCfg) do
        if v.cfgId == initLayout then
            presetBuilds = v.presetBuilds
            break
        end
    end
    if not presetBuilds or not next(presetBuilds) then
        if isAssert then
            assert(false, "BuildBag:oncreate presetBuilds error")
        else
            return
        end
    end
    for _, v in pairs(presetBuilds) do
        local param = {
            cfgId = v.cfgId,
            quality = v.quality,
            level = v.level,
            x = v.x,
            z = v.z,
            life = v.life,
            curLife = v.curLife,
        }
        local build = self:newBuild(param)
        if build then
            self:addBuild(build, { logType = gamelog.CREATE_PLAYER_GIFT, notNotify = true })
        end
    end
end

function BuildBag:oncreate()
    self:_createGmRobotBuilds()
    --""
    if not next(self.builds) then
        self:_initPresetBuilds(true)
    end
end

--"","",""onload""
function BuildBag:onload()
    --""
    for _,build in pairs(self.builds) do
        build:makeRes(true)
    end
    self:checkBuilds(true)
    self:refreshSoliderLevel(true)
    self:checkSoliderLevelsUp(true)
    self:refreshSoliderForgeLevel(true)
    local baseBuildLevel = self:getBuildLevelByCfgId(constant.BUILD_BASE)
    if baseBuildLevel and baseBuildLevel > 0 then
        gg.shareProxy:send("setPlayerBaseInfo", self.player.pid, { level = baseBuildLevel })
    end
end

function BuildBag:InitDefence()
    local buildCfg = gg.getGlobalCfgTableValue("InitDefence",{})
    local buildCfgId = buildCfg[1]
    local quality = buildCfg[2]
    local level = buildCfg[3]
    local life = ggclass.Build.randomBuildLife(quality)
    local param = {
        cfgId = buildCfgId,
        quality = quality,
        level = level,
        life = life,
        curLife = life,
        chain = constant.BUILD_CHAIN_TOWER,
    }
    local build = self.player.buildBag:newBuild(param)
    if build then
        local ret = self.player.buildBag:addBuild(build, { logType = gamelog.CREATE_PLAYER_GIFT, notNotify = false })
    end
end

function BuildBag:correctNftBuildData(ids)
    for _,id in pairs(ids) do
        local build = self:getBuild(id)
        constant.setRef(build, constant.REF_NONE)
        build.refBy = 0
        build.donateTime = 0
        build.ownerPid = 0
    end
    gg.client:send(self.player.linkobj,"S2C_Player_BuildData",{ buildData = self:packBuild() })
    self.player:say(util.i18nFormat(errors.BUILD_FRESH_SUCCESS))
end

function BuildBag:correctBuilds(buildId)
    local nfts = {}
    if not buildId then  -- ""nft build""
        for _, build in pairs(self.builds) do
            if build.chain > 0 then
                if constant.IsRefUnion(build) or constant.IsRefGrid(build) then
                    if build.refBy > 0 then
                        nfts[build.id] = { refBy = build.refBy, level = build.level}
                    end
                end
            end
        end
    else -- ""nft""
        local nowTick = gg.time.time()
        if self.lastFreshNftTick ~= 0 and nowTick - self.lastFreshNftTick < 2 then
            self.player:say(util.i18nFormat(errors.BUILD_FREQUENT_REFRESH))
            return
        end
        self.lastFreshNftTick = nowTick
        local build = self:getBuild(buildId)
        if not build then
            self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
            return
        end
        if build.ref == 0 and build.refBy == 0 then
            return
        end
        if constant.IsRefUnion(build) then
            local unionId = self.player.unionBag:getMyUnionId()
            local nftsInfo = {}
            if unionId then
                table.insert(nftsInfo, {id = build.id , level = build.level})
                gg.unionProxy:send("updateNft", self.player.pid, unionId, nftsInfo)  -- ""
            end
        end
        nfts[build.id] = { refBy = build.refBy, level = build.level}
    end
    gg.starmapProxy:send("checkNftInGrid", self.player.pid, nfts)
end

-- ""
function BuildBag:sellBuild(BuildIds)
    local delIds = {}
    local rewardCount = 0
    for _,buildId in ipairs(BuildIds) do
        -- ""
        local build = self.builds[buildId]
        if not build then
            self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
            return
        end
        if build.chain > 0 and build.chain ~= constant.BUILD_CHAIN_TOWER then
            self.player:say(util.i18nFormat(errors.NFT_CANNOT_SELL))
            return
        end
        if build:isUpgrade() then
            self.player:say(util.i18nFormat(errors.BUILD_LEVEL_OR_SKILL_UP))
            return
        end
        if not constant.IsRefNone(build) then
            self.player:say(util.i18nFormat(errors.BUILD_REF_BUSY))
            return
        end
        -- ""
        local sellingPrice = gg.getGlobalCfgTableValue("SellingPrice", {})
        local resNum = sellingPrice[build.quality]
        rewardCount = rewardCount + resNum
        table.insert(delIds, buildId)
    end
    for _,Id in pairs(delIds) do
        self:delBuild(Id, { logType=gamelog.SELL_HERO })
    end
    self.player.resBag:addRes(constant.RES_STARCOIN, rewardCount, {logType=gamelog.SELL_HERO})
    local resInfo = {}
    table.insert(resInfo, { resCfgId = constant.RES_STARCOIN, count = rewardCount})
    resInfo.resCfgId = constant.RES_STARCOIN
    gg.client:send(self.player.linkobj, "S2C_Player_TipNote",  { tipType = 1, resInfo = resInfo })
    
end

function BuildBag:resetData()
    local delBuildIds = {}
    for _, build in pairs(self.builds) do
        if build.chain > 0 then
            build.nextTick = 0
            build.curStarCoin = 0
            build.curIce = 0
            build.curCarboxyl = 0
            build.curTitanium = 0
            build.curGas = 0
            build.lastMakeTick = 0
            build.soliderCfgId = 0
            build.soliderCount = 0
            build.trainCfgId = 0
            build.trainCount = 0
            build.trainTick = 0
            build.fightTick = 0

            build.level = 1
            constant.setRef(build, constant.REF_NONE)
            build.refBy = 0
            build.donateTime = 0
            build.ownerPid = 0
        else
            self.reserveArmy[build.id] = nil
            if build.cfgId == constant.BUILD_SANCTUARY then
                self.sanctuary = {}
                self.sanctuaryValue = {}
            end
            table.insert(delBuildIds, build.id)
            util.resetMapGrids({
                pos = {x = build.x, z = build.z},
                length = build.length,
                width = build.width,
                grids = self.grids,
            })
        end
    end
    for i, v in ipairs(delBuildIds) do
        self.builds[v] = nil
    end
    self.soliderLevels = {}                     -- ""
    self.soliderForgeLevels = {}                --""
    self.reserveArmy = {}                       -- ""
    self:_initPresetBuilds(false)
    self:updateConstructionCount()
    self:refreshSoliderLevel(true)
end

function BuildBag:onreset()
    self:resetData()
end

function BuildBag:onlogin()
    if not self.giftBuild then
        self.giftBuild = 1
        self:InitDefence()
    end
    self:_recreateGmRobotBuilds()
    gg.client:send(self.player.linkobj,"S2C_Player_BuildData",{ buildData = self:packBuild() })
    gg.client:send(self.player.linkobj,"S2C_Player_SoliderLevelData",{ soliderLevelData = self:packSoliderLevel() })
    gg.client:send(self.player.linkobj,"S2C_Player_SoliderForgeLevelData", {forgeLevelInfos = self:packSoliderForgeLevel()})
    gg.client:send(self.player.linkobj,"S2C_Player_BuildQueueData",{ buildQueueCount = self:_getBuildQueueLimit()  })
    if self.sanctuary.buildId then
        gg.client:send(self.player.linkobj,"S2C_Player_SanctuaryHeros",{ data = self:getSanctuaryHeros(), buildId = self.sanctuary.buildId})
    end
    self:_sendReserveArmyUpdate(constant.OP_ADD, self:packReserveArmy())
    self:updateConstructionCount()
    self:calSanctuaryValue()
end

function BuildBag:onSecond()
    self:checkBuilds()
    self:checkSoliderLevelsUp()
    self:checkReserveArmy()
end

function BuildBag:checkBuilds(notNotify)
    for _,build in pairs(self.builds) do
        build:checkLevelUp(notNotify)
        build:checkTrainFinish(notNotify)
    end
end

function BuildBag:checkSoliderLevelsUp(notNotify)
    for _,soliderLevel in pairs(self.soliderLevels) do
        soliderLevel:checkLevelUp(notNotify)
    end
end

function BuildBag:checkReserveArmy(notNotify)
    self:updateReserveArmy(true)
end

function BuildBag:onHalfHourUpdate()
    for _,build in pairs(self.builds) do
        build:makeRes()
    end
end

return BuildBag