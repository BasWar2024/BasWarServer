function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()
    gg.redismgr = ggclass.cdbmgr.new("redis")
    gg.dbmgr = ggclass.cdbmgr.new()
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
end

function gg.exit()
    gg.savemgr:saveall()
    gg.redismgr:shutdown()
    gg._exit()
end

--- ()
---@param[type=table] linkobj 
---@param[type=string] err 
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end