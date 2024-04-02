local md5 =	require	"md5" 

gamemgr = {}

function gamemgr.createRobot(cfgId, robotid, seq)
    local presetRobotCfgs = cfg.get("etc.cfg.presetRobot")
    if not presetRobotCfgs[cfgId] then
        return
    end
    local robotCfg = presetRobotCfgs[cfgId]
    local proxy = ggclass.Proxy.new(robotCfg.initGameServer, ".game")
    return proxy:call("api", "createRobot", cfgId, robotid, seq)
end

--""
function gamemgr.createBatchRobot(cfgId, count)
    local robotInfos = {}
    local pa = ggclass.cparallel.new()
    for i=1, count do
        pa:add(function()
            local robot = gamemgr.createRobot(cfgId)
            table.insert(robotInfos, robot)
        end)
    end
    pa:wait()
    return robotInfos
end

--""
function gamemgr.batchCreateRobot(gm, count)
    local ret = {}
    local pa = ggclass.cparallel.new()
    local presetRobotCfgs = cfg.get("etc.cfg.presetRobot")
    for k, v in pairs(presetRobotCfgs) do
        if v.gm == gm then
            pa:add(function(cfgId, robotid)
                local robot = gamemgr.createRobot(cfgId, robotid)
                table.insert(ret, robot)
            end, v.cfgId, v.robotid)
        end
    end
    pa:wait()
    return ret
end

function gamemgr.refreshRobot(gm)
    gm = gm or 1
    local pa = ggclass.cparallel.new()
    local docs = gg.mongoProxy.robot:find({gm=gm})
    for _, doc in pairs(docs) do
        pa:add(function(pid)
            gg.playerProxy:send(pid, "refreshRobot")
        end, doc.roleid)
    end
    pa:wait()
end

return gamemgr