local ChatBag = class("ChatBag")
function ChatBag:ctor(param)
    self.player = param.player
    self.isBanChat = false
    self.banTick = 0
end

function ChatBag:serialize()
    local data = {}
    data.isBanChat = self.isBanChat
    data.banTick = self.banTick
    return data
end

function ChatBag:deserialize(data)
    if data then
        self.isBanChat = data.isBanChat or false
        self.banTick = data.banTick or 0
    end
end

function ChatBag:onChatUnionMsgNew()
    self.player.autoPushBag:setAutoPushStatus(constant.AUTOPUSH_CFGID_CAHT_UNION_NEW)
end

function ChatBag:onChatWorldMsgNew()
    self.player.autoPushBag:setAutoPushStatus(constant.AUTOPUSH_CFGID_CAHT_WORLD_NEW)
end

--""
function ChatBag:banChat(minute)
    if minute then
        self.banTick = skynet.timestamp() + (minute * 60) * 1000
    end
    self.isBanChat = true
end

--""
function ChatBag:unbanChat()
    self.isBanChat = false
    self.banTick = 0
end

function ChatBag:sendChatMsg(channelType, text, hasHyperLink)
    if self.isBanChat then
        self.player:say(util.i18nFormat(errors.CHAT_BAN_TALK))
        return
    end
    if channelType ~= constant.CHAT_CHANNEL_WORLD and channelType ~= constant.CHAT_CHANNEL_UNION then
        self.player:say(util.i18nFormat(errors.CHAT_CHAN_TYPE_ERR))
        return
    end
    if string.len(text) == 0 then
        self.player:say(util.i18nFormat(errors.CHAT_TEXT_NULL))
        return
    end
    
    if channelType == constant.CHAT_CHANNEL_WORLD then
        local baseLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
        local minLevel = gg.getGlobalCfgIntValue("WorldChatMinBaseLevel", 5)
        if baseLevel < minLevel then
            self.player:say(util.i18nFormat(errors.BASE_BUILD_LV_LOW))
            return
        end
        -- local costHyt = gg.getGlobalCfgIntValue("WorldChatNeedMit", 10)
        -- if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, costHyt) then
        --     self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_CARBOXYL]))
        --     -- gg.client:send(self.player.linkobj, "S2C_Player_MitNotEnoughTips", {})
        --     return
        -- end
        -- if hasHyperLink == 1 then
        --     self.player:say(util.i18nFormat(errors.xxx))
        --     return
        -- end
    end
    if gg.chatFilter:isValidText(text, 0, 1024) ~= ggclass.WordFilter.CODE_OK then
        self.player:say(util.i18nFormat(errors.POLITE_LANGUAGE))
        return
    end
    
    -- local ok, isChange, utf8Text = gg.chatFilter:filter(text)
    -- if not ok then
    --     self.player:say(util.i18nFormat("invalid UTF8 text"))
    --     return
    -- end
    -- if isChange == true then
    --     text = utf8Text
    -- end
    
    -- if channelType == constant.CHAT_CHANNEL_WORLD then
    --     self.player.resBag:costRes(constant.RES_CARBOXYL, costHyt, {logType=gamelog.WORLD_CHAT})
    -- end

    local myUnionId = self.player.unionBag:getMyUnionId()
    local unionName = self.player.unionBag:getMyUnionName()
    local unionJob = self.player.unionBag:getMyUnionJob()
    local vip = self.player.vipBag:getVipLevel()
    local chain = self.player.playerInfoBag:getChainId()
    local chatMsg = {
        time = math.floor(skynet.timestamp()/1000),
        channelType = channelType,
        playerId = self.player.pid,
        playerName = self.player.name,
        headIcon = self.player.headIcon,
        text = text,
        unionId = myUnionId,
        unionJob = unionJob,
        unionName = unionName,
        vip = vip,
        hasHyperLink = hasHyperLink,
        chain = chain or 0,
    }
    gg.chatProxy:send("addChatMsg", self.player.pid, chatMsg, myUnionId)
end

function ChatBag:queryChatMsgs(channelType, cMsgId)
    local msgs
    if channelType == constant.CHAT_CHANNEL_WORLD then
        msgs, sMsgId = gg.chatProxy:call("queryWorldChatMsgs", self.player.pid, cMsgId)
        self.player.autoPushBag:delAutoPushStatus(constant.AUTOPUSH_CFGID_CAHT_WORLD_NEW)
    elseif channelType == constant.CHAT_CHANNEL_UNION then
        local myUnionId = self.player.unionBag:getMyUnionId()
        if not myUnionId then
            return
        end
        msgs, sMsgId = gg.chatProxy:call("queryUnionChatMsgs", self.player.pid, myUnionId, cMsgId)
        self.player.autoPushBag:delAutoPushStatus(constant.AUTOPUSH_CFGID_CAHT_UNION_NEW)
    end
    gg.client:send(self.player.linkobj, "S2C_Player_ChatMsgs", { msgs = msgs, sMsgId = sMsgId, channelType = channelType } )
end

--""
function ChatBag:visitFoundation(otherPid)
    local info = gg.playerProxy:call(otherPid, "visitFoundationInfo")
    if not info then
        self.player:say(util.i18nFormat(errors.NOT_ALLOW_VISIT))
        return
    end
    gg.client:send(self.player.linkobj, "S2C_Player_ChatVisitFoundation", {info = info})
end

function ChatBag:checkBanChatTick()
    if self.banTick == 0 then
        return
    end
    if skynet.timestamp() < self.banTick then
        return
    end
    self.banTick = 0
    self.isBanChat = false
end

function ChatBag:onSecond()
    self:checkBanChatTick()
end

function ChatBag:onlogin()

end

return ChatBag