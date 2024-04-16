local Brief = class("Brief")

function Brief:ctor(pid)
    self.pid = pid
    self.data = {}
    self.dirty = false
    self.subscribers = {}     -- ""
end

function Brief:serialize()
    local data = gg.deepcopy(self.data)
    for k,v in pairs(data) do
        -- """""",""
        if k:sub(1,2) == "__" then
            data[k] = nil
        end
    end
    return data
end

function Brief:deserialize(data)
    data._id = nil
    self.data = data
end

function Brief:load_from_db()
    local data = gg.mongoProxy.brief:findOne({pid=self.pid})
    assert(data,"unknow brief" .. self.pid.." now="..skynet.timestamp())
    self:deserialize(data)
end

function Brief:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    data.pid = self.pid
    gg.mongoProxy.brief:update({pid = self.pid},data,true,false)
end

function Brief.delete_from_db(pid)
    gg.mongoProxy.brief:delete({pid = pid})
end

function Brief:subscribe(pid)
    if self.subscribers[pid] then
        return false
    end
    self.subscribers[pid] = true
    return true
end

function Brief:unsubscribe(pid)
    self.subscribers[pid] = nil
    if not next(self.subscribers) then
        gg.briefMgr:delBrief(self.pid)
    end
end

function Brief:get(key,default)
    if self.data[key] then
        return self.data[key]
    end
    return default
end

function Brief:_set(attrs)
    self.dirty = true
    for k,v in pairs(attrs) do
        self.data[k] = v
    end
end

function Brief:_del(keys)
    for i,key in ipairs(keys) do
        self.data[key] = nil
    end
end

function Brief:pack()
    return self.data
end

return Brief