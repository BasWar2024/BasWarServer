local Rank = class("Rank")

--""game"","",""redis
function Rank:ctor()
    self.badgeRankTemp = nil               --""
    self.badgeRankVersion = nil            --""

    self.matchBadgeRankTemp = nil          --pvp""
    self.matchBadgeRankVersion = nil       --pvp""

    self.costMitRankTemp = nil             --mit""
    self.costMitRankVersion = nil          --mit""

    self.planetRankTemp = nil              --""
    self.planetRankVersion = nil           --""

end

function Rank:_getTypeNewRank(rankKey)
    local script = [[
        local REDIS_RANK_KEY = KEYS[1]
        local REDIS_PLAYER_BASE_INFO = KEYS[2]
        local from = ARGV[1]
        local to = ARGV[2]
        local ret = {}
        local rankList = {}
        local rangeRank = redis.call('ZREVRANGE', REDIS_RANK_KEY, from, to, 'WITHSCORES')
        for i = 1, #rangeRank, 2 do
            local temp = {}
            temp.pid = tonumber(rangeRank[i])
            temp.score = tonumber(rangeRank[i+1])
            table.insert(rankList, temp)
        end
        for i = 1, #rankList, 1 do
            local values = redis.call('HMGET', REDIS_PLAYER_BASE_INFO..rankList[i].pid, 'name', 'headIcon', 'unionName')
            if values and #values > 0 then
                rankList[i].name = values[1] or ''
                rankList[i].headIcon = values[2] or ''
                rankList[i].unionName = values[3] or ''

                table.insert(ret, rankList[i].pid)
                table.insert(ret, rankList[i].score)
                table.insert(ret, values[1] or '')
                table.insert(ret, values[2] or '')
                table.insert(ret, values[3] or '')
            end
        end
        return ret
    ]]

    local ret = gg.execRedisScript(script, 2, rankKey, constant.REDIS_PLAYER_BASE_INFO, 0, 99)
    local rankList = {}
    if ret and #ret > 0 then
        for i=1, #ret, 5 do
            table.insert(rankList, { 
                pid = ret[i],
                score = ret[i+1],
                name = ret[i+2],
                headIcon = ret[i+3],
                unionName = ret[i+4],
            })
        end
    end
    return rankList
end

function Rank:_getTypeSelfRank(rankKey, pid)
    local script = [[
        local REDIS_RANK_KEY = KEYS[1]
        local REDIS_PLAYER_BASE_INFO = KEYS[2]
        local pid = ARGV[1]
        local ret = {}
        local rankIdx = redis.call('ZREVRANK', REDIS_RANK_KEY, pid)
        local score = redis.call('ZSCORE', REDIS_RANK_KEY, pid)
        local values = redis.call('HMGET', REDIS_PLAYER_BASE_INFO..pid, 'name', 'headIcon', 'unionName')
        if values and #values > 0 then
            table.insert(ret, tonumber(rankIdx or -1))
            table.insert(ret, tonumber(pid))
            table.insert(ret, tonumber(score or 0))
            table.insert(ret, values[1] or '')
            table.insert(ret, values[2] or '')
            table.insert(ret, values[3] or '')
        end
        return ret
    ]]

    local ret = gg.execRedisScript(script, 2, rankKey, constant.REDIS_PLAYER_BASE_INFO, pid)
    local selfRank = {}
    if ret and #ret > 0 then
        selfRank = {
            rankIdx = ret[1],
            pid = ret[2],
            score = ret[3],
            name = ret[4],
            headIcon = ret[5],
            unionName = ret[6],
        }
    end
    return selfRank
end

function Rank:_refreshTypeRank(key)
    local refreshCfg = constant.RANK_TYPE_REFRESH_CFG[key]
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
    --self[refreshCfg.rankVersion] = nil
end

--""
function Rank:refreshRank()
    for k, v in pairs(constant.RANK_REFRESH_RANK_KEY) do
        self:_refreshTypeRank(k)
    end
end

function Rank:checkUpDown(newRank, oldRank)
    for k, v in ipairs(newRank) do
        v.upDown = 999
        for kk, vv in ipairs(oldRank) do
            if v.pid == vv.pid then
                v.upDown = kk - k
                break
            end
        end
    end
end

-- function Rank:getPlayerName(pid)
--     local keyName = constant.REDIS_PLAYER_BASE_INFO .. pid
--     return gg.redisProxy:call("hget", keyName, "name")
-- end

-- function Rank:getPlayerHeadIcon(pid)
--     local keyName = constant.REDIS_PLAYER_BASE_INFO .. pid
--     return gg.redisProxy:call("hget", keyName, "headIcon")
-- end

function Rank:_syncInfo(rankKey, pid, value)
    if gg.isGmRobotPlayer(pid) then
        return
    end
    gg.redisProxy:send("zadd",rankKey, value, pid)
end

function Rank:_increInfo(rankKey, pid, value)
    if gg.isGmRobotPlayer(pid) then
        return
    end
    gg.redisProxy:send("zincrby",rankKey, value, pid)
end

function Rank:_getAward(rankKey, rank)
    if rankKey == constant.REDIS_RANK_BADGE then
        return (100 - rank + 1) * 1
    elseif rankKey == constant.REDIS_RANK_COST_MIT then
        return (300 - rank + 1) * 1
    elseif rankKey == constant.REDIS_RANK_PLANET then
        return (200 - rank + 1) * 1
    else
        return 0
    end
end

function Rank:_getRankList(rankKey, pid, version)
    local refreshCfg = constant.RANK_TYPE_REFRESH_CFG[rankKey]
    local curKey = refreshCfg.curKey
    local dataKey = refreshCfg.dataKey
    local rankType = refreshCfg.rankType
    if not self[refreshCfg.rankTemp] then
        --""redis""
        self[refreshCfg.rankTemp] = {}
        --self[refreshCfg.rankVersion] = math.floor(skynet.timestamp() / 1000)
        local rankCurText = gg.redisProxy:call("get",curKey)
        if rankCurText and rankCurText ~= "" then
            self[refreshCfg.rankTemp] = cjson.decode(rankCurText)
            for k,v in ipairs(self[refreshCfg.rankTemp]) do
                v.award = self:_getAward(rankKey, k)
            end
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

        if v.pid == pid then
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

    if not data.selfRank then
        local myRank = self:_getTypeSelfRank(rankKey, pid)
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

function Rank:syncBadgeInfo(pid, badge)
    self:_syncInfo(constant.REDIS_RANK_BADGE, pid, badge)
end

function Rank:getBadgeRank(pid, version)
    return self:_getRankList(constant.REDIS_RANK_BADGE, pid, version)
end

function Rank:syncPvpMatchBadgeInfo(pid, badge)
    self:_syncInfo(constant.REDIS_MATCH_RANK_BADGE, pid, badge)
end

function Rank:increPvpMatchBadgeInfo(pid, badge)
    if badge < 0 then
        local myRank = self:_getTypeSelfRank(constant.REDIS_MATCH_RANK_BADGE, pid)
        if myRank.score == 0 then
            return
        end
    end
    self:_increInfo(constant.REDIS_MATCH_RANK_BADGE, pid, badge)
end

function Rank:getPvpMatchBadgeRank(pid, version)
    return self:_getRankList(constant.REDIS_MATCH_RANK_BADGE, pid, version)
end

function Rank:syncCostMitInfo(pid, costMit)
    self:_syncInfo(constant.REDIS_RANK_COST_MIT, pid, costMit)
end

function Rank:getCostMitRank(pid, version)
    return self:_getRankList(constant.REDIS_RANK_COST_MIT, pid, version)
end

function Rank:syncPlanetInfo(pid, count)
    self:_syncInfo(constant.REDIS_RANK_PLANET, pid, count)
end

function Rank:getPlanetRank(pid, version)
    return self:_getRankList(constant.REDIS_RANK_PLANET, pid, version)
end

function Rank:getRealBadgeRank()
    local rankList = self:_getTypeNewRank(constant.REDIS_RANK_BADGE)
    return rankList
end

function Rank:getSelfRank(rankKey, pid)
    local data = self:_getRankList(rankKey, pid, 0)
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

function Rank:delRank(rankKey)
    gg.redisProxy:send("del",rankKey)
    local refreshCfg = constant.RANK_TYPE_REFRESH_CFG[rankKey]
    local curKey = refreshCfg.curKey
    gg.redisProxy:send("del",curKey)
    return true
end

function Rank:getDifferentRank(redisRankKey, pid, version)
    return self:_getRankList(redisRankKey, pid, version)
end

function Rank:syncDifferentRankVal(redisRankKey, pid, val)
    self:_syncInfo(redisRankKey, pid, val)
end

function Rank:increDifferentRankVal(redisRankKey, pid, val)
    self:_increInfo(redisRankKey, pid, val)
end

return Rank