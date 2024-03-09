function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg.component = {}
    gg.ordered_component = {}
    gg._init()
    gg.centerProxy = ggclass.Proxy.new(nil,".center")
    gg.shareProxy = ggclass.ShareProxy.new()
    gg.playerProxy = ggclass.PlayerProxy.new()
    gg.timectrl = ggclass.ctimectrl.new()
    gg.shareMgr = ggclass.ShareMgr.new()
    gg.dbmgr = ggclass.cdbmgr.new()
    gg.redismgr = ggclass.cdbmgr.new("redis")
    gg.savemgr = ggclass.csavemgr.new()
    gg.resMgr = ggclass.ResMgr.new()
    gg.resPlanetMgr = ggclass.ResPlanetMgr.new()
    gg.addComponent("resPlanetMgr", gg.resPlanetMgr)
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
    gg.savemgr:saveall()
    gg.redismgr:shutdown()
    gg._exit()
end

function gg.addComponent(name, component)
    assert(gg.component[name] == nil)
    gg.component[name] = component
    table.insert(gg.ordered_component, component)
end

--- : 
function gg.onSecond()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onSecond) == "function" then
            xpcall(component.onSecond, gg.onerror, component)
        end
    end
end

--- : 5
function gg.onFiveMinuteUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onFiveMinuteUpdate) == "function" then
            xpcall(component.onFiveMinuteUpdate, gg.onerror, component)
        end
    end
end

--- : 
function gg.onHalfHourUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onHalfHourUpdate) == "function" then
            xpcall(component.onHalfHourUpdate, gg.onerror, component)
        end
    end
end

--- : 
function gg.onHourUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onHourUpdate) == "function" then
            xpcall(component.onHourUpdate, gg.onerror, component)
        end
    end
end


--- ()
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end

