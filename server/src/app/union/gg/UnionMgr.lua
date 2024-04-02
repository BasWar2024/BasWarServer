local UnionMgr = class("UnionMgr")

function UnionMgr:ctor()
    self.unions = {} -- unionId to unionInfo
    self.pidToUnionId = {} -- pid to UnionId
    self.unionNameToUnionId = {} -- unionName to UnionId
    self:initUnions()
end

function UnionMgr:initUnions()
    local docs = gg.mongoProxy.union:find({})
    for _, data in pairs(docs) do
        local union = ggclass.Union.new()
        union:deserialize(data)
        union:doRefresh()
        self.unions[data.unionId] = union
        self:setUnionNameToUnionId(union.unionName, union.unionId)
        for _, member in pairs(union.members) do
            self:setPidToUnionId(member.playerId, union.unionId)
        end
        gg.savemgr:autosave(union)
    end
end

function UnionMgr:setPidToUnionId(pid, unionId)
    self.pidToUnionId[pid] = unionId
end

function UnionMgr:setUnionNameToUnionId(unionName, unionId)
    self.unionNameToUnionId[unionName] = unionId
end

function UnionMgr:getUnionByUnionName(unionName)
    local unionId = self.unionNameToUnionId[unionName]
    if not unionId then
        return nil
    end
    local union = self.unions[unionId]
    if not union then
        return nil
    end
    return union
end

function UnionMgr:getUnionById(unionId)
    local union = self.unions[unionId]
    return union
end

function UnionMgr:getUnionByPlayerId(playerId)
    local unionId = self.pidToUnionId[playerId]
    if not unionId then
        return nil
    end
    local union = self.unions[unionId]
    if not union then
        return nil
    end
    return union
end

function UnionMgr:getUnionMember(unionId, playerId)
    local union = self.unions[unionId]
    if not union then
        return nil
    end
    return union:getMember(playerId)
end

function UnionMgr:getUnionShareInfo(unionId, pid, cfgId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:getUnionShareInfo(pid)
end

function UnionMgr:getUnionBeginGridId(unionId, pid)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union.beginGridId
end

function UnionMgr:setUnionBeginGrid(unionId, beginGridId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    if beginGridId == 0 then
        union.beginGridId = 0
        return true
    end
    assert(union.beginGridId == 0, "beginGrid must be 0")
    union.beginGridId = beginGridId
    return true
end

function UnionMgr:getUnionChainId(unionId, pid)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union.unionChain
end

function UnionMgr:shareGridRes2Union(unionId, pid, cfgId, carboxyl)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:shareGridRes2Union(pid, carboxyl)
end

function UnionMgr:getJoinableUnionList()
    local list = {}
    local i = 0
    for k, v in pairs(self.unions) do
        if table.count(v.members) < v:getMemberMax() and v.enterType ~= constant.UNION_JOIN_TYPE_NOT_ALLOW then
            table.insert(list, v:packUnionJoin())
            i = i + 1
            if i >= constant.UNION_JOINABLE_LIST_MAX_COUNT then
                break
            end
        end
    end
    return list
end

function UnionMgr:personalCampaignReward(pid, unionId, gridCfgId, gridCarboxyl, resDict)
    local union = self.unions[unionId]
    if union then
        union:personalCampaignReward(pid, gridCfgId, gridCarboxyl, resDict)
    end
end

function UnionMgr:changeGridOwner(oldPid, oldUnionId, newPid, newUnionId, gridCfgId, gridCarboxyl, resDict, attackContriDict)
    local oldUnion = self.unions[oldUnionId]
    if oldUnion then
        oldUnion:unsetGridOwner(oldPid, gridCfgId)
    end
    local newUnion = self.unions[newUnionId]
    newUnion:setGridOwner(newPid, gridCfgId)
    newUnion:campaignReward(newPid, gridCfgId, gridCarboxyl, resDict)
    newUnion:attackGridContri(attackContriDict)
end

function UnionMgr:unsetGridOwner(oldPid, oldUnionId, gridCfgId)
    local oldUnion = self.unions[oldUnionId]
    if oldUnion then
        oldUnion:unsetGridOwner(oldPid, gridCfgId)
    end
end

function UnionMgr:starmapGridContribute(pid, gridCfgId, contriDegree)
    -- TODO: better
    for unionId, union in pairs(self.unions) do
        if union:isMember(pid) then
            union:addContriDegree(pid, contriDegree)
            break
        end
    end
end

function UnionMgr:starmapGridReward(pid, unionId, gridCfgId, gridCarboxyl, nftBuilds, resDict)
    local union = self.unions[unionId]
    if not union then
        return
    end
    union:starmapGridReward(pid, gridCfgId, gridCarboxyl, nftBuilds, resDict)
end

function UnionMgr:starmapAddGridScoreCount(pid, unionId, gridCfgId, makeScoreCount)
    local union = self.unions[unionId]
    if not union then
        return
    end
    union:starmapAddGridScoreCount(pid, gridCfgId, makeScoreCount)
end

function UnionMgr:getPersonalGridScore(unionId)
    local union = self.unions[unionId]
    if not union then
        return 0
    end
    return union:getPersonalGridScore()
end

function UnionMgr:getStarmapMatchRankList(matchCfgId, matchMembers)
    local rankMembers = {}
    for unionId in pairs(matchMembers) do
        local union = self.unions[unionId]
        if union then
            local rankInfo = {}
            rankInfo.unionId = unionId
            rankInfo.unionName = union.unionName
            rankInfo.unionFlag = union.unionFlag
            rankInfo.memberCount = table.count(union.members)
            local unionScore = union:getMatchScore(matchCfgId)
            local personScore = union:getPersonalGridScore()
            rankInfo.personScore = personScore
            rankInfo.score = unionScore + personScore
            if rankInfo.score > 0 then
                table.insert(rankMembers, rankInfo)
            end
        end
    end
    if table.count(rankMembers) > 0 then
        table.sort(rankMembers, function(a, b)
            if a.score == b.score then
                return a.unionId < b.unionId
            else
                return a.score > b.score
            end
        end)
    end
    for i, v in ipairs(rankMembers) do
        gg.shareProxy:send("setStarmapMatchUnionRankInfo", v.unionId, {
            unionId = v.unionId,
            unionName = v.unionName,
            personScore = v.personScore,
            score = v.score,
            rank = i,
        })
    end

    return rankMembers
end

function UnionMgr:onMatchRankUpdate(matchCfgId, matchMembers)
    -- ""、""、""、""、""
    local rankMembers = self:getStarmapMatchRankList(matchCfgId, matchMembers)
    if table.count(rankMembers) > 0 then
        -- gg.internal:send(".match", "api", "updateMatchRankInfo", matchCfgId, rankMembers)
        gg.matchProxy:send("updateMatchRankInfo", matchCfgId, rankMembers)
    end
end

function UnionMgr:getStarmapMatchChainRankList(matchCfgId, matchMembers)
    local chainRankData = {}
    for unionId in pairs(matchMembers) do
        local union = self.unions[unionId]
        if union then
            local chainIndex = gg.getChainIndexById(union.unionChain)
            chainRankData[chainIndex] = chainRankData[chainIndex] or {}
            local rankInfo = {}
            rankInfo.unionId = unionId
            rankInfo.unionName = union.unionName
            rankInfo.unionFlag = union.unionFlag
            rankInfo.unionChain = union.unionChain
            rankInfo.memberCount = table.count(union.members)
            local unionScore = union:getMatchChainScore(matchCfgId)
            local personScore = union:getPersonalGridScore()
            rankInfo.personScore = personScore
            rankInfo.score = unionScore + personScore
            if rankInfo.score > 0 then
                table.insert(chainRankData[chainIndex], rankInfo)
            end
        end
    end
    for k, v in pairs(chainRankData) do
        if table.count(v) > 0 then
            table.sort(v, function(a, b)
                if a.score == b.score then
                    return a.unionId < b.unionId
                else
                    return a.score > b.score
                end
            end)
        end
    end
    
    for k, v in pairs(chainRankData) do
        for ii, vv in ipairs(v) do
            gg.shareProxy:send("setStarmapMatchUnionRankInfo", vv.unionId, {
                unionId = vv.unionId,
                unionName = vv.unionName,
                unionChain = vv.unionChain,
                personScore = vv.personScore,
                score = vv.score,
                rank = ii,
            })
        end
    end

    return chainRankData
end

function UnionMgr:onMatchChainRankUpdate(matchCfgId, matchMembers)
    -- ""、""、""、""、""
    local chainRankData = self:getStarmapMatchChainRankList(matchCfgId, matchMembers)
    if table.count(chainRankData) > 0 then
        gg.matchProxy:send("updateMatchChainRankInfo", matchCfgId, chainRankData)
    end
end

function UnionMgr:_getMatchUnionRankData(rewardInfos)
    local unionRankDict = {}
    for _, v in pairs(rewardInfos) do
        local union = self.unions[v.unionId]
        if union then
            unionRankDict[v.unionId] = {
                rank = v.rank,
                hyt = v.hyt,
                mit = v.mit,
            }
        end
    end
    return unionRankDict
end

--- ""
--@param[type=int] matchCfgId 
--@param[type=table] rewardInfos={
    -- {unionId = ""id,
    -- rank = ""
    -- hyt = ""
    -- mit = ""mit},...
-- }
function UnionMgr:distributeMatchReward(matchCfgId, rewardInfos)
    logger.logf("info","StarmapMatchReward","op=distributeMatchReward,matchCfgId=%s,rewardInfos=%s,", matchCfgId, table.dump(rewardInfos))
    self:backupStarmapMatchUnionData()
    ----------------------------------------
    local unionRankDict = self:_getMatchUnionRankData(rewardInfos)
    local contributeRatio = gg.getGlobalCfgFloatValue("GuildContributeRatio", 0)
    --[[
        playerRewardDict = {
            [pid] = {
                [unionId] = {
                    ["totalHy"] = "",
                    ["rankTotalHy"] = "",
                    ["rankTotalMit"] = ""mit,

                    ["jobHy"] = "",
                    ["jobName"] = "",
                    ["jobRatio"] = "",

                    ["contriDegree"] = "",
                    ["totalDegree"] = "",
                    ["contriHy"] = "",

                    ["combatVal"] = "",
                    ["totalCombatVal"] = "",
                    ["combatHy"] = "",

                    ["rankJobHy"] = "",
                    ["rankJobMit"] = ""mit"",

                    ["rankContriHy"] = "",
                    ["rankContriMit"] = ""mit"",

                    ["rankCombatHy"] = "",
                    ["rankcCombatMit"] = ""mit"",
                }
            }
        }    
    --]]
    local playerRewardDict = {}
    --[[
        othUnionResTotal = {
            [pid] = {
                [unionId] = {
                    ["unionName"] = "",
                    ["hy"] = "",
                    ["mit"] = mit"",
                }
            }
        }    
    --]]
    local othUnionResTotal = {}
    --[[
        plyMailRes = {
            [pid] = {
                ["hy"] = "",
                ["mit"] = mit"",
            }
        }    
    --]]
    local plyMailRes = {}
    --[[
        plyMailParams = {
            [pid] = {
                ["unionName"] = "",
                ["unionRank"] = "",
                ["jobName"] = "",
                ["jobRatio"] = "",
                ["contriDegree"] = "",
                ["totalDegree"] = "",
                ["combatVal"] = "",
                ["totalCombatVal"] = "",
                ["othUnionStr"] = "",
                ["totalHy"] = "",
                ["rankTotalHy"] = "",
            }
        }
    --]]
    local plyMailParams = {}
    for unionId, union in pairs(self.unions) do
        --""
        if union.carboxyl > 0 then
            --""
            local jobCostHy = 0
            for pid, member in pairs(union.members) do
                local dict = playerRewardDict[pid] or {}
                local tempUnionDict = dict[unionId] or {}
                tempUnionDict.totalHy = union.carboxyl
                tempUnionDict.rankTotalHy = 0
                tempUnionDict.rankTotalMit = 0
                local ratio = ggclass.Union.getUnionJobRewardRatio(member.unionJob)
                tempUnionDict.jobHy = math.floor(union.carboxyl * ratio)
                tempUnionDict.jobName = constant.UNION_JOB_NAME[member.unionJob]
                tempUnionDict.jobRatio = ratio * 100
                if tempUnionDict.jobHy > 0 then
                    jobCostHy = jobCostHy + tempUnionDict.jobHy
                end
                dict[unionId] = tempUnionDict
                playerRewardDict[pid] = dict

                plyMailRes[pid] = plyMailRes[pid] or {}
                plyMailRes[pid]["hy"] = (plyMailRes[pid]["hy"] or 0) + tempUnionDict.jobHy

                plyMailParams[pid] = plyMailParams[pid] or {}
                plyMailParams[pid]["unionName"] = plyMailParams[pid]["unionName"] or union.unionName
                plyMailParams[pid]["unionRank"] = plyMailParams[pid]["unionRank"] or 0
                plyMailParams[pid]["jobName"] = plyMailParams[pid]["jobName"] or tempUnionDict.jobName
                plyMailParams[pid]["jobRatio"] = plyMailParams[pid]["jobRatio"] or tempUnionDict.jobRatio
                plyMailParams[pid]["othUnionStr"] = plyMailParams[pid]["othUnionStr"] or ""
                plyMailParams[pid]["totalHy"] = tempUnionDict.totalHy
                plyMailParams[pid]["rankTotalHy"] = tempUnionDict.rankTotalHy
            end
            union.carboxyl = union.carboxyl - jobCostHy

            --""
            local valDict = {
                carboxyl = union.carboxyl * contributeRatio,
            }
            local memValDict = union:_getMemValByContribute(valDict)
            for pid, pval in pairs(memValDict) do
                local dict = playerRewardDict[pid] or {}
                local tempUnionDict = dict[unionId] or {}
                tempUnionDict.contriDegree = union.contriDegree[pid] or 0
                tempUnionDict.totalDegree = pval.allDegree or 0
                tempUnionDict.contriHy = pval.carboxyl or 0
                if union:isMember(pid) then
                    plyMailParams[pid] = plyMailParams[pid] or {}
                    plyMailParams[pid]["contriDegree"] = plyMailParams[pid]["contriDegree"] or tempUnionDict.contriDegree
                    plyMailParams[pid]["totalDegree"] = plyMailParams[pid]["totalDegree"] or tempUnionDict.totalDegree
                else
                    othUnionResTotal[pid] = othUnionResTotal[pid] or {}
                    othUnionResTotal[pid][unionId] = othUnionResTotal[pid][unionId] or {}
                    othUnionResTotal[pid][unionId]["unionName"] = othUnionResTotal[pid][unionId]["unionName"] or union.unionName
                    othUnionResTotal[pid][unionId]["hy"] = (othUnionResTotal[pid][unionId]["hy"] or 0) + (pval.carboxyl or 0)
                end
                dict[unionId] = tempUnionDict
                playerRewardDict[pid] = dict

                plyMailRes[pid] = plyMailRes[pid] or {}
                plyMailRes[pid]["hy"] = (plyMailRes[pid]["hy"] or 0) + tempUnionDict.contriHy
            end

            --""
            local combatValDict = {
                carboxyl = union.carboxyl * (1 - contributeRatio),
            }
            local memCombatValDict = union:_getMemValByCombatVal(combatValDict)
            for pid, pval in pairs(memCombatValDict) do
                local dict = playerRewardDict[pid] or {}
                local tempUnionDict = dict[unionId] or {}
                tempUnionDict.combatVal = union.combatDict[pid] or 0
                tempUnionDict.totalCombatVal = pval.allVal or 0
                tempUnionDict.combatHy = pval.carboxyl or 0
                if union:isMember(pid) then
                    plyMailParams[pid] = plyMailParams[pid] or {}
                    plyMailParams[pid]["combatVal"] = plyMailParams[pid]["combatVal"] or tempUnionDict.combatVal
                    plyMailParams[pid]["totalCombatVal"] = plyMailParams[pid]["totalCombatVal"] or tempUnionDict.totalCombatVal
                else
                    othUnionResTotal[pid] = othUnionResTotal[pid] or {}
                    othUnionResTotal[pid][unionId] = othUnionResTotal[pid][unionId] or {}
                    othUnionResTotal[pid][unionId]["unionName"] = othUnionResTotal[pid][unionId]["unionName"] or union.unionName
                    othUnionResTotal[pid][unionId]["hy"] = (othUnionResTotal[pid][unionId]["hy"] or 0) + (pval.carboxyl or 0)
                end
                dict[unionId] = tempUnionDict
                playerRewardDict[pid] = dict

                plyMailRes[pid] = plyMailRes[pid] or {}
                plyMailRes[pid]["hy"] = (plyMailRes[pid]["hy"] or 0) + tempUnionDict.combatHy
            end
        end

        --""
        if unionRankDict[unionId] then
            local rankDict = unionRankDict[unionId]
            if rankDict.hyt > 0 or rankDict.mit > 0 then
                --""
                local jobCostHy = 0
                local jobCostMit = 0
                for pid, member in pairs(union.members) do
                    local dict = playerRewardDict[pid] or {}
                    local tempUnionDict = dict[unionId] or {}
                    tempUnionDict.totalHy = tempUnionDict.totalHy or union.carboxyl
                    tempUnionDict.rankTotalHy = rankDict.hyt
                    tempUnionDict.rankTotalMit = rankDict.mit
                    local ratio = ggclass.Union.getUnionJobRewardRatio(member.unionJob)
                    tempUnionDict.rankJobHy = math.floor(rankDict.hyt * ratio)
                    tempUnionDict.rankJobMit = math.floor(rankDict.mit * ratio)
                    tempUnionDict.jobName = tempUnionDict.jobName or constant.UNION_JOB_NAME[member.unionJob]
                    tempUnionDict.jobRatio = tempUnionDict.jobRatio or (ratio * 100)
                    if tempUnionDict.rankJobHy > 0 then
                        jobCostHy = jobCostHy + tempUnionDict.rankJobHy
                    end
                    if tempUnionDict.rankJobMit > 0 then
                        jobCostMit = jobCostMit + tempUnionDict.rankJobMit
                    end
                    dict[unionId] = tempUnionDict
                    playerRewardDict[pid] = dict

                    plyMailRes[pid] = plyMailRes[pid] or {}
                    plyMailRes[pid]["hy"] = (plyMailRes[pid]["hy"] or 0) + tempUnionDict.rankJobHy
                    plyMailRes[pid]["mit"] = (plyMailRes[pid]["mit"] or 0) + tempUnionDict.rankJobMit

                    plyMailParams[pid] = plyMailParams[pid] or {}
                    plyMailParams[pid]["unionName"] = plyMailParams[pid]["unionName"] or union.unionName
                    plyMailParams[pid]["unionRank"] = rankDict.rank
                    plyMailParams[pid]["jobName"] = plyMailParams[pid]["jobName"] or tempUnionDict.jobName
                    plyMailParams[pid]["jobRatio"] = plyMailParams[pid]["jobRatio"] or tempUnionDict.jobRatio
                    plyMailParams[pid]["othUnionStr"] = plyMailParams[pid]["othUnionStr"] or ""
                    plyMailParams[pid]["totalHy"] = tempUnionDict.totalHy
                    plyMailParams[pid]["rankTotalHy"] = tempUnionDict.rankTotalHy
                end
                rankDict.hyt = rankDict.hyt - jobCostHy
                rankDict.mit = rankDict.mit - jobCostMit
                if rankDict.hyt > 0 or rankDict.mit > 0 then
                    --""
                    local valDict = {
                        carboxyl = rankDict.hyt * contributeRatio,
                        mit = rankDict.mit * contributeRatio,
                    }
                    local memValDict = union:_getMemValByContribute(valDict)
                    for pid, pval in pairs(memValDict) do
                        local dict = playerRewardDict[pid] or {}
                        local tempUnionDict = dict[unionId] or {}
                        tempUnionDict.contriDegree = tempUnionDict.contriDegree or (union.contriDegree[pid] or 0)
                        tempUnionDict.totalDegree = tempUnionDict.totalDegree or (pval.allDegree or 0)
                        tempUnionDict.rankContriHy = pval.carboxyl or 0
                        tempUnionDict.rankContriMit = pval.mit or 0
                        if union:isMember(pid) then
                            plyMailParams[pid] = plyMailParams[pid] or {}
                            plyMailParams[pid]["contriDegree"] = plyMailParams[pid]["contriDegree"] or tempUnionDict.contriDegree
                            plyMailParams[pid]["totalDegree"] = plyMailParams[pid]["totalDegree"] or tempUnionDict.totalDegree
                        else
                            othUnionResTotal[pid] = othUnionResTotal[pid] or {}
                            othUnionResTotal[pid][unionId] = othUnionResTotal[pid][unionId] or {}
                            othUnionResTotal[pid][unionId]["unionName"] = othUnionResTotal[pid][unionId]["unionName"] or union.unionName
                            othUnionResTotal[pid][unionId]["hy"] = (othUnionResTotal[pid][unionId]["hy"] or 0) + (pval.carboxyl or 0)
                            othUnionResTotal[pid][unionId]["mit"] = (othUnionResTotal[pid][unionId]["mit"] or 0) + (pval.mit or 0)
                        end
                        dict[unionId] = tempUnionDict
                        playerRewardDict[pid] = dict

                        plyMailRes[pid] = plyMailRes[pid] or {}
                        plyMailRes[pid]["hy"] = (plyMailRes[pid]["hy"] or 0) + tempUnionDict.rankContriHy
                        plyMailRes[pid]["mit"] = (plyMailRes[pid]["mit"] or 0) + tempUnionDict.rankContriMit
                    end
                    -----------------------------------
                    --""
                    local combatValDict = {
                        carboxyl = rankDict.hyt * (1 - contributeRatio),
                        mit = rankDict.mit * (1 - contributeRatio),
                    }
                    local memCombatValDict = union:_getMemValByCombatVal(combatValDict)
                    for pid, pval in pairs(memCombatValDict) do
                        local dict = playerRewardDict[pid] or {}
                        local tempUnionDict = dict[unionId] or {}
                        tempUnionDict.combatVal = tempUnionDict.combatVal or (union.combatDict[pid] or 0)
                        tempUnionDict.totalCombatVal = tempUnionDict.totalCombatVal or (pval.allVal or 0)
                        tempUnionDict.rankCombatHy = pval.carboxyl or 0
                        tempUnionDict.rankcCombatMit = pval.mit or 0
                        if union:isMember(pid) then
                            plyMailParams[pid] = plyMailParams[pid] or {}
                            plyMailParams[pid]["combatVal"] = plyMailParams[pid]["combatVal"] or tempUnionDict.combatVal
                            plyMailParams[pid]["totalCombatVal"] = plyMailParams[pid]["totalCombatVal"] or tempUnionDict.totalCombatVal
                        else
                            othUnionResTotal[pid] = othUnionResTotal[pid] or {}
                            othUnionResTotal[pid][unionId] = othUnionResTotal[pid][unionId] or {}
                            othUnionResTotal[pid][unionId]["unionName"] = othUnionResTotal[pid][unionId]["unionName"] or union.unionName
                            othUnionResTotal[pid][unionId]["hy"] = (othUnionResTotal[pid][unionId]["hy"] or 0) + (pval.carboxyl or 0)
                            othUnionResTotal[pid][unionId]["mit"] = (othUnionResTotal[pid][unionId]["mit"] or 0) + (pval.mit or 0)
                        end
                        dict[unionId] = tempUnionDict
                        playerRewardDict[pid] = dict

                        plyMailRes[pid] = plyMailRes[pid] or {}
                        plyMailRes[pid]["hy"] = (plyMailRes[pid]["hy"] or 0) + tempUnionDict.rankCombatHy
                        plyMailRes[pid]["mit"] = (plyMailRes[pid]["mit"] or 0) + tempUnionDict.rankcCombatMit
                    end
                end
            end
        end
    end
    local settlementData = {
        unionRankDict = unionRankDict,
        playerRewardDict = playerRewardDict,
        othUnionResTotal = othUnionResTotal,
    }
    logger.logf("info","StarmapMatchReward","op=distributeMatchReward,matchCfgId=%s,settlementData=%s,", matchCfgId, table.dump(settlementData))
    --""
    local sendCnt = 0
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_STARMAP_UNION_REWARD]
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle
    for pid, resVal in pairs(plyMailRes) do
        local needSend = false
        local mailItems = {}
        if resVal.hy and resVal.hy > 0 then
            table.insert(mailItems, {
                cfgId = constant.RES_CARBOXYL,
                count = resVal.hy,
                type = constant.MAIL_ATTACH_RES,
            })
            needSend = true
        end
        if resVal.mit and resVal.mit > 0 then
            table.insert(mailItems, {
                cfgId = constant.RES_MIT,
                count = resVal.mit,
                type = constant.MAIL_ATTACH_RES,
            })
            needSend = true
        end
        if needSend then
            local othResDict = othUnionResTotal[pid] or {}
            local unionStr = "0"
            for _uninId, _v in pairs(othResDict) do
                unionStr = unionStr.."DAO: "..(_v.unionName or "")..", ".."Reward: "..((_v.hy or 0)/1000).."HY"..", "..((_v.mit or 0)/1000).."MIT"..";\n"
            end
            local mailParams = plyMailParams[pid] or {}
            local mailData = {
                title = title,
                content = string.format(mailCfg.mailContent, 
                    mailParams.unionName or "", --1
                    mailParams.unionRank or 0, --2
                    (mailParams.rankTotalHy or 0)/1000, --3
                    (mailParams.totalHy or 0)/1000, --4
                    mailParams.jobName or "", --5
                    mailParams.jobRatio or 0, --6
                    mailParams.contriDegree or 0, --7
                    mailParams.totalDegree or 0, --8
                    mailParams.combatVal or 0, --9
                    mailParams.totalCombatVal or 0, --10
                    unionStr--11
                ),
                attachment = mailItems,
                logType = gamelog.STARMAP_MATCH_UNION_REWARD
            }
            gg.mailProxy:send("gmSendMail", sendId, sendName, { pid }, mailData)
            logger.logf("info","StarmapMatchReward","op=distributeMatchReward,matchCfgId=%s,pid=%s,mailItems=%s,content=%s,", matchCfgId, pid, table.dump(mailItems), mailData.content)
            sendCnt = sendCnt + 1
        end
        if sendCnt == 100 then
            skynet.sleep(1)
            sendCnt = 0
        end
    end
end

function UnionMgr:starmapUnionRankReward(unionId, rank, score, matchCfgId, actCfgId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    union:starmapUnionRankReward(rank, score, matchCfgId, actCfgId)
end

function UnionMgr:onMatchNoticeTime(matchCfgId)

end

function UnionMgr:onMatchStartTime(matchCfgId)
    local ret = {}
    for unionId, union in pairs(self.unions) do
        local ok = union:onMatchStartTime()
        if ok then
            table.insert(ret, unionId)
        end
    end
    return ret
end

function UnionMgr:onMatchEndTime(matchCfgId)

end

function UnionMgr:onUnionCampaignUpdate(unionId, pid, battleId, campaignId, fightNftIds)
    local union = self.unions[unionId]
    if not union then
        return
    end
    union:onUnionCampaignUpdate(pid, battleId, campaignId, fightNftIds)
end

function UnionMgr:takeStarmapCampaignArmy(unionId, pid, gridCfgId, unionArmys)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:takeStarmapCampaignArmy(pid, gridCfgId, unionArmys)
end

function UnionMgr:starmapCampaignCostArmyLife(unionId, pid, fightArmy, dieSoliders)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:starmapCampaignCostArmyLife(pid, fightArmy, dieSoliders)
end

function UnionMgr:returnBackCampaignArmy(unionId, pid, fightArmy)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:returnBackCampaignArmy(pid, fightArmy)
end

function UnionMgr:delUnionOwnGrid(pid, unionId, gridCfgId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    union:unsetGridOwner(pid, gridCfgId)
end

function UnionMgr:matchSeasonEndHandle()
    local ret = {}
    for unionId, union in pairs(self.unions) do
        local ok = union:matchSeasonEndHandle()
        if ok then
            table.insert(ret, unionId)
        end
    end

    local tempUnions = {}
    for unionId, union in pairs(self.unions) do
        table.insert(tempUnions, union)
    end

    self.unions = {}
    self.pidToUnionId = {}
    self.unionNameToUnionId = {}

    for _, union in pairs(tempUnions) do
        --""
        union:doDissolve()
    end

    gg.mongoProxy.union:delete({})

    logger.logf("info","DissolveUnion","op=matchSeasonEndHandle,unionIdList=%s,", table.dump(ret))
    return ret
end

function UnionMgr:addUnionFavoriteGrid(pid, unionId, cfgId, tag)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doAddUnionFavoriteGrid(pid, cfgId, tag)
end

function UnionMgr:delUnionFavoriteGrid(pid, unionId, cfgId)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doDelUnionFavoriteGrid(pid, cfgId)
end

function UnionMgr:getUnionFavoriteGridState(unionId, pid, inGrids)
    local union = self.unions[unionId]
    if not union then
        return {}
    end
    return union:getFavoriteGridState(inGrids)
end

function UnionMgr:getUnionFavoriteGrids(unionId, pid)
    local union = self.unions[unionId]
    if not union then
        return {}
    end
    return union:getUnionFavoriteGrids()
end

function UnionMgr:getUnionDefenseBuild(unionId, pid, buildId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:getUnionDefenseBuild(pid, buildId)
end

----------------------------------------------------------------------

-- ""
function UnionMgr:createUnion(pid, data)
    local existUnion = self:getUnionByUnionName(data.unionName)
    if existUnion then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NAME_REPEAT))
        return
    end
    local playerUnion = self:getUnionByPlayerId(pid)
    if playerUnion then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_JOINED))
        return
    end
    local unionId = gg.shareProxy:call("genUnionId")
    local union = ggclass.Union.new()
    self.unions[unionId] = union
    union:doCreate(unionId, data)
    gg.savemgr:autosave(union)
    gg.savemgr:nowsave(union)
end

-- ""
function UnionMgr:joinUnion(pid, unionId, data)
    local playerUnion = self:getUnionByPlayerId(pid)
    if playerUnion then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_JOINED))
        return
    end
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doJoin(pid, data)
end

-- ""
function UnionMgr:joinUnionAnswer(pid, unionId, applyPid, answer)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doJoinAnswer(pid, applyPid, answer)
end

-- ""
function UnionMgr:unionClearAllApply(pid, unionId)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doClearAllApply(pid)
end

-- ""
function UnionMgr:inviteJoinUnion(pid, unionId, invitePid)
    local playerUnion = self:getUnionByPlayerId(invitePid)
    if playerUnion then -- ""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_JOINED))
        return
    end
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doInviteJoin(pid, invitePid)
end

-- ""
function UnionMgr:answerUnionInvite(pid, unionId, answer, memberInfo)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doAnswerInvite(pid, answer, memberInfo)
end

-- ""
function UnionMgr:modifyUnionInfo(pid, unionId, newInfo)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doModifyUnionInfo(pid, newInfo)
end

-- ""
function UnionMgr:updateMemberInfo(pid, unionId, memberInfo)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doUpdateMemberInfo(pid, memberInfo)
end

-- ""
function UnionMgr:quitUnion(pid, unionId)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doQuit(pid)
    -- "", ""
    if not next(union.members) then
        gg.savemgr:closesave(union)
        self.unions[unionId] = nil
        union:doDissolve(pid)
    end
end

-- ""
function UnionMgr:tickOutUnion(pid, unionId, tickedPid)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doTickOut(pid, tickedPid)
end

-- ""
function UnionMgr:editUnionJob(pid, unionId, editedPid, unionJob, editType)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:doEditJob(pid, editedPid, unionJob, editType)
end

-- ""
function UnionMgr:donate(pid, unionId, donateInfo)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:donate(pid, donateInfo)
end

-- ""NFT
function UnionMgr:donateNft(pid, unionId, donateInfo)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:donateNft(pid, donateInfo)
end

-- ""NFT
function UnionMgr:updateNft(pid, unionId, nftsInfo)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:updateNft(pid, nftsInfo)
end

-- ""NFT
function UnionMgr:takeBackNft(pid, unionId, idList)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:takeBackNft(pid, idList)
end

-- ""nft""
function UnionMgr:starMapTakeNft(unionId, nftId, where)
    local union = self.unions[unionId]
    if not union then
        return false
    end
    if not union:canTakeNft(nftId, constant.ITEM_BUILD) then
        return false
    end
    return union:takeNftForBattle(nftId, where, true)
end

function UnionMgr:starMapUseNftListToGrid(unionId, nftIds, where)
    local list = {}
    local union = self.unions[unionId]
    if not union then
        return list
    end
    for i, v in ipairs(nftIds) do
        if union:canTakeNft(v, constant.ITEM_BUILD) then
            local nft = union:takeNftForBattle(v, where, true)
            table.insert(list, v)
        end
    end
    return list
end

function UnionMgr:starMapNotUseNftListToGrid(unionId, nftIds, where)
    local list = {}
    local union = self.unions[unionId]
    if not union then
        return list
    end
    for i, v in ipairs(nftIds) do
        local item = union.items[v]
        if item then
            item.refBy = 0
            table.insert(list, v)
        end
    end
    return list
end

function UnionMgr:getNftInfo(unionId, nftId)
    local union = self.unions[unionId]
    if not union then
        return false
    end
    return union:getItemEntity(nftId)
end

function UnionMgr:getNftList(unionId, nftIds)
    local union = self.unions[unionId]
    if not union then
        return false
    end
    return union:getItemList(nftIds)
end

function UnionMgr:getDefenseBuildList(unionId, pid, buildIds)
    local union = self.unions[unionId]
    if not union then
        return
    end
    local list = {}
    for i, v in ipairs(buildIds) do
        local build = union.builds[v]
        if build then
            table.insert(list, build:pack())
        end
    end
    return list
end

-- ""
function UnionMgr:starMapTakeDefenseBuild(pid, unionId, buildId)
    local member = self:getUnionMember(unionId, pid)
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return false, -1
    end
    local union = self.unions[unionId]
    if not union then
        return false
    end
    local jobAuth = union.unionJobCanPutBuild(member.unionJob)
    if not jobAuth then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return false, -1
    end
    return union:getDefenseBuildInfo(buildId, pid)
end

-- ""nft""
function UnionMgr:starMapBackNfts(unionId, nfts)
    local union = self.unions[unionId]
    if not union then
        return false
    end
    union:returnBackNftsWithEntity(nfts)
    union:handleMemZeroLifeNfts()
    return true
end

-- ""
function UnionMgr:trainSolider(pid, unionId, soliderCfgId, soliderCount)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:trainSolider(pid, soliderCfgId, soliderCount)
end

-- gm""
function UnionMgr:gmGenSolider(pid, unionId, soliderCfgId, soliderCount)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:gmGenSolider(pid, soliderCfgId, soliderCount)
end

-- gm""NFT""
function UnionMgr:gmClearNFTRef(pid, unionId)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:gmClearNFTRef(pid)
end

function UnionMgr:genDefenseBuild(pid, unionId, defenseCfgId, defenseCount)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:genDefenseBuild(pid, defenseCfgId, defenseCount)
end

function UnionMgr:levelUpTech(pid, unionId, techCfgId)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:levelUpTech(pid, techCfgId)
end

function UnionMgr:startEditUnionArmys(pid, unionId)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    union:startEditUnionArmys(pid)
end

-- ""
function UnionMgr:transferBeginGrid(pid, unionId, dstCfgId)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    return union:doTransferBeginGrid(pid, dstCfgId)
end

-- ""DAO
function UnionMgr:donateDaoItem(pid, unionId, contriDegree, exp)
    local union = self.unions[unionId]
    if not union then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    return union:donateDaoItem(pid, contriDegree, exp)
end

function UnionMgr:getAllUnionInfo()
    local unionInfos = {}
    for k, v in pairs(self.unions) do
        table.insert(unionInfos, v:packUnionInfo())
    end
    return unionInfos
end

function UnionMgr:getUnionBase(unionId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:packUnionBase()
end

function UnionMgr:getUnionRes(unionId, pid)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:packUnionRes(pid)
end

function UnionMgr:isUnionResDictEnough(unionId, resDict, pid)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:isUnionResDictEnough(resDict, pid)
end

function UnionMgr:costUnionResDict(unionId, resDict, pid)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:costUnionResDict(resDict, pid)
end

function UnionMgr:getUnionSoliders(unionId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:packUnionSoliders()
end

function UnionMgr:getUnionBuilds(unionId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:packUnionBuilds()
end

function UnionMgr:getUnionNfts(unionId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:packUnionNfts()
end

function UnionMgr:getUnionMembers(unionId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:packUnionMembers()
end

function UnionMgr:getUnionTechs(unionId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:packUnionTechs()
end

function UnionMgr:getUnionApplyList(unionId)
    local union = self.unions[unionId]
    if not union then
        return
    end
    return union:packUnionApplyList()
end

function UnionMgr:getUnionCampaignIdList(unionId, pageNo, pageSize)
    local union = self.unions[unionId]
    if not union then
        return {}
    end
    local list = {}
    local count = 0
    local totalRows = table.count(union.campaignIdList)
    for i = totalRows - pageSize*(pageNo - 1), totalRows - pageSize*pageNo + 1, -1 do
        count = count + 1
        table.insert(list, union.campaignIdList[i])
        if count >= pageSize then
            break
        end
    end
    return list
end

function UnionMgr:_getUnionGridScore(list)
    local pa = ggclass.cparallel.new()
    for i, v in ipairs(list) do
        pa:add(function(unionId)
            v.score = gg.starmapProxy:call("getGridScore", nil, unionId)
        end, v.unionId)
    end
    pa:wait()
end

function UnionMgr:_getUnionGridsPos(list)
    local pa = ggclass.cparallel.new()
    for i, v in ipairs(list) do
        pa:add(function(unionId)
            local retInfo = gg.starmapProxy:call("getUnionGridsPos", unionId)
            for gridCfgId, pos in pairs(retInfo) do
                table.insert(v.hyPosList, gridCfgId..","..pos.x..","..pos.y)
            end
        end, v.unionId)
    end
    pa:wait()
end

function UnionMgr:getUnionRankRealTimeData(count, sortKey)
    local maxCount = 0
    local sortList = {}
    for unionId, union in pairs(self.unions) do
        local presidentPId = 0
        local presidentName = ""
        local president = union:getPresidentMember()
        if president then
            presidentName = president.playerName
            presidentPId = president.playerId
        end
        local beginPos = ""
        if union.beginGridId > 0 then
            local cfg = gg.getExcelCfg("starmapConfig")[union.beginGridId]
            if cfg then
                beginPos = union.beginGridId..","..cfg.pos.x..","..cfg.pos.y
            end
        end
        local techs = {}
        for tk, tv in pairs(union.techs) do
            table.insert(techs, tv.cfgId..","..tv.level)
        end
        table.insert(sortList, {
            unionId = union.unionId,
            unionName = union.unionName,
            unionLevel = union.unionLevel,
            score = 0,
            memCount = table.count(union.members),
            presidentPId = presidentPId,
            presidentName = presidentName,
            beginPos = beginPos,
            hyPosList = {},
            techs = techs,
        })
        maxCount = maxCount + 1
    end
    count = math.min(count, maxCount)
    local list = {}
    if sortKey == "level" then
        table.sort(sortList, function(a, b)
            if a.unionLevel == b.unionLevel then
                return a.unionId < b.unionId
            else
                return a.unionLevel > b.unionLevel
            end
        end)
        for i = 1, count, 1 do
            if sortList[i] then
                table.insert(list, sortList[i])
            end
        end
        self:_getUnionGridScore(list)
    elseif sortKey == "memCount" then
        table.sort(sortList, function(a, b)
            if a.memCount == b.memCount then
                return a.unionId < b.unionId
            else
                return a.memCount > b.memCount
            end
        end)
        for i = 1, count, 1 do
            if sortList[i] then
                table.insert(list, sortList[i])
            end
        end
        self:_getUnionGridScore(list)
    elseif sortKey == "score" then
        --1.get score
        self:_getUnionGridScore(sortList)
        --2.sort
        table.sort(sortList, function(a, b)
            if a.score == b.score then
                return a.unionId < b.unionId
            else
                return a.score > b.score
            end
        end)
        --3.get
        for i = 1, count, 1 do
            if sortList[i] then
                table.insert(list, sortList[i])
            end
        end
    end
    self:_getUnionGridsPos(list)
    return list
end

function UnionMgr:searchUnionNameOrUnionIdLike(keyWord)
    local unions = {}
    local cnt = 0
    for k, v in pairs(self.unions) do
        if string.find(tostring(v.unionName), keyWord) or string.find(tostring(v.unionId), keyWord) then
            local unionBase = self:getUnionBase(v.unionId)
            if unionBase then
                table.insert(unions, unionBase)
            end
            cnt = cnt + 1
            if cnt >= 30 then
                break
            end
        end
    end
    return unions
end

function UnionMgr:backupStarmapMatchUnionData()
    local isBackup = gg.shareProxy:call("getOpCfg", constant.REDIS_STARMAP_BACKUP_UNION)
    if not isBackup or isBackup ~= 1 then
        return
    end
    --""
    local jackpotInfo = gg.redisProxy:call("get", constant.REDIS_STARMAP_JACKPOT_INFO)
    gg.redisProxy:call("set", constant.REDIS_STARMAP_JACKPOT_INFO_BAK, jackpotInfo)
    
    local data = {}
    for unionId, union in pairs(self.unions) do
        local unionData = union:serialize()
        local infoDict = {}
        for ukey, uval in pairs(unionData) do
            if constant.UNION_STARMAP_BACKUP_KEYS[ukey] then
                infoDict[ukey] = uval
            end
        end
        data[unionId] = infoDict
    end
    local isOk = gg.shareProxy:call("setStarmapMatchUnionData", data)
    logger.logf("info", "StarmapMatchUnionData", "op=%s, isOk=%s, ", "backup", isOk)
    return isOk
end

function UnionMgr:restoreStarmapMatchUnionData()
    local isBackup = gg.shareProxy:call("getOpCfg", constant.REDIS_STARMAP_BACKUP_UNION)
    if not isBackup or isBackup ~= 1 then
        return
    end
    local data = gg.shareProxy:call("getStarmapMatchUnionData")
    for unionId, v in pairs(data) do
        local union = self.unions[unionId]
        if union then
            for kk, vv in pairs(v) do
                if kk == "gridsScoreCount" then
                    for kkk, vvv in pairs(vv or {}) do
                        union.gridsScoreCount[tonumber(kkk)] = vvv
                    end
                elseif kk == "techs" then
                    for kkk, vvv in pairs(vv or {}) do
                        local tech = ggclass.UnionTech.new({union = union})
                        tech:deserialize(vvv)
                        union.techs[vvv.cfgId] = tech
                    end
                elseif kk == "contriDegree" then
                    for kkk, vvv in pairs(vv or {}) do
                        union.contriDegree[tonumber(kkk)] = vvv
                    end
                elseif kk == "combatDict" then
                    for kkk, vvv in pairs(vv or {}) do
                        union.combatDict[tonumber(kkk)] = vvv
                    end
                else
                    union[kk] = vv
                end
            end
            union.dirty = true
        end
    end
    logger.logf("info", "StarmapMatchUnionData", "op=%s, isOk=%s, ", "restore", true)
    return true
end

function UnionMgr:reDistributeGridHy()
    local isBackup = gg.shareProxy:call("getOpCfg", constant.REDIS_STARMAP_BACKUP_UNION)
    if not isBackup or isBackup ~= 1 then
        return
    end
    logger.logf("info", "StarmapMatchUnionData", "op=%s, isOk=%s, ", "reDistribute", true)
    return true
end

function UnionMgr:reDistributeGridHyFromRedis()
end

function UnionMgr:reDistributeRankRes()
end

function UnionMgr:clearStarmapMatchUnionData()
    local isBackup = gg.shareProxy:call("getOpCfg", constant.REDIS_STARMAP_BACKUP_UNION)
    if not isBackup or isBackup ~= 1 then
        return
    end
    local data = {}
    for unionId, union in pairs(self.unions) do
        for kk, vv in pairs(constant.UNION_STARMAP_CLEAR_KEYS) do
            if vv.clear then
                if vv.dtype == "table" then
                    union[kk] = {}
                elseif vv.dtype == "number" then
                    union[kk] = 0
                elseif vv.dtype == "string" then
                    union[kk] = ""
                end
            end
        end
        union.dirty = true
    end
    logger.logf("info", "StarmapMatchUnionData", "op=%s, isOk=%s, ", "clear", true)
    return true
end

function UnionMgr:handleStarmapMatchUnionCmd(op, opParam)
    if op == "backup" then
        return self:backupStarmapMatchUnionData()
    elseif op == "restore" then
        return self:restoreStarmapMatchUnionData()
    elseif op == "reDistribute" then
        if opParam == "hy" then
            return self:reDistributeGridHy()
        elseif opParam == "rank" then
            self:reDistributeRankRes()
        elseif opParam == "hyFromRedis" then
            self:reDistributeGridHyFromRedis()
        end
    elseif op == "clear" then
        return self:clearStarmapMatchUnionData()
    end
end

function UnionMgr:sendUnionOnlineMembers(unionId, minUnionJob, cmd, ...)
    local union = self.unions[unionId]
    if not union then
        return
    end
    local pids = union:getOnlineMemberPids(minUnionJob)
    union:sendMembers(pids, cmd, ...)
end

function UnionMgr:playerLogin(pid, data)
    local union = self:getUnionByPlayerId(pid)
    if not union then
        return nil
    end
    union:setMemberOnlineStatus(pid, 1)
    union:setMemberChain(pid, data.chain or 0)

    local member = union:getRealMember(pid)
    if member and member.unionJob >= constant.UNION_JOB_VICEPRESIDENT then
        if not data.applyVersion or data.applyVersion ~= union.applyVersion then
            union:sendMembers({pid}, "onUnionNewApply")
        end
    end
end

function UnionMgr:playerLogout(pid, data)
    local union = self:getUnionByPlayerId(pid)
    if not union then
        return nil
    end
    union:setMemberOnlineStatus(pid, 0)
end

function UnionMgr:shutdown()
    for k, union in pairs(self.unions) do
        union.dirty = true
        union:save_to_db()
    end
end

function UnionMgr:onSecond()
    for _, union in pairs(self.unions) do
        union:onSecond()
    end
end

-- ""
function UnionMgr:onMinuteUpdate()

end

-- ""5""
function UnionMgr:onFiveMinuteUpdate()
    -- self:distributeGridRes()
    for _, union in pairs(self.unions) do
        union:onFiveMinute()
    end
end

return UnionMgr
