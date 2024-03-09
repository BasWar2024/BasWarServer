gg.canntHotfixModules = {
    "gg%.service%..*",
    "gg%.like_skynet%..*",
    "app%..*%.main",
}

function gg._init()
    logger.init()
    gg.trace.print = logger.print
    gg.moduleName = gg.serviceName:sub(2)
    gg.loadStartConfig()
    if not gg.ignoreCfg then
        if gg.standalone then
            cfg.loadAll()
        end
        cfg.init()
    end
    local index = tonumber(skynet.config.index)
    local nodes = skynet.config.nodes
    local node_index = {}
    for node_name,conf in pairs(nodes) do
        if conf.index > 0 then
            node_index[node_name] = conf.index
        end
    end
    snowflake.init(index,node_index)
    skynet.name(gg.serviceName,skynet.self())
    gg.heartbeatTime = 0
    gg.gate = {}
    gg.proxy = {}
    gg.clusterQueue = ggclass.ClusterQueue.new(skynet.config.id,skynet.config.centerserver,".center")
    gg.tempProxy = {}
end

function gg._exit()
    gg.actor:exit()
    if gg.standalone then
        -- game.exit()#skynet.abort
        gg.serviceMgr:exit()
    else
        skynet.fork(skynet.exit)
    end
end

function gg.getGateConfig()
    local address = skynet.self()
    local node = skynet.getenv("id")
    local slave_num = tonumber(skynet.getenv("gate_slave_num"))
    local proto_type = assert(skynet.getenv("proto_type"))
    local key = proto_type .. "_config"
    local proto_config = assert(skynet.getenv(key))
    local msg_max_len = assert(tonumber(skynet.getenv("msg_max_len")))
    -- (1/100)
    local timeout = assert(tonumber(skynet.getenv("socket_timeout")))
    local maxclient = assert(tonumber(skynet.getenv("socket_max_num")))
    local encrypt_algorithm = skynet.getenv("encrypt_algorithm")

    local gateConfig = {
        watchdog_node = node,
        watchdog_address = address,
        proto_type = proto_type,
        proto_config = proto_config,
        msg_max_len = msg_max_len,
        timeout = timeout,
        encrypt_algorithm = encrypt_algorithm,
        slave_num = slave_num,
        maxclient = maxclient,
    }
    return gateConfig
end

function gg.startTcpGate()
    local gate_conf = gg.getGateConfig()
    local tcp_port = skynet.getenv("tcp_port")
    if tcp_port then
        gate_conf.port = tcp_port
        gg.gate.tcp = skynet.newservice("gg/service/gate/tcp")
        skynet.call(gg.gate.tcp,"lua","open",gate_conf)
    end
end

function gg.startKcpGate()
    --[[
    if true then
        -- test
        local gate_conf = gg.getGateConfig()
        gate_conf.port = skynet.getenv("kcp_port")
        gate_conf.encrypt_algorithm = nil   -- 
        gg.gate.tcp = skynet.newservice("gg/service/gate/tcp")
        skynet.call(gg.gate.tcp,"lua","open",gate_conf)
        return
    end
    ]]
    local gate_conf = gg.getGateConfig()
    local kcp_port = skynet.getenv("kcp_port")
    if kcp_port then
        local kcp_socket_timeout = tonumber(skynet.getenv("kcp_socket_timeout"))
        if kcp_socket_timeout then
            gate_conf.timeout = kcp_socket_timeout
        end
        gate_conf.port = kcp_port
        gg.gate.kcp = skynet.newservice("gg/service/gate/kcp")
        skynet.call(gg.gate.kcp,"lua","open",gate_conf)
    end
end

function gg.startWebsocketGate()
    local gate_conf = gg.getGateConfig()
    local websocket_port = skynet.getenv("websocket_port")
    if websocket_port then
        gate_conf.port = websocket_port
        gg.gate.websocket = skynet.newservice("gg/service/gate/websocket")
        skynet.call(gg.gate.websocket,"lua","open",gate_conf)
    end
end

function gg.startHttpGate()
    local gate_conf = gg.getGateConfig()
    local http_port = skynet.getenv("http_port")
    if http_port then
        gate_conf.port = http_port
        gg.gate.http = skynet.newservice("gg/service/gate/http")
        skynet.call(gg.gate.http,"lua","open",gate_conf)
    end
end

function gg.startTimerOpenLogin(time)
    gg.stopTimerOpenLogin()
    gg.openLoginTimer = gg.timer:timeout(time,function ()
        gg.closeEnterGame = false
        gg.closeCreateRole = false
    end)
end

function gg.stopTimerOpenLogin()
    local openLoginTimer = gg.openLoginTimer
    if not openLoginTimer then
        return
    end
    gg.openLoginTimer = nil
    gg.timer:deltimer(openLoginTimer)
end

function gg.isSelfService(serviceName)
    if serviceName:sub(1,1) ~= "." then
        serviceName = "." .. serviceName
    end
    local realServiceName = gg.serviceName
    local tempName,serviceIndex = string.match(gg.serviceName,"(.+)(%d)")
    if tempName then
        realServiceName = tempName
    end
    return realServiceName == serviceName
end

-- /
function gg.uniqueservice(serviceName)
    local servicePath = string.format("app/%s/main",serviceName)
    local name = "." .. serviceName
    local serviceAddress = skynet.uniqueservice(servicePath,name)
    skynet.name(name,serviceAddress)
    return serviceAddress
end

-- 
function gg.proxyservice(serviceName, serviceNodeName)
    serviceNodeName = serviceNodeName or serviceName
    local node = skynet.config[serviceNodeName .. "server"] or skynet.config.id
    local proxy = ggclass.Proxy.new(node,"." .. serviceName)
    gg.proxy[serviceName] = proxy
    return proxy
end

function gg.loadStartConfig()
    local config = skynet.config
    config.index = tonumber(config.index)
    config.opentime = string.totime(config.opentime)
    config.cluster_port = tonumber(config.cluster_port)
    config.tcp_port = tonumber(config.tcp_port)
    config.kcp_port = tonumber(config.kcp_port)
    config.websocket_port = tonumber(config.websocket_port)
    config.http_port = tonumber(config.http_port)
    config.debug_port = tonumber(config.debug_port)
    config.onlinelimit = tonumber(config.onlinelimit)
end

function gg.busyness()
    --help=([0,0.5),:[0.5,1),:[1,max))
    local mqlen = skynet.mqlen()
    local loadlv = mqlen / 100 -- >=1--
    local busyness
    if gg._busyness then
        busyness = 0.3 * loadlv + 0.8 * gg._busyness()
    else
        busyness = loadlv
    end
    busyness = math.ceil(busyness * 1000) / 1000
    return busyness
end


function gg.status()
    local data = {
        -- 
        id = skynet.config.id,
        index = skynet.config.index,
        type = skynet.config.type,
        name = skynet.config.name,
        busyness = gg.busyness(),
        standalone = gg.standalone,
    }
    if gg._status then
        table.update(data,gg._status())
    end
    return data
end

if not skynet.snapshot_ignore then
    function skynet.snapshot_ignore(obj)
        if type(obj) ~= "table" then
            return true
        else
            if obj == _G or obj == debug.getregistry() then
                return false
            end
            if obj.__cache then
                -- cfg
                return true
            end
            if obj == gg.profile then
                return true
            end
        end
        return false
    end
end

function gg.genI18nTexts()
    local readfile = function (filename)
        filename = "src/etc/" .. filename
        local cjson = require "cjson"
        local fd = io.open(filename,"rb")
        local data = fd:read("*a")
        fd:close()
        return cjson.decode(data)
    end
    local languages = {}
    local en_US = readfile("i18n/en_US.json")
    for k,v in pairs(en_US) do
        if not languages[k] then
            languages[k] = {}
        end
        languages[k].en_US = v
    end
    local zh_TW = readfile("i18n/zh_TW.json")
    for k,v in pairs(zh_TW) do
        if not languages[k] then
            languages[k] = {}
        end
        languages[k].zh_TW = v
    end
    local zh_CN = readfile("i18n/zh_CN.json")
    for k,v in pairs(zh_CN) do
        if not languages[k] then
            languages[k] = {}
        end
        languages[k].zh_CN = v
    end

    return languages
end

function gg.initI18n()
    gg.useI18n = true
    skynet.register_serialize_type(i18n.I18N_TEXT_TYPE,i18n.serialize_text,i18n.deserialize_text)
    i18n.init({
        original_lang = "zh_CN",
        languages = gg.genI18nTexts()
    })
end

function gg.getGlobalCgfIntValue(key, defaultValue)
    local globalCgf = assert(cfg.get("etc.cfg.global"), "etc.cfg.global is not exist")
    if not globalCgf[key] then
        assert(defaultValue, "globalCgf["..key.."] not exist and defaultValue is nil")
        return defaultValue or 0
    end
    return globalCgf[key].intValue
end

function gg.getGlobalCgfFloatValue(key, defaultValue)
    local globalCgf = assert(cfg.get("etc.cfg.global"), "etc.cfg.global is not exist")
    if not globalCgf[key] then
        assert(defaultValue, "globalCgf["..key.."] not exist and defaultValue is nil")
        return defaultValue
    end
    return globalCgf[key].floatValue
end

function gg.getGlobalCgfTableValue(key, defaultValue)
    local globalCgf = assert(cfg.get("etc.cfg.global"), "etc.cfg.global is not exist")
    if not globalCgf[key] then
        assert(defaultValue, "globalCgf["..key.."] not exist and defaultValue is nil")
        return defaultValue
    end
    return globalCgf[key].tableValue
end

function gg.getGlobalCgfStringValue(key, defaultValue)
    local globalCgf = assert(cfg.get("etc.cfg.global"), "etc.cfg.global is not exist")
    if not globalCgf[key] then
        assert(defaultValue, "globalCgf["..key.."] not exist and defaultValue is nil")
        return defaultValue
    end
    return globalCgf[key].stringValue
end

function gg.getProxy(node,address)
    local proxys = gg.tempProxy[node]
    if not proxys then
        proxys = {}
        gg.tempProxy[node] = proxys
    end
    local proxy = proxys[address]
    if not proxy then
        proxy = ggclass.Proxy.new(node,address)
        proxys[address] = proxy
    end
    return proxy
end

function gg.isLocalServer()
    if skynet.config.clusterid == "master" or skynet.config.clusterid == "main" then
        return skynet.config.index < 20
    end
    return false
end

function gg.isInnerServer()
    return gg.isDevelopServer() or gg.isAlphaServer()
end

-- 
function gg.isDevelopServer()
    return skynet.config.clusterid == "master" or skynet.config.clusterid == "main"
end

-- 
function gg.isAlphaServer()
    return skynet.config.clusterid == "alpha"
end

-- 
function gg.isAlphaServer()
    return skynet.config.clusterid == "beta"
end

-- 
function gg.isReleaseServer()
    return skynet.config.clusterid == "release"
end

--- 
function gg.loadAllCfg()
    assert(cfg.load("etc.cfg.test"))
    assert(cfg.load("etc.cfg.filterWords"))
    assert(cfg.load("etc.cfg.build"))
    assert(cfg.load("etc.cfg.solider"))
    assert(cfg.load("etc.cfg.skill"))
    assert(cfg.load("etc.cfg.hero"))
    assert(cfg.load("etc.cfg.warShip"))
    assert(cfg.load("etc.cfg.life"))
    assert(cfg.load("etc.cfg.natural"))
    assert(cfg.load("etc.cfg.global"))
    assert(cfg.load("etc.cfg.item"))
    assert(cfg.load("etc.cfg.resPlanet"))
    assert(cfg.load("etc.cfg.buff"))
    assert(cfg.load("etc.cfg.bullet"))
    assert(cfg.load("etc.cfg.pledge"))
    assert(cfg.get("etc.cfg.pledge"))
    -- for k, v in pairs(pledgeCfg) do
    --     print("v.expression=", v.expression)
    --     v.expression = assert(load(v.expression,"t"), "load expression error cfgId="..k)
    --     print("v.expression=", v.expression, "expression(10)=", v.expression(10))
    -- end
end


function __hotfix(module)
end