local UnionRank = class("UnionRank")

function UnionRank:ctor()
end

function UnionRank:_getUnionInfo(unionId)
    local ret = {}
    local unionBase = gg.unionProxy:call("getUnionBase", unionId)
    if unionBase then
        ret = {
            name = unionBase.unionName,
            headIcon = unionBase.unionFlag,
            unionName = unionBase.unionName,
        }
    end
    return ret
end

function UnionRank:_getTypeNewRank(rankKey)
    local script = [[
        local REDIS_RANK_KEY = KEYS[1]
        local from = ARGV[1]
        local to = ARGV[2]
        local rangeRank = redis.call('ZREVRANGE', REDIS_RANK_KEY, from, to, 'WITHSCORES')
        return rangeRank
    ]]

    local ret = gg.execRedisScript(script, 1, rankKey, 0, 99)
    local rankList = {}
    if ret and #ret > 0 then
        for i=1, #ret, 2 do
            local unionId = tonumber(ret[i])
            local info = self:_getUnionInfo(unionId)
            table.insert(rankList, {
                unionId = unionId,
                score = tonumber(ret[i+1]),
                name = info.name or "",
                headIcon = tostring(info.headIcon or ""),
                unionName = info.unionName or "",
            })
        end
    end
    return rankList
end

function UnionRank:_getTypeSelfRank(rankKey, unionId)
    local script = [[
        local REDIS_RANK_KEY = KEYS[1]
        local unionId = ARGV[1]
        local ret = {}
        local rankIdx = redis.call('ZREVRANK', REDIS_RANK_KEY, unionId)
        local score = redis.call('ZSCORE', REDIS_RANK_KEY, unionId)
        table.insert(ret, tonumber(rankIdx or -1))
        table.insert(ret, tonumber(unionId))
        table.insert(ret, tonumber(score or 0))
        return ret
    ]]

    local ret = gg.execRedisScript(script, 1, rankKey, unionId)
    local selfRank = {}
    if ret and #ret > 0 then
        local unionId = ret[2]
        local info = self:_getUnionInfo(unionId)
        selfRank = {
            rankIdx = ret[1],
            unionId = unionId,
            score = ret[3],
            name = info.name or "",
            headIcon = tostring(info.headIcon or ""),
            unionName = info.unionName or "",
        }
    end
    return selfRank
end

function UnionRank:_refreshTypeRank(key)
    local refreshCfg = constant.RANK_TYPE_UNION_REFRESH[key]
    local curKey = refreshCfg.curKey
    local dataKey = refreshCfg.dataKey
    local rankNew = self:_getTypeNewRank(key)
    local rankCur = {}
    local rankCurText = gg.redisProxy:call("get", curKey)
    if rankCurText and rankCurText ~= "" then
        rankCur = cjson.decode(rankCurText)
    end
    self:checkUpDown(rankNew, rankCur)
    gg.redisProxy:send("set", curKey, cjson.encode(rankNew))
    self[refreshCfg.rankTemp] = nil
    -- self[refreshCfg.rankVersion] = nil
end

--""
function UnionRank:refreshRank()
    for k, v in pairs(constant.RANK_REFRESH_UNION_RANK_KEY) do
        self:_refreshTypeRank(k)
    end
end

function UnionRank:checkUpDown(newRank, oldRank)
    for k, v in ipairs(newRank) do
        v.upDown = 999
        for kk, vv in ipairs(oldRank) do
            if v.unionId == vv.unionId then
                v.upDown = kk - k
                break
            end
        end
    end
end

function UnionRank:_syncInfo(rankKey, unionId, value)
    gg.redisProxy:send("zadd",rankKey, value, unionId)
end

function UnionRank:_increInfo(rankKey, unionId, value)
    gg.redisProxy:send("zincrby",rankKey, value, unionId)
end

function UnionRank:_getRankList(rankKey, unionId, version)
    local refreshCfg = constant.RANK_TYPE_UNION_REFRESH[rankKey]
    local curKey = refreshCfg.curKey
    local dataKey = refreshCfg.dataKey
    local rankType = refreshCfg.rankType
    if not self[refreshCfg.rankTemp] then
        --""redis""
        self[refreshCfg.rankTemp] = {}
        -- self[refreshCfg.rankVersion] = math.floor(skynet.timestamp() / 1000)
        local rankCurText = gg.redisProxy:call("get",curKey)
        if rankCurText and rankCurText ~= "" then
            self[refreshCfg.rankTemp] = cjson.decode(rankCurText)
        end
        self[refreshCfg.rankVersion] = math.floor(skynet.timestamp() / 1000)
    end
    if version > 0 and version == self[refreshCfg.rankVersion] then
        return nil
    end
    local data = {}
    data.rankType = rankType
    data.version = self[refreshCfg.rankVersion]
    data.rank = {}
    for k,v in ipairs(self[refreshCfg.rankTemp]) do
        local temp = {}
        temp.index = k
        temp.name = v.name
        temp.value = v.score
        temp.upDown = v.upDown
        temp.award = v.award
        temp.headIcon = v.headIcon
        table.insert(data.rank, temp)

        if v.unionId == unionId then
            data.selfRank = {
                index = k,
                name = v.name,
                value = v.score,
                upDown = v.upDown,
                award = v.award,
                headIcon = v.headIcon,
            }
        end
    end

    if not data.selfRank and unionId then
        local myRank = self:_getTypeSelfRank(rankKey, unionId)
        data.selfRank = {
            index = (myRank.rankIdx or -1) + 1,
            name = myRank.name,
            value = myRank.score,
            upDown = 0,
            award = 0,
            headIcon = myRank.headIcon,
        }
    end
    return data
end

function UnionRank:getSelfRank(rankKey, unionId)
    local data = self:_getRankList(rankKey, unionId, 0)
    local ret = {
        index = 0,
        score = 0,
    }
    if data.selfRank then
        ret.index = data.selfRank.index
        ret.score = data.selfRank.value
    end
    return ret
end

function UnionRank:delRank(rankKey)
    gg.redisProxy:send("del",rankKey)
    local refreshCfg = constant.RANK_TYPE_UNION_REFRESH[rankKey]
    local curKey = refreshCfg.curKey
    gg.redisProxy:send("del",curKey)
    return true
end

function UnionRank:getDifferentRank(redisRankKey, unionId, version)
    return self:_getRankList(redisRankKey, unionId, version)
end

function UnionRank:syncDifferentRankVal(redisRankKey, unionId, val)
    self:_syncInfo(redisRankKey, unionId, val)
end

function UnionRank:increDifferentRankVal(redisRankKey, unionId, val)
    self:_increInfo(redisRankKey, unionId, val)
end


return UnionRank