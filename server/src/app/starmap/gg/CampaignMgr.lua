local CampaignMgr = class("CampaignMgr")

function CampaignMgr:ctor()
    self.campaigns = {} --campaignId: campaingn
end

function CampaignMgr:init()
    local docs = gg.mongoProxy:call("getOnGoingCampaigns")
    for k, v in pairs(docs) do
        local campaign = ggclass.Campaign.new()
        campaign:deserialize(v)
        self.campaigns[v.campaignId] = campaign
    end
end

function CampaignMgr:getCampaign(campaignId)
    local campaign = self.campaigns[campaignId]
    if campaign then
        return campaign
    end
    local campaignInfo = gg.mongoProxy:call("getCampaignInfo", campaignId)
    if not campaignInfo then
        return
    end
    campaign = ggclass.Campaign.new()
    campaign:deserialize(campaignInfo)
    self.campaigns[campaignId] = campaign
    return campaign
end

--""
function CampaignMgr:getGridOnGoingCampaign(gridCfgId)
    for k, v in pairs(self.campaigns) do
        if v.gridCfgId == gridCfgId and v.isEnd == false then
            return v
        end
    end
end

--""
function CampaignMgr:createCampaign(gridCfgId, defender, builds)
    local existCampaign = self:getGridOnGoingCampaign(gridCfgId)
    if existCampaign then
        return
    end
    local campaign = ggclass.Campaign.new()
    campaign:init(gridCfgId, defender, builds)
    self.campaigns[campaign.campaignId] = campaign
    return campaign
end

function CampaignMgr:getUnionStarmapCampaignReports(unionId, campaignIdList)
    local offlineIds = {}
    local onlineReports = {}
    for i, v in ipairs(campaignIdList) do
        local campaign = self.campaigns[v]
        if campaign then
            local gridCfg = gg.getExcelCfg("starmapConfig")[campaign.gridCfgId]
            if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION then
                -- local plyCombat = {}
                -- for kk, vv in pairs(campaign.attackContriDegree) do
                --     table.insert(plyCombat, {playerId = tonumber(kk), val = math.floor(vv * 1000)})
                -- end
                table.insert(onlineReports, {
                    gridCfgId = campaign.gridCfgId,
                    campaignId = campaign.campaignId,
                    startTime = campaign.startTime,
                    defender = campaign.defender,
                    -- plyCombat = plyCombat,
                    maxLoseHp = campaign.maxLoseHp,
                    maxHp = campaign.maxHp,
                    isEnd = campaign.isEnd,
                })
            end
        else
            table.insert(offlineIds, v)
        end
    end
    local offlineReports = {}
    if table.count(offlineIds) > 0 then
        offlineReports = gg.mongoProxy:call("getUnionStarmapCampaignReports", unionId, offlineIds)
    end
    for i, v in ipairs(onlineReports) do
        table.insert(offlineReports, v)
    end
    return offlineReports
end

function CampaignMgr:getUnionStarmapBattleReports(unionId, campaignId, pageNo, pageSize)
    local onlineReports = {}
    local campaign = self.campaigns[campaignId]
    if campaign then
        local gridCfg = gg.getExcelCfg("starmapConfig")[campaign.gridCfgId]
        if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION then
            local count = 0
            local totalRows = table.count(campaign.reports)
            for i = totalRows - pageSize*(pageNo - 1), totalRows - pageSize*pageNo + 1, -1 do
                count = count + 1
                if campaign.reports[i] then
                    table.insert(onlineReports, campaign.reports[i])
                end
                if count >= pageSize then
                    break
                end
            end
        end
        return onlineReports
    else
        return gg.mongoProxy:call("getUnionStarmapBattleReports", unionId, campaignId, pageNo, pageSize)
    end
end

function CampaignMgr:getPersonalStarmapCampaignReports(pid, campaignIdList)
    local offlineIds = {}
    local onlineReports = {}
    for i, v in ipairs(campaignIdList) do
        local campaign = self.campaigns[v]
        if campaign then
            local gridCfg = gg.getExcelCfg("starmapConfig")[campaign.gridCfgId]
            if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF then
                -- local plyCombat = {}
                -- for kk, vv in pairs(campaign.attackContriDegree) do
                --     table.insert(plyCombat, {playerId = tonumber(kk), val = math.floor(vv * 1000)})
                -- end
                table.insert(onlineReports, {
                    gridCfgId = campaign.gridCfgId,
                    campaignId = campaign.campaignId,
                    startTime = campaign.startTime,
                    defender = campaign.defender,
                    -- plyCombat = plyCombat,
                    maxLoseHp = campaign.maxLoseHp,
                    maxHp = campaign.maxHp,
                    isEnd = campaign.isEnd,
                })
            end
        else
            table.insert(offlineIds, v)
        end
    end
    local offlineReports = {}
    if table.count(offlineIds) > 0 then
        offlineReports = gg.mongoProxy:call("getPersonalStarmapCampaignReports", pid, offlineIds)
    end
    for i, v in ipairs(onlineReports) do
        table.insert(offlineReports, v)
    end
    return offlineReports
end

function CampaignMgr:getPersonalStarmapBattleReports(campaignId, pageNo, pageSize)
    local onlineReports = {}
    local campaign = self.campaigns[campaignId]
    if campaign then
        local gridCfg = gg.getExcelCfg("starmapConfig")[campaign.gridCfgId]
        if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF then
            local count = 0
            local totalRows = table.count(campaign.reports)
            for i = totalRows - pageSize*(pageNo - 1), totalRows - pageSize*pageNo + 1, -1 do
                count = count + 1
                if campaign.reports[i] then
                    table.insert(onlineReports, campaign.reports[i])
                end
                if count >= pageSize then
                    break
                end
            end
        end
        return onlineReports
    else
        return gg.mongoProxy:call("getPersonalStarmapBattleReports", campaignId, pageNo, pageSize)
    end
end

function CampaignMgr:getStarmapCampaignPlyStatistics(unionId, campaignId)
    local onlineReports = {}
    local campaign = self.campaigns[campaignId]
    if campaign then
        local gridCfg = gg.getExcelCfg("starmapConfig")[campaign.gridCfgId]
        if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION then
            for k, v in pairs(campaign.attackerStatistics) do
                table.insert(onlineReports, {
                    playerId = k,
                    playerName = v.playerName,
                    atkCnt = v.atkCnt,
                    atkHp = v.atkHp,
                })
            end
        end
        return onlineReports
    else
        return gg.mongoProxy:call("getStarmapCampaignPlyStatistics", unionId, campaignId)
    end
end

function CampaignMgr:onSecond()
    for _, v in pairs(self.campaigns) do
        if v.onSecond then
            v:onSecond()
        end
    end
end

function CampaignMgr:onFiveMinuteUpdate()
    local clearCampaignIds = {}
    for k, v in pairs(self.campaigns) do
        if v.onFiveMinuteUpdate then
            v:onFiveMinuteUpdate()
        end
        if skynet.timestamp() > v.campaignEndTick + 600 * 1000 then
            table.insert(clearCampaignIds, v.campaignId)
        end
    end
    for _, campaignId in pairs(clearCampaignIds) do
        if self.campaigns[campaignId] then
            self.campaigns[campaignId] = nil
        end
    end
end

function CampaignMgr:shutdown()
    for k, v in pairs(self.campaigns) do
        if v.shutdown then
            v:shutdown()
        end
    end
end


return CampaignMgr