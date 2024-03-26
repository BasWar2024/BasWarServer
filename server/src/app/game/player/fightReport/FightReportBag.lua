local FightReportBag = class("FightReportBag")

function FightReportBag:ctor(param)
    self.player = param.player
    self.pveReportIdList = {}
    self.pveReports = {}
    self.pvpReportIdList = {}
    self.pvpReports = {}
    self.starmapCampaignIdList = {}
    self.starmapCampaignIdDict = {}
end

function FightReportBag:serialize()
    local data = {}
    data.pveReportIdList = self.pveReportIdList
    data.pveReports = {}
    for k, v in pairs(self.pveReports) do
        table.insert(data.pveReports, v)
    end
    data.pvpReportIdList = self.pvpReportIdList
    data.pvpReports = {}
    for k, v in pairs(self.pvpReports) do
        table.insert(data.pvpReports, v)
    end
    data.starmapCampaignIdList = self.starmapCampaignIdList
    data.starmapCampaignIdDict = {}
    for k, v in pairs(self.starmapCampaignIdDict) do
        table.insert(data.starmapCampaignIdDict, v)
    end
    return data
end

function FightReportBag:deserialize(data)
    self.pveReportIdList = data.pveReportIdList or {}
    self.pveReports = {}
    if data.pveReports then
        for k, v in pairs(data.pveReports) do
            self.pveReports[v.fightId] = v
        end
    end
    self.pvpReportIdList = data.pvpReportIdList or {}
    self.pvpReports = {}
    if data.pvpReports then
        for k, v in pairs(data.pvpReports) do
            self.pvpReports[v.fightId] = v
        end
    end
    self.starmapCampaignIdList = data.starmapCampaignIdList or {}
    self.starmapCampaignIdDict = {}
    if data.starmapCampaignIdDict then
        for k, v in pairs(data.starmapCampaignIdDict) do
            self.starmapCampaignIdDict[v] = true
        end
    end
end

local BATTLETYPE_TO_LIST_KEY = {
    [constant.BATTLE_TYPE_MAIN_BASE] = "pvpReportIdList",
    [constant.BATTLE_TYPE_PVE] = "pveReportIdList",
}
local BATTLETYPE_TO_DICT_KEY = {
    [constant.BATTLE_TYPE_MAIN_BASE] = "pvpReports",
    [constant.BATTLE_TYPE_PVE] = "pveReports",
}
function FightReportBag:_doPackPvxReports(battleType)
    local reports = {}
    local reportIdList = self[BATTLETYPE_TO_LIST_KEY[battleType]]
    local pvxReports = self[BATTLETYPE_TO_DICT_KEY[battleType]]
    for i, id in ipairs(reportIdList) do
        table.insert(reports, pvxReports[id])
    end
    return reports
end

function FightReportBag:packPvpReports()
    return self:_doPackPvxReports(constant.BATTLE_TYPE_MAIN_BASE)
end

function FightReportBag:packPveReports()
    return self:_doPackPvxReports(constant.BATTLE_TYPE_PVE)
end

function FightReportBag:packStarmapCampaignReports(pageNo, pageSize)
    local list = {}
    local count = 0
    local totalRows = table.count(self.starmapCampaignIdList)
    for i = totalRows - pageSize*(pageNo - 1), totalRows - pageSize*pageNo + 1, -1 do
        count = count + 1
        table.insert(list, self.starmapCampaignIdList[i])
        if count >= pageSize then
            break
        end
    end
    local reports = self.player.starmapBag:getPersonalStarmapCampaignReports(list)
    return reports
end

function FightReportBag:packStarmapBattleReports(campaignId, pageNo, pageSize)
    local reports = self.player.starmapBag:getPersonalStarmapBattleReports(campaignId, pageNo, pageSize)
    return reports
end

function FightReportBag:_doAddFightPvxReport(battleType, report)
    if not report then
        return
    end
    for k, v in pairs(report.soliders or {}) do
        local buildId = v.id
        local build = self.player.buildBag:getBuild(buildId)
        if build and build.soliderCfgId then
            v.cfgId = build.soliderCfgId
        end
    end
    local reportIdList = self[BATTLETYPE_TO_LIST_KEY[battleType]]
    local pvxReports = self[BATTLETYPE_TO_DICT_KEY[battleType]]
    pvxReports[report.fightId] = report
    table.insert(reportIdList, report.fightId)
    local count = table.count(reportIdList)
    if count > constant.FIGHT_REPORT_MAX then
        local diff = count - constant.FIGHT_REPORT_MAX
        for i = 1, diff, 1 do
            local id = table.remove(reportIdList, 1)
            pvxReports[id] = nil
        end
    end
end

function FightReportBag:addFightPveReport(report)
    self:_doAddFightPvxReport(constant.BATTLE_TYPE_PVE, report)
    gg.client:send(self.player.linkobj, "S2C_Player_FightReportAdd", { report = report })
end

--""
function FightReportBag:addFightPvpReport(report)
    self:_doAddFightPvxReport(constant.BATTLE_TYPE_MAIN_BASE, report)
    gg.client:send(self.player.linkobj, "S2C_Player_FightReportAdd", { report = report })
end

--""
function FightReportBag:addStarmapReport(battleId, campaignId)
    -- if not battleId then
    --     return
    -- end
    if self.starmapCampaignIdDict[campaignId] then
        return
    end
    local count = table.count(self.starmapCampaignIdList)
    if count > constant.FIGHT_REPORT_MAX then
        local diff = count - constant.FIGHT_REPORT_MAX
        for i = 1, diff, 1 do
            local id = table.remove(self.starmapCampaignIdList, 1)
            self.starmapCampaignIdDict[id] = nil
        end
    end
    table.insert(self.starmapCampaignIdList, campaignId)
    self.starmapCampaignIdDict[campaignId] = true
    local reports = self.player.starmapBag:getPersonalStarmapCampaignReports({campaignId})
    if table.count(reports) > 0 then
        gg.client:send(self.player.linkobj, "S2C_Player_StarmapCampaignReportUpdate", { op_type = constant.OP_ADD, report = reports[1] })
    end
    return true
end

function FightReportBag:getReportByReportId(id)
    local report = self.pvpReports[id]
    if report then
        return report
    end
    report = self.pveReports[id]
    return report
end

function FightReportBag:_doUpdatePvxFightReport(battleType, battleId, battleResult, resInfo)
    local reportIdList = self[BATTLETYPE_TO_LIST_KEY[battleType]]
    local pvxReports = self[BATTLETYPE_TO_DICT_KEY[battleType]]
    local report = pvxReports[battleId]
    if not report then
        return
    end
    if battleResult.signinPosId then
        report.signinPosId = battleResult.signinPosId
    end
    if battleResult.bVersion then
        report.bVersion = battleResult.bVersion
    end
    if report.isAttacker then
        report.result = battleResult.ret
    else
        if battleResult.ret == constant.BATTLE_RESULT_WIN then
            report.result = constant.BATTLE_RESULT_LOSE
        elseif battleResult.ret == constant.BATTLE_RESULT_LOSE then
            report.result = constant.BATTLE_RESULT_WIN
        end
    end
    if battleResult.soliders and next(battleResult.soliders) then
        for k, v in pairs(battleResult.soliders) do
            local id = v.id
            local dieCount = v.count
            for k, v in pairs(report.soliders) do
                if v.id == id then
                    v.dieCount = dieCount
                    break
                end
            end
        end
    end
    if resInfo then
        if report.isAttacker then
            report.atkBadge = resInfo.atkBadge or 0
        else
            report.defenBadge = resInfo.defenBadge or 0
        end
        local RES_KEYS_CFGID = {
            ["starCoin"] = constant.RES_STARCOIN,
            ["ice"] = constant.RES_ICE,
            ["titanium"] = constant.RES_TITANIUM,
            ["gas"] = constant.RES_GAS,
        }
        -- ""
        if not report.isAttacker then
            RES_KEYS_CFGID["tesseract"] = constant.RES_TESSERACT
        end
        -- ""
        if report.isAttacker then
            RES_KEYS_CFGID["carboxyl"] = constant.RES_CARBOXYL
        end
        for k, v in pairs(RES_KEYS_CFGID) do
            if resInfo[k] and resInfo[k] > 0 then
                table.insert(report.currencies, { resCfgId = v, count = resInfo[k]} )
            end
        end
    end
    return report
end

--""
function FightReportBag:updatePvpFightReport(battleId, battleResult, resInfo)
    return self:_doUpdatePvxFightReport(constant.BATTLE_TYPE_MAIN_BASE, battleId, battleResult, resInfo)
end

function FightReportBag:updatePveFightReport(battleId, battleResult, resInfo)
    return self:_doUpdatePvxFightReport(constant.BATTLE_TYPE_PVE, battleId, battleResult, resInfo)
end

function FightReportBag:updateStarmapReport(id, info)
    -- local report = self.starmapCampaignIdDict[id]
    -- if not report then
    --     return
    -- end
    -- gg.client:send(self.player.linkobj, "S2C_Player_StarmapCampaignReportUpdate", { op_type = constant.OP_MODIFY, report = report })
end

--""
function FightReportBag:queryFightReports(battleType)
    local reports = {}
    if battleType == constant.BATTLE_TYPE_MAIN_BASE then
        reports = self:packPvpReports()
    elseif battleType == constant.BATTLE_TYPE_PVE then
        reports = self:packPveReports()
    end
    gg.client:send(self.player.linkobj, "S2C_Player_FightReports", { reports = reports, battleType = battleType })
end

--""
function FightReportBag:queryStarmapCampaignReports(pageNo, pageSize)
    pageSize = math.max(pageSize, 5)
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapCampaignReports", { reports = self:packStarmapCampaignReports(pageNo, pageSize) })
end

--""
function FightReportBag:queryStarmapBattleReports(campaignId, pageNo, pageSize)
    pageSize = math.max(pageSize, 5)
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapBattleReports", { reports = self:packStarmapBattleReports(campaignId, pageNo, pageSize) })
end


function FightReportBag:onlogin()
    
end

function FightReportBag:onlogout()

end

return FightReportBag