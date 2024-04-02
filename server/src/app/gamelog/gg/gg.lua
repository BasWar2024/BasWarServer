function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg.component = {}
    gg.ordered_component = {}
    gg._init()
    gg.mongoProxy = ggclass.MongodbProxy.new()
    gg.redisProxy = ggclass.RedisProxy.new()
    
    gg.timectrl = ggclass.ctimectrl.new()
    gg.gameLog = ggclass.GameLog.new()
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

    gg.gameLog:beginLog()
end

function gg.exit()
    gg.gameLog:shutdown()
    gg._exit()
end

--- "": ""
function gg.onSecond()
    gg.gameLog:onSecond()
end

--- "": ""
function gg.onMinuteUpdate()
    gg.gameLog:onMinuteUpdate()
end

--- "": 5""
function gg.onFiveMinuteUpdate()
    gg.gameLog:onFiveMinuteUpdate()
end

--- "": ""
function gg.onHalfHourUpdate()
    gg.gameLog:onHalfHourUpdate()
end

--- ""("")
---@param[type=table] linkobj ""
---@param[type=string] err ""
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end