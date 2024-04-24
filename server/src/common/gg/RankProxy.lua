local RankProxy = class("RankProxy")

function RankProxy:ctor()
    self.node = skynet.config.id
    local centerserver = skynet.config.centerserver or self.node
    self.rankProxy = ggclass.Proxy.new(centerserver,".rank")
    self.isLocal = self.rankProxy:isLocal()
    self.address = skynet.localname(".rescenter")
    self.cache = {}
end

function RankProxy:getRankList(rankKey, pid, version)
    local list = self:call("getRankList", rankKey, pid, version)
    return list
end

function RankProxy:playerLogin(pid)
    self.rankProxy:send("api", "playerLogin", pid)
end

function RankProxy:playerLogout(pid)
    self.rankProxy:send("api", "playerLogout", pid)
end

function RankProxy:call(cmd, ...)
    return self.rankProxy:call("api", cmd, ...)
end

function RankProxy:send(cmd, ...)
    return self.rankProxy:send("api", cmd, ...)
end

return RankProxy
