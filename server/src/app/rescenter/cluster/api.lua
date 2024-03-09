-- api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

--
function api.playerLogin(pid)
    gg.playerResMgr:playerLogin(pid)
end

--
function api.playerLogout(pid)
    gg.playerResMgr:playerLogout(pid)
end

--()
function api.addCostRes(pid, resData)
    local ok, ret1, ret2 = gg.sync:once_do("PlayerCostRes_"..pid, gg.playerResMgr.addCostRes, gg.playerResMgr, pid, resData)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.queryPlayerCostRes(pid)
    local ok, ret1, ret2 = gg.sync:once_do("PlayerCostRes_"..pid, gg.playerResMgr.queryPlayerCostRes, gg.playerResMgr, pid)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.costPlayerRes(pid, costIds)
    local ok, ret1, ret2 = gg.sync:once_do("PlayerCostRes_"..pid, gg.playerResMgr.costPlayerRes, gg.playerResMgr, pid, costIds)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--()
function api.addBoatRes(pid, resData)
    local ok, ret1, ret2 = gg.sync:once_do("PlayerBoat_"..pid, gg.playerResMgr.addBoatRes, gg.playerResMgr, pid, resData)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.queryBoatRes(pid)
    local ok, ret1, ret2 = gg.sync:once_do("PlayerBoat_"..pid, gg.playerResMgr.queryBoatRes, gg.playerResMgr, pid)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.pickBoatRes(pid, boatIds)
    local ok, ret1, ret2 = gg.sync:once_do("PlayerBoat_"..pid, gg.playerResMgr.pickBoatRes, gg.playerResMgr, pid, boatIds)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

function api.syncBoatAndCostData(pid, syncData)
    local ok, ret1, ret2 = gg.sync:once_do("PlayerBoat_"..pid, gg.playerResMgr.syncBoatAndCostData, gg.playerResMgr, pid, syncData)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

return api