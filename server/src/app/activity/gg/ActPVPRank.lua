local ActPVPRank = class("ActPVPRank", ggclass.ActivityOnce)

function ActPVPRank:ctor(cfgId)
    ActPVPRank.super.ctor(self, cfgId)
end

function ActPVPRank:onStartTimeout()
end

function ActPVPRank:onEndTimeout()
    if self.isReward then
        return
    end
    self:pvpRankReward()
    self.isReward = true
    return true
end

function ActPVPRank:pvpRankReward()
    local pidDict = {}
    local cfg = self:getActCfg()
    local from = 0
    local to = cfg.rankTopN - 1
    local settlementList = gg.shareProxy:call("getPvpMatchRankList", from, to)
    for rank, data in ipairs(settlementList) do
        if data.score > 0 then
            pidDict[data.pid] = {
                rank = rank,
                score = data.score,
            }
        end
    end
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_ACTPVPRANK]
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle
    for pid, data in pairs(pidDict) do
        skynet.fork(function(playerId, rank, score)
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
                    logType = gamelog.ACT_PVP_RANK
                }
                gg.mailProxy:send("gmSendMail", sendId, sendName, { playerId }, mailData)
            end
        end, pid, data.rank, data.score)
    end
    return true
end

return ActPVPRank
