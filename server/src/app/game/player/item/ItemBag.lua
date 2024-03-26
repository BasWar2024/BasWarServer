local ItemBag = class("ItemBag")

function ItemBag:ctor(param)
    self.player = param.player
    --self.maxSpace = param.maxSpace or gg.getGlobalCfgIntValue("ItemBagInitSpace", 50)  -- ""
    self.maxSpace = 9999                                                                 -- "",""
    self.expandSpace = 0                                                                 -- "", ""=maxSpace+expandSpace
    self.items = {}                                                                      -- id -> ""
end

-- @override
function ItemBag:newItem(param)
    param.player = self.player
    return ggclass.Item.create(param)
end

function ItemBag:serialize()
    local data = {}
    data.maxSpace = self.maxSpace
    data.expandSpace = self.expandSpace
    data.items = {}
    for _, item in pairs(self.items) do
        table.insert(data.items, item:serialize())
    end
    return data
end

function ItemBag:deserialize(data)
    self.maxSpace = data.maxSpace or 9999
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

end

function ItemBag:getItemCfg(cfgId)
    return ggclass.Item.getItemCfg(cfgId)
end

function ItemBag:getItemEffectCfg(cfgId)
    local itemCfg = cfg.get("etc.cfg.itemEffect")
    return itemCfg[cfgId]
end

--- ""
function ItemBag:canOverlay(item,maxNum)
    if item.num >= maxNum then
        return false
    end
    return true
end

function ItemBag:getMaxSpace()
    return self.expandSpace + self.maxSpace
end

--- ""
--@param[type=integer] needSpace ""
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

--""
function ItemBag:getItemsByItemType(itemType)
    local list = {}
    for _, v in pairs(self.items) do
        if v.itemType == itemType then
            table.insert(list, v)
        end
    end
    return list
end

--- ""
function ItemBag:getItemsByCfgId(cfgId)
    local list = {}
    for k, v in pairs(self.items) do
        if v.cfgId == cfgId then
            table.insert(list, v)
        end
    end
    return list
end

--- ""
function ItemBag:getItemNumByCfgId(cfgId)
    local items = self:getItemsByCfgId(cfgId)
    local num = 0
    for i,item in pairs(items) do
        num = num + item.num
    end
    return num
end

--- ""
function ItemBag:getItemNumByItemType(itemType)
    local num = 0
    for k, item in pairs(self.items) do
        if item.itemType == itemType then
            num = num + item.num
        end
    end
    return num
end

-- ""
function ItemBag:getAllItems()
    return self.items
end

-- ""
--@param[type=integer] id ""id
function ItemBag:getItem(id)
    return self.items[id]
end

-- ""
--@param[type=integer] cfgId ""id
function ItemBag:isItemEnough(cfgId, count)
    local itemNum = self.player.itemBag:getItemNumByCfgId(cfgId)
    if itemNum < count then
        self.player:say(util.i18nFormat(errors.ITEM_NOT_ENOUGH))
        return false
    end
    return true
end

--- ""
--@param[type=table] dict "" {cfgId1 = count1, cfgId2 = count2,...}
function ItemBag:isItemDictEnough(dict)
    for k, v in pairs(dict) do
        if not self:isItemEnough(k, v) then
            return false
        end
    end
    return true
end

--- ""
--@param[type=table] item ""
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
function ItemBag:addItemObj(item, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ItemBag:addItemObj " .. debug.traceback())
        return false
    end
    local id = assert(item.id, "item.id is nil")
    if self.items[id] then
        return false
    end
    local cfgId = assert(item.cfgId, "item.cfgId is nil")
    self.items[id] = item
    if not source.notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_ItemAdd",{item=item:pack()})
    end
    if source.logType ~= gamelog.DRAW_CARD and item.itemType == constant.ITEM_SKILL  then
        local skillCfgId = self:getItemCfg(item.cfgId).skillCfgID[1]
        local skillCfg = ggclass.Hero.getHeroSkillCfg(skillCfgId, 0, 1)
        local data = {}
        data[skillCfgId] = { cfgId = skillCfgId, quality = skillCfg.quality }
        self.player.drawCardBag:isNewGet(data)
    end
    gg.internal:send(".gamelog", "api", "addItemLog", self.player.pid, self.player.platform, item.id, item.cfgId, "add", 0, item.num, item.num, source.logType, gamelog[source.logType])
    return true
end

--- ""id""
--@param[type=integer] id ""id
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
function ItemBag:delItemObj(id, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ItemBag:delItemObj " .. debug.traceback())
        return
    end
    local item = self.items[id]
    if not item then
        self.player:say(util.i18nFormat(errors.ITEM_NOT_EXIST))
        return
    end
    self.items[id] = nil
    if not source.notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_ItemDel",{id=id})
    end
    gg.internal:send(".gamelog", "api", "addItemLog", self.player.pid, self.player.platform, item.id, item.cfgId, "del", item.num, -item.num, 0, source.logType, gamelog[source.logType])
    return item
end

--- ""
--@param[type=table] item ""
--@param[type=integer] change ""
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
function ItemBag:costItemNum(item, change, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ItemBag:costItemNum " .. debug.traceback())
        return
    end
    local old = item.num
    local new  = item.num - change
    assert(new >= 0)
    item.num = new
    gg.internal:send(".gamelog", "api", "addItemLog", self.player.pid, self.player.platform, item.id, item.cfgId, "dec", old, -change, new, source.logType, gamelog[source.logType])
    if not source.notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_ItemUpdate",{ item=item:pack() })
    end
    if item.num <= 0 then
        self:delItemObj(item.id, source)
    end
end

--- ""
--@param[type=table] item ""
--@param[type=integer] change ""
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
function ItemBag:addItemNum(item, change, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ItemBag:addItemNum " .. debug.traceback())
        return
    end
    local maxNum = self:getItemCfg(item.cfgId).maxNum
    local old = item.num
    local new = old + change
    assert(new <= maxNum)
    gg.internal:send(".gamelog", "api", "addItemLog", self.player.pid, self.player.platform, item.id, item.cfgId, "inc", old, change, new, source.logType, gamelog[source.logType])
    item.num = new
    if not source.notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_ItemUpdate",{ item=item:pack() })
    end
end

--- ""("")
--@param[type=integer] cfgId ""id
--@param[type=integer] num ""
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
--@return[type=integer] ""
function ItemBag:costItem(cfgId,num,source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ItemBag:costItem " .. debug.traceback())
        return num
    end
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

--- ""id""("")
--@param[type=table] dict "" {cfgId1 = count1, cfgId2 = count2,...}
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
--@return[type=table] "" {cfgId1 = count1, cfgId2 = count2,...}
function ItemBag:costItemDict(dict, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ItemBag:costItemDict " .. debug.traceback())
        return dict
    end
    local ret = {}
    for k, v in pairs(dict) do
        ret[k] = self:costItem(k, v, source)
    end
    return ret
end

--- ""
--@param[type=integer] cfgId ""id
--@param[type=integer] num ""
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
--@param[type=table] args "", "" id  { id = xxx }
--@return[type=integer, type=table] "",""
function ItemBag:addItem(cfgId, num, source, args)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=ItemBag:addItem " .. debug.traceback())
        return -1
    end
    assert(num > 0, "require num>0, num="..tostring(num))
    local itemCfg = self:getItemCfg(cfgId)
    if not itemCfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return -1
    end
    
    local itemType = itemCfg.itemType
    local param = { cfgId = cfgId, num = num }
    if args then
        param.id = args.id
    end
    local autoUseItems = {}
    local modifiedItems = {}
    local maxNum = itemCfg.maxNum
    local leftNum = num
    local items = self:getItemsByCfgId(cfgId)
    for i,item in ipairs(items) do
        if self:canOverlay(item, maxNum) then --""
            local addNum = math.min(leftNum,maxNum - item.num)
            leftNum = leftNum - addNum
            self:addItemNum(item, addNum, source)
            if itemCfg.isAutoUse and itemCfg.isAutoUse == 1 then
                local _id = item.id
                local isOk = self:autoUseItem(_id, addNum)
                if isOk then
                    if self:getItem(_id) then
                        table.insert(modifiedItems, item)
                    end
                end
            else
                table.insert(modifiedItems, item)
            end
        end
        if leftNum <= 0 then
            break
        end
    end
    
    while leftNum > 0 do
        local itemNum = math.min(leftNum,maxNum)
        param.num = itemNum
        local item = self:newItem(param)
        if self:addItemObj(item, source) then
            leftNum = leftNum - itemNum
            if itemCfg.isAutoUse and itemCfg.isAutoUse == 1 then
                local _id = item.id
                local isOk = self:autoUseItem(_id, itemNum)
                if isOk then
                    if self:getItem(_id) then
                        table.insert(modifiedItems, item)
                    end
                end
            else
                table.insert(modifiedItems, item)
            end
        else
            break
        end
    end

    if itemType and itemType >= constant.AUTOPUSH_CFGID_NEW_ITEM_13 and itemType <= constant.AUTOPUSH_CFGID_NEW_ITEM_16 and itemCfg.isAutoUse == 0 then
        self.player.autoPushBag:setAutoPushStatus(itemType)
    end

    return num - leftNum, modifiedItems
end

--- ""
--@param[type=integer] id ""id
--@param[type=integer] count ""
function ItemBag:resolveItem(id, count)
    local item = self.items[id]
    if not item then
        self.player:say(util.i18nFormat(errors.ITEM_NOT_EXIST))
        return
    end
    local itemCfg = self:getItemCfg(item.cfgId)
    if not itemCfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    if itemCfg.canResolve ~= 1 then
        self.player:say(util.i18nFormat(errors.ITEM_CANNOT_RESOLVE))
        return
    end
    if count <= 0 or count > item.num then
        self.player:say(util.i18nFormat(errors.ITEM_COUNT_LESS))
        return
    end
    local resolveItem = itemCfg.resolveItem
    local itemDict = {}
    local items = {}
    local resDict = {}
    if resolveItem and next(resolveItem) then
        for i = 1, count do
            for k,v in pairs(resolveItem) do
                local cfgId = math.floor(tonumber(v[1]))
                local value = math.floor(tonumber(v[2]))
                if constant.RES_KEYS[cfgId] then
                    resDict[cfgId] = value
                else
                    itemDict[cfgId] = (itemDict[cfgId] or 0) + value
                end
            end
        end
    end
    for cfgId, value in pairs(itemDict) do
        local num = 0
        local res = {}
        num,res = self:addItem(cfgId, value, { logType=gamelog.ITEM_RESOLVE })
        for k,v in pairs(res) do
            local item = v:pack()
            if not items[id] then
                items[id] = {id = item.id, cfgId = item.cfgId, num = num}
            else
                items[id].num = items[id].num + num
            end
        end
    end
    self.player.resBag:addResDict(resDict,{ logType=gamelog.ITEM_RESOLVE })
    self:costItemNum(item, count, { logType=gamelog.ITEM_RESOLVE })
    return items, resDict
end

--- ""
--@param[type=integer] id ""id
--@param[type=integer] count ""
function ItemBag:autoUseItem(id, count)
    local item = self.items[id]
    if not item then
        return
    end
    local itemCfg = self:getItemCfg(item.cfgId)
    if not itemCfg then
        return
    end
    -- if itemCfg.canUse ~= 1 then
    --     return
    -- end
    if count <= 0 or count > item.num then
        return
    end
    if itemCfg.unique and itemCfg.unique == 1 then
        local ret = gg.shareProxy:call("getUsedItem",  self.player.pid, item.cfgId)
        if ret == "1" then
            self.player:say(util.i18nFormat(errors.ITEM_ONLY_USE_ONCE))
            return
        end
    end

    self:useItemEffect(id, count, itemCfg)
    self:costItemNum(item, count, { logType=gamelog.ITEM_USE })

    if itemCfg.unique and itemCfg.unique == 1 then
        gg.shareProxy:send("setUsedItem",  self.player.pid, item.cfgId)
    end

    return true
end

--- ""
--@param[type=integer] id ""id
--@param[type=integer] count ""
function ItemBag:useItem(id, count)
    local item = self.items[id]
    if not item then
        self.player:say(util.i18nFormat(errors.ITEM_NOT_EXIST))
        return
    end
    local itemCfg = self:getItemCfg(item.cfgId)
    if not itemCfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    if itemCfg.canUse ~= 1 then
        self.player:say(util.i18nFormat(errors.ITEM_CANNOT_USE))
        return
    end
    -- ""
    if itemCfg.unique and itemCfg.unique == 1 then
        local ret = gg.shareProxy:call("getUsedItem",  self.player.pid, item.cfgId)
        if ret == "1" then
            self.player:say(util.i18nFormat(errors.ITEM_ONLY_USE_ONCE))
            return
        end
    end
    
    if itemCfg.useNeedBaseLevel then -- ""
        local baselLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
        if baselLevel < itemCfg.useNeedBaseLevel then
            self.player:say(util.i18nFormat(errors.ITEM_NOT_BASE_LEVEL))
            return
        end
    end

    if count <= 0 or count > item.num then
        self.player:say(util.i18nFormat(errors.ITEM_COUNT_LESS))
        return
    end
    self:useItemEffect(id, count, itemCfg)
    self:costItemNum(item, count, { logType=gamelog.ITEM_USE })

    if itemCfg.unique and itemCfg.unique == 1 then
        gg.shareProxy:send("setUsedItem",  self.player.pid, item.cfgId)
    end

    gg.client:send(self.player.linkobj,"S2C_Player_UseItem",{cfgId = item.cfgId, count = count})
end

function ItemBag:useItemEffect(id, count, itemCfg)
    for i=1,count do
        for _, cfgId in pairs(itemCfg.effect) do
            local effectCfg = self:getItemEffectCfg(cfgId)
            -- ""
            if effectCfg.effectType == constant.ITEM_EFFECT_TYPE_RES then
                local resDict = {}
                local addRes = effectCfg.value
                if addRes and next(addRes) then
                    local resCfgId = math.floor(tonumber(addRes[1]))
                    local value = math.floor(tonumber(addRes[2]))
                    resDict[resCfgId] = value
                    self.player.resBag:addResDict(resDict, { logType=gamelog.ITEM_USE, extraId = id })
                end
            end

            -- ""
            if effectCfg.effectType == constant.ITEM_EFFECT_TYPE_HERO then
                local addHero = effectCfg.value
                if addHero and next(addHero) then
                    local heroCfgId = math.floor(tonumber(addHero[1]))
                    local quality = math.floor(tonumber(addHero[2]))
                    local level = math.floor(tonumber(addHero[3]))
                    local life = ggclass.Hero.randomHeroLife(quality)
                    local param = {
                        cfgId = heroCfgId,
                        quality = quality,
                        level = level,
                        life = life,
                        curLife = life,
                    }
                    local hero = self.player.heroBag:newHero(param)
                    if hero then
                        local ret = self.player.heroBag:addHero(hero, { logType = gamelog.ITEM_USE, notNotify = false })
                    end
                end
            end

            -- ""
            if effectCfg.effectType == constant.ITEM_EFFECT_TYPE_WARSHIP then
                local addWarShip = effectCfg.value
                if addWarShip and next(addWarShip) then
                    local heroCfgId = math.floor(tonumber(addWarShip[1]))
                    local quality = math.floor(tonumber(addWarShip[2]))
                    local level = math.floor(tonumber(addWarShip[3]))
                    local life = ggclass.WarShip.randomWarShipLife(quality)
                    local param = {
                        cfgId = heroCfgId,
                        quality = quality,
                        level = level,
                        life = life,
                        curLife = life,
                    }
                    local warship = self.player.warShipBag:newWarShip(param)
                    if warship then
                        local ret = self.player.warShipBag:addWarShip(warship, { logType = gamelog.ITEM_USE, notNotify = false })
                    end
                end
            end

            -- ""
            if effectCfg.effectType == constant.ITEM_EFFECT_TYPE_CARD then
                local addCard = effectCfg.value
                if addCard and next(addCard) then
                    self:addItem(addCard[1], addCard[2], {logType = gamelog.ITEM_USE})
                end
            end

            -- ""
            if effectCfg.effectType == constant.ITEM_EFFECT_TYPE_BUILD_QUEUE then
                self.player.rechargeActivityBag:addBuildQueueTimeByTime(effectCfg.value[1])
            end

            -- ""
            if effectCfg.effectType == constant.ITEM_EFFECT_TYPE_BUILD then
                local addBuild = effectCfg.value
                if addBuild and next(addBuild) then
                    local heroCfgId = math.floor(tonumber(addBuild[1]))
                    local quality = math.floor(tonumber(addBuild[2]))
                    local level = math.floor(tonumber(addBuild[3]))
                    local life = ggclass.Build.randomBuildLife(quality)
                    local param = {
                        cfgId = heroCfgId,
                        quality = quality,
                        level = level,
                        life = life,
                        curLife = life,
                        chain = constant.BUILD_CHAIN_TOWER,
                    }
                    local build = self.player.buildBag:newBuild(param)
                    if build then
                        local ret = self.player.buildBag:addBuild(build, { logType = gamelog.ITEM_USE, notNotify = false })
                    end
                end
            end
        end
    end
end

function ItemBag:dismantleSkillCard(skillCardData)
    if not next(skillCardData) then
        return
    end
    local getItemDict = {}
    local resDict = {}
    for _,skillCard in pairs(skillCardData) do
        local itemDict = {}
        itemDict, resDict = self:resolveItem(skillCard.id, skillCard.num)
        if next(itemDict) and next(resDict) then
            table.insert(getItemDict, itemDict)
        end
    end
    local items = {}
    for k,v in pairs(getItemDict) do
       for kk,vv in pairs(v) do
            table.insert(items, vv)
       end
    end
    local resInfo = {}
    for cfgId,num in pairs(resDict) do
        if num > 0 then
            table.insert(resInfo, { resCfgId = cfgId, count = num})
        end
    end
    gg.client:send(self.player.linkobj,"S2C_Player_DismantleReward", { result = true, items = items})
    if next(resInfo) then
        gg.client:send(self.player.linkobj, "S2C_Player_TipNote",  { tipType = 1, resInfo = resInfo })
    end
    
end

function ItemBag:sellSkillCard(itemData)
    local delItems = {}
    local rewardCount = 0
    for _,data in ipairs(itemData) do
        -- ""
        local item = self.items[data.id]
        if not item then
            self.player:say(util.i18nFormat(errors.ITEM_NOT_EXIST))
            return
        end
        if not self:isItemEnough(item.cfgId, data.num) then
            return
        end
        local itemCfg = self:getItemCfg(item.cfgId)
        if not itemCfg then
            self.player:say(util.i18nFormat(errors.ITEM_CFG_NOT_EXIST))
            return
        end
        local skillCfg = gg.getExcelCfgByFormat("skillConfig", itemCfg.skillCfgID[1], itemCfg.skillCfgID[2])
        -- ""
        local sellingPrice = gg.getGlobalCfgTableValue("SellingPrice", {})
        local resNum = sellingPrice[skillCfg.quality]
        rewardCount = rewardCount + math.floor(resNum * data.num)
        table.insert(delItems, {item = item, num = data.num})
    end
    for _,data in pairs(delItems) do
        self:costItemNum(data.item, data.num, { logType=gamelog.SELL_ITEM })
    end
    self.player.resBag:addRes(constant.RES_STARCOIN, rewardCount, {logType=gamelog.SELL_ITEM})
    local resInfo = {}
    table.insert(resInfo, { resCfgId = constant.RES_STARCOIN, count = rewardCount})
    resInfo.resCfgId = constant.RES_STARCOIN
    gg.client:send(self.player.linkobj, "S2C_Player_TipNote",  { tipType = 1, resInfo = resInfo })
end

function ItemBag:packItems()
    local itemData = {}
    for id,item in pairs(self.items) do
        table.insert(itemData, item:pack())
    end
    return itemData
end

--- ""
function ItemBag:expandItemBag()
    
end

function ItemBag:onSecond()
end

function ItemBag:onload()
    
end

function ItemBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_ItemBag",{expandSpace=self.expandSpace, maxSpace=self.maxSpace, items=self:packItems()})
end

return ItemBag