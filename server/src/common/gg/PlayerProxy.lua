local PlayerProxy = class("PlayerProxy")

--player
function PlayerProxy:ctor()
    self.pidToNode = {}
end

function PlayerProxy:getPlayerProxy(pid)
    local node = self.pidToNode[pid]
    if node then
        return gg.getProxy(node,".game")
    end
    assert(gg.shareProxy, "need init shareProxy")
    node = gg.shareProxy:call("getPlayerNodeByPid", pid)
    if not node then
        return nil
    end
    self.pidToNode[pid] = node
    return gg.getProxy(node,".game")
end

function PlayerProxy:call(pid, cmd, ...)
    local proxy = self:getPlayerProxy(pid)
    if not proxy then
        return nil
    end
    return proxy:call("api", "doPlayerCmd", pid, cmd, ...)
end

function PlayerProxy:send(pid, cmd,...)
    local proxy = self:getPlayerProxy(pid)
    if not proxy then
        return nil
    end
    return proxy:send("api", "doPlayerCmd", pid, cmd, ...)
end

function PlayerProxy:playerIsOnline(pid)

end

return PlayerProxy