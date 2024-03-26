function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg.component = {}
    gg.ordered_component = {}
    gg._init()
    gg.initI18n()
    gg.mongoProxy = ggclass.MongodbProxy.new()
    gg.centerProxy = ggclass.CenterProxy.new()
    gg.shareProxy = ggclass.ShareProxy.new()
    gg.playerProxy = ggclass.PlayerProxy.new()
    gg.unionProxy = ggclass.UnionProxy.new()
    gg.matchProxy = ggclass.MatchProxy.new()
    gg.multicastProxy = ggclass.MulticastProxy.new()
    gg.activityProxy = ggclass.ActivityProxy.new()
    gg.chatProxy = ggclass.ChatProxy.new()
    gg.dynamicCfg = ggclass.DynamicCfg.new()
    gg.timectrl = ggclass.ctimectrl.new()
    gg.savemgr = ggclass.csavemgr.new()
    gg.starmap = ggclass.Starmap.new()
    gg.battleMgr = ggclass.BattleMgr.new()
    gg.campaignMgr = ggclass.CampaignMgr.new()

    gg.addComponent("starmap", gg.starmap)
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
    if gg.starmap and gg.starmap.shutdown then
        gg.starmap:shutdown()
    end
    if gg.campaignMgr and gg.campaignMgr.shutdown then
        gg.campaignMgr:shutdown()
    end
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
    for _, component in pairs(gg.ordered_component) do
        if type(component.onSecond) == "function" then
            xpcall(component.onSecond, gg.onerror, component)
        end
    end
    if gg.battleMgr and gg.battleMgr.onSecond then
        gg.battleMgr:onSecond()
    end
    if gg.campaignMgr and gg.campaignMgr.onSecond then
        gg.campaignMgr:onSecond()
    end
end

function gg.onMinuteUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onMinute) == "function" then
            xpcall(component.onMinute, gg.onerror, component)
        end
    end
    if gg.campaignMgr and gg.campaignMgr.onMinute then
        gg.campaignMgr:onMinute()
    end
end

--- "": 5""
function gg.onFiveMinuteUpdate()
    for _, component in pairs(gg.ordered_component) do
        if type(component.onFiveMinuteUpdate) == "function" then
            xpcall(component.onFiveMinuteUpdate, gg.onerror, component)
        end
    end
    if gg.campaignMgr and gg.campaignMgr.onFiveMinuteUpdate then
        gg.campaignMgr:onFiveMinuteUpdate()
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


--- ""("")
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end

