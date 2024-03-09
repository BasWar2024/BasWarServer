local RepairItem = class("RepairItem")

function RepairItem.create(param)
    return RepairItem.new(param)
end

function RepairItem:ctor(param)
    self.player = assert(param.player, "param must with player")
    self.id = assert(param.id, "param must with id")               -- id
    self.life = param.life or 0                                    -- 
    self.curLife = param.curLife or 0                              -- 
    self.cfgId = param.cfgId or 0                                  -- 1- 2- 3-
    self.nextTick = param.nextTick or 0                            -- 
end

function RepairItem:serialize()
    local data = {}
    data.id = self.id
    data.life = self.life
    data.curLife = self.curLife
    data.cfgId = self.cfgId
    data.nextTick = self.nextTick
    return data
end

function RepairItem:deserialize(data)
    self.id = data.id
    self.life = data.life or 0
    self.curLife = data.curLife or 0
    self.cfgId = data.cfgId or 0
    self.nextTick = data.nextTick or 0
end

function RepairItem:pack()
    local data = {}
    data.id = self.id
    data.life = self.life
    data.curLife = self.curLife
    data.cfgId = self.cfgId
    data.lessTick = self:getLessTick()
    return data
end

function RepairItem:getLessTick()
    return math.ceil((self.nextTick - skynet.timestamp())/1000)
end

--- needTick
function RepairItem:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick*1000
end

function RepairItem:checkRepairFinish()
    local repairTime = gg.getGlobalCgfIntValue("RepairTimePerLife", 600)
    if skynet.timestamp() < self.nextTick then
        return false
    end
    if self.nextTick <= 0 then
        return true
    end
    local item = self.player.itemBag:getItem(self.id)
    if not item then
        return true
    end
    item:setAttr("curLife", self.life)
    item:setRef(constant.ITEM_REF_NONE)
    self.nextTick = 0
    gg.client:send(self.player.linkobj,"S2C_Player_ItemUpdate",{item=item:pack()})
    gg.client:send(self.player.linkobj,"S2C_Player_RepairItemDel",{id=self.id})
    return true
end

return RepairItem
