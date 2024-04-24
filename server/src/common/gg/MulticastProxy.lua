local MulticastProxy = class("MulticastProxy")

function MulticastProxy:ctor()
    self.centerProxy = ggclass.Proxy.new("center", ".main")
    self.channels = {}
    skynet.register_protocol {
        name = "multicast",-- ""
        id = 101,
        pack = skynet.pack,
        unpack = skynet.unpack, 
        dispatch = function (session, address, chan, ...)
            if session > 0 then
                skynet.retpack(self:onMessage(chan, ...))
            else
                self:onMessage(chan, ...)
            end
        end
    }
end

function MulticastProxy:subscribe(chan, func, caller)
    local chanInfo = {func = func, caller = caller}
    self.channels[chan] = chanInfo
    gg.internal:send(".multicast", "api", "subscribe", chan, skynet.self())
end

function MulticastProxy:unsubscribe(chan)
    if not self.channels[chan] then
        return
    end
    gg.internal:send(".multicast", "api", "unsubscribe", chan, skynet.self())
end

function MulticastProxy:onMessage(chan, ...)
    local chanInfo = self.channels[chan]
    if not chanInfo then
        return
    end
    if chanInfo.caller then
        return chanInfo.func(chanInfo.caller, chan, ...)
    else
        return chanInfo.func(chan, ...)
    end
end

function MulticastProxy:publish(chan, ...)
    self:send("onMulticastPublish", chan, ...)
end

function MulticastProxy:call(cmd, ...)
    return self.centerProxy:call("api", cmd, ...)
end

function MulticastProxy:send(cmd, ...)
    self.centerProxy:send("api", cmd, ...)
end

return MulticastProxy