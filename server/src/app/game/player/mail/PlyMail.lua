local PlyMail = class("PlyMail")

function PlyMail:ctor()
    self.dirty = false
    self.savetick = 3600
    self.id = 0                                         --id
    self.mailType = 0                                   --""
    self.duration = 0                                   --""("")
    self.sendPid = 0                                    --""id
    self.sendName = nil                                 --""
    self.title = nil                                    --""
    self.content = nil                                  --""
    self.sendTime = nil                                 --""
    self.attachment = nil                               --""
    self.read = false                                   --""
    self.get = false                                    --""
    self.filter = constant.MAIL_GET_FILTER_ALL
    self.logType = gamelog.MAIL_FROM_GMASTER
end

function PlyMail:serialize()
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
    data.read = self.read
    data.get = self.get
    data.logType = self.logType
    return data
end

function PlyMail:deserialize(data)
    self.id = data.id
    self.mailType = data.mailType
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
    self.read = data.read or false
    self.get = data.get or false
    self.logType = data.logType
end

function PlyMail:packBrief()
    local data = {}
    data.id = self.id
    data.sendPid = self.sendPid
    data.sendName = self.sendName
    data.title = self.title
    data.sendTime = self.sendTime
    data.read = self.read
    if self.attachment and next(self.attachment) then
        data.canGet = not self.get
    end
    return data
end

function PlyMail:pack()
    local data = {}
    data.id = self.id
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
    data.read = self.read
    data.get = self.get
    return data
end

return PlyMail