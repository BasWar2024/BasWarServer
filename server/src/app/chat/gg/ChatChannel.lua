local ChatChannel = class("ChatChannel")

function ChatChannel:ctor()
    self.dirty = false
    -- self.savetick = 300
    self.savename = "ChatChannel"
    self.channelId = 0   --""ID ""Id""Id
    self.channelType = 0 --"" 1-"" 2-""
    self.msgs = {}
    self.msgId = 0
end

function ChatChannel:load_from_db()
    
end

function ChatChannel:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    gg.mongoProxy.chat_channel:update({channelId = self.channelId}, data, true, false)
    self.dirty = false
end

function ChatChannel:serialize()
    local data = {}
    data.channelId = self.channelId
    data.channelType = self.channelType
    data.msgId = self.msgId
    data.msgs = self.msgs
    return data
end

function ChatChannel:deserialize(data)
    if data then
        self.channelId = data.channelId or 0
        self.channelType = data.channelType or 0
        self.msgs = {}
        self.msgId = data.msgId or 0
        for k, v in pairs(data.msgs) do
            if v.msgId > self.msgId then
                self.msgId = v.msgId
            end
            table.insert(self.msgs, v)
        end
    end
end

function ChatChannel:getMsgId()
    self.msgId = self.msgId + 1
    return self.msgId
end

function ChatChannel:addMsg(msg)
    msg.msgId = self:getMsgId()
    table.insert(self.msgs, msg)
    local msgCount = #self.msgs
    for k, v in pairs(self.msgs) do
        if v.playerId == msg.playerId then
            v.headIcon = msg.headIcon
        end
    end
    if msgCount > gg.MaxChatMsgCount then
        for i=1, msgCount - gg.MaxChatMsgCount do
            table.remove(self.msgs, 1)
        end
    end
    self.dirty = true
    if msg.channelType == constant.CHAT_CHANNEL_UNION then
        gg.unionProxy:send("sendUnionOnlineMembers", msg.unionId, constant.UNION_JOB_MEMBER, "onChatUnionMsgNew")
    else
        gg.centerProxy:broadCast2Game("onChatUpdate", "onChatWorldMsgNew")
    end
end

function ChatChannel:getMsgs(msgId)
    msgId = msgId or 0
    local data = {}
    for k, v in pairs(self.msgs) do
        if v.msgId > msgId then
            table.insert(data, v)
        end
    end
    return data, self.msgId
end

function ChatChannel:shutdown()
    self.dirty = true
    self:save_to_db()
end

return ChatChannel