-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

function api.onGameServerStart()
    gg.matchMgr:saveall()
end

function api.joinMatch(belong, pid, id)
    return gg.matchMgr:joinMatch(belong, pid, id)
end

function api.updateMatchRankInfo(matchCfgId, rankMembers)
    gg.matchMgr:updateMatchRankInfo(matchCfgId, rankMembers)
end

function api.updateMatchChainRankInfo(matchCfgId, chainRankData)
    gg.matchMgr:updateMatchChainRankInfo(matchCfgId, chainRankData)
end

function api.getMatchStage(belong)
    return gg.matchMgr:getMatchStage(belong)
end

function api.getMatchData(belong, matchType)
    return gg.matchMgr:getMatchData(belong, matchType)
end

function api.getCurrentMatchRank(belong, matchType, myUnionId)
    return gg.matchMgr:getCurrentMatchRank(belong, matchType, myUnionId)
end

function api.getCurrentMatchChainRank(belong, matchType, myUnionId, chainIdx)
    return gg.matchMgr:getCurrentMatchChainRank(belong, matchType, myUnionId, chainIdx)
end

function api.getCurrentMatchSelfRank(belong, matchType, myUnionId)
    return gg.matchMgr:getCurrentMatchSelfRank(belong, matchType, myUnionId)
end

function api.getCurrentMatchChainSelfRank(belong, matchType, myUnionId, chainIdx)
    return gg.matchMgr:getCurrentMatchChainSelfRank(belong, matchType, myUnionId, chainIdx)
end

function api.getCurrentMatchInfo(belong, matchType)
    return gg.matchMgr:getCurrentMatchInfo(belong, matchType)
end

function api.handleMatchDataCmd(cfgId, op, opParam)
    return gg.matchMgr:handleMatchDataCmd(cfgId, op, opParam)
end

return 