local api = gg.api

local function _encodeStarmapMatchUnionInfo(info)
    local infoDict = {}
    for kk, vv in pairs(info) do
        local cfg = constant.UNION_STARMAP_BACKUP_KEYS[kk]
        if cfg.dtype == "table" then
            infoDict[kk] = cjson.encode(vv)
        else
            infoDict[kk] = vv
        end
    end
    return infoDict
end

local function _decodeStarmapMatchUnionInfo(info)
    local infoDict = {}
    for i = 1, #info, 2 do
        local field = info[i]
        local val = info[i+1]
        local cfg = constant.UNION_STARMAP_BACKUP_KEYS[field]
        if cfg.dtype == "table" then
            infoDict[field] = cjson.decode(val)
        elseif cfg.dtype == "number" then
            infoDict[field] = tonumber(val)
        end
    end
    return infoDict
end

function api.setStarmapMatchUnionInfo(unionId, infoDict)
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_DATA .. unionId
    for k,v in pairs(infoDict) do
        gg.redisProxy:send("hset", keyName, k, v)
    end
end

function api.getStarmapMatchUnionInfo(unionId)
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_DATA .. unionId
    return gg.redisProxy:call("hgetall", keyName)
end

function api.getStarmapMatchUnionDecodeInfo(unionId)
    local ret = {}
    if not unionId then
        return ret
    end
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_DATA .. unionId
    local info = gg.redisProxy:call("hgetall",keyName) or {}
    return _decodeStarmapMatchUnionInfo(info)
end

function api.delStarmapMatchUnionInfo(unionId)
    if not unionId then
        return
    end
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_DATA .. unionId
    return gg.redisProxy:call("del", keyName)
end

function api.getStarmapMatchUnionInfoKey(unionId, key, defaultValue)
    if not unionId then
        return defaultValue
    end
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_DATA .. unionId
    return gg.redisProxy:call("hget", keyName, key) or defaultValue
end

function api.removeStarmapMatchUnionInfoKey(unionId, key)
    if not unionId then
        return
    end
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_DATA .. unionId
    return gg.redisProxy:call("hdel", keyName, key)
end

function api.setStarmapMatchUnionData(data)
    for k, v in pairs(data) do
        local infoDict = _encodeStarmapMatchUnionInfo(v)
        api.setStarmapMatchUnionInfo(k, infoDict)
    end
    return true
end

function api.getStarmapMatchUnionData()
    local ret = {}
    local keyList = gg.redisProxy:call("keys", constant.REDIS_STARMAP_MATCH_UNION_DATA .. "*")
    for i, v in ipairs(keyList) do
        local info = gg.redisProxy:call("hgetall",v) or {}
        local decodeInfo = _decodeStarmapMatchUnionInfo(info)
        ret[decodeInfo.unionId] = decodeInfo
    end
    return ret
end
-----------------------------------------------------------------
function api.setStarmapMatchUnionRankInfo(unionId, infoDict)
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_RANK .. unionId
    for k,v in pairs(infoDict) do
        gg.redisProxy:send("hset",keyName, k, v)
    end
end

function api.getStarmapMatchUnionRankField(unionId, field, defaultValue)
    if not unionId then
        return defaultValue
    end
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_RANK .. unionId
    return tonumber( gg.redisProxy:call("hget",keyName, field) or defaultValue )
end

function api.getStarmapMatchUnionRankInfo(unionId)
    local ret = {}
    if not unionId then
        return ret
    end
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_RANK .. unionId
    local info = gg.redisProxy:call("hgetall",keyName) or {}
    for i = 1, #info, 2 do
        ret[info[i]] = info[i+1]
    end
    return ret
end

function api.removeStarmapMatchUnionRankField(unionId, field)
    if not unionId then
        return
    end
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_RANK .. unionId
    return gg.redisProxy:call("hdel",keyName, field)
end

function api.delStarmapMatchUnionRankInfo(unionId)
    if not unionId then
        return
    end
    local keyName = constant.REDIS_STARMAP_MATCH_UNION_RANK .. unionId
    return gg.redisProxy:call("del",keyName)
end
-----------------------------------------------------------------
function api.setStarmapPrivateGridsResInfo(pid, infoDict)
    local keyName = constant.REDIS_STARMAP_PRIVATE_GRIDS_RES .. pid
    for k,v in pairs(infoDict) do
        gg.redisProxy:send("hset", keyName, k, v)
    end
end

function api.incrbyStarmapPrivateGridsResInfo(pid, infoDict)
    local keyName = constant.REDIS_STARMAP_PRIVATE_GRIDS_RES .. pid
    for k,v in pairs(infoDict) do
        gg.redisProxy:send("hincrby", keyName, k, v)
    end
end

function api.getStarmapPrivateGridsResField(pid, field, defaultValue)
    local keyName = constant.REDIS_STARMAP_PRIVATE_GRIDS_RES .. pid
    return gg.redisProxy:call("hget", keyName, field) or defaultValue
end

function api.getStarmapPrivateGridsResInfo(pid)
    local ret = {}
    local keyName = constant.REDIS_STARMAP_PRIVATE_GRIDS_RES .. pid
    local info = gg.redisProxy:call("hgetall", keyName) or {}
    for i = 1, #info, 2 do
        ret[info[i]] = info[i+1]
    end
    return ret
end

function api.removeStarmapPrivateGridsResField(pid, field)
    local keyName = constant.REDIS_STARMAP_PRIVATE_GRIDS_RES .. pid
    return gg.redisProxy:call("hdel", keyName, field)
end

function api.delStarmapPrivateGridsResInfo(pid)
    local keyName = constant.REDIS_STARMAP_PRIVATE_GRIDS_RES .. pid
    return gg.redisProxy:call("del", keyName)
end
----------------------------------------------------------------------------
function api.setStarmapMatchJackpot(data)
    local keyName = constant.REDIS_STARMAP_JACKPOT_INFO
    local info
    -- local db = gg.mongoProxy.redisdb
    local value = gg.redisProxy:call("get",keyName)
    if not value or value == "" then
        value = {
            sysCarboxyl = data.sysCarboxyl or 0,
            plyCarboxyl = data.plyCarboxyl or 0,
        }
        info = cjson.encode(value)
    else
        info = cjson.decode(value)
        info.sysCarboxyl = info.sysCarboxyl + (data.sysCarboxyl or 0)
        info.plyCarboxyl = info.plyCarboxyl + (data.plyCarboxyl or 0)
        info = cjson.encode(info)
    end
    gg.redisProxy:call("set", keyName, info)
end

return api