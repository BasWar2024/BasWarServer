local ResPlanet = class("ResPlanet")

function ResPlanet.getResPlanetCfg(index)
    local resPlanetCfg = cfg.get("etc.cfg.resPlanet")
    return resPlanetCfg[index]
end

function ResPlanet.create(param)
    return ResPlanet.new(param)
end

--
function ResPlanet.getResPlanetMakeResTime()
    return gg.getGlobalCgfIntValue("ResPlanetMakeResTime", 1800)
end

--
function ResPlanet.getResPlanetSettleTime()
    return gg.getGlobalCgfIntValue("ResPlanetSettleTime", 86400)
end

function ResPlanet:ctor(param)
    self.resPlanetMgr = param.resPlanetMgr
    self.dirty = false
    self.savename = "res_planet"
    self.ver = param.ver or skynet.timestamp()                                     --
    self.serverId = param.id or skynet.config.id                                   --
    self.index = param.index or 0                                                  --
    self.isOpen = param.isOpen or 1                                                --
    self.x = param.x or 0
    self.z = param.z or 0
    self.holderOnline = false                                                      --
    self.quality = param.quality or 1                                              --
    self.holdPlayerName = param.holdPlayerName or ""                               --
    self.holdPlayerId = param.holdPlayerId or 0                                    --id
    self.holdPlayerLevel = param.holdPlayerLevel or 0                              --
    self.holdPlayerScore = param.holdPlayerScore or 0                              --PVP
    self.holdBeginTick = param.holdBeginTick or 0                                  --
    self.builds = {}                                                               --
    self.buildsByCfgId = {}                                                        --
    self.buildGrids = {}                                                           --
    self.holdResRatio = param.holdResRatio or {
        starRatio = 1,
        iceRatio = 1,
        carboxylRatio = 1,
        titaniumRatio = 1,
        gasRatio = 1,
    }

    --
    self.starCoin = 0                                                              --
    self.ice = 0                                                                   --
    self.carboxyl = 0                                                              --
    self.titanium = 0                                                              --
    self.gas = 0                                                                   --
    self.settleRecord = {}                                                         --
    self.makeStarCoinBuildTick = param.makeStarCoinBuildTick or 0                  --
    self.makeIceBuildTick = param.makeIceBuildTick or 0                            --
    self.makeCarboxylBuildTick =param.makeCarboxylBuildTick or 0                   --
    self.makeTitaniumBuildTick = param.makeTitaniumBuildTick or 0                  --
    self.makeGasBuildTick = param.makeGasBuildTick or 0                            --
    self.settleTick = param.settleTick or (gg.time.dayzerotime() + 86400) * 1000   --


    --
    self.fightId = 0                                                               --id
    self.attackerOnline = false                                                    --
    self.attackTick = 0                                                            --
    self.attackPlayerId = 0                                                        --Id
    self.attackPlayerName = ""                                                     --
    self.attackPlayerLevel = 0                                                     --
    self.attackPlayerScore = 0                                                     --pvp
    self.attackBaseBuild = nil                                                     --
    self.attackArmyInfo = nil                                                      --
    self.attackResRatio = nil
end

function ResPlanet:serialize()
    local data = {}
    data.ver = self.ver
    data.serverId = self.serverId
    data.index = self.index
    data.isOpen = self.isOpen
    data.x = self.x
    data.z = self.z
    data.quality = self.quality
    data.holdPlayerName = self.holdPlayerName
    data.holdPlayerId = self.holdPlayerId
    data.holdPlayerLevel = self.holdPlayerLevel
    data.holdPlayerScore = self.holdPlayerScore
    data.holdBeginTick = self.holdBeginTick
    data.holdResRatio = self.holdResRatio

    data.starCoin = self.starCoin
    data.ice = self.ice
    data.carboxyl = self.carboxyl
    data.titanium = self.titanium
    data.gas = self.gas
    data.makeStarCoinBuildTick = self.makeStarCoinBuildTick
    data.makeIceBuildTick = self.makeIceBuildTick
    data.makeCarboxylBuildTick = self.makeCarboxylBuildTick
    data.makeTitaniumBuildTick = self.makeTitaniumBuildTick
    data.makeGasBuildTick = self.makeGasBuildTick
    data.settleRecord = self.settleRecord

    data.builds = {}
    for _,build in pairs(self.builds) do
        table.insert(data.builds, build:serialize())
    end

    -- data.attackerOnline = false
    data.attackResRatio = self.attackResRatio
    data.attackArmyInfo = self.attackArmyInfo
    data.attackTick = self.attackTick
    data.attackPlayerId = self.attackPlayerId
    data.attackPlayerName = self.attackPlayerName
    data.attackPlayerLevel = self.attackPlayerLevel
    data.attackPlayerScore = self.attackPlayerScore
    if self.attackBaseBuild then
        data.attackBaseBuild = self.attackBaseBuild
    end

    return data
end

function ResPlanet:deserialize(data)
    self.ver = data.ver or skynet.timestamp()
    self.serverId = data.serverId or skynet.config.id
    self.index = data.index or 0
    self.isOpen = data.isOpen or 1
    self.x = data.x or 0
    self.z = data.z or 0
    self.holdPlayerId = data.holdPlayerId or 0
    self.holdPlayerName = data.holdPlayerName or ""
    self.holdPlayerLevel = data.holdPlayerLevel or 0
    self.holdPlayerScore = data.holdPlayerScore or 0
    self.holdBeginTick = data.holdBeginTick or 0
    self.holdResRatio = data.holdResRatio or {
        starRatio = 1,
        iceRatio = 1,
        carboxylRatio = 1,
        titaniumRatio = 1,
        gasRatio = 1,
    }

    self.starCoin = data.starCoin or 0
    self.ice = data.ice or 0
    self.carboxyl = data.carboxyl or 0
    self.titanium = data.titanium or 0
    self.gas = data.gas or 0
    self.settleRecord = data.settleRecord or {}
    self.makeStarCoinBuildTick = data.makeStarCoinBuildTick or 0
    self.makeIceBuildTick = data.makeIceBuildTick or 0
    self.makeCarboxylBuildTick = data.makeCarboxylBuildTick or 0
    self.makeTitaniumBuildTick = data.makeTitaniumBuildTick or 0
    self.makeGasBuildTick = data.makeGasBuildTick or 0
    self.settleTick = data.settleTick or (gg.time.dayzerotime() + 86400) * 1000

    self.builds = {}
    if data.builds and next(data.builds) then
        for _, buildData in ipairs(data.builds) do
            local build = self:newBuild(buildData)
            if build then
                build:deserialize(buildData)
                self.builds[build.id] = build
            end
        end
    end

    -- data.attackerOnline = false
    self.attackArmyInfo = data.attackArmyInfo
    self.attackTick = data.attackTick or 0
    self.attackPlayerId = data.attackPlayerId or 0
    self.attackPlayerName = data.attackPlayerName or ""
    self.attackPlayerLevel = data.attackPlayerLevel or 0
    self.attackPlayerScore = data.attackPlayerScore or 0
    self.attackBaseBuild = data.attackBaseBuild
    self.attackResRatio = data.attackResRatio

    self:refreshBuilds()
end

function ResPlanet:pack()
    local data = {}
    data.ver = self.ver
    data.index = self.index
    data.isOnline = self.holderOnline
    data.isAttacking = self:isPlanetAttacking()
    data.pos = { x = self.x, y = 0, z = self.z }
    data.quality = self.quality
    data.holdPlayerName = self.holdPlayerName
    data.holdPlayerId = self.holdPlayerId
    data.holdPlayerLevel = self.holdPlayerLevel
    data.holdPlayerScore = self.holdPlayerScore
    data.currencies = self:getAttackWinRes()
    data.builds = {}
    for _,build in pairs(self.builds) do
        local buildData = build:packFightData()
        table.insert(data.builds, buildData)
    end
    return data
end

function ResPlanet:sendPlayer(cmd, pid, data, ...)
    if pid <= 0 then
        return
    end
    local brief = gg.centerProxy:call("api","getBrief", pid)
    if brief then
        gg.cluster:send(brief.node, ".main", "playerexec", pid, cmd, data, ...)
    end
end

--
function ResPlanet:updateVer()
    self.ver = skynet.timestamp()
end

--
function ResPlanet:packBrief()
    local data = {}
    data.index = self.index
    data.holdPlayerId = self.holdPlayerId
    data.holdPlayerName = self.holdPlayerName
    data.currencies = self:getAttackWinRes()
    return data
end

--
function ResPlanet:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    local db = assert(gg.dbmgr:getdb(), "db is nil")
    db.res_planet:update({index=self.index}, {["$set"] = data}, true, false)
    self.dirty = false
end

function ResPlanet:newBuild(buildData)
    return ggclass.Build.create(buildData)
end

function ResPlanet:getBuild(buildId)
    return self.builds[buildId]
end

function ResPlanet:isRobotHold()
    return self.holdPlayerId == 0
end

function ResPlanet:setAttackTick(second)
    self.attackTick = skynet.timestamp() + second*1000
end

function ResPlanet:isPlanetAttacking()
    if not self.attackPlayerId then
        return false
    end
    --
    if self.attackTick <= 0 then
        return false
    end
    --,
    if skynet.timestamp() > self.attackTick then
        return false
    end
    return true
end

function ResPlanet:isPlanetOpen()
    return self.isOpen == 1
end

function ResPlanet:getSelfCfg()
    return ResPlanet.getResPlanetCfg(self.index)
end

--
function ResPlanet:isHoldBuildByCfgId(cfgId)
    return self.buildsByCfgId[cfgId]
end

--
function ResPlanet:isPlayerHold(playerId)
    return self.holdPlayerId == playerId
end

function ResPlanet:isHoldPlayerOnline()
    return self.isOnline
end

function ResPlanet:setHoldPlayerOnline(isOnline)
    if isOnline == true then
        self.holderOnline = true
    else --
        self.holderOnline = false
        --test
        self.dirty = true
        self:save_to_db()
    end
end

function ResPlanet:setAttackPlayerOnline(isOnline)
    if isOnline == false then
        self.attackerOnline = false
    end
end

--
function ResPlanet:generateBuild(cfgId, quality, level)
    local life = ggclass.Build.randomBuildLife(quality)
    local curLife = life
    local param = { cfgId = cfgId, quality = quality, level = level, life = life, curLife = curLife }
    return self:newBuild(param)
end

function ResPlanet:addBuild(build)
    self.builds[build.id] = build
    self:refreshBuilds()
    if not self:isRobotHold() then
        self:sendPlayer("resPlanetBag:onBuildAdd", self.holdPlayerId, self.index, build:packFightData())
    end
end

function ResPlanet:delBuild(build)
    self.builds[build.id] = nil
    self:refreshBuilds()
    if not self:isRobotHold() then
        self:sendPlayer("resPlanetBag:onBuildDel", self.holdPlayerId, self.index, build.id)
    end
end

function ResPlanet:updateBuild(build)
    self:refreshBuilds()
    if not self:isRobotHold() then
        self:sendPlayer("resPlanetBag:onBuildUpdate", self.holdPlayerId, self.index, build:packFightData())
    end
end


function ResPlanet:getAttackWinRes()
    local rate = gg.getGlobalCgfIntValue("AttackResPlanetWinResRate", 3000) / 10000
    local currencies = {}
    if self.starCoin > 0 then
        table.insert(currencies, {resCfgId=constant.RES_STARCOIN, count=math.floor(self.starCoin * rate)})
    end
    if self.ice > 0 then
        table.insert(currencies, {resCfgId=constant.RES_ICE, count=math.floor(self.ice * rate)})
    end
    if self.carboxyl > 0 then
        table.insert(currencies, {resCfgId=constant.RES_CARBOXYL, count=math.floor(self.carboxyl * rate)})
    end
    if self.titanium > 0 then
        table.insert(currencies, {resCfgId=constant.RES_TITANIUM, count=math.floor(self.titanium * rate)})
    end
    if self.gas > 0 then
        table.insert(currencies, {resCfgId=constant.RES_GAS, count=math.floor(self.gas * rate)})
    end
    return currencies
end

function ResPlanet:canPutDown(oldPos, newPos, length, width, cfgId)
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
function ResPlanet:moveBuild(id, pos)
    local build = self.builds[id]
    if not build then
        return false, "no this build"
    end
    local oldPos = Vector3.New(build.x, 0, build.z)
    local ret = self:canPutDown(oldPos, pos, build.length, build.width)
    if not ret then
        return false, "error pos"
    end
    build:setNewPos(pos.x, pos.z)
    self:updateBuild(build)
    return true, build:packFightData()
end

--
function ResPlanet:putBuild(build, pos)
    self.builds[build.id] = build
    build:setNewPos(pos.x, pos.z)
    self:addBuild(build)
    return build:packFightData()
end

function ResPlanet:updateMakeResRatio(pid, ratioInfo)
    if not pid or not ratioInfo then
        return
    end
    if self.holdPlayerId == pid then
        self.holdResRatio = ratioInfo
    end
    if self.attackPlayerId == pid then
        self.attackResRatio = ratioInfo
    end
end

--
function ResPlanet:makeRes()
    local cfg = self:getSelfCfg()
    if cfg.perMakeStarCoin and cfg.makeStarCoinBuild and self:isHoldBuildByCfgId(cfg.makeStarCoinBuild) and self.makeStarCoinBuildTick > 0 then
        local holdSeconds = math.ceil((skynet.timestamp() - self.makeStarCoinBuildTick)/1000)
        local cycleCount = math.floor(holdSeconds / ResPlanet.getResPlanetMakeResTime())
        if cycleCount > 0 then
            local startRatio = self.holdResRatio.startRatio
            self.starCoin = self.starCoin + cycleCount * cfg.perMakeStarCoin * startRatio
            self.makeStarCoinBuildTick = skynet.timestamp()
            self.dirty = true
        end
    end
    if cfg.makeIceBuild and cfg.perMakeIce and self:isHoldBuildByCfgId(cfg.makeIceBuild) and self.makeIceBuildTick > 0 then
        local holdSeconds = math.ceil((skynet.timestamp() - self.makeIceBuildTick)/1000)
        local cycleCount = math.floor(holdSeconds / ResPlanet.getResPlanetMakeResTime())
        if cycleCount > 0 then
            local iceRatio = self.holdResRatio.iceRatio
            self.ice = self.ice + cycleCount * cfg.perMakeIce * iceRatio
            self.makeIceBuildTick = skynet.timestamp()
            self.dirty = true
        end
    end
    if cfg.makeCarboxylBuild and cfg.perMakeCarboxyl and self:isHoldBuildByCfgId(cfg.makeCarboxylBuild) and self.makeCarboxylBuildTick > 0 then
        local holdSeconds = math.ceil((skynet.timestamp() - self.makeCarboxylBuildTick)/1000)
        local cycleCount = math.floor(holdSeconds / ResPlanet.getResPlanetMakeResTime())
        if cycleCount > 0 then
            local carboxylRatio = self.holdResRatio.carboxylRatio
            self.carboxyl = self.carboxyl + cycleCount * cfg.carboxylRatio
            self.makeCarboxylBuildTick = skynet.timestamp()
            self.dirty = true
        end
    end
    if cfg.makeTitaniumBuild and cfg.perMakeTitanium and self:isHoldBuildByCfgId(cfg.makeTitaniumBuild) and self.makeTitaniumBuildTick > 0 then
        local holdSeconds = math.ceil((skynet.timestamp() - self.makeTitaniumBuildTick)/1000)
        local cycleCount = math.floor(holdSeconds / ResPlanet.getResPlanetMakeResTime())
        if cycleCount > 0 then
            local titaniumRatio = self.holdResRatio.titaniumRatio
            self.titanium = self.titanium + cycleCount * cfg.perMakeTitanium * titaniumRatio
            self.makeTitaniumBuildTick = skynet.timestamp()
            self.dirty = true
        end
    end
    if cfg.makeGasBuild and cfg.perMakeGas and self:isHoldBuildByCfgId(cfg.makeGasBuild) and self.makeGasBuildTick > 0 then
        local holdSeconds = math.ceil((skynet.timestamp() - self.makeGasBuildTick)/1000)
        local cycleCount = math.floor(holdSeconds / ResPlanet.getResPlanetMakeResTime())
        if cycleCount > 0 then
            local gasRatio = self.holdResRatio.gasRatio
            self.gas = self.gas + cycleCount * cfg.perMakeGas * gasRatio
            self.makeGasBuildTick = skynet.timestamp()
            self.dirty = true
        end
    end
end

--
function ResPlanet:checkSettle()
    if self.settleTick <= 0 then
        return
    end
    if skynet.timestamp() < self.settleTick then
        return
    end
    local playerSettleOk = {}
    for _, log in pairs(self.settleRecord) do
        if log.playerId ~= 0 then
            playerSettleOk[log.playerId] = playerSettleOk[log.playerId] or {currencies = {}}
            if log.starCoin > 0 then
                table.insert(playerSettleOk[log.playerId].currencies, {resCfgId=constant.RES_STARCOIN, count=log.starCoin})
            end
            if log.ice > 0 then
                table.insert(playerSettleOk[log.playerId].currencies, {resCfgId=constant.RES_ICE, count=log.ice})
            end
            if log.carboxyl > 0 then
                table.insert(playerSettleOk[log.playerId].currencies, {resCfgId=constant.RES_CARBOXYL, count=log.carboxyl})
            end
            if log.titanium > 0 then
                table.insert(playerSettleOk[log.playerId].currencies, {resCfgId=constant.RES_TITANIUM, count=log.titanium})
            end
            if log.gas > 0 then
                table.insert(playerSettleOk[log.playerId].currencies, {resCfgId=constant.RES_GAS, count=log.gas})
            end
        end
    end

    --
    local cfg = self:getSelfCfg()
    self.settleTick = (gg.time.dayzerotime() + 86400) * 1000
    self.holdBeginTick = skynet.timestamp()
    self.settleRecord = {}
    if self:isHoldBuildByCfgId(cfg.makeStarCoinBuild) then
        self.makeStarCoinBuildTick = skynet.timestamp()
    end
    if self:isHoldBuildByCfgId(cfg.makeIceBuild) then
        self.makeIceBuildTick = skynet.timestamp()
    end
    if self:isHoldBuildByCfgId(cfg.makeCarboxylBuild) then
        self.makeCarboxylBuildTick = skynet.timestamp()
    end
    if self:isHoldBuildByCfgId(cfg.makeTitaniumBuild) then
        self.makeTitaniumBuildTick = skynet.timestamp()
    end
    if self:isHoldBuildByCfgId(cfg.makeGasBuild) then
        self.makeGasBuildTick = skynet.timestamp()
    end
    --
    for playerId, resData in pairs(playerSettleOk) do
        gg.resMgr:addBoatRes(playerId, resData)
        gg.resMgr:queryBoatRes(playerId)
    end
    self.dirty = true
end

--
function ResPlanet:refreshBuilds()
    self.buildGrids = {}
    self.buildsByCfgId = {}
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
        self.buildsByCfgId[build.cfgId] = self.buildsByCfgId[build.cfgId] or {}
        table.insert(self.buildsByCfgId[build.cfgId], build)
    end
end

--
function ResPlanet:canAttack()
    if self:isPlanetAttacking() then
        return false, "planet is attacked by other"
    end
    if self.isOnline then
        return false, "holder is online"
    end
    return true
end

function ResPlanet:getAttackInfo()
    local attackInfo = self:pack()
    attackInfo.fightId = self.fightId
    attackInfo.attackPlayerName = self.attackPlayerName
    attackInfo.attackPlayerId = self.attackPlayerId
    attackInfo.attackPlayerLevel = self.attackPlayerLevel
    attackInfo.attackPlayerScore = self.attackPlayerScore
    attackInfo.attackArmyInfo = self.attackArmyInfo
    return attackInfo
end

function ResPlanet:startAttack(attackPlayer, attackArmyInfo, attackBaseBuild, fightId)
    self.fightId = fightId or snowflake.uuid()
    self.attackPlayerId = attackPlayer.playerId
    self.attackPlayerName = attackPlayer.playerName
    self.attackPlayerLevel = attackPlayer.playerLevel
    self.attackPlayerScore = attackPlayer.playerScore
    self.attackArmyInfo = attackArmyInfo
    self.attackBaseBuild = attackBaseBuild
    self.attackResRatio = attackPlayer.resRatio

    local beginData = self:getAttackInfo()

    --10+430
    local resPlanetFightEndTime = gg.getGlobalCgfIntValue("ResPlanetFightEndTime", 870)
    self:setAttackTick(resPlanetFightEndTime)
    self.dirty = true
    self:save_to_db()
    -- self:sendPlayer("resPlanetBag:onAttackBegin", self.attackPlayerId, self.index, beginData)
    return beginData
end

function ResPlanet:createBoat(currencies, items)
    local data = {boatId=snowflake.uuid()}
    if currencies and next(currencies) then
        data.currencies = currencies
    end
    if items and next(items) then
        data.items = items
    end
    return data
end

function ResPlanet:endAttack(pid, result, soldiers)
    assert(self.attackPlayerId == pid)
    local endInfo
    local attackPlayerId = self.attackPlayerId
    local holdPlayerId = self.holdPlayerId
    if result == constant.FIGHT_RESULT_WIN then
        -- local leftResData = {currencies={}, items={}}
        local rebackItems = {}
        for k, v in pairs(self.builds) do --
            if v.cfgId ~= constant.BUILD_BASE then
                v.curLife = v.curLife - 1
                local cfg = ggclass.Build.getBuildCfg(v.cfgId, v.quality, v.level)
                table.insert(rebackItems, {
                    id = v.id,
                    cfgId = cfg.itemCfgId,
                    num = 1,
                    targetCfgId = v.cfgId,
                    targetLevel = v.level,
                    targetQuality = v.quality,
                    life = v.life,
                    curLife = v.curLife,
                    skillLevel1 = 0,
                    skillLevel2 = 0,
                    skillLevel3 = 0,
                    skillLevel4 = 0,
                    skillLevel5 = 0,
                })
            end
        end

        --
        local rate = (10000-gg.getGlobalCgfIntValue("AttackResPlanetWinResRate", 3000)) / 10000
        table.insert(self.settleRecord, {
            playerId = self.holdPlayerId,
            starCoin = math.floor(self.starCoin * rate),
            ice = math.floor(self.ice*rate),
            carboxyl = math.floor(self.carboxyl*rate),
            titanium = math.floor(self.titanium*rate),
            gas = math.floor(self.gas*rate),
        })
        --
        local winCurrencies = self:getAttackWinRes()

        --
        local costArmyInfo = {warShips={}, heros={}, soldiers={}}
        if soldiers then
            for k, v in pairs(soldiers) do
                table.insert(costArmyInfo.soldiers, {id=v.id, cfgId=v.cfgId, life=v.count})
            end
        end

        -- local holderReport = ggclass.FightReport.new()
        -- holderReport.fightId = self.fightId
        -- holderReport.resPlanetIndex = self.index
        -- holderReport.fightTime = self.attackTick
        -- holderReport.fightType = constant.FIGHT_RES_PLANET
        -- holderReport.playerId = self.holdPlayerId
        -- holderReport.isWin = constant.FIGHT_RESULT_LOSE
        -- holderReport.isAttacker = false
        -- holderReport.enemyPlayerId = self.attackPlayerId
        -- holderReport.enemyPlayerName = self.attackPlayerName
        -- holderReport.enemyPlayerLevel = self.enemyPlayerLevel
        -- holderReport.enemyPlayerScore = self.attackPlayerScore
        -- holderReport.loseArmyInfo = self.attackArmyInfo
        -- holderReport.currencies = winCurrencies


        -- local attackerReport = ggclass.FightReport.new()
        -- attackerReport.fightId = self.fightId
        -- attackerReport.resPlanetIndex = self.index
        -- attackerReport.fightTime = self.attackTick
        -- attackerReport.fightType = constant.FIGHT_RES_PLANET
        -- attackerReport.playerId = self.attackPlayerId
        -- attackerReport.isWin = constant.FIGHT_RESULT_WIN
        -- attackerReport.isAttacker = true
        -- attackerReport.enemyPlayerId = self.holdPlayerId
        -- attackerReport.enemyPlayerName = self.holdPlayerName
        -- attackerReport.enemyPlayerLevel = self.holdPlayerLevel
        -- attackerReport.enemyPlayerScore = self.holdPlayerScore
        -- attackerReport.loseArmyInfo = self.attackArmyInfo
        -- attackerReport.currencies = winCurrencies
        endInfo = {index=self.index,fightId=self.fightId,result=constant.FIGHT_RESULT_WIN,currencies={},soldiers=soldiers}

        --
        self.builds = {}
        self.holdPlayerId = self.attackPlayerId
        self.holdPlayerName = self.attackPlayerName
        self.holdPlayerLevel = self.attackPlayerLevel
        self.holdPlayerScore = self.attackPlayerScore
        self.holdResRatio = self.attackResRatio
        self.holdBeginTick = skynet.timestamp()
        local baseBuild = self:newBuild(self.attackBaseBuild)
        baseBuild:setNewPos(23, 23)
        table.insert(self.builds, baseBuild)

        self.starCoin = 0
        self.ice = 0
        self.carboxyl = 0
        self.titanium = 0
        self.gas = 0
        self.makeStarCoinBuildTick = 0
        self.makeIceBuildTick = 0
        self.makeCarboxylBuildTick = 0
        self.makeTitaniumBuildTick = 0
        self.makeGasBuildTick = 0

        self.fightId = 0
        self.attackTick = 0
        self.attackPlayerId = 0
        self.attackPlayerName = ""
        self.attackPlayerLevel = 0
        self.attackPlayerScore = 0
        self.attackBaseBuild = nil
        self.attackResRatio = nil

        self:refreshBuilds()
        self.dirty = true

        local attackBoat = self:createBoat(winCurrencies)
        local holderBoat = self:createBoat(nil, rebackItems)

        gg.playerProxy:call(attackPlayerId, "costPlayerArmyLife", costArmyInfo)
        gg.playerProxy:call(attackPlayerId, "addBoat", attackBoat)
        gg.playerProxy:call(holdPlayerId, "addBoat", holderBoat)

        -- gg.fightReportMgr:addFightReport(holdPlayerId, holderReport)
        -- gg.fightReportMgr:addFightReport(attackPlayerId, attackerReport)
        -- gg.resMgr:addBoatRes(attackPlayerId, {currencies = winCurrencies})
        -- gg.resMgr:addBoatRes(holdPlayerId, leftResData)
        -- gg.resMgr:queryBoatRes(attackPlayerId)
        -- gg.resMgr:queryBoatRes(holdPlayerId)
        -- self:sendPlayer("resPlanetBag:onAttackEnd", attackPlayerId, self.index, endData)
    else --

        --
        -- local holderReport = ggclass.FightReport.new()
        -- holderReport.fightId = self.fightId
        -- holderReport.resPlanetIndex = self.index
        -- holderReport.fightTime = self.attackTick
        -- holderReport.fightType = constant.FIGHT_RES_PLANET
        -- holderReport.playerId = self.holdPlayerId
        -- holderReport.isWin = constant.FIGHT_RESULT_WIN
        -- holderReport.isAttacker = false
        -- holderReport.enemyPlayerId = self.attackPlayerId
        -- holderReport.enemyPlayerName = self.attackPlayerName
        -- holderReport.enemyPlayerLevel = self.enemyPlayerLevel
        -- holderReport.enemyPlayerScore = self.attackPlayerScore
        -- holderReport.loseArmyInfo = self.attackArmyInfo
        -- holderReport.currencies = {}


        -- local attackerReport = ggclass.FightReport.new()
        -- attackerReport.fightId = self.fightId
        -- attackerReport.resPlanetIndex = self.index
        -- attackerReport.fightTime = self.attackTick
        -- attackerReport.fightType = constant.FIGHT_RES_PLANET
        -- attackerReport.playerId = self.attackPlayerId
        -- attackerReport.isWin = constant.FIGHT_RESULT_LOSE
        -- attackerReport.isAttacker = true
        -- attackerReport.enemyPlayerId = self.holdPlayerId
        -- attackerReport.enemyPlayerName = self.holdPlayerName
        -- attackerReport.enemyPlayerLevel = self.holdPlayerLevel
        -- attackerReport.enemyPlayerScore = self.holdPlayerScore
        -- attackerReport.loseArmyInfo = self.attackArmyInfo
        -- attackerReport.currencies = {}

        --
        local costArmyInfo = {warShips={}, heros={}, soldiers={}}
        if self.attackArmyInfo.warShip then
            table.insert(costArmyInfo.warShips, {id = self.attackArmyInfo.warShip.id, life = 1})
        end
        if self.attackArmyInfo.hero then
            table.insert(costArmyInfo.heros, {id=self.attackArmyInfo.hero.id, life=1})
        end
        if soldiers then
            for k, v in pairs(soldiers) do
                table.insert(costArmyInfo.soldiers, {id=v.id, cfgId=v.cfgId, life=v.count})
            end
        end

        --
        --

        self.fightId = 0
        self.attackTick = 0
        self.attackPlayerId = 0
        self.attackPlayerName = ""
        self.attackPlayerLevel = 0
        self.attackPlayerScore = 0
        self.attackBaseBuild = nil
        self.attackResRatio = nil

        -- gg.fightReportMgr:addFightReport(holdPlayerId, holderReport)
        -- gg.fightReportMgr:addFightReport(attackPlayerId, attackerReport)
        -- gg.resMgr:addCostRes(attackPlayerId, resCostData)
        -- gg.resMgr:queryPlayerCostRes(attackPlayerId)
        -- endInfo = {index=self.index,fightId=self.fightId,result=constant.FIGHT_RESULT_LOSE,currencies={},soldiers=soldiers}
        -- self:sendPlayer("resPlanetBag:onAttackEnd", attackPlayerId, self.index, endData)
        gg.playerProxy:call(attackPlayerId, "costPlayerArmyLife", costArmyInfo)
    end
    self.dirty = true
    self:save_to_db()

    return endInfo
end

--
function ResPlanet:checkAttackTimeout()
    if self.attackTick <= 0 or skynet.timestamp() < self.attackTick then
        return
    end
    local holdPlayerId = self.holdPlayerId
    local attackPlayerId = self.attackPlayerId
    --
    --
    -- local holderReport = ggclass.FightReport.new()
    -- holderReport.fightId = self.fightId
    -- holderReport.resPlanetIndex = self.index
    -- holderReport.fightTime = self.attackTick
    -- holderReport.fightType = constant.FIGHT_RES_PLANET
    -- holderReport.playerId = self.holdPlayerId
    -- holderReport.isWin = constant.FIGHT_RESULT_OFFLINE
    -- holderReport.isAttacker = false
    -- holderReport.enemyPlayerId = self.attackPlayerId
    -- holderReport.enemyPlayerName = self.attackPlayerName
    -- holderReport.enemyPlayerLevel = self.enemyPlayerLevel
    -- holderReport.enemyPlayerScore = self.attackPlayerScore
    -- holderReport.loseArmyInfo = self.attackArmyInfo
    -- holderReport.resData = {}

    -- local attackerReport = ggclass.FightReport.new()
    -- attackerReport.fightId = self.fightId
    -- attackerReport.resPlanetIndex = self.index
    -- attackerReport.fightTime = self.attackTick
    -- attackerReport.fightType = constant.FIGHT_RES_PLANET
    -- attackerReport.playerId = self.attackPlayerId
    -- attackerReport.isWin = constant.FIGHT_RESULT_OFFLINE
    -- attackerReport.isAttacker = true
    -- attackerReport.enemyPlayerId = self.holdPlayerId
    -- attackerReport.enemyPlayerName = self.holdPlayerName
    -- attackerReport.enemyPlayerLevel = self.holdPlayerLevel
    -- attackerReport.enemyPlayerScore = self.holdPlayerScore
    -- attackerReport.loseArmyInfo = self.attackArmyInfo
    -- attackerReport.resData = {}

    -- local resCostData = {warShips={}, heros={}, soldiers={}}
    -- if self.attackArmyInfo.warShip then
    --     table.insert(resCostData.warShips, {id = self.attackArmyInfo.warShip.id, life = 1})
    -- end
    -- if self.attackArmyInfo.hero then
    --     table.insert(resCostData.heros, {id=self.attackArmyInfo.hero.id, life=1})
    -- end
    -- if soldiers then
    --     for k, v in pairs(soldiers) do
    --         table.insert(resCostData.soldiers, {id=v.id, cfgId=v.cfgId, life=v.count})
    --     end
    -- end

    self.fightId = 0
    self.attackTick = 0
    self.attackPlayerId = 0
    self.attackPlayerName = ""
    self.attackPlayerLevel = 0
    self.attackPlayerScore = 0
    self.attackBaseBuild = nil
    self.attackResRatio = nil
    self.dirty = true
    self:save_to_db()
    -- gg.fightReportMgr:addFightReport(holdPlayerId, holderReport)
    -- gg.fightReportMgr:addFightReport(attackPlayerId, attackerReport)
    -- gg.resMgr:addCostRes(attackPlayerId, resCostData)
    -- gg.resMgr:queryPlayerCostRes(attackPlayerId)
    local endData = {index=self.index,fightId=self.fightId,result=constant.FIGHT_RESULT_OFFLINE,currencies={},soldiers={}}
    self:sendPlayer("resPlanetBag:onAttackEnd", attackPlayerId, self.index, endData)
end

return ResPlanet