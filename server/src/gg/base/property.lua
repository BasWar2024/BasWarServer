---"": cproperty,"","",""cdatabaseable,ctoday,cthisweek,cthistemp""
---"",""rpg"",""
--@script gg.base.property
--@author sundream
--@release 2020/03/11 14:00:00

local cproperty = {}

local cproperty_meta = {
    __index = function (self,key)
        if cproperty[key] ~= nil then
            return cproperty[key]
        end
        return self:get(key)
    end,
    __newindex = function (self,key,value)
        if value == nil then
            self:delete(key)
        else
            self:set(key,value)
        end
    end,
}


--[[
local constraits = {
    key1 = {
        pack = true,         -- ""
        serialize = true,    -- ""
        default = 0,         -- ""
        id = 1,              -- ""id("")
        ttl = nil            -- ""("","")
    }
}
]]
function cproperty.new(constraits)
    local self = {
        constraits = constraits or {},
        time = {},
        data = {},
    }
    setmetatable(self, cproperty_meta)
    self:clear()
    return self
end

function cproperty:clear()
    self.time = {}
    self.data = {}
    for key,constrait in pairs(self.constraits) do
        self:_set(key,constrait.default)
    end
end

function cproperty:register(callbacks)
    if callbacks.on_update then
        rawset(self,"on_update",callbacks.on_update)
    end
    if callbacks.on_delete then
        rawset(self,"on_delete",callbacks.on_delete)
    end
    if callbacks.now then
        rawset(self,"now",callbacks.now)
    end
end

function cproperty:check()
    for key in pairs(self.time) do
        self:check_expire(key)
    end
end

function cproperty:serialize()
    self:check()
    local time = {}
    local data = {}
    for key,constrait in pairs(self.constraits) do
        if constrait.serialize and self.data[key] ~= nil then
            time[key] = self.time[key]
            data[key] = self.data[key]
        end
    end
    return {
        time = time,
        data = data,
    }
end

function cproperty:deserialize(data)
    self.time = data.time
    self.data = data.data
end

function cproperty:pack()
    self:check()
    local data = {}
    for key,constrait in pairs(self.constraits) do
        if constrait.pack and self.data[key] ~= nil then
            table.insert(data,{
                key = key,
                id = constrait.id,
                value = self.data[key],
                time = self.time[key],
            })
        end
    end
    return data
end

function cproperty:now()
    return os.time()
end

function cproperty:get(key)
    self:check_expire(key)
    return self.data[key]
end

function cproperty:set(key,value)
    local old_value = self:_set(key,value)
    if self.on_update then
        self:on_update(key,old_value,value)
    end
end

function cproperty:_set(key,value)
    self:check_expire(key)
    local old_value = self.data[key]
    self.data[key] = value
    if not self.time[key] then
        local constrait = self.constraits[key]
        if constrait and constrait.ttl then
            self.time[key] = self:now() + constrait.ttl
        end
    end
    return old_value
end

function cproperty:delete(key,reason)
    self.time[key] = nil
    self.data[key] = nil
    if self.on_delete then
        self:on_delete(key,reason)
    end
end

function cproperty:add(key,value)
    self:check_expire(key)
    local new_value = (self.data[key] or 0) + value
    self:set(key,new_value)
end

function cproperty:check_expire(key)
    local ttl = self:ttl(key)
    if ttl and ttl <= 0 then
        self:delete(key,"expire")
        return false
    end
    return true
end

function cproperty:ttl(key)
    local expire = self.time[key]
    if not expire then
        return
    end
    return expire - self:now()
end

function cproperty:expire(key,ttl)
    self:expireat(key,self:now()+ttl)
end

function cproperty:expireat(key,expire)
    self.time[key] = expire
end

return cproperty