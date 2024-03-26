local ResBag = class("ResBag")

function ResBag:ctor(param)
    self.player = param.player                  -- ""
    self.resources = {}
    self.costMit = 0                            -- mit""
end

function ResBag:serialize()
    local data = {}
    data.resources = {}
    data.costMit = self.costMit
    for k,v in pairs(self.resources) do
        data.resources[tostring(k)] = {num = math.floor(v.num or 0), bindNum = math.floor(v.bindNum or 0)}
    end
    return data
end

function ResBag:deserialize(data)
    if data and data.resources and next(data.resources) then
        for resCfgId,num in pairs(data.resources) do
            local t = {}
            if type(num) == "number" then--""
                t = {num = math.floor(num), bindNum = 0}
            elseif type(num) == "table" then
                t = {num = math.floor(num.num)+math.floor(num.bindNum), bindNum = 0}--""（"")
            end
            self.resources[tonumber(resCfgId)] = t
        end
    end
    self.costMit = data.costMit or 0
end

function ResBag:isValidRes(resCfgId)
    if resCfgId >= constant.RES_MIN and resCfgId <= constant.RES_MAX then
        return true
    end
    return false
end

function ResBag:enoughRes(resCfgId, value)
    local curValue = self:getRes(resCfgId, true) + self:getRes(resCfgId, false)
    if curValue < value then
        return false
    end
    return true
end

function ResBag:enoughResDict(resDict, notTips)
    for resCfgId, value in pairs(resDict) do
        local curValue = self:getRes(resCfgId, true) + self:getRes(resCfgId, false)
        if curValue < value then
            if not notTips then
                self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[resCfgId]))
                if resCfgId == constant.RES_MIT then
                    gg.client:send(self.player.linkobj, "S2C_Player_MitNotEnoughTips", {})
                end
            end
            return false, resCfgId
        end
    end
    return true
end

function ResBag:getRes(resCfgId, bind)
    local t = self.resources[resCfgId] or {}
    local val = t.num or 0
    if bind then
        -- val = t.bindNum or 0
        val = 0
    end
    return val
end

function ResBag:setRes(resCfgId, newVal, bind)
    local t = self.resources[resCfgId] or {}
    if bind then
        -- t.bindNum = newVal
        t.bindNum = 0
    else
        t.num = newVal
    end
    self.resources[resCfgId] = t
end

--- ""
--@param[type=integer] resCfgId ""id
--@param[type=integer] value ""
--@param[type=table] source "" { logType }
--@return ok,succValue ""
function ResBag:addRes(resCfgId, value, source, bind, animArg)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ResBag:addRes " .. debug.traceback())
        return false
    end
    bind = false--""
    if value <= 0 then
        return false
    end
    value = math.floor(value)
    local oldValue = self:getRes(resCfgId, bind)
    local newValue = oldValue + value
    self:setRes(resCfgId, newValue, bind)
    -- self.resources[resCfgId] = newValue
    self:onResChange(resCfgId, oldValue, newValue, source, bind, animArg)
    
    return true, value
end

function ResBag:addResDict(resDict, source, bind, animArg)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ResBag:addResDict " .. debug.traceback())
        return false
    end
    bind = false--""
    for resCfgId, value in pairs(resDict) do
        if value > 0 then
            local oldValue = self:getRes(resCfgId, bind)
            local newValue = oldValue + value
            self:setRes(resCfgId, newValue, bind)
            -- self.resources[resCfgId] = newValue
            self:onResChange(resCfgId, oldValue, newValue, source, bind, animArg)
        end
    end
end

function ResBag:addJackpotPly(value)
    local plyRatio = gg.dynamicCfg:get(constant.REDIS_PVP_JACKPOT_PLAYER_RATIO)
    local addPlyVal = math.floor(value * plyRatio)
    local data = {plyCarboxyl = addPlyVal}
    gg.shareProxy:send("setPvpMatchJackpot", data)

    local starmapPlyRatio = gg.dynamicCfg:get(constant.REDIS_STARMAP_JACKPOT_PLAYER_RATIO)
    local starmapAddPlyVal = math.floor(value * starmapPlyRatio)
    local starmapData = {plyCarboxyl = starmapAddPlyVal}
    gg.shareProxy:send("setStarmapMatchJackpot", data)
end

function ResBag:costRes(resCfgId, value, source, animArg)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ResBag:costRes " .. debug.traceback())
        return false
    end
    if value <= 0 then
        return false
    end
    -- local bindOldValue = self:getRes(resCfgId, true)
    -- local newValue = bindOldValue - math.floor(value)
    -- if newValue < 0 then--bind res not enough
    --     if bindOldValue > 0 then
    --         self:setRes(resCfgId, 0, true)
    --         self:onResChange(resCfgId, bindOldValue, 0, source, true, animArg)
    --     end
    --     local oldValue = self:getRes(resCfgId, false)
    --     newValue = oldValue + newValue
    --     if newValue < 0 then
    --         newValue = 0
    --     end
    --     self:setRes(resCfgId, newValue, false)
    --     self:onResChange(resCfgId, oldValue, newValue, source, false, animArg)
    -- else--bind res left
    --     self:setRes(resCfgId, newValue, true)
    --     self:onResChange(resCfgId, bindOldValue, newValue, source, true, animArg)
    -- end
    local oldValue = self:getRes(resCfgId, false)
    local newValue = oldValue - math.floor(value)
    if newValue < 0 then
        newValue = 0
    end
    self:setRes(resCfgId, newValue, false)
    self:onResChange(resCfgId, oldValue, newValue, source, false, animArg)

    --PVP jackpot
    if resCfgId == constant.RES_CARBOXYL then
        self:addJackpotPly(value)
    end
    self.player.taskBag:update(constant.TASK_CONSUME_RES_NUM, {cfgId = resCfgId, count = value})
end

function ResBag:costResDict(resDict, source, animArg)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ResBag:costResDict " .. debug.traceback())
        return false
    end
    for resCfgId, value in pairs(resDict) do
        if value > 0 then
            self:costRes(resCfgId, value, source, animArg)
        end
    end
    return true
end

--""
function ResBag:getResFreeSpace(resCfgId)
    local STOREKEY = {
        [constant.RES_STARCOIN] = "storeStarCoin",
        [constant.RES_ICE] = "storeIce",
        -- [constant.RES_CARBOXYL] = "storeCarboxyl",
        [constant.RES_TITANIUM] = "storeTitanium",
        [constant.RES_GAS] = "storeGas",
    }
    local free = -1
    local storeKey = STOREKEY[resCfgId]
    if storeKey then
        local cur = self:getRes(resCfgId, true) + self:getRes(resCfgId, false)
        local storeCount = self.player.buildBag:getResCount(storeKey)
        free = storeCount - cur
    end
    return free
end

--"",""
function ResBag:safeAddRes(resCfgId, count, source, bind, animArg)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ResBag:safeAddRes " .. debug.traceback())
        return false
    end
    bind = false--""
    local succCount = 0
    local freespace = self:getResFreeSpace(resCfgId)
    if freespace == -1 then --""
        succCount = count
    else
        succCount = (count >= freespace) and freespace or count
    end    
    if succCount > 0 then
        source.loseValue = count - succCount
        self:addRes(resCfgId, succCount, source, bind, animArg)
        return true, succCount
    end
    return false, 0
end

function ResBag:safeAddResDict(resDict, source, bind, animArg)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ResBag:safeAddResDict " .. debug.traceback())
        return false
    end
    bind = false--""
    local succDict = {}
    for resCfgId, value in pairs(resDict) do
        if value > 0 then
            local succCount = 0
            local freespace = self:getResFreeSpace(resCfgId)
            if freespace == -1 then --""
                succCount = value
            else
                succCount = (value >= freespace) and freespace or value
            end    
            if succCount > 0 then
                source.loseValue = value - succCount
                self:addRes(resCfgId, succCount, source, bind, animArg)
                succDict[resCfgId] = succCount
            end
        end
    end
    return true, succDict
end

function ResBag:onResChange(resCfgId, oldValue, newValue, source, bind, animArg)
    bind = false--""
    --""
    source = source or {}
    local change = newValue - oldValue
    if animArg then
        local animSend = {
            resCfgId = resCfgId,
            count = newValue,
            change = change,
            buildId = animArg.buildId,
            animationId = animArg.animationId,
            fromId = animArg.fromId,
        }
        gg.client:send(self.player.linkobj,"S2C_Player_ResAnimation",animSend)
    end
    gg.client:send(self.player.linkobj,"S2C_Player_ResChange",{resCfgId=resCfgId, count=newValue, change=change, bind=bind})
    local platform = self.player.platform
    gg.internal:send(".gamelog", "api", "addResLog", self.player.pid, platform, resCfgId, change, oldValue, newValue, source.logType, gamelog[source.logType], source.loseValue or 0, source.extraId or 0)

    if resCfgId == constant.RES_BADGE then
        -- gg.rankProxy:send("syncBadgeInfo", self.player.pid, newValue)
        -- self.player.pvpBag:updateMatchRankScore(change)
    elseif resCfgId == constant.RES_MIT then
        if change < 0 then --""
            self.costMit = self.costMit + math.abs(change)
            gg.rankProxy:send("syncCostMitInfo", self.player.pid, self.costMit)
        end
    elseif resCfgId == constant.RES_STARCOIN then
        if change > 0 then
        end
    elseif resCfgId == constant.RES_ICE then
        if change > 0 then
        end
    elseif resCfgId == constant.RES_TITANIUM then
        if change > 0 then
        end
    elseif resCfgId == constant.RES_CARBOXYL then
        if change > 0 then
            local RANK_TYPE_GET_HYDROXYL_LOGTYPE = {
                [gamelog.PVP_PLUNDER] = true,
                [gamelog.PVP_MATCH_SETTLEMENT] = true,
                [gamelog.STARMAP_DRAW_REWARD] = true,
            }
            if RANK_TYPE_GET_HYDROXYL_LOGTYPE[source.logType] then
                gg.rankProxy:send("increDifferentRankVal", constant.REDIS_RANK_GET_HYDROXYL, self.player.pid, change)
            end
        end
    elseif resCfgId == constant.RES_GAS then
        if change > 0 then
        end
    end
end

function ResBag:packRes()
    local resData = {}
    for cfgId,t in pairs(self.resources) do
        table.insert(resData, { resCfgId = cfgId, count = t.num, bind = false})
        table.insert(resData, { resCfgId = cfgId, count = t.bindNum, bind = true})
    end
    return resData
end

function ResBag:resCostTesseract(resDict)
    local chain = self.player.playerInfoBag:getChainId() or 0
    chain = tostring(chain)
    local result = gg.dynamicCfg:get(constant.REDIS_TESSERACT_TO_RES)
    local rateDict = result[chain] or result["0"]
    local need = 0
    for cfgId, count in pairs(resDict) do
        if cfgId ~= constant.RES_MIT and cfgId ~= constant.RES_TESSERACT then
            local rkey = constant.RES_JSON_KEYS[cfgId]
            local rcount = rateDict[rkey] or 1
            need = need + (count / rcount * 1)
        end
    end
    need = math.ceil(need)
    return need
end

function ResBag:timeCostMit(sec)
    local SpeedUpPerMinute = gg.getGlobalCfgIntValue("SpeedUpPerMinute")
    local count = math.ceil((sec or 0) / 60)
    return SpeedUpPerMinute * count
end

function ResBag:timeCostTesseract(sec)
    local SpeedUpPerMinute = gg.getGlobalCfgIntValue("SpeedUpPerMinute")
    local count = math.ceil((sec or 0) / 60)
    return SpeedUpPerMinute * count
end

function ResBag:exchangeRes(from, fromCount, to)
    local chain = self.player.playerInfoBag:getChainId() or 0
    chain = tostring(chain)
    if fromCount <= 0 then
        self.player:say(util.i18nFormat(errors.NOT_ADD_RES_NUM ))
        return
    end
    if from ~= constant.RES_TESSERACT and from ~= constant.RES_CARBOXYL then
        self.player:say(util.i18nFormat(errors.RES_EXCHANGE_ERR))
        return
    end
    if not self:enoughRes(from, fromCount) then
        self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[from]))
        return
    end
    local jsKey = constant.RES_JSON_KEYS[to]
    if not jsKey then
        self.player:say(util.i18nFormat(errors.RES_EXCHANGE_ERR))
        return
    end
    local RES_KEY_TO_REDIS_KEY = {
        [constant.RES_TESSERACT] = constant.REDIS_TESSERACT_TO_RES,
        [constant.RES_CARBOXYL] = constant.REDIS_HYDROXYL_TO_TESSERACT,
    }
    local result = gg.dynamicCfg:get(RES_KEY_TO_REDIS_KEY[from])
    local rateDict = result[chain] or result["0"]
    if not rateDict then
        self.player:say(util.i18nFormat(errors.RES_EXCHANGE_ERR))
        return
    end
    local resDict = {}
    for k, v in pairs(rateDict) do
        if k == jsKey then
            resDict[to] = v * fromCount
        end
    end
    self:costRes(from, fromCount, { logType=gamelog.EXCHANGE_RES })
    self:addResDict(resDict, { logType=gamelog.EXCHANGE_RES })
 
    -- "" ""
    if from == constant.RES_CARBOXYL and to == constant.RES_TESSERACT then
        local dict = {}
        dict.res = from
        dict.count = fromCount
        gg.internal:send(".gamelog", "api", "addPlayerHydroxylExchangeLog", self.player.pid, fromCount, resDict[to])
        self.player.mailBag:rebateToInviter(dict, constant.MAIL_TEMPLATE_TRANGE_REBATETOINVITER)
    end
    self.player:say(util.i18nFormat(errors.EXCHANGE_SUCCESS))
end

function ResBag:getPlunderableRes(resCfgId)
    local cur = self:getRes(resCfgId, true) + self:getRes(resCfgId, false)
    return cur
end

function ResBag:sendResExchangeRate(tipType)
    local chain = self.player.playerInfoBag:getChainId() or 0
    chain = tostring(chain)
    local keyToFrom = {
        [constant.REDIS_TESSERACT_TO_RES] = constant.RES_TESSERACT,
        [constant.REDIS_HYDROXYL_TO_TESSERACT] = constant.RES_CARBOXYL,
    }
    local rates = {}
    for key, from in pairs(keyToFrom) do
        local result = gg.dynamicCfg:get(key)
        local data = {
            from = from,
            to = result[chain] or result["0"],
        }
        table.insert(rates, data)
    end
    gg.client:send(self.player.linkobj,"S2C_Player_Exchange_Rate", {rates = rates, tipType = tipType})
end

function ResBag:onload()
    
end

function ResBag:onreset()
    local INIT_RES = {
        [constant.RES_STARCOIN] = gg.getGlobalCfgIntValue("InitStarCoin", 0),
        [constant.RES_TITANIUM] = gg.getGlobalCfgIntValue("InitTitanium", 0),
        [constant.RES_GAS] = gg.getGlobalCfgIntValue("InitGas", 0),
        [constant.RES_ICE] = gg.getGlobalCfgIntValue("InitIce", 0),
    }
    for resCfgId,num in pairs(self.resources) do
        if INIT_RES[resCfgId] then
            num.num = INIT_RES[resCfgId]
            num.bindNum = 0
        end
    end
end

function ResBag:onlogin()
    self:sendResExchangeRate()
    gg.client:send(self.player.linkobj, "S2C_Player_ResData", { resData = self:packRes() })
    local rankScore = self.player.pvpBag:getPlayerRankScore()
    gg.rankProxy:send("syncBadgeInfo", self.player.pid, rankScore)
end

function ResBag:oncreate()
    gg.rankProxy:send("syncBadgeInfo", self.player.pid, 0)
    self:addRes(constant.RES_MIT, gg.getGlobalCfgIntValue("InitMit", 0), {logType=gamelog.CREATE_PLAYER_GIFT})
    self:addRes(constant.RES_STARCOIN, gg.getGlobalCfgIntValue("InitStarCoin", 0), {logType=gamelog.CREATE_PLAYER_GIFT})
    self:addRes(constant.RES_TITANIUM, gg.getGlobalCfgIntValue("InitTitanium", 0), {logType=gamelog.CREATE_PLAYER_GIFT})
    self:addRes(constant.RES_GAS, gg.getGlobalCfgIntValue("InitGas", 0), {logType=gamelog.CREATE_PLAYER_GIFT})
    self:addRes(constant.RES_CARBOXYL, gg.getGlobalCfgIntValue("InitCarboxyl", 0), {logType=gamelog.CREATE_PLAYER_GIFT})
    self:addRes(constant.RES_ICE, gg.getGlobalCfgIntValue("InitIce", 0), {logType=gamelog.CREATE_PLAYER_GIFT})
    self:addRes(constant.RES_TESSERACT, gg.getGlobalCfgIntValue("InitTesseract", 0), {logType=gamelog.CREATE_PLAYER_GIFT})
end

return ResBag