local ChatMgr = class("ChatMgr")

function ChatMgr:ctor()
    self.dirty = false
    self.savetick = 300
    self.savename = "chat_mgr"
    self.channels = {}
    self.channelCd = {}
    self:init()
end

function ChatMgr:init()
    local docs = gg.mongoProxy.chat_channel:find({})
    for _, doc in pairs(docs) do
        local channel = ggclass.ChatChannel.new()
        channel:deserialize(doc)
        self.channels[channel.channelId] = channel
        gg.savemgr:autosave(channel)
    end
end

function ChatMgr:checkAndSetChannelCD(channelType, channelId, pid)
    channelType = channelType or 0
    local cd = constant.CHAT_CHANNEL_CD[channelType] or 0
    if cd <= 0 then
        return true
    end
    local channelInfo = self.channelCd[channelId] or {}
    local lastTick = channelInfo[pid] or 0
    local nowTick = skynet.timestamp()
    if lastTick + (cd * 1000) > nowTick then
        return false
    end
    channelInfo[pid] = nowTick
    self.channelCd[channelId] = channelInfo
    return true
end

function ChatMgr:getChannel(channelId, channelType)
    local channel = self.channels[channelId]
    if channel then
       return channel 
    end
    local channel = ggclass.ChatChannel.new()
    channel.channelId = channelId
    channel.channelType = channelType
    channel.dirty = true
    channel:save_to_db()
    self.channels[channelId] = channel
    gg.savemgr:autosave(channel)
    return channel
end

function ChatMgr:addChatMsg(pid, msg, unionId)
    local channelId = 0
    if msg.channelType == constant.CHAT_CHANNEL_UNION then
        channelId = unionId
    end
    local ret = self:checkAndSetChannelCD(msg.channelType, channelId, pid)
    if not ret then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.CHAT_CD))
        return
    end
    local channel = self:getChannel(channelId, msg.channelType)
    if channel then
        channel:addMsg(msg)
    end
end

function ChatMgr:addSysMsg(sysMsg)
    local channelId = 0
    if sysMsg.channelType == constant.CHAT_CHANNEL_UNION then
        channelId = sysMsg.unionId
    end
    local channel = self:getChannel(channelId, sysMsg.channelType)
    if channel then
        channel:addMsg(sysMsg)
    end
end

function ChatMgr:queryWorldChatMsgs(pid, msgId)
    local channel = self:getChannel(0, constant.CHAT_CHANNEL_WORLD)
    return channel:getMsgs(msgId)
end

function ChatMgr:queryUnionChatMsgs(pid, unionId, msgId)
    if not unionId then
        return
    end
    local channel = self:getChannel(unionId, constant.CHAT_CHANNEL_UNION)
    return channel:getMsgs(msgId)
end

function ChatMgr:shutdown()
    self.dirty = true
    for k, channel in pairs(self.channels) do
        channel:shutdown()
    end
end

return ChatMgr