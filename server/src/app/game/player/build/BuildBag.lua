local BuildBag = class("BuildBag")

function BuildBag:ctor(param)
    self.player = param.player                  -- 
    self.builds = {}                            -- 
    self.buildGrids = {}                        -- 

    self.soliderLevels = {}                     -- 

    self.mineLevels = {}                        -- 
end

function BuildBag:newBuild(param)
    param.player = self.player
    return ggclass.Build.create(param)
end

function BuildBag:newSoliderLevel(param)
    param.player = self.player
    return ggclass.SoliderLevel.create(param)
end

function BuildBag:newMineLevel(param)
    param.player = self.player
    return ggclass.MineLevel.create(param)
end

function BuildBag:getMineLevel(cfgId)
    local mineLevel = self.mineLevels[cfgId]
    if not mineLevel then
        return 0
    end
    return mineLevel.level
end

function BuildBag:getBuild(id)
    return self.builds[id]
end

--
function BuildBag:generateBuild(cfgId, quality, level)
    local life = ggclass.Build.randomBuildLife(quality)
    local curLife = life
    local param = { cfgId = cfgId, quality = quality, level = level or 0, life = life, curLife = curLife }
    return self:newBuild(param)
end

function BuildBag:serialize()
    local data = {}
    data.builds = {}
    for _,build in pairs(self.builds) do
        table.insert(data.builds, build:serialize())
    end
    data.soliderLevels = {}
    for _, soliderLevel in pairs(self.soliderLevels) do
        table.insert(data.soliderLevels, soliderLevel:serialize())
    end
    data.mineLevels = {}
    for _, mineLevel in pairs(self.mineLevels) do
        table.insert(data.mineLevels, mineLevel:serialize())
    end
    return data
end

function BuildBag:deserialize(data)
    if not data then
        return
    end
    if data.builds and next(data.builds) then
        for _, buildData in ipairs(data.builds) do
            local build = self:newBuild(buildData)
            if build then
                build:deserialize(buildData)
                self.builds[build.id] = build
            end
        end
    end
    if data.soliderLevels and next(data.soliderLevels) then
        for _, soliderLevelData in ipairs(data.soliderLevels) do
            local soliderLevel = self:newSoliderLevel(soliderLevelData)
            if soliderLevel then
                soliderLevel:deserialize(soliderLevelData)
                self.soliderLevels[soliderLevel.cfgId] = soliderLevel
            end
        end
    end
    if data.mineLevels and next(data.mineLevels) then
        for _, mineLevelData in ipairs(data.mineLevels) do
            local mineLevel = self:newMineLevel(mineLevelData)
            if mineLevel then
                mineLevel:deserialize(mineLevelData)
                self.mineLevels[mineLevel.cfgId] = mineLevel
            end
        end
    end
end

function BuildBag:packBuild()
    local buildData = {}
    for id,build in pairs(self.builds) do
        table.insert(buildData, build:pack())
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

function BuildBag:packMineLevel()
    local mineLevelData = {}
    for id,mineLevel in pairs(self.mineLevels) do
        table.insert(mineLevelData, mineLevel:pack())
    end
    return mineLevelData
end

--
function BuildBag:refreshBuildGrids()
    self.buildGrids = {}
    for _, build in pairs(self.builds) do
        local startX = build.x
        local startZ = build.z
        for i = 1, build.length do
            for j = 1, build.width do
                local x = startX + i - 1
                local z = startZ + j - 1
                self.buildGrids[x .. "_" .. z] = true
            end
        end
    end
end

function BuildBag:addSoliderLevel(soliderLevel)
    self.soliderLevels[soliderLevel.cfgId] = soliderLevel
    gg.client:send(self.player.linkobj,"S2C_Player_SoliderLevelUpdate",{soliderLevel=soliderLevel:pack()})
end

--,
function BuildBag:refreshSoliderLevel(notNotify)
    --1
    local soliderCfg = cfg.get("etc.cfg.solider")
    for k,v in pairs(soliderCfg) do
        local soliderLevel = self.soliderLevels[v.cfgId]
        if not soliderLevel then
            local param = { cfgId = v.cfgId, level = 0}
            soliderLevel = self:newSoliderLevel(param)
            self.soliderLevels[v.cfgId] = soliderLevel
        end
        if soliderLevel.level <= 0 and v.level <= 0 then
            local levelUpNeedBuilds = v.levelUpNeedBuilds or {}
            local arrive = true
            for _, info in ipairs(levelUpNeedBuilds) do
                local needCfgId = info[1]
                local needLevel = info[2]
                if self:getBuildLevelByCfgId(needCfgId) < needLevel then
                    arrive = false
                    break
                end
            end
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

--,
function BuildBag:refreshMineLevel(notNotify)
    --1
    local buildCfg = cfg.get("etc.cfg.build")
    for k,v in pairs(buildCfg) do
        if v.subType == constant.BUILD_SUBTYPE_MINE then
            local mineLevel = self.mineLevels[v.cfgId]
            if not mineLevel then
                local param = { cfgId = v.cfgId, level = 0}
                mineLevel = self:newMineLevel(param)
                self.mineLevels[v.cfgId] = mineLevel
            end
            if mineLevel.level <= 0 and v.level <= 0 then
                local levelUpNeedBuilds = v.levelUpNeedBuilds or {}
                local arrive = true
                for _, info in ipairs(levelUpNeedBuilds) do
                    local needCfgId = info[1]
                    local needLevel = info[2]
                    if self:getBuildLevelByCfgId(needCfgId) < needLevel then
                        arrive = false
                        break
                    end
                end
                if arrive then
                    mineLevel.level = 1
                    self.mineLevels[v.cfgId] = mineLevel
                    if not notNotify then
                        gg.client:send(self.player.linkobj,"S2C_Player_MineLevelUpdate",{ mineLevel = self:pack() })
                    end
                end
            end
        end
    end
end

--Id
function BuildBag:getBuildLevelByCfgId(cfgId)
    local level = 0
    for _,build in pairs(self.builds) do
        if build.cfgId == cfgId and build.level > level then
            level = build.level
        end
    end
    return level
end

-- 
function BuildBag:getStoreStarCoin()
    local storeStarCoin = 0
    for _,build in pairs(self.builds) do
        storeStarCoin = storeStarCoin + build.storeStarCoin
    end
    return storeStarCoin
end

-- 
function BuildBag:getStoreIce()
    local storeIce = 0
    for _,build in pairs(self.builds) do
        storeIce = storeIce + build.storeIce
    end
    return storeIce
end

-- 
function BuildBag:getStoreCarboxyl()
    local storeCarboxyl = 0
    for _,build in pairs(self.builds) do
        storeCarboxyl = storeCarboxyl + build.storeCarboxyl
    end
    return storeCarboxyl
end

-- 
function BuildBag:getStoreTitanium()
    local storeTitanium = 0
    for _,build in pairs(self.builds) do
        storeTitanium = storeTitanium + build.storeTitanium
    end
    return storeTitanium
end

-- 
function BuildBag:getStoreGas()
    local storeGas = 0
    for _,build in pairs(self.builds) do
        storeGas = storeGas + build.storeGas
    end
    return storeGas
end

--
function BuildBag:getSoliderLevel(cfgId)
    local soliderLevel = self.soliderLevels[cfgId]
    if not soliderLevel then
        return 0
    end
    return soliderLevel.level
end

function BuildBag:canPutDown(oldPos, newPos, length, width, cfgId)
    if cfgId == constant.BUILD_LIBERATORSHIP then
        --
        local isShipPos = false
        for _, shipPos in ipairs(constant.BUILD_LIBERATORSHIPPOSLIST) do
            if shipPos[1] == newPos.x and shipPos[2] == newPos.z then
                isShipPos = true
                break
            end
        end
        if not isShipPos then
            return false
        end
        local liberatorShips = self:getBuildsByCfgId(cfgId)
        for _, liberatorShip in ipairs(liberatorShips) do
            if liberatorShip.x == newPos.x and liberatorShip.z == newPos.z then
                return false
            end
        end
        return true
    end
    local buildGrids = gg.deepcopy(self.buildGrids)
    if oldPos then
        local startOldX = oldPos.x
        local startOldZ = oldPos.z
        for i = 1, length do
            for j = 1, width do
                local x = startOldX + i - 1
                local z = startOldZ + j - 1
                buildGrids[x .. "_" .. z] = nil
            end
        end
    end
    local startNewX = newPos.x
    local startNewZ = newPos.z
    for i = 1, length do
        for j = 1, width do
            local x = startNewX + i - 1
            local z = startNewZ + j - 1
            if x < 6 or x > 52 or z < 6 or z > 52 then
                return false
            end
            if buildGrids[x .. "_" .. z] then
                return false
            end
        end
    end
    return true
end

--
function BuildBag:addBuildByParam(cfgId, quality, level, x, z, life, curLife, notNotify)
    local param = { cfgId = cfgId, quality = quality, level = level, x = x, z = z, life = life, curLife = curLife }
    local build = self:newBuild(param)
    if build then
        build:setMakeTick()
        self.builds[build.id] = build
        if not notNotify then
            gg.client:send(self.player.linkobj, "S2C_Player_BuildAdd",{ build = build:pack() })
        end
        return build
    end
    return nil
end

--
function BuildBag:addBuild(build, notNotify)
    build:setMakeTick()
    self.builds[build.id] = build
    if not notNotify then
        gg.client:send(self.player.linkobj, "S2C_Player_BuildAdd",{ build = build:pack() })
    end
end

--
function BuildBag:getBuildsByCfgId(cfgId)
    local builds = {}
    for _, build in pairs(self.builds) do
        if cfgId == build.cfgId then
            table.insert(builds, build)
        end
    end
    return builds
end

--
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

function BuildBag:createBuild(cfgId, pos)
    local cfg = ggclass.Build.getBuildCfg(cfgId, 1, 0)
    if not cfg then
        self.player:say(i18n.format("build not exist"))
        return
    end
    if cfgId == constant.BUILD_BASE then
        self.player:say(i18n.format("error base"))
        return
    end
    --
    local ret = self:canPutDown(nil, pos, cfg.length, cfg.width, cfgId)
    if not ret then
        self.player:say(i18n.format("error pos"))
        return
    end
    --
    local levelUpNeedBuilds = cfg.levelUpNeedBuilds or {}
    local arrive = true
    for _, info in ipairs(levelUpNeedBuilds) do
        local needCfgId = info[1]
        local needLevel = info[2]
        if self.player.buildBag:getBuildLevelByCfgId(needCfgId) < needLevel then
            arrive = false
            break
        end
    end
    if not arrive then
        self.player:say(i18n.format("less build level"))
        return
    end

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin) then
            self.player:say(i18n.format("less StarCoin"))
            return
        end
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        if not self.player.resBag:enoughRes(constant.RES_ICE, cfg.levelUpNeedIce) then
            self.player:say(i18n.format("less Ice"))
            return
        end
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl) then
            self.player:say(i18n.format("less Carboxyl"))
            return
        end
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        if not self.player.resBag:enoughRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium) then
            self.player:say(i18n.format("less Titanium"))
            return
        end
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        if not self.player.resBag:enoughRes(constant.RES_GAS, cfg.levelUpNeedGas) then
            self.player:say(i18n.format("less Gas"))
            return
        end
    end

    --
    local build = self:generateBuild(cfgId, 1)
    if not build then
        self.player:say(i18n.format("build error"))
        return
    end
    build:setNewPos(pos.x, pos.z)
    build:setNextTick((cfg.levelUpNeedTick or 0) * 1000)
    self:addBuild(build)

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin)
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        self.player.resBag:costRes(constant.RES_ICE, cfg.levelUpNeedIce)
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        self.player.resBag:costRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl)
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        self.player.resBag:costRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium)
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        self.player.resBag:costRes(constant.RES_GAS, cfg.levelUpNeedGas)
    end

    self:refreshBuildGrids()
end

--- 
--@param[type=integer] id id
--@param[type=table] source 
function BuildBag:delBuild(id, source)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    self.builds[id] = nil
    gg.client:send(self.player.linkobj, "S2C_Player_BuildDel",{ id = id})
    self:refreshBuildGrids()
    return build
end

function BuildBag:moveBuild(id, pos)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    if build.cfgId == constant.BUILD_LIBERATORSHIP then
        self.player:say(i18n.format("build can not move"))
        return
    end
    --
    local oldPos = Vector3.New(build.x, 0, build.z)
    local ret = self:canPutDown(oldPos, pos, build.length, build.width)
    if not ret then
        self.player:say(i18n.format("error pos"))
        gg.client:send(self.player.linkobj,"S2C_Player_BuildMove",{ ret = 1, build = build:pack() })
        return
    end
    build:setNewPos(pos.x, pos.z)
    gg.client:send(self.player.linkobj,"S2C_Player_BuildMove",{ ret = 0, build = build:pack() })

    self:refreshBuildGrids()
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

function BuildBag:levelUpBuild(id, speedUp)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    if build.subType == constant.BUILD_SUBTYPE_MINE then
        self.player:say(i18n.format("error mine"))
        return
    end
    local curLevel = build.level
    local nextLevel = curLevel + 1
    local nextCfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, nextLevel)
    if not nextCfg then
        self.player:say(i18n.format("max level"))
        return
    end
    local cfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, curLevel)
    if not cfg then
        self.player:say(i18n.format("error level"))
        return
    end

    --
    if build:getLessTick() > 0 then
        self.player:say(i18n.format("error levelup"))
        return
    end
    --
    if build:getLessTrainTick() > 0 then
        self.player:say(i18n.format("error trainning"))
        return
    end
    --,
    if build.cfgId == constant.BUILD_HEROHUT then
        if self.player.heroBag:isHeroBusy() then
            self.player:say(i18n.format("error hero busy"))
            return
        end
    end

    --
    local levelUpNeedBuilds = cfg.levelUpNeedBuilds or {}
    local arrive = true
    for _, info in ipairs(levelUpNeedBuilds) do
        local needCfgId = info[1]
        local needLevel = info[2]
        if self.player.buildBag:getBuildLevelByCfgId(needCfgId) < needLevel then
            arrive = false
            break
        end
    end
    if not arrive then
        self.player:say(i18n.format("less build level"))
        return
    end

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin) then
            self.player:say(i18n.format("less StarCoin"))
            return
        end
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        if not self.player.resBag:enoughRes(constant.RES_ICE, cfg.levelUpNeedIce) then
            self.player:say(i18n.format("less Ice"))
            return
        end
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl) then
            self.player:say(i18n.format("less Carboxyl"))
            return
        end
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        if not self.player.resBag:enoughRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium) then
            self.player:say(i18n.format("less Titanium"))
            return
        end
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        if not self.player.resBag:enoughRes(constant.RES_GAS, cfg.levelUpNeedGas) then
            self.player:say(i18n.format("less Gas"))
            return
        end
    end
    local SpeedUpNeedMit = 0
    if speedUp > 0 then
        local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
        local count = math.ceil((cfg.levelUpNeedTick or 0) / 60)
        SpeedUpNeedMit = SpeedUpPerMinute * count
        if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
            self.player:say(i18n.format("less Mit"))
            return
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    build:setNextTick(levelUpNeedTick * 1000)

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin)
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        self.player.resBag:costRes(constant.RES_ICE, cfg.levelUpNeedIce)
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        self.player.resBag:costRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl)
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        self.player.resBag:costRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium)
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        self.player.resBag:costRes(constant.RES_GAS, cfg.levelUpNeedGas)
    end
    if speedUp > 0 then
        self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
    end

    gg.client:send(self.player.linkobj,"S2C_Player_BuildLevelUp",{ build = build:pack() })
end

function BuildBag:speedUpLevelUpBuild(id)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    local lessTick = build:getLessTick()
    if lessTick <= 0 then
        self.player:say(i18n.format("error speedUp"))
        return
    end
    local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
    local count = math.ceil(lessTick / 60)
    local SpeedUpNeedMit = SpeedUpPerMinute * count
    if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
        self.player:say(i18n.format("less Mit"))
        return
    end
    build:setNextTick(0)
    self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
end

function BuildBag:exchangeBuild(fromId, toId)
    local fromBuild = self.builds[fromId]
    if not fromBuild then
        self.player:say(i18n.format("no build"))
        return
    end
    local toBuild = self.builds[toId]
    if not toBuild then
        self.player:say(i18n.format("no build"))
        return
    end
    if fromBuild.cfgId ~= constant.BUILD_LIBERATORSHIP or toBuild.cfgId ~= constant.BUILD_LIBERATORSHIP then
        self.player:say(i18n.format("can not exchange"))
        return
    end
    local fromX = fromBuild.x
    local fromZ = fromBuild.z
    local toX = toBuild.x
    local toZ = toBuild.z
    fromBuild:setNewPos(toX, toZ)
    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = fromBuild:pack() })

    toBuild:setNewPos(fromX, fromZ)
    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = toBuild:pack() })
end

function BuildBag:getBuildRes(id)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    if build.curStarCoin <= 0 and build.curIce <= 0 and build.curCarboxyl <= 0 and build.curTitanium <= 0 and build.curGas <= 0 then
        return
    end
    --
    if build.curStarCoin > 0 and self.player.resBag:getRes(constant.RES_STARCOIN) + build.curStarCoin > self:getStoreStarCoin() then
        self.player:say(i18n.format("max starCoin"))
        return
    end
    if build.curIce > 0 and self.player.resBag:getRes(constant.RES_ICE) + build.curIce > self:getStoreIce() then
        self.player:say(i18n.format("max ice"))
        return
    end
    if build.curCarboxyl > 0 and self.player.resBag:getRes(constant.RES_CARBOXYL) + build.curCarboxyl > self:getStoreCarboxyl() then
        self.player:say(i18n.format("max carboxyl"))
        return
    end
    if build.curTitanium > 0 and self.player.resBag:getRes(constant.RES_TITANIUM) + build.curTitanium > self:getStoreTitanium() then
        self.player:say(i18n.format("max titanium"))
        return
    end
    if build.curGas > 0 and self.player.resBag:getRes(constant.RES_GAS) + build.curGas > self:getStoreGas() then
        self.player:say(i18n.format("max gas"))
        return
    end
    if build.curStarCoin > 0 then
        self.player.resBag:addRes(constant.RES_STARCOIN, build.curStarCoin)
    end
    if build.curIce > 0 then
        self.player.resBag:addRes(constant.RES_ICE, build.curIce)
    end
    if build.curCarboxyl > 0 then
        self.player.resBag:addRes(constant.RES_CARBOXYL, build.curCarboxyl)
    end
    if build.curTitanium > 0 then
        self.player.resBag:addRes(constant.RES_TITANIUM, build.curTitanium)
    end
    if build.curGas > 0 then
        self.player.resBag:addRes(constant.RES_GAS, build.curGas)
    end
    gg.client:send(self.player.linkobj,"S2C_Player_BuildGetRes",{ id = build.id, getStarCoin = build.curStarCoin, getIce = build.curIce, getCarboxyl = build.curCarboxyl, getTitanium = build.curTitanium, getGas = build.curGas })
    build.curStarCoin = 0
    build.curIce = 0
    build.curCarboxyl = 0
    build.curTitanium = 0
    build.curGas = 0
    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
end

function BuildBag:soliderLevelUp(cfgId, speedUp)
    local soliderLevel = self.soliderLevels[cfgId]
    if not soliderLevel then
        self.player:say(i18n.format("solider not exist"))
        return
    end
    if soliderLevel.level <= 0 then
        self.player:say(i18n.format("solider not unlock"))
        return
    end
    --
    if soliderLevel:getLessTick() > 0 then
        self.player:say(i18n.format("error levelup"))
        return
    end
    local nextLevel = soliderLevel.level + 1
    local nextCfg = ggclass.SoliderLevel.getSoliderCfg(soliderLevel.cfgId, nextLevel)
    if not nextCfg then
        self.player:say(i18n.format("max level"))
        return
    end
    local cfg = ggclass.SoliderLevel.getSoliderCfg(soliderLevel.cfgId, soliderLevel.level)
    if not cfg then
        self.player:say(i18n.format("error level"))
        return
    end
    local levelUpNeedBuilds = cfg.levelUpNeedBuilds or {}
    local arrive = true
    for _, info in ipairs(levelUpNeedBuilds) do
        local needCfgId = info[1]
        local needLevel = info[2]
        if self.player.buildBag:getBuildLevelByCfgId(needCfgId) < needLevel then
            arrive = false
            break
        end
    end
    if not arrive then
        self.player:say(i18n.format("less build level"))
        return
    end
    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin) then
            self.player:say(i18n.format("less StarCoin"))
            return
        end
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        if not self.player.resBag:enoughRes(constant.RES_ICE, cfg.levelUpNeedIce) then
            self.player:say(i18n.format("less Ice"))
            return
        end
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl) then
            self.player:say(i18n.format("less Carboxyl"))
            return
        end
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        if not self.player.resBag:enoughRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium) then
            self.player:say(i18n.format("less Titanium"))
            return
        end
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        if not self.player.resBag:enoughRes(constant.RES_GAS, cfg.levelUpNeedGas) then
            self.player:say(i18n.format("less Gas"))
            return
        end
    end
    local SpeedUpNeedMit = 0
    if speedUp > 0 then
        local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
        local count = math.ceil((cfg.levelUpNeedTick or 0) / 60)
        SpeedUpNeedMit = SpeedUpPerMinute * count
        if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
            self.player:say(i18n.format("less Mit"))
            return
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end

    soliderLevel:setNextTick(levelUpNeedTick * 1000)

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin)
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        self.player.resBag:costRes(constant.RES_ICE, cfg.levelUpNeedIce)
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        self.player.resBag:costRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl)
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        self.player.resBag:costRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium)
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        self.player.resBag:costRes(constant.RES_GAS, cfg.levelUpNeedGas)
    end
    if speedUp > 0 then
        self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
    end

    gg.client:send(self.player.linkobj,"S2C_Player_SoliderLevelUpdate",{ soliderLevel = soliderLevel:pack() })
end

function BuildBag:speedUpSoliderLevelUp(cfgId)
    local soliderLevel = self.soliderLevels[cfgId]
    if not soliderLevel then
        self.player:say(i18n.format("solider not exist"))
        return
    end
    --
    local lessTick = soliderLevel:getLessTick()
    if lessTick <= 0 then
        self.player:say(i18n.format("error speedUp"))
        return
    end
    local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
    local count = math.ceil(lessTick / 60)
    local SpeedUpNeedMit = SpeedUpPerMinute * count
    if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
        self.player:say(i18n.format("less Mit"))
        return
    end
    soliderLevel:setNextTick(0)
    self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
end

function BuildBag:mineLevelUp(cfgId, speedUp)
    local mineLevel = self.mineLevels[cfgId]
    if not mineLevel then
        self.player:say(i18n.format("mine not exist"))
        return
    end
    if mineLevel.level <= 0 then
        self.player:say(i18n.format("mine not unlock"))
        return
    end
    --
    if mineLevel:getLessTick() > 0 then
        self.player:say(i18n.format("error levelup"))
        return
    end
    local nextLevel = mineLevel.level + 1
    local nextCfg = ggclass.MineLevel.getMineCfg(mineLevel.cfgId, nextLevel)
    if not nextCfg then
        self.player:say(i18n.format("max level"))
        return
    end
    local cfg = ggclass.MineLevel.getMineCfg(mineLevel.cfgId, mineLevel.level)
    if not cfg then
        self.player:say(i18n.format("error level"))
        return
    end
    local levelUpNeedBuilds = cfg.levelUpNeedBuilds or {}
    local arrive = true
    for _, info in ipairs(levelUpNeedBuilds) do
        local needCfgId = info[1]
        local needLevel = info[2]
        if self.player.buildBag:getBuildLevelByCfgId(needCfgId) < needLevel then
            arrive = false
            break
        end
    end
    if not arrive then
        self.player:say(i18n.format("less build level"))
        return
    end
    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin) then
            self.player:say(i18n.format("less StarCoin"))
            return
        end
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        if not self.player.resBag:enoughRes(constant.RES_ICE, cfg.levelUpNeedIce) then
            self.player:say(i18n.format("less Ice"))
            return
        end
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl) then
            self.player:say(i18n.format("less Carboxyl"))
            return
        end
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        if not self.player.resBag:enoughRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium) then
            self.player:say(i18n.format("less Titanium"))
            return
        end
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        if not self.player.resBag:enoughRes(constant.RES_GAS, cfg.levelUpNeedGas) then
            self.player:say(i18n.format("less Gas"))
            return
        end
    end
    local SpeedUpNeedMit = 0
    if speedUp > 0 then
        local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
        local count = math.ceil((cfg.levelUpNeedTick or 0) / 60)
        SpeedUpNeedMit = SpeedUpPerMinute * count
        if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
            self.player:say(i18n.format("less Mit"))
            return
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end

    mineLevel:setNextTick(levelUpNeedTick * 1000)

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin)
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        self.player.resBag:costRes(constant.RES_ICE, cfg.levelUpNeedIce)
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        self.player.resBag:costRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl)
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        self.player.resBag:costRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium)
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        self.player.resBag:costRes(constant.RES_GAS, cfg.levelUpNeedGas)
    end
    if speedUp > 0 then
        self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
    end

    gg.client:send(self.player.linkobj,"S2C_Player_MineLevelUpdate",{ mineLevel = mineLevel:pack() })
end

function BuildBag:speedUpMineLevelUp(cfgId)
    local mineLevel = self.mineLevels[cfgId]
    if not mineLevel then
        self.player:say(i18n.format("mine not exist"))
        return
    end
    --
    local lessTick = mineLevel:getLessTick()
    if lessTick <= 0 then
        self.player:say(i18n.format("error speedUp"))
        return
    end
    local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
    local count = math.ceil(lessTick / 60)
    local SpeedUpNeedMit = SpeedUpPerMinute * count
    if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
        self.player:say(i18n.format("less Mit"))
        return
    end
    mineLevel:setNextTick(0)
    self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
end

function BuildBag:refreshAllMineLevel(notNotify)
    for _,build in pairs(self.builds) do
        if build.subType == constant.BUILD_SUBTYPE_MINE then
            local curMineLevel = self:getMineLevel(build.cfgId)
            if curMineLevel > build.level then
                build.level = curMineLevel
                if not notNotify then
                    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
                end
            end
        end
    end
end

--
function BuildBag:trainSolider(id, soliderCfgId, soliderCount)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    if build.maxTrainSpace <= 0 then
        self.player:say(i18n.format("error build"))
        return
    end
    --
    if build.soliderCfgId > 0 and build.soliderCfgId ~= soliderCfgId then
        self.player:say(i18n.format("diff solider"))
        return
    end
    --
    if build:getLessTick() > 0 then
        self.player:say(i18n.format("error levelup"))
        return
    end
    --
    if build:getLessTrainTick() > 0 then
        self.player:say(i18n.format("error training"))
        return
    end
    --
    local soliderLevel = self:getSoliderLevel(soliderCfgId)
    if soliderLevel <= 0 then
        self.player:say(i18n.format("error soliderLevel"))
        return
    end
    --
    local cfg = ggclass.SoliderLevel.getSoliderCfg(soliderCfgId, soliderLevel)
    if not cfg then
        self.player:say(i18n.format("error solider"))
        return
    end
    local trainSpace = cfg.trainSpace or 0
    local trainNeedTick = cfg.trainNeedTick or 0
    local trainNeedStarCoin = cfg.trainNeedStarCoin or 0

    local curTrainSpace = trainSpace * build.soliderCount
    local needTrainSpace = trainSpace * soliderCount
    if curTrainSpace + needTrainSpace > build.maxTrainSpace then
        self.player:say(i18n.format("less space"))
        return
    end
    --
    local needStarCoin = trainNeedStarCoin * soliderCount
    if not self.player.resBag:enoughRes(constant.RES_STARCOIN, needStarCoin) then
        self.player:say(i18n.format("less StarCoin"))
        return
    end

    --
    self.player.resBag:costRes(constant.RES_STARCOIN, needStarCoin)

    --
    build.trainCfgId = soliderCfgId
    build.trainCount = soliderCount
    local needTick = trainNeedTick * soliderCount
    build:setNextTrainTick(needTick * 1000)

    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
end

function BuildBag:speedUpTrainSolider(id)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    --
    local lessTick = build:getLessTrainTick()
    if lessTick <= 0 then
        self.player:say(i18n.format("error speedUp"))
        return
    end
    local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
    local count = math.ceil(lessTick / 60)
    local SpeedUpNeedMit = SpeedUpPerMinute * count
    if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
        self.player:say(i18n.format("less Mit"))
        return
    end
    build:setNextTrainTick(0)
    self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
end

--
function BuildBag:replaceSolider(id, soliderCfgId, soliderCount)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    if build.maxTrainSpace <= 0 then
        self.player:say(i18n.format("error build"))
        return
    end
    --
    if build.soliderCfgId <= 0 or build.soliderCfgId == soliderCfgId then
        self.player:say(i18n.format("same solider"))
        return
    end
    --
    if build:getLessTick() > 0 then
        self.player:say(i18n.format("error levelup"))
        return
    end
    --
    if build:getLessTrainTick() > 0 then
        self.player:say(i18n.format("error training"))
        return
    end
    --
    local soliderLevel = self:getSoliderLevel(soliderCfgId)
    if soliderLevel <= 0 then
        self.player:say(i18n.format("error soliderLevel"))
        return
    end
    local cfg = ggclass.SoliderLevel.getSoliderCfg(soliderCfgId, soliderLevel)
    if not cfg then
        self.player:say(i18n.format("error solider"))
        return
    end
    local trainSpace = cfg.trainSpace or 0
    local trainNeedTick = cfg.trainNeedTick or 0
    local trainNeedStarCoin = cfg.trainNeedStarCoin or 0

    local needTrainSpace = trainSpace * soliderCount
    if needTrainSpace > build.maxTrainSpace then
        self.player:say(i18n.format("less space"))
        return
    end
    --
    local needStarCoin = trainNeedStarCoin * soliderCount
    if not self.player.resBag:enoughRes(constant.RES_STARCOIN, needStarCoin) then
        self.player:say(i18n.format("less StarCoin"))
        return
    end
    --
    self.player.resBag:costRes(constant.RES_STARCOIN, needStarCoin)

    --
    build.soliderCfgId = 0
    build.soliderCount = 0
    build.trainCfgId = soliderCfgId
    build.trainCount = soliderCount
    local needTick = trainNeedTick * soliderCount
    build:setNextTrainTick(needTick * 1000)

    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
end

function BuildBag:buildMove2ItemBag(id)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end

    if self:isBuildInFighting(id) or self:isBuildInLevelUp(id) or self:isBuildInTraining(id) then
        self.player:say(i18n.format("build is in fighting or levelup or trainning"))
        return
    end

    local cfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
    if not cfg then
        self.player:say(i18n.format("config not exist"))
        return
    end

    if not cfg.itemCfgId then
        self.player:say(i18n.format("build can not move to itemBag"))
        return
    end

    if not self.player.itemBag:spaceIsEnough(1) then
        self.player:say(i18n.format("itemBag not engouh"))
        return
    end

    self:delBuild(id, {reason = "move build to itemBag"})
    local targetParam = {
        cfgId = cfg.itemCfgId,
        targetCfgId = build.cfgId,
        targetLevel = build.level,
        targetQuality = build.quality,
        skillLevel1 = 0,
        skillLevel2 = 0,
        skillLevel3 = 0,
        life = build.life,
        curLife = build.curLife,
    }
    self.player.itemBag:addItem(cfg.itemCfgId,1,targetParam,{reason = "move build to itemBag"})

end

function BuildBag:buildMoveOutItemBag(item, pos)
    assert(item, "item is not exist")
    local cfg = ggclass.Build.getBuildCfg(item.targetCfgId, item.targetQuality, item.targetLevel)
    if not cfg then
        self.player:say(i18n.format("build not exist"))
        return
    end
    local ret = self:canPutDown(nil, pos, cfg.length, cfg.width)
    if not ret then
        self.player:say(i18n.format("error pos, cannot put down"))
        return
    end
    self.player.itemBag:delItem(item.id, {reason = "move build out from itemBag"})
    self:addBuildByParam(item.targetCfgId, item.targetQuality, item.targetLevel, pos.x, pos.z, item.life, item.curLife)

    self:refreshBuildGrids()
end

--
function BuildBag:removeMess(id)
    local build = self.builds[id]
    if not build then
        self.player:say(i18n.format("no build"))
        return
    end
    if build.type ~= constant.BUILD_TYPE_MESS then
        self.player:say(i18n.format("not mess"))
        return
    end
    local cfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
    if not cfg then
        self.player:say(i18n.format("error build"))
        return
    end
    local removeNeedBuilds = cfg.removeNeedBuilds or {}
    local arrive = true
    for _, info in ipairs(removeNeedBuilds) do
        local needCfgId = info[1]
        local needLevel = info[2]
        if self.player.buildBag:getBuildLevelByCfgId(needCfgId) < needLevel then
            arrive = false
            break
        end
    end
    if not arrive then
        self.player:say(i18n.format("less level"))
        return
    end
    --
    if cfg.removeNeedStarCoin and cfg.removeNeedStarCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cfg.removeNeedStarCoin) then
            self.player:say(i18n.format("less StarCoin"))
            return
        end
    end

    --
    if cfg.removeNeedStarCoin and cfg.removeNeedStarCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cfg.removeNeedStarCoin)
    end

    local getMit = cfg.removeGitMit or 0

    --
    gg.client:send(self.player.linkobj,"S2C_Player_RemoveMess",{ id = build.id, getMit = getMit })
    self:delBuild(build.id)
    self.player.resBag:addRes(constant.RES_MIT, getMit)
end

--,,onload
function BuildBag:onload()
    --
    if not next(self.builds) then
        local naturalCfg = cfg.get("etc.cfg.natural")
        local cfg = table.chooseFromDict(naturalCfg)
        self:addBuildByParam(constant.BUILD_BASE, 1, 1, cfg.baseBuild[1], cfg.baseBuild[2], constant.DEFAULT_LIFT, constant.DEFAULT_LIFT, true)
        if cfg.extra1 then
            for _, extraCfg in pairs(cfg.extra1) do
                self:addBuildByParam(extraCfg[1], extraCfg[2], extraCfg[3], extraCfg[4], extraCfg[5], constant.DEFAULT_LIFT, constant.DEFAULT_LIFT, true)
            end
        end
        if cfg.extra2 then
            for _, extraCfg in pairs(cfg.extra2) do
                self:addBuildByParam(extraCfg[1], extraCfg[2], extraCfg[3], extraCfg[4], extraCfg[5], constant.DEFAULT_LIFT, constant.DEFAULT_LIFT, true)
            end
        end
        if cfg.extra3 then
            for _, extraCfg in pairs(cfg.extra3) do
                self:addBuildByParam(extraCfg[1], extraCfg[2], extraCfg[3], extraCfg[4], extraCfg[5], constant.DEFAULT_LIFT, constant.DEFAULT_LIFT, true)
            end
        end
        if cfg.extra4 then
            for _, extraCfg in pairs(cfg.extra4) do
                self:addBuildByParam(extraCfg[1], extraCfg[2], extraCfg[3], extraCfg[4], extraCfg[5], constant.DEFAULT_LIFT, constant.DEFAULT_LIFT, true)
            end
        end
        --
        self:addBuildByParam(constant.BUILD_LIBERATORSHIP, 1, 1, constant.BUILD_LIBERATORSHIPPOSLIST[1][1], constant.BUILD_LIBERATORSHIPPOSLIST[1][2], constant.DEFAULT_LIFT, constant.DEFAULT_LIFT, true)
    end
    self:refreshBuildGrids()
    --
    for _,build in pairs(self.builds) do
        build:makeRes(true)
    end
    self:checkBuilds(true)
    self:refreshSoliderLevel(true)
    self:refreshMineLevel(true)
    self:checkSoliderLevelsUp(true)
end

function BuildBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_BuildData",{ buildData = self:packBuild() })
    gg.client:send(self.player.linkobj,"S2C_Player_SoliderLevelData",{ soliderLevelData = self:packSoliderLevel() })
    gg.client:send(self.player.linkobj,"S2C_Player_MineLevelData",{ mineLevelData = self:packMineLevel() })
end

function BuildBag:onSecond()
    self:checkBuilds()
    self:checkSoliderLevelsUp()
    self:checkMineLevelsUp()
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

function BuildBag:checkMineLevelsUp(notNotify)
    for _,mineLevel in pairs(self.mineLevels) do
        mineLevel:checkLevelUp(notNotify)
    end
end

function BuildBag:onHalfHourUpdate()
    for _,build in pairs(self.builds) do
        build:makeRes()
    end
end

return BuildBag