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
    
    gg.centerProxy = ggclass.CenterProxy.new()
    gg.shareProxy = ggclass.ShareProxy.new()
    gg.playerProxy = ggclass.PlayerProxy.new()
    gg.multicastProxy = ggclass.MulticastProxy.new()
    gg.dynamicCfg = ggclass.DynamicCfg.new()
    gg.timectrl = ggclass.ctimectrl.new()
    gg.savemgr = ggclass.csavemgr.new()
    gg.unionProxy = ggclass.UnionProxy.new()
    gg.starmapProxy = ggclass.StarmapProxy.new()
    gg.rankProxy = ggclass.RankProxy.new()
    gg.mailProxy = ggclass.MailProxy.new()
    gg.matchProxy = ggclass.MatchProxy.new()
    gg.activityMgr = ggclass.ActivityMgr.new()
    gg.addComponent("activityMgr", gg.activityMgr)

    gg.activityMgr:init(true)
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
    gg.activityMgr:saveall()
    gg.savemgr:saveall()
    gg._exit()
end

function gg.addComponent(name, component)
    assert(gg.component[name] == nil)
    gg.component[name] = component
    table.insert(gg.ordered_component, component)
end

--- "": ""
function gg.onSecond()
    -- local dateStr = os.date("%Y-%m-%d %H:%M:%S",os.time()) 
    -- local convertTimestamp = string.totime(dateStr)
    -- print("=========now date=", dateStr, "nowTimestamp=", os.time(), "convertTimestamp=", convertTimestamp)
    

    for _, component in pairs(gg.ordered_component) do
        if type(component.onSecond) == "function" then
            xpcall(component.onSecond, gg.onerror, component)
        end
    end
end

--- "": 1""
function gg.onMinuteUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onMinuteUpdate) == "function" then
            xpcall(component.onMinuteUpdate, gg.onerror, component)
        end
    end
end

--- "": 5""
function gg.onFiveMinuteUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onFiveMinuteUpdate) == "function" then
            xpcall(component.onFiveMinuteUpdate, gg.onerror, component)
        end
    end
end

--- "": 5""
function gg.onTenMinuteUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onTenMinuteUpdate) == "function" then
            xpcall(component.onTenMinuteUpdate, gg.onerror, component)
        end
    end
end

--- "": ""
function gg.onHalfHourUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onHalfHourUpdate) == "function" then
            xpcall(component.onHalfHourUpdate, gg.onerror, component)
        end
    end
end

--- "": ""
function gg.onHourUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onHourUpdate) == "function" then
            xpcall(component.onHourUpdate, gg.onerror, component)
        end
    end
end

function gg.onSaturdayUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onSaturdayUpdate) == "function" then
            xpcall(component.onSaturdayUpdate, gg.onerror, component)
        end
    end
end

--- ""("")
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end

