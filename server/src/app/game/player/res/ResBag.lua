local ResBag = class("ResBag")

function ResBag:ctor(param)
    self.player = param.player                  -- 
    self.resources = {}
    self.costMit = 0                            -- mit
end

function ResBag:serialize()
    local resources = {}
    for k,v in pairs(self.resources) do
        resources[tostring(k)] = math.floor(v)
    end
    local data = {
        resources = resources,
        costMit = self.costMit,
    }
    return data
end

function ResBag:deserialize(data)
    if data and data.resources and next(data.resources) then
        for resCfgId,num in pairs(data.resources) do
            self.resources[tonumber(resCfgId)] = math.floor(num)
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
    local curValue = self:getRes(resCfgId)
    if curValue < value then
        return false
    end
    return true
end

function ResBag:getRes(resCfgId)
    return self.resources[resCfgId] or 0
end

--- 
--@param[type=integer] resCfgId id
--@param[type=integer] value 
--@param[type=string] source 
--@return ok,succValue 
function ResBag:addRes(resCfgId, value, source)
    if value <= 0 then
        return false
    end
    value = math.floor(value)
    local oldValue = self:getRes(resCfgId)
    local newValue = oldValue + value
    self.resources[resCfgId] = newValue
    self:onResChange(resCfgId, oldValue, newValue, source)
    return true, value
end

function ResBag:costRes(resCfgId, value, source)
    if value <= 0 then
        return
    end
    local oldValue = self:getRes(resCfgId)
    local newValue = oldValue - math.floor(value)
    self.resources[resCfgId] = newValue
    self:onResChange(resCfgId, oldValue, newValue, source)
end

function ResBag:onResChange(resCfgId, oldValue, newValue, source)
    --
    local change = newValue - oldValue
    gg.client:send(self.player.linkobj,"S2C_Player_ResChange",{resCfgId=resCfgId, count=newValue, change=change})

    if resCfgId == constant.RES_BADGE then
        gg.internal:send(".rank","api","syncBadgeInfo", self.player.pid, newValue)
    end
    if resCfgId == constant.RES_MIT then
        if change < 0 then
            self.costMit = self.costMit + math.abs(change)
            gg.internal:send(".rank","api","syncCostMitInfo", self.player.pid, self.costMit)
        end
    end
end

function ResBag:packRes()
    local resData = {}
    for cfgId,count in pairs(self.resources) do
        table.insert(resData, { resCfgId = cfgId, count = count})
    end
    return resData
end

function ResBag:exchangeRes(mit, cfgId)
    if not self.player.resBag:enoughRes(constant.RES_MIT, mit) then
        self.player:say(i18n.format("less mit"))
        return
    end
    local data = gg.shareMgr:call("getMitExchangeRate")
    local oneMit = data.mit or 1
    local oneValue = 0
    if cfgId == constant.RES_STARCOIN then
        oneValue = data.starCoin
    elseif cfgId == constant.RES_ICE then
        oneValue = data.ice
    elseif cfgId == constant.RES_CARBOXYL then
        oneValue = data.carboxyl
    elseif cfgId == constant.RES_TITANIUM then
        oneValue = data.titanium
    elseif cfgId == constant.RES_GAS then
        oneValue = data.gas
    else
        self.player:say(i18n.format("error mit"))
        return
    end
    local total = math.floor(mit / oneMit * oneValue)
    if cfgId == constant.RES_STARCOIN then
        self:addRes(constant.RES_STARCOIN, total)
    elseif cfgId == constant.RES_ICE then
        self:addRes(constant.RES_ICE, total)
    elseif cfgId == constant.RES_CARBOXYL then
        self:addRes(constant.RES_CARBOXYL, total)
    elseif cfgId == constant.RES_TITANIUM then
        self:addRes(constant.RES_TITANIUM, total)
    elseif cfgId == constant.RES_GAS then
        self:addRes(constant.RES_GAS, total)
    end
    self:costRes(constant.RES_MIT, mit)
end

function ResBag:onload()
    gg.shareMgr:send("setPlayerBaseInfo", self.player.pid, { name = self.player.name })
end

function ResBag:onlogin()
    gg.client:send(self.player.linkobj, "S2C_Player_ResData", { resData = self:packRes() })
end

return ResBag