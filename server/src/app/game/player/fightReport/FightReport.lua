local FightReport = class("FightReport")

function FightReport:ctor()
    self.dirty = false
    self.savetick = 3600
    self.playerId = 0            --ID
    self.fightId = 0             --ID
    self.fightType = 0           --
    self.resPlanetIndex = 0      --
    self.isWin = false           --
    self.isAttacker = false      --
    self.enemyPlayerId = 0       --ID
    self.enemyPlayerName = ""    --
    self.enemyPlayerLevel = 0    --
    self.enemyPlayerScore = 0    --
    self.loseArmyInfo = nil      --
    self.currencies = {}           --
    self.fightTime = 0           --
end

function FightReport:serialize()
    local data = {}
    data.fightId = self.fightId
    data.fightType = self.fightType
    data.playerId = self.playerId
    data.isWin = self.isWin
    data.isAttacker = self.isAttacker
    data.enemyPlayerId = self.enemyPlayerId
    data.enemyPlayerName = self.enemyPlayerName
    data.enemyPlayerLevel = self.enemyPlayerLevel
    data.enemyPlayerScore = self.enemyPlayerScore
    data.loseArmyInfo = self.loseArmyInfo
    data.currencies = self.currencies
    data.fightTime = self.fightTime
    return data
end

function FightReport:deserialize(data)
    self.fightId = data.fightId or 0
    self.fightType = data.fightType or 0
    self.playerId = data.playerId or 0
    self.isWin = data.isWin or false
    self.isAttacker = data.isAttacker or false
    self.enemyPlayerId = data.enemyPlayerId or 0
    self.enemyPlayerName = data.enemyPlayerName or ""
    self.enemyPlayerLevel = data.enemyPlayerLevel or 0
    self.enemyPlayerScore = data.enemyPlayerScore or 0
    self.loseArmyInfo = data.loseArmyInfo
    self.currencies = data.currencies or {}
    self.fightTime = data.fightTime or 0
end

function FightReport:pack()
    local data = {}
    data.fightId = self.fightId
    data.fightType = self.fightType
    data.playerId = self.playerId
    data.isWin = self.isWin
    data.isAttacker = self.isAttacker
    data.enemyPlayerId = self.enemyPlayerId
    data.enemyPlayerName = self.enemyPlayerName
    data.enemyPlayerLevel = self.enemyPlayerLevel
    data.enemyPlayerScore = self.enemyPlayerScore
    data.loseArmyInfo = self.loseArmyInfo
    data.currencies = self.currencies
    return data
end

return FightReport