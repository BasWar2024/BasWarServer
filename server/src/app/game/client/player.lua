local net = {}

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
    if not cfgId or not pos then
        return
    end
    local buildPos = Vector3.New(math.floor(pos.x), 0, math.floor(pos.z))
    player.buildBag:createBuild(cfgId, buildPos)
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
    local fromId = args.fromId
    local toId = args.toId
    if not fromId or not toId then
        return
    end
    player.buildBag:exchangeBuild(fromId, toId)
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

function net.C2S_Player_SpeedUp_BuildLevelUp(player,args)
    local id = args.id
    if not id then
        return
    end
    player.buildBag:speedUpLevelUpBuild(id)
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
    local cfgId = args.cfgId
    if not cfgId then
        return
    end
    local speedUp = args.speedUp
    if not speedUp then
        return
    end
    player.buildBag:mineLevelUp(cfgId,speedUp)
end

function net.C2S_Player_SpeedUp_MineLevelUp(player,args)
    local cfgId = args.cfgId
    if not cfgId then
        return
    end
    player.buildBag:speedUpMineLevelUp(cfgId)
end

function net.C2S_Player_ExpandItemBag(player, args)
    player.itemBag:expandItemBag()
end

function net.C2S_Player_DestoryItem(player, args)
    local id = args.id
    if not id then
        return
    end
    player.itemBag:delItem(id, {reason="client destroy item"})
end

function net.C2S_Player_Move2ItemBag(player, args)
    local id = args.id
    if not id then
        return
    end
    local itemType = args.itemType
    if not itemType then
        return
    end
    if itemType == constant.ITEM_WAR_SHIP then
        player.warShipBag:warShipMove2ItemBag(id)
    elseif itemType == constant.ITEM_HERO then
        player.heroBag:heroMove2ItemBag(id)
    elseif itemType == constant.ITEM_BUILD then
        player.buildBag:buildMove2ItemBag(id)
    end
end

function net.C2S_Player_MoveOutItemBag(player, args)
    local id = args.id
    if not id then
        player:say(i18n.format("argument error,no id"))
        return
    end
    local pos = args.pos
    if not pos then
        player:say(i18n.format("argument error,no pos"))
        return
    end
    local item = player.itemBag:getItem(id)
    if not item then
        player:say(i18n.format("item not exist"))
        return
    end
    if player.repairBag:isItemInRepair(id) then
        player:say(i18n.format("item is in repair"))
        return
    end
    if item.itemType == constant.ITEM_WAR_SHIP then
        player.warShipBag:warShipMoveOutItemBag(item)
    elseif item.itemType == constant.ITEM_HERO then
        player.heroBag:heroMoveOutItemBag(item)
    elseif item.itemType == constant.ITEM_BUILD then
        player.buildBag:buildMoveOutItemBag(item, pos)
    end
end

function net.C2S_Player_RemoveMess(player,args)
    local id = args.id
    if not id then
        return
    end
    player.buildBag:removeMess(id)
end

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
    player.buildBag:trainSolider(id, soliderCfgId, soliderCount)
end

function net.C2S_Player_SpeedUp_SoliderTrain(player,args)
    local id = args.id
    if not id then
        return
    end
    player.buildBag:speedUpTrainSolider(id)
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
    player.buildBag:replaceSolider(id, soliderCfgId, soliderCount)
end

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

function net.C2S_Player_SpeedUp_HeroLevelUp(player,args)
    local id = args.id
    if not id then
        return
    end
    player.heroBag:speedUpLevelUpHero(id)
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

function net.C2S_Player_SpeedUp_HeroSkillUp(player,args)
    local id = args.id
    if not id then
        return
    end
    player.heroBag:speedUpSkillUpHero(id)
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

function net.C2S_Player_SpeedUp_WarShipLevelUp(player,args)
    local id = args.id
    if not id then
        return
    end
    player.warShipBag:speedUpLevelUpWarShip(id)
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

function net.C2S_Player_SpeedUp_WarShipSkillUp(player,args)
    local id = args.id
    if not id then
        return
    end
    player.warShipBag:speedUpSkillUpWarShip(id)
end

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

function net.C2S_Player_Repair(player, args)
    if not args.ids then
        return
    end
    player.repairBag:repair(args.ids)
end

function net.C2S_Player_RepairSpeed(player, args)
    if not args.id then
        return
    end
    player.repairBag:repairSpeed(args.id)
end

function net.C2S_Player_GetRepairItems(player, args)
    -- if not args.id then
    --     return
    -- end
    player.repairBag:getRepairItems()
end

function net.C2S_Player_PickBoatRes(player, args)
    player.resPlanetBag:pickBoatRes(args.boatIds)
end

function net.C2S_Player_ResPlanetMoveBuild(player, args)
    player.resPlanetBag:moveBuild(args.index, args.buildId, args.pos)
end

function net.C2S_Player_ResPlanetBuild2ItemBag(player, args)
    if not args.index then
        return
    end
    if not args.id then
        return
    end
    player.resPlanetBag:buildMove2ItemBag(args.index, args.id)
end

function net.C2S_Player_ItemBagBuild2ResPlanet(player, args)
    if not args.index then
        return
    end
    if not args.id then
        return
    end
    if not args.pos then
        return
    end
    player.resPlanetBag:buildMove2ResPlanet(args.index, args.id, args.pos)
end

function net.C2S_Player_LookResPlanet(player, args)
    if not args.index then
        return
    end
    player.resPlanetBag:lookResPlanet(args.index)
end

function net.C2S_Player_QueryAllResPlanetBrief(player, args)
    player.resPlanetBag:queryAllResPlanetBrief()
end

function net.C2S_Player_BeginAttackResPlanet(player, args)
    if not args.index then
        return
    end
    player.resPlanetBag:beginAttackResPlanet(args.index)
end

function net.C2S_Player_EndAttackResPlanet(player, args)
    if not args.index then
        return
    end
    if not args.fightInfo then
        return
    end
    player.resPlanetBag:endAttackResPlanet(args.index, args.fightInfo)
end

function net.C2S_Player_Exchange_Rate(player, args)
    local result = gg.shareMgr:call("getMitExchangeRate")
    local data = {}
    data.mit = result.mit
    data.starCoin = result.starCoin
    data.ice = result.ice
    data.carboxyl = result.carboxyl
    data.titanium = result.titanium
    data.gas = result.gas
    gg.client:send(player.linkobj,"S2C_Player_Exchange_Rate", data)
end

function net.C2S_Player_Exchange_Res(player, args)
    local mit = args.mit
    if not mit then
        return
    end
    local cfgId = args.cfgId
    if not cfgId then
        return
    end
    player.resBag:exchangeRes(mit, cfgId)
end

function net.C2S_Player_Pledge(player, args)
    player.pledgeBag:pledge(args.cfgId, args.mit)
end

function net.C2S_Player_PledgeCancel(player, args)
    player.pledgeBag:cancel(args.cfgId)
end

function net.C2S_Player_AirwayAddFreight(player, args)
    player.airwayBag:addFreight(args.cfgId,args.freight)
end

function net.C2S_Player_AirwayClickFinish(player, args)
    player.airwayBag:clickAirwayFinish(args.cfgId)
end

function net.C2S_Player_AirwaySetWarShip(player, args)
    player.airwayBag:setWarShip(args.cfgId, args.warShipId)
end

function net.C2S_Player_AirwaySetOut(player, args)
    player.airwayBag:setOut(args.cfgId)
end

function __hotfix(module)
    gg.client:open()
end

return net