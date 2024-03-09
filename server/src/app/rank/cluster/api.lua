-- api
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

function api.getBadgeRank()

end

function api.syncCostMitInfo(pid, costMit)
    gg.rank:syncCostMitInfo(pid, costMit)
end

function api.getCostMitRank()

end

function api.syncPlanetInfo(pid, count)
    gg.rank:syncPlanetInfo(pid, count)
end

function api.getPlanetRank()

end

return api