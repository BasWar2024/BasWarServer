local api = gg.api

function api.setPvpMatchJackpot(data)
    local keyName = constant.REDIS_PVP_JACKPOT_INFO
    local info
    local db = gg.mongoProxy.redisdb
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

local function getPvpMatchSettlementDebug(matchData)
    local db = gg.mongoProxy.redisdb
    local REDIS_RANK_KEY = constant.REDIS_MATCH_RANK_BADGE
    local REDIS_PVP_JACKPOT_INFO = constant.REDIS_PVP_JACKPOT_INFO
    local REDIS_PVP_JACKPOT_SHARE_RATIO = constant.REDIS_PVP_JACKPOT_SHARE_RATIO
    local REDIS_PVP_STAGE_RATIO = constant.REDIS_PVP_STAGE_RATIO
    local REDIS_PVP_RANK_MIT_REWARD = constant.REDIS_PVP_RANK_MIT_REWARD
    local REDIS_PVP_MATCH_REWARD = constant.REDIS_PVP_MATCH_REWARD

    local from = 0
    local to = 99
    local season = matchData.season
    local rankTime = matchData.rankTime
    local rewardTime = matchData.rewardTime
    local rankList = {}
    local rangeRank = gg.redisProxy:call("zrevrangebyscore", REDIS_RANK_KEY, '+inf', '-inf', 'WITHSCORES')
    for i = 1, #rangeRank, 2 do
        local temp = {}
        temp.pid = tonumber(rangeRank[i])
        temp.score = tonumber(rangeRank[i+1])
        table.insert(rankList, temp)
    end

    local jackpotInfo = gg.redisProxy:call("get", REDIS_PVP_JACKPOT_INFO)
    local jackpot = cjson.decode(jackpotInfo)
    local carboxyl = jackpot.sysCarboxyl + jackpot.plyCarboxyl
    local jackpotShareRatio = gg.redisProxy:call("get", REDIS_PVP_JACKPOT_SHARE_RATIO)
    local shareRatio = tonumber(jackpotShareRatio)
    local stageRatioInfo = gg.redisProxy:call("get", REDIS_PVP_STAGE_RATIO)
    local stageRatio = cjson.decode(stageRatioInfo)
    local rankMitReward = gg.redisProxy:call("get", REDIS_PVP_RANK_MIT_REWARD)
    local rankMitCfg = cjson.decode(rankMitReward)

    local stageData = {}
    local plyStage = 0
    local plyRatio = 0
    local minScore
    local maxScore
    for i = 1, #stageRatio, 1 do
        local psr = stageRatio[i]
        local scoreList = psr.score
        minScore = tonumber(scoreList[1])
        maxScore = tonumber(scoreList[#scoreList])
        local rangeCount = gg.redisProxy:call("zcount", REDIS_RANK_KEY, minScore, maxScore)
        stageData[i] = {
            plyStage = tonumber(psr.stage),
            plyStageStr = psr.name,
            plyRatio = tonumber(psr.ratio),
            minScore = minScore,
            maxScore = maxScore,
            rangeCount = rangeCount,
        }
    end
    for i = 1, #rankList, 1 do
        local rdata = rankList[i]
        for j = 1, #stageData, 1 do
            local sd = stageData[j]
            if rdata.score >= sd.minScore and rdata.score <= sd.maxScore then
                local reward = math.floor((carboxyl * shareRatio * sd.plyRatio) / sd.rangeCount)
                rdata.carboxyl = reward
                rdata.stage = sd.plyStage
                rdata.stageName = sd.plyStageStr
            end
        end
        rdata.carboxyl = rdata.carboxyl or 0
    end

    jackpot.sysCarboxyl = math.floor(jackpot.sysCarboxyl * (1 - shareRatio))
    jackpot.plyCarboxyl = math.floor(jackpot.plyCarboxyl * (1 - shareRatio))
    jackpotInfo = cjson.encode(jackpot)
    gg.redisProxy:call("set", REDIS_PVP_JACKPOT_INFO, jackpotInfo)

    for i = 1, #rankList, 1 do
        local rdata = rankList[i]
        if rdata.score == 0 then
            rdata.mit = 0
        else
            for j = 1, #rankMitCfg, 1 do
                local rmcfg = rankMitCfg[j]
                if i >= rmcfg.min_rank and i <= rmcfg.max_rank then
                    rdata.mit = tonumber(rmcfg.mit)
                end
            end
        end
        rdata.mit = rdata.mit or 0
    end

    local ret = {}
    for i = 1, #rankList, 1 do
        table.insert(ret, rankList[i].pid)
        table.insert(ret, rankList[i].score)
        table.insert(ret, rankList[i].carboxyl)
        table.insert(ret, rankList[i].mit)
        table.insert(ret, rankList[i].stageName or '')
        if rankList[i].score > 0 then
            local keyName = REDIS_PVP_MATCH_REWARD .. rankList[i].pid
            gg.redisProxy:call("hset", keyName, 'season', season)
            gg.redisProxy:call("hset", keyName, 'rankTime', rankTime)
            gg.redisProxy:call("hset", keyName, 'rewardTime', rewardTime)
            gg.redisProxy:call("hset", keyName, 'rank', i)
            gg.redisProxy:call("hset", keyName, 'score', rankList[i].score)
            gg.redisProxy:call("hset", keyName, 'carboxyl', rankList[i].carboxyl)
            gg.redisProxy:call("hset", keyName, 'mit', rankList[i].mit)
            gg.redisProxy:call("hset", keyName, 'stage', rankList[i].stage or 0)
            gg.redisProxy:call("hset", keyName, 'stageName', rankList[i].stageName or '')
        end
    end
    return ret
end

function api.getPvpMatchSettlement(matchData)
    -- "" = （"" * "" * "" ）/ ""
    local script = [[
        local REDIS_RANK_KEY = KEYS[1]
        local REDIS_PVP_JACKPOT_INFO = KEYS[2]
        local REDIS_PVP_JACKPOT_SHARE_RATIO = KEYS[3]
        local REDIS_PVP_STAGE_RATIO = KEYS[4]
        local REDIS_PVP_RANK_MIT_REWARD = KEYS[5]
        local REDIS_PVP_MATCH_REWARD = KEYS[6]

        local from = ARGV[1]
        local to = ARGV[2]
        local season = tonumber(ARGV[3])
        local rankTime = tonumber(ARGV[4])
        local rewardTime = tonumber(ARGV[5])
        local rankList = {}
        local rangeRank = redis.call('ZREVRANGEBYSCORE', REDIS_RANK_KEY, '+inf', '-inf', 'WITHSCORES')
        for i = 1, #rangeRank, 2 do
            local temp = {}
            temp.pid = tonumber(rangeRank[i])
            temp.score = tonumber(rangeRank[i+1])
            table.insert(rankList, temp)
        end

        local jackpotInfo = redis.call('GET', REDIS_PVP_JACKPOT_INFO)
        local jackpot = cjson.decode(jackpotInfo)
        local carboxyl = jackpot.sysCarboxyl + jackpot.plyCarboxyl
        local jackpotShareRatio = redis.call('GET', REDIS_PVP_JACKPOT_SHARE_RATIO)
        local shareRatio = tonumber(jackpotShareRatio)
        local stageRatioInfo = redis.call('GET', REDIS_PVP_STAGE_RATIO)
        local stageRatio = cjson.decode(stageRatioInfo)
        local rankMitReward = redis.call('GET', REDIS_PVP_RANK_MIT_REWARD)
        local rankMitCfg = cjson.decode(rankMitReward)

        local stageData = {}
        local plyStage = 0
        local plyRatio = 0
        local minScore
        local maxScore
        for i = 1, #stageRatio, 1 do
            local psr = stageRatio[i]
            local scoreList = psr.score
            minScore = tonumber(scoreList[1])
            maxScore = tonumber(scoreList[#scoreList])
            local rangeCount = redis.call('ZCOUNT', REDIS_RANK_KEY, minScore, maxScore)
            stageData[i] = {
                plyStage = tonumber(psr.stage),
                plyStageStr = psr.name,
                plyRatio = tonumber(psr.ratio),
                minScore = minScore,
                maxScore = maxScore,
                rangeCount = rangeCount,
            }
        end

        for i = 1, #rankList, 1 do
            local rdata = rankList[i]
            for j = 1, #stageData, 1 do
                local sd = stageData[j]
                if rdata.score >= sd.minScore and rdata.score <= sd.maxScore then
                    local reward = math.floor((carboxyl * shareRatio * sd.plyRatio) / sd.rangeCount)
                    rdata.carboxyl = reward
                    rdata.stage = sd.plyStage
                    rdata.stageName = sd.plyStageStr
                end
            end
            rdata.carboxyl = rdata.carboxyl or 0
        end

        jackpot.sysCarboxyl = math.floor(jackpot.sysCarboxyl * (1 - shareRatio))
        jackpot.plyCarboxyl = math.floor(jackpot.plyCarboxyl * (1 - shareRatio))
        jackpotInfo = cjson.encode(jackpot)
        redis.call('SET', REDIS_PVP_JACKPOT_INFO, jackpotInfo)

        for i = 1, #rankList, 1 do
            local rdata = rankList[i]
            if rdata.score == 0 then
                rdata.mit = 0
            else
                for j = 1, #rankMitCfg, 1 do
                    local rmcfg = rankMitCfg[j]
                    if i >= rmcfg.min_rank and i <= rmcfg.max_rank then
                        rdata.mit = tonumber(rmcfg.mit)
                    end
                end
            end
            rdata.mit = rdata.mit or 0
        end

        local ret = {}
        for i = 1, #rankList, 1 do
            table.insert(ret, rankList[i].pid)
            table.insert(ret, rankList[i].score)
            table.insert(ret, rankList[i].carboxyl)
            table.insert(ret, rankList[i].mit)
            table.insert(ret, rankList[i].stageName or '')
            if rankList[i].score > 0 then
                local keyName = REDIS_PVP_MATCH_REWARD .. rankList[i].pid
                redis.call('HSET', keyName, 'season', season)
                redis.call('HSET', keyName, 'rankTime', rankTime)
                redis.call('HSET', keyName, 'rewardTime', rewardTime)
                redis.call('HSET', keyName, 'rank', i)
                redis.call('HSET', keyName, 'score', rankList[i].score)
                redis.call('HSET', keyName, 'carboxyl', rankList[i].carboxyl)
                redis.call('HSET', keyName, 'mit', rankList[i].mit)
                redis.call('HSET', keyName, 'stage', rankList[i].stage or 0)
                redis.call('HSET', keyName, 'stageName', rankList[i].stageName or '')
            end
        end
        return ret
    ]]

    local ret = gg.execRedisScript(
        script,
        6,
        constant.REDIS_MATCH_RANK_BADGE,
        constant.REDIS_PVP_JACKPOT_INFO,
        constant.REDIS_PVP_JACKPOT_SHARE_RATIO,
        constant.REDIS_PVP_STAGE_RATIO,
        constant.REDIS_PVP_RANK_MIT_REWARD,
        constant.REDIS_PVP_MATCH_REWARD,
        0,
        99,
        matchData.season,
        matchData.rankTime,
        matchData.rewardTime or 0
    )
    -- local ret = getPvpMatchSettlementDebug(matchData)
    local settlementList = {}
    if ret and #ret > 0 then
        for i=1, #ret, 5 do
            table.insert(settlementList, {
                pid = ret[i],
                score = ret[i+1],
                carboxyl = ret[i+2],
                mit = ret[i+3],
                stageName = ret[i+4],
            })
        end
    end
    return settlementList
end

local function getPvpMatchRankListDebug(from, to)
    local db = gg.mongoProxy.redisdb
    local REDIS_RANK_KEY = constant.REDIS_MATCH_RANK_BADGE

    local rankList = {}
    local rangeRank = gg.redisProxy:call("zrevrange", REDIS_RANK_KEY, from, to, 'WITHSCORES')
    for i = 1, #rangeRank, 2 do
        local temp = {}
        temp.pid = tonumber(rangeRank[i])
        temp.score = tonumber(rangeRank[i+1])
        table.insert(rankList, temp)
    end

    local ret = {}
    for i = 1, #rankList, 1 do
        table.insert(ret, rankList[i].pid)
        table.insert(ret, rankList[i].score)
    end
    return ret
end

function api.getPvpMatchRankList(from, to)
    local script = [[
        local REDIS_RANK_KEY = KEYS[1]
        local from = ARGV[1]
        local to = ARGV[2]
        local rankList = {}
        local rangeRank = redis.call('ZREVRANGE', REDIS_RANK_KEY, from, to, 'WITHSCORES')
        for i = 1, #rangeRank, 2 do
            local temp = {}
            temp.pid = tonumber(rangeRank[i])
            temp.score = tonumber(rangeRank[i+1])
            table.insert(rankList, temp)
        end

        local ret = {}
        for i = 1, #rankList, 1 do
            table.insert(ret, rankList[i].pid)
            table.insert(ret, rankList[i].score)
        end
        return ret
    ]]

    local ret = gg.execRedisScript(
        script,
        1,
        constant.REDIS_MATCH_RANK_BADGE,
        from,
        to
    )
    -- local ret = getPvpMatchRankListDebug(from, to)
    local settlementList = {}
    if ret and #ret > 0 then
        for i=1, #ret, 2 do
            table.insert(settlementList, {
                pid = ret[i],
                score = ret[i+1],
            })
        end
    end
    return settlementList
end

local function getPvpMatchInfoTest(pid, armyPlayerList)
    local db = gg.mongoProxy.redisdb
    local REDIS_RANK_KEY = constant.REDIS_MATCH_RANK_BADGE
    local REDIS_PVP_JACKPOT_INFO = constant.REDIS_PVP_JACKPOT_INFO
    local REDIS_PVP_JACKPOT_SHARE_RATIO = constant.REDIS_PVP_JACKPOT_SHARE_RATIO
    local REDIS_PVP_STAGE_RATIO = constant.REDIS_PVP_STAGE_RATIO
    local REDIS_PLAYER_BASE_INFO = constant.REDIS_PLAYER_BASE_INFO
    local PID = pid
    local inPlayerList = armyPlayerList

    local retInfo = {}
    local jackpotInfo = gg.redisProxy:call("get", REDIS_PVP_JACKPOT_INFO)
    local jackpot = cjson.decode(jackpotInfo)
    local carboxyl = jackpot.sysCarboxyl + jackpot.plyCarboxyl
    local scoreS = gg.redisProxy:call("zscore", REDIS_RANK_KEY, PID)
    local score = tonumber(scoreS)
    local reward = 0
    if not score then
        reward = 0
    else
        local jackpotShareRatio = gg.redisProxy:call("get", REDIS_PVP_JACKPOT_SHARE_RATIO)
        local shareRatio = tonumber(jackpotShareRatio)
        local stageRatioInfo = gg.redisProxy:call("get", REDIS_PVP_STAGE_RATIO)
        local stageRatio = cjson.decode(stageRatioInfo)

        local plyStage = 0
        local plyRatio = 0
        local minScore
        local maxScore
        for i = 1, #stageRatio, 1 do
            local psr = stageRatio[i]
            local scoreList = psr.score
            if score >= tonumber(scoreList[1]) and score <= tonumber(scoreList[#scoreList]) then
                plyStage = tonumber(psr.stage)
                plyRatio = tonumber(psr.ratio)
                minScore = tonumber(scoreList[1])
                maxScore = tonumber(scoreList[#scoreList])
                break
            end
        end
        if plyStage == 0 then
            reward = 0
        else
            local rangeCount = gg.redisProxy:call("zcount", REDIS_RANK_KEY, minScore, maxScore)
            if rangeCount == 0 then
                rangeCount = 1
            end
            reward = math.floor((carboxyl * shareRatio * plyRatio) / rangeCount)
        end
    end
    table.insert(retInfo, carboxyl)
    table.insert(retInfo, reward)

    local sysTime = gg.redisProxy:call("time")
    local now = tonumber(sysTime[1])
    local playerDict = {}
    for i, _pid in ipairs(inPlayerList) do
        local _scoreS = gg.redisProxy:call("zscore", REDIS_RANK_KEY, _pid)
        local _score = tonumber(scoreS) or 0
        local plyId = tonumber(_pid)
        local values = gg.redisProxy:call("hmget",
            REDIS_PLAYER_BASE_INFO.._pid,
            'name',
            'level',
            'protectTick',
            'headIcon',
            'unionName',
            'createTime'
        )
        if values and #values > 0 then
            local protectTick = tonumber(values[3]) or 0
            if now >= protectTick then
                table.insert(playerDict, {
                    playerId = plyId,
                    playerScore = _score,
                    playerName = values[1] or '',
                    playerLevel = tonumber(values[2]) or 0,
                    protectTick = tonumber(values[3]) or 0,
                    playerHead = values[4] or '',
                    unionName  = values[5] or '',
                    diffTick = now - (tonumber(values[3]) or 0),
                    diffScore = math.abs((score or 0)-_score),
                    canAttack = true,
                })
            end
        end
    end
    local playerDictJson = cjson.encode(playerDict)
    table.insert(retInfo, playerDictJson)
    return retInfo
end

function api.getPvpMatchInfo(pid, armyPlayerList)
    -- "" = （"" * "" * "" ）/ ""
    local script = [[
        local REDIS_RANK_KEY = KEYS[1]
        local REDIS_PVP_JACKPOT_INFO = KEYS[2]
        local REDIS_PVP_JACKPOT_SHARE_RATIO = KEYS[3]
        local REDIS_PVP_STAGE_RATIO = KEYS[4]
        local REDIS_PLAYER_BASE_INFO = KEYS[5]

        local PID = ARGV[1]
        local inPlayerList = cjson.decode(ARGV[2])

        local retInfo = {}
        local jackpotInfo = redis.call('GET', REDIS_PVP_JACKPOT_INFO)
        local jackpot = cjson.decode(jackpotInfo)
        local carboxyl = jackpot.sysCarboxyl + jackpot.plyCarboxyl
        local scoreS = redis.call('ZSCORE',REDIS_RANK_KEY, PID)
        local score = tonumber(scoreS)
        local reward = 0
        if not score then
            reward = 0
        else
            local jackpotShareRatio = redis.call('GET', REDIS_PVP_JACKPOT_SHARE_RATIO)
            local shareRatio = tonumber(jackpotShareRatio)
            local stageRatioInfo = redis.call('GET', REDIS_PVP_STAGE_RATIO)
            local stageRatio = cjson.decode(stageRatioInfo)

            local plyStage = 0
            local plyRatio = 0
            local minScore
            local maxScore
            for i = 1, #stageRatio, 1 do
                local psr = stageRatio[i]
                local scoreList = psr.score
                if score >= tonumber(scoreList[1]) and score <= tonumber(scoreList[#scoreList]) then
                    plyStage = tonumber(psr.stage)
                    plyRatio = tonumber(psr.ratio)
                    minScore = tonumber(scoreList[1])
                    maxScore = tonumber(scoreList[#scoreList])
                    break
                end
            end
            if plyStage == 0 then
                reward = 0
            else
                local rangeCount = redis.call('ZCOUNT',REDIS_RANK_KEY, minScore, maxScore)
                if rangeCount == 0 then
                    rangeCount = 1
                end
                reward = math.floor((carboxyl * shareRatio * plyRatio) / rangeCount)
            end
        end
        table.insert(retInfo, carboxyl)
        table.insert(retInfo, reward)

        local sysTime = redis.call('TIME')
        local now = tonumber(sysTime[1])
        local playerDict = {}
        for i, _pid in ipairs(inPlayerList) do
            local _scoreS = redis.call('ZSCORE',REDIS_RANK_KEY, _pid)
            local _score = tonumber(scoreS) or 0
            local plyId = tonumber(_pid)
            local values = redis.call(
                'HMGET',
                REDIS_PLAYER_BASE_INFO.._pid,
                'name',
                'level',
                'protectTick',
                'headIcon',
                'unionName',
                'createTime'
            )
            if values and #values > 0 then
                local protectTick = tonumber(values[3]) or 0
                if now >= protectTick then
                    table.insert(playerDict, {
                        playerId = plyId,
                        playerScore = _score,
                        playerName = values[1] or '',
                        playerLevel = tonumber(values[2]) or 0,
                        protectTick = tonumber(values[3]) or 0,
                        playerHead = values[4] or '',
                        unionName  = values[5] or '',
                        diffTick = now - (tonumber(values[3]) or 0),
                        diffScore = math.abs((score or 0)-_score),
                        canAttack = true,
                    })
                end
            end
        end
        local playerDictJson = cjson.encode(playerDict)
        table.insert(retInfo, playerDictJson)
        return retInfo
    ]]

    local retInfo = gg.execRedisScript(
        script,
        5,
        constant.REDIS_MATCH_RANK_BADGE,
        constant.REDIS_PVP_JACKPOT_INFO,
        constant.REDIS_PVP_JACKPOT_SHARE_RATIO,
        constant.REDIS_PVP_STAGE_RATIO,
        constant.REDIS_PLAYER_BASE_INFO,
        pid,
        cjson.encode(armyPlayerList)
    )
    -- local retInfo = getPvpMatchInfoTest(pid, armyPlayerList)
    local ret = {
        jackpot = retInfo[1],
        reward = retInfo[2],
        playerList = cjson.decode(retInfo[3]),
    }
    return ret
end

function api.setPlayerPvpMatchReward(pid, infoDict)
    local keyName = constant.REDIS_PVP_MATCH_REWARD .. pid
    for k,v in pairs(infoDict) do
        gg.redisProxy:send("hset", keyName, k, v)
    end
end

function api.getPlayerPvpMatchReward(pid)
    local keyName = constant.REDIS_PVP_MATCH_REWARD .. pid
    return gg.redisProxy:call("hgetall", keyName)
end

function api.delPlayerPvpMatchReward(pid)
    local keyName = constant.REDIS_PVP_MATCH_REWARD .. pid
    return gg.redisProxy:call("del", keyName)
end

function api.getPlayerPvpMatchRewardKey(pid, key, defaultValue)
    local keyName = constant.REDIS_PVP_MATCH_REWARD .. pid
    return gg.redisProxy:call("hget", keyName, key) or defaultValue
end

function api.removePlayerPvpMatchRewardKey(pid, key)
    local keyName = constant.REDIS_PVP_MATCH_REWARD .. pid
    return gg.redisProxy:call("hdel", keyName, key)
end


local function searchPlayersByBadgeDebug(pid, score, randValue, scoreBoundary, searchCount, opArgs)
    local db = gg.mongoProxy.redisdb
    local result = {}
    local REDIS_RANK_BADGE = constant.REDIS_MATCH_RANK_BADGE -- MatchRankBadge
    local REDIS_PLAYER_BASE_INFO = constant.REDIS_PLAYER_BASE_INFO -- PlayerBaseInfo
    local PID = pid

    -- local score = tonumber(ARGV[1])
    local rand_value = math.random()
    local score_boundary = scoreBoundary
    local search_count = searchCount            -- ""
    local be_attack_lv = constant.PVP_BE_ATTACK_LV -- 0 pvp""
    local be_attack_sec = constant.PVP_BE_ATTACK_SEC  -- 0 pvp""
    local is_expand_scope = opArgs.expandScope  -- ""
    local max_scope = opArgs.maxScope           -- "" 1000
    local is_expand_lv = opArgs.expandLv        -- ""
    local max_lv = opArgs.maxLv                 -- ""
    local lv_boundary = opArgs.lvBoundary       -- ""
    if score == -1 then  -- ""
        score = gg.redisProxy:call("zscore", REDIS_RANK_BADGE, PID) -- MatchRankBadge
        if not score then
            return result
        end
    end
    local plylvValue = gg.redisProxy:call("hget",
        REDIS_PLAYER_BASE_INFO..PID,
        'level'
    )
    local playerLv = tonumber(plylvValue) or 1
    local boundMinLv = playerLv - lv_boundary
    local boundMaxLv = playerLv + lv_boundary
    local sysTime = gg.redisProxy:call("time")
    local now = tonumber(sysTime[1])
    local boundMinScore = score - score_boundary
    local boundMaxScore = score + score_boundary
    local rangeCount = gg.redisProxy:call("zcount", REDIS_RANK_BADGE, boundMinScore, boundMaxScore) -- ""
    local playerIds
    local poolList = {}
    local poolDict = {}
    local function do_select(is_filter_lv) -- is_filter_lv ""
        playerIds = gg.redisProxy:call("zrangebyscore", REDIS_RANK_BADGE, boundMinScore, boundMaxScore, 'WITHSCORES')
        for i=1, #playerIds, 2 do
            local plyId = tonumber(playerIds[i])
            if plyId ~= PID then
                local can_add = true
                local ptValue = gg.redisProxy:call("hget",
                    REDIS_PLAYER_BASE_INFO..playerIds[i],
                    'protectTick'
                )
                local lvValue = gg.redisProxy:call("hget",
                    REDIS_PLAYER_BASE_INFO..playerIds[i],
                    'level'
                )
                local plyLV = tonumber(lvValue) or 1
                local protectTick = tonumber(ptValue) or now
                if now < protectTick then   -- ""，""
                    rangeCount = rangeCount - 1
                    can_add = false
                else
                    if is_filter_lv then  -- ""，""
                        if plyLV > boundMaxLv or plyLV < boundMinLv then
                            if is_expand_lv == 1 then
                                lv_boundary = lv_boundary * 2
                                boundMinLv = playerLv - lv_boundary
                                boundMaxLv = playerLv + lv_boundary
                                if plyLV > boundMaxLv or plyLV < boundMinLv then
                                    rangeCount = rangeCount - 1
                                end
                            else
                                rangeCount = rangeCount - 1
                                can_add = false
                            end
                        end
                    end
                end
                if can_add then   -- ""
                    if not poolDict[plyId] then
                        table.insert(poolList, plyId)
                        poolDict[plyId] = {
                            pid = plyId,
                            score = tonumber(playerIds[i+1]),
                            level = plyLV,
                        }
                    end
                end
            end
        end
    end
    if rangeCount <= search_count then --  "" "" ""
        if is_expand_scope == 1 then   -- ""
            while(score_boundary < max_scope) do
                score_boundary = score_boundary * 2
                boundMinScore = score - score_boundary
                boundMaxScore = score + score_boundary
                rangeCount = gg.redisProxy:call("zcount", REDIS_RANK_BADGE, boundMinScore, boundMaxScore)
                if rangeCount >= search_count then
                    do_select(true)
                end
                if #poolList >= search_count then
                    break
                end
            end
        end
    else
        do_select(true)
    end
    if #poolList < search_count then
        rangeCount = gg.redisProxy:call("zcount", REDIS_RANK_BADGE, boundMinScore, boundMaxScore)
        do_select(false)
    end
    local selectList = {}
    local selectDict = {}
    local psize = #poolList
    if psize <= search_count then
        selectList = poolList
        selectDict = poolDict
    else
        local startIdx = math.floor(rand_value * psize)
        if psize - startIdx < search_count - 1 then
            startIdx = psize - search_count + 1
        end
        local endIdx = startIdx + search_count - 1
        if startIdx <= 0 then
            startIdx = 1
            endIdx = startIdx + search_count - 1
        end
        for i = startIdx, endIdx, 1 do
            local pid = poolList[i]
            if pid then
                table.insert(selectList, pid)
                selectDict[pid] = poolDict[pid]
            end
        end
    end
    for k, value in pairs(selectDict) do
        local values = gg.redisProxy:call("hmget",
            REDIS_PLAYER_BASE_INFO..value.pid,
            'name',
            'level',
            'protectTick',
            'headIcon',
            'unionName',
            'createTime'
        )
        if values and #values > 0 then
            local level = tonumber(values[2]) or 0
            local createTime = tonumber(values[6]) or now
            if level >= be_attack_lv or (now - createTime) >= be_attack_sec then -- "" "" "" ""
                table.insert(result, tonumber(value.pid))
                table.insert(result, tonumber(value.score))
                table.insert(result, values[1] or '')
                table.insert(result, tonumber(values[2]) or 0)
                table.insert(result, tonumber(values[3]) or 0)
                table.insert(result, values[4] or '')
                table.insert(result, values[5] or '')
            end
        end
    end
    return result
end

function api.searchPlayersByBadge(pid, score, scoreBoundary, searchCount, opArgs)
    local script = [[
        local result = {}
        local REDIS_RANK_BADGE = KEYS[1]
        local REDIS_PLAYER_BASE_INFO = KEYS[2]
        local PID = tonumber(KEYS[3])

        local score = tonumber(ARGV[1])
        local rand_value = tonumber(ARGV[2])
        local score_boundary = tonumber(ARGV[3])
        local search_count = tonumber(ARGV[4])
        local be_attack_lv = tonumber(ARGV[5])
        local be_attack_sec = tonumber(ARGV[6])
        local is_expand_scope = tonumber(ARGV[7])
        local max_scope = tonumber(ARGV[8])
        local exclude_pid = tonumber(ARGV[9])
        local is_expand_lv = tonumber(ARGV[10])
        local max_lv = tonumber(ARGV[11])
        local lv_boundary = tonumber(ARGV[12])

        if score == -1 then
            score = redis.call('ZSCORE', REDIS_RANK_BADGE, PID)
            if not score then
                return result
            end
        end

        local plylvValue = redis.call("HGET",
            REDIS_PLAYER_BASE_INFO..PID,
            'level'
        )
        local playerLv = tonumber(plylvValue) or 1
        local boundMinLv = playerLv - lv_boundary
        local boundMaxLv = playerLv + lv_boundary
        
        local sysTime = redis.call('TIME')
        local now = tonumber(sysTime[1])

        local boundMinScore = score - score_boundary
        local boundMaxScore = score + score_boundary
        local rangeCount = redis.call('ZCOUNT', REDIS_RANK_BADGE, boundMinScore, boundMaxScore)
        local playerIds
        local poolList = {}
        local poolDict = {}
        local function do_select(is_filter_lv)
            playerIds = redis.call('ZRANGEBYSCORE', REDIS_RANK_BADGE, boundMinScore, boundMaxScore, 'WITHSCORES')
            for i=1, #playerIds, 2 do
                local plyId = tonumber(playerIds[i])
                if plyId ~= PID and plyId ~= exclude_pid then
                    local can_add = true
                    local value = redis.call(
                        'HGET',
                        REDIS_PLAYER_BASE_INFO..playerIds[i],
                        'protectTick'
                    )
                    local lvValue = redis.call(
                        "HGET",
                        REDIS_PLAYER_BASE_INFO..playerIds[i],
                        'level'
                    )
                    local plyLV = tonumber(lvValue) or 1
                    local protectTick = tonumber(value) or now
                    if now < protectTick then
                        rangeCount = rangeCount - 1
                        can_add = false
                    else
                        if is_filter_lv then
                            if plyLV > boundMaxLv or plyLV < boundMinLv then
                                if is_expand_lv == 1 then
                                    lv_boundary = lv_boundary * 2
                                    boundMinLv = playerLv - lv_boundary
                                    boundMaxLv = playerLv + lv_boundary
                                    if plyLV > boundMaxLv or plyLV < boundMinLv then
                                        rangeCount = rangeCount - 1
                                    end
                                else
                                    rangeCount = rangeCount - 1
                                    can_add = false
                                end
                            end
                        end
                    end
                    if can_add then
                        if not poolDict[plyId] then
                            table.insert(poolList, plyId)
                            poolDict[plyId] = {
                                pid = plyId,
                                score = tonumber(playerIds[i+1]),
                                level = plyLV,
                            }
                        end
                    end
                end
            end
        end
        if rangeCount <= search_count then
            if is_expand_scope == 1 then
                while(score_boundary < max_scope) do
                    score_boundary = score_boundary * 2
                    boundMinScore = score - score_boundary
                    boundMaxScore = score + score_boundary
                    rangeCount = redis.call('ZCOUNT', REDIS_RANK_BADGE, boundMinScore, boundMaxScore)
                    if rangeCount >= search_count then
                        do_select(true)
                    end
                    if #poolList >= search_count then
                        break
                    end
                end
            end
        else
            do_select(true)
        end
        if #poolList < search_count then
            rangeCount = redis.call('ZCOUNT',REDIS_RANK_BADGE, boundMinScore, boundMaxScore)
            do_select(false)
        end
        local selectList = {}
        local selectDict = {}
        local psize = #poolList
        if psize <= search_count then
            selectList = poolList
            selectDict = poolDict
        else
            local startIdx = math.floor(rand_value * psize)
            if psize - startIdx < search_count - 1 then
                startIdx = psize - search_count + 1
            end
            local endIdx = startIdx + search_count - 1
            if startIdx <= 0 then
                startIdx = 1
                endIdx = startIdx + search_count - 1
            end
            for i = startIdx, endIdx, 1 do
                local pid = poolList[i]
                if pid then
                    table.insert(selectList, pid)
                    selectDict[pid] = poolDict[pid]
                end
            end
        end
        for k, value in pairs(selectDict) do
            local values = redis.call(
                'HMGET',
                REDIS_PLAYER_BASE_INFO..value.pid,
                'name',
                'level',
                'protectTick',
                'headIcon',
                'unionName',
                'createTime'
            )
            if values and #values > 0 then
                local level = tonumber(values[2]) or 0
                local createTime = tonumber(values[6]) or now
                if level >= be_attack_lv or (now - createTime) >= be_attack_sec then
                    table.insert(result, tonumber(value.pid))
                    table.insert(result, tonumber(value.score))
                    table.insert(result, values[1] or '')
                    table.insert(result, tonumber(values[2]) or 0)
                    table.insert(result, tonumber(values[3]) or 0)
                    table.insert(result, values[4] or '')
                    table.insert(result, values[5] or '')
                end
            end
        end
        return result
    ]]

    local list = gg.redisProxy:call("eval",
        script,
        3,
        constant.REDIS_MATCH_RANK_BADGE,
        constant.REDIS_PLAYER_BASE_INFO,
        pid,
        score,
        math.random(),
        scoreBoundary,
        searchCount,
        constant.PVP_BE_ATTACK_LV,
        constant.PVP_BE_ATTACK_SEC,
        opArgs.expandScope,
        opArgs.maxScope,
        opArgs.excludePid or 0,
        opArgs.expandLv,
        opArgs.maxLv,
        opArgs.lvBoundary
    )
    -- local list = searchPlayersByBadgeDebug(pid, score, math.random(), scoreBoundary, searchCount, opArgs)

    local nowTime = skynet.timestamp()
    local players = {}
    if list and #list > 0 then
        for i=1, #list, 7 do
            if pid ~= list[i] and nowTime > list[i+4] then
                table.insert(players, {
                    playerId = list[i],
                    playerScore = list[i+1],
                    playerName = list[i+2],
                    playerLevel = list[i+3],
                    protectTick = list[i+4],
                    playerHead = list[i+5],
                    unionName  = list[i+6],
                    diffTick = nowTime - list[i+4],
                    diffScore = math.abs((score or 0)-list[i+1]),
                })
            end
        end
    end

    table.sort(players, function(a, b)
        if a.diffScore < b.diffScore then
            return true
        elseif a.diffScore > b.diffScore then
            return false
        end
        return a.diffTick > b.diffTick
    end)
    return players
end

function api.getPvpRankMembers()
    local script = [[
        local REDIS_RANK_BADGE = KEYS[1]
        local REDIS_PLAYER_BASE_INFO = KEYS[2]
        local nowTime = tonumber(KEYS[3])
        local playerlist = {}
        local playerIds = redis.call('ZREVRANGE', REDIS_RANK_BADGE, 0, 99, 'WITHSCORES')
        if playerIds and #playerIds > 0 then
            local rank = 1
            for i=1, #playerIds, 2 do
                local values = redis.call(
                    'HMGET',
                    REDIS_PLAYER_BASE_INFO..playerIds[i],
                    'name',
                    'level',
                    'protectTick',
                    'headIcon',
                    'unionName',
                    'createTime'
                )
                if values and #values > 0 then
                    local level = tonumber(values[2]) or 0
                    local createTime = tonumber(values[6]) or nowTime
                    local protectTick = tonumber(values[3]) or 0
                    if protectTick == 0 or nowTime * 1000 > protectTick then
                        local playerInfo = {}
                        playerInfo.rank = rank
                        playerInfo.playerId = tonumber(playerIds[i])
                        playerInfo.playerScore = tonumber(playerIds[i+1])
                        playerInfo.playerLevel = level
                        playerInfo.playerName = values[1]
                        playerInfo.protectTick = tonumber(values[3]) or 0
                        playerInfo.playerHead = values[4] or ''
                        playerInfo.unionName = values[5] or ''
                        table.insert(playerlist, cjson.encode(playerInfo))
                        rank = rank + 1
                    end
                end
            end
        end
        return playerlist
    ]]
    local rankMembers = {}
    local list = gg.redisProxy:call("eval", script, 3, constant.REDIS_MATCH_RANK_BADGE, constant.REDIS_PLAYER_BASE_INFO, os.time())
    if list and #list > 0 then
        for k, v in pairs(list) do
            local playerInfo = cjson.decode(v)
            table.insert(rankMembers, playerInfo)
        end
    end
    return rankMembers
end

return api