local ItemBag = class("ItemBag")

function ItemBag:ctor(param)
    self.player = param.player
    self.maxSpace = param.maxSpace or gg.getGlobalCgfIntValue("ItemBagInitSpace", 50)    -- 
    self.expandSpace = 0                                                                 -- 
    self.items = {}                                                                      -- id -> 
    self.composeItems = {}                                                               -- id --> 
end

-- @override
function ItemBag:newItem(param)
    param.player = self.player
    return ggclass.Item.create(param)
end

function ItemBag:newComposeItem(param)
    param.player = self.player
    return ggclass.ComposeItem.create(param)
end

function ItemBag:serialize()
    local data = {}
    data.maxSpace = self.maxSpace
    data.expandSpace = self.expandSpace
    data.items = {}
    data.composeItems = {}
    for _, item in pairs(self.items) do
        table.insert(data.items, item:serialize())
    end
    for _, composeItem in pairs(self.composeItems) do
        table.insert(data.composeItems, composeItem:serialize())
    end
    return data
end

function ItemBag:deserialize(data)
    self.maxSpace = data.maxSpace or gg.getGlobalCgfIntValue("ItemBagInitSpace", 50)
    self.expandSpace = data.expandSpace or 0
    if data.items and next(data.items) then
        for _, itemData in pairs(data.items) do
            local item = self:newItem(itemData)
            if item then
                item:deserialize(itemData)
                self.items[item.id] = item
            end
        end
    end
    if data.composeItems and next(data.composeItems) then
        for _, composeItemData in pairs(data.composeItems) do
            local composeItem = self:newComposeItem(composeItemData)
            if composeItem then
                composeItem:deserialize(composeItemData)
                self.composeItems[composeItem.item.id] = composeItem
            end
         end
    end
end

function ItemBag:getItemCfg(cfgId)
    return ggclass.Item.getItemCfg(cfgId)
end


--- 
function ItemBag:canOverlay(item,maxNum)
    if item.num >= maxNum then
        return false
    end
    return item:canOverlay()
end

function ItemBag:getMaxSpace()
    return self.expandSpace + self.maxSpace
end
--- 
--@param[type=integer] needSpace 
function ItemBag:spaceIsEnough(needSpace)
    if needSpace <= 0 then
        return true
    end
    local maxSpace = self:getMaxSpace()
    local items = table.values(self.items)
    local num = maxSpace - #items
    if num >= needSpace then
        return true
    end
    return false
end

function ItemBag:getItemsByItemType(itemType)
    local list = {}
    for _, v in pairs(self.items) do
        if v.itemType == itemType then
            table.insert(list, v)
        end
    end
    return list
end

-- 
function ItemBag:getAvailableItemsByItemType(itemType)
    local list = {}
    for _, v in pairs(self.items) do
        if v.itemType == itemType and not v:isUsing() then
            table.insert(list, v)
        end
    end
    return list
end

--- 
function ItemBag:getItemsByCfgId(cfgId)
    local list = {}
    for k, v in pairs(self.items) do
        if v.cfgId == cfgId then
            table.insert(list, v)
        end
    end
    return list
end

--- 
function ItemBag:getLeftOverlayNum(cfgId)
    local num = 0
    local items = self:getItemsByCfgId(cfgId)
    local itemCfg = self:getItemCfg(cfgId)
    for i,item in ipairs(items) do
        num = num + itemCfg.maxNum - item.num
    end
    return num
end

--- 
function ItemBag:getItemNumByCfgId(cfgId)
    local items = self:getItemsByCfgId(cfgId)
    local num = 0
    for i,item in ipairs(items) do
        num = num + item.num
    end
    return num
end

-- 
--@param[type=integer] id id
function ItemBag:getItem(id)
    return self.items[id]
end

-- 
--@param[type=integer] id id
function ItemBag:isItemInBag(id)
    return self.items[id] ~= nil
end

-- 
--@param[type=integer] id id
function ItemBag:isItemInComposing(id)
    return self.composeItems[id] ~= nil
end

-- 
--@param[type=integer] id id
--@param[type=table] attrs 
function ItemBag:update(id, attrs, source)
    local player = self.player
    local item = self:getItem(id)
    if not item then
        return
    end
    if attrs and next(attrs) then
        for k, v in pairs(attrs) do
            if item[k] then
                item:setAttr(k, v)
            end
        end
    end
    if not source.notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_ItemUpdate",{item=item:pack()})
    end
end

--- 
--@param[type=table] item 
--@param[type=string] reason 
function ItemBag:addItemObj(item, source)
    local id = assert(item.id, "item.id is nil")
    local reason = source.reason
    local cfgId = assert(item.cfgId, "item.cfgId is nil")
    self.items[id] = item
    if not source.notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_ItemAdd",{item=item:pack()})
    end
end

--- id
--@param[type=integer] id id
--@param[type=string] reason 
function ItemBag:delItem(id, source)
    local item = self.items[id]
    if not item then
        self.player:say(i18n.format("no item"))
        return
    end
    self.items[id] = nil
    if not source.notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_ItemDel",{id=id})
    end
    return item
end

--- 
--@param[type=table] item 
--@param[type=integer] change 
--@param[type=table] source 
function ItemBag:costItemNum(item, change, source)
    local old = item.num
    local new  = item.num - change
    assert(new >= 0)
    self:update(item.id,{ num = new }, source)
    if item.num <= 0 then
        self:delItem(item.id, source)
    end
end

--- 
--@param[type=table] item 
--@param[type=integer] change 
--@param[type=table] source 
function ItemBag:addItemNum(item,change,source)
    local maxNum = self:getItemCfg(item.cfgId).maxNum
    local old = item.num
    local new = old + change
    assert(new <= maxNum)
    self:update(item.id,{ num = new }, source)
end

--- ()
--@param[type=integer] cfgId id
--@param[type=integer] num 
--@param[type=table] source 
--@return[type=integer] 
function ItemBag:costItem(cfgId,num,source)
    local leftNum = num
    local items = self:getItemsByCfgId(cfgId)
    table.sort(items,function (item1,item2)
        if item1.num ~= item2.num then
            return item1.num > item2.num
        end
        return false
    end)

    for i = #items, 1, -1 do
        local item = items[i]
        local costNum = math.min(leftNum,item.num)
        leftNum = leftNum - costNum
        self:costItemNum(item,costNum,source)
        if leftNum <= 0 then
            break
        end
    end
    return leftNum
end

--- 
--@param[type=integer] cfgId id
--@param[type=integer] num 
--@param[type=table] targetParam 
--@return[type=table] source {reason,isSys}
function ItemBag:addItem(cfgId,num,targetParam,source)
    assert(num > 0, "require num>0, num="..tostring(num))
    local itemCfg = self:getItemCfg(cfgId)
    if not itemCfg then
        self.player:say(i18n.format("itemConfig[%d] is not exist", cfgId))
        return -1
    end
    local itemType = itemCfg.itemType
    if itemType >= constant.ITEM_WAR_SHIP then
        if not targetParam or not targetParam.targetCfgId or not targetParam.targetQuality or not targetParam.targetLevel then
            self.player:say("argument error, when item is warship or hero or build, need target cfgId and quality and level")
            return -1
        end
        if itemType == constant.ITEM_WAR_SHIP then
            local warShip = self.player.warShipBag:generateWarShip(targetParam.targetCfgId, targetParam.targetQuality)
            if not warShip then
                self.player:say("argument error, config not exists")
                return -1
            end
            targetParam.skillLevel1 = targetParam.skillLevel1 or warShip.skillLevel1
            targetParam.skillLevel2 = targetParam.skillLevel2 or warShip.skillLevel2
            targetParam.skillLevel3 = targetParam.skillLevel3 or warShip.skillLevel3
            targetParam.skillLevel4 = targetParam.skillLevel4 or warShip.skillLevel4
            targetParam.skillLevel5 = targetParam.skillLevel5 or warShip.skillLevel5
            targetParam.life = targetParam.life or warShip.life
            targetParam.curLife = targetParam.curLife or warShip.curLife
        elseif itemType == constant.ITEM_HERO then
            local hero = self.player.heroBag:generateHero(targetParam.targetCfgId, targetParam.targetQuality)
            if not hero then
                self.player:say("argument error, config not exists")
                return -1
            end
            targetParam.skillLevel1 = targetParam.skillLevel1 or hero.skillLevel1
            targetParam.skillLevel2 = targetParam.skillLevel2 or hero.skillLevel2
            targetParam.skillLevel3 = targetParam.skillLevel3 or hero.skillLevel3
            targetParam.life = targetParam.life or hero.life
            targetParam.curLife = targetParam.curLife or hero.curLife
        elseif itemType == constant.ITEM_BUILD then
            local build = self.player.buildBag:generateBuild(targetParam.targetCfgId, targetParam.targetQuality)
            if not build then
                self.player:say("argument error, config not exists")
                return -1
            end
            targetParam.life = targetParam.life or build.life
            targetParam.curLife = targetParam.curLife or build.curLife
        elseif itemType == constant.ITEM_MINING_MACHINE then --,,
            local build = self.player.buildBag:generateBuild(targetParam.targetCfgId, targetParam.targetQuality)
            if not build then
                self.player:say("argument error, config not exists")
                return -1
            end
            targetParam.life = targetParam.life or build.life
            targetParam.curLife = targetParam.curLife or build.curLife
        end
    end

    local param = {}
    param.cfgId = cfgId
    if targetParam then
        param.id = targetParam.id
        param.targetCfgId = targetParam.targetCfgId
        param.targetQuality = targetParam.targetQuality
        param.targetLevel = targetParam.targetLevel
        param.skillLevel1 = targetParam.skillLevel1
        param.skillLevel2 = targetParam.skillLevel2
        param.skillLevel3 = targetParam.skillLevel3
        param.skillLevel4 = targetParam.skillLevel4
        param.skillLevel5 = targetParam.skillLevel5
        param.life = targetParam.life
        param.curLife = targetParam.curLife
        param.ver = targetParam.ver
    end
    local modifiedItems = {}
    local maxNum = itemCfg.maxNum
    local leftNum = num
    local items = self:getItemsByCfgId(cfgId)
    for i,item in ipairs(items) do
        if self:canOverlay(item, maxNum) then
            local addNum = math.min(leftNum,maxNum - item.num)
            leftNum = leftNum - addNum
            self:addItemNum(item, addNum, source)
            table.insert(modifiedItems, item)
        end
        if leftNum <= 0 then
            break
        end
    end
    while leftNum > 0 do
        -- 
        if not self:spaceIsEnough(1) then
            break
        end
        local itemNum = math.min(leftNum,maxNum)
        leftNum = leftNum - itemNum
        param.num = itemNum
        local item = self:newItem(param)
        self:addItemObj(item, source)
        table.insert(modifiedItems, item)
    end
    return num - leftNum, modifiedItems
end

function ItemBag:packItems()
    local itemData = {}
    for id,item in pairs(self.items) do
        table.insert(itemData, item:pack())
    end
    return itemData
end

--- 
function ItemBag:expandItemBag()
    local expandSpace = gg.getGlobalCgfIntValue("ItemBagExpandSpace", 5)
    local cost = gg.getGlobalCgfIntValue("ItemBagUpCost", 666)
    local costRate = gg.getGlobalCgfIntValue("ItemBagUpCostRate", 1000)
    local upgradeCount = math.floor(self.expandSpace / expandSpace)
    for i=1, upgradeCount do
        cost = math.floor(cost * (costRate + 10000) / 10000)
    end
    if cost > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cost) then
            self.player:say(i18n.format("StarCoin is not enough"))
            return
        end
    end
    self.expandSpace = self.expandSpace + expandSpace
    if cost > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cost)
    end
    gg.client:send(self.player.linkobj,"S2C_Player_ExpandItemBag",{expandSpace=self.expandSpace})
end

--- 
--@param[type=integer] id id
--@param[type=integer] hour 
--@return[type=table]
function ItemBag:playerItemCompose(id, hour)
    local item = self:getItem(id)
    if not item then
        self.player:say(i18n.format("you have not this item"))
        return
    end
    local count = table.count(self.composeItems)
    if count >= gg.getGlobalCgfIntValue("ComposeCount",3) then
        self.player:say(i18n.format("compose total is full"))
        return
    end
    local itemCfg = ggclass.Item.getItemCfg(item.cfgId)
    if not itemCfg then
        self.player:say(i18n.format("item is not config"))
        return
    end
    if hour*3600 < itemCfg.minComposeTime or hour*3600 > itemCfg.maxComposeTime then
        self.player:say(i18n.format("time is not valid"))
        return
    end
    if self:getItemNumByCfgId(item.cfgId) < itemCfg.composeNeed then
        self.player:say(i18n.format("item num is not enough"))
        return
    end
    if itemCfg.composeNeedStartCoin and itemCfg.composeNeedStartCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, itemCfg.composeNeedStartCoin) then
            self.player:say(i18n.format("less StarCoin"))
            return
        end
    end
    if itemCfg.composeNeedIce and itemCfg.composeNeedIce > 0 then
        if not self.player.resBag:enoughRes(constant.RES_ICE, itemCfg.composeNeedIce) then
            self.player:say(i18n.format("less Ice"))
            return
        end
    end
    if itemCfg.composeNeedCarboxyl and itemCfg.composeNeedCarboxyl > 0 then
        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, itemCfg.composeNeedCarboxyl) then
            self.player:say(i18n.format("less Carboxyl"))
            return
        end
    end
    if itemCfg.composeNeedTitanium and itemCfg.composeNeedTitanium > 0 then
        if not self.player.resBag:enoughRes(constant.RES_TITANIUM, itemCfg.composeNeedTitanium) then
            self.player:say(i18n.format("less Titanium"))
            return
        end
    end
    if itemCfg.composeNeedGas and itemCfg.composeNeedGas > 0 then
        if not self.player.resBag:enoughRes(constant.RES_GAS, itemCfg.composeNeedGas) then
            self.player:say(i18n.format("less Gas"))
            return
        end
    end
    local composeItem = self:newComposeItem({player = self.player, hour=hour})
    composeItem.item = self:newItem(item:pack())
    composeItem.item.num = itemCfg.composeNeed
    self.composeItems[id] = composeItem

    if itemCfg.composeNeedStartCoin and itemCfg.composeNeedStartCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, itemCfg.composeNeedStartCoin)
    end
    if itemCfg.composeNeedIce and itemCfg.composeNeedIce > 0 then
        self.player.resBag:costRes(constant.RES_ICE, cfg.composeNeedIce)
    end
    if itemCfg.composeNeedCarboxyl and itemCfg.composeNeedCarboxyl > 0 then
        self.player.resBag:costRes(constant.RES_CARBOXYL, itemCfg.composeNeedCarboxyl)
    end
    if itemCfg.composeNeedTitanium and itemCfg.composeNeedTitanium > 0 then
        self.player.resBag:costRes(constant.RES_TITANIUM, itemCfg.composeNeedTitanium)
    end
    if itemCfg.composeNeedGas and itemCfg.composeNeedGas > 0 then
        self.player.resBag:costRes(constant.RES_GAS, itemCfg.composeNeedGas)
    end
    composeItem:setNextTick(hour*3600)
    self:costItem(item.cfgId, itemCfg.composeNeed, { reason="" })

    gg.client:send(self.player.linkobj,"S2C_Player_ItemComposeAdd",{ item = composeItem:pack() })


end

--- 
--@param[type=integer] id id
--@return[type=table]
function ItemBag:playerItemComposeCancel(id)
    local composeItem = self.composeItems[id]
    if not composeItem then
        self.player:say(i18n.format("you have not this item"))
        return
    end
    if composeItem:getLessTick() <= 0 then
        self.player:say(i18n.format("you have composed item"))
        return
    end
    composeItem:initNextTick()
    self:addItem(composeItem.item.cfgId, composeItem.item.num, composeItem.item:serialize(), {reason=""})
    self.composeItems[id] = nil
    gg.client:send(self.player.linkobj,"S2C_Player_ItemComposeCancel",{ item = composeItem.item:pack() })
end

--- 
--@param[type=integer] id id
--@return[type=table]
function ItemBag:playerItemComposeSpeed(id, mit)
    local composeItem = self.composeItems[id]
    if not composeItem then
        self.player:say(i18n.format("you have not this item"))
        return
    end
    if composeItem:getLessTick() <= 0 then
        self.player:say(i18n.format("you have composed item"))
        return
    end
    local lessTick = composeItem:getLessTick()
    local hour = math.ceil(lessTick/3600)
    local costPerHour = gg.getGlobalCgfIntValue("ComposeSpeedCostPerHour", 2)
    local cost = hour * costPerHour
    if not self.player.resBag:enoughRes(constant.RES_MIT, cost) then
        self.player:say(i18n.format("less mit"))
        return
    end
    self.player.resBag:costRes(constant.RES_MIT, cost)
    composeItem:setNextTick(0)
    composeItem:checkComposeFinish()
end

function ItemBag:packComposeItems()
    local items = {}
    for _, v in pairs(self.composeItems) do
        table.insert(items, v:pack())
    end
    return items
end

function ItemBag:onSecond()
    self:checkComposeFinish()
end

function ItemBag:checkComposeFinish(notNotify)
    local removeList = {}
    for id, composeItem in pairs(self.composeItems) do
        local isFinished = composeItem:checkComposeFinish(notNotify)
        if isFinished then
            removeList[#removeList+1] = id
        end
    end
    for _, v in pairs(removeList) do
        self.composeItems[v] = nil
    end
end

function ItemBag:onload()
    self:checkComposeFinish(false)
end

function ItemBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_ItemBag",{expandSpace=self.expandSpace, maxSpace=self.maxSpace, items=self:packItems()})
    gg.client:send(self.player.linkobj,"S2C_Player_ComposeItemData",{items=self:packComposeItems()})
end

return ItemBag