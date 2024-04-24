local ChainBridgeProxy = class("ChainBridgeProxy")

function ChainBridgeProxy:ctor()
    self.node = skynet.config.id
    local centerserver = skynet.config.centerserver or self.node
    self.chainBridgeProxy = ggclass.Proxy.new(centerserver, ".chainbridge")
end

function ChainBridgeProxy:call(cmd, ...)
    return self.chainBridgeProxy:call("api", cmd, ...)
end

function ChainBridgeProxy:send(cmd, ...)
    return self.chainBridgeProxy:send("api", cmd, ...)
end

return ChainBridgeProxy