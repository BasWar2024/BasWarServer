local ChatProxy = class("ChatProxy")

function ChatProxy:ctor()
    self.node = skynet.config.id
    local centerserver = skynet.config.centerserver or self.node
    self.chatProxy = ggclass.Proxy.new(centerserver, ".chat")
end

function ChatProxy:doOnlinePlayerCmd(cmd, ...)
    local allPlayers = gg.playermgr:allplayer()
    for i,pid in ipairs(allPlayers) do
        local player = gg.playermgr:getonlineplayer(pid)
        if player and player.chatBag and player.chatBag[cmd] then
            player.chatBag[cmd](player.chatBag, ...)
        end
    end
end

function ChatProxy:onChatUpdate(cmd, ...)
    if cmd == "onChatWorldMsgNew" then
        self:doOnlinePlayerCmd("onChatWorldMsgNew", ...)
    end
end

function ChatProxy:sendSysMsg(data)
    local sysMsg = {
        time = gg.time.time(),
        channelType = data.channelType,
        playerId = data.playerId or 0,
        playerName = data.playerName or "",
        headIcon = data.headIcon or "",
        text = data.text,
        unionId = data.unionId,
        unionJob = 0,
        unionName = data.unionName,
        vip = 0,
    }
    self:send("addSysMsg", sysMsg)
end

function ChatProxy:call(cmd, ...)
    return self.chatProxy:call("api", cmd, ...)
end

function ChatProxy:send(cmd, ...)
    return self.chatProxy:send("api", cmd, ...)
end

return ChatProxy