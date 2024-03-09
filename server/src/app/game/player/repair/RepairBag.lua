local RepairBag = class("RepairBag")

function RepairBag:ctor(param)
    self.player = param.player
    self.repairItems = {}
end

function RepairBag:serialize()
    local data = {}
    data.repairItems = {}
    for _, item in pairs(self.repairItems) do
        table.insert(data.repairItems, item:serialize())
    end
    return data
end

function RepairBag:deserialize(data)
    for _, v in pairs(data.repairItems) do
        v.player = self.player
        local item = ggclass.RepairItem.new(v)
        if item then
            item.player = self.player
            item:deserialize(v)
            self.repairItems[v.id] = item
        end
    end
end

function RepairBag:pack()

end

function RepairBag:isItemInRepair(id)
    local repairItem = self.repairItems[id]
    if not repairItem then
        return false
    end
    return repairItem:getLessTick() > 0
end

function RepairBag:packRepairItems()
    local repairItems = {}
    for _, item in pairs(self.repairItems) do
        table.insert(repairItems, item:pack())
    end
    return repairItems
end

function RepairBag:getRepairItems()
    gg.client:send(self.player.linkobj,"S2C_Player_RepairItems",{items=self:packRepairItems()})
end


--- repairItemcost
--@param[type=integer] ids id
--@return[type=table]
function RepairBag:getRepairItemAndCost(id)
    local item = self.player.itemBag:getItem(id)
    if not item then
        return
    end
    if item.life <= 0 then
        return
    end
    if item.curLife >= item.life then
        return
    end
    local repairItem1 = self.repairItems[id]
    if repairItem1 then
        return
    end
    local repairCount = item.life - item.curLife
    local repairCost = gg.getGlobalCgfIntValue("RepairCostPerLife", 5) * repairCount
    local repairTime = gg.getGlobalCgfIntValue("RepairTimePerLife", 600) * repairCount
    if not self.player.resBag:enoughRes(constant.RES_MIT, repairCost) then
        self.player:say(i18n.format("less mit"))
        return
    end
    self.player.resBag:costRes(constant.RES_MIT, repairCost)

    repairItem1 = ggclass.RepairItem.new({
        player = self.player,
        id  = item.id,
        life = item.life,
        curLife = item.curLife,
        cfgId = item.targetCfgId,
    })
    item:setRef(constant.ITEM_REF_REPAIR)
    self.repairItems[item.id] = repairItem1
    repairItem1:setNextTick(repairTime)
    return repairItem1, repairCost
end

--- ()
--@param[type=integer] ids id
--@return[type=table]
function RepairBag:repair(ids)
    local totalCost = 0
    local repairItems = {}
    for _, v in pairs(ids) do
        local item, cost = self:getRepairItemAndCost(v)
        if item and cost then
            totalCost = totalCost + cost
            table.insert(repairItems, item)
        end
    end

    local successItems = {}
    for _, v in pairs(repairItems) do
        table.insert(successItems, v:pack())
    end
    if totalCost > 0 and #successItems > 0 then
        gg.client:send(self.player.linkobj,"S2C_Player_RepairReturn",{ successItems=successItems, totalCost=totalCost} )
    end
end

--- 
--@param[type=integer] ids id
--@return[type=table]
function RepairBag:repairSpeed(id)
    local repairItem = self.repairItems[id]
    if repairItem then -- 
        if repairItem:getLessTick() <= 0 then
            self.player:say(i18n.format("this item has repaired"))
            return
        end
        --
        local leftHour = math.ceil(repairItem:getLessTick() / 3600)
        local repairCost = gg.getGlobalCgfIntValue("RepairSpeedCost", 5) * leftHour
        if not self.player.resBag:enoughRes(constant.RES_MIT, repairCost) then
            self.player:say(i18n.format("less mit"))
            return
        end
        repairItem:setNextTick(0)
        repairItem:checkRepairFinish()
        self.player.resBag:costRes(constant.RES_MIT, repairCost)
        self.repairItems[id] = nil
    else --
        --
        local item = self.player.itemBag:getItem(id)
        if not item then
            self.player:say(i18n.format("you have not this item"))
            return
        end
        local repairCount = item.life - item.curLife
        local repairTime = gg.getGlobalCgfIntValue("RepairTimePerLife", 600) * repairCount
        local leftHour = math.ceil(repairTime / 3600)
        local repairCost = gg.getGlobalCgfIntValue("RepairSpeedCost", 5) * leftHour
        if not self.player.resBag:enoughRes(constant.RES_MIT, repairCost) then
            self.player:say(i18n.format("less mit"))
            return
        end
        item:setAttr("curLife", item.life)
        item:setRef(constant.ITEM_REF_NONE)
        self.player.resBag:costRes(constant.RES_MIT, repairCost)
        gg.client:send(self.player.linkobj,"S2C_Player_ItemUpdate",{item=item:pack()})
        gg.client:send(self.player.linkobj,"S2C_Player_RepairItemDel",{id=self.id})
    end

end

function RepairBag:checkRepairItemFinish()
    local finishList = {}
    for id, item in pairs(self.repairItems) do
        if item:checkRepairFinish() then
            table.insert(finishList, id)
        end
    end
    for _, id in pairs(finishList) do
        self.repairItems[id] = nil
    end
end

function RepairBag:onSecond()
    self:checkRepairItemFinish()
end

function RepairBag:onload()
    self:checkRepairItemFinish()
end

function RepairBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_RepairItems",{items=self:packRepairItems()})
end

return RepairBag