function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg.component = {}
    gg.ordered_component = {}
    gg._init()
    gg.timectrl = ggclass.ctimectrl.new()
    gg.redismgr = ggclass.cdbmgr.new("redis")
    gg.rank = ggclass.Rank.new()
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
    gg.redismgr:shutdown()
    gg._exit()
end

--- : 
function gg.onSecond()

end

--- : 
function gg.on_minute_update()

end

--- : 5
function gg.onFiveMinuteUpdate()

end

--- : 
function gg.onHalfHourUpdate()
    
end

--- ()
---@param[type=table] linkobj 
---@param[type=string] err 
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end