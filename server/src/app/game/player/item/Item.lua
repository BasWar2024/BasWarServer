local Item = class("Item")

function Item.getItemCfg(cfgId)
    local itemCfg = cfg.get("etc.cfg.item")
    return itemCfg[cfgId]
end

function Item.create(param)
    return Item.new(param)
end

function Item:ctor(param)
    assert(param.cfgId, "param.cfgId is nil")
    local itemCfg = Item.getItemCfg(param.cfgId)
    self.id = param.id or snowflake.uuid()
    self.cfgId = param.cfgId or 0
    self.num = param.num or 0
    self.itemType = itemCfg.itemType or 0
    self.targetCfgId = param.targetCfgId or 0
    self.targetLevel = param.targetLevel or 0
    self.targetQuality = param.targetQuality
    self.skillLevel1 = param.skillLevel1 or 0
    self.skillLevel2 = param.skillLevel2 or 0
    self.skillLevel3 = param.skillLevel3 or 0
    self.skillLevel4 = param.skillLevel4 or 0
    self.skillLevel5 = param.skillLevel5 or 0
    self.life = param.life or 0
    self.curLife = param.curLife or 0
    self.ref = param.ref or 0 --0- 1- 2-
end

function Item:canOverlay()
    local itemCfg = Item.getItemCfg(self.cfgId)
    if itemCfg.overlay == 1 then
        return true
    end
    return false
end

function Item:overlayMaxNum()
    local itemCfg = Item.getItemCfg(self.cfgId)
    return itemCfg.maxNum
end

function Item:serialize()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.itemType = self.itemType
    data.num = self.num
    data.targetCfgId = self.targetCfgId
    data.targetLevel = self.targetLevel
    data.targetQuality = self.targetQuality
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.skillLevel4 = self.skillLevel4
    data.skillLevel5 = self.skillLevel5
    data.life = self.life
    data.curLife = self.curLife
    data.ref = self.ref
    return data
end

function Item:deserialize(data)
    self.id = data.id or self.id
    self.cfgId = data.cfgId or self.cfgId
    self.itemType = data.itemType or self.itemType
    self.num = data.num or 0
    self.targetCfgId = data.targetCfgId or 0
    self.targetLevel = data.targetLevel or 0
    self.targetQuality = data.targetQuality or 0
    self.skillLevel1 = data.skillLevel1 or 0
    self.skillLevel2 = data.skillLevel2 or 0
    self.skillLevel3 = data.skillLevel3 or 0
    self.skillLevel4 = data.skillLevel4 or 0
    self.skillLevel5 = data.skillLevel5 or 0
    self.life = data.life or 0
    self.curLife = data.curLife or 0
    self.ref = data.ref or 0
end

function Item:pack()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.num = self.num
    data.targetCfgId = self.targetCfgId
    data.targetLevel = self.targetLevel
    data.targetQuality = self.targetQuality
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.skillLevel4 = self.skillLevel4
    data.skillLevel5 = self.skillLevel5
    data.life = self.life
    data.curLife = self.curLife
    data.ref = self.ref
    return data
end

function Item:setAttr(keyName, value)
    assert(self[keyName] and type(self[keyName]) ~= "function")
    self[keyName] = value
end

function Item:setRef(ref)
    self.ref = ref
end

function Item:getRef()
    return self.ref
end

function Item:isUsing()
    return self.ref > constant.ITEM_REF_NONE
end

return Item