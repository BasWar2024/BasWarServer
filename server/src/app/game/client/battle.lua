local json = require "cjson"

local function getBulletCfg(cfgId)
    local bulletCfg = cfg.get("etc.cfg.bullet")
    for k,v in pairs(bulletCfg) do
        if v.cfgId == cfgId then
            return v
        end
    end
    return nil
end

local function getBuffCfg(cfgId)
    local buffCfg = cfg.get("etc.cfg.buff")
    for k,v in pairs(buffCfg) do
        if v.cfgId == cfgId then
            return v
        end
    end
    return nil
end

local function getBuildingList(builds)
    local buildList = {}
    local i = 1
    for k,v in pairs(builds) do
        if v.cfgId < 1400000 and v.cfgId ~= 1207001 and v.cfgId ~= 1201001 then --1500000 1400000
            local buildCfg = ggclass.Build.getBuildCfg(v.cfgId, v.quality, v.level)
            local build = {}
            build.cfgId = v.cfgId
            build.model = buildCfg.model
            build.wreckageModel = buildCfg.wreckageModel
            build.explosionEffect = buildCfg.explosionEffect
            build.x = v.x
            build.z = v.z
            build.maxHp = buildCfg.maxHp
            build.atk = buildCfg.atk
            build.atkSpeed = buildCfg.atkSpeed
            build.atkRange = buildCfg.atkRange
            build.radius = buildCfg.radius
            build.atkAir = buildCfg.atkAir
            build.bulletCfgId = buildCfg.bulletCfgId
            if v.cfgId == 1001001 then
                build.isMain = 1
            else
                build.isMain = 0
            end
            build.type = buildCfg.type
            buildList[i] = build
            i = i + 1
        end
    end

    return buildList
end

local function getTrapList(builds)
    local trapList = {}
    local i = 1
    for k,v in pairs(builds) do
        if v.cfgId >= 1400000 and v.cfgId < 1500000 then --1400000 ~ 1499999
            local buildCfg = ggclass.Build.getBuildCfg(v.cfgId, v.quality, v.level)
            local trap = {}
            trap.cfgId = v.cfgId
            trap.model = buildCfg.model
            trap.explosionEffect = buildCfg.explosionEffect
            trap.x = v.x
            trap.z = v.z
            trap.buffCfgId = buildCfg.buffCfgId
            trap.alertRange = buildCfg.alertRange
            trap.atkRange = buildCfg.atkRange
            trap.radius = buildCfg.radius
            trap.delayExplosionTime = buildCfg.delayExplosionTime
            trapList[i] = trap
            i = i + 1
        end
    end

    return trapList
end

local function getSoliderList(soliders)
    local soliderList = {}
    local i = 1
    for k,v in pairs(soliders) do
        local soliderCfg = ggclass.SoliderLevel.getSoliderCfg(v.cfgId, v.level)
        local solider = {}
        solider.cfgId = v.cfgId
        solider.uuid = v.id
        solider.model = soliderCfg.model
        solider.icon = soliderCfg.icon
        solider.amount = v.count
        solider.moveSpeed = soliderCfg.moveSpeed
        solider.maxHp = soliderCfg.maxHp
        solider.atk = soliderCfg.atk
        solider.atkSpeed = soliderCfg.atkSpeed
        solider.atkRange = soliderCfg.atkRange
        solider.radius = soliderCfg.radius
        solider.originCost = soliderCfg.originCost
        solider.addCost = soliderCfg.addCost
        solider.bulletCfgId = soliderCfg.bulletCfgId
        solider.flashMoveDelayTime = soliderCfg.flashMoveDelayTime
        solider.type = soliderCfg.type
        soliderList[i] = solider
        i = i + 1
    end

    return soliderList
end

local function getHero(mainHero)
    if next(mainHero) == nil then
        return nil
    end

    local hero = {}
    local heroCfg = ggclass.Hero.getHeroCfg(mainHero.cfgId, mainHero.quality, mainHero.level)
    hero.cfgId = mainHero.cfgId
    hero.model = heroCfg.model
    hero.icon = heroCfg.icon
    hero.moveSpeed = heroCfg.moveSpeed
    hero.maxHp = heroCfg.maxHp
    hero.atk = heroCfg.atk
    hero.atkSpeed = heroCfg.atkSpeed
    hero.atkRange = heroCfg.atkRange
    hero.radius = heroCfg.radius
    hero.flashMoveDelayTime = heroCfg.flashMoveDelayTime
    hero.bulletCfgId = heroCfg.bulletCfgId
    return hero
end

local function getMainShip(mainWarShip)
    local mainShip = {}
    local mainShipCfg = ggclass.WarShip.getWarShipCfg(mainWarShip.cfgId, mainWarShip.quality, mainWarShip.level)
    mainShip.cfgId = mainWarShip.cfgId
    mainShip.model = mainShipCfg.model
    mainShip.skillPoint = mainShipCfg.skillPoint
    return mainShip
end

local function getSkill(skillCfg)

    if skillCfg == nil then
        return
    end

    local skill = {}
    skill.cfgId = skillCfg.cfgId
    skill.model = skillCfg.model
    skill.icon = skillCfg.icon
    skill.effectModel = skillCfg.effectModel
    skill.buffCfgId = skillCfg.buffCfgId
    skill.moveSpeed = skillCfg.moveSpeed
    skill.lifeTime = skillCfg.lifeTime
    skill.frequency = skillCfg.frequency
    skill.range = skillCfg.range
    skill.originCost = skillCfg.originCost
    skill.addCost = skillCfg.addCost
    skill.followSelf = skillCfg.followSelf
    skill.type = skillCfg.type
    return skill
end

local function getSkillList(mainWarShip)
    local skillList = {}
    local skill1Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill1, mainWarShip.skillLevel1)
    local skill2Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill2, mainWarShip.skillLevel2)
    local skill3Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill3, mainWarShip.skillLevel3)
    local skill4Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill4, mainWarShip.skillLevel4)
    local skill5Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill5, mainWarShip.skillLevel5)

    local skill1 = getSkill(skill1Cfg)
    local skill2 = getSkill(skill2Cfg)
    local skill3 = getSkill(skill3Cfg)
    local skill4 = getSkill(skill4Cfg)
    local skill5 = getSkill(skill5Cfg)

    skillList[1] = skill1
    skillList[2] = skill2
    skillList[3] = skill3
    skillList[4] = skill4
    skillList[5] = skill5

    return skillList
end

local function getHeroSkill(mainHero)
    local heroSkill = {}

    local skillCfgId = nil
    local skillLevel = nil
    if mainHero.selectSkill == 1 then
        skillCfgId = mainHero.skill1
        skillLevel = mainHero.skillLevel1
    elseif mainHero.selectSkill == 2 then
        skillCfgId = mainHero.skill2
        skillLevel = mainHero.skillLevel2
    else
        skillCfgId = mainHero.skill3
        skillLevel = mainHero.skillLevel3
    end

    local heroCfg = ggclass.Hero.getHeroSkillCfg(skillCfgId, skillLevel)
    heroSkill.cfgId = mainHero.cfgId
    heroSkill.model = heroCfg.model
    heroSkill.icon = heroCfg.icon
    heroSkill.effectModel = heroCfg.effectModel
    heroSkill.buffCfgId = heroCfg.buffCfgId
    heroSkill.moveSpeed = heroCfg.moveSpeed
    heroSkill.lifeTime = heroCfg.lifeTime
    heroSkill.frequency = heroCfg.frequency
    heroSkill.range = heroCfg.range
    heroSkill.originCost = heroCfg.originCost
    heroSkill.addCost = heroCfg.addCost
    heroSkill.followSelf = heroCfg.followSelf
    heroSkill.type = heroCfg.type

    return heroSkill
end

local function getBulletList(buildingList, soliderList, hero)
    local bulletList = {}
    local i = 1
    for k,v in pairs(buildingList) do
        if v.bulletCfgId ~= nil and v.bulletCfgId ~= 0 then
            local bulletCfg = getBulletCfg(v.bulletCfgId)
            local bullet = {}
            bullet.cfgId = v.bulletCfgId
            bullet.model = bulletCfg.model
            bullet.explosionEffect = bulletCfg.explosionEffect
            bullet.type = bulletCfg.type
            bullet.moveSpeed = bulletCfg.moveSpeed
            bullet.atkRange = bulletCfg.atkRange
            bulletList[i] = bullet
            i = i + 1
        end
    end

    for k,v in pairs(soliderList) do
        if v.bulletCfgId ~= nil and v.bulletCfgId ~= 0 then
            local bulletCfg = getBulletCfg(v.bulletCfgId)
            local bullet = {}
            bullet.cfgId = v.bulletCfgId
            bullet.model = bulletCfg.model
            bullet.explosionEffect = bulletCfg.explosionEffect
            bullet.type = bulletCfg.type
            bullet.moveSpeed = bulletCfg.moveSpeed
            bullet.atkRange = bulletCfg.atkRange
            bulletList[i] = bullet
            i = i + 1
        end
    end

    if hero.bulletCfgId ~= nil and hero.bulletCfgId ~= 0 then
        local bulletCfg = getBulletCfg(hero.bulletCfgId)
        local bullet = {}
        bullet.cfgId = hero.bulletCfgId
        bullet.model = bulletCfg.model
        bullet.explosionEffect = bulletCfg.explosionEffect
        bullet.type = bulletCfg.type
        bullet.moveSpeed = bulletCfg.moveSpeed
        bullet.atkRange = bulletCfg.atkRange
        bulletList[i] = bullet
    end

    return bulletList
end

local function getBuffList(trapList, skillList, heroSkill)
    local buffList = {}
    local i = 1
    for k,v in pairs(trapList) do
        if v.buffCfgId ~= nil and v.buffCfgId ~= 0 then
            local buffCfg = getBuffCfg(v.buffCfgId)
            local buff = {}
            buff.cfgId = v.buffCfgId
            buff.model = buffCfg.model
            buff.atk = buffCfg.atk
            buff.cure = buffCfg.cure
            buff.addAtk = buffCfg.addAtk
            buff.addAtkSpeed = buffCfg.addAtkSpeed
            buff.addMoveSpeed = buffCfg.addMoveSpeed
            buff.stopAction = buffCfg.stopAction
            buff.lifeTime = buffCfg.lifeTime
            buff.frequency = buffCfg.frequency
            buff.lifeType = buffCfg.lifeType
            buffList[i] = buff
            i = i + 1
        end
    end

    for k,v in pairs(skillList) do
        if v.buffCfgId ~= nil and v.buffCfgId ~= 0 then
            local buffCfg = getBuffCfg(v.buffCfgId)
            local buff = {}
            buff.cfgId = v.buffCfgId
            buff.model = buffCfg.model
            buff.atk = buffCfg.atk
            buff.cure = buffCfg.cure
            buff.addAtk = buffCfg.addAtk
            buff.addAtkSpeed = buffCfg.addAtkSpeed
            buff.addMoveSpeed = buffCfg.addMoveSpeed
            buff.stopAction = buffCfg.stopAction
            buff.lifeTime = buffCfg.lifeTime
            buff.frequency = buffCfg.frequency
            buff.lifeType = buffCfg.lifeType
            buffList[i] = buff
            i = i + 1
        end
    end

    if heroSkill.buffCfgId ~= nil and heroSkill.buffCfgId ~= 0 then
        local buffCfg = getBuffCfg(heroSkill.buffCfgId)
        local buff = {}
        buff.cfgId = heroSkill.buffCfgId
        buff.model = buffCfg.model
        buff.atk = buffCfg.atk
        buff.cure = buffCfg.cure
        buff.addAtk = buffCfg.addAtk
        buff.addAtkSpeed = buffCfg.addAtkSpeed
        buff.addMoveSpeed = buffCfg.addMoveSpeed
        buff.stopAction = buffCfg.stopAction
        buff.lifeTime = buffCfg.lifeTime
        buff.frequency = buffCfg.frequency
        buff.lifeType = buffCfg.lifeType
        buffList[i] = buff
    end

    return buffList
end

-----------------------------------------------------------------------------------------------------------------------------------------
local net = {}

function net.C2S_Player_EndBattle(player,args)
    local battleId = args.battleId
    local bVersion = args.bVersion
    local ret = args.ret
    local signinPosId = args.signinPosId
    local soliders = args.soliders
    local operates = args.operates

    print(table.dump(args))
    --


    local endInfo
    --
    local enemyId = player.foundationBag:getEmemyId(battleId)
    if enemyId and enemyId > 0 then --
        endInfo = player.foundationBag:endBattle(battleId, ret, soliders)
        if not endInfo then
            return
        end
    else --
        local fightId = player.resPlanetBag:getFightId()
        if not fightId then --,
            return
        end
        if fightId ~= battleId then --,
            return
        end
        local index = player.resPlanetBag:getFightPlanet()
        endInfo = player.resPlanetBag:endAttackResPlanet(index, ret, soliders)
        if not endInfo then
            return
        end
    end


    gg.client:send(player.linkobj,"S2C_Player_EndBattle",{
        battleId = battleId,
        starCoin = 10,
        ice = 20,
        carboxyl = 30,
        titanium = 40,
        gas = 50,
    })
end

function net.C2S_Player_StartBattle(player,args)
    local battleType = args.battleType
    if not battleType then
        return
    end
    local enemyId = args.enemyId
    if not enemyId then
        return
    end

    local builds = {}               --
    local mainWarShip = nil         --
    local mainHero = nil            --
    local soliders = {}             --
    local battleId = snowflake.uuid()

    mainWarShip = player.armyBag:getFightWarShip()
    if not mainWarShip then
        player:say(i18n.format("no warShip"))
        return
    end
    mainHero = player.armyBag:getFightHero()
    mainHero = mainHero or {}
    if battleType == constant.BATTLE_TYPE_MAIN then
        --
        if enemyId == 0 then
            enemyId = player.pid
        end
        builds = player.foundationBag:startBattle(enemyId, battleId)
        if not builds then
            return
        end
    elseif battleType == constant.BATTLE_TYPE_PLANET then
        --
        local beginData = player.resPlanetBag:beginAttackResPlanet(enemyId, battleId)
        if not beginData then
            return
        end
        builds = beginData.builds
    else
        player:say(i18n.format("error battle"))
        return
    end
    if not builds then
        player:say(i18n.format("error buildings"))
        return
    end
    soliders = player.armyBag:getFightSoldiers()

    --ggclass.Build.getBuildCfg(cfgId, quality, level)
    --ggclass.WarShip.getWarShipCfg(cfgId, quality, level)

    local battleInfo = {}

    local buildsList = getBuildingList(builds)
    local trapsList = getTrapList(builds)
    local solidersList = getSoliderList(soliders)
    local hero = getHero(mainHero) or {}
    local mainShip = getMainShip(mainWarShip)
    local skillsList = getSkillList(mainWarShip)
    local heroSkill = getHeroSkill(mainHero)
    local bulletsList = getBulletList(buildsList, solidersList, hero)
    local buffsList = getBuffList(trapsList, skillsList, heroSkill)

    battleInfo.builds = buildsList
    battleInfo.traps = trapsList
    battleInfo.soliders = solidersList
    battleInfo.hero = hero
    battleInfo.mainShip = mainShip
    battleInfo.skills = skillsList
    battleInfo.heroSkill = heroSkill
    battleInfo.bullets = bulletsList
    battleInfo.buffs = buffsList

    print(table.dump(battleInfo))

    --local battleInfo = json.encode(battleTable) --"battleInfo"

    --

    --
    gg.client:send(player.linkobj,"S2C_Player_StartBattle",{
        battleId = battleId,
        battleInfo = battleInfo,
    })
end

function __hotfix(module)
    gg.client:open()
end

return net