-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

function api.updateOperationCfg(key, value)
    gg.opCfgMgr:updateOpCfg(key, value)
end

function api.getOperationCfg(key)
    return gg.opCfgMgr:getOpCfg(key)
end

return api