local cchannels = class("cchannels")

function cchannels:ctor(dispatch)
    -- ""
    self.channels = {}
    self.name_channels = {}                         -- ""
    self.node = skynet.config.id                -- ""
    self.nodeid = snowflake.node(self.node)
    self.dispatch = dispatch
    self.address = skynet.self()
    self.id = 0
end

function cchannels:get(id)
    return self.channels[id]
end

function cchannels:genid()
    local uuid
    repeat
        self.id = (self.id + 1) & 0xffffffff
        if self.id == 0 then
            self.id = 1
        end
        uuid = skynet.compose_uuid(self.nodeid,self.address,self.id)
    until self.channels[uuid] == nil
    return uuid
end

--- ""
function cchannels:new_channel(kind)
    local id = self:genid()
    local channel = ggclass.cchannel.new({
        id = id,
        dispatch=self.dispatch,
        kind=kind,
    })
    return self:add(channel)
end

function cchannels:add(channel)
    local id = channel.id
    self.channels[id] = channel
    return id
end

--- ""
function cchannels:del(id)
    local channel = self:get(id)
    if not channel then
        return
    end
    channel:destroy()
    self.channels[id] = nil
    local name = channel.name
    if name then
        self.name_channels[name] = nil
    end
end

--- ""
function cchannels:publish(id,...)
    local is_remote,node,address = self:is_remote(id)
    if is_remote then
        gg.cluster:send(node,address,"api","channel_publish",id,...)
        return
    end
    self:local_publish(id,...)
end

function cchannels:local_publish(id,...)
    local channel = self:get(id)
    if not channel then
        return
    end
    channel:publish(...)
end

--- ""
function cchannels:subscribe(id,who)
    local channel = self:get(id)
    if not channel then
        local is_remote,node,address = self:is_remote(id)
        if is_remote then
            channel = ggclass.cchannel.new({
                id = id,
                dispatch = self.dispatch,
            })
            self:add(channel)
            gg.cluster:send(node,address,"exec","gg.api.channel_subscribe",id,skynet.globaladdress())
        else
            return
        end
    end
    channel:subscribe(who)
end

--- ""
function cchannels:unsubscribe(id,who)
    local channel = self:get(id)
    if not channel then
        return
    end
    channel:unsubscribe(who)
    if next(channel.subscribers) then
        return
    end
    local is_remote,node,address = self:is_remote(id)
    if not is_remote then
        return
    end
    gg.cluster:send(node,address,"exec","gg.api.channel_unsubscribe",id,skynet.globaladdress())
    -- "",""
    self:del(id)
end

function cchannels:is_remote(id)
    local nodeid,address,sequence = skynet.decompose_uuid(id)
    return nodeid ~= self.nodeid,snowflake.node(nodeid),address,sequence
end

--- ""
function cchannels:name_channel(name,id)
    local channel = self:get(id)
    if not channel then
        return false
    end
    assert(not self:query_channel(name))
    channel.name = name
    self.name_channels[name] = channel
    return true
end

--- ""
function cchannels:query_channel(name)
    return self.name_channels[name]
end

function cchannels:mark_delay(id,time,max_length,drop)
    local channel = self:get(id)
    if not channel then
        return
    end
    channel:mark_delay(time,max_length,drop)
end

return cchannels