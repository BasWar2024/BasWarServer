local Airway = class("Airway")


function Airway.getAirwayCfg(cfgId)
    local airwayCfg = cfg.get("etc.cfg.airway")
    return airwayCfg[cfgId]
end

function Airway.getTonnage(cfgId)
    local tonnageCfg = cfg.get("etc.cfg.tonnage")
    if not tonnageCfg[cfgId] then
        return 0
    end
    return tonnageCfg[cfgId].tonnage
end

--
function Airway:ctor(param)
    self.cfgId = param.cfgId
    self.name = param.name
    self.warShipId = param.warShipId or 0
    self.flyTime = param.flyTime or 0
    self.nextTick = param.nextTick or 0
    self.checked = false   --
    self.packageId = param.packageId
    self.currencies = {}
    self.items = {}
end

function Airway:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.name = self.name
    data.warShipId = self.warShipId
    data.nextTick = self.nextTick
    data.flyTime = self.flyTime
    data.packageId = self.packageId
    data.checked = self.checked
    data.currencies = {}
    data.items = {}
    if self.currencies and next(self.currencies) then
        for _, v in pairs(self.currencies) do
            table.insert(data.currencies, v)
        end
    end
    if self.package.items and next(self.package.items) then
        for _,v in pairs(self.items) do
            table.insert(data.items, v)
        end
    end
    return data
end

function Airway:deserialize(data)
    self.cfgId = data.cfgId
    self.name = data.name
    self.warShipId = data.warShipId or 0
    self.nextTick = data.nextTick or 0
    self.flyTime = data.flyTime or 0
    self.packageId = data.packageId
    self.checked = data.checked or false
    if data.currencies and next(data.currencies) then
        self.currencies = {}
        for k, v in pairs(data.currencies) do
            self.currencies[v.resCfgId] = v
        end
    end
    if data.items and next(data.items) then
        self.items = {}
        for k, v in pairs(data.items) do
            self.items[id] = v
        end
    end
end

function Airway:pack()
    local data = {}
    data.cfgId = self.cfgId
    data.name = self.name
    data.warShipId = self.warShipId
    data.lessTime = self:getLessTime()
    data.flyTime = self.flyTime
    data.status = self:getSetOutStatus()
    data.currencies = {}
    data.items = {}
    if self.currencies and next(self.currencies) then
        for _, v in pairs(self.currencies) do
            table.insert(data.currencies, v)
        end
    end
    if self.package.items and next(self.package.items) then
        for _,v in pairs(self.items) do
            table.insert(data.items, v)
        end
    end
    return data
end

function Airway:setNextTick(second)
    self.nextTick = skynet.timestamp() + second * 1000
end

function Airway:getLessTime()
    if self.nextTick <= 0 then
        return 0
    end
    if skynet.timestamp() >= self.nextTick then
        return 0
    end
    return math.floor((self.nextTick - skynet.timestamp())/1000)
end

-- 
function Airway:getSetOutStatus()
    if self.packageId == 0 then
        return 0 --
    end
    if self:getLessTime() > 0 then
        return 1 --
    end
    if self.checked == false then
        return 2 --,
    end
    return 3 --
end

-- 
function Airway:isSetOut()
    return self:getSetOutStatus() > 0
end

--
function Airway:getTotalTonnage()
    local total = 0
    for k, v in pairs(self.currencies) do
        total = total + Airway.getTonnage(v.resCfgId) * v.count
    end
    for k, v in pairs(self.items) do
        total = total + Airway.getTonnage(v.targetCfgId) * v.num
    end
    return total
end

function Airway:addCurrency(resCfgId, count)
    self.currencies[resCfgId] = self.currencies[resCfgId] or {resCfgId = 0, count = 0}
    self.currencies[resCfgId].count = self.currencies[resCfgId].count + count
end

function Airway:addItem(item)
    self.items[item.id] = item
end


function Airway:checkFinish()
    if self.nextTick == 0 then
        return
    end
    if skynet.timestamp() < self.nextTick then
        return
    end

    gg.client:send(self.player.linkobj,"S2C_Player_AirwayUpdate",{ airway=self:pack() })
    self.nextTick = 0
end

return Airway