gg = gg or {}

function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = true
    gg._init()
    gg.savemgr = ggclass.csavemgr.new()
    gg.dbmgr = ggclass.cdbmgr.new()
    gg.thistemp = ggclass.cthistemp.new()
    gg.proxyservice("center")
end

function gg.start()
    local address = skynet.self()
    local node = skynet.getenv("id")
    local slave_num = tonumber(skynet.getenv("gate_slave_num"))
    -- (1/100)
    local gate_conf = {
        watchdog_node = node,
        watchdog_address = address,
        msg_max_len = 8 * 1024,
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
    accountmgr.start_timer_settle_pay()
end

-- : gg.init -> gg.start -> gg.exit
function gg.exit()
    gg.savemgr:saveall()
    gg.dbmgr:shutdown()
end

-- http
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

return gg