---"","",""
--@script gg.base.databaseable
--@author sundream
--@release 2018/12/25 10:30:00
local cdatabaseable = class("cdatabaseable")

--- cdatabaseable.new""
--@usage local data = cdatabaseable.new()
function cdatabaseable:ctor()
    self.loadstate = "unload"
    self.dirty = true
    self.data = {}
end

--- ""
--@return ""
function cdatabaseable:serialize()
    return self.data
end

--- ""
--@param[type=table] data ""
function cdatabaseable:deserialize(data)
    if not data or not next(data) then
        return
    end
    self.data = data
end

--- ""
function cdatabaseable:clear()
    self.dirty = false
    self.data = {}
end

--- ""
--@return[type=bool] ""
function cdatabaseable:isdirty()
    return self.dirty
end

function cdatabaseable:__getattr(data,attrs)
    return table.query(data,attrs)
end

function cdatabaseable:__split(key)
    return string.split(key,".")
end

--- ""
--@param[type=string] key ""
--@param[type=any] default ""
--@return[type=any] ""
--@usage local val = data:get("key",0)
--@usage local val = data:get("k1.k2.k3")
function cdatabaseable:get(key,default)
    local attrs = self:__split(key)
    local val = self:__getattr(self.data,attrs)
    if val ~= nil then
        return val
    else
        return default
    end
end

--- [deprecated] get""
cdatabaseable.query = cdatabaseable.get

function cdatabaseable:__setattr(data,attrs,val)
    local oldval = table.setattr(data,attrs,val)
    self.dirty = true
    return oldval
end

--- ""
--@param[type=string] key ""
--@param[type=any] val ""
--@usage data:set("key",1)
--@usage data:set("k1.k2.k3","hi")
function cdatabaseable:set(key,val)
    local attrs = self:__split(key)
    return self:__setattr(self.data,attrs,val)
end

--- ""
--@param[type=string] key ""("")
--@param[type=number] val ""
--@return[type=any] ""
--@usage data:add("key",1)
function cdatabaseable:add(key,val)
    local oldval = self:get(key)
    local newval
    if oldval == nil then
        newval = val
    else
        newval = oldval + val
    end
    return self:__setattr(self.data,key,newval)
end

function cdatabaseable:__delattr(data,attrs)
    local lastkey = table.remove(attrs)
    local mod = self:__getattr(data,attrs)
    if mod == nil then
        return nil
    end
    local oldval = mod[lastkey]
    mod[lastkey] = nil
    self.dirty = true
    return oldval
end

--- ""
--@param[type=string] key ""
--@return[type=any] ""
--@usage data:del("key")
--@usage data:del("k1.k2.k3")
function cdatabaseable:del(key)
    local attrs = self:__split(key)
    return self:__delattr(self.data,attrs)
end

--- [deprecated] del""
cdatabaseable.delete = cdatabaseable.del

return cdatabaseable
