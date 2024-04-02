local StarmapMatch = class("StarmapMatch", ggclass.MatchBase)

function StarmapMatch:ctor(cfgId)
    StarmapMatch.super.ctor(self, cfgId)
end

function StarmapMatch:addJackpotSysVal()
    if not constant.STARMAP_AUTO_ADD_JACKPOT then
        return
    end
    local matchCfg = self:getMatchCfg()
    if matchCfg.matchType ~= constant.MATCH_TYPE_SEASON then
        return
    end
    local jackpotInfo
    local info = gg.redisProxy:call("get", constant.REDIS_STARMAP_JACKPOT_INFO)
    if not info or info == "" then
        jackpotInfo = {
            sysCarboxyl = 0,
            plyCarboxyl = 0,
        }
    else
        jackpotInfo = cjson.decode(info)
    end
    jackpotInfo.sysCarboxyl = jackpotInfo.sysCarboxyl + constant.STARMAP_JACKPOT_SYSVAL
    gg.redisProxy:call("set", constant.REDIS_STARMAP_JACKPOT_INFO, cjson.encode(jackpotInfo))
end

function StarmapMatch:onNoticeTimeout()
    self:addJackpotSysVal()
    gg.unionProxy:send("onMatchNoticeTime", self.cfgId)
end

function StarmapMatch:onStartTimeout()
    gg.unionProxy:send("onMatchStartTime", self.cfgId)
end

function StarmapMatch:onEndTimeout()
    local rankMembers = gg.unionProxy:call("getStarmapMatchRankList", self.cfgId, self.members)
    self:updateMatchRankInfo(rankMembers)

    -- local chainRankData = gg.unionProxy:call("getStarmapMatchChainRankList", self.cfgId, self.members)
    -- self:updateMatchChainRankInfo(chainRankData)
    gg.unionProxy:send("onMatchEndTime", self.cfgId)
end

function StarmapMatch:onDistributeReward(rankVersion)
    local matchCfg = self:getMatchCfg()
    local carboxyl = 0
    local shareRatio = 0
    local jackpot = {}
    if matchCfg.matchType == constant.MATCH_TYPE_SEASON then
        jackpot = gg.shareProxy:call("getOpCfg", constant.REDIS_STARMAP_JACKPOT_INFO)
        carboxyl = jackpot.sysCarboxyl + jackpot.plyCarboxyl
        shareRatio = gg.shareProxy:call("getOpCfg", constant.REDIS_STARMAP_JACKPOT_SHARE_RATIO)
    end

    local rewardInfos = {}
    for rank, v in pairs(rankVersion.rankMembers) do
        local rewardCfg = self:getRewardByRank(rank)
        if rewardCfg then
            --""+GVG"" * gvgPercentage /10000
            local hyt = rewardCfg.hyt + math.floor(carboxyl * shareRatio * rewardCfg.gvgPercentage / 10000)
            table.insert(rewardInfos, { unionId = v.unionId, rank = rank, hyt = hyt, mit = rewardCfg.mit })
        end
    end
    gg.unionProxy:call("distributeMatchReward", self.cfgId, rewardInfos)
    rankVersion.isDistribute = true
    if matchCfg.matchType == constant.MATCH_TYPE_SEASON then
        jackpot.sysCarboxyl = math.floor(jackpot.sysCarboxyl * (1 - shareRatio))
        jackpot.plyCarboxyl = math.floor(jackpot.plyCarboxyl * (1 - shareRatio))
        local jackpotInfo = cjson.encode(jackpot)
        gg.redisProxy:call("set", constant.REDIS_STARMAP_JACKPOT_INFO, jackpotInfo)
    end
    -- ""、""、""
    if matchCfg.matchType == constant.MATCH_TYPE_SEASON then
        local ret = gg.starmapProxy:call("matchSeasonEndHandle")
        if not ret then
            logger.error("starmapMatch", "StarmapMatch call starmap matchSeasonEndHandle error cfgId=%d", self.cfgId)
        end
        skynet.sleep(10)
        local ret = gg.unionProxy:call("matchSeasonEndHandle")
        if not ret then
            logger.error("starmapMatch", "StarmapMatch call union matchSeasonEndHandle error cfgId=%d", self.cfgId)
        end
        gg.redisProxy:call("set", constant.REDIS_STARMAP_CUR_MATCH_ID, self.cfgId)
        gg.centerProxy:send("broadCast2Game", "kickAllPlayer", "reset")
        --nft""
        gg.mongoProxy.nftInfo:update({}, {["$set"] = { level = 1 } }, false, true)
    end
    return true
    -- return self:onDistributeChainReward(rankVersion)
end

function StarmapMatch:onDistributeChainReward(rankVersion)
    local rewardInfos = {}
    for k, v in pairs(rankVersion.chainRankData) do
        for rank, vv in pairs(v) do
            local rewardCfg = self:getRewardByRank(rank)
            if rewardCfg then
                table.insert(rewardInfos, { unionId = vv.unionId, rank = rank, hyt = rewardCfg["hy_"..k], mit = rewardCfg["mit_"..k] })
            end
        end
    end
    gg.unionProxy:call("distributeMatchReward", self.cfgId, rewardInfos)
    rankVersion.isDistribute = true
    -- ""、""、""
    local matchCfg = self:getMatchCfg()
    if matchCfg.matchType == constant.MATCH_TYPE_SEASON then
        local ret = gg.starmapProxy:call("matchSeasonEndHandle")
        if not ret then
            logger.error("starmapMatch", "StarmapMatch call starmap matchSeasonEndHandle error cfgId=%d", self.cfgId)
        end
        local ret = gg.unionProxy:call("matchSeasonEndHandle")
        if not ret then
            logger.error("starmapMatch", "StarmapMatch call union matchSeasonEndHandle error cfgId=%d", self.cfgId)
        end
    end
    return true
end

function StarmapMatch:onMinute()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    if not util.betweenCfgTime(matchCfg, "startTime", "endTime") then
        return
    end
    gg.unionProxy:send("onMatchRankUpdate", self.cfgId, self.members)
    -- gg.unionProxy:send("onMatchChainRankUpdate", self.cfgId, self.members)
end

return StarmapMatch
