local BattleMgr = class("BattleMgr")

--""game"",""mongo
function BattleMgr:ctor()
    self.battles = {}
    self.incompletes = {}
end

--""battle
function BattleMgr:onSecond()
    local now = gg.time.time()
    local clearBattleIds = {}
    for battleId, battle in pairs(self.battles) do
        if battle.clearTick <= now then
            table.insert(clearBattleIds, battleId)
        end
    end
    for k, battleId in pairs(clearBattleIds) do
        local battle = self.battles[battleId]
        if battle.dirty then
            battle:save_to_db()
        end
        self.battles[battleId] = nil
    end
end

function BattleMgr:getBattle(battleId)
    local battle = self.battles[battleId]
    if battle then
        return battle
    end
    local battleInfo = gg.mongoProxy:call("getBattleInfo", battleId)
    if not battleInfo then
        return
    end
    local className = constant.BATTLE_TYPE_CLASS[battleInfo.battleType]
    local battle = ggclass[className].new()
    battle:deserialize(battleInfo)
    self.battles[battleId] = battle
    return battle
end

function BattleMgr:createBattle(battleType, args)
    local className = constant.BATTLE_TYPE_CLASS[battleType]
    if not className then
        return
    end
    local battle = ggclass[className].new()
    assert(battle)
    self.battles[battle.battleId] = battle
    battle:initBattle(args)
    battle:save_to_db()
    return battle
end

function BattleMgr:startBattle(battleId)
    local battle = self:getBattle(battleId)
    if not battle then
        return
    end
    self.incompletes[battle.attacker.playerId] = battleId
    return battle:startBattle()
end

function BattleMgr:createFightReport(battleId, extData)
    local battle = self:getBattle(battleId)
    if not battle then
        return
    end
    return battle:createFightReport(extData)
end

function BattleMgr:checkBattleValid(battleId, battleResult)
    local battle = self:getBattle(battleId)
    if not battle then
        return false, constant.BATTLE_CODE_533
    end
    local isValid, code = battle:checkBattleValid(battleResult)
    if not isValid then
        self.incompletes[battle.attacker.playerId] = nil
    end
    return isValid, code
end

function BattleMgr:endBattle(battleId, battleResult)
    local battle = self:getBattle(battleId)
    if not battle then
        return
    end
    self.incompletes[battle.attacker.playerId] = nil
    battle:endBattle(battleResult)
    battle:save_to_db()
end

function BattleMgr:lookBattlePlayerBack(battleId)
    local battle = self.battles[battleId]
    if battle then
        return battle:serialize()
    end
    return gg.mongoProxy:call("getBattleInfo", battleId)
end

function BattleMgr:getIncompleteBattle(playerId, battleType)
    local battleId = self.incompletes[playerId]
    if not battleId then
        return
    end
    local battle = self:getBattle(battleId)
    if not battle then
        return
    end
    if battle.battleType ~= battleType then
        return
    end
    return battleId
end

function BattleMgr:execIncompleteBattle(battleId, battleResult)
    local battle = self:getBattle(battleId)
    if not battle then
        return false, constant.BATTLE_CODE_533
    end
    local ret, retInfo = battle:execIncompleteBattle(battleResult)
    return ret, retInfo
end

function BattleMgr:delTimeoutBattleData()
    local now = gg.time.time()
    local diff = now - constant.BATTLE_DATA_HOLE_TIME
    local query = {startBattleTime = {["$lt"] = diff}}
    return gg.mongoProxy:call("delMultipleBattleInfo", query)
end

return BattleMgr