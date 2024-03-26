local json = require "cjson"
local net = {}

function net.C2S_Player_EndBattle(player, args)
    local request, err = table.check(args, {
        battleId = {type="number"},
        ret = {type="number"},
        bVersion = {type="string"},
    })
    if err then
        player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    local battle = gg.battleMgr:getBattle(request.battleId)
    if not battle then
        gg.client:send(player.linkobj,"S2C_Player_EndBattle_NotCompletely", {battleId=request.battleId,code=constant.BATTLE_CODE_525})
        return
    end
    local resInfo
    local code
    if battle.battleType == constant.BATTLE_TYPE_MAIN_BASE then
        local heroIds = {}
        for k,v in pairs(battle.battleInfo.heros) do
            table.insert(heroIds, v.id)
        end

        if next(heroIds) then
            args.heroIds = heroIds
        end
        resInfo, code = player.foundationBag:endBattle(request.battleId, args)
    elseif battle.battleType == constant.BATTLE_TYPE_STAR then
        resInfo, code = player.starmapBag:endBattle(request.battleId, args)
    elseif battle.battleType == constant.BATTLE_TYPE_PVE then
        local heroIds = {}
        for k,v in pairs(battle.battleInfo.heros) do
            table.insert(heroIds, v.id)
        end
        if next(heroIds) then
            args.heroIds = heroIds
        end
        resInfo, code = player.pveBag:endBattle(request.battleId, args)
    end
    if not resInfo then
        gg.client:send(player.linkobj,"S2C_Player_EndBattle_NotCompletely", {battleId=request.battleId,code=code})
        return
    end

    -- ""
    local soliders = {}
    local temp = {} -- k：""cfgId，v：dieCount  
    -- ""cfgId""dieCount
    for k,v in pairs(request.soliders or {}) do
        temp[v.cfgId] = ( temp[v.cfgId] or 0 ) + v.dieCount
    end

    for k,v in pairs(request.soliders or {}) do
        if temp[v.cfgId] then
            v.dieCount = temp[v.cfgId]
            table.insert(soliders,v)
            temp[v.cfgId] = nil
        end
    end
    gg.client:send(player.linkobj,"S2C_Player_EndBattle", {
        battleId = request.battleId,
        starCoin = resInfo.starCoin,
        ice = resInfo.ice,
        carboxyl = resInfo.carboxyl,
        titanium = resInfo.titanium,
        gas = resInfo.gas,
        badge = resInfo.atkBadge,
        result = request.ret,
        soliders = soliders,
        battleType = battle.battleType,
        endInfo = resInfo.endInfo,
    })
    player.taskBag:update(constant.TASK_DESTORY_BUILD_TYPE_COUNT, {buildType = 1, count = args.destoryEconomyCount})
    player.taskBag:update(constant.TASK_DESTORY_BUILD_TYPE_COUNT, {buildType = 2, count = args.destoryDevelopCount})
    player.taskBag:update(constant.TASK_DESTORY_BUILD_TYPE_COUNT, {buildType = 3, count = args.destoryDefendCount})
end

function net.C2S_Player_StartBattle(player, args)
    local request, err = table.check(args, {
        battleType = {type="number"},
        enemyId = {type="number"},
    })
    if err then
        player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    local battleType = request.battleType
    local enemyId = request.enemyId
    local battleDetail
    if battleType == constant.BATTLE_TYPE_MAIN_BASE then
        battleDetail = player.foundationBag:startBattle(enemyId, args)
    elseif battleType == constant.BATTLE_TYPE_STAR then
        battleDetail = player.starmapBag:startBattle(enemyId, args)
    elseif battleType == constant.BATTLE_TYPE_PVE then
        battleDetail = player.pveBag:startBattle(enemyId, args)
    elseif battleType == constant.BATTLE_TYPE_SELF then
        battleDetail = player.foundationBag:startBattle(enemyId, args)
    elseif battleType == constant.BATTLE_TYPE_STAR_INNER then
        battleDetail = player.starmapBag:startBattle(enemyId, args)
    else
        player:say(util.i18nFormat(errors.BATTLE_TYPE_ERR))
        return
    end
    if not battleDetail then
        return
    end
    local taskData = {}
    for k,v in pairs(battleDetail.battleInfo.soliders) do
        if not taskData[v.cfgId] then
            taskData[v.cfgId] = v.cfgId
        end
    end
    player.taskBag:update(constant.TASK_SOLDIER_JOIN_BATTLE, { data = taskData })
    if battleType == constant.BATTLE_TYPE_STAR then
        player.taskBag:update(constant.TASK_STARMAP_ATTACK, {})
    end
    gg.client:send(player.linkobj,"S2C_Player_StartBattle",{
        battleId = battleDetail.battleId,
        battleInfo = battleDetail.battleInfo,
        battleType = battleDetail.battleType,
    })
end

function net.C2S_Player_LookBattlePlayBack(player,args)
    local battleId = args.battleId
    local bVersion = args.bVersion
    -- local report = player.fightReportBag:getReportByReportId(battleId)
    -- if not report then
    --     player:say(util.i18nFormat(errors.BATTLE_NOT_EXIST))
    --     return
    -- end
    local battleDetail = gg.battleMgr:lookBattlePlayerBack(battleId)
    if not battleDetail or not battleDetail.battleInfo or not battleDetail.operates then
        player:say(util.i18nFormat(errors.BATTLE_DATA_ERR))
        return
    end
    local now = gg.time.time()
    if (battleDetail.startBattleTime + constant.BATTLE_DATA_HOLE_TIME) < now then
        player:say(util.i18nFormat(errors.BATTLE_DATA_TIMEOUT))
        return
    end
    if battleDetail.bVersion ~= bVersion then
        player:say(util.i18nFormat(errors.BATTLE_DATA_TIMEOUT))
        return
    end
    if battleDetail.signinPosId <= 0 then
        player:say(util.i18nFormat(errors.BATTLE_NOT_FINISH))
        return
    end
    gg.client:send(player.linkobj,"S2C_Player_LookBattlePlayBack",{
        battleId = battleDetail.battleId,
        battleInfo = battleDetail.battleInfo,
        signinPosId = battleDetail.signinPosId,
        bVersion = battleDetail.bVersion,
        operates = battleDetail.operates,
        endStep = battleDetail.endStep,
    })
end

function net.C2S_Player_UploadBattle(player, args)
    local request, err = table.check(args, {
        battleId = {type="number"},
        signinPosId = {type="number"},
        bVersion = {type="string"},
        -- operates = {type="json"},
    })
    if err then
        player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    local battle = gg.battleMgr:getBattle(request.battleId)
    if not battle then
        -- gg.client:send(player.linkobj,"S2C_Player_EndBattle_NotCompletely", {battleId=request.battleId,code=constant.BATTLE_CODE_525})
        return
    end
    if battle.battleType ~= constant.BATTLE_TYPE_MAIN_BASE and battle.battleType ~= constant.BATTLE_TYPE_PVE then
        return
    end
    local tmpBattleId = gg.battleMgr:getIncompleteBattle(player.pid, battle.battleType)
    if not tmpBattleId then
        return
    end
    if request.battleId ~= tmpBattleId then
        return
    end
    request.endStep = 0
    local isOk, retInfo = gg.battleMgr:execIncompleteBattle(request.battleId, request)
    if not isOk then
        return
    end
    request.ret = retInfo.ret
    request.soliders = retInfo.soliders
    request.endStep = retInfo.endStep or 0
    local resInfo
    local code
    if battle.battleType == constant.BATTLE_TYPE_MAIN_BASE then
        local heroIds = {}
        for k,v in pairs(battle.battleInfo.heros) do
            table.insert(heroIds, v.id)
        end

        if next(heroIds) then
            args.heroIds = heroIds
        end
        resInfo, code = player.foundationBag:endBattle(request.battleId, request)
    elseif battle.battleType == constant.BATTLE_TYPE_STAR then
        -- resInfo, code = player.starmapBag:endBattle(request.battleId, request)
    elseif battle.battleType == constant.BATTLE_TYPE_PVE then
        local heroIds = {}
        for k,v in pairs(battle.battleInfo.heros) do
            table.insert(heroIds, v.id)
        end
        if next(heroIds) then
            args.heroIds = heroIds
        end
        resInfo, code = player.pveBag:endBattle(request.battleId, request)
    end
    if not resInfo then
        -- gg.client:send(player.linkobj,"S2C_Player_EndBattle_NotCompletely", {battleId=request.battleId,code=code})
        return
    end
end

function __hotfix(module)
    gg.client:open()
end

return net