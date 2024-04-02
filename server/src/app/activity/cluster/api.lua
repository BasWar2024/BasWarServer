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
end

function api.updateActivityData(cfgId, data)
    return gg.activityMgr:updateActivityData(cfgId, data)
end

function api.actFirstGetGridRank(pid, cfgId)
    return gg.activityMgr:actFirstGetGridRank(pid, cfgId)
end

return 