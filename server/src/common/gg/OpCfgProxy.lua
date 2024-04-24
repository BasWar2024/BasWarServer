local OpCfgProxy = class("OpCfgProxy")

function OpCfgProxy:ctor()
    self.node = skynet.config.id
    local centerserver = skynet.config.centerserver or self.node
    self.opCfgProxy = ggclass.Proxy.new(centerserver,".operationcfg")
    self.isLocal = self.opCfgProxy:isLocal()
    self.address = skynet.localname(".rescenter")
    self.cache = {}
end

function OpCfgProxy:getOpCfg(key)
    if self.cache[key] then
        return self.cache[key]
    end
    local ok, msg = self:call("getOperationCfg", key)
    if not ok then
        return
    end
    self.cache[key] = msg
    return msg
end

function OpCfgProxy:broadcastOpCfg(key, value)
    self.cache[key] = value
end

function OpCfgProxy:playerLogin(pid)
    self.opCfgProxy:send("api", "playerLogin", pid)
end

function OpCfgProxy:playerLogout(pid)
    self.opCfgProxy:send("api", "playerLogout", pid)
end

function OpCfgProxy:call(cmd, ...)
    return self.opCfgProxy:call("api", cmd, ...)
end

function OpCfgProxy:send(cmd, ...)
    return self.opCfgProxy:send("api", cmd, ...)
end

return OpCfgProxy
