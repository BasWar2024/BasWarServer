-- ""api
local md5 =	require	"md5" 

gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

function api.subscribe(chan, addr)
    return gg.multicast:subscribe(chan, addr)
end

function api.unsubscribe(chan, addr)
    return gg.multicast:unsubscribe(chan, addr)
end

function api.onPublish(chan, ...)
    return gg.multicast:onPublish(chan, ...)
end

return api