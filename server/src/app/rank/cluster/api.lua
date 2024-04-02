-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

function api.syncBadgeInfo(pid, badge)
    gg.rank:syncBadgeInfo(pid, badge)
end

function api.getBadgeRank(pid, version)
    return gg.rank:getBadgeRank(pid, version)
end

function api.syncPvpMatchBadgeInfo(pid, badge)
    gg.rank:syncPvpMatchBadgeInfo(pid, badge)
end

function api.increPvpMatchBadgeInfo(pid, badge)
    gg.rank:increPvpMatchBadgeInfo(pid, badge)
end

function api.getPvpMatchBadgeRank(pid, version)
    return gg.rank:getPvpMatchBadgeRank(pid, version)
end

function api.syncCostMitInfo(pid, costMit)
    gg.rank:syncCostMitInfo(pid, costMit)
end

function api.getCostMitRank(pid, version)
    return gg.rank:getCostMitRank(pid, version)
end

function api.syncPlanetInfo(pid, count)
    gg.rank:syncPlanetInfo(pid, count)
end

function api.getPlanetRank(pid, version)
    return gg.rank:getPlanetRank(pid, version)
end

function api.getRealBadgeRank()
    return gg.rank:getRealBadgeRank()
end

function api.delRank(rankKey)
    return gg.rank:delRank(rankKey)
end


local function _getRankList(rankKey, pid, version)
    if constant.RANK_REFRESH_RANK_KEY[rankKey] then
        return gg.rank:getDifferentRank(rankKey, pid, version)
    elseif constant.RANK_REFRESH_UNION_RANK_KEY[rankKey] then
        return gg.unionRank:getDifferentRank(rankKey, pid, version)
    end
end
function api.getRankList(rankKey, pid, version)
    local ok, ret1, ret2 = gg.sync:once_do("rank_"..rankKey, _getRankList, rankKey, pid, version)
    if not ok then
        return nil
    end
    return ret1, ret2
end

function api.getSelfRank(rankKey, pid)
    if constant.RANK_REFRESH_RANK_KEY[rankKey] then
        return gg.rank:getSelfRank(rankKey, pid)
    elseif constant.RANK_REFRESH_UNION_RANK_KEY[rankKey] then
        return gg.unionRank:getSelfRank(rankKey, pid)
    end
end

function api.syncDifferentRankVal(rankKey, pid, val)
    if constant.RANK_REFRESH_RANK_KEY[rankKey] then
        gg.rank:syncDifferentRankVal(rankKey, pid, val)
    elseif constant.RANK_REFRESH_UNION_RANK_KEY[rankKey] then
        gg.unionRank:syncDifferentRankVal(rankKey, pid, val)
    end
end

function api.increDifferentRankVal(rankKey, pid, val)
    if constant.RANK_REFRESH_RANK_KEY[rankKey] then
        gg.rank:increDifferentRankVal(rankKey, pid, val)
    elseif constant.RANK_REFRESH_UNION_RANK_KEY[rankKey] then
        gg.unionRank:increDifferentRankVal(rankKey, pid, val)
    end
end

return api