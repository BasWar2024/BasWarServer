function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()
    gg.mongoProxy = ggclass.MongodbProxy.new()
    gg.redisProxy = ggclass.RedisProxy.new()
    gg.savemgr = ggclass.csavemgr.new()
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

    gg.api.initialWhiteListStatus()
    gg.api.initialChainBridgeStatus()
    gg.api.initialTransportBanList()
    gg.api.initialPrivateApi()
    gg.api.initialChainExclusive()
    gg.api.initialUrlConfig()
end

function gg.exit()
    gg.savemgr:saveall()
    gg._exit()
end

--- ""("")
---@param[type=table] linkobj ""
---@param[type=string] err ""
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end