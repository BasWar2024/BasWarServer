local PlayerResCost = class("PlayerResCost")

function PlayerResCost:ctor(param)
    self.dirty = false
    self.savename = "player_res_cost"
    self.savetick = 300
    self.id = param.id or skynet.config.id
    self.pid = param.pid or 0
    self.heros = {}     --{id,life}
    self.warShips = {}  --{id, life}
    self.soldiers = {}  --{id, cfgId, life}
    self.costPacks = {}
end

function PlayerResCost:serialize()
    local data = {}
    data.id = self.id
    data.pid = self.pid
    data.heros = {}
    data.warShips = {}
    data.soldiers = {}
    data.costPacks = {}
    for k, v in pairs(self.heros) do
        table.insert(data.heros, v)
    end
    for k,v in pairs(self.warShips) do
        table.insert(data.warShips, v)
    end
    for k,v in pairs(self.soldiers) do
        table.insert(data.soldiers, v)
    end
    for k, v in pairs(self.costPacks) do
        table.insert(data.costPacks, v)
    end
    return data
end

function PlayerResCost:deserialize(data)
    self.id = self.id or skynet.config.id
    self.pid = data.pid or 0
    self.heros = {}
    self.warShips = {}
    self.soldiers = {}
    if data.heros and next(data.heros) then
        for k,v in pairs(data.heros) do
            self.heros[v.id] = v
        end
    end
    if data.warShips and next(data.warShips) then
        for k,v in pairs(data.warShips) do
            self.warShips[v.id] = v
        end
    end
    if data.soldiers and next(data.soldiers) then
        for k, v in pairs(data.soldiers) do
            self.soldiers[v.id..":"..v.cfgId] = v
        end
    end
    if data.costPacks and next(data.costPacks) then
        for k,v in pairs(data.costPacks) do
            self.costPacks[v.costId] = v
        end

    end
end

function PlayerResCost:pack()
    local data = {}
    data.heros = {}
    data.warShips = {}
    data.soldiers = {}
    for k, v in pairs(self.heros) do
        table.insert(data.heros, v)
    end
    for k,v in pairs(self.warShips) do
        table.insert(data.warShips, v)
    end
    for k,v in pairs(self.soldiers) do
        table.insert(data.soldiers, v)
    end
    return data
end

function PlayerResCost:createCostPack()
    local costId = snowflake.uuid()
    local data = self:pack()
    data.costId = costId
    self.costPacks[costId] = data
    self.heros = {}
    self.warShips = {}
    self.soldiers = {}
    self.dirty = true
    return data
end

function PlayerResCost:getCostPacks(ids)
    local packs = {}
    for _, id in pairs(ids) do
        assert(self.costPacks[id], "costPacks["..id.."] is nil")
        table.insert(packs, self.costPacks[id])
    end
    return packs
end

function PlayerResCost:getAllCostPacks()
    local packs = {}
    for _, v in pairs(self.costPacks) do
        table.insert(packs, v)
    end
    return packs
end

function PlayerResCost:isCostIdsExist(ids)
    for _, id in pairs(ids) do
        if not self.costPacks[id] then
            return false
        end
    end
    return true
end

function PlayerResCost:removeCostPacks(ids)
    for _, id in pairs(ids) do
        self:removeCostPack(id)
    end
end

function PlayerResCost:removeCostPack(id)
    if self.costPacks[id] then
        self.costPacks[id] = nil
        self.dirty = true
    end
end

function PlayerResCost:addHero(id, life)
    self.heros[id] = self.heros[id] or {id=id, life=0}
    self.heros[id].life = self.heros[id].life + life
end

function PlayerResCost:addWarShip(id, life)
    self.warShips[id] = self.warShips[id] or {id=id, life=0}
    self.warShips[id].life = self.warShips[id].life + life
end

function PlayerResCost:addSoldier(id, cfgId, life)
    local key = id..":"..cfgId
    self.soldiers[key] = self.soldiers[key] or {id=id, cfgId=cfgId, life=0}
    self.soldiers[key].life = self.soldiers[key].life + life
end

function PlayerResCost:addRes(resData)
    if resData.heros and next(resData.heros) then
        for k, v in pairs(resData.heros) do
            self:addHero(v.id, v.life)
        end
    end
    if resData.warShips and next(resData.warShips) then
        for k, v in pairs(resData.warShips) do
            self:addWarShip(v.id, v.life)
        end
    end
    if resData.soldiers and next(resData.soldiers) then
        for k, v in pairs(resData.soldiers) do
            self:addSoldier(v.id, v.cfgId, v.life)
        end
    end
    return self:pack()
end

function PlayerResCost:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    gg.dbmgr:getdb().player_res_cost:update({pid=self.pid}, {["$set"] = data}, true, false)
    self.dirty = false
end

function PlayerResCost:syncCostData(costIds)
    for k, costId in pairs(costIds) do
        if self.costPacks[costId] then
            self.costPacks[costId] = nil
            self.dirty = true
        end
    end
    local leftCostIds = {}
    for k, v in pairs(self.costPacks) do
        leftCostIds[v.costId] = true
    end
    return leftCostIds
end

return PlayerResCost