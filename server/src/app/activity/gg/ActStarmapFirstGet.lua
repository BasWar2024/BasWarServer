local ActStarmapFirstGet = class("ActStarmapFirstGet", ggclass.ActivityOnce)

function ActStarmapFirstGet:ctor(cfgId)
    ActStarmapFirstGet.super.ctor(self, cfgId)
    self.pidRankList = {}
    self.pidDict = {}
end

function ActStarmapFirstGet:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.pidRankList = self.pidRankList
    return data
end

function ActStarmapFirstGet:deserialize(data)
    if not data then
        return
    end
    self.cfgId = data.cfgId
    self.pidRankList = data.pidRankList or {}
    for i, v in ipairs(self.pidRankList) do
        self.pidDict[v] = true
    end
end

function ActStarmapFirstGet:onStartTimeout()
end

function ActStarmapFirstGet:onEndTimeout()
    return true
end

function ActStarmapFirstGet:updateActivityData(data)
    if self.pidDict[data.pid] then
        return
    end
    local cfg = self:getActCfg()
    local topN = cfg.rankTopN
    if #self.pidRankList >= topN then
        return
    end
    table.insert(self.pidRankList, data.pid)
    self.pidDict[data.pid] = true
    local rank = #self.pidRankList
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_ACTSTARMAPFIRSTGET]
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle
    local reward = self:getRankReward(rank)
    if reward then
        local mailItems = {}
        self:fomatMailItems(reward.resReward, constant.MAIL_ATTACH_RES, mailItems)
        self:fomatMailItems(reward.itemReward, constant.MAIL_ATTACH_ITEM, mailItems)
        -- self:fomatMailItems(reward.resReward2, constant.MAIL_ATTACH_RES, mailItems)
        -- self:fomatMailItems(reward.itemReward2, constant.MAIL_ATTACH_ITEM, mailItems)
        local mailData = {
            title = title,
            content = string.format(mailCfg.mailContent, rank),
            attachment = mailItems,
            logType = gamelog.ACT_STARMAP_FIRST_GET
        }
        gg.mailProxy:send("gmSendMail", sendId, sendName, { data.pid }, mailData)
    end
    self.dirty = true
end

function ActStarmapFirstGet:getActRankList(pid)
    local ret = {}
    local list = {}
    local selfRank = {}
    for i, v in ipairs(self.pidRankList) do
        local info = gg.shareProxy:call("getPlayerAllBaseInfo", v)
        table.insert(list, {
            index = i,
            pid = v,
            name = info.name,
            headIcon = info.headIcon,
        })
        if v == pid then
            selfRank = {
                index = i,
                pid = v,
                name = info.name,
                headIcon = info.headIcon,
            }
        end
    end
    ret = {list = list, selfRank = selfRank}
    return ret
end

return ActStarmapFirstGet
