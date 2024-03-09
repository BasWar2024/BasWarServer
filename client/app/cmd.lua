local http = require "socket.http"
local cjson = require "cjson"
local crypt = require "crypt"
local Answer = require "app.answer"

function exit()
    os.exit(0)
end

local device = {
    registerLoginType = 1,
    deviceCode = "deviceCode",
    network = "WIFI",
    wifiName = "wifiName",
    deviceType = 3,
    deviceMode = "deviceMode",
    os = "os",
    channelId = 0,
    lang = "zh_CN",
}

function help()
    print([=[
maybe you need change loginserver's ip
    e.g:
        app.config.loginserver.ip = "127.0.0.1"
connect(ip,port,[master_linkid]) ->
    tcp connect to ip:port and return a linkobj
    e.g:
        linkobj = connect("127.0.0.1",6001)
kcp_connect(ip,port,[master_linkid]) ->
    kcp connect to ip:port and return a kcpobj
    e.g:
        linkobj = kcp_connect("127.0.0.1",7001)
websocket_connect(ip,port,[master_linkid]) ->
    websocket connect to ip:port and return a kcpobj
    e.g:
        linkobj = websocket_connect("127.0.0.1",5001)
quicklogin(linkobj,account,roleid) ->
    use account#roleid to login,if account donn't exist,auto register it
    if account's role donn't exist,auto create role(roleid may diffrence)
    e.g:
        quicklogin(linkobj,"lgl",1000000)
entergame(linkobj,account,roleid) ->
    use roleid to debuglogin,if role donn't exist,auto create role
    debuglogin's features:
        1. do not communicate with loginserver when entergame
        so donn't use it except you really understand
    e.g:
        entergame(linkobj,"lgl",1000000)
linkobj:send_request(cmd,args,[callback]) ->
    use linkobj to send a request
    e.g:
        linkobj:send_request("C2S_Ping",{str="hello,world!"})
linkobj:send_response(cmd,args,session) ->
    use linkobj to send a response
linkobj:quite() ->
    stop/start print linkobj receive message
linkobj:close() ->
    close linkobj
    ]=])
end

function connect(ip,port,master_linkid)
    local tcp = require "app.client.tcp"
    local tcpobj = tcp.new()
    tcpobj.master_linkid = master_linkid
    tcpobj:connect(ip,port)
    return tcpobj
end

function kcp_connect(ip,port,master_linkid)
    local kcp = require "app.client.kcp"
    local kcpobj = kcp.new()
    kcpobj.master_linkid = master_linkid
    kcpobj:connect(ip,port)
    return kcpobj
end

function websocket_connect(ip,port,master_linkid)
    local websocket = require "app.client.websocket"
    local wbobj = websocket.new()
    wbobj.master_linkid = master_linkid
    wbobj:connect(ip,port)
    return wbobj
end

-- ,,tokendebug,
-- debug:
--1. do not communicate with loginserver when entergame
function entergame(linkobj,account,roleid,token,callback)
    local function fail(fmt,...)
        fmt = string.format("[linktype=%s,account=%s,roleid=%s] %s",linkobj.linktype,linkobj.account or account,roleid,fmt)
        print(string.format(fmt,...))
    end
    local name = string.format("%s",roleid)
    local token = token or "debug"
    local forward = "EnterGame"
    local checktoken = {account=account,token=token,forward=forward,version="99.99.99",device=device}
    linkobj:send_request("C2S_EnterGame",{roleid=roleid,checktoken=checktoken})
    linkobj:wait("S2C_EnterGameFail",function (linkobj,args)
        linkobj:ignore_one("S2C_EnterGameSuccess")
        linkobj:ignore_one("S2C_ReEnterGame")
        local status = args.status
        local code = args.code
        if code == Answer.code.ROLE_NOEXIST then
            checktoken.forward = "CreateRole"
            linkobj:send_request("C2S_CreateRole",{account=account,name=name,checktoken=checktoken})
            linkobj:wait("S2C_CreateRoleFail",function (linkobj,args)
                linkobj:ignore_one("S2C_CreateRoleSuccess")
                local status = args.status
                local code = args.code
                fail("op=S2C_CreateRoleFail,status=%s,code=%s",status,code)
            end)
            linkobj:wait("S2C_CreateRoleSuccess",function (linkobj,args)
                linkobj:ignore_one("S2C_CreateRoleFail")
                local role = args.role
                roleid = assert(role.roleid)
                fail(string.format("op=S2C_CreateRoleSuccess,roleid=%s",roleid))
                entergame(linkobj,account,roleid,token)
            end)
            return
        end
        fail("op=S2C_EnterGameFail,status=%s,code=%s",status,code)
    end)
    linkobj:wait("S2C_EnterGameSuccess",function (linkobj,args)
        linkobj:ignore_one("S2C_EnterGameFail")
        linkobj:ignore_one("S2C_ReEnterGame")
        linkobj.account = args.account
        linkobj.endpoint_linkid = args.linkid
        fail("op=S2C_EnterGameSuccess")
        print("EnterGameSuccess")
    end)
    linkobj:wait("S2C_ReEnterGame",function (linkobj,args)
        linkobj:ignore_one("S2C_EnterGameResult")
        local token = args.token
        local roleid = args.roleid
        local go_serverid = args.go_serverid
        local ip = args.ip
        local new_linkobj
        if linkobj.linktype == "tcp" then
            new_linkobj = connect(ip,args.tcp_port)
        elseif linkobj.linktype == "kcp" then
            new_linkobj = kcp_connect(ip,args.kcp_port)
        elseif linkobj.linktype == "websocket" then
            new_linkobj = websocket_connect(ip,args.websocket_port)
        end
        linkobj.child = new_linkobj
        entergame(new_linkobj,account,roleid,token)
    end)
    linkobj:wait("S2C_Scene_Enter",function (linkobj,args)
        local mapId = args.scene.mapId
        local sceneId = args.scene.sceneId
        fail("op=S2C_Scene_Enter,mapId=%s,sceneId=%s",mapId,sceneId)
        linkobj:send_request("C2S_Scene_LoadProgress",{
            loadProgress = 100,
        })
        if callback then
            callback(linkobj)
        end
    end)
end

local function signature(str,secret)
    if type(str) == "table" then
        str = table.ksort(str,"&",{sign=true})
    end
    return crypt.base64encode(crypt.hmac_sha1(secret,str))
end

local function make_request(request,secret)
    secret = secret or app.config.loginserver.appkey
    request.sign = signature(request,secret)
    return cjson.encode(request)
end

local function unpack_response(response)
    response = cjson.decode(response)
    return response
end

-- entergame,,
function quicklogin(linkobj,account,roleid)
    local function fail(fmt,...)
        fmt = string.format("[linktype=%s,account=%s,roleid=%s] %s",linkobj.linktype,linkobj.account or account,roleid,fmt)
        print(string.format(fmt,...))
    end
    local passwd = "1"
    local loginserver = app.config.loginserver
    local appid = app.config.appid
    local url = string.format("http://%s:%s/api/account/login",loginserver.ip,loginserver.port)
    local req = make_request({
        appid = appid,
        account = account,
        passwd = passwd,
        sdk = "local",
        platform = "local",
        device = cjson.encode(device),
    })
    local response,status = http.request(url,req)
    if not response or status ~= 200 then
        fail("login fail,status:%s",status)
        return
    end
    response = unpack_response(response)
    local code = response.code
    if code == Answer.code.ACCT_NOEXIST then
        -- register account
        local url = string.format("http://%s:%s/api/account/register",loginserver.ip,loginserver.port)
        local req = make_request({
            appid = appid,
            account = account,
            passwd = passwd,
            sdk = "local",
            platform = "local",
            device = cjson.encode(device),
        })
        local response,status = http.request(url,req)
        if not response or status ~= 200 then
            fail("register fail: status=%s",status)
            return
        end
        response = unpack_response(response)
        local code = response.code
        if code ~= Answer.code.OK then
            fail("register fail: code=%s,message=%s",code,response.message)
            return
        end
        quicklogin(linkobj,account,roleid)
        return
    elseif code ~= Answer.code.OK then
        fail("login fail: code=%s,message=%s",code,response.message)
        return
    end
    local token = response.data.token
    account = response.data.account or account
    entergame(linkobj,account,roleid,token)
end
