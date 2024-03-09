local net = {}

function net.C2S_Ping(linkobj,args)
    local lutil = require "lutil"
    local player
    local token = nil
    local changeCount = math.floor(skynet.config.tokentick / 2 / 5)
    if typename(linkobj) == "cplayer" then
        player = linkobj
        linkobj = player.linkobj
        player.heartbeatCount = (player.heartbeatCount or 0) + 1
        if player.heartbeatCount % changeCount == 0 then
            -- token
            token = string.gen_token()
            linkobj.token = token
            gg.playermgr.tokens:set(token,{account = player.account},skynet.config.tokentick)
        end
    end
    if linkobj then
        gg.client:send(linkobj,"S2C_Pong",{
            str = args and args.str,
            time = lutil.getms(),
            token = token,
        })
    end
end

function net.is_low_version(version)
    local list1 = string.split(gg.version,".")
    local list2 = string.split(version,".")
    local len = #list1
    for i=1,len do
        local ver1 = tonumber(list1[i])
        local ver2 = tonumber(list2[i])
        if not ver2 then
            return true
        end
        if ver2 < ver1 then
            return true
        end
    end
    return false
end

function net.checktoken(linkobj,args,what)
    local token = assert(args.token)
    local account = assert(args.account)
    local version = assert(args.version)
    local device = args.device       -- 
    local ip = linkobj.ip
    if gg.starting then
        local response = httpc.answer.response(httpc.answer.code.SERVER_STARTING)
        response.status = 200
        return false,response
    end
    if gg.stoping then
        local response = httpc.answer.response(httpc.answer.code.SERVER_STOPING)
        response.status = 200
        return false,response
    end
    if net.is_low_version(version) then
        local response = httpc.answer.response(httpc.answer.code.LOW_VERSION)
        response.status = 200
        return false,response
    end
    if what == "CreateRole" then
        if gg.isCloseCreateRole(account,ip) then
            local response = httpc.answer.response(httpc.answer.code.CLOSE_CREATEROLE)
            response.status = 200
            return false,response
        end
    else
        -- EnterGame
        if gg.isCloseEnterGame(account,ip) then
            local response = httpc.answer.response(httpc.answer.code.CLOSE_ENTERGAME)
            response.status = 200
            return false,response
        end
    end
    local debuglogin = false
    local token_data = gg.playermgr.tokens:get(token)
    if token == "debug" and gg.isDebugLoginSafeIp(linkobj.ip) then
        debuglogin = true
    elseif token_data ~= nil then
        if token_data.account and token_data.account ~= account then
            local response = httpc.answer.response(httpc.answer.code.TOKEN_UNAUTH)
            response.status = 200
            return false,response
        end
        if token_data.kuafu then
            -- 
            token_data.kuafu = nil
            linkobj.kuafu_forward = token_data
        end
    else
        local status,response = gg.loginserver:checktoken(account,token)
        if status ~= 200 then
            return false,{status = status}
        end
        if response.code ~= httpc.answer.code.OK then
            return false,{
                status = status,
                code = response.code,
                message = response.message,
            }
        end
        gg.playermgr.tokens:set(token,{account = account},skynet.config.tokentick)
    end
    linkobj.passlogin = true
    linkobj.version = version
    linkobj.token = token
    linkobj.debuglogin = debuglogin
    linkobj.device = device
    return true
end

function net.C2S_CreateRole(linkobj,args)
    local checktoken = assert(args.checktoken)
    local account = assert(args.account)
    local name = assert(args.name)
    local heroId = args.heroId or 1001
    local ok,response = net.checktoken(linkobj,checktoken,"CreateRole")
    if not ok then
        gg.client:send(linkobj,"S2C_CreateRoleFail",response)
        return
    end
    local errcode = gg.isValidName(name)
    if errcode ~= httpc.answer.code.OK then
        local response = httpc.answer.response(errcode)
        response.status = 200
        gg.client:send(linkobj,"S2C_CreateRoleFail",response)
        return
    end
    local role = {
        account = account,
        name = name,
        heroId = heroId,
    }
    local appid = skynet.config.appid
    local serverid = skynet.config.id
    local status,response = gg.loginserver:addrole(account,serverid,role,nil,appid,1000000,2000000000)
    if status ~= 200 then
        gg.client:send(linkobj,"S2C_CreateRoleFail",{status = status,})
        return
    end
    if response.code ~= httpc.answer.code.OK then
        gg.client:send(linkobj,"S2C_CreateRoleFail",{
            status = status,
            code = response.code,
            message = response.message,
        })
        return
    end
    local roledata = assert(response.data.role)
    role.roleid = assert(tonumber(roledata.roleid))
    role.name = roledata.name
    role.createTime = roledata.createTime or os.time()
    role.account = account
    role.currentServerId = serverid
    role.createServerId = serverid
    gg.playermgr:createplayer(role.roleid,role)
    gg.client:send(linkobj,"S2C_CreateRoleSuccess",{
        role = role,
    })
end

function net._entergame(linkobj,args)
    local checktoken = assert(args.checktoken)
    local pid = assert(args.roleid)
    local ok,response = net.checktoken(linkobj,checktoken,"EnterGame")
    local replace
    if not ok then
        gg.client:send(linkobj,"S2C_EnterGameFail",response)
        return
    end
    if linkobj.pid then
        local response = httpc.answer.response(httpc.answer.code.REPEAT_ENTERGAME)
        response.status = 200
        linkobj = linkobj.linkobj or linkobj
        gg.client:send(linkobj,"S2C_EnterGameFail",response)
        return
    end

    local player = gg.playermgr:getplayer(pid)
    if player then
        replace = true
        if not player:isdisconnect() then
            -- TODO: give tip to been replace's linkobj?
            -- will unbind and del linkobj
            player:beforeBeReplace(linkobj)
            player:disconnect(ggclass.cplayer.LOGOUT_TYPE_REPLACE)
        end
    else
        -- 
        local open_kuafu = skynet.getenv("open_kuafu") == "1"
        if open_kuafu then
            local ok,onlineState,currentServerId = gg.route(pid)
            if ok and onlineState ~= ggclass.cplayer.ONLINE_STATE_OFFLINE then
                if currentServerId ~= skynet.config.id then
                    -- online
                    linkobj.roleid = pid
                    gg.playermgr:go_server(linkobj,currentServerId)
                    return
                end
            end
        end
        replace = false
        player = gg.playermgr:recoverplayer(pid)
        if not player then
            local response = httpc.answer.response(httpc.answer.code.ROLE_NOEXIST)
            response.status = 200
            gg.client:send(linkobj,"S2C_EnterGameFail",response)
            return
        end
    end
    if gg.isBanEnterGame(player) then
        local response = httpc.answer.response(httpc.answer.code.BAN_ROLE)
        gg.client:send(linkobj,"S2C_EnterGameFail",response)
        return
    end
    gg.playermgr:bind_linkobj(player,linkobj)
    if not replace then
        -- gg.playermgr:loadplayerentergame,player
        if gg.playermgr:getplayer(pid) then
            gg.playermgr:delplayer(pid)
        end
        gg.playermgr:addplayer(player)
    end
    local response = {
        account = player.account,
        linkid = linkobj.linkid,
    }
    gg.client:send(linkobj,"S2C_EnterGameSuccess",response)
    local brief = player:entergame(replace)
    gg.client:send(linkobj,"S2C_EnterGameFinish",{ brief = brief })
end

function net.C2S_EnterGame(linkobj,args)
    local roleid = assert(args.roleid,"roleid==nil")
    local id = string.format("EnterGame.%s",roleid)
    --gg.clusterQueue:queue(id,net._entergame,linkobj,args)
    local ok,errmsg = gg.sync:once_do(id,net._entergame,linkobj,args)
    assert(ok,errmsg)
end

function net.C2S_ExitGame(player,args)
    gg.playermgr:kick(player.pid,"normal")
end

function net.C2S_CheckName(linkobj,args)
    local name = assert(args.name)
    local errcode = gg.isValidName(name)
    local ok = true
    local errmsg
    if errcode ~= httpc.answer.code.OK then
        local response = httpc.answer.response(errcode)
        errmsg = response.message
        ok = false
    end
    if typename(linkobj) == "cplayer" then
        linkobj = linkobj.linkobj
    end
    if linkobj then
        gg.client:send(linkobj,"S2C_NameIsValid",{
            name = name,
            ok = ok,
            errmsg = errmsg,
        })
    end
end

function __hotfix(module)
    gg.client:open()
end

return net
