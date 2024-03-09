local skynet = require "skynet"
local cjson = require "cjson"
local crypt = require "skynet.crypt"
local Answer = require "app.answer"
local httpc = require "http.httpc"
local config = require "app.config.custom"

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

local function signature(str,secret)
    if type(str) == "table" then
        str = table.ksort(str,"&",{sign=true})
    end
    return crypt.base64encode(crypt.hmac_sha1(secret,str))
end

local function make_request(request,secret)
    secret = secret or config.loginserver.appkey
    request.sign = signature(request,secret)
    return request
end

local function unpack_response(response)
    response = cjson.decode(response)
    return response
end

--- httpc.post,header,headercontent-typeform
--@param[type=string] host ,:127.0.0.1:4000
--@param[type=string] url url
--@param[type=string|table] form body,tableheadercontent-type
--@param[type=table,opt] header ,application/json
--@param[type=table,opt] recvheader header
function httpc.postx(host,url,form,header,recvheader)
    if not header then
        header = {
            ["content-type"] = "application/json;charset=utf-8"
        }
    end
    local content_type = header["content-type"]
    local body
    if string.find(content_type,"application/json") then
        if type(form) == "table" then
            body = cjson.encode(form)
        else
            body = form
        end
    else
        assert(string.find(content_type,"application/x-www-form-urlencoded"))
        if type(form) == "table" then
            body = string.urlencode(form)
        else
            body = form
        end
    end
    assert(type(body) == "string")
    return httpc.request("POST", host, url, recvheader, header, body)
end

-- ,,tokendebug,
-- debug:
--1. do not communicate with loginserver when entergame
function entergame(linkobj,account,roleid,token,handler)
    local function fail(fmt,...)
        fmt = string.format("[linktype=%s,account=%s,roleid=%s] %s",linkobj.linktype,linkobj.account or account,roleid,fmt)
        skynet.error(string.format(fmt,...))
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
            local createrole = handler.pack_create_role({account=account,name=name,checktoken=checktoken})
            linkobj:send_request("C2S_CreateRole",createrole)
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
                entergame(linkobj,account,roleid,token,handler)
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
        if handler then
            handler.onlogin(linkobj)
        end
    end)
    --[[
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
        entergame(new_linkobj,account,roleid,token,handler)
    end)
    ]]
    --[[
    linkobj:wait("S2C_Scene_Enter",function (linkobj,args)
        handler.sceneId = args.scene.sceneId
        linkobj:send_request("C2S_Scene_LoadProgress",{
            loadProgress = 100,
        })
        if handler then
            handler.onlogin(linkobj)
        end
    end)
    ]]
end


-- entergame,,
local function quicklogin(linkobj,account,roleid,handler)
    local function fail(fmt,...)
        fmt = string.format("[linkid=%s,account=%s,roleid=%s] login fail %s",linkobj.linkid,linkobj.account or account,roleid,fmt)
        skynet.error(string.format(fmt,...))
    end
    local passwd = "1"
    local loginserver = string.format("%s:%s",config.loginserver.ip,config.loginserver.port)
    local appid = config.appid
    local url = "/api/account/login"
    local req = make_request({
        appid = appid,
        account = account,
        passwd = passwd,
        platform = "local",
        sdk = "local",
        device = cjson.encode(device),
    })
    local status,response = httpc.postx(loginserver,url,req)
    if status ~= 200 then
        fail("login fail,status:%s",status)
        return
    end
    response = unpack_response(response)
    local code = response.code
    if code == Answer.code.ACCT_NOEXIST then
        -- register account
        local url = "/api/account/register"
        local req = make_request({
            appid = appid,
            account = account,
            passwd = passwd,
            sdk = "local",
            platform = "local",
            device = cjson.encode(device),
        })
        local status,response = httpc.postx(loginserver,url,req)
        if status ~= 200 then
            fail("register fail: status=%s",status)
            return
        end
        response = unpack_response(response)
        local code = response.code
        if code ~= Answer.code.OK then
            fail("register fail: code=%s,message=%s",code,response.message)
            return
        end
        quicklogin(linkobj,account,roleid,handler)
        return
    elseif code ~= Answer.code.OK then
        fail("login fail: code=%s,message=%s",code,response.message)
        return
    end
    local token = response.data.token
    account = response.data.account or account
    entergame(linkobj,account,roleid,token,handler)
end

return {
    entergame = entergame,
    quicklogin = quicklogin,
}
