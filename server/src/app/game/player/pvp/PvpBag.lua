local PvpBag = class("PvpBag")

function PvpBag.getPvpCost(level)
    if not level then
        return
    end
    local pvpCostCfg = cfg.get("etc.cfg.pvpCost")
    if not pvpCostCfg then
        return
    end
    return pvpCostCfg[level]
end

function PvpBag:ctor(param)
    self.player = param.player
    self.index = 1                                            -- ""
    self.armyPlayers = {}                                     -- ""
    self.armyPlayerList = {}
    self.refreshCount = 0     -- ""
    self.refreshTotal = constant.PVP_PLAYER_REFRESH_TOTAL     -- ""
    self.battleNum = constant.PVP_PLAYER_BATTLE_TOTAL         -- ""
    self.battleNumPurchased = 0
    self.banBattleTick = 0                                    -- ""
    self.banBattleCount = 0                                   -- ""
    self.resetTick = 0                                        -- ""("")
    self.scoreBoundary = 10                                   --""
    self.freeFight = false                                   --""
    self.freeBeFight = false                                   --""

    self.pveWinIds = {}
    self.pveScore = 0
    self.matchRecords = {}
    self.rewardsTips = {}

    self.copyPlayerList = {}
    self.copyPlayers = {}
end

function PvpBag:serialize()
    local data = {}
    data.index = self.index
    data.refreshCount = self.refreshCount
    data.refreshTotal = self.refreshTotal
    data.battleNum = self.battleNum
    data.battleNumPurchased = self.battleNumPurchased
    data.resetTick = self.resetTick
    data.banBattleTick = self.banBattleTick
    data.banBattleCount = self.banBattleCount
    data.armyPlayers = {}
    if self.armyPlayers and next(self.armyPlayers) then
        for k, v in pairs(self.armyPlayers) do
            table.insert(data.armyPlayers, v)
        end
    end
    data.pveScore = self.pveScore or 0
    data.pveWinIds = {}
    if self.pveWinIds and next(self.pveWinIds) then
        for k, v in pairs(self.pveWinIds) do
            table.insert(data.pveWinIds, k)
        end
    end

    data.matchRecords = {}
    if self.matchRecords and next(self.matchRecords) then
        for i, v in ipairs(self.matchRecords) do
            local reward = {}
            for resid, count in pairs(v.reward) do
                reward[tostring(resid)] = count
            end
            table.insert(data.matchRecords, {
                rankTime = v.rankTime,
                season = v.season,
                score = v.score,
                rank = v.rank,
                reward = reward,
            })
        end
    end

    data.rewardsTips = {}
    for i, v in ipairs(self.rewardsTips) do
        local reward = {}
        for resid, count in pairs(v) do
            reward[tostring(resid)] = count
        end
        table.insert(data.rewardsTips, reward)
    end
    return data
end

function PvpBag:deserialize(data)
    if not data then
        return
    end
    self.index = data.index or 1
    self.refreshCount = data.refreshCount or constant.PVP_PLAYER_REFRESH_TOTAL
    self.refreshTotal = data.refreshTotal or constant.PVP_PLAYER_REFRESH_TOTAL
    self.battleNum = data.battleNum or constant.PVP_PLAYER_BATTLE_TOTAL
    self.battleNumPurchased = data.battleNumPurchased or 0
    self.banBattleTick = data.banBattleTick or 0
    self.banBattleCount = data.banBattleCount or 0
    self.resetTick = data.resetTick or 0
    self.armyPlayers = {}
    self.armyPlayerList = {}
    if data.armyPlayers and next(data.armyPlayers) then
        for k, v in pairs(data.armyPlayers) do
            self.armyPlayers[v.playerId] = v
            table.insert(self.armyPlayerList, v.playerId)
        end
    end

    self.pveScore = data.pveScore or 0
    self.pveWinIds = {}
    if data.pveWinIds and next(data.pveWinIds) then
        for k, v in pairs(data.pveWinIds) do
            self.pveWinIds[v] = true
        end
    end

    self.matchRecords = {}
    if data.matchRecords and next(data.matchRecords) then
        for i, v in ipairs(data.matchRecords) do
            local reward = {}
            for resid, count in pairs(v.reward) do
                reward[tonumber(resid)] = count
            end
            table.insert(self.matchRecords, {
                rankTime = v.rankTime,
                season = v.season,
                score = v.score,
                rank = v.rank,
                reward = reward,
            })
        end
    end

    self.rewardsTips = {}
    for i, v in ipairs(data.rewardsTips or {}) do
        local reward = {}
        for resid, count in pairs(v) do
            reward[tonumber(resid)] = count
        end
        table.insert(self.rewardsTips, reward)
    end
end

function PvpBag:pack()
    local matchInfo = self:getPvpMatchInfo()
    for i, v in ipairs(matchInfo.playerList) do
        local armyPlayer = self.armyPlayers[v.playerId]
        if armyPlayer then
            for kk, vv in pairs(v) do
                armyPlayer[kk] = vv
            end
        end
    end
    local season = 0
    local lifeTime = 0
    local info = gg.matchProxy:call("getCurrentMatchInfo", constant.MATCH_BELONG_PVP, constant.MATCH_TYPE_SEASON)
    if info then
        season = info.season
        local endTime = string.totime(info.endTime)
        lifeTime = math.max(endTime - gg.time.time(), 0)
    end
    local data = {
        enemies = {},
        battleTotal = self:getBattleTotal(),
        battleNum = self.battleNum,
        battleNumPurchased = self.battleNumPurchased,
        banLessTime = self:getBanLessTime(),
        banTotalTime = self:getBanTotalTime(),
        jackpot = matchInfo.jackpot,
        myreward = matchInfo.reward,
        myScore = self:getPlayerRankScore(),
        refreshCount = self.refreshCount,
        season = season,
        lifeTime = lifeTime,
    }
    local enemies = {}
    for i=1, #self.armyPlayerList do
        local playerId = self.armyPlayerList[i]
        local armyPlayer = self.armyPlayers[playerId]
        if armyPlayer and not armyPlayer.skip then
            table.insert(enemies, armyPlayer)
        end
    end
    if #enemies >= 1 then
        local enemie = table.chooseFromDict(enemies)
        table.insert(data.enemies, enemie)
    end
    local armyPlas = {}
    for k,v in pairs(self.armyPlayers) do
        table.insert(armyPlas, v.playerId)
    end
    if data.enemies[1] then
        logger.logf("info","PvpBattle","attPlayerId=%s, enemieId=%s, enemiePool=%s", self.player.pid, data.enemies[1].playerId, table.dump(armyPlas))    
    end
    return data
end

function PvpBag:getPvpMatchInfo()
    local pid = self.player.pid
    if gg.isGmRobotPlayer(pid) then
        pid = 0
    end
    local info = gg.shareProxy:call("getPvpMatchInfo", pid, self.armyPlayerList)
    return info
end

function PvpBag:getPlayerRankScore()
    local rankInfo = gg.rankProxy:call("getSelfRank", constant.REDIS_MATCH_RANK_BADGE, self.player.pid)
    return rankInfo.score
end

function PvpBag:getPlayerRankInfo()
    local rankInfo = gg.rankProxy:call("getSelfRank", constant.REDIS_MATCH_RANK_BADGE, self.player.pid)
    return rankInfo
end

function PvpBag:resetData()
    self.resetTick = (gg.time.dayzerotime() + 86400) * 1000
    self.banBattleCount = 0
    self.banBattleTick = 0
    self.refreshCount = 0
    self.battleNum = self:getBattleTotal()
    self.battleNumPurchased = 0

    self.index = 1
    self.armyPlayers = {}
    self.armyPlayerList = {}
    self:_checkNewEnemies()
end

function PvpBag:getNftCount()
    local nftCount = {0, 0, 0, 0, 0}
    local nftHeros = self.player.heroBag:getNftHeros()
    local nftBuilds = self.player.buildBag:getNftBuilds()
    local nftWarShips = self.player.warShipBag:getNftWarShips()
    local nftHeroCount = self:getOtherNftCount(nftHeros)
    local nftBuildCount = self:getOtherNftCount(nftBuilds)
    local nftWarShipCount = self:getOtherNftCount(nftWarShips)
    for i=1,5 do
        nftCount[i] = nftHeroCount[i] + nftBuildCount[i] + nftWarShipCount[i]
    end
    return nftCount
end

function PvpBag:getOtherNftCount(nfts)
    local nftCount = {0, 0, 0, 0, 0}
    if not nfts or not next(nfts) then
        return nftCount
    end
    for _, nft in pairs(nfts) do
        local quality = nft.quality
        if quality and quality > 0 then
            nftCount[quality] = nftCount[quality] + 1
        end
    end
    return nftCount
end

function PvpBag:getNftBattleAdd()
    local nftBattleAdd = 0
    local nftCount = self:getNftCount()
    local nftBattleAddCfg = cfg.get("etc.cfg.nftBattleAdd")
    if not nftBattleAddCfg or not next(nftBattleAddCfg) then
        return nftBattleAdd
    end

    for _,v in pairs(nftBattleAddCfg) do
        nftBattleAdd = nftBattleAdd + math.floor(nftCount[v.quality] / v.nftNum) * v.addNum
    end
    return nftBattleAdd
end

function PvpBag:calBaseBattleAdd(tab, level)
    for k,v in pairs(tab) do
        if v.level == level then
            return v.battleNumAdd
        end
    end
end

function PvpBag:getBaseBattleAdd()
    local baseBattleAdd = 0
    local baseBuildLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
    local cfg = gg.getExcelCfg("baseLevel")  --constant.PVP_PLAYER_BATTLE_ADD_BASE  -- ""
    if not cfg or not next(cfg) then
        return baseBattleAdd
    end
    baseBattleAdd = self:calBaseBattleAdd(cfg, baseBuildLevel)
    return baseBattleAdd
end

function PvpBag:getVipBattleAdd()
    local vipBattleAdd = 0
    local vipLevel = self.player.vipBag:getVipLevel()
    local cfgs = cfg.get("etc.cfg.vip")
    local cfg = cfgs[vipLevel]
    if not cfg then
        return vipBattleAdd
    end
    vipBattleAdd = cfg.battleNumAdd
    return vipBattleAdd
end

function PvpBag:getBattleTotal()
    local nftBattleAdd = self:getNftBattleAdd()
    local baseBattleAdd = self:getBaseBattleAdd()
    local vipBattleAdd = self:getVipBattleAdd()
    local battleTotal = constant.PVP_PLAYER_BATTLE_TOTAL + nftBattleAdd + baseBattleAdd + vipBattleAdd
    local vipLevel = self.player.vipBag:getVipLevel()
    logger.logf("info","GetBattleTotal","PvpBag:getBattleTotal pid=%d nftBattleAdd=%d baseBattleAdd=%d vipBattleAdd=%d vipLevel=%s", self.player.pid, nftBattleAdd, baseBattleAdd, vipBattleAdd,vipLevel)
    if battleTotal > constant.PVP_PLAYER_BATTLE_MAX then
        battleTotal = constant.PVP_PLAYER_BATTLE_MAX
    end
 
    -- if self.battleNum > battleTotal then
    --     self.battleNum = battleTotal
    -- end
    return battleTotal
end

function PvpBag:getPerBattleNumCost(num)
    local pvpBuyCfg = cfg.get("etc.cfg.pvpBuyCost")
    if not pvpBuyCfg or not next(pvpBuyCfg) then
        return 0
    end
    local len = #pvpBuyCfg
    if num >= 1 and num <= len then
        return pvpBuyCfg[num].tesseractCost
    elseif num > len then
        return pvpBuyCfg[len].tesseractCost
    end
end

function PvpBag:calBattleNumCost(addNum)
    local start = self.battleNumPurchased + 1
    local stop = start + addNum - 1
    local cost = 0
    for i = start, stop do
        cost = cost + self:getPerBattleNumCost(i)
    end
    return cost
end

function PvpBag:addBattleNum(addNum)
    if not addNum then
        self.player:say(util.i18nFormat(errors.BATTLE_NUM_BOUGHT_WRONG))
        return
    end
    -- if self:getBattleTotal() == self.battleNum then
    --     self.player:say(util.i18nFormat(errors.BATTLE_NUM_FULL))
    --     return
    -- end
    if addNum < 1 or addNum > 10 then
        self.player:say(util.i18nFormat(errors.BATTLE_NUM_BOUGHT_WRONG))
        return
    end
    if not self.player:isGm() then
        local battleNumBuyLimit = gg.getGlobalCfgIntValue("BattleNumBuyLimit", 10)
        if self.battleNumPurchased + addNum > battleNumBuyLimit then
            self.player:say(util.i18nFormat(errors.BATTLE_NUM_BOUGHT_LIMIT, battleNumBuyLimit))
            return
        end
    end

    local cost = self:calBattleNumCost(addNum)
    if not self.player.resBag:enoughRes(constant.RES_TESSERACT, cost) then
        self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
        return
    end
    self.player.resBag:costRes(constant.RES_TESSERACT, cost, {logType=gamelog.ADD_BATTLE_NUM})
    self.battleNum = self.battleNum + addNum
    self.battleNumPurchased = self.battleNumPurchased + addNum
    gg.client:send(self.player.linkobj,"S2C_Player_PvpData", self:pack())
end

function PvpBag:getBanLessTime()
    -- if self.banBattleTick == 0 or skynet.timestamp() > self.banBattleTick then
    --     return 0
    -- end
    -- return math.floor((self.banBattleTick - skynet.timestamp()) / 1000)
    return 0
end

--""
function PvpBag:isBanBattle()
    -- if self.banBattleTick > 0 and skynet.timestamp() < self.banBattleTick then
    --     return true
    -- end
    return false
end

function PvpBag:getBanTotalTime()
    if constant.BAN_OFFLINE_BATTLE_TIME[self.banBattleCount] then
        return constant.BAN_OFFLINE_BATTLE_TIME[self.banBattleCount]
    else
        return constant.BAN_OFFLINE_BATTLE_TIME[#constant.BAN_OFFLINE_BATTLE_TIME]
    end
end

--""
function PvpBag:setBanBattleTick()
    self.banBattleCount = self.banBattleCount + 1
    self.banBattleTick = skynet.timestamp() + self:getBanTotalTime() * 1000
end

--""
function PvpBag:updateArmyAttacked(armyId)
    if not armyId or armyId == 0 then
        return
    end
    if gg.isGmRobotPlayer(armyId) then
        -- self.player.pveBag:updateArmyAttacked(armyId)
        -- self.pveWinIds[armyId] = true
        -- self.pveScore = self.pveScore + armyId * 1
        -- local pveLog = {}
        -- pveLog.pid = self.player.pid
        -- pveLog.account = self.player.account
        -- pveLog.name = self.player.name
        -- pveLog.pveScore = self.pveScore
        -- pveLog.pveLevel = armyId
        -- pveLog.level = self.player.buildBag:getBaseBuildLevel()

        -- gg.internal:send(".gamelog", "api", "addPlayerPVELog", pveLog)
    end
    if not self.armyPlayers[armyId] then
        return
    end
    if gg.getGlobalCfgIntValue("EnableBattleSameEnemyRepeat", 1) == 0 then
        self.armyPlayers[armyId].canAttack = false
        gg.client:send(self.player.linkobj,"S2C_Player_PvpData", self:pack())
    end
end

function PvpBag:enoughBattleNum(enemyId)
    if gg.isGmRobotPlayer(enemyId) then
        return true
    end
    return self.battleNum > 0
end
function PvpBag:decrPlayerBattleNum(enemyId)
    if self.freeFight and self.battleNum <= 0 then
        return
    end
    if not gg.isGmRobotPlayer(enemyId) then
        self.battleNum = self.battleNum - 1
    end
end

function PvpBag:getFreeFight(enemyId)
    return self.freeFight
end

function PvpBag:setFreeFight(flag)
    self.freeFight = flag
end

function PvpBag:getFreeBeFight(enemyId)
    return self.freeBeFight
end

function PvpBag:setFreeBeFight(flag)
    self.freeBeFight = flag
end

function PvpBag:_cachePlayers()
    self.copyPlayerList =  self.armyPlayerList
    self.copyPlayers = self.armyPlayers
    self.armyPlayerList = {}
    self.armyPlayers = {}
end

function PvpBag:_recoverPlayers()
    self.armyPlayerList = self.copyPlayerList
    self.armyPlayers = self.copyPlayers
    self.copyPlayerList = {}
    self.copyPlayers = {}
end

function PvpBag:_clearCachePlayers()
    self.copyPlayerList = {}
    self.copyPlayers = {}
end

function PvpBag:changePlayers()
    local baseLv = self.player.buildBag:getBaseBuildLevel()
    local cfgVal = gg.getGlobalCfgIntValue("PvpUnlockLevel", 3)
    if baseLv < cfgVal then
        local msg = util.i18nFormat(errors.BATTLE_BASE_LEVEL_NOT_ENOUGH, cfgVal)
        self.player:say(msg)
        return
    end
    -- local playerLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
    -- local costCfg = PvpBag.getPvpCost(playerLevel)
    -- if not costCfg then
    --     self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
    --     return
    -- end
    self:_cachePlayers()
    self:_checkNewEnemies()
    if table.count(self.armyPlayerList) == 0 or table.count(self.armyPlayers) == 0 then
        self:_recoverPlayers()
        return
    end
    -- local costStarCoin = costCfg.findCost or 0
    local gPvpCostCfg = gg.getGlobalCfgTableValue("FindPvpPlayersCostStarCoin", {})
    local refreshCount = self.refreshCount + 1
    if refreshCount >= #gPvpCostCfg then
        refreshCount = #gPvpCostCfg
    end
    local costStarCoin = gPvpCostCfg[refreshCount]
    if not costStarCoin then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        self:_recoverPlayers()
        return
    end
    if not self.player.resBag:enoughRes(constant.RES_STARCOIN, costStarCoin) then
        self.player:say(util.i18nFormat(errors.STARCOIN_NOT_ENOUGH))
        self:_recoverPlayers()
        return
    end
    self.player.resBag:costRes(constant.RES_STARCOIN, costStarCoin, {logType = gamelog.FIND_PVP_PLAYERS})
    self:_clearCachePlayers()
    self.refreshCount = self.refreshCount + 1
    gg.client:send(self.player.linkobj, "S2C_Player_PvpData", self:pack())
end

function PvpBag:autoChangePlayers(enemyId)
    self:_cachePlayers()
    self:_checkNewEnemies(enemyId)
    if table.count(self.armyPlayerList) == 0 or table.count(self.armyPlayers) == 0 then
        self:_recoverPlayers()
        return
    end
    self:_clearCachePlayers()
    gg.client:send(self.player.linkobj, "S2C_Player_PvpData", self:pack())
end

function PvpBag:queryPlayers()
    self:joinMatch()
    local data = self:pack()
    gg.client:send(self.player.linkobj, "S2C_Player_PvpData", data)
end

function PvpBag:_scoutGMRobotFoundation(enemyId)
    local info = gg.playerProxy:call(enemyId, "getFoundationInfo")
    if not info then
        self.player:say(util.i18nFormat(errors.EMEMY_NO_PLAYER))
        return
    end
    local canAttack = true--not self.pveWinIds[enemyId]
    gg.client:send(self.player.linkobj,"S2C_Player_PvpScoutFoundation", {info=info, canAttack=canAttack})
end

--""
function PvpBag:scoutFoundation(enemyId)
    -- if gg.isGmRobotPlayer(enemyId) then
    -- --    return self:_scoutGMRobotFoundation(enemyId)
    --    return self.player.pveBag:_scoutFoundation(enemyId)
    -- end

    local defender = self.armyPlayers[enemyId]
    if not defender then
        self.player:say(util.i18nFormat(errors.EMEMY_NOT_PVP))
        return
    end
    local info = gg.playerProxy:call(enemyId, "getFoundationInfo")
    if not info then
        self.player:say(util.i18nFormat(errors.EMEMY_NO_PLAYER))
        return
    end
    local costCfg = ggclass.PvpBag.getPvpCost(info.playerLevel)
    if not costCfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    local costStarCoin = costCfg.scoutCost or 0
    if not self.player.resBag:enoughRes(constant.RES_STARCOIN, costStarCoin) then
        self.player:say(util.i18nFormat(errors.STARCOIN_NOT_ENOUGH))
        return
    end
    self.player.resBag:costRes(constant.RES_STARCOIN, costStarCoin, {logType=gamelog.SCOUT_PVP_PLAYER}) 
    gg.client:send(self.player.linkobj,"S2C_Player_PvpScoutFoundation", {info=info, canAttack=defender.canAttack})
end

-- function PvpBag:queryGmRobotPlayers()
--     local list = {}
--     local pidList = {}
--     for i = 1, 20, 1 do
--         table.insert(pidList, i)
--     end
--     local pidResult = gg.playerProxy:batchCall(pidList, "getFoundationInfo")
--     for i, pid in ipairs(pidList) do
--         local rInfo = pidResult[pid]
--         if rInfo then
--             table.insert(list, {
--                 playerId = rInfo.playerId,
--                 playerName = rInfo.playerName,
--                 level = rInfo.playerLevel,
--                 daoName = "",
--                 playerHead = rInfo.playerHead,
--                 canAttack = true,
--             })
--         end
--     end
--     local sendData = {
--         enemies = list,
--         pveWinIds = table.keys(self.pveWinIds),
--         pveScore = self.pveScore,
--     }
--     gg.client:send(self.player.linkobj, "S2C_Player_PvpGmRobotPlayers", sendData)
-- end

function PvpBag:sendPvpBackGroundCfg()
    -- local PvpStage = gg.opCfgProxy:getOpCfg(constant.REDIS_PVP_STAGE_RATIO)
    local PvpStage = gg.dynamicCfg:get(constant.REDIS_PVP_STAGE_RATIO)
    -- local PvpRankMitReward = gg.opCfgProxy:getOpCfg(constant.REDIS_PVP_RANK_MIT_REWARD)
    local PvpRankMitReward = gg.dynamicCfg:get(constant.REDIS_PVP_RANK_MIT_REWARD)
    gg.client:send(self.player.linkobj,"S2C_Player_sendPvpBackGroundCfg", {
        stage = PvpStage,
        reward = PvpRankMitReward,
    })
end

function PvpBag:addMatchRecord(data)
    local record = {
        rankTime = data.rankTime,
        season = data.season,
        score = data.score,
        rank = data.rank,
        reward = data.reward,
    }
    table.insert(self.matchRecords, record)
end

function PvpBag:packMatchRecords()
    local matchRecords = {}
    for i, v in ipairs(self.matchRecords) do
        local reward = {}
        for resid, count in pairs(v.reward) do
            table.insert(reward, {
                resCfgId = resid,
                count = count,
                bind = false,
            })
        end
        table.insert(matchRecords, {
            rankTime = v.rankTime,
            season = v.season,
            score = v.score,
            rank = v.rank,
            reward = reward,
        })
    end
    return matchRecords
end

function PvpBag:sendPvpMatchRewardRecords()
    local records = self:packMatchRecords()
    gg.client:send(self.player.linkobj,"S2C_Player_pvpMatchRewardRecords", {
        records = records,
    })
end

function PvpBag:addRewardsTips(reward)
    table.insert(self.rewardsTips, reward)
end

function PvpBag:packRewardsTips()
    local rewardsTips = {}
    for i, v in ipairs(self.rewardsTips) do
        local reward = {}
        for resid, count in pairs(v) do
            table.insert(reward, {
                resCfgId = resid,
                count = count,
                bind = false,
            })
        end
        table.insert(rewardsTips, {reward = reward})
    end
    return rewardsTips
end

function PvpBag:sendPvpMatchRewardsTips()
    if table.count(self.rewardsTips) == 0 then
        return
    end
    if not self.player.linkobj then
        return
    end
    local records = self:packRewardsTips()
    gg.client:send(self.player.linkobj,"S2C_Player_pvpMatchRewardTips", {
        rewards = records,
    })
    self.rewardsTips = {}
end

-- function PvpBag:_sendMatchRankReward(settleData)
--     if settleData.mit <= 0 then
--         return
--     end
--     local mailTemplate = gg.getExcelCfg("mailTemplate")
--     local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_PVP_RANK]
--     local sendId = 0
--     local sendName = mailCfg.sendName
--     local title = mailCfg.mailTitle
--     local mailItems = {}
--     table.insert(mailItems, {
--         cfgId = constant.RES_MIT,
--         count = settleData.mit,
--         type = constant.MAIL_ATTACH_RES,
--     })
--     local mailData = {
--         title = title,
--         content = string.format(mailCfg.mailContent, settleData.rank),
--         attachment = mailItems,
--         logType = gamelog.PVP_MATCH_SETTLEMENT
--     }
--     gg.mailProxy:send("gmSendMail", sendId, sendName, { self.player.pid }, mailData)
-- end

-- function PvpBag:_sendMatchStageReward(settleData)
--     if settleData.carboxyl <= 0 then
--         return
--     end
--     local mailTemplate = gg.getExcelCfg("mailTemplate")
--     local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_PVP_STAGE]
--     local sendId = 0
--     local sendName = mailCfg.sendName
--     local title = mailCfg.mailTitle
--     local mailItems = {}
--     table.insert(mailItems, {
--         cfgId = constant.RES_CARBOXYL,
--         count = settleData.carboxyl,
--         type = constant.MAIL_ATTACH_RES,
--     })
--     local mailData = {
--         title = title,
--         content = string.format(mailCfg.mailContent, settleData.score, settleData.stageName),
--         attachment = mailItems,
--         logType = gamelog.PVP_MATCH_SETTLEMENT
--     }
--     gg.mailProxy:send("gmSendMail", sendId, sendName, { self.player.pid }, mailData)
-- end

function PvpBag:_sendMatchReward(settleData)
    if settleData.carboxyl <= 0 and settleData.mit <= 0 then
        return
    end
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_PVP_MATCH_REWARD]
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle
    local mailItems = {}
    if settleData.carboxyl > 0 then
        table.insert(mailItems, {
            cfgId = constant.RES_CARBOXYL,
            count = settleData.carboxyl,
            type = constant.MAIL_ATTACH_RES,
        })
    end
    if settleData.mit > 0 then
        table.insert(mailItems, {
            cfgId = constant.RES_MIT,
            count = settleData.mit,
            type = constant.MAIL_ATTACH_RES,
        })
    end
    
    local mailData = {
        title = title,
        content = string.format(mailCfg.mailContent, settleData.score, settleData.stageName or "", settleData.rank),
        attachment = mailItems,
        logType = gamelog.PVP_MATCH_SETTLEMENT
    }
    gg.mailProxy:send("gmSendMail", sendId, sendName, { self.player.pid }, mailData)
end

function PvpBag:matchSettlement(settleData)
    local delN = gg.shareProxy:call("delPlayerPvpMatchReward", self.player.pid)
    if delN == 0 then
        return
    end
    -- self:_sendMatchRankReward(settleData)
    -- self:_sendMatchStageReward(settleData)
    self:_sendMatchReward(settleData)
    local reward = {[constant.RES_MIT] = settleData.mit, [constant.RES_CARBOXYL] = settleData.carboxyl}
    -- self.player.resBag:addResDict(reward, { logType = gamelog.PVP_MATCH_SETTLEMENT })
    self:addMatchRecord({
        rankTime = settleData.rankTime,
        season = settleData.season,
        score = settleData.score,
        rank = settleData.rank,
        reward = reward,
    })
    -- self:addRewardsTips(reward)
    -- self:sendPvpMatchRewardsTips()

    self:resetData()
    return true
end

function PvpBag:joinMatch()
    local baseLv = self.player.buildBag:getBaseBuildLevel()
    local cfgVal = gg.getGlobalCfgIntValue("PvpUnlockLevel", 3)
    if baseLv < cfgVal then
        return
    end
    local joinOk = gg.matchProxy:call("joinMatch", constant.MATCH_BELONG_PVP, self.player.pid, 1)
    if joinOk then
        gg.rankProxy:send("syncPvpMatchBadgeInfo", self.player.pid, 0)
    end
end

function PvpBag:updateMatchRankScore(change)
    if change == 0 then
        return
    end
    local rankInfos = gg.matchProxy:getInStartMatchs(constant.MATCH_BELONG_PVP, constant.MATCH_TYPE_SEASON)
    if table.count(rankInfos) == 0 then
        return
    end
    if change > 0 then
        return self:_increMatchRankScore(change)
    else
        return self:_decreMatchRankScore(change)
    end
end

function PvpBag:_increMatchRankScore(change)
    if constant.PVP_MATCH_TEST_SCORE then
        gg.rankProxy:send("increPvpMatchBadgeInfo", self.player.pid, constant.PVP_MATCH_TEST_SCORE)
    end
    gg.rankProxy:send("increPvpMatchBadgeInfo", self.player.pid, change)
    self.player.taskBag:update(constant.TASK_PVP_SCORE, {score = change})
    return true
end

function PvpBag:_decreMatchRankScore(change)
    gg.rankProxy:send("increPvpMatchBadgeInfo", self.player.pid, change)
    return true
end

function PvpBag:_canAddNewEnemies()
    if gg.isGmRobotPlayer(self.player.pid) then
        return
    end

    local stageDict = gg.matchProxy:call("getMatchStage", constant.MATCH_BELONG_PVP)
    for cfgId, stage in pairs(stageDict) do
        if stage == constant.MATCH_STATE.NOTICE or stage == constant.MATCH_STATE.BEGIN then
            return true
        end
    end
end

function PvpBag:_addNewEnemies(armies)
    for _, v in pairs(armies) do
        if not self.armyPlayers[v.playerId] then
            v.diff = nil
            v.canAttack = true
            self.armyPlayers[v.playerId] = v
            table.insert(self.armyPlayerList, v.playerId)
        else
            self.armyPlayers[v.playerId].skip = false
            self.armyPlayers[v.playerId].canAttack = true
        end
    end
end

function PvpBag:_checkNewEnemies(enemyId)
    if table.count(self.armyPlayerList) >= constant.ARMY_COUNT_PER_INDEX then
        return
    end
    if not self:_canAddNewEnemies() then
        return
    end
    local score = -1
    local scoreBoundary = gg.getGlobalCfgIntValue("PvpMatchPoint", 3)
    local lvBoundary = gg.getGlobalCfgIntValue("PvpMatchLevel", 3)
    local pvpSearchCount = gg.getGlobalCfgIntValue("PvpSearchCount", 7)
    local armies = gg.shareProxy:call(
        "searchPlayersByBadge",
        self.player.pid,
        score,
        scoreBoundary,
        pvpSearchCount,   -- pvp""
        {
            expandScope = 1,
            maxScope = 1000,
            excludePid = enemyId,

            expandLv = 0,
            maxLv = 40,
            lvBoundary = lvBoundary,
        }
    )
    self:_addNewEnemies(armies)
end

function PvpBag:_checkMatchSettlement()
    local data = gg.shareProxy:call("getPlayerPvpMatchReward", self.player.pid)
    if not data then
        return
    end
    local size = table.count(data)
    if size == 0 then
        return
    end
    local STR_KEYS = {
        ["stageName"] = true,
    }
    local settleData = {}
    for i = 1, size, 2 do
        local k = data[i]
        local v = data[i+1]
        if not STR_KEYS[k] then
            v = tonumber(data[i+1])
        end
        settleData[k] = v
    end
    self:matchSettlement(settleData)
end

function PvpBag:getMaxPveWin()
    local maxPve = 0
    for armyId, _ in pairs(self.pveWinIds) do
        if armyId > maxPve then
            maxPve = armyId
        end
    end
    return maxPve
end

function PvpBag:checkResetData()
    if gg.time.time() * 1000  <= self.resetTick then
        return
    end
    self:resetData()
    gg.client:send(self.player.linkobj,"S2C_Player_PvpData", self:pack())
end

function PvpBag:onSecond()
    self:checkResetData()
end

--""10""
function PvpBag:onTenMinuteUpdate()
end

function PvpBag:onload()
    self:_checkNewEnemies()
end

function PvpBag:oncreate()
    self.index = 1
    self.resetTick = (gg.time.dayzerotime() + 86400) * 1000
end

function PvpBag:onlogin()
    self:sendPvpBackGroundCfg()
    self:sendPvpMatchRewardRecords()
    -- self:sendPvpMatchRewardsTips()

    self:joinMatch()
    self:_checkMatchSettlement()
end

function PvpBag:onlogout()

end


return PvpBag