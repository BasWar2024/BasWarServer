---
--@script app.player.playermgr.kuafu
--@usage
--CGS1,GS2
--  1. GS1token,GS2
--  2. GS1CGS2(token),C,C
--  3. CGS1,GS2,tokenGS2
--  4. GS2C,C
--  5. CGS2(C,)



---
--@param[type=int|table] linkobj ID|
--@param[type=string] onlogin gg.pack_function

local cplayermgr = reload_class("cplayermgr")

--- (,,)
--@param[type=table] linkobj 
--@param[type=string] go_serverid id
--@param[type=string] onlogin (gg.pack_function)
function cplayermgr:go_server(linkobj,go_serverid,onlogin)
    local fromServerId = skynet.config.id
    if fromServerId == go_serverid then
        if onlogin then
            local callback = gg.unpack_function(onlogin)
            xpcall(callback,gg.onerror)
        end
        return
    end
    local go_server = gg.onlineServerList[go_serverid]
    if not go_server then
        return
    end
    local account
    local pid
    local player
    if type(linkobj) == "number" then
        player = self:getplayer(linkobj)
        if not player then
            return
        end
        if player.beforeGoServer then
            player:beforeGoServer(go_serverid)
        end
        account = player.account
        pid = player.pid
    else
        -- linkobj
        account = linkobj.account
        pid = linkobj.roleid
    end
    local ttl = skynet.config.tokentick
    local token = string.gen_token(fromServerId)
    local token_data = {
        kuafu = true,
        onlogin = onlogin,
        fromServerId = fromServerId,
        account = account,
    }
    logger.logf("info","kuafu","op=go_server,pid=%s,fromServerId=%s,go_serverid=%s,token=%s",pid,fromServerId,go_serverid,token)
    gg.cluster:call(go_serverid,".game","exec","gg.playermgr.tokens:set",token,token_data,ttl)
    gg.client:send(linkobj,"S2C_ReEnterGame",{
        token = token,
        roleid = pid,
        go_serverid = go_serverid,
        ip = go_server.ip,
        tcp_port = go_server.tcp_port,
        kcp_port = go_server.kcp_port,
        websocket_port = go_server.websocket_port,
    })
    local reason = string.format("go_server:%s",go_serverid)
    if type(linkobj) == "number" then
        self:kick(pid,reason)
    else
        gg.client:dellinkobj(linkobj.linkid,true)
    end
end

return cplayermgr