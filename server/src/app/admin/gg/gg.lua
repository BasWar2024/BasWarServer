gg = gg or {}

function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()
    --""
    skynet.newservice("app/mongodb/main", ".mongodb")
    gg.mongoProxy = ggclass.MongodbProxy.new()

    skynet.newservice("app/redisdb/main", ".redisdb")
    gg.redisProxy = ggclass.RedisProxy.new()
    
    gg.timectrl = ggclass.ctimectrl.new()
    gg.savemgr = ggclass.csavemgr.new()
    gg.thistemp = ggclass.cthistemp.new()

    gg.shareProxy = ggclass.ShareProxy.new(4)
    
    gg.centerProxy = ggclass.CenterProxy.new()
    gg.playerProxy = ggclass.PlayerProxy.new()
    gg.mailProxy = ggclass.MailProxy.new()
    gg.unionProxy = ggclass.UnionProxy.new()
    gg.multicastProxy = ggclass.MulticastProxy.new()
    gg.dynamicCfg = ggclass.DynamicCfg.new()
    gg.opCfgProxy = ggclass.OpCfgProxy.new()
    gg.matchProxy = ggclass.MatchProxy.new()
    gg.analyzer = ggclass.Analyzer.new()
    gg.proxyservice("center")
    
    skynet.newservice("app/multicast/main", ".multicast")       --""
    
    gg.loginserver = ggclass.cloginserver.new({
        host = skynet.getenv("loginserver"),
        appid = skynet.getenv("appid"),
        appkey = skynet.getenv("appkey"),
        loginserver_appkey = skynet.getenv("loginserver_appkey"),
    })
end

function gg.start()
    local address = skynet.self()
    local node = skynet.getenv("id")
    local slave_num = tonumber(skynet.getenv("gate_slave_num"))
    -- ""(1/100"")
    local gate_conf = {
        watchdog_node = node,
        watchdog_address = address,
        msg_max_len = 800 * 1024,
        slave_num = slave_num,
    }
    local http_gate
    local http_port = skynet.getenv("http_port")
    if http_port then
        gate_conf.port = http_port
        http_gate = skynet.uniqueservice("gg/service/gate/http")
        skynet.call(http_gate,"lua","open",gate_conf)
    end
    gg.actor:start()
    gg.gm:open()
    logger.print("gm:open")
    if gg.standalone then
        gg.cluster:open()
        logger.print("cluster:open")
    end
    gg.internal:open()
    logger.print("internal:open")

    gg.client:open()
    logger.print("client:open")

    adminaccountmgr.initialadminaccount()

    gg.timectrl:tick()
    logger.print("timer tick")

    
end

-- "": gg.init -> gg.start -> gg.exit
function gg.exit()
    gg.savemgr:saveall()
end

-- ""http""
function gg.gameserver(host,appkey)
    if not gg.gameservers then
        gg.gameservers = {}
    end
    if not gg.gameservers[host] then
        local gameserver = ggclass.cgameserver.new({
            host = host,
            appkey = appkey,
        })
        gg.gameservers[host] = gameserver
    end
    return gg.gameservers[host]
end

--- "": ""
function gg.onSecond()
    if gg.analyzer and gg.analyzer.onSecond then
        gg.analyzer:onSecond()
    end
end

--- "": ""
function gg.onMinuteUpdate()
    if gg.analyzer and gg.analyzer.onMinuteUpdate then
        gg.analyzer:onMinuteUpdate()
    end
end

--- "": 5""
function gg.onFiveMinuteUpdate()
    if gg.analyzer and gg.analyzer.onFiveMinuteUpdate then
        gg.analyzer:onFiveMinuteUpdate()
    end
end

function gg.onTenMinuteUpdate()
    if gg.analyzer and gg.analyzer.onTenMinuteUpdate then
        gg.analyzer:onTenMinuteUpdate()
    end
    
end

--- "": ""
function gg.onHalfHourUpdate()
    if gg.analyzer and gg.analyzer.onHalfHourUpdate then
        gg.analyzer:onHalfHourUpdate()
    end
end

function gg.onDayUpdate()
    if gg.analyzer and gg.analyzer.onDayUpdate then
        gg.analyzer:onDayUpdate()
    end
end

return gg
