local MailMgr = class("MailMgr")

function MailMgr:ctor(param)
    self.dirty = false
    self.savetick = 300
    self.savename = "mail_mgr"
    self.sysMailId = 0
    self.plyMailId = 0
    self.mailsDict = {}   --id : mail
    self.pidMailIds = {}  --pid: {id1,id2...}
    self:load_from_db()

end

function MailMgr:serialize()
    local data = {}
    data.sysMailId = self.sysMailId
    data.plyMailId = self.plyMailId
    return data
end

function MailMgr:deserialize(data)
    self.sysMailId = data.sysMailId
    self.plyMailId = data.plyMailId
end

function MailMgr:shutdown()
    self.dirty = true
    for id, mail in pairs(self.mailsDict) do
        mail:shutdown()
    end
end

function MailMgr:load_from_db()
    -- local docs = gg.mongoProxy.mail:find({})
    -- for _, doc in pairs(docs) do
    --     local mail = ggclass.Mail.new()
    --     mail:deserialize(doc)
    --     self.mailsDict[mail.id] = mail
    --     self.pidMailIds[mail.receivePid] = self.pidMailIds[mail.receivePid] or {}
    --     table.insert(self.pidMailIds[mail.receivePid], mail.id)
    --     gg.savemgr:autosave(mail)
    -- end
    -- self.dirty = true
    local data = gg.mongoProxy[self.savename]:findOne({})
    if data then
        self:deserialize(data)
    end
end

function MailMgr:save_to_db()
    if not self.dirty then
        return
    end
    local db = gg.mongoProxy
    local data = self:serialize()
    db[self.savename]:update({},data,true,false)
    self.dirty = false
end

function MailMgr:incSysMailId()
    self.sysMailId = gg.shareProxy:call("genMailId")
    return self.sysMailId
end

function MailMgr:incPlyMailId()
    self.plyMailId = gg.shareProxy:call("genMailId")
    return self.plyMailId
end

function MailMgr:getSysMailId()
    return self.sysMailId
end

function MailMgr:getPlyMailId()
    return self.plyMailId
end

function MailMgr:cleanUpMailsFromCache()
    local delMailIds = {}
    local now = gg.time.time()
    for id, mail in pairs(self.mailsDict) do
        if (mail.sendTime + gg.time.HOUR_SECS) < now then
            mail:save_to_db()
            table.insert(delMailIds, mail.id)
        end
    end
    for i, v in ipairs(delMailIds) do
        self.mailsDict[v] = nil
    end
end

function MailMgr:cleanUpMailsFromDB()
    local now = gg.time.time()
    skynet.fork(function()
        local mailDict = self:_findMailsFromDB("plymail", {})
        for id, mail in pairs(mailDict) do
            if (mail.sendTime + (mail.duration * gg.time.HOUR_SECS)) < now then
                gg.mongoProxy.plymail:safe_delete({id = id},true)
            end
        end

        local sysMailDict = self:_findMailsFromDB("sysmail", {})
        for id, mail in pairs(sysMailDict) do
            if (mail.sendTime + (mail.duration * gg.time.HOUR_SECS)) < now then
                gg.mongoProxy.sysmail:safe_delete({id = id},true)
            end
        end
    end)
end

function MailMgr:_findMailsFromCache(pid, lastPlyMailId, lastSysMailId)
    local mailDict = {}
    local delMailIds = {}
    for id, mail in pairs(self.mailsDict) do
        if lastPlyMailId and mail.mailType == constant.MAIL_TYPE_PLY then
            if pid and pid == mail.receivePid and mail.id > lastPlyMailId then
                mailDict[mail.id] = mail:serialize()
                table.insert(delMailIds, mail.id)
            end
        elseif lastSysMailId and mail.mailType == constant.MAIL_TYPE_SYS then
            if mail.receivePid == 0 and mail.id > lastSysMailId then
                mailDict[mail.id] = mail:serialize()
            end
        end
    end
    for _, id in pairs(delMailIds) do
        if self.mailsDict[id] then
            self.mailsDict[id] = nil
        end
    end
    return mailDict
end

function MailMgr:_findMailsFromDB(tblName, condition, func)
    local mailDict = {}
    local docs
    if tblName == "plymail" then
        docs = gg.mongoProxy.plymail:find(condition)
    else
        docs = gg.mongoProxy.sysmail:find(condition)
    end
    for _, doc in pairs(docs) do
        local mail = ggclass.Mail.new(doc)
        mail:deserialize(doc)
        mailDict[mail.id] = mail:serialize()
        if func then
            func(mail)
        end
    end
    return mailDict
end
-----------------------------------------------
function MailMgr:_getPlyMails(pid, lastPlyMailId, includeDel)
    local cacheMailDict = self:_findMailsFromCache(pid, lastPlyMailId, nil)
    local condition = {
        receivePid = pid,
        delete = {["$ne"] = true}
    }
    if lastPlyMailId then
        condition = {
            id = {["$gt"] = lastPlyMailId},
            receivePid = pid,
            delete = {["$ne"] = true}
        }
    end
    if includeDel then
        condition.delete = nil
    end
    local mailDict = self:_findMailsFromDB("plymail", condition)
    local retDict = {}
    for k, v in pairs(cacheMailDict) do
        retDict[k] = v
    end
    for k, v in pairs(mailDict) do
        if not retDict[k] then
            retDict[k] = v
        end
    end
    return retDict
end

function MailMgr:_getSysMails(pid, lastSysMailId)
    local cacheMailDict = self:_findMailsFromCache(pid, nil, lastSysMailId)
    local syscondition = {
        receivePid = 0
    }
    if lastSysMailId then
        syscondition = {
            id = {["$gt"] = lastSysMailId},
            receivePid = 0
        }
    end
    local retDict = {}
    for k, v in pairs(cacheMailDict) do
        retDict[k] = v
    end
    local now = gg.time.time()
    local mailDict = self:_findMailsFromDB("sysmail", syscondition)
    for id, mail in pairs(mailDict) do
        if mail.duration == 0 or (mail.duration > 0 and (mail.sendTime + mail.duration * 3600) > now) then
            retDict[id] = mail
        end
    end
    return retDict
end

function MailMgr:_saveMails(mailDict)
    for id, mail in pairs(mailDict) do
        mail.dirty = true
        mail:save_to_db()
    end
end

function MailMgr:_notifyPlyMails(mailDict)
    for id, mail in pairs(mailDict) do
    end
end

function MailMgr:_sendPlyMails(mailDict)
    for id, mail in pairs(mailDict) do
        mail:newPlyMail()
    end
end

function MailMgr:_createPlyMails(mailData, toPidList)
    mailData.mailType = constant.MAIL_TYPE_PLY
    local mailDict = {}
    for _, pid in ipairs(toPidList) do
        mailData.receivePid = pid
        local plyMailId = self:incPlyMailId()
        mailData.id = plyMailId
        local mail = ggclass.Mail.new(mailData)
        mail:deserialize(mailData)
        mailDict[mail.id] = mail
        self.mailsDict[mail.id] = mail
    end
    self.dirty = true
    
    skynet.fork(function()
        self:save_to_db()

        self:_saveMails(mailDict)
        self:_sendPlyMails(mailDict)
    end)
end

function MailMgr:_createSysMails(mailData)
    mailData.mailType = constant.MAIL_TYPE_SYS
    mailData.receivePid = 0
    local sysMailId = self:incSysMailId()
    mailData.id = sysMailId
    local mail = ggclass.Mail.new(mailData)
    mail:deserialize(mailData)
    mail:newSysMail()
    mail.dirty = true
    
    skynet.fork(function()
        mail:save_to_db()
    end)
end

function MailMgr:_addMails(sendId, sendName, toPidList, mailData)
    local data = {
        sendPid = sendId,
        sendName = sendName,
        title = mailData.title,
        content = mailData.content,
        sendTime = mailData.sendTime or gg.time.time(),
        attachment = mailData.attachment,
        duration = mailData.duration or constant.MAIL_DURATION,
        filter = mailData.filter,
        logType = mailData.logType,
    }
    if #toPidList == 0 then
        self:_createSysMails(data)
    else
        self:_createPlyMails(data, toPidList)
    end
    gg.internal:send(".gamelog", "api", "addGmSendMailLog", sendId, sendName, toPidList, data)
    return true
end

function MailMgr:gmSendMail(sendId, sendName, toPidList, mailData)
    return self:_addMails(sendId, sendName, toPidList, mailData)
end

function MailMgr:gmGetMails(sendId, sendName, isDetail)
    local condition = {
    }
    if sendId ~= 0 then
        condition.sendPid = sendId
    end
    if sendName and sendName ~= "" then
        condition.sendName = sendName
    end
    local mailList = {}
    local plyMailDict = self:_findMailsFromDB("plymail", condition)
    local sysMailDict = self:_findMailsFromDB("sysmail", condition)
    for id, mail in pairs(plyMailDict) do
        if not isDetail then
            mail.content = nil
            mail.attachment = nil
        end
        table.insert(mailList,mail)
    end
    for id, mail in pairs(sysMailDict) do
        if not isDetail then
            mail.content = nil
            mail.attachment = nil
        end
        table.insert(mailList,mail)
    end
    return mailList
end

function MailMgr:_getMailsFromDB(tblName, condition, isDetail, pageNo, pageSize, beginDate, endDate)
    local rows = {}
    local tblRows = gg.mongoProxy[tblName]:findCount(condition)
    local tblPages = math.ceil(tblRows / pageSize)
    local docs = gg.mongoProxy[tblName]:findSortSkipLimit(condition, {{ id = -1 }, { _id = -1 }}, pageSize*(pageNo - 1), pageSize)
    for k, doc in pairs(docs) do
        local info = {
            mailType = doc.mailType,
            id = doc.id,
            sendPid = doc.sendPid,
            sendName = doc.sendName,
            sendTime = doc.sendTime,
            title = doc.title,
            -- content = doc.content,
            -- attachment = doc.attachment,
            receivePid = doc.receivePid,
            logType = doc.logType,
            reason = gamelog[doc.logType] or "",
            duration = doc.duration,
            filter = doc.filter,
            filterDesc = constant.MAIL_GET_FILTER_DESC[doc.filter] or "",
        }
        if isDetail then
            info.content = doc.content
            info.attachment = doc.attachment
        end
        local sendDate = gg.UnixStampToDateTime(info.sendTime) -- "yy-mm-dd hh:mm:ss"
        local year,mon,day = string.match(sendDate,"^(%d+)[/-](%d+)[/-](%d+)%s+(%d+):(%d+):(%d+)$")
        local sendDate = tonumber(year..mon..day)
        if beginDate <= sendDate and endDate >= sendDate then
            table.insert(rows, info)
        end
    end
    return {
        tblRows = tblRows,
        tblPages = tblPages,
        rows = rows,
    }
end

function MailMgr:gmGetMailsByPage(sendId, sendName, isDetail, pageNo, pageSize, beginDate, endDate)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = 0
    result.totalPage = 0
    result.rows = {}
    local condition = {
    }
    if sendId ~= 0 then
        condition.sendPid = sendId
    end
    if sendName and sendName ~= "" then
        condition.sendName = sendName
    end
    local sysMails = self:_getMailsFromDB("sysmail", condition, isDetail, pageNo, pageSize, beginDate, endDate)
    local plyMails = self:_getMailsFromDB("plymail", condition, isDetail, pageNo, pageSize, beginDate, endDate)
    result.totalRows = sysMails.tblRows + plyMails.tblRows
    result.totalPage = math.ceil(result.totalRows / pageSize)
    for i, v in ipairs(sysMails.rows) do
        table.insert(result.rows, v)
    end
    for i, v in ipairs(plyMails.rows) do
        table.insert(result.rows, v)
    end
    return result
end

function MailMgr:gmDelMail(id)
    local ret = false
    local db = gg.mongoProxy
    local data = db.sysmail:findOne({id = id})
    if data then
        ret = db.sysmail:safe_delete({id = id},true)
    else
        data = db.plymail:findOne({id = id})
        if data then
            ret = db.plymail:safe_delete({id = id},true)
        end
    end
    return ret
end

function MailMgr:getPlayerMails(pid, lastSysMailId, lastPlyMailId)
    local mailDict = {}
    local plyMailDict = self:_getPlyMails(pid, lastPlyMailId)
    local sysMailDict = self:_getSysMails(pid, lastSysMailId)
    for id, mail in pairs(plyMailDict) do
        mailDict[id] = mail
    end
    for id, mail in pairs(sysMailDict) do
        mailDict[id] = mail
    end

    gg.playerProxy:sendOnline(pid, "addPlayerMails", mailDict)
    return true, mailDict
end

function MailMgr:delPlayerMails(pid, delPlyMailIds)
    local db = gg.mongoProxy
    for i, id in ipairs(delPlyMailIds) do
        db.plymail:safe_delete({id = id, receivePid = pid},true)
    end
end

function MailMgr:checkAndGetPlayerMails(pid, lastSysMailId, lastPlyMailId)
    local mailDict = {}
    --Note: only get player mails,lastPlyMailId==0 means get all
    local plyMailDict = self:_getPlyMails(pid, 0)
    for id, mail in pairs(plyMailDict) do
        mailDict[id] = mail
    end

    gg.playerProxy:sendOnline(pid, "addPlayerMails", mailDict)
    return true, mailDict
end
-----------------------------------------------
--""
function MailMgr:onSecond()
end

function MailMgr:onTenMinuteUpdate()
    self:cleanUpMailsFromCache()
end

function MailMgr:onHourUpdate()
    self:cleanUpMailsFromDB()
end

function MailMgr:playerLogin(pid)
    
end

function MailMgr:playerLogout(pid)
    
end

return MailMgr