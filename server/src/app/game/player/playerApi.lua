--""player""
local cplayer = reload_class("cplayer")

function cplayer:send2Client(cmd, msg)
    gg.client:send(self.linkobj, cmd, msg)
end

--""
function cplayer:createPresetBuilds(cfgId)
    self.buildBag:createPresetBuilds(cfgId)
end

--""
function cplayer:refreshRobot()
    if self.gm == constant.ROBOT_GM_TYPE_NORMAL then
        self.pvpBag:joinMatch()
    elseif self.gm == constant.ROBOT_GM_TYPE_PVE then
        self.buildBag:_recreateGmRobotBuilds()
    end
end

-- ""gm""
function cplayer:changePlayerGm(gm)
    self.gm = gm
    if gm > 0 then
        self.gmValidTime = os.time()
    else
        self.gmValidTime = 0
    end
    local data = {pid=self.pid, gm=gm, mail=self.account, name=self.name, gmValidTime = self.gmValidTime}
    gg.mongoProxy.gm_players:update({pid=self.pid}, data, true, false)
    return data
end

--""
function cplayer:freezePlayer()
    self.banGame = true
    gg.playermgr:kick(self.pid, "FreezeAccount By Admin")
end

--""
function cplayer:unfreezePlayer()
    self.banGame = false
end

--""
function cplayer:banChat(minute)
    self.chatBag:banChat(minute)
end

--""
function cplayer:unbanChat()
    self.chatBag:unbanChat()
end

--""
function cplayer:kickPlayer(reason)
    gg.playermgr:kick(self.pid, reason)
end

function cplayer:onChatUnionMsgNew()
    self.chatBag:onChatUnionMsgNew()
end

--""
function cplayer:getBuildData()
    return self.buildBag:packBuildToBattle()
end


function cplayer:getPlayerInfo()
    return self.playerInfoBag:getPlayerInfo()
end

--""
function cplayer:getFoundationInfo()
    return self.foundationBag:getFoundationInfo()
end

function cplayer:visitFoundationInfo()
    return self.foundationBag:visitFoundationInfo()
end

--""
function cplayer:startAttacked(tick, inner, isFreeFight)
    return self.foundationBag:startAttacked(tick, inner, isFreeFight)
end

--""
function cplayer:endAttacked(result, attackerPid)
    return self.foundationBag:endAttacked(result, attackerPid)
end

--""
function cplayer:costPlayerArmyLife(costArmyInfo)
    return self.armyBag:costArmyLife(costArmyInfo)
end

--""
function cplayer:starmapCampaignCostArmyLife(armyInfo, leftSoliders)
    return self.armyBag:starmapCampaignCostArmyLife(armyInfo, leftSoliders)
end

--""
function cplayer:takeStarmapCampaignArmy(gridCfgId, personalArmys)
    return self.armyBag:takeStarmapCampaignArmy(gridCfgId, personalArmys)
end

--""
function cplayer:returnBackCampaignArmy(pid, fightArmy)
    return self.armyBag:returnBackCampaignArmy(pid, fightArmy)
end

--""
function cplayer:isPersonalUnionSoldierEnough(solidersDict)
    return self.armyBag:isPersonalUnionSoldierEnough(solidersDict)
end

--""
function cplayer:costPersonalUnionSoldier(solidersDict)
    return self.armyBag:costPersonalUnionSoldier(solidersDict)
end

--""
function cplayer:returnBackPersonalUnionSoldier(soliders)
    return self.armyBag:returnBackPersonalUnionSoldier(soliders)
end

--""
function cplayer:unionSelfBattleResult(data)
    gg.client:send(self.linkobj, "S2C_Player_UnionSelfBattleResult", data)
end

--""
function cplayer:taskStarmapAtt(data)
    return self.taskBag:update(constant.TASK_STARMAP_ATTACK, data)
end

--""
function cplayer:addFightPvpReport(report)
    return self.fightReportBag:addFightPvpReport(report)
end

function cplayer:addFightPveReport(report)
    return self.fightReportBag:addFightPveReport(report)
end

--""
function cplayer:updatePvpFightReport(battleId, result, dieSoliders, resInfo, signinPosId, bVersion)
    return self.fightReportBag:updatePvpFightReport(battleId, result, dieSoliders, resInfo, signinPosId, bVersion)
end

function cplayer:updatePveFightReport(battleId, result, dieSoliders, resInfo, signinPosId, bVersion)
    return self.fightReportBag:updatePveFightReport(battleId, result, dieSoliders, resInfo, signinPosId, bVersion)
end

--""
function cplayer:addStarmapReport(battleId, campaignId)
    return self.fightReportBag:addStarmapReport(battleId, campaignId)
end

--""
function cplayer:updateStarmapReport(report)
    return self.fightReportBag:updateStarmapReport(report)
end

--""
function cplayer:onPlayerMultiCmd(multiCmdInfos)
    for cmd, args in pairs(multiCmdInfos) do
        local func = assert(self[cmd], "cmd["..cmd.."] is not exist")
        if args and next(args) then --args""list""
            func(self, table.unpack(args))
        end
    end
end

--""
function cplayer:setPlayerBanBattle()
    return self.pvpBag:setBanBattleTick()
end

function cplayer:isResDictEnough(resDict)
    return self.resBag:enoughResDict(resDict)
end

function cplayer:costResDict(resDict, logType)
    return self.resBag:costResDict(resDict, {logType = logType})
end

-------------------------------""

--""NFT
function cplayer:useNftItemOnGrid(cfgId, buildId)
    return self.buildBag:useNftToGrid(buildId, cfgId)
end

function cplayer:useNftListToGrid(cfgId, buildIds)
    return self.buildBag:useNftListToGrid(cfgId, buildIds)
end

function cplayer:notUseNftListToGrid(cfgId, buildIds)
    return self.buildBag:notUseNftListToGrid(cfgId, buildIds)
end

function cplayer:useBuildListToGrid(cfgId, buildIds)
    return self.buildBag:useBuildListToGrid(cfgId, buildIds)
end

function cplayer:notUseBuildListToGrid(cfgId, buildIds)
    return self.buildBag:notUseBuildListToGrid(cfgId, buildIds)
end

function cplayer:getNftItemOnGrid(cfgId, buildId)
    return self.buildBag:getNftBuild(buildId)
end

function cplayer:getNftListToGrid(cfgId, buildIds)
    return self.buildBag:getNftBuildList(buildIds)
end

function cplayer:getBuildListToGrid(cfgId, buildIds)
    return self.buildBag:getBuildList(buildIds)
end

--""NFT""
function cplayer:storeNftItemInBag(cfgId, nftBuilds)
    local ret = self.buildBag:returnFromStarmapGrid(nftBuilds)
    return ret
end

function cplayer:updateBuildRefBy(builds)
    return self.buildBag:updateBuildRefBy(builds)
end

--""1""
function cplayer:onStarmapMyGridDel(cfgId)
    return self.starmapBag:onMyGridDel(cfgId)
end

--""
function cplayer:onStarmapMyGridAdd(cfgId, gridData, carboxyl, resDict)
    return self.starmapBag:onMyGridAdd(cfgId, gridData, carboxyl, resDict)
end

--""1""
function cplayer:onStarmapUnionGridDel(cfgId)
    return self.starmapBag:onUnionGridDel(cfgId)
end

--""
function cplayer:shareGridRes(cfgId, data)
    return self.starmapBag:shareGridRes(cfgId, data)
end

--""
function cplayer:starmapMatchRankReward(data)
    return self.starmapBag:starmapMatchRankReward(data)
end

-- --""
-- function cplayer:onGridCampaignBattle(battleDetail)
--     gg.client:send(self.linkobj,"S2C_Player_LookBattlePlayBack",{
--         battleId = battleDetail.battleId,
--         battleInfo = battleDetail.battleInfo,
--         signinPosId = battleDetail.signinPosId,
--         bVersion = battleDetail.bVersion,
--         operates = battleDetail.operates,
--         endStep = battleDetail.endStep,
--     })
-- end

-- --""
-- function cplayer:onGridCampaignBattleCancel(data)
--     gg.client:send(self.linkobj,"S2C_Player_StarmapBattleCancel",{
--         campaignId = data.campaignId,
--         gridCfgId = data.gridCfgId,
--         armyType = data.armyType,
--     })
-- end

--""
function cplayer:onGridCampaignBattleErr(data)
    gg.client:send(self.linkobj,"S2C_Player_EndBattle_NotCompletely", {battleId = data.battleId,code = data.code})
end

function cplayer:onGridCountInfoUpdate(info)
    return self.starmapBag:onGridCountInfoUpdate(info)
end

-----------------------""----------------------------
--""
function cplayer:onUnionJoinSucc(unionBase)
    self.unionBag:onUnionJoinSucc(unionBase)
end

function cplayer:onUnionQuitSucc(unionId)
    self.unionBag:onUnionQuitSucc(unionId)
end

function cplayer:onUnionTickedSucc(unionId)
    self.unionBag:onUnionTickedSucc(unionId)
end

--""
function cplayer:canInvitedJoinUnion()
    return self.playerInfoBag:canInvitedJoinUnion()
end

function cplayer:onInvitedJoinUnion(unionId, invite)
    self.unionBag:onInvitedJoinUnion(unionId, invite)
end

--""
function cplayer:onClearAllApplyFinish()
    self.unionBag:onClearAllApplyFinish()
end

--""
function cplayer:onUnionNewApply()
    self.unionBag:onUnionNewApply()
end

--""
function cplayer:onUnionDonate(unionId, realDonateInfo)
    return self.unionBag:onUnionDonate(unionId, realDonateInfo)
end

--""
function cplayer:onUnionDonateFinish()
    return self.unionBag:onUnionDonateFinish()
end

--""NFT
function cplayer:onUnionDonateNft(unionId, realDonateInfo)
    return self.unionBag:onUnionDonateNft(unionId, realDonateInfo)
end

--""NFT""
function cplayer:onUnionDonateNftFinish()
    return self.unionBag:onUnionDonateNftFinish()
end

--""NFT
function cplayer:onUnionTakeBackNft(unionId, idList, nftLifeDict)
    return self.unionBag:onUnionTakeBackNft(unionId, idList, nftLifeDict)
end

--""NFT""
function cplayer:onUnionTakeBackNftFinish()
    return self.unionBag:onUnionTakeBackNftFinish()
end

function cplayer:onUnionTrainSoliderFinish()
    return self.unionBag:onUnionTrainSoliderFinish()
end

function cplayer:onUnionGenDefenseBuildFinish()
    return self.unionBag:onUnionGenDefenseBuildFinish()
end

function cplayer:onUnionLevelUpTechFinish()
    return self.unionBag:onUnionLevelUpTechFinish()
end

function cplayer:onJoinUnionAnswerFinish()
    return self.unionBag:onJoinUnionAnswerFinish()
end

--""
function cplayer:onTickOutUnionFinish(unionId, tickedPid)
    return self.unionBag:onTickOutUnionFinish(unionId, tickedPid)
end

--""
function cplayer:onModifyUnionInfoFinish()
    return self.unionBag:onModifyUnionInfoFinish()
end

--""
function cplayer:onUnionJobChange(unionJob)
    return self.unionBag:onUnionJobChange(unionJob)
end

--""
function cplayer:onUnionEditJobFinish(editType, editJob, editedPlayerName)
    return self.unionBag:onUnionEditJobFinish(editType, editJob, editedPlayerName)
end

--""
function cplayer:onAddUnionFavoriteGridFinish(cfgId, tag)
    return self.unionBag:onAddUnionFavoriteGridFinish(cfgId, tag)
end

--""
function cplayer:onDelUnionFavoriteGridFinish(cfgId)
    return self.unionBag:onDelUnionFavoriteGridFinish(cfgId)
end

--""
function cplayer:checkJoinUnionCD()
    return self.unionBag:checkJoinUnionCD()
end

--""
function cplayer:onUnionCampaignUpdate(campaignId)
    return self.unionBag:onUnionCampaignUpdate(campaignId)
end

-- ""nft""
function cplayer:correctBuilds()
    return self.buildBag:correctBuilds()
end

--""nft""ref，refBy""
function cplayer:correctNftBuildData(ids)
    return self.buildBag:correctNftBuildData(ids)
end

-------------------------------
function cplayer:addPlayerMails(mailDict)
    return self.mailBag:addMyMails(mailDict)
end

function cplayer:newMailsNotice()
    return self.mailBag:newMailsNotice()
end

--""
function cplayer:getPlayerInfoByAdmin(isDetail)
    self.playerInfoBag:refreshWalletInfo()
    return self.playerInfoBag:getPlayerInfoByAdmin(isDetail)
end

--""nft"","" ""
function cplayer:correctPlayerNFT(tokenId)
    local result = {}
    local nftBuilds = self.buildBag:getNftBuilds()
    for _, build in pairs(nftBuilds) do
        if not tokenId or build.id == tokenId then
            if build.ref == constant.REF_UNION or build.ref == constant.REF_GRID then
                build.ref = constant.REF_NONE
                build.refBy = 0
                build.donateTime = 0
                build.ownerPid = 0
                table.insert(result, build.id)
            end
        end
    end

    local nftHeros = self.heroBag:getNftHeros()
    for _, hero in pairs(nftHeros) do
        if not tokenId or hero.id == tokenId then
            if hero.ref == constant.REF_UNION or hero.ref == constant.REF_GRID then
                hero.ref = constant.REF_NONE
                hero.refBy = 0
                hero.donateTime = 0
                hero.ownerPid = 0
                table.insert(result, hero.id)
            end
        end
    end

    local nftWarShips = self.warShipBag:getNftWarShips()
    for _, warShip in pairs(nftWarShips) do
        if not tokenId or warShip.id == tokenId then
            if warShip.ref == constant.REF_UNION or warShip.ref == constant.REF_GRID then
                warShip.ref = constant.REF_NONE
                warShip.refBy = 0
                warShip.donateTime = 0
                warShip.ownerPid = 0
                table.insert(result, warShip.id)
            end
        end
    end

    return result
end

--=======================""========================
function cplayer:dealRechargeToken(data)
    self.chainBridgeBag:dealRechargeToken(data)
end

function cplayer:backWithdrawToken(data)
    self.chainBridgeBag:backWithdrawToken(data)
end

function cplayer:dealRechargeNFT(data)
    self.chainBridgeBag:dealRechargeNFT(data)
end

function cplayer:dealPayOrder(data)
    self.chainBridgeBag:dealPayOrder(data)
end
--------------------------------------------
function cplayer:onPvpMatchSettlement(settleData)
    return self.pvpBag:matchSettlement(settleData)
end

return cplayer