local profile = require "skynet.profile"
local cprofile = class("cprofile")

function cprofile:ctor()
    self.threshold = tonumber(skynet.config.profile_threshold) or 0.03   -- 30ms
    self.open = false --skynet.config.profile_open == "1"
    self.client = {}
    self.cluster = {}
    self.internal = {}
    self.gm = {}
    self.timer = {}

    self.client_send = {}
    self.cluster_send = {}
    self.cluster_call = {}
    self.internal_send = {}
    self.internal_call = {}

    self.cost = {
        client = self.client,
        cluster = self.cluster,
        internal = self.internal,
        gm = self.gm,
        timer = self.timer,

        client_send = self.client_send,
        internal_send = self.internal_send,
        internal_call = self.internal_call,
        cluster_send = self.cluster_send,
        cluster_call = self.cluster_call,
    }
end

function cprofile:stat(typename,name,onerror,func,...)
    if not name then
        local thread = func
        if type(func) == "table" and func.__name == "functor" then
            thread = func.__fn
        end
        if thread then
            local info = debug.getinfo(thread,"nS")
            if info.name then
                name = info.name
            else
                name = string.format("%s:%s",info.source,info.linedefined)
            end
        end
    end
    profile.start()
    local result = table.pack(xpcall(func,onerror,...))
    local ok = result[1]
    local time = profile.stop()
    local record = self:incr(typename,name)
    record.time = record.time + time
    if not ok then
        record.failcnt = record.failcnt + 1
    else
        if self.threshold and time > self.threshold then
            record.overtimecnt = record.overtimecnt + 1
            logger.logf("info","profile","op=overtime,address=%s,name=%s,time=%ss",skynet.address(skynet.self()),name,time)
        end
    end
    return table.unpack(result)
end

function cprofile:incr(typename,name)
    local container = assert(self[typename],typename)
    local record = container[name]
    if not record then
        record = {
            cnt = 0,
            time = 0,
            failcnt = 0,
            overtimecnt = 0
        }
        container[name] = record
    end
    record.cnt = record.cnt + 1
    return record
end

return cprofile
