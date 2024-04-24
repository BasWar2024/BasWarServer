local RedisProxy = class("RedisProxy")

function RedisProxy:ctor()
    
end

function RedisProxy:call(cmd, ...)
    return gg.internal:call(".redisdb", "api", "runCommand", cmd, ...)
end

function RedisProxy:send(cmd, ...)
    return gg.internal:send(".redisdb", "api", "runCommand", cmd, ...)
end

return RedisProxy

