local Multicast = class("Multicast")

function Multicast:ctor()
    self.channels = {}
    skynet.register_protocol {
        name = "multicast",-- ""
        id = 101,
        pack = skynet.pack,
        unpack = skynet.unpack, 
    }
end

function Multicast:subscribe(chan, addr)
    self.channels[chan] = self.channels[chan] or {}
    self.channels[chan][addr] = true
end

function Multicast:unsubscribe(chan, addr)
    if not self.channels[chan] then
        return
    end
    if not self.channels[chan][addr] then
        return
    end
    self.channels[chan][addr] = nil
end

function Multicast:onPublish(chan, ...)
    if not self.channels[chan] then
        return
    end
    for addr in pairs(self.channels[chan]) do
        skynet.send(addr, "multicast", chan,  ...)
    end
end

return Multicast