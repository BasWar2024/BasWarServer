-- ""api
gg.api = gg.api or {}
local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

--chatserver -> local
function api.channel_publish(channel_id,is_queue,message)
    if is_queue then
        local channel = gg.channels:get(channel_id)
        if not channel then
            return
        end
        channel:_publish(is_queue,message)
    else
        gg.channels:local_publish(channel_id,message)
    end
end

-- order""game/client/http/api/payback
function api.payback(order)
    gg.payback(order)
end

-- ""#START
function api.wakeup(recoverPointId)
    skynet.wakeup(recoverPointId)
end
-- ""#END

function api.loginRPC(param1, param2, param3)
    -- print("loginRPC:")
    -- print(param1, param2, param3)
end

function api.updateItemProductCfg()
    
end


function api.doPlayerCmd(pid, cmd, ...)
    local player = gg.playermgr:loadplayer(pid)
    if not player then
        return nil
    end
    gg.playermgr:setplayerlasttick(pid)
    assert(player[cmd])
    return player[cmd](player, ...)
end

function api.batchDoPlayerCmd(pidList, cmd, ...)
    local cmdResult = {}
    for i, pid in ipairs(pidList) do
        local player = gg.playermgr:loadplayer(pid)
        if player then
            gg.playermgr:setplayerlasttick(pid)
            assert(player[cmd])
            cmdResult[pid] = player[cmd](player, ...)
        end
    end
    return cmdResult
end

function api.doOnlinePlayerCmd(pid, cmd, ...)
    local player = gg.playermgr:getonlineplayer(pid)
    if not player then
        return nil
    end
    assert(player[cmd])
    return player[cmd](player, ...)
end

function api.getOnlineStatus(pid)
    local player = gg.playermgr:getonlineplayer(pid)
    if not player then
        return 0
    end
    return 1
end

function api.kickAllPlayer(reason)
    gg.playermgr:kickall(reason)
end



--""
function api.onUnionAdd(unionInfo, createPid)
    if gg.unionProxy then
        gg.unionProxy:onUnionAdd(unionInfo, createPid)
    end
end

function api.onUnionDel(unionId, lastPid)
    if gg.unionProxy then
        gg.unionProxy:onUnionDel(unionId, lastPid)
    end
end

--""
function api.onUnionUpdate(...)
    if gg.unionProxy then
        gg.unionProxy:onUnionUpdate(...)
    end
end

function api.onChatUpdate(...)
    if gg.chatProxy then
        gg.chatProxy:onChatUpdate(...)
    end
end
-------------------------------------------------
function api.broadcastSysMail(...)
    if gg.mailProxy then
        gg.mailProxy:broadcastSysMail(...)
    end
end

function api.broadcastOpCfg(...)
    if gg.opCfgProxy then
        gg.opCfgProxy:broadcastOpCfg(...)
    end
end
-------------------------------------------------

function api.onGridUpdate(...)
    if gg.starmapProxy then
        gg.starmapProxy:onGridUpdate(...)
    end
end
-------------------------------------------------

------------------match----------------------
function api.onMatchUpdate(...)
    if gg.matchProxy then
        gg.matchProxy:onMatchUpdate(...)
    end
end

return gg.api
