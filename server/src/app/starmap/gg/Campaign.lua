local queue = require "skynet.queue"
local Campaign = class("Campaign")

function Campaign:ctor()
    self.dirty = false
    self.lock = queue()
    self.campaignId = snowflake.uuid()
    self.startTime = os.time()
    self.gridCfgId = nil
    self.defender = nil
    self.builds = nil
    self.campaignEndTick = 0
    self.battleQueue = {}
    self.reports = {}
    self.joinPids = {}
    self.joinUnionIds = {}
    self.attackContriDegree = {}
    self.attackerStatistics = {}
    self.isEnd = false
    self.maxHp = 0
    self.maxLoseHp = 0
end

function Campaign:init(gridCfgId, defender, builds)
    self.gridCfgId = gridCfgId
    self.defender = defender
    self.builds = {}
    local buildList = ggclass.BattleBase.getBuilds(builds)
    if buildList and next(buildList) then
        for k, v in pairs(buildList) do
            v.isMain = 0
            table.insert(self.builds, v)
            self.maxHp = self.maxHp + v.maxHp
        end
    end
    local campaignTime = gg.getGlobalCfgIntValue("LeagueBattleTime", 3600)
    local gridCfg = gg.getExcelCfg("starmapConfig")[gridCfgId]
    if gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF then
        campaignTime = gg.getGlobalCfgIntValue("LeaguePersonBattleTime", 3600)
    end
    self.campaignEndTick = skynet.timestamp() + campaignTime * 1000
    gg.starmap:onCampaignBegin(self.gridCfgId, self.defender)
end

function Campaign:serialize()
    local data = {}
    data.gridCfgId = self.gridCfgId
    data.campaignId = self.campaignId
    data.defender = self.defender
    data.startTime = self.startTime
    data.campaignEndTick = self.campaignEndTick
    data.builds = self.builds
    data.battleQueue = self.battleQueue
    data.reports = self.reports
    data.isEnd = self.isEnd
    data.joinPids = {}
    for k, v in pairs(self.joinPids) do
        data.joinPids[tostring(k)] = v
    end
    data.joinUnionIds = {}
    for k, v in pairs(self.joinUnionIds) do
        table.insert(data.joinUnionIds, k)
    end
    data.attackContriDegree = {}
    for k, v in pairs(self.attackContriDegree) do
        data.attackContriDegree[tostring(k)] = v
    end
    data.attackerStatistics = {}
    for k, v in pairs(self.attackerStatistics) do
        data.attackerStatistics[tostring(k)] = v
    end

    data.maxHp = self.maxHp
    data.maxLoseHp = self.maxLoseHp
    return data
end

function Campaign:deserialize(data)
    self.campaignId = data.campaignId
    self.gridCfgId = data.gridCfgId
    self.defender = data.defender
    self.startTime = data.startTime
    self.campaignEndTick = data.campaignEndTick
    self.builds = data.builds
    self.battleQueue = data.battleQueue
    self.reports = data.reports
    self.isEnd = data.isEnd
    self.joinPids = {}
    if data.joinPids and next(data.joinPids) then
        for k, v in pairs(data.joinPids) do
            self.joinPids[tonumber(k)] = v
        end
    end
    self.joinUnionIds = {}
    if data.joinUnionIds and next(data.joinUnionIds) then
        for k, v in ipairs(data.joinUnionIds) do
            self.joinUnionIds[k] = true
        end
    end
    for k, v in pairs(data.attackContriDegree or {}) do
        self.attackContriDegree[tonumber(k)] = v
    end
    for k, v in pairs(data.attackerStatistics or {}) do
        self.attackerStatistics[tonumber(k)] = v
    end
    self.maxHp = data.maxHp
    self.maxLoseHp = data.maxLoseHp
end

function Campaign:save_to_db()
    if not self.dirty then
        return
    end
    self.dirty = false
    gg.mongoProxy:send("setCampaignInfo", self.campaignId, self:serialize())
end

function Campaign:startBattle(attacker, armyType, armys, bVersion, signinPosId, operates, armyInfos, vipLevel)
    if skynet.timestamp() >= self.campaignEndTick then
        gg.centerProxy:playerSay(attacker.playerId, util.i18nFormat(errors.CAMPAIGN_TIMEOUT))
        return
    end

    local fightArmys = {}
    for k, v in pairs(armyInfos) do
        table.insert(fightArmys, v)
    end
    local battleTick = skynet.timestamp()
    for _, army in pairs(fightArmys) do
        local info = {}
        info.armyType = armyType
        info.battleTick = battleTick
        info.attacker = attacker
        info.fightArmy = army
        info.signinPosId = signinPosId
        info.operates = operates
        info.bVersion = bVersion or "1"
        info.battleNum = #fightArmys
        info.vipLevel = vipLevel
        table.insert(self.battleQueue, info)
        battleTick = battleTick + gg.getGlobalCfgIntValue("CampaignBattleInterval", 0) * 1000
    end
    table.sort(self.battleQueue, function(a, b)
        return a.battleTick < b.battleTick
    end)
    self.dirty = true
    self.joinPids[attacker.playerId] = attacker.unionId
    if not self.joinUnionIds[attacker.unionId] then
        self.joinUnionIds[attacker.unionId] = true
    end
    gg.starmap:onJoinCampaign(self.gridCfgId, attacker.playerId)
    gg.unionProxy:send("onJoinCampaign", attacker.unionId, attacker.playerId, self.campaignId)
end

function Campaign:addAttackContriDegree(attacker, diffHp)
    local gridCfg = gg.getExcelCfg("starmapConfig")[self.gridCfgId]
    if gridCfg then
        if gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION and self.maxHp > 0 then
            -- "" / ""
            local combatFactor = gg.getGlobalCfgIntValue("DamageToPerConquest", 1)
            combatFactor = math.max(combatFactor, 1)
            -- local addVal = diffHp / self.maxHp * gridCfg.occupyContribute
            local addVal = diffHp / combatFactor
            self.attackContriDegree[attacker.playerId] = (self.attackContriDegree[attacker.playerId] or 0) + addVal
        end
    end
end

function Campaign:updateBuilds(builds, attacker)
    local diffHp = 0
    if table.count(builds or {}) == 0 then
        return diffHp
    end

    local newBuilds = {}
    for i, v in ipairs(self.builds) do
        for kk, vv in pairs(builds) do
            if vv.id == v.id then
                diffHp = diffHp + (v.hp - vv.hp)
                if vv.hp > 0 then
                    v.hp = vv.hp
                    table.insert(newBuilds, v)
                else
                    --do nothing
                end
            end
        end
    end
    self.builds = newBuilds
    self:addAttackContriDegree(attacker, diffHp)

    return diffHp
end

function Campaign:getLeftSoliders(fightSoliders, dieSoliders)
    local leftSoliders = {}
    for i, v in ipairs(fightSoliders) do
        for kk, vv in pairs(dieSoliders) do
            if v.id == vv.id then
                v.count = v.count - vv.dieCount
            end
        end
        leftSoliders[v.id] = v
    end
    return leftSoliders
end

function Campaign:getBuildsLeftHp()
    local leftHp = 0
    for i, v in ipairs(self.builds) do
        leftHp = leftHp + v.hp
    end
    return leftHp
end

function Campaign:getReportArmy(fightArmy, dieSoliders)
    local formatArmy = {}
    formatArmy.warShip = {
        id = fightArmy.mainWarShip.id,
        cfgId = fightArmy.mainWarShip.cfgId,
        quality = fightArmy.mainWarShip.quality,
        level = fightArmy.mainWarShip.level,
    }
    formatArmy.heros = {}
    for i, v in ipairs(fightArmy.heros) do
        table.insert(formatArmy.heros, {
            id = v.id,
            cfgId = v.cfgId,
            quality = v.quality,
            level = v.level,
            index = v.index,
        })
    end
    formatArmy.soliders = {}
    for i, v in ipairs(fightArmy.soliders) do
        local sd = {
            id = v.id,
            cfgId = v.cfgId,
            count = v.count,
            level = v.level,
            dieCount = 0,
            index = v.index,
        }
        for kk, vv in pairs(dieSoliders) do
            if v.id == vv.id then
                sd.dieCount = vv.dieCount
            end
        end
        table.insert(formatArmy.soliders, sd)
    end
    return formatArmy
end

function Campaign:createReport(battleDetail, attacker, fightArmy, dieSoliders)
    local report = {}
    report.battleId = battleDetail.battleId
    report.battleTime = battleDetail.startBattleTime
    report.playerId = attacker.playerId
    report.playerName = attacker.playerName
    report.unionId = attacker.unionId
    report.unionName = attacker.unionName
    report.presidentName = attacker.presidentName
    report.unionFlag = attacker.unionFlag
    report.result = battleDetail.result
    report.leftHp = self:getBuildsLeftHp()
    local reportArmy = self:getReportArmy(fightArmy, dieSoliders)
    report.warShip = reportArmy.warShip
    report.heros = reportArmy.heros
    report.soliders = reportArmy.soliders
    report.gridCfgId = self.gridCfgId
    report.campaignId = self.campaignId
    return report
end

function Campaign:_warShipCostLife(result, warShip)
    if not warShip then
        return
    end
    local costLife = 0
    if result == constant.BATTLE_RESULT_WIN then
        costLife = gg.getGlobalCfgIntValue("LeagueWinCostWarshipLife", 0)
    elseif result == constant.BATTLE_RESULT_LOSE then
        costLife = gg.getGlobalCfgIntValue("LeagueFailCostWarshipLife", 0)
    end
    if costLife == 0 then
        return
    end
    if warShip.curLife == 0 then
        return
    end
    warShip.curLife = warShip.curLife - costLife
    if warShip.curLife < 0 then
        warShip.curLife = 0
    end
end

function Campaign:_herosCostLife(result, heros)
    if not heros then
        return
    end
    local costLife = 0
    if result == constant.BATTLE_RESULT_WIN then
        costLife = gg.getGlobalCfgIntValue("LeagueWinCostHeroLife", 0)
    elseif result == constant.BATTLE_RESULT_LOSE then
        costLife = gg.getGlobalCfgIntValue("LeagueFailCostHeroLife", 0)
    end
    if costLife == 0 then
        return
    end
    for k, v in pairs(heros) do
        if v.curLife > 0 then
            local cost = math.min(v.curLife, costLife)
            v.curLife = v.curLife - cost
        end
    end
end

function Campaign:getSceneId(gridCfgId)
    local sceneId = 1
    -- local cfg = gg.shareProxy:call("getRedisStarMapCfg", gridCfgId)
    local cfg = gg.getExcelCfg("starmapConfig")[gridCfgId]
    if not cfg then
        return sceneId
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

function Campaign:doBattle(attacker, armyType, fightArmy, bVersion, signinPosId, operates, battleNum, statistics, vipLevel)
    if self.isEnd then --""
        return
    end
    local sceneId = self:getSceneId(self.gridCfgId)
    local cpyBuilds = gg.deepcopy(self.builds)
    local cpyEnemyInfo = gg.deepcopy(self.defender)
    local battleData = {
        battleType = constant.BATTLE_TYPE_STAR,
        attacker = attacker,
        defender = cpyEnemyInfo,
        defenderBuilds = cpyBuilds,
        attackerArmy = fightArmy,
        bVersion = bVersion,
        signinPosId = signinPosId,
        operates = operates,
        sceneId  = sceneId,
        gridCfgId  = self.gridCfgId,
    }
    local battle = gg.battleMgr:createBattle(constant.BATTLE_TYPE_STAR, battleData)
    local ok, code = gg.battleMgr:startBattle(battle.battleId)
    if not ok then
        gg.playerProxy:send(attacker.playerId, "onGridCampaignBattleErr", {battleId = battle.battleId,code = code})
        if armyType == constant.BATTLE_ARMY_TYPE_UNION then
            gg.unionProxy:send("returnBackCampaignArmy", attacker.unionId, attacker.playerId, fightArmy)
        elseif armyType == constant.BATTLE_ARMY_TYPE_SELF then
            --gg.playerProxy:send(attacker.playerId, "returnBackCampaignArmy", attacker.playerId, fightArmy)
        end
        return
    end
    local builds = battle.resInfo.builds
    local dieSoliders = battle.resInfo.soliders

    statistics[attacker.playerId] = statistics[attacker.playerId] or {}
    if armyType == constant.BATTLE_ARMY_TYPE_UNION then
        for index,soliders in pairs(dieSoliders) do
            statistics[attacker.playerId].reserveCount = (statistics[attacker.playerId].reserveCount or 0) + soliders.dieCount
        end
    elseif armyType == constant.BATTLE_ARMY_TYPE_SELF then
        for index,soliders in pairs(dieSoliders) do
            local soliderCfgs = gg.getExcelCfgByFormat("soliderConfig", soliders.cfgId, 0)
            local soliderSpace = soliderCfgs.trainSpace
            statistics[attacker.playerId].reserveCount = (statistics[attacker.playerId].reserveCount or 0) + soliderSpace * soliders.dieCount
        end
    end
    

    local battleDetail = battle:serialize()
    self.dirty = true
    local loseHp = self:updateBuilds(builds, attacker)
    if loseHp > self.maxLoseHp then
        self.maxLoseHp = loseHp
    end
    self:_addAttackerAtkHp(attacker, loseHp)

    local leftSoliders = self:getLeftSoliders(fightArmy.soliders, dieSoliders)
    self:_warShipCostLife(battleDetail.result, fightArmy.mainWarShip)
    self:_herosCostLife(battleDetail.result, fightArmy.heros)
    if armyType == constant.BATTLE_ARMY_TYPE_SELF then 
        gg.playerProxy:send(attacker.playerId, "starmapCampaignCostArmyLife", fightArmy, dieSoliders)
    elseif armyType == constant.BATTLE_ARMY_TYPE_UNION then
        gg.unionProxy:send("starmapCampaignCostArmyLife", attacker.unionId, attacker.playerId, fightArmy, leftSoliders)
    end

    -- local report = self:createReport(battleDetail, attacker, fightArmy, dieSoliders)
    local extData = {
        leftHp = self:getBuildsLeftHp(),
        loseHp = loseHp,
        gridCfgId = self.gridCfgId,
        campaignId = self.campaignId,
    }
    local report = gg.battleMgr:createFightReport(battle.battleId, extData)
    table.insert(self.reports, report)
    self:endBattle(battleDetail.result, attacker, battleDetail.battleId, report, armyType, statistics, battleNum, vipLevel)
end

function Campaign:_initAttackerStatistics(attacker)
    if self.attackerStatistics[attacker.playerId] then
        return
    end
    self.attackerStatistics[attacker.playerId] = {
        playerName = attacker.playerName,
        atkCnt = 0,
        atkHp = 0,
    }
end

function Campaign:_addAttackerAtkCnt(attacker, val)
    self:_initAttackerStatistics(attacker)
    self.attackerStatistics[attacker.playerId]["atkCnt"] = (self.attackerStatistics[attacker.playerId]["atkCnt"] or 0) + val
end

function Campaign:_addAttackerAtkHp(attacker, val)
    self:_initAttackerStatistics(attacker)
    self.attackerStatistics[attacker.playerId]["atkHp"] = (self.attackerStatistics[attacker.playerId]["atkHp"] or 0) + val
end

function Campaign:_getRemainBuilds()
    local remainBuilds = {}
    for i, v in ipairs(self.builds) do
        table.insert(remainBuilds, v.id)
    end
    return remainBuilds
end

function Campaign:endBattle(battleResult, attacker, battleId, report, armyType, statistics, battleNum, vipLevel)
    if attacker then
        statistics[attacker.playerId].battleNum = (statistics[attacker.playerId].battleNum or 0) + 1
        statistics[attacker.playerId].battleResult = battleResult
        self:_addAttackerAtkCnt(attacker, 1)
    end
    
    if battleId then
        gg.battleMgr:endBattle(battleId, battleResult)
        gg.starmap:endBattle(attacker.playerId, self.gridCfgId, battleResult)
    end
    if battleResult == constant.BATTLE_RESULT_WIN then
        self:pushCampaignReport(attacker, battleId, report, armyType)
        self.isEnd = true
        self.campaignEndTick = skynet.timestamp()
        self:cancelBattle(attacker)
        local remainBuilds = self:_getRemainBuilds()
        gg.starmap:onCampaignEnd(self.gridCfgId, battleResult, attacker, armyType, remainBuilds, self.joinPids, self.attackContriDegree, vipLevel)

        -- ""
        local data = {
            battleTotal = statistics[attacker.playerId].battleNum,
            reserveTotal = statistics[attacker.playerId].reserveCount,
            battleResult = battleResult,
            gridCfgId = self.gridCfgId
        }
        statistics[attacker.playerId] = nil
        gg.playerProxy:send(attacker.playerId, "unionSelfBattleResult", data)
    elseif battleResult == constant.BATTLE_RESULT_LOSE then
        self:pushCampaignReport(attacker, battleId, report, armyType)
        -- ""
        if statistics[attacker.playerId].battleNum == battleNum then
            local data = {
                battleTotal = statistics[attacker.playerId].battleNum,
                reserveTotal = statistics[attacker.playerId].reserveCount,
                battleResult = battleResult,
                gridCfgId = self.gridCfgId
            }
            statistics[attacker.playerId] = nil
            gg.playerProxy:send(attacker.playerId, "unionSelfBattleResult", data)
        end
        
    elseif battleResult == constant.BATTLE_RESULT_UNKNOW then
        self:pushCampaignReport(attacker, battleId, report, armyType)
        self.isEnd = true
        self.campaignEndTick = skynet.timestamp()
        self.dirty = true
        self:cancelBattle(attacker)
        local remainBuilds = self:_getRemainBuilds()
        gg.starmap:onCampaignEnd(self.gridCfgId, battleResult, nil, nil, remainBuilds)
    end
    if attacker then
        gg.playerProxy:send(attacker.playerId, "taskStarmapAtt", {})
    end
end

function Campaign:_getFightNftIds(report)
    local fightNftIds = {}
    table.insert(fightNftIds, report.warShip.id)
    for i, v in ipairs(report.heros) do
        table.insert(fightNftIds, v.id)
    end
    return fightNftIds
end

function Campaign:pushCampaignReport(attacker, battleId, report, armyType)
    if not report then
        return
    end
    local gridCfg = gg.getExcelCfg("starmapConfig")[self.gridCfgId]
    local fightNftIds = self:_getFightNftIds(report)
    for pid, unionId in pairs(self.joinPids) do
        if gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF then
            if attacker then
                if pid == attacker.playerId then
                    gg.playerProxy:send(pid, "addStarmapReport", battleId, self.campaignId)
                end
            else
                gg.playerProxy:send(pid, "addStarmapReport", battleId, self.campaignId)
            end
            if self.defender.playerId ~= 0 then
                gg.playerProxy:send(self.defender.playerId, "addStarmapReport", battleId, self.campaignId)
            end
        elseif gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION then
            gg.unionProxy:send("onUnionCampaignUpdate", unionId, pid, battleId, self.campaignId, fightNftIds)
            if self.defender.unionId ~= 0 then
                gg.unionProxy:send("onUnionCampaignUpdate", self.defender.unionId, pid, battleId, self.campaignId, {})
            end
        end
    end
end

function Campaign:cancelBattle(winner)
    if not self.isEnd then
        return
    end
    local pushData = {}
    for i, info in ipairs(self.battleQueue) do
        pushData[info.attacker.playerId] = {
            gridCfgId = self.gridCfgId,
            campaignId = self.campaignId,
            armyType = info.armyType,
        }
        if info.armyType == constant.BATTLE_ARMY_TYPE_UNION then
            gg.unionProxy:send("returnBackCampaignArmy", info.attacker.unionId, info.attacker.playerId, info.fightArmy)
        elseif info.armyType == constant.BATTLE_ARMY_TYPE_SELF then
            --gg.playerProxy:send(info.attacker.playerId, "returnBackCampaignArmy", info.attacker.playerId, info.fightArmy)
        end
    end
    self.dirty = true
    self.battleQueue = {}
    -- for pid, v in pairs(pushData) do
    --     -- gg.playerProxy:send(pid, "onGridCampaignBattleCancel", v)
    --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.CAMPAIGN_BATTLE_CANCEL))
    -- end
end

function Campaign:packCampaignReport(report)
    local campaignReport = {}
    campaignReport.gridCfgId = self.gridCfgId
    campaignReport.campaignId = self.campaignId
    campaignReport.startTime = self.startTime
    campaignReport.reports = {report}
    campaignReport.defender = self.defender
    return campaignReport
end

function Campaign:checkBattleStart()
    if self.isEnd then
        return
    end
    if skynet.timestamp() > self.campaignEndTick then --""
        self:endBattle(constant.BATTLE_RESULT_UNKNOW, nil, nil, nil, nil)
        return
    end
    if not next(self.battleQueue) then
        return
    end
    local count = #self.battleQueue
    local statistics = {}
    for i=1, count do
        local info = table.remove(self.battleQueue, 1)
        if not info then
            break
        end
        if skynet.timestamp() > info.battleTick then
            self.lock(self.doBattle, self, info.attacker, info.armyType, info.fightArmy, info.bVersion, info.signinPosId, info.operates, info.battleNum, statistics, info.vipLevel)
        else
            table.insert(self.battleQueue, 1, info)
            break
        end
    end
end

function Campaign:onSecond()
    self:checkBattleStart()
end

function Campaign:shutdown()
    self.dirty = true
    self:save_to_db()
end

function Campaign:onFiveMinuteUpdate()
    self:save_to_db()
end

return Campaign