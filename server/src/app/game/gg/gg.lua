--- game""
--@script app.game.gg.gg

gg.invalidNameWords = {' ','\t','\n','\r'}


function gg.init()
    gg.client.queue = false
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()

    --""
    skynet.newservice("app/mongodb/main", ".mongodb")
    gg.mongoProxy = ggclass.MongodbProxy.new()

    skynet.newservice("app/redisdb/main", ".redisdb")
    gg.redisProxy = ggclass.RedisProxy.new()

    gg.savemgr = ggclass.csavemgr.new()
    gg.timectrl = ggclass.ctimectrl.new()

    gg.shareProxy = ggclass.ShareProxy.new()

    gg.playerProxy = ggclass.PlayerProxy.new()
    gg.chainBridgeProxy = ggclass.ChainBridgeProxy.new()


    gg.playermgr = ggclass.cplayermgr.new()
    gg.loginserver = ggclass.cloginserver.new({
        host = skynet.getenv("loginserver"),
        appid = skynet.getenv("appid"),
        appkey = skynet.getenv("appkey"),
        loginserver_appkey = skynet.getenv("loginserver_appkey"),
    })
    -- "": ""
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
    gg.chatFilter = ggclass.WordFilter.new(cfg.get("etc.cfg.filterWords"))
    gg.dynamicCfg = ggclass.DynamicCfg.new()
    gg.multicastProxy = ggclass.MulticastProxy.new()
    gg.starmapProxy = ggclass.StarmapProxy.new()
    gg.unionProxy = ggclass.UnionProxy.new()
    gg.chatProxy = ggclass.ChatProxy.new()
    gg.mailProxy = ggclass.MailProxy.new()
    gg.opCfgProxy = ggclass.OpCfgProxy.new()
    gg.rankProxy = ggclass.RankProxy.new()
    gg.matchProxy = ggclass.MatchProxy.new()
    gg.activityProxy = ggclass.ActivityProxy.new()
    gg.battleMgr = ggclass.BattleMgr.new()
    -- gg.starMapExcel = ggclass.StarMapExcel.new()
    if skynet.config.centerserver == nil then
        gg.uniqueservice("center")
    end
    gg.proxyservice("center")
    if gg.isLocalServer() then
        -- "",""
        --gg.uniqueservice("scenemgr")
    end

    -- TODO: ""
    skynet.newservice("app/multicast/main", ".multicast")       --""
    skynet.newservice("app/gamelog/main",".gamelog")            --""

end

function gg.start()
    gg.actor:start()
    gg.startTcpGate()
    --gg.startKcpGate()
    -- gg.startWebsocketGate()
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
    -- TODO: ""
    gg.briefMgr.event:addListener("onDelBriefAttrs",gg)
    gg.briefMgr.event:addListener("onSetBriefAttrs",gg)
    gg.briefMgr:start()

    gg.unionProxy:start()
    gg.starmapProxy:start()
    gg.matchProxy:start()
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

        -- ""
        tcp_gate = gg.gate.tcp,
        kcp_gate = gg.gate.kcp,
        websocket_gate = gg.gate.websocket,
    }
    table.update(data,gg.heartbeatStatus())
    return data
end

function gg.heartbeatStatus()
    local baseInfo = {
        onlinelimit = gg.playermgr.onlinelimit,
        linknum = gg.client and gg.client.linkobjs.length or 0,
        cpu = skynet.stat("cpu"),
        message = skynet.stat("message"),
        mqlen = skynet.mqlen(),
        task = skynet.task(),
    }
    local actualNumDict = gg.playermgr:getActualNum()
    for k,v in pairs(actualNumDict) do
        baseInfo[k] = v
    end
    return baseInfo
end

--- ""?
---@param[type=string] account ""
---@param[type=string] ip ip
function gg.isCloseCreateRole(account,ip)
    return gg.closeCreateRole
end

--- ""
---@param[type=string] account ""
---@param[type=string] ip ip
function gg.isCloseEnterGame(account,ip)
    return gg.closeEnterGame
end

--- ""
---@param[type=table] player ""
function gg.isBanEnterGame(player)
    if player.banGame then
        return true
    end
    return false
end

--- ""ip
--@param[type=string] ip IP""
--@return[type=bool] true="",false=""
function gg.isDebugLoginSafeIp(ip)
    if ip == "127.0.0.1" then
        return true
    end
    return false
end

--- ""
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
    -- if gg.isRepeatName(name) then
    --     return httpc.answer.code.REPEAT_NAME
    -- end
    return httpc.answer.code.OK
end

function gg.isRepeatName(name)
    local data = gg.mongoProxy.player:findOne({["attr.name"] = name}, {pid = 1})
    if data then
        return true
    end
    return false
end

function gg.logStatus()
    -- ""5""，""
    if gg.time.time() % 300 == 0 then
        gg.playermgr:resetActualNum()
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
    local version = "0.0.0"     -- ""
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
    if gg.time.time() % 60 == 0 then
        gg.internal:send(".gamelog", "api", "addServerStatusLog", server)
    end
end

--- ""("")
---@param[type=table] linkobj ""
---@param[type=string] err ""
function gg.sayError(linkobj,err)
    gg.client:send(linkobj,"S2C_Msg_Error",{
        err = err,
    })
end

--- "",""
---@param[type=int] pid ""id
---@return[type=bool] true="",false=""
---@return[type=int] "" 0="",1="",2=""
---@return[type=string] ""id
function gg.route(pid)
    local brief = gg.briefMgr:getBrief(pid)
    if not brief then
        return false
    end
    return true,brief.onlineState,brief.currentServerId
end

--- ""
---@param[type=table] order "",""game/client/http/api/payback
function gg.payback(order)
    local account = order.account
    local roleid = order.roleid
end

--- "": ""
function gg.onSecond()
    local now = gg.time.time()
    if now % 10 == 0 then
        gg.logStatus()
    end
    gg.playermgr:broadcast(ggclass.cplayer.onSecond)
    if gg.battleMgr then
        gg.battleMgr:onSecond()
    end
end

function gg.onMinuteUpdate()
    gg.playermgr:onMinute()
    gg.playermgr:broadcast(ggclass.cplayer.onMinuteUpdate)
end

--- "": 5""
function gg.onFiveMinuteUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onFiveMinuteUpdate)
end

--- "": ""
function gg.onHalfHourUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onHalfHourUpdate)
end

--- "": ""
function gg.onHourUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onHourUpdate)
end

--- "": ""
function gg.onDayUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onDayUpdate)
end

--- "": ""
function gg.onMondayUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onMondayUpdate)
end

--- "": ""
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

--""
function gg.initSystemNoticeCfg()
    local noticeText = gg.shareProxy:call("getSystemNoticeInfo")
    if noticeText then
        gg.systemNoticeCfg = cjson.decode(noticeText)
    end
end

--""
function gg.updateSystemNoticeCfg()
    gg.initSystemNoticeCfg()
end

function gg.isGmRobotPlayer(pid)
    if pid >= constant.ROBOT_PVE_MIN_PLAYERID and pid <= constant.ROBOT_PVE_MAX_PLAYERID then
        return true
    end
    return false
end

--- "": ""
function gg.onMonthUpdate()
    gg.playermgr:broadcast(ggclass.cplayer.onMonthUpdate)
end

--- ""
function gg.onHotfixCfg(filename)

end

--- ""AI""
function gg.onHotfixAI(aiName)

end

function __hotfix(module)
end