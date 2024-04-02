local PveBag = class("PveBag")

function PveBag:ctor(param)
    self.player = param.player
    self.pass = {}
    self.dailyRewards = {}
    self.dayPass = {}
    self.pveScore = 0
    self.resetTick = 0
end

function PveBag:serialize()
    local data = {}
    data.pveScore = self.pveScore or 0
    data.resetTick = self.resetTick
    data.pass = {}
    for k, v in pairs(self.pass) do
        data.pass[tostring(k)] = v
    end
    data.dayPass = {}
    for k, v in pairs(self.dayPass) do
        data.dayPass[tostring(k)] = v
    end
    data.dailyRewards = {}
    for k, v in pairs(self.dailyRewards) do
        data.dailyRewards[tostring(k)] = v
    end
    return data
end

function PveBag:deserialize(data)
    if not data then
        return
    end
    self.pveScore = data.pveScore or 0
    self.resetTick = data.resetTick or 0
    self.pass = {}
    for k, v in pairs(data.pass or {}) do
        self.pass[tonumber(k)] = v
    end
    for k, v in pairs(data.dayPass or {}) do
        self.dayPass[tonumber(k)] = v
    end
    self.dailyRewards = {}
    for k, v in pairs(data.dailyRewards or {}) do
        self.dailyRewards[tonumber(k)] = v
    end
end

function PveBag:pack()
    local pass = {}
    for k, v in pairs(self.pass) do
        table.insert(pass, {cfgId = k, star = v})
    end
    local dayPass = {}
    for k, v in pairs(self.dayPass) do
        table.insert(dayPass, {cfgId = k, stars = v})
    end
    local ret = {
        pass = pass,
        dayPass = dayPass,
        dailyRewards = table.keys(self.dailyRewards),
        dailyResetTick = math.floor(self.resetTick / 1000)
    }
    return ret
end

function PveBag:updateToClient()
    local pack = self:pack()
    gg.client:send(self.player.linkobj,"S2C_Player_PveInfo", pack)
end

function PveBag:_getLevelBuildId(presetLayoutId, index)
    local id = 1000000000000000000 + presetLayoutId * 1000 + index
    return id
end

function PveBag:_getLevelBuildBase(presetLayoutId, index)
    local data = {}
    data.id = self:_getLevelBuildId(presetLayoutId, index)
    data.cfgId = 0
    data.level = 0
    data.quality = 0
    data.race = 0
    data.life = 0
    data.curLife = 0
    data.pos = Vector3.New(0, 0, 0)
    data.lessTick = 0
    data.curStarCoin = 0
    data.curIce = 0
    data.curCarboxyl = 0
    data.curTitanium = 0
    data.curGas = 0
    data.soliderCfgId = 0
    data.soliderCount = 0
    data.trainCfgId = 0
    data.trainCount = 0
    data.lessTrainTick = 0
    data.chain = 0
    data.repairLessTick = 0
    return data
end

function PveBag:_getLevelBuilds(presetLayoutId)
    local buildData = {}
    if presetLayoutId then
        local presetBuilds = nil
        local pblCfg = gg.getExcelCfg("presetBuildLayout")
        for k, v in pairs(pblCfg) do
            if v.cfgId == presetLayoutId then
                presetBuilds = v.presetBuilds
                break
            end
        end
        if presetBuilds then
            local i = 0
            for _, v in pairs(presetBuilds) do
                i = i + 1
                local build = self:_getLevelBuildBase(presetLayoutId, i)
                build.cfgId = v.cfgId
                build.level = v.level
                build.quality = v.quality
                build.life = v.life
                build.curLife = v.curLife
                build.pos.x = v.x
                build.pos.z = v.z
                build.race = v.race or 0
                table.insert(buildData, build)
            end
        end
    end
    return buildData
end

function PveBag:canChallenge(enemyId)
    local cfg = gg.getExcelCfg("pve")[enemyId]
    if not cfg then
        self.player:say(util.i18nFormat(errors.EMEMY_NO_PLAYER))
        return
    end
    if not cfg.preCfgId then
        return true
    end
    if not self.pass[cfg.preCfgId] then
        return false
    end
    if self.pass[cfg.cfgId] then
        return (cfg.canRepeat and true or false)
    end
    return true
end

function PveBag:getLevelInfo(enemyId)
    local cfg = gg.getExcelCfg("pve")[enemyId]
    if not cfg then
        self.player:say(util.i18nFormat(errors.EMEMY_NO_PLAYER))
        return
    end
    local sceneId = 1
    local presetLayoutId = cfg.presetLayoutId
    if presetLayoutId then
        local pblCfg = gg.getExcelCfg("presetBuildLayout")
        if pblCfg[presetLayoutId] then
            sceneId = pblCfg[presetLayoutId].sceneId
        end
    end
    local info = {}
    info.player = {}
    info.player.playerId = cfg.cfgId
    info.player.playerName = "level"..cfg.cfgId
    info.player.playerLevel = 1
    info.player.playerScore = 0
    info.player.playerHead = ""
    info.builds = self:_getLevelBuilds(cfg.presetLayoutId)
    info.canAttack = self:canChallenge(enemyId)
    info.sceneId = sceneId
    return info
end


function PveBag:scoutFoundation(enemyId)
    local levelInfo = self:getLevelInfo(enemyId)
    if not levelInfo then
        return
    end
    local info = {}
    info.playerId = levelInfo.player.playerId
    info.playerName = levelInfo.player.playerName
    info.playerLevel = levelInfo.player.playerLevel
    info.playerScore = levelInfo.player.playerScore
    info.playerHead = levelInfo.player.playerHead
    info.builds = levelInfo.builds
    info.sceneId = levelInfo.sceneId
    local canAttack = levelInfo.canAttack
    gg.client:send(self.player.linkobj,"S2C_Player_PveScoutFoundation", { info=info, canAttack=canAttack} )
end

function PveBag:getMaxPveWin()
    local maxPve = 0
    for armyId, _ in pairs(self.pass) do
        if armyId > maxPve then
            maxPve = armyId
        end
    end
    return maxPve
end

function PveBag:getSceneId(enemyId)
    local sceneId = 1
    local cfg = gg.getExcelCfg("pve")[enemyId]
    if not cfg then
        self.player:say(util.i18nFormat(errors.EMEMY_NO_PLAYER))
        return
    end
    local presetLayoutId = cfg.presetLayoutId
    if presetLayoutId then
        local pblCfg = gg.getExcelCfg("presetBuildLayout")
        if pblCfg[presetLayoutId] then
            sceneId = pblCfg[presetLayoutId].sceneId
        end
    end
    return sceneId
end

function PveBag:startBattle(enemyId, args)
    if not self:canChallenge(enemyId) then
        self.player:say(util.i18nFormat(errors.PVE_CANT_ATTACK))
        return
    end
    local fightArmy = self.player.armyBag:getFightArmy(args.armyId)
    if not fightArmy.mainWarShip then
        -- self.player:say(util.i18nFormat(errors.ARMY_NO_WARSHIP))
        return
    end
    if not fightArmy.soliders then
        self.player:say(util.i18nFormat(errors.ARMY_NO_SOLIDER))
        return
    end
    local robotInfo = self:getLevelInfo(enemyId)
    if not robotInfo then
        return
    end
    local attacker = {}
    attacker.playerId = self.player.pid
    attacker.playerName = self.player.name
    attacker.playerLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
    attacker.playerScore = self.player.pvpBag:getPlayerRankScore()
    attacker.playerHead = self.player.headIcon
    local sceneId = self:getSceneId(enemyId)
    local battleData = {
        battleType = constant.BATTLE_TYPE_PVE,
        attacker = attacker,
        defender = robotInfo.player,
        defenderBuilds = robotInfo.builds,
        attackerArmy = fightArmy,
        bVersion = args.bVersion,
        sceneId= sceneId,
    }
    local battle = gg.battleMgr:createBattle(constant.BATTLE_TYPE_PVE, battleData)
    gg.battleMgr:startBattle(battle.battleId)
    local attackerReport = gg.battleMgr:createFightReport(battle.battleId, {isAttacker = true})
    self.player.fightReportBag:addFightPveReport(attackerReport)
    local fightTime = gg.getGlobalCfgIntValue("FightMaxCostTime", 300) * 1000 + skynet.timestamp()
    self.player.armyBag:setFightTick(fightTime)
    return battle:serialize()
end

function PveBag:_pveLog(pveLevel)
    local pveLog = {}
    pveLog.pid = self.player.pid
    pveLog.platform = self.player.platform
    pveLog.account = self.player.account
    pveLog.name = self.player.name
    pveLog.pveScore = self.pveScore
    pveLog.pveLevel = pveLevel
    pveLog.level = self.player.buildBag:getBaseBuildLevel()
    gg.internal:send(".gamelog", "api", "addPlayerPVELog", pveLog)
end

function PveBag:_mergeRewards(reward, resDict)
    for i, v in ipairs(reward or {}) do
        resDict[v[1]] = resDict[v[1]] or 0
        resDict[v[1]] = resDict[v[1]] + v[2]
    end
end

function PveBag:_doRecvRewards(resDict, logType)
    if table.count(resDict) == 0 then
        return
    end
    self.player.resBag:addResDict(resDict, {logType = logType}, false)
end

local STAR_REWARD = {
    [1] = "firstStarReward",
    [2] = "secondStarReward",
    [3] = "thirdStarReward",
}
function PveBag:_recvStarRewards(cfgId, newStar)
    local cfg = gg.getExcelCfg("pve")[cfgId]
    if not cfg then
        return
    end
    local dpTbl = self.dayPass[cfgId]
    local maxStar = 0
    for i, v in ipairs(dpTbl or {}) do
        if v > maxStar then
            maxStar = v
        end
    end
    local resDict = {}
    local oldRecvStar = self.dailyRewards[cfgId] or 0
    for i = oldRecvStar + 1, newStar, 1 do
        if i > maxStar then
            local reward = cfg[STAR_REWARD[i]]
            self:_mergeRewards(reward, resDict)
        end
    end
    self:_doRecvRewards(resDict, gamelog.PVE_DAILY_REWARD)
end

function PveBag:_recvPassRewards(cfgId)
    local cfg = gg.getExcelCfg("pve")[cfgId]
    if not cfg then
        return
    end
    local resDict = {}
    self:_mergeRewards(cfg.passReward, resDict)
    self:_doRecvRewards(resDict, gamelog.PVE_PASS_REWARD)
end

function PveBag:_getPassStar(cfgId, endStep)
    local newStar = 1
    local cfg = gg.getExcelCfg("pve")[cfgId]
    if not cfg then
        return newStar
    end
    local STAR_CFG_KEY = {
        [1] = "firstStarQuest",
        [2] = "secondStarQuest",
        [3] = "thirdStarQuest",
    }
    local BASECOND = 1
    local TIMECOND = 2
    local max
    local passSec = math.floor(endStep / 15)
    for i, key in ipairs(STAR_CFG_KEY) do
        local condCfg = cfg[key]
        if condCfg[1] == BASECOND then
            max = i
        elseif condCfg[1] == TIMECOND then
            if passSec <= condCfg[2] then
                max = i
            end
        end
    end
    newStar = max
    return newStar
end

function PveBag:_handleWin(report, result, endStep)
    if result ~= constant.BATTLE_RESULT_WIN then
        return
    end
    local firstPass = false
    local oldStar = self.pass[report.enemyPlayerId]
    local newStar = self:_getPassStar(report.enemyPlayerId, endStep)
    if not oldStar then
        firstPass = true
    end
    if firstPass then
        self:_recvPassRewards(report.enemyPlayerId)
        self.player.taskBag:update(constant.TASK_PVE_WIN, {cfgId = report.enemyPlayerId, count = 1})
        self:_pveLog(report.enemyPlayerId)
    end
    self.dayPass[report.enemyPlayerId] = self.dayPass[report.enemyPlayerId] or {}
    local diffStar = newStar - (oldStar or 0)
    if diffStar > 0 then
        self.pass[report.enemyPlayerId] = newStar
        self:_recvStarRewards(report.enemyPlayerId, newStar)
        self.dailyRewards[report.enemyPlayerId] = newStar
        table.insert(self.dayPass[report.enemyPlayerId], newStar)
        self.pveScore = self.pveScore + report.enemyPlayerId * 1
    end
    if firstPass or diffStar > 0 then
        self:updateToClient()
    end
    return {firstPass = firstPass, star = newStar, isNewStar = diffStar > 0}
end

function PveBag:endBattle(battleId, battleResult)
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
    local winRet = self:_handleWin(report, result, battleResult.endStep)

    local resInfo = {}
    resInfo.endInfo = {cfgId = report.enemyPlayerId}
    if winRet then
        resInfo.endInfo.firstPass = winRet.firstPass
        resInfo.endInfo.star = winRet.star
        resInfo.endInfo.isNewStar = winRet.isNewStar
    end
    local costArmyInfo = { heros = {}, warShips = {}, soliders = {}}
    for k, v in pairs(battleResult.soliders) do
        table.insert(costArmyInfo.soliders, {id = v.id, dieCount = v.dieCount, index = v.index})
    end

    self.player.foundationBag:_getHerosCostLife(result, costArmyInfo.heros, battleResult.heroIds)
    self.player.foundationBag:_getWarShipCostLife(result, costArmyInfo.warShips)
    self.player.armyBag:costArmyLife(costArmyInfo)
    self.player.armyBag:setFightTick(0)
    self.player.fightReportBag:updatePveFightReport(battleId, battleResult, resInfo)
    gg.battleMgr:endBattle(battleId, battleResult)
    return resInfo
end

function PveBag:receiveDailyRewards(cfgId)
    local resDict = {}
    local recvCfgIds = {}
    for k, v in pairs(self.pass) do
        if not self.dailyRewards[k] then
            self:_recvStarRewards(k, v)
            recvCfgIds[k] = v
        end
    end
    for k, v in pairs(recvCfgIds) do
        self.dailyRewards[k] = v
    end
    self:updateToClient()
end

function PveBag:resetData()
    self.resetTick = (gg.time.dayzerotime() + 86400) * 1000
    self.dailyRewards = {}
    self.dayPass = {}
    self:updateToClient()
end

function PveBag:checkResetData()
    if skynet.timestamp() <= self.resetTick then
        return
    end
    self:resetData()
end

function PveBag:onSecond()
    self:checkResetData()
end


function PveBag:onload()
end

function PveBag:oncreate()
    self.resetTick = (gg.time.dayzerotime() + 86400) * 1000
end

function PveBag:onreset()
    self.pass = {}
    self.dailyRewards = {}
    self.dayPass = {}
    self.pveScore = 0
end

function PveBag:onlogin()
    self:updateToClient()
    local battleId = gg.battleMgr:getIncompleteBattle(self.player.pid, constant.BATTLE_TYPE_PVE)
    if battleId then
        gg.client:send(self.player.linkobj,"S2C_Player_UploadBattle", {
            battleId = battleId,
        })
    end
end

function PveBag:onlogout()

end


return PveBag