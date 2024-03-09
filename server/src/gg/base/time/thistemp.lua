---: cthistemp
--@script gg.base.time.thistemp
--@author sundream
--@release 2019/3/29 14:00:00

local cdatabaseable = ggclass.cdatabaseable
local cthistemp = class("cthistemp",cdatabaseable)

function cthistemp:ctor()
    cdatabaseable.ctor(self)
    self.time = {}
end

--- 
--@return 
function cthistemp:serialize()
    local data = {}
    data["data"] = self.data
    data["time"] = self.time
    return data
end

--- 
--@param[type=table] data 
function cthistemp:deserialize(data)
    if not data or not next(data) then
        return
    end
    self.data = data["data"]
    self.time = data["time"]
end

--- 
function cthistemp:clear()
    cdatabaseable.clear(self)
    self.time = {}
end

function cthistemp:checkvalid(key)
    local attrs = self:__split(key)
    local expire = self:__getattr(self.time,attrs)
    if expire then
        local now = os.time()
        assert(type(expire) == "number",string.format("not-leaf-node:%s",key))
        if expire <= now then
            self:__setattr(self.time,attrs,nil)
            cdatabaseable.del(self,key)
            return false,nil
        end
    end
    return true,expire
end

--- ,,secs,
--@param[type=string] key 
--@param[type=any] val 
--@param[type=int] secs ,
--@param[type=func,opt] callback 
--@usage thistemp:set("firstset",1,10)
--@usage thistemp:set("firstset",20)    -- 20
--@usage thistemp:set("firstset",10,20) -- 10,20s
function cthistemp:set(key,val,secs)
    local expire = self:getexpire(key)
    local now = os.time()
    local new_expire
    if not expire then
        assert(secs)
        new_expire = now + secs
    else
        if secs then
            new_expire = now + secs
        else
            new_expire = expire
        end
    end
    local oldval = cdatabaseable.set(self,key,val)
    if expire ~= new_expire then
        local attrs = self:__split(key)
        self:__setattr(self.time,attrs,new_expire)
    end
    return oldval,expire
end

--- 
--@param[type=string] key ()
--@param[type=number] val 
--@usage
--      local oldval,expire = thistemp:get(key)
--      if nil == oldval then
--          local new_val = xxx
--          local new_expire = xxx
--          thistemp:set(key,new_val,new_expire)
--      else
--          thistemp:add(key,addval)
--      end
function cthistemp:add(key,val)
    return cdatabaseable.add(self,key,val)
end

--- 
--@param[type=string] key 
--@param[type=any] default 
--@return[type=any] 
--@usage local val = thistemp:get("key",0)
--@usage local val = thistemp:get("k1.k2.k3")
function cthistemp:get(key,default)
    local expire = self:getexpire(key)
    return cdatabaseable.get(self,key,default),expire
end

--- [deprecated] get
cthistemp.query = cthistemp.get

--- 
--@param[type=string] key 
--@return[type=any] 
--@usage thistemp:del("key")
--@usage thistemp:del("k1.k2.k3")
function cthistemp:del(key)
    local attrs = self:__split(key)
    return cdatabaseable.del(self,key),self:__delattr(self.time,attrs)
end

--- [deprecated] del
cthistemp.delete = cthistemp.del

--- 
--@param[type=string] key 
--@return[type=int] 
--@usage local expire = thistemp:getexpire("key")
--@usage local expire = thistemp:getexpire("k1.k2.k3")
function cthistemp:getexpire(key)
    local ok,expire = self:checkvalid(key)
    if not ok then
        return nil
    end
    return expire
end

cthistemp.getexceedtime = cthistemp.getexpire

--- TTL
--@param[type=string] key 
--@return[type=int] TTL,
--@usage local ttl = thistemp:ttl("key")
--@usage local ttl = thistemp:ttl("k1.k2.k3")
function cthistemp:ttl(key)
    local expire = self:getexpire(key)
    if not expire then
        return nil
    end
    return expire - os.time()
end

--- (key)
--@param[type=string] key 
--@param[type=int] expire ,
--@return[type=int] 
function cthistemp:expireat(key,expire)
    local old_expire = self:getexpire(key)
    if not old_expire then
        return
    end
    local now = os.time()
    if expire <= now then
        self:del(key)
    else
        local attrs = self:__split(key)
        self:__setattr(self.time,attrs,expire)
    end
    return old_expire
end

--- (key)
--@param[type=string] key 
--@param[type=int] ttl ,expireat(key,os.time()+ttl)
--@return[type=int] 
function cthistemp:expire(key,ttl)
    return self:expireat(key,os.time()+ttl)
end

cthistemp.delay = cthistemp.expire

return cthistemp
