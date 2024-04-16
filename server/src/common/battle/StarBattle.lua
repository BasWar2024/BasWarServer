local StarBattle = class("StarBattle", ggclass.BattleBase)
function StarBattle:ctor()
    StarBattle.super.ctor(self)
end

function StarBattle:initBattle(args)
    StarBattle.super.initBattle(self, args)
    self.bVersion = args.bVersion
    self.signinPosId = args.signinPosId
    self.operates = args.operates
    self.gridCfgId = args.gridCfgId
end

function StarBattle:getBattleInfo()
    local battleInfo = {}--StarBattle.super.getBattleInfo(self)
    battleInfo.enemy = self.enemy
    battleInfo.builds = self.builds
    battleInfo.traps = {}
    battleInfo.soliders = StarBattle.super.getSoliders(self.army.soliders)
    battleInfo.heros = StarBattle.super.getHeros(self.army.heros)
    battleInfo.mainShip = StarBattle.super.getMainShip(self.army.mainWarShip)
    battleInfo.skills = StarBattle.super.getMainShipSkills(self.army.mainWarShip, battleInfo.mainShip)
    battleInfo.heroSkills = StarBattle.super.getHeroSkills(self.army.heros, battleInfo.heros)

    battleInfo.skillEffects, battleInfo.buffs, battleInfo.summonSoliders =
        ggclass.BattleBase.getSkillSystem(battleInfo.builds, battleInfo.soliders, battleInfo.heros, battleInfo.skills, battleInfo.heroSkills, nil, nil, nil)

    battleInfo.battleMapInfo = StarBattle.super.getMap(self.sceneId)
    return battleInfo
end

function StarBattle:startBattle()
    local ok, result = gg.shareProxy:call("calcBattleResult", self.battleId, self.battleType, self.battleInfo, self.signinPosId, self.operates)
    if not ok then
        logger.logf("error", "StarBattle", "calcBattleResult battleId=%s, result=%s, ", tostring(self.battleId), table.dump(result or {}))
        return false, constant.BATTLE_CODE_536
    end
    self.result = result.ret
    self.endStep = result.endStep
    self.resInfo = {builds = result.builds, soliders = result.soliders}
    self.dirty = true
    return ok
end

function StarBattle:endBattle(battleResult)
end

function StarBattle:checkBattleValid(battleResult)
    return true
end

function StarBattle:_getReportArmy(fightArmy, dieSoliders)
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

function StarBattle:createFightReport(extData)
    local report = {}
    report.battleId = self.battleId
    report.battleTime = self.startBattleTime
    report.playerId = self.attacker.playerId
    report.playerName = self.attacker.playerName
    report.unionId = self.attacker.unionId
    report.unionName = self.attacker.unionName
    report.presidentName = self.attacker.presidentName
    report.unionFlag = self.attacker.unionFlag
    report.result = self.result
    report.leftHp = extData.leftHp
    report.loseHp = extData.loseHp
    local reportArmy = self:_getReportArmy(self.army, self.resInfo.soliders)
    report.warShip = reportArmy.warShip
    report.heros = reportArmy.heros
    report.soliders = reportArmy.soliders
    report.gridCfgId = extData.gridCfgId
    report.campaignId = extData.campaignId
    return report
end

return StarBattle