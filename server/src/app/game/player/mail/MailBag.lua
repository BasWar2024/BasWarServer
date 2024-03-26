local MailBag = class("MailBag")

function MailBag:ctor(param)
    self.player = assert(param.player, "param.player is nil")
    self.mailsDict = {}   --id : mail
    self.lastSysMailId = nil
    self.lastPlyMailId = nil
    self.testActivityRewardTick = 0
end

function MailBag:serialize()
    local data = {}
    data.lastSysMailId = self.lastSysMailId
    data.lastPlyMailId = self.lastPlyMailId
    data.testActivityRewardTick = self.testActivityRewardTick
    data.mailsDict = {}
    for id,mail in pairs(self.mailsDict) do
        table.insert(data.mailsDict, mail:serialize())
    end
    return data
end

function MailBag:deserialize(data)
    self.lastSysMailId = data.lastSysMailId
    self.lastPlyMailId = data.lastPlyMailId
    self.testActivityRewardTick = data.testActivityRewardTick or 0
    if data.mailsDict then
        for _,mailData in ipairs(data.mailsDict) do
            local mail = ggclass.PlyMail.new(mailData)
            mail:deserialize(mailData)
            self.mailsDict[mail.id] = mail
            if not self.lastSysMailId or self.lastSysMailId < mail.id then
                self.lastSysMailId = mail.id
            end
            if not self.lastPlyMailId or self.lastPlyMailId < mail.id then
                self.lastPlyMailId = mail.id
            end
        end
    end
end
-----------------------------------------------------
function MailBag:packMailBrief(mailsDict)
    local list = {}
    for id,mail in pairs(mailsDict) do
        table.insert(list, mail:packBrief())
    end
    return list
end

function MailBag:_sendUpdate(op, list)
    gg.client:send(self.player.linkobj,"S2C_Player_MailUpdate",{
        op_type = op,
        mailList = list
    })
end

function MailBag:_receiveAttachment(ids)
    local resData = {}
    local itemData = {}
    for i, id in ipairs(ids) do
        local mail = self.mailsDict[id]
        if mail then
            if mail.attachment then
                for _, value in ipairs(mail.attachment) do
                    if value.type == constant.MAIL_ATTACH_RES then
                        local resDict = {}
                        resDict[value.cfgId] = resDict[value.cfgId] or 0
                        resDict[value.cfgId] = resDict[value.cfgId] + value.count                        
                        self.player.resBag:addResDict(resDict, { logType = mail.logType, extraId = mail.sendPid}, false, {animationId = constant.ANIMATION_MAIL})
                        
                        resData[value.cfgId] = resData[value.cfgId] or 0
                        resData[value.cfgId] = resData[value.cfgId] + value.count
                    elseif value.type == constant.MAIL_ATTACH_ITEM then
                        self.player.itemBag:addItem(value.cfgId, value.count, {logType = mail.logType})
                        itemData[value.cfgId] = itemData[value.cfgId] or 0
                        itemData[value.cfgId] = itemData[value.cfgId] + value.count
                    end
                end
                mail.get = true
            end
        end
    end
    local resInfo = {}
    for k,v in pairs(resData) do
        table.insert(resInfo, { resCfgId = k, count = v })
    end
    local items = {}
    for k,v in pairs(itemData) do
        table.insert(items, { cfgId = k, num = v })
    end
    
    return true,{ resInfo = resInfo, items = items}
end

--""
function MailBag:getMail(id)
    local mail = self.mailsDict[id]
    if not mail then
        self.player:say(util.i18nFormat(errors.MAIL_NOT_EXIST))
        return
    end
    if not mail.read then
        mail.read = true
        -- self:_receiveAttachment({id})
    end
    gg.client:send(self.player.linkobj, "S2C_Player_MailDetail",{mail = mail:pack()})
    self:_sendUpdate(constant.OP_MODIFY, self:packMailBrief({[mail.id] = mail}))
end

--""
function MailBag:delMail(id)
    local mail = self.mailsDict[id]
    if not mail then
        self.player:say(util.i18nFormat(errors.MAIL_NOT_EXIST))
        return
    end
    if not self:_canDel(mail) then
        self.player:say(util.i18nFormat(errors.MAIL_ATTACH_NOT_RECEIVED))
        return
    end
    self.mailsDict[id] = nil
    self:_sendUpdate(constant.OP_DEL, {{id = id}})
end

function MailBag:_canDel(mail)
    if not mail.read then
        return
    end
    if mail.attachment and next(mail.attachment) and not mail.get then
        return
    end
    return true
end

--""
function MailBag:oneKeyDelMails()
    local delMails = {}
    for id, mail in pairs(self.mailsDict) do
        if self:_canDel(mail) then
            self.mailsDict[id] = nil
            table.insert(delMails, {id = id})
        end
    end
    if table.count(delMails) > 0 then
        self:_sendUpdate(constant.OP_DEL, delMails)
    end
end

--""
function MailBag:oneKeyReadMails()
    local readMails = {}
    for id, mail in pairs(self.mailsDict) do
        if not mail.read or not mail.get then
            mail.read = true
            readMails[id] = mail
        end
    end

    local res,data = self:_receiveAttachment(table.keys(readMails))
    -- ""
    if next(data.resInfo) or next(data.items) then
        gg.client:send(self.player.linkobj, "S2C_Player_TipNote",  { tipType = 1, resInfo = data.resInfo, items = data.items })
    end
    self:_sendUpdate(constant.OP_MODIFY, self:packMailBrief(readMails))
end

--""
function MailBag:receiveMailAttach(id)
    local mail = self.mailsDict[id]
    if not mail then
        self.player:say(util.i18nFormat(errors.MAIL_NOT_EXIST))
        return
    end
    if mail.get then
        self.player:say(util.i18nFormat(errors.MAIL_ATTACH_REPEAT_GET))
        return
    end
    if not mail.attachment then
        self.player:say(util.i18nFormat(errors.MAIL_ATTACH_NOT_EXIST))
        return
    end
    self:_receiveAttachment({id})
    -- gg.client:send(self.player.linkobj, "S2C_Player_MailDetail",{mail = mail:pack()})
    self:_sendUpdate(constant.OP_MODIFY, self:packMailBrief({[mail.id] = mail}))
end
-----------------------------------------------------
function MailBag:newMailsNotice()
    gg.mailProxy:getPlayerMails(self.player.pid, self.lastSysMailId, self.lastPlyMailId)
end

function MailBag:addMyMails(mailDict)
    local delPlyMailIds = {}
    local newMailDict = {}
    for id, mail in pairs(mailDict) do
        if not self.mailsDict[id] then
            local plymail = ggclass.PlyMail.new()
            plymail:deserialize(mail)
            local canAdd = false
            if plymail.mailType == constant.MAIL_TYPE_SYS then
                if not self.lastSysMailId or self.lastSysMailId < plymail.id then
                    self.lastSysMailId = plymail.id
                end
                if plymail.filter == constant.MAIL_GET_FILTER_BEFORE then
                    if self.player.createTime < plymail.sendTime then
                        canAdd = true
                    end
                elseif plymail.filter == constant.MAIL_GET_FILTER_AFTER then
                    if self.player.createTime >= plymail.sendTime then
                        canAdd = true
                    end
                else
                    canAdd = true
                end
            elseif plymail.mailType == constant.MAIL_TYPE_PLY then
                if not self.lastPlyMailId or self.lastPlyMailId < plymail.id then
                    self.lastPlyMailId = plymail.id
                end
                table.insert(delPlyMailIds, plymail.id)
                canAdd = true
            end
            if canAdd then
                self.mailsDict[id] = plymail
                newMailDict[id] = plymail
            end
        end
    end
    gg.mailProxy:delPlayerMails(self.player.pid, delPlyMailIds)
    gg.mailProxy:setPlayerMailInit(self.player.pid)
    self:_sendUpdate(constant.OP_ADD, self:packMailBrief(self.mailsDict))
end

function MailBag:localAddMyMail(args, isPush)
    local plymail = ggclass.PlyMail.new()
    local data = {
        id = gg.shareProxy:call("genMailId"),
        sendPid = args.sendPid,
        sendName = args.sendName,
        title = args.title,
        content = args.content,
        attachment = args.attachment,
        sendTime = args.sendTime or os.time(),
        duration = args.duration or constant.MAIL_DURATION,
        mailType = constant.MAIL_TYPE_PLY,
        logType = args.logType,
    }
    plymail:deserialize(data)
    self.mailsDict[plymail.id] = plymail

    if isPush then
        self:_sendUpdate(constant.OP_ADD, self:packMailBrief({[plymail.id] = plymail}))
    end
    return plymail
end

function MailBag:_customMail()
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_NEW_PLAYER]
    return self:localAddMyMail({
        sendPid = 0,
        sendName = mailCfg.sendName,
        title = mailCfg.mailTitle,
        content = mailCfg.mailContent,
    }, false)
end

function MailBag:_isExpire(mail)
    return (mail.sendTime + mail.duration * gg.time.HOUR_SECS) <= gg.time.time()
end

function MailBag:checkExpireMails()
    local now = gg.time.time()
    local delMails = {}
    for id, mail in pairs(self.mailsDict) do
        if self:_isExpire(mail) then
            self.mailsDict[id] = nil
            table.insert(delMails, {id = id})
        end
    end
    if table.count(delMails) > 0 then
        self:_sendUpdate(constant.OP_DEL, delMails)
    end
end

function MailBag:onSecond()
end

function MailBag:onHalfHourUpdate()
    self:checkExpireMails()
end

function MailBag:sendMailToInviter(sendId, sendName, mailData)
    local inviteDoc = gg.mongoProxy.inviteAccount:findOne({account = self.player.account})
    if inviteDoc then
        -- "" ""，""
        local fatherInviteCode = inviteDoc.fatherInviteCode
        local fatherPid = inviteDoc.fatherPid
        if fatherPid then
            local ret = gg.mailProxy:call("gmSendMail", sendId, sendName, { fatherPid }, mailData)
        end
    end
end

function MailBag:rebateToInviter(dict, cfgId)
    local mailItems = {}
    local rebateRate = gg.getGlobalCfgFloatValue("RebateRate", 0)
    local rewardRes = math.floor( dict.count * rebateRate )
    table.insert(mailItems, {
        cfgId = dict.res,
        count = rewardRes,
        type = constant.MAIL_ATTACH_RES,
    })
    local mailTemplate = gg.getExcelCfg("mailTemplate")

    local mailCfg = mailTemplate[cfgId]
    local sendId = self.player.pid
    local sendName = self.player.name
    local title = mailCfg.mailTitle

    local mailData = {
        title = title,
        content = string.format(mailCfg.mailContent, self.player.name, self.player.pid, rewardRes / 1000, constant.RES_NAME[dict.res]),
        attachment = mailItems,
        logType = gamelog.INVITEE_PURCHASE_RATE
    }
    self:sendMailToInviter(sendId, sendName, mailData)
end

function MailBag:sendNotificationMail(productId)
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_RECHARGE_NOTIFICATION]
    if constant.IS_GIFT_BAG[productId] then
        mailCfg =  mailTemplate[constant.MAIL_TEMPLATE_RECHARGE_GIFT_NOTIFICATION]
    elseif constant.IS_LOGIN_ACT[productId] then  -- ""
        return
    end
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle

    local productCfg = self.player.rechargeActivityBag:getProductCfg(productId)
    if not productCfg then
        return
    end
    local mailData = {
        title = title,
        content =  string.format(mailCfg.mailContent, productCfg.mailTips),
        logType = gamelog.RECHARGE
    }
    gg.mailProxy:send("gmSendMail", sendId, sendName, { self.player.pid }, mailData)
end

function MailBag:onload()
    local isNew = self.player.data:get("isNew",0)

    if isNew == 1 then--""
        self:_customMail()

        -- ""，""
        local mailTemplate = gg.getExcelCfg("mailTemplate")
        local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_SENDMAILTOINVITER]
        local sendId = self.player.pid
        local sendName = self.player.name
        local title = mailCfg.mailTitle

        local mailData = {
            title = title,
            content = string.format(mailCfg.mailContent, self.player.name, self.player.pid),
            logType = gamelog.SEND_EMAIL_TO_INVITER
        }
        self:sendMailToInviter(sendId, sendName, mailData)

        --""
        self.testActivityRewardTick = skynet.timestamp()
        self.player.data:set("isNew",nil)
    end
end

function MailBag:onlogin()
    gg.mailProxy:getPlayerMails(self.player.pid, self.lastSysMailId, self.lastPlyMailId)
    self:_sendUpdate(constant.OP_ADD, self:packMailBrief(self.mailsDict))
    -- if not gg.mailProxy:isPlayerMailInit(self.player.pid) then
    --     gg.mailProxy:getPlayerMails(self.player.pid, self.lastSysMailId, self.lastPlyMailId)
    -- else
    --     self:_sendUpdate(constant.OP_ADD, self:packMailBrief(self.mailsDict))
    -- end
    local isCheck = gg.shareProxy:call("getOpCfg", constant.REDIS_MAIL_CHECK_PLY_MAIL)
    if tonumber(isCheck) and tonumber(isCheck) == 1 then
        gg.mailProxy:send("checkAndGetPlayerMails", self.player.pid, self.lastSysMailId, self.lastPlyMailId)
    end
end

function MailBag:onlogout()

end

function MailBag:oncreate()
    
end

return MailBag
