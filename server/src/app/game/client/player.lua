local net = {}

function net.C2S_Player_SearchPlayer(player, args)
    if not args.playerId then
        return
    end
    local playerInfo = gg.playerProxy:call(args.playerId, "getPlayerInfo")
    if playerInfo then
        gg.client:send(player.linkobj, "S2C_Player_SearchPlayer", {
            playerId = args.playerId,
            playerName = playerInfo.name,
            fightPower = playerInfo.fightPower or 0,
            baseLevel = playerInfo.baseLevel or 1,
            chain = playerInfo.chain or 0,
        })
    else
        player:say(util.i18nFormat(errors.PLAYER_NOT_EXIST))
    end
end

function net.C2S_Player_LookBriefs(player,args)
    local session = args.session
    local pids = args.pids
    local briefs = {}
    for i,pid in ipairs(pids) do
        local brief = gg.briefMgr:getBrief(pid)
        if brief then
            briefs[#briefs+1] = brief
        end
    end
    gg.client:send(player.linkobj,"S2C_Player_LookBriefs",{
        session = session,
        briefs = briefs,
    })
end

function net.C2S_Player_BuildCreate(player,args)
    local cfgId = args.cfgId
    local pos = args.pos
    local opType = args.opType
    local guideNow = args.guideNow
    if not cfgId or not pos or not opType then
        return
    end
    -- local buildPos = Vector3.New(math.floor(pos.x), 0, math.floor(pos.z))
    local build = player.buildBag:createBuild(cfgId, pos, opType)
    if guideNow and build then
        player.buildBag:levelUpBuild(build.id, 1)
    end
end

function net.C2S_Player_BuildMove(player,args)
    local id = args.id
    local pos = args.pos
    if not id or not pos then
        return
    end
    local buildPos = Vector3.New(math.floor(pos.x), 0, math.floor(pos.z))
    player.buildBag:moveBuild(id, buildPos)
end

function net.C2S_Player_BuildExchange(player,args)
    -- local fromId = args.fromId
    -- local toId = args.toId
    -- if not fromId or not toId then
    --     return
    -- end
    -- player.buildBag:exchangeBuild(fromId, toId)
end

function net.C2S_Player_BuildLevelUp(player,args)
    local id = args.id
    if not id then
        return
    end
    local speedUp = args.speedUp
    if not speedUp then
        return
    end
    player.buildBag:levelUpBuild(id, speedUp)
end

function net.C2S_Player_BuildGetRes(player,args)
    local id = args.id
    if not id then
        return
    end
    player.buildBag:getBuildRes(id)
end

function net.C2S_Player_SoliderLevelUp(player,args)
    local cfgId = args.cfgId
    if not cfgId then
        return
    end
    local speedUp = args.speedUp
    if not speedUp then
        return
    end
    player.buildBag:soliderLevelUp(cfgId,speedUp)
end

function net.C2S_Player_SpeedUp_SoliderLevelUp(player,args)
    local cfgId = args.cfgId
    if not cfgId then
        return
    end
    player.buildBag:speedUpSoliderLevelUp(cfgId)
end

function net.C2S_Player_MineLevelUp(player,args)
    -- local cfgId = args.cfgId
    -- if not cfgId then
    --     return
    -- end
    -- local speedUp = args.speedUp
    -- if not speedUp then
    --     return
    -- end
    -- player.buildBag:mineLevelUp(cfgId,speedUp)
end

function net.C2S_Player_SpeedUp_MineLevelUp(player,args)
    -- local cfgId = args.cfgId
    -- if not cfgId then
    --     return
    -- end
    -- player.buildBag:speedUpMineLevelUp(cfgId)
end

function net.C2S_Player_GMBuildCreate(player,args)
    local cfgId = args.cfgId
    local pos = args.pos
    local opType = args.opType
    local guideNow = args.guideNow
    if not cfgId or not pos or not opType then
        return
    end
    -- local buildPos = Vector3.New(math.floor(pos.x), 0, math.floor(pos.z))
    local build = player.buildBag:gmCreateBuild(cfgId, pos, opType)
    if guideNow and build then
        player.buildBag:levelUpBuild(build.id, 1)
    end
end

function net.C2S_Player_GMBuildBatchCreate(player,args)
    player.buildBag:gmBatchCreateBuild(args.builds)
end

function net.C2S_Player_BuildRepair(player,args)
    local id = args.id
    if not id then
        return
    end
    player.buildBag:buildRepair(id)
end

function net.C2S_Player_RemoveMess(player,args)
    local id = args.id
    if not id then
        return
    end
    player.buildBag:removeMess(id)
end

function net.C2S_Player_ReserveArmyTrain(player,args)
    local id = args.id
    if not id then
        return
    end
    local soliderCfgId = args.soliderCfgId
    if not soliderCfgId then
        return
    end
    local soliderCount = args.soliderCount
    if not soliderCount then
        return
    end
    player.buildBag:reserveArmyTrain(id, soliderCfgId, soliderCount)
end

function net.C2S_Player_GetReserveArmy(player,args)
    if not args.id then
        return
    end
    player.buildBag:GetReserveArmy(args.id)
end

function net.C2S_Player_SpeedupReserveArmy(player,args)
    if not args.id then
        return
    end
    local soliderCfgId = args.soliderCfgId
    if not soliderCfgId then
        return
    end
    local soliderCount = args.soliderCount
    if not soliderCount then
        return
    end
    player.buildBag:SpeedupReserveArmy(args.id, soliderCfgId, soliderCount)
end

function net.C2S_Player_OneKeyTrainSoldiers(player, args)
    -- player.buildBag:oneKeyTrainSoliders(args.ids)
end

function net.C2S_Player_OneKeySpeedTrainSoldiers(player, args)
    -- player.buildBag:oneKeySpeedTrainSoliders(args.ids)
end

function net.C2S_Player_OneKeySpeedAndFullTrainSoldiers(player, args)
    -- player.buildBag:oneKeySpeedAndFullTrainSoliders(args.ids)
end

function net.C2S_Player_SoliderQualityUpgrade(player, args)
    -- player.buildBag:soliderQualityUpgrade(args.cfgId, args.speedUp or 0)
end

function net.C2S_Player_SoliderQualityUpgradeSpeed(player, args)
    -- player.buildBag:soliderQualityUpgradeSpeed(args.cfgId)
end

function net.C2S_Player_SoliderForge(player, args)
    -- player.buildBag:soliderForge(args.cfgId, args.addRatio)
end

-- ""nft build ""
function net.C2S_Player_freshBuild(player, args)
    if not args.buildId then
        return
    end
    player.buildBag:correctBuilds(args.buildId)

end

-----------------------""-----------------------------
function net.C2S_Player_QuerySanctuaryHeros(player)
    player.buildBag:querySanctuaryHeros()
end

function net.C2S_Player_UpdateSanctuaryHero(player, args)
    local  buildId = args.buildId
    if not buildId then
        return
    end
    local index = args.index
    if not index then
        return
    end
    local heroId = args.heroId
    if not heroId then
        return
    end
    player.buildBag:updateSanctuaryHero(buildId, index, heroId)
end

---------------------------------------------------
function net.C2S_Player_UseItem(player, args)
    local id = args.id
    if not id then
        return
    end
    local count = args.count
    if not count then
        return
    end
    player.itemBag:useItem(id, count)
end

function net.C2S_Player_ExpandItemBag(player, args)
    player.itemBag:expandItemBag()
end

function net.C2S_Player_ResolveItem(player, args)
    local id = args.id
    if not id then
        return
    end
    local count = args.count
    if not count then
        return
    end
    player.itemBag:resolveItem(id, count)
end

function net.C2S_Player_SellItem(player, args)
    player.itemBag:sellSkillCard(args.itemData)
end
function net.C2S_Player_DismantleSkillCard(player, args)
    player.itemBag:dismantleSkillCard(args.skillCardData)
end


---------------------------------------------------

function net.C2S_Player_SoliderTrain(player,args)
    local id = args.id
    if not id then
        return
    end
    local soliderCfgId = args.soliderCfgId
    if not soliderCfgId then
        return
    end
    local soliderCount = args.soliderCount
    if not soliderCount then
        return
    end
    local guideNow = args.guideNow
end

function net.C2S_Player_SpeedUp_SoliderTrain(player,args)
    local id = args.id
    if not id then
        return
    end
end

function net.C2S_Player_SoliderReplace(player,args)
    local id = args.id
    if not id then
        return
    end
    local soliderCfgId = args.soliderCfgId
    if not soliderCfgId then
        return
    end
    local soliderCount = args.soliderCount
    if not soliderCount then
        return
    end
end

---------------------------------------------------
function net.C2S_Player_HeroLevelUp(player,args)
    local id = args.id
    if not id then
        return
    end
    local speedUp = args.speedUp
    if not speedUp then
        return
    end
    player.heroBag:levelUpHero(id,speedUp)
end

function net.C2S_Player_HeroSkillUp(player,args)
    local id = args.id
    if not id then
        return
    end
    local skillUp = args.skillUp
    if not skillUp then
        return
    end
    local speedUp = args.speedUp
    if not speedUp then
        return
    end
    player.heroBag:heroSkillUp(id, skillUp, speedUp)
end

function net.C2S_Player_HeroSelectSkill(player,args)
    local id = args.id
    if not id then
        return
    end
    local selectSkill = args.selectSkill
    if not selectSkill then
        return
    end
    player.heroBag:heroSelectSkill(id, selectSkill)
end

function net.C2S_Player_SetUseHero(player,args)
    local id = args.id
    if not id then
        return
    end
    player.heroBag:setUseHero(id)
end

function net.C2S_Player_HeroRepair(player,args)
    local id = args.id
    if not id then
        return
    end
    player.heroBag:heroRepair(id)
end

function net.C2S_Player_HeroPutonSkill(player,args)
    if not args.id or not args.skillIndex or not args.itemCfgId then
        return
    end
    player.heroBag:heroPutonSkill(args.id, args.skillIndex, args.itemCfgId)
end

function net.C2S_Player_HeroResetSkill(player,args)
    if not args.id or not args.skillIndex then
        return
    end
    player.heroBag:heroResetSkill(args.id, args.skillIndex)
end

function net.C2S_Player_HeroForgetSkill(player,args)
    if not args.id or not args.skillIndex then
        return
    end
    player.heroBag:heroForgetSkill(args.id, args.skillIndex)
end

function net.C2S_Player_DismantleHero(player,args)
    if not args.heroIds then
        return
    end
    player.heroBag:dismantleHero(args.heroIds)
end

---------------------------------------------------
function net.C2S_Player_WarShipLevelUp(player,args)
    local id = args.id
    if not id then
        return
    end
    local speedUp = args.speedUp
    if not speedUp then
        return
    end
    player.warShipBag:levelUpWarShip(id, speedUp)
end

function net.C2S_Player_WarShipSkillUp(player,args)
    local id = args.id
    if not id then
        return
    end
    local skillUp = args.skillUp
    if not skillUp then
        return
    end
    local speedUp = args.speedUp
    if not speedUp then
        return
    end
    player.warShipBag:warShipSkillUp(id, skillUp, speedUp)
end

function net.C2S_Player_SetUseWarShip(player,args)
    local id = args.id
    if not id then
        return
    end
    player.warShipBag:setUseWarShip(id)
end

function net.C2S_Player_WarShipRepair(player,args)
    local id = args.id
    if not id then
        return
    end
    player.warShipBag:warShipRepair(id)
end

function net.C2S_Player_WarShipPutonSkill(player,args)
    if not args.id or not args.skillIndex or not args.itemCfgId then
        return
    end
    player.warShipBag:warShipPutonSkill(args.id, args.skillIndex, args.itemCfgId)
end

function net.C2S_Player_WarShipResetSkill(player,args)
    if not args.id or not args.skillIndex then
        return
    end
    player.warShipBag:warShipResetSkill(args.id, args.skillIndex)
end

function net.C2S_Player_WarShipForgetSkill(player,args)
    if not args.id or not args.skillIndex then
        return
    end
    player.warShipBag:warShipForgetSkill(args.id, args.skillIndex)
end

function net.C2S_Player_DismantleWarShip(player, args)
    player.warShipBag:dismantleWarShip(args.warShipIds)
end
---------------------------------------------------
function net.C2S_Player_ItemCompose(player, args)
    if not args.id then
        return
    end
    if not args.hour then
        return
    end
    player.itemBag:playerItemCompose(args.id, args.hour)
end

function net.C2S_Player_ItemComposeCancel(player, args)
    if not args.id then
        return
    end
    player.itemBag:playerItemComposeCancel(args.id)
end

function net.C2S_Player_ItemComposeSpeed(player, args)
    if not args.id then
        return
    end
    player.itemBag:playerItemComposeSpeed(args.id)
end

---------------------------------------------------
function net.C2S_Player_Exchange_Rate(player, args)
    player.resBag:sendResExchangeRate(args.tipType)
end

function net.C2S_Player_Exchange_Res(player, args)
    local from = args.from
    if not from then
        return
    end
    local fromCount = args.fromCount
    if not fromCount then
        return
    end
    local to = args.to
    if not to then
        return
    end
    player.resBag:exchangeRes(from, fromCount, to)
end


function net.C2S_Player_Rank_Info(player, args)
    local rankType = args.rankType
    if not rankType then
        return
    end
    local version = args.version
    if not version then
        return
    end
    local ret = nil
    local rankKey = constant.RANK_TYPE_TO_RANK_KEY[rankType]
    if not rankKey then
        return
    end
    if constant.RANK_REFRESH_RANK_KEY[rankKey] then
        ret = gg.rankProxy:getRankList(rankKey, player.pid, version)
    elseif constant.RANK_REFRESH_UNION_RANK_KEY[rankKey] then
        ret = player.unionBag:queryUnionRank(rankKey, player.pid, version)
    end
    if ret then
        gg.client:send(player.linkobj,"S2C_Player_Rank_Info", ret)
    end
end

function net.C2S_Player_QueryFightReports(player, args)
    if not args.battleType then
        return
    end
    player.fightReportBag:queryFightReports(args.battleType)
end

function net.C2S_Player_QueryStarmapCampaignReports(player, args)
    if not args.pageNo or not args.pageSize then
        return
    end
    if args.pageNo <= 0 or args.pageSize <= 0 then
        return
    end
    player.fightReportBag:queryStarmapCampaignReports(args.pageNo, args.pageSize)
end

function net.C2S_Player_QueryStarmapBattleReports(player, args)
    if not args.campaignId or not args.pageNo or not args.pageSize then
        return
    end
    if args.campaignId <= 0 or args.pageNo <= 0 or args.pageSize <= 0 then
        return
    end
    player.fightReportBag:queryStarmapBattleReports(args.campaignId, args.pageNo, args.pageSize)
end

function net.C2S_Player_QueryPvpPlayers(player, args)
    player.pvpBag:queryPlayers()
end

function net.C2S_Player_ChangePvpPlayers(player, args)
    player.pvpBag:changePlayers()
end

function net.C2S_Player_PvpScoutFoundation(player, args)
    player.pvpBag:scoutFoundation(args.playerId)
end

function net.C2S_Player_AddPvpBattleNum(player)
    player.pvpBag:addBattleNum()
end

function net.C2S_Player_queryGmRobotPlayers(player, args)
    -- player.pveBag:queryGmRobotPlayers()
end

function net.C2S_Player_PVEScoutFoundation(player, args)
    player.pveBag:scoutFoundation(args.cfgId)
end

function net.C2S_Player_PVERecvDailyRewards(player, args)
    player.pveBag:receiveDailyRewards(args.cfgId)
end

function net.C2S_Player_DrawAchievement(player, args)
    player.achievementBag:drawAchievement(args.index)
end

function net.C2S_Player_GetArmysAvailableHeros(player)
    player.armyBag:getArmysAvailableHeros()
end

function net.C2S_Player_ArmyFormationUpdate(player,args)
    local armyId = args.armyId
    if not armyId then
        return
    end
    local index = args.index
    if not index then
        return
    end
    local armyName = args.armyName
    local teams = args.teams
    if not teams then
        return
    end
    player.armyBag:updateArmy(armyId, index, teams, armyName)
end

function net.C2S_Player_CleanAllArmy(player)
    player.armyBag:cleanAllArmy()
end

function net.C2S_Player_ArmyFormationAdd(player,args)
    local armyId = args.armyId
    if not armyId then
        player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    local armyName = args.armyName
    local teams = args.teams
    player.armyBag:addArmys(armyId, armyName, teams)
end

function net.C2S_Player_ArmyFormationQuery(player)
    player.armyBag:queryArmys()
end

function net.C2S_Player_ArmyFormationDelete(player, args)
    local armyId = args.armyId
    if not armyId then
        player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    player.armyBag:deleteArmys(armyId)
end

function net.C2S_Player_AddGuildReserveCount(player, args)
    local guildReserveCount = args.guildReserveCount
    if guildReserveCount <= 0 then
        return
    end
    player.armyBag:addGuildReserveCount(guildReserveCount)
end

function net.C2S_Player_IsUseGuidArmy(player, args)
    local isUseGuidArmy = args.isUseGuidArmy
    if isUseGuidArmy ~= 0 and isUseGuidArmy ~= 1 then
        return
    end
    player.armyBag:setIsUseGuidArmy(isUseGuidArmy)
end

-- ""
function net.C2S_Player_CreateUnion(player, args)
    player.unionBag:createUnion(args)
end

function net.C2S_Player_JoinUnion(player, args)
    player.unionBag:joinUnion(args.unionId)
end

function net.C2S_Player_SearchUnion(player, args)
    player.unionBag:searchUnion(args.keyWord)
end

function net.C2S_Player_JoinUnionAnswer(player, args)
    player.unionBag:joinUnionAnswer(args.unionId, args.playerId, args.answer)
end

function net.C2S_Player_InviteJoinUnion(player, args)
    player.unionBag:inviteJoinUnion(args.unionId, args.playerId)
end

function net.C2S_Player_AnswerUnionInvite(player, args)
    player.unionBag:answerUnionInvite(args.unionId, args.answer)
end

function net.C2S_Player_ModifyUnionInfo(player, args)
    player.unionBag:modifyUnionInfo(args.unionId, args)
end

function net.C2S_Player_QuitUnion(player, args)
    player.unionBag:quitUnion(args.unionId)
end

function net.C2S_Player_TickOutUnion(player, args)
    player.unionBag:tickOutUnion(args.unionId, args.playerId)
end

function net.C2S_Player_EditUnionJob(player, args)
    player.unionBag:editUnionJob(args.unionId, args.playerId, args.unionJob, args.editType)
end

function net.C2S_Player_GetUnionInviteList(player, args)
    player.unionBag:getInviteList()
end

function net.C2S_Player_QueryMyUnionInfo(player, args)
    player.unionBag:queryMyUnionInfo()
end

function net.C2S_Player_QueryUnionBaseInfo(player, args)
    local unionId = args.unionId
    if not unionId then
        return
    end
    player.unionBag:queryUnionBaseInfo(unionId)
end

function net.C2S_Player_GetUnionApplyList(player, args)
    player.unionBag:getUnionApplyList(args.unionId)
end

function net.C2S_Player_UnionDonate(player, args)
    player.unionBag:donate(args.unionId, args)
end

function net.C2S_Player_UnionDonateNft(player, args)
    player.unionBag:donateNft(args.unionId, args.idList)
end

function net.C2S_Player_UnionTakeBackNft(player, args)
    player.unionBag:takeBackNft(args.unionId, args.idList)
end

function net.C2S_Player_UnionTrainSolider(player, args)
    player.unionBag:trainSolider(args.unionId, args.cfgId, args.count)
end

function net.C2S_Player_UnionTechLevelUp(player, args)
    player.unionBag:levelUpTech(args.unionId, args.cfgId)
end

function net.C2S_Player_UnionGenBuild(player, args)
    player.unionBag:genDefenseBuild(args.unionId, args.cfgId, args.count)
end

function net.C2S_Player_UnionClearAllApply(player, args)
    player.unionBag:unionClearAllApply()
end

function net.C2S_Player_StartEditUnionArmys(player, args)
    player.unionBag:startEditUnionArmys(args.unionId)
end

function net.C2S_Player_QueryUnionStarmapCampaignReports(player, args)
    if not args.pageNo or not args.pageSize then
        return
    end
    if args.pageNo <= 0 or args.pageSize <= 0 then
        return
    end
    args.pageSize = 5
    player.unionBag:queryUnionStarmapCampaignReports(args.pageNo, args.pageSize)
end

function net.C2S_Player_QueryUnionStarmapBattleReports(player, args)
    if not args.campaignId or not args.pageNo or not args.pageSize then
        return
    end
    if args.campaignId <= 0 or args.pageNo <= 0 or args.pageSize <= 0 then
        return
    end
    args.pageSize = 5
    player.unionBag:queryUnionStarmapBattleReports(args.campaignId, args.pageNo, args.pageSize)
end

function net.C2S_Player_QueryStarmapCampaignPlyStatistics(player, args)
    if not args.campaignId then
        return
    end
    if args.campaignId <= 0 then
        return
    end
    player.unionBag:queryStarmapCampaignPlyStatistics(args.campaignId)
end

function net.C2S_Player_QueryJoinableUnionList(player, args)
    player.unionBag:queryJoinableUnionList()
end

function net.C2S_Player_QueryUnionRes(player, args)
    player.unionBag:queryUnionRes()
end

function net.C2S_Player_QueryUnionSoliders(player, args)
    player.unionBag:queryUnionSoliders()
end

function net.C2S_Player_QueryUnionBuilds(player, args)
    player.unionBag:queryUnionBuilds()
end

function net.C2S_Player_QueryUnionNfts(player, args)
    player.unionBag:queryUnionNfts(true)
end

function net.C2S_Player_QueryUnionMembers(player, args)
    player.unionBag:queryUnionMembers()
end

function net.C2S_Player_QueryUnionTechs(player, args)
    player.unionBag:queryUnionTechs()
end

function net.C2S_Player_UnionVisitFoundation(player, args)
    player.unionBag:visitFoundation(args.playerId)
end

function net.C2S_Player_StarmapMatchRank(player, args)
    player.unionBag:getUnionMatchRank(args.matchType, args.unionChain)
end

function net.C2S_Player_GetMints(player, args)
    player.unionBag:getMints()
end

function net.C2S_Player_AddMint(player, args)
    if not args.nftId1 or not args.nftId2 or not args.nftType then
        return
    end
    player.unionBag:addMint(args.nftId1, args.nftId2, args.nftType)
end

function net.C2S_Player_ReceiveMintItem(player, args)
    if not args.index then
        return
    end
    player.unionBag:receiveMintItem(args.index)
end

function net.C2S_Player_GetStarmapScore(player, args)
    player.unionBag:getStarmapScore()
end

function net.C2S_Player_DonateDaoItem(player, args)
    if not args.id or not args.count then
        return
    end
    if args.count <= 0 then
        return
    end
    player.unionBag:donateDaoItem(args.id, args.count)
end

function net.C2S_Player_QueryStarmapHyJackpot(player, args)
    player.unionBag:queryStarmapHyJackpot()
end


--------------------------""end----------------


function net.C2S_Player_SendChatMsg(player, args)
    player.chatBag:sendChatMsg(args.channelType, args.text, args.hasHyperLink)
end

function net.C2S_Player_QueryChatMsgs(player, args)
    player.chatBag:queryChatMsgs(args.channelType, args.cMsgId)
end

function net.C2S_Player_DrawTask(player, args)
    player.taskBag:receiveTaskRewards(args.index)
end

function net.C2S_Player_DrawChapterTask(player, args)
    player.taskBag:receiveChapterRewards()
end

function net.C2S_Player_DrawTaskActivation(player, args)
    player.taskBag:receiveActivationRewards(args.cfgId)
end




function net.C2S_Player_QueryPlayerInfo(player, args)
    player.playerInfoBag:queryPlayerInfo()
end

function net.C2S_Player_ModifyPlayerName(player, args)
    player.playerInfoBag:modifyPlayerName(args.name)
end

function net.C2S_Player_ModifyPlayerLanguage(player, args)
    player.playerInfoBag:modifyPlayerLanguage(args.language)
end

function net.C2S_Player_ModifyPlayerInfo(player, args)
    player.playerInfoBag:modifyPlayerInfo(args)
end

function net.C2S_Player_ChatVisitFoundation(player, args)
    player.chatBag:visitFoundation(args.playerId)
end



--------------------------------------------------""
function net.C2S_Player_GetMail(player, args)
    if not args.id then
        return
    end
    player.mailBag:getMail(args.id)
end

function net.C2S_Player_DelMail(player, args)
    if not args.id then
        return
    end
    player.mailBag:delMail(args.id)
end

function net.C2S_Player_OneKeyDelMails(player, args)
    player.mailBag:oneKeyDelMails()
end

function net.C2S_Player_OneKeyReadMails(player, args)
    player.mailBag:oneKeyReadMails()
end

function net.C2S_Player_ReceiveMailAttach(player, args)
    if not args.id then
        return
    end
    player.mailBag:receiveMailAttach(args.id)
end
----------------------------------------------------
function net.C2S_Player_finishGuides(player, args)
    -- args == {guides = {{guideId=1}, {guideId=2}}}
    local guides = args.guides
    if not guides then
        return
    end
    player.guideBag:checkFinish(guides)
end

function net.C2S_Player_BuyBattleNum(player, args)
    if not args.battleNum then
        return
    end
    player.pvpBag:addBattleNum(args.battleNum)    
end

function net.C2S_Player_QueryWallet(player, args)
    player.playerInfoBag:refreshWalletInfo()
    player.playerInfoBag:queryWallet()
end

function net.C2S_Player_ReapGuideRes(player, args)
    local id = args.id
    local resId = args.resId
    if not id or not resId then
        return
    end
    if resId == constant.RES_ICE then
        player.guideBag:reapGuideIce(id)
    elseif resId == constant.RES_STARCOIN then
        player.guideBag:reapGuideStarCoin(id)
    end
end
---------------------------------------------------

function net.C2S_Player_enterStarmap(player, args)
    player.starmapBag:notifyChainExclusiveGrids()
    player.starmapBag:enterStarmap(args.gridCfgIds)
end

function net.C2S_Player_leaveStarmap(player, args)
    player.starmapBag:leaveStarmap()
end

function net.C2S_Player_scoutStarmapGrid(player, args)
    player.starmapBag:scoutGrid(args.cfgId)
end

function net.C2S_Player_putBuildOnGrid(player, args)
    player.starmapBag:putBuildOnGrid(args.cfgId, args.buildId, args.pos)
end

function net.C2S_Player_PutUnionBuildOnGrid(player, args)
    local cfgId = args.cfgId
    local buildId = args.buildId
    local pos = args.pos
    if not cfgId or not buildId or not pos then
        return
    end
    player.starmapBag:addDefenseBuildOnGrid(cfgId, buildId, pos)
end

function net.C2S_Player_putBuildListOnGrid(player, args)
    local cfgId = args.cfgId
    local buildList = args.buildList
    local from = args.from
    if not cfgId or not buildList or not from then
        return
    end
    player.starmapBag:putBuildListOnGrid(cfgId, buildList, from)
end

function net.C2S_Player_moveBuildOnGrid(player, args)
    player.starmapBag:moveBuildOnGrid(args.cfgId, args.buildId, args.pos)
end

function net.C2S_Player_delBuildOnGrid(player, args)
    player.starmapBag:delBuildOnGrid(args.cfgId, args.buildId)
end

function net.C2S_Player_storeBuildOnGrid(player, args)
    player.starmapBag:storeBuildOnGrid(args.cfgId, args.buildId)
end

function net.C2S_Player_GetMyGirdList(player, args)
    player.starmapBag:getMyGridList()
end

function net.C2S_Player_GetMyFavoriteGridList(player, args)
    player.starmapBag:getMyFavoriteGridList()
end

function net.C2S_Player_GetUnionFavoriteGridList(player, args)
    player.starmapBag:getUnionFavoriteGridList()
end

function net.C2S_Player_AddMyFavoriteGrid(player, args)
    if not args.cfgId or not args.tag then
        return
    end
    player.starmapBag:addMyFavoriteGrid(args.cfgId, args.tag)
end

function net.C2S_Player_DelMyFavoriteGrid(player, args)
    player.starmapBag:delMyFavoriteGrid(args.cfgId)
end

function net.C2S_Player_AddUnionFavoriteGrid(player, args)
    if not args.cfgId or not args.tag then
        return
    end
    player.starmapBag:addUnionFavoriteGrid(args.cfgId, args.tag)
end

function net.C2S_Player_DelUnionFavoriteGrid(player, args)
    player.starmapBag:delUnionFavoriteGrid(args.cfgId)
end

function net.C2S_Player_GiveUpMyGrid(player, args)
    player.starmapBag:giveUpMyGrid(args.cfgId)
end

function net.C2S_Player_GiftWithMyGrid(player, args)
   player.starmapBag:giftWithMyGrid(args.cfgId, args.playerId)
end

function net.C2S_Player_GetMyStarmapRewardList(player, args)
    player.starmapBag:getMyStarmapRewardList()
end

function net.C2S_Player_DrawMyStarmapReward(player)
    player.starmapBag:drawMyStarmapReward()
end

function net.C2S_Player_subscribeGrids(player, args)
    player.starmapBag:subscribeGrids(args.cfgIds)
end

function net.C2S_Player_unsubscribeGrids(player, args)
    player.starmapBag:unsubscribeGrids(args.cfgIds)
end

function net.C2S_Player_StarmapMatchUnionGrids(player, args)
    player.starmapBag:getStarmapMatchUnionGrids()
end

function net.C2S_Player_StarmapMatchPersonalGrids(player, args)
    player.starmapBag:getStarmapMatchPersonalGrids()
end

function net.C2S_Player_StarmapTransferBeginGrid(player, args)
    if not args.cfgId then
        return
    end
    player.starmapBag:transferBeginGrid(args.cfgId)
end

function net.C2S_Player_StarmapMinimap(player, args)
    player.starmapBag:minimap()
end
--TODO: movo to activity bag
function net.C2S_Player_FirstGetGridRank(player, args)
    player.starmapBag:firstGetGridRank()
end

------------------------------------------------------------
function net.C2S_Player_LaunchToBridge(player, args)
    local chainId = args.chainId
    local warShipId = args.warShipId
    local mit = args.mit
    local hyt = args.hyt
    local tokenIds = args.tokenIds
    local tokenKinds = args.tokenKinds
    if not chainId and not warShipId and not mit or not hyt or not tokenIds or not tokenKinds then
        return
    end
    local entityNfts = {}
    local itemNfts = {}
    for i, tokenId in pairs(tokenIds) do
        local tokenKind = tokenKinds[i]
        if not tokenKind then
            return
        end
        if constant.CHAIN_BRIDGE_ENTITY_NFT[tokenKind] then
            entityNfts[tokenId] = tokenKind
        elseif constant.CHAIN_BRIDGE_ITEM_NFT[tokenKind] then
            itemNfts[tokenId] = tokenKind
        else
            player:say(util.i18nFormat(errors.ARG_ERR))
            return
        end
    end
    player.chainBridgeBag:launchToBridge(chainId, warShipId, mit, hyt, entityNfts, itemNfts)
end

function net.C2S_Player_ChainBridgeInfo(player, args)
    local result = gg.shareProxy:call("getChainBridgeInfo")
    local chains = {}
    for k, v in pairs(result) do
        table.insert(chains, { chainId = math.floor(tonumber(v.chainId)), chainName = v.chainName, open = math.floor(tonumber(v.open)) })
    end
    gg.client:send(player.linkobj,"S2C_Player_ChainBridgeInfo", { chains = chains })
end

function net.C2S_Player_GetLaunchBridgeRecrods(player, args)
    player.chainBridgeBag:getLaunchBridgeRecrods()
end

--------------------------------------------------
function net.C2S_Player_ResetGOLevel(player, args)
    player.editorBag:gameObjectOp(args)
end

function net.C2S_Player_GOChangeSkill(player, args)
    player.editorBag:gameObjectChangeSkill(args)
end

function net.C2S_Player_OPLandShipSoldier(player, args)
    player.editorBag:opLandShipSoldier(args)
end

function net.C2S_Player_OPMoveBuild(player,args)
    player.editorBag:OPMoveBuild(args)
end

function net.C2S_Player_EditedArmyFormation(player, args)
    player.editorBag:editedArmyFormation(args)
end

function net.C2S_Player_automaticForces(player, args)
    local autoStatus = args.autoStatus
    player.armyBag:updateAutomatic(autoStatus)
end
function net.C2S_Player_OneKeyFillUpSoliders(player, args)
    player.armyBag:oneKeyFillUpSoliders(args.armyIds)
end
--------------------------------------------------
function net.C2S_Player_Draw_Card(player, args)
    if not args.cfgId or not args.drawCount then
        return
    end
    player.drawCardBag:drawCard(args.cfgId, args.drawCount)
end

function net.C2S_Player_GetDrawCardRecord(player, args)
    player.drawCardBag:getDrawCardRecord()
end



-- ""
function net.C2S_Player_GetCumulativeFunds(player, args)
    local cfgId = args.cfgId
    if not cfgId then
        return
    end
    player.rechargeActivityBag:getFundsReward(cfgId)
end

function net.C2S_Player_GetRechargeReward(player, args)
    local giftCfgId = args.giftCfgId
    if not giftCfgId then
        return
    end
    player.rechargeActivityBag:getFirstOrRechargeReward(giftCfgId)
end

function net.C2S_Player_BuyMoreBuilder(player, args)
    local cfgId = args.cfgId
    if not cfgId then
        return
    end
    player.rechargeActivityBag:addBuildQueueTime(cfgId)
end

function net.C2S_Player_GetDailyReward(player, args)
    player.rechargeActivityBag:getDailyCheckReward(args.weekDay)
end

function net.C2S_Player_FreshShoppingMall(player)
    player.rechargeActivityBag:freshShoppingMall()
end

function net.C2S_Player_BuyGoods(player, args)
    player.rechargeActivityBag:buyGoodsByTesseract(args.index)
end

function net.C2S_Player_GetLoginActReward(player, args)
    player.rechargeActivityBag:getLoginActDayReward(args.day)
end

function net.C2S_Player_UnlockLoginAdv(player, args)
    player.rechargeActivityBag:unLockLoginActAdv(args.day)
end

-- "" end

function net.C2S_Player_PayChannelInfo(player, args)
    local platform = args.platform
    if not platform then
        return
    end
    if platform == constant.PLATFORM_4 or platform == constant.PLATFORM_5 then
        return
    end

    local info = gg.dynamicCfg:get(constant.REDIS_PAY_CHANNEL_INFO)
    local data = {}
    for k,v in pairs(info) do
        if v.status == "open" and k ~= constant.PAYCHANNEL_APPSTORE and k ~= constant.PAYCHANNEL_GOOGLEPLAY then
            local vv = {}
            vv.name = v.name
            vv.currency = v.currency
            vv.payType = {}
            for nk, nv in pairs(v.payType or {}) do
                if nv.status == "open" then
                    vv.payType[nk] = nv
                end
            end
            data[k] = vv
        end
    end

    gg.client:send(player.linkobj, "S2C_Player_PayChannelInfo", { info = cjson.encode(data) })
end

function net.C2S_Player_UseGiftCode(player, args)
    local code = args.code
    if not code then
        return
    end
    player.giftBag:useGiftCode(code)
end

function net.C2S_Player_AutoPushStatus_Del(player, args)
    local autoPushCfgId = args.autoPushCfgId
    if not autoPushCfgId then
        return
    end
    player.autoPushBag:delAutoPushStatus(autoPushCfgId)
end

function net.C2S_Player_SellEntity(player, args)
    local sellType = args.type
    local idList = args.idList
    if sellType == 1 then  -- 1.""，2.""，3.""
        player.heroBag:sellHero(idList)
    elseif sellType == 2 then
        player.buildBag:sellBuild(idList)
    elseif sellType == 3 then
        player.warShipBag:sellWarShip(idList)
    end
end

function __hotfix(module)
    gg.client:open()
end

return net