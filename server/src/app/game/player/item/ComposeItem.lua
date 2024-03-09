local ComposeItem = class("ComposeItem")

-- 
function ComposeItem.getItemProductCfg(cfgId)
    return gg.itemProductCfg[cfgId]
end

function ComposeItem.getLifeCfg(cfgId, quality)
    local lifeCfg = cfg.get("etc.cfg.life")
    for k, v in pairs(lifeCfg) do
        if v.cfgId == cfgId and v.quality == quality then
            return v
        end
    end
end

--- 
function ComposeItem.decrProductTotal(quality)
    return gg.shareMgr:call("decrProductTotal", quality)
end

function ComposeItem.create(param)
    return ComposeItem.new(param)
end

function ComposeItem:ctor(param)
    self.player = param.player
    self.item = param.item or {}                      --
    self.nextTick = param.nextTick or 0               --
    self.hour = param.hour or 0                       --
end

function ComposeItem:serialize()
    local data = {}
    data.item = self.item:serialize()
    data.nextTick = self.nextTick
    data.hour = self.hour
    return data
end

function ComposeItem:deserialize(data)
    local item = self.player.itemBag:newItem(data.item)
    item:deserialize(data.item)
    self.item = item or {}
    self.nextTick = data.nextTick or 0
    self.hour = data.hour or 0
end

function ComposeItem:pack()
    local data = {}
    data.item = self.item:pack()
    data.lessTick = self:getLessTick()
    data.hour = self.hour
    return data
end

function ComposeItem:getLessTick()
    return math.ceil((self.nextTick - skynet.timestamp())/1000)
end

--- nextTick->
function ComposeItem:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick*1000
end

function ComposeItem:initNextTick()
    self.nextTick = 0
end

function ComposeItem:checkComposeFinish(notNotify)
    if self.nextTick <= 0 then
        return true
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.nextTick then
        return false
    end
    local itemCfg = ggclass.Item.getItemCfg(self.item.cfgId)
    if not itemCfg then
        return true
    end

    local modifiedItems
    local productCfg = ComposeItem.getItemProductCfg(self.item.cfgId)
    if itemCfg.itemType <= constant.ITEM_SOLIDER_PIECES then --
        local product = table.chooseByValue(productCfg.product, function(v)
            return v[2]
        end)
        local itemCfgId = product[1]
        local targetCfg = ggclass.Item.getItemCfg(itemCfgId)
        if not targetCfg then
            return false
        end
        _, modifiedItems = self.player.itemBag:addItem(itemCfgId, 1, {}, {reason=""})
    elseif itemCfg.itemType <= constant.ITEM_BUILD_PAPER and itemCfg.itemType > constant.ITEM_SOLIDER_PIECES then
        local productItem
        while true do
            productItem = table.chooseByValue(productCfg.product, function(v)
                return v[3]
            end)
            if productItem[2] == 1 then
                break
            end
            local leftTotal = ComposeItem.decrProductTotal(productItem[2])
            if leftTotal > 0 then
                break
            end
            productItem[3] = 0
        end
        local itemCfgId
        local targetParam
        if itemCfg.itemType == constant.ITEM_WAR_SHIP_PAPER then
            local warShipCfg = ggclass.WarShip.getWarShipCfg(productItem[1], productItem[2], 1)
            if not warShipCfg then
                self.player:say(string.format("not this warShip config, cfgId=%d quality=%d level=1", productItem[1], productItem[2]))
                return false
            end
            itemCfgId = warShipCfg.itemCfgId
            local warShip = self.player.warShipBag:generateWarShip(productItem[1], productItem[2])
            targetParam = {
                targetCfgId = warShip.cfgId,
                targetLevel = warShip.level,
                targetQuality = warShip.quality,
                life = warShip.life,
                curLife = warShip.curLife,
                skillLevel1 = warShip.skillLevel1,
                skillLevel2 = warShip.skillLevel2,
                skillLevel3 = warShip.skillLevel3,
                skillLevel4 = warShip.skillLevel4,
                skillLevel5 = warShip.skillLevel5,
            }
        elseif itemCfg.itemType == constant.ITEM_HERO_PAPER then
            local heroCfg = ggclass.Hero.getHeroCfg(productItem[1], productItem[2], 1)
            if not heroCfg then
                self.player:say(string.format("not this hero config, cfgId=%d quality=%d level=1", productItem[1], productItem[2]))
                return false
            end
            itemCfgId = heroCfg.itemCfgId
            local hero = self.player.heroBag:generateHero(productItem[1], productItem[2])
            targetParam = {
                targetCfgId = hero.cfgId,
                targetLevel = hero.level,
                targetQuality = hero.quality,
                skillLevel1 = hero.skillLevel1,
                skillLevel2 = hero.skillLevel2,
                skillLevel3 = hero.skillLevel3,
                life = hero.life,
                curLife = hero.curLife,
            }
        elseif itemCfg.itemType == constant.ITEM_BUILD_PAPER then
            local buildCfg = ggclass.Build.getBuildCfg(productItem[1], productItem[2], 1)
            if not buildCfg then
                self.player:say(string.format("not this build config, cfgId=%d quality=%d level=1", productItem[1], productItem[2]))
                return false
            end
            itemCfgId = buildCfg.itemCfgId
            local build = self.player.buildBag:generateBuild(productItem[1], productItem[2])
            targetParam = {
                targetCfgId = build.cfgId,
                targetLevel = build.level,
                targetQuality = build.quality,
                life = build.life,
                curLife = build.life,
            }
        end
        local targetCfg = ggclass.Item.getItemCfg(itemCfgId)
        if not targetCfg then
            return false
        end
        _, modifiedItems = self.player.itemBag:addItem(itemCfgId, 1, targetParam,{reason=""})
    elseif itemCfg.itemType == constant.ITEM_SOLIDER_PAPER then
        assert(productCfg.product[1], "")
        assert(productCfg.product[1][1], "1")
        local itemCfgId = productCfg.product[1][1]
        local soliderLevel = self.player.buildBag:newSoliderLevel({cfgId=itemCfgId,level=1})
        self.player.buildBag:addSoliderLevel(soliderLevel)
        self.player.buildBag:refreshSoliderLevel()
        self.nextTick = 0
        return true
    end
    self.nextTick = 0
    if not notNotify and modifiedItems and #modifiedItems > 0 then
        local modifiedItem = modifiedItems[1]
        gg.client:send(self.player.linkobj,"S2C_Player_ItemCompose",{id = self.item.id, item = modifiedItem:pack()})
    end
    return true
end

return ComposeItem