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
    gg.resPlanetMgr:playerLogin(pid)
end

--
function api.playerLogout(pid)
    gg.resPlanetMgr:playerLogout(pid)
end

function api.moveBuild(pid, index, buildId, pos)
    local ok, ret1, ret2 = gg.sync:once_do("resPlanet_"..index, gg.resPlanetMgr.moveBuild, gg.resPlanetMgr, pid, index, buildId, pos)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.buildMove2ResPlanet(pid, index, buildData, pos)
    local ok, ret1, ret2 = gg.sync:once_do("resPlanet_"..index, gg.resPlanetMgr.buildMove2ResPlanet, gg.resPlanetMgr, pid, index, buildData, pos)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.buildMove2ItemBag(pid, index, buildId)
    local ok, ret1, ret2 =  gg.sync:once_do("resPlanet_"..index, gg.resPlanetMgr.buildMove2ItemBag, gg.resPlanetMgr, pid, index, buildId)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.queryAllResPlanetBrief(pid)
    return gg.resPlanetMgr:queryAllResPlanetBrief(pid)
end

--
function api.queryResPlanet(pid, index)
    return gg.resPlanetMgr:queryResPlanet(pid, index)
end

--
function api.beginAttackResPlanet(pid, index, playerInfo, armyInfo, baseBuild, fightId)
    local ok, ret1, ret2 =  gg.sync:once_do("resPlanet_"..index, gg.resPlanetMgr.beginAttackResPlanet, gg.resPlanetMgr, pid, index, playerInfo, armyInfo, baseBuild, fightId)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.endAttackResPlanet(pid, index, result, soldiers)
    local ok, ret1, ret2 =  gg.sync:once_do("resPlanet_"..index, gg.resPlanetMgr.endAttackResPlanet, gg.resPlanetMgr, pid, index, result, soldiers)
    if not ok then
        return false, "server error"
    end
    return ret1, ret2
end

--
function api.updateMakeResRatio(pid, ratioInfo)
    return gg.resPlanetMgr:updateMakeResRatio(pid, ratioInfo)
end

return api