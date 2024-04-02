---""
--@module operationmgr
--@usage

operationmgr = operationmgr or {}

local JSON_KEYS = {
    [constant.REDIS_PVP_STAGE_RATIO] = true,
    [constant.REDIS_PVP_RANK_MIT_REWARD] = true,
    [constant.REDIS_PVP_JACKPOT_INFO] = true,
}

local PVP_MATCH_OP_KEYS = {
    [constant.REDIS_PVP_SYS_CARBOXYL] = true,           --PVP""
    [constant.REDIS_PVP_STAGE_RATIO] = true,            --pvp""
    [constant.REDIS_PVP_JACKPOT_PLAYER_RATIO] = true,   --pvp""
    [constant.REDIS_PVP_JACKPOT_SHARE_RATIO] = true,    --pvp""
    [constant.REDIS_PVP_RANK_MIT_REWARD] = true,        --pvp""mit""
    -- [constant.REDIS_PVP_JACKPOT_SYSVAL] = true,         --PVP""("")
    [constant.REDIS_PVP_JACKPOT_INFO] = true,           --PVP""
}

function operationmgr.isJsonKey(key)
    return JSON_KEYS[key]
end

function operationmgr.getOpData(key)
    local data
    local text = gg.redisProxy:call("get", key)
    if operationmgr.isJsonKey(key) then
        if not text or text == "" then
            data = {}
        else
            data = cjson.decode(text)
        end
    else
        if not text or text == "" then
            data = ""
        else
            data = text
        end
    end
    return data
end

function operationmgr.getPvpCtrlData()
    local ret = {}
    for key, value in pairs(PVP_MATCH_OP_KEYS) do
        local data = operationmgr.getOpData(key)
        if key == constant.REDIS_PVP_JACKPOT_INFO then
            ret[key] = {
                sysCarboxyl = data.sysCarboxyl / 1000,
                plyCarboxyl = data.plyCarboxyl / 1000,
            }
        else
            ret[key] = data
        end
    end
    return ret
end
------------------------------------------------
function operationmgr.checkAdminAccount(linkobj, request, args, authority)
    local adminAccount = request.adminAccount
    local accountobj = adminaccountmgr.getadminaccount(adminAccount)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    local token = adminaccountmgr.gettoken(adminAccount)
    if not token then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.TOKEN_UNAUTH))
        return
    end
    if not util.admin_check_token_signature(args,token) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    authority = authority or constant.ADMIN_AUTHORITY_ROOT
    if not accountobj.authority or accountobj.authority > authority then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.AUTHORITY_ERR))
        return
    end
    return true
end

function operationmgr.checkBusinessAccount(linkobj, request, args)
    local businessAccount = request.businessAccount
    local accountobj = businessaccountmgr.getbusinessaccount(businessAccount)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    local token = businessaccountmgr.gettoken(businessAccount)
    if not token then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.TOKEN_UNAUTH))
        return
    end
    if not util.business_check_token_signature(args,token) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    return true
end
-------------------------------------
function operationmgr.checkPvpStage(pvpStage)
    if not pvpStage then
        return false, "pvpStage is nil"
    end
    if table.count(pvpStage) == 0 then
        return false, "pvpStage size is 0"
    end
    local overlapScore = {}
    for index, value in ipairs(pvpStage) do
        if not value.stage then
            return false, "stage is nil"
        end
        if not tonumber(value.stage) then
            return false, "stage must be number"
        end
        if not value.score then
            return false, "score is nil"
        end
        if type(value.score) ~= "table" then
            return false, "score format error"
        end
        if table.count(value.score) <= 1 then
            return false, "score size is lesss than 2"
        end
        local min_score = tonumber(value.score[1])
        local max_score = tonumber(value.score[#value.score])
        if min_score > max_score then
            return false, "first score is bigger than last score"
        end
        for i, v in ipairs(value.score) do
            local _score = tonumber(v)
            if not _score then
                return false, "score must be number"
            end
            if _score < min_score or _score > max_score then
                return false, "score not in valid range"
            end
        end
        overlapScore[index] = {min_score, max_score}
        if not value.ratio then
            return false, "ratio is nil"
        end
        if not tonumber(value.ratio) then
            return false, "ratio must be number"
        end
        local pre = overlapScore[index-1]
        local cur = overlapScore[index]
        if pre then
            if pre[2] >= cur[1] then
                return false, "score is overlap"
            end
        end
    end
    return true
end

function operationmgr.checkPvpRankMitReward(reward)
    if not reward then
        return false, "reward is nil"
    end
    if table.count(reward) == 0 then
        return false, "reward size is 0"
    end
    for index, value in ipairs(reward) do
        if not value.min_rank then
            return false, "min_rank is nil"
        end
        if not value.max_rank then
            return false, "max_rank is nil"
        end
        if not value.mit then
            return false, "mit is nil"
        end
        if not tonumber(value.min_rank) then
            return false, "min_rank must be number"
        end
        if not tonumber(value.max_rank) then
            return false, "max_rank must be number"
        end
        if not tonumber(value.mit) then
            return false, "mit must be number"
        end
    end
    return true
end
-------------------------------------

function operationmgr._checkKey(cfg, key, opArgs)
    opArgs = opArgs or {}
    if not cfg[key] then
        return false, key.." is nil"
    end
    if opArgs.isNum and not tonumber(cfg[key]) then
        return false, key.." must be number"
    end
    if opArgs.limitMap then
        if not opArgs.limitMap[cfg[key]] then
            local s = ""
            for k, v in pairs(opArgs.limitMap) do
                s = s..k..", "
            end
            return false, key.." must between in"..s
        end
    end
end

function operationmgr._checkKeyDict(cfg, keyDict, sortTimeKeys)
    for key, value in pairs(keyDict) do
        local r, err = operationmgr._checkKey(cfg, key, value)
        if not r then
            return r, err
        end
    end
    if sortTimeKeys then
        local sortTime = {}
        for i, v in ipairs(sortTimeKeys) do
            local t = string.totime(cfg[v])
            table.insert(sortTime, {v, t})
        end
        local s = table.count(sortTime)
        for i = 1, s-1, 1 do
            local t1 = sortTime[i][2]
            local t2 = sortTime[i+1][2]
            if t1 > t2 then
                return false, sortTime[i][1].." bigger than "..sortTime[i+1][1]
            end
        end
    end
    return true
end
local MATCH_TYPE_MAP = {
    [constant.MATCH_TYPE_WEEK] = true,
    [constant.MATCH_TYPE_MONTH] = true,
    [constant.MATCH_TYPE_SEASON] = true,
}
local MATCH_BELONG_MAP = {
    [constant.MATCH_BELONG_UNION] = true,
    [constant.MATCH_BELONG_PVP] = true,
}
local MATCH_REWARD_TYPE_MAP = {
    [constant.MATCH_REWARD_TYPE_DATE_TIME] = true,
    [constant.MATCH_REWARD_TYPE_DELAY_SEC] = true,
}
function operationmgr.checkMatchConfig(matchCfgs, cfg)
    if cfg.cfgId then
        if not tonumber(cfg.cfgId) then
            return false, "cfgId must be number"
        end
    end
    local keyDict = {
        ["matchType"] = {
            isNum = true,
            limitMap = MATCH_TYPE_MAP,
        },
        ["season"] = {
            isNum = true,
        },
        ["belong"] = {
            isNum = true,
            limitMap = MATCH_BELONG_MAP,
        },
        ["rewardType"] = {
            isNum = true,
            limitMap = MATCH_REWARD_TYPE_MAP,
        },
    }
    local sortTimeKeys = {"noticeTime", "startTime", "endTime", "rewardTime", "showEndTime"}
    local r, err = operationmgr._checkKeyDict(cfg, keyDict, sortTimeKeys)
    if not r then
        return r, err
    end

    local noticeTime = string.totime(cfg.noticeTime)
    local startTime = string.totime(cfg.startTime)
    local endTime = string.totime(cfg.endTime)
    if (startTime - noticeTime) < 60 then
        return false, "noticeTime must be less than startTime for more than 60 seconds"
    end
    if (endTime - startTime) < 60 then
        return false, "startTime must be less than endTime for more than 60 seconds"
    end
    -----------------------------
    local editCfgId = cfg.cfgId
    local maxCfgId = 0
    local matchCfgIdx = {}
    local sameSeason = {}
    local ret
    local index
    for k, v in pairs(matchCfgs) do
        matchCfgIdx[v.cfgId] = k
        if v.cfgId > maxCfgId then
            maxCfgId = v.cfgId
        end
        if v.season == cfg.season and v.belong == cfg.belong and v.status == 1 then
            sameSeason[v.cfgId] = v
        end
        if sameSeason[editCfgId] then
            index = k
        end
    end
    if not editCfgId then
        editCfgId = maxCfgId + 1
        ret = {op = "add", val = cfg}
    else
        if matchCfgIdx[editCfgId] then
            if not sameSeason[editCfgId] then
                return false, "not the same season and belong"
            end
            ret = {op = "update",  index = index, val = cfg}
        else
            ret = {op = "add", val = cfg}
        end
    end
    return true, ret
end

function operationmgr.getItemCfg(cfgId)
    local itemCfg = cfg.get("etc.cfg.item")
    return itemCfg[cfgId]
end

function operationmgr.getBuildCfg(cfgId, quality, level)
    return gg.getExcelCfgByFormat("buildConfig", cfgId, quality, level)
end

function operationmgr.getHeroCfg(cfgId, quality, level)
    return gg.getExcelCfgByFormat("heroConfig", cfgId, quality, level)
end

function operationmgr.getWarShipCfg(cfgId, quality, level)
    return gg.getExcelCfgByFormat("warShipConfig", cfgId, quality, level)
end

function operationmgr.getSkillCfg(cfgId, level)
    return gg.getExcelCfgByFormat("skillConfig", cfgId, level)
end

return operationmgr
