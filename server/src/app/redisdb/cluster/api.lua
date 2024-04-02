-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

function api.runCommand(cmd, ...)
    local db = gg.redismgr:getdb()
    return db[cmd](db, ...)
end

return api