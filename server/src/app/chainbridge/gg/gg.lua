function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()
    gg.mongoProxy = ggclass.MongodbProxy.new()
    gg.redisProxy = ggclass.RedisProxy.new()
    
    gg.timectrl = ggclass.ctimectrl.new()
    gg.shareProxy = ggclass.ShareProxy.new()
    gg.bridgeMgr = ggclass.BridgeMgr.new()
    gg.rechargeMgr = ggclass.RechargeMgr.new()
    gg.withdrawMgr = ggclass.WithdrawMgr.new()
    gg.playerProxy = ggclass.PlayerProxy.new()
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
    gg.bridgeMgr:initial()
end

function gg.exit()
    gg._exit()
end

--- "": ""
function gg.onSecond()
    gg.rechargeMgr:onSecond()
end

--- ""("")
---@param[type=table] linkobj ""
---@param[type=string] err ""
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end