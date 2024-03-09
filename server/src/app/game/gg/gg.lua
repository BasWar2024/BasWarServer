--- game
--@script app.game.gg.gg

gg.invalidNameWords = {' ','\t','\n','\r'}

function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()

    gg.dbmgr = ggclass.cdbmgr.new()
    gg.savemgr = ggclass.csavemgr.new()
    gg.timectrl = ggclass.ctimectrl.new()
    gg.shareMgr = ggclass.ShareMgr.new()
    gg.playerProxy = ggclass.PlayerProxy.new()

    gg.playermgr = ggclass.cplayermgr.new()
    gg.loginserver = ggclass.cloginserver.new({
        host = skynet.getenv("loginserver"),
        appid = skynet.getenv("appid"),
        appkey = skynet.getenv("appkey"),
        loginserver_appkey = skynet.getenv("loginserver_appkey"),
    })
    -- : 
    gg.initI18n()
    gg.reqresp = ggclass.creqresp.new()

    local function channel_dispatch(channel,pid,is_queue,message)
        local player = gg.playermgr:getplayer(pid)
        if not player or not player.linkobj then
            return
        end
        player:sayToChannel(channel,is_queue,message)
    end

    gg.channels = ggclass.cchannels.new(channel_dispatch)
    gg.briefMgr = ggclass.BriefMgr.new()
    gg.allServerList = {}
    gg.onlineServerList = {}
    gg.version = gg.readVersion()
    gg.nameFilter = ggclass.WordFilter.new(cfg.get("etc.cfg.filterWords"),gg.invalidNameWords)

    gg.resMgr = ggclass.ResMgr.new()
    gg.bigmapMgr = ggclass.BigmapMgr.new()
    if skynet.config.centerserver == nil then
        gg.uniqueservice("center")
    end
    gg.proxyservice("center")
    if gg.isLocalServer() then
        -- ,
        --gg.uniqueservice("scenemgr")
    end
    --gg.sceneMgrProxy = ggclass.SceneMgrProxy.new()
    -- TODO: 
    skynet.newservice("app/rank/main",".rank")        --

    gg.initItemProductCfg()
    gg.initItemProductTotal()
end

function gg.start()
    gg.actor:start()
    gg.startTcpGate()
    --gg.startKcpGate()
    gg.startWebsocketGate()
    if gg.standalone then
        gg.cluster:open()
        logger.print("cluster:open")
    end
    gg.internal:open()
    logger.print("internal:open")
    gg.gm:open()
    logger.print("gm:open")
    gg.timectrl:tick()
    logger.print("timectrl:tick")
    gg.client:open()
    logger.print("client:open")
    -- TODO: 
    gg.briefMgr.event:addListener("onDelBriefAttrs",gg)
    gg.briefMgr.event:addListener("onSetBriefAttrs",gg)
    gg.briefMgr:start()
    if gg.standalone then
        gg.closeEnterGame = true
        gg.closeCreateRole = true
        local time = tonumber(skynet.config.auto_open_login_time)
        if time and time >= 0 then
            gg.startTimerOpenLogin(time)
        end
    end
end

function gg.exit()
    gg.briefMgr:exit()
    gg.playermgr:kickall()
    gg.savemgr:saveall()
    gg.dbmgr:shutdown()
    gg._exit()
end

function gg.onHeartbeat()
    --print("onHeartbeat",gg.actor.time,gg.actor.deltaTime)
    local now = skynet.timestamp()
    local diffTime = now - gg.heartbeatTime
    if diffTime >= 5000 then
        gg.heartbeatTime = skynet.timestamp()
        local status = gg.heartbeatStatus()
        status.id = skynet.config.id
        status.busyness = gg.busyness()
        gg.proxy.center:sendx(function (nodeExist)
            if not nodeExist then
                gg.proxy.center:send("exec","gg.nodeMgr:login",gg.status())
                gg.briefMgr:resubscribeAllBrief()
                return
            end
        end,"exec","gg.nodeMgr:heartbeat",status)
    end
end

function gg._busyness()
    local linknum = gg.client.linkobjs.length
    local onlinelimit = tonumber(skynet.config.onlinelimit)
    return linknum / onlinelimit
end

function gg._status()
    local data = {
        appid = skynet.config.appid,
        appkey = skynet.config.appkey,
        zoneid = skynet.config.zoneid,
        zonename = skynet.config.zonename,
        clusterid = skynet.config.clusterid,
        clustername = skynet.config.clustername,
        opentime = skynet.config.opentime,
        loglevel = skynet.config.loglevel,

        ip = skynet.config.ip,
        cluster_ip = skynet.config.cluster_ip,
        cluster_port = skynet.config.cluster_port,
        tcp_port = skynet.config.tcp_port,
        kcp_port = skynet.config.kcp_port,
        websocket_port = skynet.config.websocket_port,
        http_port = skynet.config.http_port,
        debug_port = skynet.config.debug_port,
        runId = gg.runId,

        -- 
        tcp_gate = gg.gate.tcp,
        kcp_gate = gg.gate.kcp,
        websocket_gate = gg.gate.websocket,
    }
    table.update(data,gg.heartbeatStatus())
    return data
end

function gg.heartbeatStatus()
    return {
        onlinelimit = gg.playermgr.onlinelimit,
        onlinenum = gg.playermgr.onlinenum,
        tuoguannum = gg.playermgr:tuoguannum(),
        min_onlinenum = gg.min_onlinenum,
        max_onlinenum = gg.max_onlinenum,
        linknum = gg.client and gg.client.linkobjs.length or 0,
        cpu = skynet.stat("cpu"),
        message = skynet.stat("message"),
        mqlen = skynet.mqlen(),
        task = skynet.task(),
    }
end

--- ?
---@param[type=string] account 
---@param[type=string] ip ip
function gg.isCloseCreateRole(account,ip)
    return gg.closeCreateRole
end

--- 
---@param[type=string] account 
---@param[type=string] ip ip
function gg.isCloseEnterGame(account,ip)
    return gg.closeEnterGame
end

--- 
---@param[type=table] player 
function gg.isBanEnterGame(player)
    return false
end

--- ip
--@param[type=string] ip IP
--@return[type=bool] true=,false=
function gg.isDebugLoginSafeIp(ip)
    if ip == "127.0.0.1" then
        return true
    end
    return false
end

--- 
function gg.isValidName(name)
    local code = gg.nameFilter:isValidText(name,1,20)
    if code ~= ggclass.WordFilter.CODE_OK then
        if code == ggclass.WordFilter.CODE_TOO_SHORT then
            return httpc.answer.code.NAME_TOO_SHORT
        elseif code == ggclass.WordFilter.CODE_TOO_LONG then
            return httpc.answer.code.NAME_TOO_LONG
        elseif code == ggclass.WordFilter.CODE_FMT_ERR then
            return httpc.answer.code.NAME_FMT_ERR
        else
            return httpc.answer.code.NAME_ERR
        end
    end
    if gg.isRepeatName(name) then
        return httpc.answer.code.REPEAT_NAME
    end
    return httpc.answer.code.OK
end

function gg.isRepeatName(name)
    local db = gg.dbmgr:getdb()
    local data = db.player:findOne({["attr.name"] = name}, {pid = 1})
    if data then
        return true
    end
    return false
end

function gg.logStatus()
    -- 5
    if gg.time.time() % 300 == 0 then
        gg.min_onlinenum = nil
        gg.max_onlinenum = nil
    end
    gg.min_onlinenum = gg.min_onlinenum or gg.playermgr.onlinenum
    gg.max_onlinenum = gg.max_onlinenum or gg.playermgr.onlinenum
    if gg.playermgr.onlinenum < gg.min_onlinenum then
        gg.min_onlinenum = gg.playermgr.onlinenum
    end
    if gg.playermgr.onlinenum > gg.max_onlinenum then
        gg.max_onlinenum = gg.playermgr.onlinenum
    end
    local server = gg.status()
    logger.logf("info","status","serverid=%s,onlinenum=%s,tuoguannum=%s,min_onlinenum=%s,max_onlinenum=%s,linknum=%s,onlinelimit=%s,cpu=%s,message=%s,mqlen=%s,task=%s,busyness=%s",
        server.id,server.onlinenum,server.tuoguannum,server.min_onlinenum,server.max_onlinenum,server.linknum,server.onlinelimit,server.cpu,server.message,server.mqlen,server.task,server.busyness)
    local serverid = server.id
    if skynet.config.type == "game" then
        local status,response = gg.loginserver:updateserver(serverid,server)
        assert(status==200)
        assert(response.code == httpc.answer.code.OK)
    end
    local version = "0.0.0"     -- 
    local platform = "local"
    local status,response = gg.loginserver:serverlist(version,platform)
    assert(status==200)
    assert(response.code == httpc.answer.code.OK)
    local allServerList = response.data.serverlist
    local onlineServerList = table.filter(allServerList,function (srv)
        return srv.is_down == 0
    end)
    for i,server in ipairs(allServerList) do
        local hasServer = gg.allServerList[server.id]
        if hasServer then
            table.update(hasServer,server)
        else
            gg.allServerList[server.id] = server
        end
    end
    for i,server in ipairs(onlineServerList) do
        local hasServer = gg.onlineServerList[server.id]
        if hasServer then
            table.update(hasServer,server)
        else
            gg.onlineServerList[server.id] = server
        end
    end
    local my = gg.allServerList[skynet.config.id]
    if my then
        gg.is_new = my.is_new
        gg.is_down = my.is_down
    else
        gg.is_new = 0
        gg.is_down = 0
    end
end

--- ()
---@param[type=table] linkobj 
---@param[type=string] err 
function gg.sayError(linkobj,err)
    gg.client:send(linkobj,"S2C_Msg_Error",{
        err = err,
    })
end

--- ,
---@param[type=int] pid id
---@return[type=bool] true=,false=
---@return[type=int]  0=,1=,2=
---@return[type=string] id
function gg.route(pid)
    local brief = gg.briefMgr:getBrief(pid)
    if not brief then
        return false
    end
    return true,brief.onlineState,brief.currentServerId
end

--- 
---@param[type=table] order ,game/client/http/api/payback
function gg.payback(order)
    local account = order.account
    local roleid = order.roleid
end

--- : 
function gg.onSecond()
    local now = gg.time.time()
    if now % 10 == 0 then
        gg.logStatus()
    end
    gg.playermgr:broadcast(ggclass.cplayer.onSecond)
end

function gg.on_minute_update()
    gg.playermgr:onMinute()
    gg.playermgr:broadcast(ggclass.cplayer.onMinuteUpdate)
end

--- : 5
function gg.onFiveMinuteUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onFiveMinuteUpdate)
end

--- : 
function gg.onHalfHourUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onHalfHourUpdate)
end

--- : 
function gg.onHourUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onHourUpdate)
end

--- : 
function gg.onDayUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onDayUpdate)
end

--- : 
function gg.onMondayUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onMondayUpdate)
end

--- : 
function gg.onSundayUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onSundayUpdate)
end

function gg:onDelBriefAttrs(event,brief,keys)
end

function gg:onSetBriefAttrs(event,brief,attrs)
    local pid = brief.pid
    attrs.pid = pid
    for pid in pairs(brief.subscribers) do
        local player = gg.playermgr:getplayer(pid)
        if player then
            gg.client:send(player.linkobj,"S2C_Player_UpdateBrief",{
                brief = attrs,
            })
        end
    end
end

--- 
function gg.initItemProductCfg()
    gg.itemProductCfg = {}
    local itemProductCfg = gg.shareMgr:call("getItemProductCfg")
    if not itemProductCfg or #itemProductCfg == 0 then
        itemProductCfg = {}
        local itemCfg = cfg.get("etc.cfg.item")
        for k, v in pairs(itemCfg) do
            if v.product then
                gg.itemProductCfg[v.cfgId] = { cfgId = v.cfgId, product = v.product }
                itemProductCfg[#itemProductCfg+1] = gg.itemProductCfg[v.cfgId]
            end
        end
        gg.shareMgr:call("setItemProductCfg", itemProductCfg)
    else
        local i=1
        for k, v in pairs(itemProductCfg) do
            gg.itemProductCfg[v.cfgId] = v
        end
    end
end

--- 
function gg.updateItemProductCfg()
    local itemProductCfg = gg.shareMgr:call("getItemProductCfg")
    if itemProductCfg and #itemProductCfg > 0  then
        for k, v in pairs(itemProductCfg) do
            gg.itemProductCfg[v.cfgId] = v
        end
    end
end

--
function gg.initItemProductTotal()
    for quality=2,5 do
        local defaultValue = 0
        if quality == 5 then
            defaultValue = gg.getGlobalCgfIntValue("ProductTotal5",9)
        elseif quality == 4 then
            defaultValue = gg.getGlobalCgfIntValue("ProductTotal4",999)
        elseif quality == 3 then
            defaultValue = gg.getGlobalCgfIntValue("ProductTotal3",9999)
        elseif quality == 2 then
            defaultValue = gg.getGlobalCgfIntValue("ProductTotal2",99999)
        end
        local total =  gg.shareMgr:call("getProductTotal", quality)
        if not total then
            gg.shareMgr:call("setProductTotal", quality, defaultValue)
        end
    end
end

--- : 
function gg.onMonthUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onMonthUpdate)
end

--- 
function gg.onHotfixCfg(filename)
end

--- AI
function gg.onHotfixAI(aiName)
end



function __hotfix(module)
end