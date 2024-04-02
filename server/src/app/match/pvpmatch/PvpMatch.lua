local PvpMatch = class("PvpMatch", ggclass.MatchBase)

function PvpMatch:ctor(cfgId)
    PvpMatch.super.ctor(self, cfgId)
    self.season = 1
    self:_init()
end

function PvpMatch:_init()
    -- local jackpotInfo = gg.shareProxy:call("getOpCfg", constant.REDIS_PVP_JACKPOT_INFO)
    local jackpotInfo = gg.dynamicCfg:get(constant.REDIS_PVP_JACKPOT_INFO)
    -- local stageRatio = gg.shareProxy:call("getOpCfg", constant.REDIS_PVP_STAGE_RATIO)
    local stageRatio = gg.dynamicCfg:get(constant.REDIS_PVP_STAGE_RATIO)
    -- local jackpotShareRatio = gg.shareProxy:call("getOpCfg", constant.REDIS_PVP_JACKPOT_SHARE_RATIO)
    local jackpotShareRatio = gg.dynamicCfg:get(constant.REDIS_PVP_JACKPOT_SHARE_RATIO)
    -- local rankMitReward = gg.shareProxy:call("getOpCfg", constant.REDIS_PVP_RANK_MIT_REWARD)
    local rankMitReward = gg.dynamicCfg:get(constant.REDIS_PVP_RANK_MIT_REWARD)
end

--overwrite
function PvpMatch:joinMatch(pid, id)
    if not self:isNoticeStage() and not self:isStartStage() then
        return
    end
    if self.members[pid] then
        return
    end
    self.members[pid] = id
    self.dirty = true
    return true
end

function PvpMatch:clearRankData()
    local isOk = gg.internal:call(".rank", "api", "delRank", constant.REDIS_MATCH_RANK_BADGE)
    if isOk then
    end
end

function PvpMatch:addJackpotSysVal()
    if not constant.PVP_AUTO_ADD_JACKPOT then
        return
    end
    local jackpotInfo
    local info = gg.redisProxy:call("get", constant.REDIS_PVP_JACKPOT_INFO)
    if not info or info == "" then
        jackpotInfo = {
            sysCarboxyl = 0,
            plyCarboxyl = 0,
        }
    else
        jackpotInfo = cjson.decode(info)
    end
    jackpotInfo.sysCarboxyl = jackpotInfo.sysCarboxyl + constant.PVP_JACKPOT_SYSVAL
    gg.dynamicCfg:set(constant.REDIS_PVP_JACKPOT_INFO, jackpotInfo)
end

function PvpMatch:onNoticeTimeout()
    self:clearRankData()
    self:addJackpotSysVal()
end

function PvpMatch:onStartTimeout()
end

function PvpMatch:onEndTimeout()
    local rankMembers = gg.shareProxy:call("getPvpRankMembers", self.cfgId)
    self:updateMatchRankInfo(rankMembers)
end

function PvpMatch:onDistributeReward(rankVersion)
    local pidDict = {}
    local rankInfo
    for kk, vv in pairs(self.rankVersions) do
        if vv.ver == self.nowVer then
            rankInfo = vv
            break
        end
    end
    local matchData = {
        season = self.nowVer,
        rankTime = rankInfo.rankTime,
        rewardTime = rankInfo.rewardTime,
    }
    local settlementList = gg.shareProxy:call("getPvpMatchSettlement", matchData)
    for rank, data in ipairs(settlementList) do
        if self.members[data.pid] then
            if data.score > 0 then
                local settleData = {
                    season = self.nowVer,
                    rankTime = rankInfo.rankTime,
                    rewardTime = rankInfo.rewardTime,
                    rank = rank,
                    score = data.score,
                    carboxyl = data.carboxyl,
                    mit = data.mit,
                    stageName = data.stageName,
                }
                pidDict[data.pid] = settleData
            end
        end
    end
    for pid, data in pairs(pidDict) do
        gg.playerProxy:sendOnline(pid, "onPvpMatchSettlement", data)
    end
    rankVersion.isDistribute = true
    return true
end

function PvpMatch:onMinute()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    if not util.betweenCfgTime(matchCfg, "startTime", "endTime") then
        return
    end
    local rankMembers = gg.shareProxy:call("getPvpRankMembers", self.cfgId)
    self:updateMatchRankInfo(rankMembers)
end

return PvpMatch
