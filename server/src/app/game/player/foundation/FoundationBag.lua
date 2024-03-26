local FoundationBag = class("FoundationBag")

--""
function FoundationBag:ctor(param)
    self.player = param.player
    self.attackedTick = 0         -- ""
    self.attackedFightId = 0      -- ""ID
    self.protectTick = 0          -- ""
    self.battleLog = {
        lastEnemyId = 0,
        count = 0
    }
end

function FoundationBag:serialize()
    local data = {}
    data.protectTick = self.protectTick
    data.attackedTick = self.attackedTick

    return data
end

function FoundationBag:deserialize(data)
    if not data then
        return
    end
    self.protectTick = data.protectTick or 0
    self.attackedTick = data.attackTick or 0
end

--""
function FoundationBag:isAttaced()
    if gg.isGmRobotPlayer(self.player.pid) then
        return false
    end
    return self.attackedTick > 0 and skynet.timestamp() < self.attackedTick
end

--""
function FoundationBag:isInProtect()
    if gg.isGmRobotPlayer(self.player.pid) then
        return false
    end
    if self.protectTick == 0 then
        return false
    end
    if skynet.timestamp() <= self.protectTick then
        return true
    end
    return false
end

--""
function FoundationBag:isProtectEnd()
    if self.protectTick == 0 then
        return false
    end
    if skynet.timestamp() > self.protectTick then
        return true
    end
    return false
end

--""PVP""
function FoundationBag:getNewHandProtectRatio()
    local baseLevel = self.player.buildBag:getBaseBuildLevel()
    local newHandProtectRatios = gg.dynamicCfg:get("NewHandPvpProtectRatio")
    local protectRatio = 0.0
    for k, v in pairs(newHandProtectRatios) do
        if baseLevel >= v.minBaseLevel and baseLevel <= v.maxBaseLevel then
            protectRatio = v.ratio
            break
        elseif baseLevel >= v.minBaseLevel and v.maxBaseLevel == -1 then
            protectRatio = v.ratio
            break
        end
    end
    return protectRatio
end

-- ""
function FoundationBag:getStorePlunderable(cfgId, buildProtectRatio)
    local resLowLimit = 0
    if cfgId == constant.RES_STARCOIN then
        resLowLimit =  self.player.buildBag:getStoreStarCoin() * buildProtectRatio  -- ""
    end
    if cfgId == constant.RES_ICE then
        resLowLimit =  self.player.buildBag:getStoreIce() * buildProtectRatio  -- ""
    end
    if cfgId == constant.RES_GAS then
        resLowLimit =  self.player.buildBag:getStoreGas() * buildProtectRatio  -- ""
    end
    if cfgId == constant.RES_TITANIUM then
        resLowLimit =  self.player.buildBag:getStoreTitanium() * buildProtectRatio  -- ""
    end
    local curStroe = self.player.resBag:getPlunderableRes(cfgId)     -- ""
    if curStroe - resLowLimit > 0 then
        return curStroe - resLowLimit
    end
    return 0
end

--""
function FoundationBag:getPlunderableResInfo()
    local plunderRatio = gg.getGlobalCfgFloatValue("PvpPlunderRatio", 0.1)
    local newHandProtectRatio = self:getNewHandProtectRatio()
    local buildProtectRatio = self.player.buildBag:getBuildResProtectRatio()

    --""
    local resTotalPlunderRatio =  (1-newHandProtectRatio) * plunderRatio
    --""
    local storeTotalPlunderRatio = (1-newHandProtectRatio) * plunderRatio

    local plunderInfo = {}
    plunderInfo.resStarCoin = math.floor(self:getStorePlunderable(constant.RES_STARCOIN, buildProtectRatio) * resTotalPlunderRatio)
    plunderInfo.resIce = math.floor(self:getStorePlunderable(constant.RES_ICE, buildProtectRatio) * resTotalPlunderRatio)
    plunderInfo.resCarboxyl =  0 --math.floor(self.player.resBag:getPlunderableRes(constant.RES_CARBOXYL) * resTotalPlunderRatio)
    plunderInfo.resGas = math.floor(self:getStorePlunderable(constant.RES_GAS, buildProtectRatio) * resTotalPlunderRatio)
    plunderInfo.resTitanium = math.floor(self:getStorePlunderable(constant.RES_TITANIUM, buildProtectRatio) * resTotalPlunderRatio)


    plunderInfo.storeStarCoin = math.floor(self.player.buildBag:getCurStoreStarCoin() * storeTotalPlunderRatio)
    plunderInfo.storeIce = math.floor(self.player.buildBag:getCurStoreIce() * storeTotalPlunderRatio)
    plunderInfo.storeCarboxyl = 0 --math.floor(self.player.buildBag:getCurStoreCarboxyl() * storeTotalPlunderRatio)
    plunderInfo.storeTitanium = math.floor(self.player.buildBag:getCurStoreTitanium() * storeTotalPlunderRatio)
    plunderInfo.storeGas = math.floor(self.player.buildBag:getCurStoreGas() * storeTotalPlunderRatio)

    local totalPlunderInfo = {starCoin = 0, ice=0, carboxyl=0, titanium=0, gas=0, badge = 0}
    totalPlunderInfo.starCoin = plunderInfo.resStarCoin + plunderInfo.storeStarCoin
    totalPlunderInfo.ice = plunderInfo.resIce + plunderInfo.storeIce
    totalPlunderInfo.titanium = plunderInfo.resTitanium + plunderInfo.storeTitanium
    totalPlunderInfo.gas = plunderInfo.resGas + plunderInfo.storeGas
    -- totalPlunderInfo.badge = gg.getGlobalCfgIntValue("PvpWinGainPoint", 0)
    return totalPlunderInfo, plunderInfo, storeTotalPlunderRatio
end

function FoundationBag:plunderInfo2ResInfos(plunderInfo)
    local resInfo = {}
    if plunderInfo.starCoin > 0 then
        table.insert(resInfo, {resCfgId = constant.RES_STARCOIN, count = plunderInfo.starCoin})
    end
    if plunderInfo.ice > 0 then
        table.insert(resInfo, {resCfgId = constant.RES_ICE, count = plunderInfo.ice})
    end
    if plunderInfo.carboxyl > 0 then
        table.insert(resInfo, {resCfgId = constant.RES_CARBOXYL, count = plunderInfo.carboxyl})
    end
    if plunderInfo.titanium > 0 then
        table.insert(resInfo, {resCfgId = constant.RES_TITANIUM, count = plunderInfo.titanium})
    end
    if plunderInfo.gas > 0 then
        table.insert(resInfo, {resCfgId = constant.RES_GAS, count = plunderInfo.gas})
    end
    -- if plunderInfo.badge > 0 then
    --     table.insert(resInfo, {resCfgId = constant.RES_BADGE, count = plunderInfo.badge})
    -- end
    return resInfo
end

function FoundationBag:_setBuildsLevel(builds)
    local baseBuildLv = self.player.buildBag:getBaseBuildLevel()
    for index, build in ipairs(builds) do
        if build.level > baseBuildLv then
            build.level = baseBuildLv
        end
    end
end

--""
function FoundationBag:getFoundationInfo()
    local info = {}
    info.playerId = self.player.pid
    info.playerName = self.player.name
    info.playerLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
    info.playerScore = self.player.pvpBag:getPlayerRankScore()
    info.playerHead = self.player.headIcon
    info.isOnline = self.player.onlineState == ggclass.cplayer.ONLINE_STATE_ONLINE
    info.builds = {}
    local builds = self.player.buildBag:packBuild()
    for i, v in ipairs(builds) do
        if v.pos.x ~= 0 and v.pos.z ~= 0 then
            table.insert(info.builds, v)
        end
    end
    -- self:_setBuildsLevel(info.builds)
    info.plunderInfo = self:getPlunderableResInfo()
    info.resInfo = self:plunderInfo2ResInfos(info.plunderInfo)
    info.sanctuaryValue = self.player.buildBag:getSanctuaryValue()
    return info
end

function FoundationBag:visitFoundationInfo()
    if not self.player.playerInfoBag:canVisitFoundation() then
        return
    end
    return self:getFoundationInfo()
end

--"",""
function FoundationBag:startAttacked(tick, inner, isFreeFight)
    if not inner and self:isInProtect() then
        return
    end
    if not inner and self:isAttaced() then
        return
    end
    self.player.pvpBag:setFreeBeFight(isFreeFight)
    local fightTime = gg.getGlobalCfgIntValue("FightMaxCostTime", 300) * 1000 + skynet.timestamp()
    self.attackedTick = fightTime
    local cannons = self.player.buildBag:getCannonBuilds()
    if cannons and next(cannons) then
        for _, build in pairs(cannons) do
            build:setFightTick(fightTime)
        end
    end
    return self:getFoundationInfo()
end

--"",""
function FoundationBag:unlockAttackedCannons(result)
    local costLife = gg.getGlobalCfgIntValue("PvpFailCostGunLife", 0)
    local cannons = self.player.buildBag:getCannonBuilds()
    if cannons and next(cannons) then
        for _, build in pairs(cannons) do
            if result == constant.BATTLE_RESULT_WIN then
                if costLife > 0 and build.curLife - costLife > 0 then
                    build:setCurLife(build.curLife - costLife)
                    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
                end
            end
            build:setFightTick(0)
        end
    end
end

--""
function FoundationBag:endAttacked(result, attackerPid)
    local isFreeBeFight = self.player.pvpBag:getFreeBeFight(attackerPid)
    --""
    local resInfo
    if result == constant.BATTLE_RESULT_WIN and not gg.isGmRobotPlayer(self.player.pid) then
        if not isFreeBeFight then
            local plunderInfo, plunderRatio
            resInfo, plunderInfo, plunderRatio = self:getPlunderableResInfo()
            --""
            self.player.resBag:costRes(constant.RES_STARCOIN, plunderInfo.resStarCoin, {logType=gamelog.PVP_PLUNDER})
            self.player.resBag:costRes(constant.RES_ICE, plunderInfo.resIce, {logType=gamelog.PVP_PLUNDER})
            self.player.resBag:costRes(constant.RES_CARBOXYL, plunderInfo.resCarboxyl, {logType=gamelog.PVP_PLUNDER})
            self.player.resBag:costRes(constant.RES_TITANIUM, plunderInfo.resTitanium, {logType=gamelog.PVP_PLUNDER})
            self.player.resBag:costRes(constant.RES_GAS, plunderInfo.resGas, {logType=gamelog.PVP_PLUNDER})
            -- if self.player.resBag:getRes(constant.RES_BADGE) > 0 then
            --     self.player.resBag:costRes(constant.RES_BADGE, resInfo.badge, {logType=gamelog.PVP_PLUNDER})
            -- end
            --""("")
            self.player.buildBag:plunderBuildRes(constant.RES_STARCOIN, plunderRatio)
            self.player.buildBag:plunderBuildRes(constant.RES_ICE, plunderRatio)
            self.player.buildBag:plunderBuildRes(constant.RES_CARBOXYL, 0)
            self.player.buildBag:plunderBuildRes(constant.RES_TITANIUM, plunderRatio)
            self.player.buildBag:plunderBuildRes(constant.RES_GAS, plunderRatio)

            local loseScore = gg.getGlobalCfgIntValue("PvpDefenceFailGainPoint", 0)
            self.player.pvpBag:updateMatchRankScore(loseScore)
            resInfo.defenBadge = loseScore
        else
            resInfo = {starCoin = 0, ice=0, carboxyl=0, titanium=0, gas=0, defenBadge = 0}
        end
    else
        if not isFreeBeFight then
            resInfo = {starCoin = 0, ice=0, carboxyl=0, titanium=0, gas=0, defenBadge = 0, tesseract = 0}
            if not gg.isGmRobotPlayer(self.player.pid) then
                resInfo.badge = gg.getGlobalCfgIntValue("PvpFailGainPoint", 0)
            end

            local winScore = gg.getGlobalCfgIntValue("PvpDefenceWinGainPoint", 0)
            self.player.pvpBag:updateMatchRankScore(winScore)
            resInfo.defenBadge = winScore
            local winRes = gg.getGlobalCfgTableValue("PvpDefenceWinGainRes", {})
            local resDict = {}
            for i, v in ipairs(winRes) do
                resDict[v[1]] = v[2]
                if v[1] == constant.RES_TESSERACT then
                    resInfo.tesseract = v[2]
                end
            end
            self.player.resBag:addResDict(resDict, { logType = gamelog.PVP_DEFEN_SUCC, extraId = attackerPid })
        else
            resInfo = {starCoin = 0, ice=0, carboxyl=0, titanium=0, gas=0, defenBadge = 0, tesseract = 0}
        end
    end
    self.attackedTick = 0
    self:unlockAttackedCannons(result)
    if result == constant.BATTLE_RESULT_LOSE then

    elseif result == constant.BATTLE_RESULT_WIN then
        local protectTime = gg.getGlobalCfgIntValue("FoundationBattleProtectTime", 36000)
        self.protectTick = skynet.timestamp() + protectTime*1000
        gg.shareProxy:send("setPlayerBaseInfo", self.player.pid, { protectTick = self.protectTick })
    end
    self.player.pvpBag:setFreeBeFight(false)
    return resInfo
end

--""
function FoundationBag:checkAttackedEnd()
    if self.attackedTick == 0 then
        return
    end
    if skynet.timestamp() < self.attackedTick then
        return
    end
    self.attackedTick = 0
    self:unlockAttackedCannons()
end

function FoundationBag:checkProtectEnd()
    if self.protectTick == 0 then
        return
    end
    if skynet.timestamp() < self.protectTick then
        return
    end
    self.protectTick = 0
    gg.shareProxy:send("setPlayerBaseInfo", self.player.pid, { protectTick = 0 })
end

-------------------------------------------------

--""
function FoundationBag:lookFoundation(otherPid)
    local info = gg.playerProxy:call(otherPid, "getFoundationInfo")
    return info
end

function FoundationBag:_startSelfBattle(enemyId, args)
    if not gg.isInnerServer() then
        return
    end
    -- if self.player.pvpBag:isBanBattle() then
    --     self.player:say(util.i18nFormat(errors.BATTLE_BAN))
    --     return
    -- end
    
    if enemyId ~= self.player.pid then
        self.player:say(util.i18nFormat(errors.EMEMY_ERR))
        return
    end

    -- if not self.player.pvpBag:enoughBattleNum(enemyId) then
    --     self.player:say(util.i18nFormat(errors.BATTLE_NUM_NOT_ENOUGH))
    --     return
    -- end
    local fightArmy = self.player.armyBag:getFightArmy(args.armyId)
    if not fightArmy.mainWarShip then
        self.player:say(util.i18nFormat(errors.ARMY_NO_WARSHIP))
        return
    end
    if not fightArmy.soliders then
        self.player:say(util.i18nFormat(errors.ARMY_NO_SOLIDER))
        return
    end

    if not fightArmy.heros or not next(fightArmy.heros) then
        return
    end

    local defender = gg.playerProxy:call(enemyId, "getFoundationInfo")
    if not defender then
        self.player:say(util.i18nFormat(errors.EMEMY_NO_PLAYER))
        return
    end
    -- local costCfg = ggclass.PvpBag.getPvpCost(defender.playerLevel)
    -- if not costCfg then
    --     self.player:say(util.i18nFormat(errors.BATTLE_PVP_COST_NOT_FOUND))
    --     return
    -- end

    -- local costStarCoin = costCfg.fightCost or 0
    -- if not self.player.resBag:enoughRes(constant.RES_STARCOIN, costStarCoin) then
    --     self.player:say(util.i18nFormat(errors.STARCOIN_NOT_ENOUGH))
    --     return
    -- end

    local fightTime = gg.getGlobalCfgIntValue("FightMaxCostTime", 300) * 1000 + skynet.timestamp()
    local enemyBaseInfo = gg.playerProxy:call(enemyId, "startAttacked", fightTime, true)
    if not enemyBaseInfo then
        self.player:say(util.i18nFormat(errors.BATTLE_ENEMY_BASE_BUSY))
        return
    end
    if not enemyBaseInfo.builds or not next(enemyBaseInfo.builds) then
        self.player:say(util.i18nFormat(errors.EMEMY_BUILDS_EMPTY))
        return
    end

    local attacker = {}
    attacker.playerId = self.player.pid
    attacker.playerName = self.player.name
    attacker.playerLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
    attacker.playerScore = self.player.pvpBag:getPlayerRankScore()
    attacker.playerHead = self.player.headIcon
    local enemy = {}
    enemy.playerId = defender.playerId
    enemy.playerName = defender.playerName
    enemy.playerLevel = defender.playerLevel
    enemy.playerScore = defender.playerScore
    enemy.playerHead = defender.playerHead
    enemy.sanctuaryValue = defender.sanctuaryValue

    local battleData = {
        battleType = constant.BATTLE_TYPE_MAIN_BASE,
        attacker = attacker,
        defender = enemy,
        defenderBuilds = enemyBaseInfo.builds,
        attackerArmy = fightArmy,
        bVersion = args.bVersion,
    }
    local battle = gg.battleMgr:createBattle(constant.BATTLE_TYPE_MAIN_BASE, battleData)
    gg.battleMgr:startBattle(battle.battleId)
    local attackerReport = gg.battleMgr:createFightReport(battle.battleId, {isAttacker = true})
    local defenserReport = gg.battleMgr:createFightReport(battle.battleId, {isAttacker = false})
    self.player.fightReportBag:addFightPvpReport(attackerReport)
    gg.playerProxy:send(enemyId, "addFightPvpReport", defenserReport)

    self.player.armyBag:setFightTick(fightTime)
    self.player.pvpBag:decrPlayerBattleNum(enemyId)
    return battle:serialize()
end

function FoundationBag:startBattle(enemyId, args)
    self.player.pvpBag:setFreeFight(false)
    if args.battleType == constant.BATTLE_TYPE_SELF then
        return self:_startSelfBattle(enemyId, args)
    end

    if self.player.pvpBag:isBanBattle() then
        self.player:say(util.i18nFormat(errors.BATTLE_BAN))
        return
    end
    
    if enemyId == self.player.pid then
        self.player:say(util.i18nFormat(errors.EMEMY_ERR))
        return
    end

    -- local report = self.player.fightReportBag:getReportByReportId(battleId)
    -- if report then
    --     self.player:say(util.i18nFormat(errors.BATTLE_IN_FIGHTING))
    --     return
    -- end

    -- if not self.player.pvpBag:enoughBattleNum(enemyId) then
    --     self.player:say(util.i18nFormat(errors.BATTLE_NUM_NOT_ENOUGH))
    --     return
    -- end
    local fightArmy = self.player.armyBag:getFightArmy(args.armyId, args.battleType)
    if not fightArmy.mainWarShip then
        -- self.player:say(util.i18nFormat(errors.ARMY_NO_WARSHIP))
        return
    end
    if not fightArmy.soliders then
        self.player:say(util.i18nFormat(errors.ARMY_NO_SOLIDER))
        return
    end
    if not fightArmy.heros or not next(fightArmy.heros) then
        return
    end
    local defender = gg.playerProxy:call(enemyId, "getFoundationInfo")
    if not defender then
        self.player:say(util.i18nFormat(errors.EMEMY_NO_PLAYER))
        return
    end
    local costCfg = ggclass.PvpBag.getPvpCost(defender.playerLevel)
    if not costCfg then
        self.player:say(util.i18nFormat(errors.BATTLE_PVP_COST_NOT_FOUND))
        return
    end

    local costStarCoin = costCfg.fightCost or 0
    if not self.player.resBag:enoughRes(constant.RES_STARCOIN, costStarCoin) then
        self.player:say(util.i18nFormat(errors.STARCOIN_NOT_ENOUGH))
        return
    end

    local isFreeFight = false
    if not self.player.pvpBag:enoughBattleNum(enemyId) then
        isFreeFight = true
    end
    local fightTime = gg.getGlobalCfgIntValue("FightMaxCostTime", 300) * 1000 + skynet.timestamp()
    local enemyBaseInfo = gg.playerProxy:call(enemyId, "startAttacked", fightTime, false, isFreeFight)
    if not enemyBaseInfo then
        self.player:say(util.i18nFormat(errors.BATTLE_ENEMY_BASE_BUSY))
        return
    end
    if not enemyBaseInfo.builds or not next(enemyBaseInfo.builds) then
        self.player:say(util.i18nFormat(errors.EMEMY_BUILDS_EMPTY))
        return
    end
    self.player.resBag:costRes(constant.RES_STARCOIN, costStarCoin, {logType=gamelog.PVP_START_BATTLE})

    local attacker = {}
    attacker.playerId = self.player.pid
    attacker.playerName = self.player.name
    attacker.playerLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
    attacker.playerScore = self.player.pvpBag:getPlayerRankScore()
    attacker.playerHead = self.player.headIcon
    local enemy = {}
    enemy.playerId = defender.playerId
    enemy.playerName = defender.playerName
    enemy.playerLevel = defender.playerLevel
    enemy.playerScore = defender.playerScore
    enemy.playerHead = defender.playerHead
    enemy.sanctuaryValue = defender.sanctuaryValue
    
    local battleData = {
        battleType = constant.BATTLE_TYPE_MAIN_BASE,
        attacker = attacker,
        defender = enemy,
        defenderBuilds = enemyBaseInfo.builds,
        attackerArmy = fightArmy,
        bVersion = args.bVersion,
    }
    local battle = gg.battleMgr:createBattle(constant.BATTLE_TYPE_MAIN_BASE, battleData)
    gg.battleMgr:startBattle(battle.battleId)
    local attackerReport = gg.battleMgr:createFightReport(battle.battleId, {isAttacker = true})
    local defenserReport = gg.battleMgr:createFightReport(battle.battleId, {isAttacker = false})
    self.player.fightReportBag:addFightPvpReport(attackerReport)
    gg.playerProxy:send(enemyId, "addFightPvpReport", defenserReport)

    self.player.armyBag:setFightTick(fightTime)
    if not self.player.pvpBag:enoughBattleNum(enemyId) then
        self.player.pvpBag:setFreeFight(true)
    else
        self.player.pvpBag:decrPlayerBattleNum(enemyId)
    end
    
    if self.battleLog.lastEnemyId == enemyId then
        self.battleLog.count = self.battleLog.count + 1
    else
        if self.battleLog.count >= 2 then
            logger.logf("info","PvpBattleNumLog","PlayerId=%s, enemieId=%s, battleNum=%s", self.player.pid, self.battleLog.lastEnemyId, self.battleLog.count)    
        end
        self.battleLog.lastEnemyId = enemyId
        self.battleLog.count = 1
    end
    return battle:serialize()
end

function FoundationBag:_getWarShipCostLife(result, outArgs)
    local costLife = 0
    if result == constant.BATTLE_RESULT_WIN then
        costLife = gg.getGlobalCfgIntValue("PvpWinCostWarShipLife", 0)
    elseif result == constant.BATTLE_RESULT_LOSE then
        costLife = gg.getGlobalCfgIntValue("PvpFailCostWarShipLife", 0)
    end
    if costLife == 0 then
        return
    end
    local warShip = self.player.armyBag:getFightWarShip()
    if warShip.curLife == 0 then
        return
    end
    costLife = math.min(warShip.curLife, costLife)
    table.insert(outArgs, {id = warShip.id, costLife = costLife})
end

function FoundationBag:_getHerosCostLife(result, outArgs, heroIds)
    local costLife = 0
    heroIds = heroIds or {}
    if result == constant.BATTLE_RESULT_WIN then
        costLife = gg.getGlobalCfgIntValue("PvpWinCostHeroLife", 0)
    elseif result == constant.BATTLE_RESULT_LOSE then
        costLife = gg.getGlobalCfgIntValue("PvpFailCostHeroLife", 0)
    end
    if costLife == 0 then
        return
    end
    local heros = {}
    for k,id in pairs(heroIds) do
        local heroData = self.player.heroBag:getHero(id)
        table.insert(heros,heroData)
    end
    for k, v in pairs(heros) do
        if v.curLife > 0 then
            local cost = math.min(v.curLife, costLife)
            table.insert(outArgs, {id = v.id, costLife = cost})
        end
    end
end

function FoundationBag:endBattle(battleId, battleResult)
    local report = self.player.fightReportBag:getReportByReportId(battleId)
    if not report then
        return false, constant.BATTLE_CODE_531
    end

    local result = battleResult.ret
    if result < constant.BATTLE_RESULT_LOSE or result > constant.BATTLE_RESULT_OFFLINE then
        return false, constant.BATTLE_CODE_532
    end

    local isValid, code = gg.battleMgr:checkBattleValid(battleId, battleResult)
    if not isValid then
        return false, code
    end

    local costArmyInfo = { heros = {}, warShips = {}, soliders = {}}
    local enemyId = report.enemyPlayerId
    local endInfo = gg.playerProxy:call(enemyId, "endAttacked", result, self.player.pid)
    -- local matchInfos = gg.matchProxy:getInStartMatchs(constant.MATCH_BELONG_PVP, constant.MATCH_TYPE_SEASON)
    -- if table.count(matchInfos) == 0 then
    --     endInfo.badge = 0
    -- end
    local freeFight = self.player.pvpBag:getFreeFight(enemyId)
    if result == constant.BATTLE_RESULT_WIN then --""
        if not gg.isGmRobotPlayer(enemyId) then
            if not freeFight then
                local hydroxylBase = gg.getGlobalCfgIntValue("PVPHydroxylBase", 10000)
                local hydroxylAddition = self.player.vipBag:getHydroxylAddition()
                local vipHydroxylAward = math.floor(hydroxylBase + hydroxylAddition)
                endInfo.carboxyl = vipHydroxylAward
            else
                endInfo.starCoin = 0
                endInfo.ice = 0
                endInfo.carboxyl = 0
                endInfo.titanium = 0
                endInfo.gas = 0
                endInfo.tesseract = 0
                endInfo.atkBadge = 0
            end
            
            self.player.resBag:safeAddRes(constant.RES_STARCOIN, endInfo.starCoin, {logType=gamelog.PVP_PLUNDER, extraId=enemyId})
            self.player.resBag:safeAddRes(constant.RES_ICE, endInfo.ice, {logType=gamelog.PVP_PLUNDER, extraId=enemyId})
            self.player.resBag:safeAddRes(constant.RES_CARBOXYL, endInfo.carboxyl, {logType=gamelog.PVP_PLUNDER, extraId=enemyId})
            self.player.resBag:safeAddRes(constant.RES_TITANIUM, endInfo.titanium, {logType=gamelog.PVP_PLUNDER, extraId=enemyId})
            self.player.resBag:safeAddRes(constant.RES_GAS, endInfo.gas, {logType=gamelog.PVP_PLUNDER, extraId=enemyId})
            -- self.player.resBag:safeAddRes(constant.RES_BADGE, endInfo.badge, {logType=gamelog.PVP_PLUNDER, extraId=enemyId})
            if not freeFight then
                local winScore = gg.getGlobalCfgIntValue("PvpWinGainPoint", 0)
                self.player.pvpBag:updateMatchRankScore(winScore)
                endInfo.atkBadge = winScore
            end
    
            self.player.pvpBag:updateArmyAttacked(enemyId)
        end
    elseif result == constant.BATTLE_RESULT_LOSE then --"",""
        if not gg.isGmRobotPlayer(enemyId) then
            -- self.player.resBag:safeAddRes(constant.RES_BADGE, endInfo.badge, {logType=gamelog.PVP_PLUNDER, extraId=enemyId})
            if not freeFight then
                local failScore = gg.getGlobalCfgIntValue("PvpFailGainPoint", 0)
                self.player.pvpBag:updateMatchRankScore(failScore)
                endInfo.atkBadge = failScore
            else
                endInfo.starCoin = 0
                endInfo.ice = 0
                endInfo.carboxyl = 0
                endInfo.titanium = 0
                endInfo.gas = 0
                endInfo.tesseract = 0
                endInfo.atkBadge = 0
            end
        end
    end

    if battleResult.soliders and next(battleResult.soliders) then
        for k, v in pairs(battleResult.soliders) do
            table.insert(costArmyInfo.soliders, {id=v.id, dieCount=v.dieCount, index=v.index})
        end
    end
    self:_getHerosCostLife(result, costArmyInfo.heros, battleResult.heroIds)
    self:_getWarShipCostLife(result, costArmyInfo.warShips)
    self.player.armyBag:costArmyLife(costArmyInfo)
    self.player.armyBag:setFightTick(0)

    -- ""
    report = self.player.fightReportBag:updatePvpFightReport(battleId, battleResult, endInfo)    
    -- ""
    gg.playerProxy:send(report.enemyPlayerId, "updatePvpFightReport", battleId, battleResult, endInfo)
    gg.battleMgr:endBattle(battleId, battleResult)
    self.player.taskBag:update(constant.TASK_PVP_COUNT, {count = 1})
    self.player.pvpBag:autoChangePlayers(enemyId)
    self.player.pvpBag:setFreeFight(false)
    return endInfo
end

--""
function FoundationBag:checkAttackEnd(notNotify)
    
end

function FoundationBag:checkUploadBattle(notNotify)
    
end

function FoundationBag:onSecond()
    self:checkAttackEnd()
    self:checkAttackedEnd()
    self:checkProtectEnd()
end

function FoundationBag:onload()
    self:checkAttackEnd(true)
    self:checkProtectEnd(true)
end

function FoundationBag:onlogin()
    local battleId = gg.battleMgr:getIncompleteBattle(self.player.pid, constant.BATTLE_TYPE_MAIN_BASE)
    if battleId then
        gg.client:send(self.player.linkobj,"S2C_Player_UploadBattle", {
            battleId = battleId,
        })
    end
end

function FoundationBag:onlogout()

end

return FoundationBag