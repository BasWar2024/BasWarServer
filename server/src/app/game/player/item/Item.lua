local Item = class("Item")

function Item.getItemCfg(cfgId)
    local itemCfg = cfg.get("etc.cfg.item")
    return itemCfg[cfgId]
end

function Item.create(param)
    local itemCfg = Item.getItemCfg(param.cfgId)
    if not itemCfg then
        return nil
    end
    return Item.new(param)
end

function Item:ctor(param)
    self.player = param.player
    self.id = param.id or snowflake.uuid()
    self.cfgId = param.cfgId or 0
    self.num = param.num or 0
    self.itemType = param.itemType or 0
    self.name = param.name or ""
    if self.cfgId > 0 then
        local itemCfg = Item.getItemCfg(param.cfgId)
        if itemCfg then
            self.itemType = itemCfg.itemType
            self.name = itemCfg.name
        end
    end
end

function Item:serialize()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.num = self.num
    return data
end

function Item:deserialize(data)
    self.num = data.num or 0
end

function Item:pack()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.num = self.num
    return data
end

function Item:getName()
    return self.name or ""
end

return Item