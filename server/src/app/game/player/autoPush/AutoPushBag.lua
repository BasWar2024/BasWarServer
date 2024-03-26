local AutoPushBag = class("AutoPushBag")

--""
function AutoPushBag:ctor(param)
    self.player = param.player
    self.autoPushStatus = {}          -- autoPushCfgId -> "", int int
end

function AutoPushBag:serialize()
    local data = {}
    for k, v in pairs(self.autoPushStatus) do
        table.insert(data, {k, v})
    end
    return data
end

function AutoPushBag:deserialize(data)
    if not data then
        return
    end
    for _, v in pairs(data) do
        self.autoPushStatus[v[1]] = v[2]
    end
end

function AutoPushBag:pack()
    local data = {}
    for k, v in pairs(self.autoPushStatus) do
        table.insert(data, { autoPushCfgId = k, status = v })
    end
    return data
end

function AutoPushBag:setAutoPushStatus(autoPushCfgId)
    if not autoPushCfgId then
        return
    end
    autoPushCfgId = math.floor(tonumber(autoPushCfgId))
    if autoPushCfgId <= 0 then
        return
    end
    if self.autoPushStatus[autoPushCfgId] then
        return
    end
    self.autoPushStatus[autoPushCfgId] = 1

    local data = {}
    table.insert(data, { autoPushCfgId = autoPushCfgId, status = self.autoPushStatus[autoPushCfgId] })
    gg.client:send(self.player.linkobj, "S2C_Player_AutoPushStatus", { data = data })
end

function AutoPushBag:delAutoPushStatus(autoPushCfgId)
    if not autoPushCfgId then
        return
    end
    autoPushCfgId = math.floor(tonumber(autoPushCfgId))
    if autoPushCfgId <= 0 then
        return
    end
    if not self.autoPushStatus[autoPushCfgId] then
        return
    end
    self.autoPushStatus[autoPushCfgId] = nil

    local data = {}
    table.insert(data, { autoPushCfgId = autoPushCfgId, status = 0 })
    gg.client:send(self.player.linkobj, "S2C_Player_AutoPushStatus", { data = data })
end

function AutoPushBag:onload()
    
end

function AutoPushBag:onlogin()
    gg.client:send(self.player.linkobj, "S2C_Player_AutoPushStatus", { data = self:pack() })

    local baseUrl = gg.shareProxy:call("getDynamicCfg", constant.REDIS_URL_CONFIG_BASE)
    local marketUrl = gg.shareProxy:call("getDynamicCfg", constant.REDIS_URL_CONFIG_MARKET)
    gg.client:send(self.player.linkobj, "S2C_Player_Url_Config", { baseUrl = baseUrl, marketUrl = marketUrl })
end

function AutoPushBag:onlogout()
   
end

return AutoPushBag