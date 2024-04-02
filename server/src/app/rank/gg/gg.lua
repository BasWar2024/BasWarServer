function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg.component = {}
    gg.ordered_component = {}
    gg._init()
    -- "": ""
    gg.initI18n()
    gg.mongoProxy = ggclass.MongodbProxy.new()
    gg.redisProxy = ggclass.RedisProxy.new()
    gg.timectrl = ggclass.ctimectrl.new()
    gg.rank = ggclass.Rank.new()
    gg.unionRank = ggclass.UnionRank.new()
    gg.unionProxy = ggclass.UnionProxy.new()
end

function gg.start()
    gg.actor:start()
    if gg.standalone then
        gg.cluster:open()
        logger.print("cluster:open")
    end
    gg.internal:open()
    logger.print("internal:open")
    gg.gm:open()
    logger.print("gm:open")
    gg.timectrl:tick()
    logger.print("timer tick")
end

function gg.exit()
    gg._exit()
end

function gg.isGmRobotPlayer(pid)
    if pid >= constant.ROBOT_PVE_MIN_PLAYERID and pid <= constant.ROBOT_PVE_MAX_PLAYERID then
        return true
    end
    return false
end

--- "": ""
function gg.onSecond()
    
end

--- "": ""
function gg.onMinuteUpdate()
    gg.rank:refreshRank()
    gg.unionRank:refreshRank()
end

--- "": 5""
function gg.onFiveMinuteUpdate()

end

--- "": ""
function gg.onHalfHourUpdate()
    
end

--- ""("")
---@param[type=table] linkobj ""
---@param[type=string] err ""
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end