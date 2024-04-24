local ActivityProxy = class("ActivityProxy")

function ActivityProxy:ctor()
    self.actProxy = ggclass.Proxy.new("center",".activity")
end

function ActivityProxy:call(cmd, ...)
    return self.actProxy:call("api", cmd, ...)
end

function ActivityProxy:send(cmd, ...)
    return self.actProxy:send("api", cmd, ...)
end

function ActivityProxy:start()
end

return ActivityProxy