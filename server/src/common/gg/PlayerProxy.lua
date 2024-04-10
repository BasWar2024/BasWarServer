local PlayerProxy = class("PlayerProxy")

--""player
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
    if not pid or pid <= 0 then
        return nil
    end
    local proxy = self:getPlayerProxy(pid)
    if not proxy then
        return nil
    end
    return proxy:call("api", "doPlayerCmd", pid, cmd, ...)
end

function PlayerProxy:send(pid, cmd, ...)
    if not pid or pid <= 0 then
        return
    end
    local proxy = self:getPlayerProxy(pid)
    if not proxy then
        return nil
    end
    return proxy:send("api", "doPlayerCmd", pid, cmd, ...)
end
----------------------------------
function PlayerProxy:batchCall(pidList, cmd, ...)
    local plSize = table.count(pidList)
    if plSize == 0 then
        return
    end
    local proxyPidList = {}
    for i, pid in ipairs(pidList) do
        local proxy = self:getPlayerProxy(pid)
        if proxy then
            proxyPidList[proxy] = proxyPidList[proxy] or {}
            table.insert(proxyPidList[proxy], pid)
        end
    end
    local pidResult = {}
    for proxy, plist in pairs(proxyPidList) do
        local cmdResult = proxy:call("api", "batchDoPlayerCmd", plist, cmd, ...)
        for pid, r in pairs(cmdResult) do
            pidResult[pid] = r
        end
    end
    return pidResult
end

function PlayerProxy:batchSend(pidList, cmd, ...)
    local plSize = table.count(pidList)
    if plSize == 0 then
        return
    end
    local proxyPidList = {}
    for i, pid in ipairs(pidList) do
        local proxy = self:getPlayerProxy(pid)
        if proxy then
            proxyPidList[proxy] = proxyPidList[proxy] or {}
            table.insert(proxyPidList[proxy], pid)
        end
    end
    for proxy, plist in pairs(proxyPidList) do
        proxy:send("api", "batchDoPlayerCmd", plist, cmd, ...)
    end
end
----------------------------------

function PlayerProxy:callOnline(pid, cmd, ...)
    local proxy = self:getPlayerProxy(pid)
    if not proxy then
        return nil
    end
    return proxy:call("api", "doOnlinePlayerCmd", pid, cmd, ...)
end

function PlayerProxy:sendOnline(pid, cmd, ...)
    local proxy = self:getPlayerProxy(pid)
    if not proxy then
        return nil
    end
    return proxy:send("api", "doOnlinePlayerCmd", pid, cmd, ...)
end

--1"",0""
function PlayerProxy:getOnlineStatus(pid)
    local proxy = self:getPlayerProxy(pid)
    if not proxy then
        return 0
    end
    local status = proxy:call("api", "getOnlineStatus", pid)
    return status
end

return PlayerProxy