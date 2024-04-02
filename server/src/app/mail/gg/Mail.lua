local Mail = class("Mail")

function Mail:ctor(param)
    self.dirty = false
    self.savetick = 300                                                            --""
    self.savename = "plymail"                                                      --""
    self.id = param.id                                                             --id("")
    self.mailType = param.mailType                                                 --""(0"",1"")
    self.duration = param.duration or constant.MAIL_DURATION                       --""("")
    self.filter = param.filter or constant.MAIL_GET_FILTER_ALL                     --""
    self.sendPid = param.sendPid                                                   --""id
    self.sendName = param.sendName                                                 --""
    self.title = param.title                                                       --""
    self.content = param.content                                                   --""
    self.sendTime = param.sendTime                                                 --""
    self.attachment = nil                                                          --""
    self.receivePid = param.receivePid                                             --""id
    self.delete = nil                                                              --""
    self.logType = param.logType or gamelog.MAIL_FROM_GMASTER                      --logtype
end

function Mail:serialize()
    local data = {}
    data.id = self.id
    data.mailType = self.mailType
    data.duration = self.duration
    data.filter = self.filter
    data.sendPid = self.sendPid
    data.sendName = self.sendName
    data.title = self.title
    data.content = self.content
    data.sendTime = self.sendTime
    if self.attachment then
        data.attachment = {}
        for _, value in ipairs(self.attachment) do
            local attach = {}
            for k, v in pairs(value) do
                attach[k] = v
            end
            table.insert(data.attachment, attach)
        end
    end
    data.receivePid = self.receivePid
    data.delete = self.delete
    data.logType = self.logType
    return data
end

function Mail:deserialize(data)
    self.mailType = data.mailType
    if self.mailType == constant.MAIL_TYPE_SYS then
        self.savename = "sysmail"
    end
    self.duration = data.duration
    self.filter = data.filter
    self.sendPid = data.sendPid
    self.sendName = data.sendName
    self.title = data.title
    self.content = data.content
    self.sendTime = data.sendTime
    if data.attachment then
        self.attachment = {}
        for _, value in ipairs(data.attachment) do
            local attach = {}
            for k, v in pairs(value) do
                attach[k] = v
            end
            table.insert(self.attachment, attach)
        end
    end
    self.receivePid = data.receivePid
    self.delete = data.delete
    self.logType = data.logType
end

function Mail:pack()
    local data = {}
    data.id = self.id
    data.mailType = self.mailType
    data.duration = self.duration
    data.sendPid = self.sendPid
    data.sendName = self.sendName
    data.title = self.title
    data.content = self.content
    data.sendTime = self.sendTime
    if self.attachment then
        data.attachment = {}
        for _, value in ipairs(self.attachment) do
            local attach = {}
            for k, v in pairs(value) do
                attach[k] = v
            end
            table.insert(data.attachment, attach)
        end
    end
    data.receivePid = self.receivePid
    data.delete = self.delete
    return data
end

function Mail:save_to_db()
    if not self.dirty then
        return
    end
    local db = gg.mongoProxy
    local data = self:serialize()
    if self.mailType == constant.MAIL_TYPE_SYS then
        db.sysmail:update({id = data.id},data,true,false)
    else
        db.plymail:update({id = data.id},data,true,false)
    end
    self.dirty = false
end

function Mail:load_from_db()
    local db = gg.mongoProxy
    local data = db.sysmail:findOne({id = self.id})
    if not data then
        data = db.plymail:findOne({id = self.id})
    end
    self:deserialize(data)
end

function Mail:shutdown()
    self.dirty = true
end
----------------------------------------------------
function Mail:newSysMail()
    gg.centerProxy:send("broadCast2Game", "broadcastSysMail")
end

-- ""，""
function Mail:newPlyMail()
    gg.playerProxy:sendOnline(self.receivePid, "newMailsNotice")
end
----------------------------------------------------
function Mail:onSecond()
end

return Mail