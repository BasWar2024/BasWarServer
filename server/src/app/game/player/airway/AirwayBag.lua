local AirwayBag = class("AirwayBag")


function AirwayBag:ctor(param)
    self.player = param.player
    self.airways = {}
end

function AirwayBag:createAirway(cfgId)
    local airCfg = ggclass.Airway.getAirwayCfg(cfgId)
    if not airCfg then
        return nil
    end
    local airway = ggclass.Airway.new({player=self.player, cfgId=cfgId, flyTime=airCfg.flyTime, name = airCfg.name})
    return airway
end

function AirwayBag:getAirway(cfgId)
    local airway = self.airways[cfgId]
    if airway then
        return airway
    end
    return self:createAirway(cfgId)
end

--
function AirwayBag:getAllAirways()
    local airways = {}
    for k, v in pairs(self.airways) do
        airways[cfgId] = v
    end
    local airwayCfg = cfg.get("etc.cfg.airway")
    for cfgId, v in pairs(airwayCfg) do
        if not airways[cfgId] then
            local airway = self:createAirway(cfgId)
            if airway then
                airways[cfgId] = airway
            end
        end
    end
    return airways
end

-- 
function AirwayBag:setWarShip(cfgId, warShipId)
    local airway = self:getAirway(cfgId)
    if airway and airway:isSetOut() then
        self.player:say(i18n.format("war ship set out"))
        return
    end
    if airway.warShipId == warShipId then
        self.player:say(i18n.format("war ship has been set"))
        return
    end
    local item = self.player.itemBag:getItem(warShipId)
    if not item then
        self.player:say(i18n.format("you not have this warship"))
        return
    end
    if item:isUsing() then
        self.player:say(i18n.format("item is using in other place"))
        return
    end
    local availableWarShips = {}
    local warShips = self.player.itemBag:getAvailableItemsByItemType(constant.ITEM_WAR_SHIP)
    if #warShips < 2 then
        self.player:say(i18n.format("you need more warship for airway"))
        return
    end
    local warShipCfg = ggclass.WarShip.getWarShipCfg(item.targetCfgId, item.targetQuality, item.targetLevel)
    if not warShipCfg then
        return
    end
    if airway.warShipId > 0 then
        local oldWarShip = self.player.itemBag:getItem(airway.warShipId)
        if oldWarShip then
            oldWarShip:setRef(constant.ITEM_REF_NONE)
        end
    end
    airway.flyTime = warShipCfg.flyTime
    airway.warShipId = warShipId
    if not self.airways[cfgId] then
        self.airways[cfgId] = airway
    end
    gg.client:send(self.player.linkobj,"S2C_Player_AirwayUpdate",{airway=airway:pack()})
end

-- 
function AirwayBag:addFreight(cfgId, freight)
    local airway = self.airways[cfgId]
    if not airway then
        return
    end
    if airway:isSetOut() then
        self.player:say(i18n.format("this airway is set out"))
        return
    end
    if airway.warShipId == 0 then
        self.player:say(i18n.format("you need set a warship for airway"))
        return
    end
    local warShip = self.player.itemBag:getItem(airway.warShipId)
    if not warShip then
        return
    end
    if not freight.currency and (freight.itemId == 0 or freight.itemNum == 0) then
        return
    end
    local warShipCfg = WarShip.getWarShipCfg(warShip.targetCfgId, warShip.targetQuality, warShip.targetLevel)
    if not warShipCfg then
        return
    end
    local curTotalTonnage = airway:getTotalTonnage()
    if freight.currency and freight.currency.resCfgId > 0 and freight.currency.count > 0 then --
        local tonnage = ggclass.Airway.getTonnage(freight.currency.resCfgId) * freight.currency.count
        if curTotalTonnage + tonnage > warShipCfg.tonnage then --
            return
        end
        --
        if not self.player.resBag:enoughRes(freight.currency.resCfgId, freight.currency.count) then
            return
        end
        --
        self.player.resBag:costRes(freight.currency.resCfgId, freight.currency.count)
        --
        airway:addCurrency(freight.currency.resCfgId, freight.currency.count)
    end
    if freight.itemId and freight.itemNum > 0 then --
        local item = self.player.itemBag:getItem(freight.itemId)
        if not item then
            return
        end
        if freight.itemNum > item.num then
            return
        end
        if item:isUsing() then
            return
        end
        local tonnage = ggclass.Airway.getTonnage(freight.itemId) * freight.itemNum
        if curTotalTonnage + tonnage > warShipCfg.tonnage then
            return
        end
        --
        self.player.itemBag:costItemNum(item, freight.itemNum, "airway add freight")
        local itemData = item:serialize()
        itemData.num = freight.itemNum
        airway:addItem(itemData)
    end
    gg.client:send(self.player.linkobj,"S2C_Player_AirwayUpdate",{airway=airway:pack()})
end

-- 
function AirwayBag:setOut(cfgId)
    local airway = self.airways[cfgId]
    if not airway then
        return
    end
    if airway:isSetOut() then
        self.player:say(i18n.format("this airway is set out"))
        return
    end
    if airway.warShipId == 0 then
        self.player:say(i18n.format("you need set a warship for airway"))
        return
    end
    if airway:getTotalTonnage() <= 0 then
        self.player:say(i18n.format("you need add some freight for airway"))
        return
    end
    airway.packageId = snowflake.uuid()


    airway:setNextTick()
    gg.client:send(self.player.linkobj,"S2C_Player_AirwayUpdate",{airway=airway:pack()})
end

--
function AirwayBag:clickAirwayFinish(cfgId)
    local airway = self.airways[cfgId]
    if not airway then
        return
    end
    if airway:getSetOutStatus() ~= 2 then
        return
    end
    airway.checked = true
    gg.client:send(self.player.linkobj,"S2C_Player_AirwayUpdate",{airway=airway:pack()})
    self.airways[cfgId] = nil
end

function AirwayBag:onSecond()
    for _, airway in pairs(self.airways) do
        airway:checkFinish()
    end
end

function AirwayBag:onload()

end

function AirwayBag:onlogin()

end

function AirwayBag:onlogout()

end


return AirwayBag