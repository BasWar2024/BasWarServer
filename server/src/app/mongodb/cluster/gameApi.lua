-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.setBattleInfo(battleId, battleInfo)
    local db = gg.getdb("game")
    db.battle:update({ battleId = battleId }, battleInfo, true, false)
end

function api.getBattleInfo(battleId)
    local db = gg.getdb("game")
    return db.battle:findOne({ battleId = battleId })
end

function api.delBattleInfo(battleId)
    local db = gg.getdb("game")
    return db.battle:safe_delete({ battleId = battleId }, true)
end

function api.delMultipleBattleInfo(query)
    local db = gg.getdb("game")
    return db.battle:safe_delete(query, false)
end

function api.setCampaignInfo(campaignId, campaignInfo)
    local db = gg.getdb("game")
    db.campaign:update({ campaignId = campaignId }, campaignInfo, true, false)
end

function api.getCampaignInfo(campaignId)
    local db = gg.getdb("game")
    return db.campaign:findOne({ campaignId = campaignId })
end

function api.getCampaignReports(campaignId)
    local db = gg.getdb("game")
    return db.campaignreport:findOne({ campaignId = campaignId })
end

--""
function api.getOnGoingCampaigns()
    local docs = {}
    local db = gg.getdb("game")
    local cursor = db.campaign:find({ isEnd = false })
    while cursor:hasNext() do
        local doc = cursor:next()
        doc._id = nil
        table.insert(docs, doc)
    end
    return docs
end

function api.getUnionStarmapCampaignReportsCount(gridCfgId)
    local diff = gg.time.time() - constant.BATTLE_DATA_HOLE_TIME
    local db = gg.getdb("game")
    local cnt = db.campaign:findCount({["gridCfgId"] = gridCfgId, startTime = {["$gte"] = diff}})
    return cnt
end

function api.getUnionStarmapCampaignReports(unionId, campaignIdList)
    local docs = {}
    local db = gg.getdb("game")
    local cursor = db.campaign:find({["campaignId"] = {["$in"] = campaignIdList}})
    while cursor:hasNext() do
        local doc = cursor:next()
        doc._id = nil
        local gridCfg = gg.getExcelCfg("starmapConfig")[doc.gridCfgId]
        if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION then
            -- local plyCombat = {}
            -- for kk, vv in pairs(doc.attackContriDegree) do
            --     table.insert(plyCombat, {playerId = tonumber(kk), val = math.floor(vv * 1000)})
            -- end
            table.insert(docs, {
                gridCfgId = doc.gridCfgId,
                campaignId = doc.campaignId,
                startTime = doc.startTime,
                defender = doc.defender,
                -- plyCombat = plyCombat,
                maxLoseHp = doc.maxLoseHp,
                maxHp = doc.maxHp,
                isEnd = doc.isEnd,
            })
        end
    end
    return docs
end

function api.getUnionStarmapBattleReports(unionId, campaignId, pageNo, pageSize)
    local docs = {}
    local db = gg.getdb("game")
    local doc = db.campaign:findOne({ campaignId = campaignId })
    if doc then
        doc._id = nil
        local gridCfg = gg.getExcelCfg("starmapConfig")[doc.gridCfgId]
        if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION then
            local count = 0
            local totalRows = table.count(doc.reports)
            for i = totalRows - pageSize*(pageNo - 1), totalRows - pageSize*pageNo + 1, -1 do
                count = count + 1
                if doc.reports[i] then
                    table.insert(docs, doc.reports[i])
                end
                if count >= pageSize then
                    break
                end
            end
        end
    end
    return docs
end

function api.getPersonalStarmapCampaignReports(pid, campaignIdList)
    local docs = {}
    local db = gg.getdb("game")
    local cursor = db.campaign:find({["campaignId"] = {["$in"] = campaignIdList}})
    while cursor:hasNext() do
        local doc = cursor:next()
        doc._id = nil
        local gridCfg = gg.getExcelCfg("starmapConfig")[doc.gridCfgId]
        if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF then
            -- local plyCombat = {}
            -- for kk, vv in pairs(doc.attackContriDegree) do
            --     table.insert(plyCombat, {playerId = tonumber(kk), val = math.floor(vv * 1000)})
            -- end
            table.insert(docs, {
                gridCfgId = doc.gridCfgId,
                campaignId = doc.campaignId,
                startTime = doc.startTime,
                defender = doc.defender,
                -- plyCombat = plyCombat,
                maxLoseHp = doc.maxLoseHp,
                maxHp = doc.maxHp,
                isEnd = doc.isEnd,
            })
        end
    end
    return docs
end

function api.getPersonalStarmapBattleReports(campaignId, pageNo, pageSize)
    local docs = {}
    local db = gg.getdb("game")
    local doc = db.campaign:findOne({ campaignId = campaignId })
    if doc then
        doc._id = nil
        local gridCfg = gg.getExcelCfg("starmapConfig")[doc.gridCfgId]
        if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF then
            local count = 0
            local totalRows = table.count(doc.reports)
            for i = totalRows - pageSize*(pageNo - 1), totalRows - pageSize*pageNo + 1, -1 do
                count = count + 1
                if doc.reports[i] then
                    table.insert(docs, doc.reports[i])
                end
                if count >= pageSize then
                    break
                end
            end
        end
    end
    return docs
end

function api.getStarmapCampaignPlyStatistics(unionId, campaignId)
    local docs = {}
    local db = gg.getdb("game")
    local doc = db.campaign:findOne({ campaignId = campaignId })
    if doc then
        doc._id = nil
        local gridCfg = gg.getExcelCfg("starmapConfig")[doc.gridCfgId]
        if gridCfg and gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION then
            for k, v in pairs(doc.attackerStatistics or {}) do
                table.insert(docs, {
                    playerId = k,
                    playerName = v.playerName,
                    atkCnt = v.atkCnt,
                    atkHp = v.atkHp,
                })
            end
        end
    end
    return docs
end

function api.updateroleid(account, roleid)
    local db = gg.getdb("common")
    db.account:update({ account = account },{["$set"] = {roleid=roleid}},false,false)
end

return api