local PlayerResMgr = class("PlayerResMgr")

function PlayerResMgr:ctor()
    self.playerBoats = {}
    self.playerResCosts = {}
end

function PlayerResMgr:sendPlayer(cmd, pid, data)
    if pid <= 0 then
        return
    end
    local brief = gg.centerProxy:call("api","getBrief",pid)
    if brief then
        gg.cluster:send(brief.node, ".main", "playerexec", pid, cmd, data)
    end
end

function PlayerResMgr:callPlayer(cmd, pid, data)
    if pid <= 0 then
        return
    end
    local brief = gg.centerProxy:call("api","getBrief",pid)
    if brief then
        return gg.cluster:call(brief.node, ".main", "playerexec", pid, cmd, data)
    end
end

--
function PlayerResMgr:getPlayerBoat(pid)
    local boat = self.playerBoats[pid]
    if not boat then
        local resData = gg.dbmgr:getdb().player_boat:findOne({pid = pid})
        if not resData then
            boat = ggclass.PlayerBoat.new({pid=pid})
            boat.dirty = true
            boat:save_to_db()
        else
            boat = ggclass.PlayerBoat.new(resData)
            boat:deserialize(resData)
        end
        self.playerBoats[pid] = boat
        gg.savemgr:autosave(boat)
    end
    return boat
end

function PlayerResMgr:getPlayerResCost(pid)
    if pid <= 0 then
        return
    end
    local playerResCost = self.playerResCosts[pid]
    if not playerResCost then
        local costData = gg.dbmgr:getdb().player_res_cost:findOne({pid = pid})
        if not costData then
            playerResCost = ggclass.PlayerResCost.new({pid=pid})
            playerResCost.dirty = true
            playerResCost:save_to_db()
        else
            playerResCost = ggclass.PlayerResCost.new(costData)
            playerResCost:deserialize(costData)
        end
        self.playerResCosts[pid] = playerResCost
        gg.savemgr:autosave(playerResCost)
    end
    return playerResCost
end

function PlayerResMgr:addCostRes(pid, resData)
    if not pid or pid <= 0 then
        return
    end
    if not resData then
        return
    end
    local playerResCost = self:getPlayerResCost(pid)
    if not playerResCost then
        return
    end
    return playerResCost:addRes(resData)
end

function PlayerResMgr:addBoatRes(pid, resData)
    if not pid or pid <= 0 then
        return
    end
    if not resData then
        return
    end
    local boat = self:getPlayerBoat(pid)
    if not boat then
        return
    end
    return boat:addRes(resData)
end

--
function PlayerResMgr:queryBoatRes(pid)
    if not pid or pid <= 0 then
        return false
    end
    local boat = self:getPlayerBoat(pid)
    if next(boat.currencies) or next(boat.items) then
        boat:createBoatPack()
    end
    if next(boat.boatPacks) then
        local packs = boat:getAllBoatPacks()
        self:sendPlayer("resPlanetBag:onPickBoatResNotify", pid, packs)
    else
        self:sendPlayer("resPlanetBag:onPickBoatResNotify", pid, {})
    end
end

-- 
--@param[type=integer] pid id
--@param[type=table] ids id
--@param[type=table] delIds id
--@return resData 
function PlayerResMgr:pickBoatRes(pid, ids)
    if not pid or pid <= 0 then
        return false, "pid is nil"
    end
    local boat = self:getPlayerBoat(pid)
    if not boat then
        self:callPlayer("resPlanetBag:onPickBoatRes", pid, {})
        return false, "player not res need pick"
    end
    local packs = boat:getAllBoatPacks()
    if not packs or not next(packs) then
        self:callPlayer("resPlanetBag:onPickBoatRes", pid, {})
        return false, "no res need pick"
    end
    local ok = self:callPlayer("resPlanetBag:onPickBoatRes", pid, packs)
    if not ok then
        return false, "server call error"
    end
    for k, v in pairs(packs) do
        boat:removeBoatPack(v.boatId)
    end
    return true
end

--
function PlayerResMgr:queryPlayerCostRes(pid)
    if not pid or pid <= 0 then
        return
    end
    local playerCost = self:getPlayerResCost(pid)
    if next(playerCost.heros) or next(playerCost.warShips) or next(playerCost.soldiers) then
        playerCost:createCostPack()
    end
    if next(playerCost.costPacks) then
        local packs = playerCost:getAllCostPacks()
        self:sendPlayer("resPlanetBag:onCostPlayerResNotify", pid, packs)
    else
        self:sendPlayer("resPlanetBag:onCostPlayerResNotify", pid, {})
    end
end

-- ()
--@param[type=integer] pid id
--@param[type=table] costData 
--@return
function PlayerResMgr:costPlayerRes(pid, costIds)
    if not pid or pid <= 0 then
        return false,"pid is nil"
    end
    local playerCost = self:getPlayerResCost(pid)
    if not playerCost then
        self:callPlayer("resPlanetBag:onCostPlayerRes", pid, {})
        return false, "player no res need to cost"
    end
    local packs = playerCost:getAllCostPacks()
    if not packs or not next(packs) then
        self:callPlayer("resPlanetBag:onCostPlayerRes", pid, {})
        return false, "player no res need to cost"
    end
    local ok = self:callPlayer("resPlanetBag:onCostPlayerRes", pid, packs)
    if not ok then
        return false, "server call error"
    end
    for k, v in pairs(packs) do
        playerCost:removeCostPack(v.costId)
    end
    return true
end

function PlayerResMgr:syncBoatAndCostData(pid, syncData)
    local result = {}
    local boat = self:getPlayerBoat(pid)
    result.boatIds = boat:syncBoatData(syncData.boatIds)
    local playerCost = self:getPlayerResCost(pid)
    result.costIds  = playerCost:syncCostData(syncData.costIds)
    return result
end

function PlayerResMgr:playerLogin(pid)
    --
    self:queryBoatRes(pid)
    --
    self:queryPlayerCostRes(pid)
end

function PlayerResMgr:playerLogout(pid)
    local playerBoat = self.playerBoats[pid]
    if playerBoat then
        playerBoat.dirty = true
        playerBoat:save_to_db()
    end
end


return PlayerResMgr