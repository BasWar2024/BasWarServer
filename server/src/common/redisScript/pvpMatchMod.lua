return [[
    local function get_rank_score(rankKey, pid)
        local scoreS = redis.call('ZSCORE', rankKey, pid)
        local score = tonumber(scoreS)
        return score
    end

    local function get_range_rank_list(rankKey, from, to)
        local rankList = {}
        local rangeRank = redis.call('ZREVRANGEBYSCORE', rankKey, to, from, 'WITHSCORES')
        for i = 1, #rangeRank, 2 do
            local temp = {}
            temp.pid = tonumber(rangeRank[i])
            temp.score = tonumber(rangeRank[i+1])
            table.insert(rankList, temp)
        end
        return rankList
    end

    local function get_stage_data(REDIS_PVP_STAGE_RATIO, REDIS_RANK_KEY)
        local stageRatioInfo = redis.call('GET', REDIS_PVP_STAGE_RATIO)
        local stageRatio = cjson.decode(stageRatioInfo)

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
                plyRatio = tonumber(psr.ratio),
                minScore = minScore,
                maxScore = maxScore,
                rangeCount = rangeCount,
            }
        end
        return stageData
    end

    local function cal_player_carboxyl(pid, rankKey, stageData, carboxyl, shareRatio)
        local reward = 0
        local score = get_rank_score(rankKey, pid)
        if not score then
            reward = 0
        else
            local plyStage = 0
            local plyRatio = 0
            local rangeCount = 0
            for i = 1, #stageData, 1 do
                local sd = stageData[i]
                if score >= sd.minScore and score <= sd.maxScore then
                    plyStage = sd.plyStage
                    plyRatio = sd.plyRatio
                    rangeCount = sd.rangeCount
                    break
                end
            end
            if plyStage == 0 then
                reward = 0
            else
                if rangeCount == 0 then
                    rangeCount = 1
                end
                reward = math.floor((carboxyl * shareRatio * plyRatio) / rangeCount)
            end
        end
        return reward
    end

    local function cal_rank_list_carboxyl(rankList, stageData, carboxyl, shareRatio, rankKey)
        for i = 1, #rankList, 1 do
            local rdata = rankList[i]
            rdata.carboxyl = cal_player_carboxyl(rdata.pid, rankKey, stageData, carboxyl, shareRatio)
        end
    end

    local function cal_rank_list_mit(rankList, rankMitCfg)
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
    end

    local function deduct_jackpot(jackpot, shareRatio, REDIS_PVP_JACKPOT_INFO)
        jackpot.sysCarboxyl = math.floor(jackpot.sysCarboxyl * (1 - shareRatio))
        jackpot.plyCarboxyl = math.floor(jackpot.plyCarboxyl * (1 - shareRatio))
        local jackpotInfo = cjson.encode(jackpot)
        redis.call('SET', REDIS_PVP_JACKPOT_INFO, jackpotInfo)
    end

    local function set_player_reward(rankList, REDIS_PVP_MATCH_REWARD, season, rankTime)
        for i = 1, #rankList, 1 do
            if rankList[i].score > 0 then
                local keyName = REDIS_PVP_MATCH_REWARD .. rankList[i].pid
                redis.call('HSET', keyName, 'season', season)
                redis.call('HSET', keyName, 'rankTime', rankTime)
                redis.call('HSET', keyName, 'rank', i)
                redis.call('HSET', keyName, 'score', rankList[i].score)
                redis.call('HSET', keyName, 'carboxyl', rankList[i].carboxyl)
                redis.call('HSET', keyName, 'mit', rankList[i].mit)
            end
        end
    end

    local function get_jackpot_carboxyl(REDIS_PVP_JACKPOT_INFO)
        local jackpotInfo = redis.call('GET', REDIS_PVP_JACKPOT_INFO)
        local jackpot = cjson.decode(jackpotInfo)
        local carboxyl = jackpot.sysCarboxyl + jackpot.plyCarboxyl
        return carboxyl
    end

    local function get_matching_player_info(inPlayerList, rankKey, REDIS_PLAYER_BASE_INFO)
        local sysTime = redis.call('TIME')
        local now = tonumber(sysTime[1])
        local playerDict = {}
        for i, _pid in ipairs(inPlayerList) do
            local _score = get_rank_score(rankKey, _pid) or 0
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
        return playerDictJson
    end

    local function add_to_matching_pool(PID, REDIS_RANK_BADGE, minScore, maxScore, REDIS_PLAYER_BASE_INFO, rangeCount, poolList, poolDict)
        local sysTime = redis.call('TIME')
        local now = tonumber(sysTime[1])
        local playerIds = redis.call('ZRANGEBYSCORE', REDIS_RANK_BADGE, minScore, maxScore, 'WITHSCORES')
        for i=1, #playerIds, 2 do
            local plyId = tonumber(playerIds[i])
            if plyId ~= PID then
                local value = redis.call(
                    'HGET',
                    REDIS_PLAYER_BASE_INFO..playerIds[i],
                    'protectTick'
                )
                local protectTick = tonumber(value) or now
                if now < protectTick then
                    rangeCount = rangeCount - 1
                else
                    if not poolDict[plyId] then
                        table.insert(poolList, plyId)
                        poolDict[plyId] = {
                            pid = plyId,
                            score = tonumber(playerIds[i+1]),
                        }
                    end
                end
            end
        end
        return rangeCount
    end

    local function get_matching_pool(PID, score, score_boundary, REDIS_RANK_BADGE, search_count, is_expand_scope, max_scope, REDIS_PLAYER_BASE_INFO)
        local minScore = score - score_boundary
        local maxScore = score + score_boundary
        local rangeCount = redis.call('ZCOUNT', REDIS_RANK_BADGE, minScore, maxScore)
        local playerIds
        local poolList = {}
        local poolDict = {}
        if rangeCount <= search_count then
            if is_expand_scope == 1 then
                while(score_boundary < max_scope) do
                    score_boundary = score_boundary * 2
                    minScore = score - score_boundary
                    maxScore = score + score_boundary
                    rangeCount = redis.call('ZCOUNT', REDIS_RANK_BADGE, minScore, maxScore)
                    if rangeCount >= search_count then
                        rangeCount = add_to_matching_pool(PID, REDIS_RANK_BADGE, minScore, maxScore, REDIS_PLAYER_BASE_INFO, rangeCount, poolList, poolDict)
                    end
                    if #poolList >= search_count then
                        break
                    end
                end
            end
        end
        if #poolList < search_count then
            rangeCount = add_to_matching_pool(PID, REDIS_RANK_BADGE, minScore, maxScore, REDIS_PLAYER_BASE_INFO, rangeCount, poolList, poolDict)
        end
        return poolList, poolDict
    end

    local function get_select_list(poolList, poolDict, search_count, rand_value)
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
        return selectList, selectDict
    end

    local function format_matching_result(selectDict, REDIS_PLAYER_BASE_INFO, be_attack_lv, be_attack_sec)
        local sysTime = redis.call('TIME')
        local now = tonumber(sysTime[1])
        local result = {}
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
    end

    local function CMDGetPvpMatchInfo(args)
        local REDIS_RANK_KEY = args.REDIS_RANK_KEY
        local REDIS_PVP_JACKPOT_INFO = args.REDIS_PVP_JACKPOT_INFO
        local REDIS_PVP_JACKPOT_SHARE_RATIO = args.REDIS_PVP_JACKPOT_SHARE_RATIO
        local REDIS_PVP_STAGE_RATIO = args.REDIS_PVP_STAGE_RATIO
        local REDIS_PLAYER_BASE_INFO = args.REDIS_PLAYER_BASE_INFO

        local PID = args.PID
        local inPlayerList = cjson.decode(args.inPlayerList)

        local retInfo = {}
        local carboxyl = get_jackpot_carboxyl(REDIS_PVP_JACKPOT_INFO)
        local stageData = get_stage_data(REDIS_PVP_STAGE_RATIO, REDIS_RANK_KEY)
        local jackpotShareRatio = redis.call('GET', REDIS_PVP_JACKPOT_SHARE_RATIO)
        local shareRatio = tonumber(jackpotShareRatio)
        local reward = cal_player_carboxyl(PID, REDIS_RANK_KEY, stageData, carboxyl, shareRatio)
        table.insert(retInfo, carboxyl)
        table.insert(retInfo, reward)

        local playerDictJson = get_matching_player_info(inPlayerList, REDIS_RANK_KEY, REDIS_PLAYER_BASE_INFO)
        table.insert(retInfo, playerDictJson)
        return retInfo
    end

    local function CMDGetPvpMatchSettlement(args)
        local REDIS_RANK_KEY = args.REDIS_RANK_KEY
        local REDIS_PVP_JACKPOT_INFO = args.REDIS_PVP_JACKPOT_INFO
        local REDIS_PVP_JACKPOT_SHARE_RATIO = args.REDIS_PVP_JACKPOT_SHARE_RATIO
        local REDIS_PVP_STAGE_RATIO = args.REDIS_PVP_STAGE_RATIO
        local REDIS_PVP_RANK_MIT_REWARD = args.REDIS_PVP_RANK_MIT_REWARD
        local REDIS_PVP_MATCH_REWARD = args.REDIS_PVP_MATCH_REWARD

        local from = args.from
        local to = args.to
        local season = args.season
        local rankTime = args.rankTime
        local rankList = get_range_rank_list(REDIS_RANK_KEY, '-inf', '+inf')
        local stageData = get_stage_data(REDIS_PVP_STAGE_RATIO, REDIS_RANK_KEY)
        local carboxyl = get_jackpot_carboxyl(REDIS_PVP_JACKPOT_INFO)
        local jackpotShareRatio = redis.call('GET', REDIS_PVP_JACKPOT_SHARE_RATIO)
        local shareRatio = tonumber(jackpotShareRatio)
        cal_rank_list_carboxyl(rankList, stageData, carboxyl, shareRatio, REDIS_RANK_KEY)

        local jackpotInfo = redis.call('GET', REDIS_PVP_JACKPOT_INFO)
        local jackpot = cjson.decode(jackpotInfo)
        deduct_jackpot(jackpot, shareRatio, REDIS_PVP_JACKPOT_INFO)

        local rankMitReward = redis.call('GET', REDIS_PVP_RANK_MIT_REWARD)
        local rankMitCfg = cjson.decode(rankMitReward)
        cal_rank_list_mit(rankList, rankMitCfg)

        set_player_reward(rankList, REDIS_PVP_MATCH_REWARD, season, rankTime)

        local ret = {}
        for i = 1, #rankList, 1 do
            table.insert(ret, rankList[i].pid)
            table.insert(ret, rankList[i].score)
            table.insert(ret, rankList[i].carboxyl)
            table.insert(ret, rankList[i].mit)
        end
        return ret
    end

    local function CMDSearchPlayersByBadge(args)
        local REDIS_RANK_BADGE = args.REDIS_RANK_BADGE
        local REDIS_PLAYER_BASE_INFO = args.REDIS_PLAYER_BASE_INFO
        local PID = args.PID

        local score = args.score
        local rand_value = args.rand_value
        local score_boundary = args.score_boundary
        local search_count = args.search_count
        local be_attack_lv = args.be_attack_lv
        local be_attack_sec = args.be_attack_sec
        local is_expand_scope = args.is_expand_scope
        local max_scope = args.max_scope
        local result = {}
        if score == -1 then
            score = get_rank_score(REDIS_RANK_BADGE, PID)
            if not score then
                return result
            end
        end
        local poolList, poolDict = get_matching_pool(
            PID, 
            score, 
            score_boundary, 
            REDIS_RANK_BADGE, 
            search_count, 
            is_expand_scope, 
            max_scope, 
            REDIS_PLAYER_BASE_INFO
        )
        local selectList, selectDict = get_select_list(poolList, poolDict, search_count, rand_value)
        result = format_matching_result(selectDict, REDIS_PLAYER_BASE_INFO, be_attack_lv, be_attack_sec)
        return result
    end

    local cmd = KEYS[1]
    local args = cjson.decode(ARGV[1])
    if cmd == 'getPvpMatchInfo' then
        return CMDGetPvpMatchInfo(args)
    elseif cmd == 'getPvpMatchSettlement' then
        return CMDGetPvpMatchSettlement(args)
    elseif cmd == 'searchPlayersByBadge' then
        return CMDSearchPlayersByBadge(args)
    end
]]