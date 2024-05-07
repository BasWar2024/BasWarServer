--- "",""，""
--@script gg.base.container
--@author sundream
--@release 2018/12/25 10:30:00
local ccontainer = class("ccontainer")

--- ccontainer.new""
--@param[type=table] param
--@return a ccontainer's instance
--@usage
--local container = ccontainer.new({
--  -- ""
--  onclear = xxx,
--  onadd = xxx,
--  ondel = xxx,
--  onupdate = xxx,
--  key2id = xxx,
--  id2key = xxx,
--})
function ccontainer:ctor(param)
    param = param or {}
    self:register(param)
    self.objid = 0
    self.length = 0
    self.objs = {}
end

--- ""
function ccontainer:clear()
    local objs = self.objs
    self.objs = {}
    self.length = 0
    if self.onclear then
        self:onclear(objs)
    end
end

-- ""
function ccontainer:id2key(id)
    return tostring(id)
end

-- ""
function ccontainer:key2id(id)
    return tonumber(id)
end

--- ""
--@param[type=table] data ""
--@param[type=func,opt] loadfunc ""
function ccontainer:deserialize(data,loadfunc)
    if not data or not next(data) then
        return
    end
    self.objid = data.objid
    local objs = data.objs or {}
    local length = 0
    for id,objdata in pairs(objs) do
        id = self:key2id(id)
        local obj
        if loadfunc then
            obj = loadfunc(objdata)
        else
            obj = objdata
        end
        if obj then
            self.objs[id] = obj
            length = length + 1
        end
    end
    self.length = length
end

--- ""
--@param[type=func,opt] savefunc ""
--@return[type=table] ""
function ccontainer:serialize(savefunc)
    local data = {}
    data.objid = self.objid
    local objs = {}
    for id,obj in pairs(self.objs) do
        id = self:id2key(id)
        if savefunc then
            objs[id] = savefunc(obj)
        else
            objs[id] = obj
        end
    end
    data.objs = objs
    return data
end

--- ""
--@param[type=table] callback ""
--@usage
--container:register({
--  onclear = xxx,
--  onadd = xxx,
--  ondel = xxx,
--  onupdate = xxx,
--  key2id = xxx,
--  id2key = xxx,
--})
function ccontainer:register(callback)
    if callback then
        if callback.onclear then
            self.onclear = callback.onclear
        end
        if callback.onadd then
            self.onadd = callback.onadd
        end
        if callback.ondel then
            self.ondel = callback.ondel
        end
        if callback.onupdate then
            self.onupdate = callback.onupdate
        end
        if callback.key2id then
            self.key2id = callback.key2id
        end
        if callback.id2key then
            self.id2key = callback.id2key
        end
    end
end

function ccontainer:genid()
    repeat
        self.objid = self.objid + 1
    until self.objs[self.objid] == nil
    return self.objid
end

--- ""
--@param[type=table] obj ""
--@param[type=int|string,opt] id ""ID,""
--@return[type=int|string] ""ID
function ccontainer:add(obj,id)
    id = id or self:genid()
    assert(self.objs[id]==nil,"Exist Object:" .. tostring(id))
    self.objs[id] = obj
    self.length = self.length + 1
    if self.onadd then
        self:onadd(id,obj)
    end
    return id
end

--- ""
--@param[type=int|string] id ""ID
--@return[type=table] ""ID"",""nil
function ccontainer:del(id)
    local obj = self:get(id)
    if obj then
        self.objs[id] = nil
        self.length = self.length - 1
        if self.ondel then
            self:ondel(id,obj)
        end
        return obj
    end
end

--- ""
--@param[type=int|string] id ""ID
--@param[type=table] attrs ""
function ccontainer:update(id,attrs)
    local obj = self:get(id)
    if obj then
        for k,v in pairs(attrs) do
            obj[k] = v
        end
        if self.onupdate then
            self:onupdate(id,attrs)
        end
    end
end

--- ""
--@param[type=int|string] id ""ID
--@return[type=table] ""ID"",""nil
function ccontainer:get(id)
    return self.objs[id]
end

-- ""
function ccontainer:toArray()
    local t = {}
    for k,v in pairs(self.objs) do
        local temp = gg.deepcopy(v)
        temp._key = k
        table.insert(t,temp)
    end
    return t
end

return ccontainer
