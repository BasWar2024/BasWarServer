
function gg.execRedisScript(script, ...)
    assert(script, "gg.execRedisScript no script")
    local tbl = {...}
    local ret = gg.redisProxy:call("eval", script, select(1,...))
    return ret
end

function __hotfix(module)
end