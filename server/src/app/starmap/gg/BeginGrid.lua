

local BeginGrid = class("BeginGrid", ggclass.Grid)

function BeginGrid:ctor(gridCfg)
    BeginGrid.super.ctor(self, gridCfg)
    self.unionIds = {}
end

function BeginGrid:init()
    local gridCfg = self:getGridCfg()
    assert(gridCfg, "gridCfg not exist")
    local startTime = os.time()
    local ok = self:load_from_db()
    if not ok then
        self:initOwner()
        self.dirty = true
        self:save_to_db()
    end
end

function BeginGrid:deserialize(data)
    BeginGrid.super.deserialize(self, data)
    for i, v in ipairs(data.unionIds or {}) do
        self.unionIds[v] = true
    end
end

function BeginGrid:serialize()
    local data = BeginGrid.super.serialize(self)
    data.unionIds = {}
    for k, v in pairs(self.unionIds) do
        table.insert(data.unionIds, k)
    end
    return data
end

function BeginGrid:isBeginGrid()
    return true
end

function BeginGrid:addUnionId(unionId)
    if self.unionIds[unionId] then
        return
    end
    self.unionIds[unionId] = true
end

function BeginGrid:delUnionId(unionId)
    self.unionIds[unionId] = nil
end

function BeginGrid:hasUnionId(unionId)
    return self.unionIds[unionId]
end

function BeginGrid:hasUnionCount()
    return table.count(self.unionIds)
end

return BeginGrid