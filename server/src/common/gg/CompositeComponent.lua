local CompositeComponent = class("CompositeComponent")

function CompositeComponent:ctor(args)
    self.attrs = {}
    for name,obj in pairs(args) do
        assert(self.attrs[name] == nil)
        self.attrs[name] = true
        self[name] = obj
    end
end

function CompositeComponent:get(name)
    if not self.attrs[name] then
        return
    end
    return self[name]
end

function CompositeComponent:add(name,obj)
    assert(self.attrs[name] == nil)
    self.attrs[name] = true
    self[name] = obj
end

function CompositeComponent:del(name)
    local obj = self:get(name)
    if not obj then
        return
    end
    self.attrs[name] = nil
    self[name] = nil
    return obj
end

function CompositeComponent:deserialize(data)
    if table.isempty(data) then
        return
    end
    for name,attrdata in pairs(data) do
        local obj = self:get(name)
        if obj then
            obj:deserialize(attrdata)
        end
    end
end

function CompositeComponent:serialize()
    local data = {}
    for name in pairs(self.attrs) do
        local obj = self:get(name)
        if obj.serialize then
            data[name] = obj:serialize()
        end
    end
    return data
end

function CompositeComponent:clear()
    for name in pairs(self.attrs) do
        local obj = self:get(name)
        if obj.clear then
            obj:clear()
        end
    end
end

function CompositeComponent:exec(method,...)
    for name in pairs(self.attrs) do
        local obj = self:get(name)
        local func = obj[method]
        if func then
            func(obj,...)
        end
    end
end

return CompositeComponent
