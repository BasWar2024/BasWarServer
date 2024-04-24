local StarmapProxy = class("StarmapProxy")

function StarmapProxy:ctor()
    self.proxy = ggclass.Proxy.new("center",".starmap")
    self.grids = {}
    self.playerGridIds = {}
    self.subscribeGrids = {}
    self.subscribeGridsByPid = {}
    -- self:init()
end

function StarmapProxy:init()
    print("Starmap init Grid ok")
end

function StarmapProxy:subscribe(pid, cfgIds)
    self.subscribeGridsByPid[pid] = self.subscribeGridsByPid[pid] or {}
    for _, v in ipairs(cfgIds) do
        self.subscribeGridsByPid[pid][v] = true
    end
    for _, cfgId in pairs(cfgIds) do
        self.subscribeGrids[cfgId] = self.subscribeGrids[cfgId] or {}
        self.subscribeGrids[cfgId][pid] = true
    end
end

function StarmapProxy:unsubscribe(pid, cfgIds)
    local gazeCfgIds = self.subscribeGridsByPid[pid]
    if not gazeCfgIds or not table.count(gazeCfgIds) == 0 then
        return
    end
    if not cfgIds or table.count(cfgIds) == 0 then
        cfgIds = table.keys(gazeCfgIds)
    end
    for _, cfgId in ipairs(cfgIds) do
        if self.subscribeGrids[cfgId] and self.subscribeGrids[cfgId][pid] then
            self.subscribeGrids[cfgId][pid] = nil
        end
        if self.subscribeGridsByPid[pid] and self.subscribeGridsByPid[pid][cfgId] then
            self.subscribeGridsByPid[pid][cfgId] = nil
        end
    end
end

function StarmapProxy:doPlayerCmd(pid, cmd, ...)
    local player = gg.playermgr:getplayer(pid)
    if not player then
        return nil
    end
    if player.starmapBag and player.starmapBag[cmd] then
        player.starmapBag[cmd](player.starmapBag, ...)
    end
end

function StarmapProxy:broadCast2SubscribePlayers(subCmd, cfgId, gridData)
    -- if subCmd == "onCampaignEnd" then
    --     self:doPlayerCmd(gridData.owner.playerId, "broadCastGridUpdate", gridData, subCmd)
    -- end
    local pids = self.subscribeGrids[cfgId]
    if not pids or not next(pids) then
        return
    end
    for pid, _ in pairs(pids) do
        self:doPlayerCmd(pid, "broadCastGridUpdate", gridData, subCmd)
    end
end

--""
function StarmapProxy:onGridUpdate(subCmd, cfgId, gridData)
    if not cfgId or type(cfgId) ~= "number" then
        return
    end
    if not gridData or type(gridData) ~= "table" then
        return
    end
    self:broadCast2SubscribePlayers(subCmd, cfgId, gridData)
end

function StarmapProxy:call(cmd, ...)
    return self.proxy:call("api", cmd, ...)
end

function StarmapProxy:send(cmd, ...)
    return self.proxy:call("api", cmd, ...)
end

function StarmapProxy:start()
    -- self:call("onGameServerStart")
    -- self:init()
end

return StarmapProxy