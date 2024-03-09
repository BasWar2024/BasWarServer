local ResMgr = class("ResMgr")

function ResMgr:ctor()
    self.node = skynet.config.id
    local centerserver = skynet.config.centerserver or self.node
    self.rescenterProxy = ggclass.Proxy.new(centerserver,".rescenter")
    self.isLocal = self.rescenterProxy:isLocal()
    self.address = skynet.localname(".rescenter")
end

--
function ResMgr:playerLogin(pid)
    self.rescenterProxy:send("api", "playerLogin", pid)
end

--
function ResMgr:playerLogout(pid)
    self.rescenterProxy:send("api", "playerLogout", pid)
end

--
function ResMgr:queryPlayerCostRes(pid)
    return self.rescenterProxy:call("api", "queryPlayerCostRes", pid)
end

--
function ResMgr:costPlayerRes(pid, costData)
    return self.rescenterProxy:call("api", "costPlayerRes", pid, costData)
end

--
function ResMgr:queryBoatRes(pid)
    return self.rescenterProxy:call("api", "queryBoatRes", pid)
end

--
function ResMgr:pickBoatRes(pid, costData)
    return self.rescenterProxy:call("api", "pickBoatRes", pid, costData)
end

function ResMgr:addBoatRes(pid, resData)
    return self.rescenterProxy:call("api", "addBoatRes", pid, resData)
end

function ResMgr:addCostRes(pid, resData)
    return self.rescenterProxy:call("api", "addCostRes", pid, resData)
end

function ResMgr:syncBoatAndCostData(pid, syncData)
    return self.rescenterProxy:call("api", "syncBoatAndCostData", pid, syncData)
end

return ResMgr