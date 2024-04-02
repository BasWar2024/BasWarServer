function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()
    gg.initI18n()
    --""
    skynet.newservice("app/mongodb/main", ".mongodb")
    gg.mongoProxy = ggclass.MongodbProxy.new()
    
    skynet.newservice("app/redisdb/main", ".redisdb")
    gg.redisProxy = ggclass.RedisProxy.new()

    gg.savemgr = ggclass.csavemgr.new()

    gg.shareProxy = ggclass.ShareProxy.new()
    
    gg.briefMgr = ggclass.BriefMgr.new()
    gg.nodeMgr = ggclass.NodeMgr.new()
    gg.itemCfgMgr = ggclass.ItemCfgMgr.new()
    -- gg.starMapExcel = ggclass.StarMapExcel.new()

    gg.createMongoIndex()

    skynet.newservice("app/multicast/main", ".multicast")  --""
    skynet.newservice("app/starmap/main",".starmap")        --""
    skynet.newservice("app/union/main",".union")          --""
    skynet.newservice("app/chat/main", ".chat")           --""
    skynet.newservice("app/mail/main",".mail")            --""
    skynet.newservice("app/operationcfg/main",".operationcfg")   --""
    skynet.newservice("app/match/main", ".match")          --""
    skynet.newservice("app/rank/main",".rank")   --""
    skynet.newservice("app/activity/main",".activity")      --""

    skynet.newservice("app/chainbridge/main",".chainbridge")   --chain bridge
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
    gg.startHttpGate()
end

function gg.exit()
    gg.savemgr:saveall()
    gg._exit()
end

function gg.onHeartbeat()
    xpcall(gg.nodeMgr.onHeartbeat,gg.onerror,gg.nodeMgr)
end

function __hotfix(module)
end