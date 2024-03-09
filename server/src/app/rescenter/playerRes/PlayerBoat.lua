local PlayerBoat = class("PlayerBoat")

function PlayerBoat:ctor(param)
    self.dirty = false
    self.savename = "player_boat"
    self.savetick = 300
    self.id = param.id or skynet.config.id
    self.pid = param.pid or 0
    self.currencies = {}
    self.items = {}
    self.boatPacks = {}
end

function PlayerBoat:serialize()
    local data = {}
    data.id = self.id
    data.pid = self.pid
    data.currencies = {}
    data.items = {}
    data.boatPacks = {}
    for k, v in pairs(self.items) do
        table.insert(data.items, v:serialize())
    end
    for k, v in pairs(self.currencies) do
        table.insert(data.currencies, v)
    end
    for k, v in pairs(self.boatPacks) do
        table.insert(data.boatPacks, v)
    end
    return data
end

function PlayerBoat:deserialize(data)
    self.id = data.id or skynet.config.id
    self.pid = data.pid or 0
    self.currencies = {}
    self.items = {}
    if data.items and next(data.items) then
        for k, v in pairs(data.items) do
            local item = ggclass.Item.create(v)
            if item then
                item:deserialize(v)
                self.items[item.id] = item
            end
        end
    end
    if data.currencies and next(data.currencies) then
        for k, v in pairs(data.currencies) do
            self.currencies[v.resCfgId] = self.currencies[v.resCfgId] or {resCfgId=v.resCfgId, count=0}
            self.currencies[v.resCfgId].count = self.currencies[v.resCfgId].count + v.count
        end
    end
end

function PlayerBoat:pack()
    local data = {}
    data.currencies = {}
    data.items = {}
    for k, v in pairs(self.items) do
        table.insert(data.items, v:pack())
    end
    for k, v in pairs(self.currencies) do
        table.insert(data.currencies, v)
    end
    return data
end

--,
function PlayerBoat:createBoatPack()
    local boatId = snowflake.uuid()
    local data = self:pack()
    data.boatId = boatId
    self.boatPacks[boatId] = data
    self.currencies = {}
    self.items = {}
    self.dirty = true
    return boatId
end

function PlayerBoat:getBoatPacks(ids)
    local packs = {}
    for _, id in pairs(ids) do
        assert(self.boatPacks[id], "boatPack["..id.."] is nil")
        table.insert(packs, self.boatPacks[id])
    end
    return packs
end

function PlayerBoat:getAllBoatPacks()
    local packs = {}
    for _, v in pairs(self.boatPacks) do
        table.insert(packs, v)
    end
    return packs
end

function PlayerBoat:isBoatIdsExist(ids)
    for _, id in pairs(ids) do
        if not self.boatPacks[id] then
            return false
        end
    end
    return true
end

function PlayerBoat:removeBoatPacks(ids)
    for _, id in pairs(ids) do
        self:removeBoatPack(id)
    end
end

function PlayerBoat:removeBoatPack(id)
    if self.boatPacks[id] then
        self.boatPacks[id] = nil
        self.dirty = true
    end
end

-- 
--@return newResData 
function PlayerBoat:reset()
    local oldResData = self:pack()
    self.currencies = {}
    self.items = {}
    self.dirty = true
    return oldResData
end

-- 
--@param[type=table] currencyData 
--@return
function PlayerBoat:addCurrency(currencyData)
    assert(currencyData and currencyData.resCfgId, "currencyData is nil or currencyData no attr")
    if self.currencies[currencyData.resCfgId] then
        self.currencies[currencyData.resCfgId].count = self.currencies[currencyData.resCfgId].count + currencyData.count
    else
        self.currencies[currencyData.resCfgId] = {resCfgId=currencyData.resCfgId, count =currencyData.count}
    end
    self.dirty = true
end


-- 
--@param[type=table] itemData 
--@return
function PlayerBoat:addItem(itemData)
    local cfg = ggclass.Item.getItemCfg(itemData.cfgId)
    if self.items[itemData.id] then
        if cfg.overlay == 1 then --
            self.items[itemData.id].num = self.items[itemData.id].num + itemData.num
        else
            assert(self.items[itemData.id] == nil, "item has exist")
        end
    else
        local item = ggclass.Item.create(itemData)
        item:deserialize(itemData)
        self.items[item.id] = item
    end
    self.dirty = true
end

-- ()
--@param[type=table] resData 
--@return
function PlayerBoat:addRes(resData)
    if resData.currencies and next(resData.currencies) then
        for k, v in pairs(resData.currencies) do
            self:addCurrency(v)
        end
    end
    if resData.items and next(resData.items) then
        for k, v in pairs(resData.items) do
            self:addItem(v)
        end
    end
    return self:pack()
end


function PlayerBoat:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    gg.dbmgr:getdb().player_boat:update({pid=self.pid}, {["$set"] = data}, true, false)
    self.dirty = false
end

function PlayerBoat:syncBoatData(boatIds)
    local leftBoatIds = {}
    for k, boatId in pairs(boatIds) do
        if self.boatPacks[boatId] then
            self.boatPacks[boatId] = nil
            self.dirty = true
        end
    end
    for k, v in pairs(self.boatPacks) do
        leftBoatIds[v.boatId] = true
    end
    return leftBoatIds
end

return PlayerBoat