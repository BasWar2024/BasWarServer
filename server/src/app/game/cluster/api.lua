-- api
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

-- ordergame/client/http/api/payback
function api.payback(order)
    gg.payback(order)
end

-- #START
function api.wakeup(recoverPointId)
    skynet.wakeup(recoverPointId)
end
-- #END

function api.loginRPC(param1, param2, param3)
    -- print("loginRPC:")
    -- print(param1, param2, param3)
end

function api.updateItemProductCfg()
    gg.updateItemProductCfg()
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

return gg.api
