function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()
    gg.dbmgr = ggclass.cdbmgr.new()
    gg.savemgr = ggclass.csavemgr.new()
    gg.shareMgr = ggclass.ShareMgr.new()
    gg.briefMgr = ggclass.BriefMgr.new()
    gg.nodeMgr = ggclass.NodeMgr.new()

    -- skynet.newservice("app/rescenter/main",".rescenter")  --
    skynet.newservice("app/bigmap/main",".bigmap")        --
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
    gg.dbmgr:shutdown()
    gg._exit()
end

function gg.onHeartbeat()
    xpcall(gg.nodeMgr.onHeartbeat,gg.onerror,gg.nodeMgr)
end

function __hotfix(module)
end