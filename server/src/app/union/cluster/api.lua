-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

--""
function api.playerLogin(pid, data)
    --print("union playerLogin:", pid, table.dump(data))
    gg.unionMgr:playerLogin(pid, data)
end

--""
function api.playerLogout(pid, data)
    --print("union playerLogout:", pid, table.dump(data))
    gg.unionMgr:playerLogout(pid, data)
end

function api.getUnionIdByPid(pid)
    local union = gg.unionMgr:getUnionByPlayerId(pid)
    if not union then
        return nil
    end
    return union.unionId
end

function api.getUnionBaseInfoByPid(pid)
    local union = gg.unionMgr:getUnionByPlayerId(pid)
    if not union then
        return nil
    end
    local ret = {
        unionId = union.unionId, 
        beginGridId = union.beginGridId,
        unionLevel = union.unionLevel,
    }
    return ret
end

function api.getUnionJob(unionId, pid)
    local member = gg.unionMgr:getUnionMember(unionId, pid)
    if not member then
        return nil
    end
    return member.unionJob
end

function api.checkUnionJobCanPutBuild(unionId, pid)
    local member = gg.unionMgr:getUnionMember(unionId, pid)
    if not member then
        return false
    end
    return ggclass.Union.unionJobCanPutBuild(member.unionJob)
end

function api.checkUnionJobCanAddBuild(unionId, pid)
    local member = gg.unionMgr:getUnionMember(unionId, pid)
    if not member then
        return false
    end
    return ggclass.Union.unionJobCanAddBuild(member.unionJob)
end

function api.getJoinableUnionList()
    return gg.unionMgr:getJoinableUnionList()
end

function api.createUnion(pid, data)
    return gg.unionMgr:createUnion(pid, data)
end

function api.getNftInfo(unionId, nftId)
    return gg.unionMgr:getNftInfo(unionId, nftId)
end

function api.getNftList(unionId, nftIds)
    return gg.unionMgr:getNftList(unionId, nftIds)
end

function api.getDefenseBuildList(pid, unionId, buildIds)
    return gg.unionMgr:getDefenseBuildList(unionId, pid, buildIds)
end

function api.modifyUnionInfo(pid, unionId, newInfo)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.modifyUnionInfo, gg.unionMgr, pid, unionId, newInfo)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.updateMemberInfo(pid, unionId, memberInfo)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.updateMemberInfo, gg.unionMgr, pid, unionId, memberInfo)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.joinUnion(pid, unionId, joinInfo)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.joinUnion, gg.unionMgr, pid, unionId, joinInfo)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.joinUnionAnswer(pid, unionId, answerPid, answer)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.joinUnionAnswer, gg.unionMgr, pid, unionId, answerPid, answer)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.unionClearAllApply(pid, unionId)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.unionClearAllApply, gg.unionMgr, pid, unionId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.inviteJoinUnion(pid, unionId, invitePid)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.inviteJoinUnion, gg.unionMgr, pid, unionId, invitePid)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.answerUnionInvite(pid, unionId, answer, memberInfo)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.answerUnionInvite, gg.unionMgr, pid, unionId, answer, memberInfo)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.editUnionJob(pid, unionId, editedPid, unionJob, editType)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.editUnionJob, gg.unionMgr, pid, unionId, editedPid, unionJob, editType)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.tickOutUnion(pid, unionId, tickPid)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.tickOutUnion, gg.unionMgr, pid, unionId, tickPid)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.quitUnion(pid, unionId)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.quitUnion, gg.unionMgr, pid, unionId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.donate(pid, unionId, donateInfo)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.donate, gg.unionMgr, pid, unionId, donateInfo)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.donateNft(pid, unionId, donateInfo)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.donateNft, gg.unionMgr, pid, unionId, donateInfo)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.updateNft(pid, unionId, nftsInfo)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.updateNft, gg.unionMgr, pid, unionId, nftsInfo)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.takeBackNft(pid, unionId, idList)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.takeBackNft, gg.unionMgr, pid, unionId, idList)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.trainSolider(pid, unionId, soliderCfgId, soliderCount)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.trainSolider, gg.unionMgr, pid, unionId, soliderCfgId, soliderCount)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.gmGenSolider(pid, unionId, soliderCfgId, soliderCount)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.gmGenSolider, gg.unionMgr, pid, unionId, soliderCfgId, soliderCount)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.gmClearNFTRef(pid, unionId)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.gmClearNFTRef, gg.unionMgr, pid, unionId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.levelUpTech(pid, unionId, techCfgId)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.levelUpTech, gg.unionMgr, pid, unionId, techCfgId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.genDefenseBuild(pid, unionId, defenseCfgId, defenseCount)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.genDefenseBuild, gg.unionMgr, pid, unionId, defenseCfgId, defenseCount)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.startEditUnionArmys(pid, unionId)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.startEditUnionArmys, gg.unionMgr, pid, unionId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.starMapTakeNft(unionId, nftId, where)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.starMapTakeNft, gg.unionMgr, unionId, nftId, where)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.starMapBackNfts(unionId, nfts)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.starMapBackNfts, gg.unionMgr, unionId, nfts)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.starMapTakeDefenseBuild(pid, unionId, buildId)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.starMapTakeDefenseBuild,  gg.unionMgr, pid, unionId, buildId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1,ret2
end

function api.reduceDefenseBuildCount(unionId, buildId)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.reduceDefenseBuildCount, gg.unionMgr, unionId, buildId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1,ret2
end

function api.transferBeginGrid(pid, unionId, dstCfgId)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.transferBeginGrid, gg.unionMgr, pid, unionId, dstCfgId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.donateDaoItem(pid, unionId, contriDegree, exp)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.donateDaoItem, gg.unionMgr, pid, unionId, contriDegree, exp)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.starMapUseNftListToGrid(unionId, nftIds, where)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.starMapUseNftListToGrid, gg.unionMgr, unionId, nftIds, where)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.starMapNotUseNftListToGrid(unionId, nftIds, where)
    local ok, ret1, ret2 = gg.sync:once_do("union_"..unionId, gg.unionMgr.starMapNotUseNftListToGrid, gg.unionMgr, unionId, nftIds, where)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.getAllUnionInfo()
    return gg.unionMgr:getAllUnionInfo()
end

function api.getUnionBase(unionId)
    return gg.unionMgr:getUnionBase(unionId)
end

function api.getUnionRes(unionId, pid)
    return gg.unionMgr:getUnionRes(unionId, pid)
end

function api.isUnionResDictEnough(unionId, resDict, pid)
    return gg.unionMgr:isUnionResDictEnough(unionId, resDict, pid)
end

function api.costUnionResDict(unionId, resDict, pid)
    return gg.unionMgr:costUnionResDict(unionId, resDict, pid)
end

function api.getUnionSoliders(unionId)
    return gg.unionMgr:getUnionSoliders(unionId)
end

function api.getUnionBuilds(unionId)
    return gg.unionMgr:getUnionBuilds(unionId)
end

function api.getUnionNfts(unionId)
    return gg.unionMgr:getUnionNfts(unionId)
end

function api.getUnionMembers(unionId)
    return gg.unionMgr:getUnionMembers(unionId)
end

function api.getUnionTechs(unionId)
    return gg.unionMgr:getUnionTechs(unionId)
end

function api.getUnionApplyList(unionId)
    return gg.unionMgr:getUnionApplyList(unionId)
end

function api.getUnionCampaignIdList(unionId, pageNo, pageSize)
    return gg.unionMgr:getUnionCampaignIdList(unionId, pageNo, pageSize)
end

function api.searchUnionNameOrUnionIdLike(keyWord)
    return gg.unionMgr:searchUnionNameOrUnionIdLike(keyWord)
end

function api.sendUnionOnlineMembers(unionId, minUnionJob, cmd, ...)
    gg.unionMgr:sendUnionOnlineMembers(unionId, minUnionJob, cmd, ...)
end

function api.getUnionRankRealTimeData(count, sortKey)
    return gg.unionMgr:getUnionRankRealTimeData(count, sortKey)
end

------------------------center internal--------------------

--""
function api.takeStarmapCampaignArmy(unionId, pid, gridCfgId, unionArmys)
    return gg.unionMgr:takeStarmapCampaignArmy(unionId, pid, gridCfgId, unionArmys)
end

function api.starmapCampaignCostArmyLife(unionId, pid, fightArmy, dieSoliders)
    return gg.unionMgr:starmapCampaignCostArmyLife(unionId, pid, fightArmy, dieSoliders)
end

function api.returnBackCampaignArmy(unionId, pid, fightArmy)
    return gg.unionMgr:returnBackCampaignArmy(unionId, pid, fightArmy)
end

function api.onJoinCampaign(unionId, pid, campaignId)
    return true
end

function api.onCampaignEnd(unionId, pid, campaignId)

end

function api.onUnionCampaignUpdate(unionId, pid, battleId, campaignId, fightNftIds)
    return gg.unionMgr:onUnionCampaignUpdate(unionId, pid, battleId, campaignId, fightNftIds)
end

function api.getUnionMember(pid, unionId, memberPid)
    return gg.unionMgr:getUnionMember(unionId, memberPid)
end

--""
function api.getUnionShareInfo(pid, unionId, cfgId)
    return gg.unionMgr:getUnionShareInfo(unionId, pid, cfgId)
end

function api.getUnionBeginGridId(pid, unionId)
    return gg.unionMgr:getUnionBeginGridId(unionId, pid)
end

function api.setUnionBeginGrid(pid, unionId, beginGridId)
    return gg.unionMgr:setUnionBeginGrid(unionId, beginGridId)
end

function api.getUnionChainId(pid, unionId)
    return gg.unionMgr:getUnionChainId(unionId, pid)
end

--""
function api.personalCampaignReward(pid, unionId, gridCfgId, gridCarboxyl, resDict)
    return gg.unionMgr:personalCampaignReward(pid, unionId, gridCfgId, gridCarboxyl, resDict)
end

--""
function api.changeGridOwner(oldPid, oldUnionId, newPid, newUnionId, gridCfgId, gridCarboxyl, resDict, attackContriDict)
    return gg.unionMgr:changeGridOwner(oldPid, oldUnionId, newPid, newUnionId, gridCfgId, gridCarboxyl, resDict, attackContriDict)
end

--""
function api.unsetGridOwner(oldPid, oldUnionId, gridCfgId)
    return gg.unionMgr:unsetGridOwner(oldPid, oldUnionId, gridCfgId)
end

function api.starmapGridContribute(pid, gridCfgId, contriDegree)
    return gg.unionMgr:starmapGridContribute(pid, gridCfgId, contriDegree)
end

--""
function api.starmapGridReward(pid, unionId, gridCfgId, gridCarboxyl, nftBuilds, resDict)
    return gg.unionMgr:starmapGridReward(pid, unionId, gridCfgId, gridCarboxyl, nftBuilds, resDict)
end

function api.starmapAddGridScoreCount(pid, unionId, gridCfgId, makeScoreCount)
    return gg.unionMgr:starmapAddGridScoreCount(pid, unionId, gridCfgId, makeScoreCount)
end

function api.getPersonalGridScore(unionId)
    return gg.unionMgr:getPersonalGridScore(unionId)
end

function api.onMatchNoticeTime(matchCfgId)

end

function api.onMatchStartTime(matchCfgId)
    return gg.unionMgr:onMatchStartTime(matchCfgId)
end

function api.onMatchEndTime(matchCfgId, matchMembers)
    return gg.unionMgr:onMatchEndTime(matchCfgId, matchMembers)
end

--""
function api.distributeMatchReward(matchCfgId, rewardInfos)
    return gg.unionMgr:distributeMatchReward(matchCfgId, rewardInfos)
end

function api.starmapUnionRankReward(unionId, rank, score, matchCfgId, actCfgId)
    return gg.unionMgr:starmapUnionRankReward(unionId, rank, score, matchCfgId, actCfgId)
end

function api.onMatchRankUpdate(matchCfgId, matchMembers)
    return gg.unionMgr:onMatchRankUpdate(matchCfgId, matchMembers)
end

function api.onMatchChainRankUpdate(matchCfgId, matchMembers)
    return gg.unionMgr:onMatchChainRankUpdate(matchCfgId, matchMembers)
end

function api.getStarmapMatchRankList(matchCfgId, matchMembers)
    return gg.unionMgr:getStarmapMatchRankList(matchCfgId, matchMembers)
end

function api.getStarmapMatchChainRankList(matchCfgId, matchMembers)
    return gg.unionMgr:getStarmapMatchChainRankList(matchCfgId, matchMembers)
end

function api.delUnionOwnGrid(pid, unionId, gridCfgId)
    return gg.unionMgr:delUnionOwnGrid(pid, unionId, gridCfgId)
end

function api.matchSeasonEndHandle()
    return gg.unionMgr:matchSeasonEndHandle()
end

function api.addUnionFavoriteGrid(pid, unionId, cfgId, tag)
    return gg.unionMgr:addUnionFavoriteGrid(pid, unionId, cfgId, tag)
end

function api.delUnionFavoriteGrid(pid, unionId, cfgId)
    return gg.unionMgr:delUnionFavoriteGrid(pid, unionId, cfgId)
end

function api.getUnionFavoriteGridState(pid, unionId, inGrids)
    return gg.unionMgr:getUnionFavoriteGridState(unionId, pid, inGrids)
end

function api.getUnionFavoriteGrids(pid, unionId)
    return gg.unionMgr:getUnionFavoriteGrids(unionId, pid)
end

function api.getUnionDefenseBuild(pid, unionId, buildId)
    return gg.unionMgr:getUnionDefenseBuild(unionId, pid, buildId)
end

function api.handleStarmapMatchUnionCmd(op, opParam)
    return gg.unionMgr:handleStarmapMatchUnionCmd(op, opParam)
end

return 