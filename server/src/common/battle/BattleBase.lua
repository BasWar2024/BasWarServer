local BattleBase = class("BattleBase")

function BattleBase.getSkillCfg(cfgId, level)
    level = level or 1
    local key = string.format("%s_%s", cfgId, level)
    local skillCfgs = cfg.get("etc.cfg.skillConfig")
    return skillCfgs[key]
end

function BattleBase.getBuffCfg(cfgId)
    local buffCfgs = cfg.get("etc.cfg.buff")
    return buffCfgs[cfgId]
end

function BattleBase.getSkillEffectCfg(cfgId)
    local skillEffectCfgs = cfg.get("etc.cfg.skillEffect")
    return skillEffectCfgs[cfgId]
end

function BattleBase.getMapCfg(sceneId)
    local battleMapCfgs = cfg.get("etc.cfg.battleMap")
    return battleMapCfgs[sceneId]
end


function BattleBase.getSolider(soliderCfg)
    if not soliderCfg then
        return
    end
    local solider = {}
    solider.id = snowflake.uuid()
    solider.cfgId = soliderCfg.cfgId
    solider.model = soliderCfg.model
    solider.icon = soliderCfg.icon
    solider.amount = 0
    solider.moveSpeed = soliderCfg.moveSpeed
    solider.maxHp = soliderCfg.maxHp
    solider.hp = solider.maxHp
    solider.atk = soliderCfg.atk
    solider.atkSpeed = soliderCfg.atkSpeed
    solider.atkRange = soliderCfg.atkRange
    solider.radius = soliderCfg.radius
    solider.atkSkillId = soliderCfg.atkSkillCfgId
    solider.type = soliderCfg.type
    solider.center = soliderCfg.center
    solider.deadEffect = soliderCfg.deadEffect
    solider.isDeminer = soliderCfg.isDeminer
    solider.atkReadyTime = soliderCfg.atkReadyTime
    solider.atkSkillShowRadius = soliderCfg.atkSkillShowRadius
    solider.isMedical = soliderCfg.isMedical
    solider.inAtkRange = soliderCfg.inAtkRange
    solider.deadSkillId = soliderCfg.deadSkillCfgId
    solider.bornSkillId = soliderCfg.bornSkillCfgId
    solider.race = soliderCfg.race
    solider.level = soliderCfg.level
    return solider
end

function BattleBase.getBuff(buffcfg)
    if not buffcfg or not next(buffcfg) then
        return
    end
    local buff = {}
    buff.cfgId = buffcfg.cfgId
    buff.name = buffcfg.name
    buff.model = buffcfg.model 
    buff.lifeTime = buffcfg.lifeTime
    buff.frequency = buffcfg.frequency
    buff.skillEffectCfgId = buffcfg.skillEffectCfgId
    buff.skillCfgId = buffcfg.skillCfgId
    return buff
end

function BattleBase.getSkillEffect(skillEffectCfg)
    if not skillEffectCfg or not next(skillEffectCfg) then
        return
    end
    local skillEffect = {}
    skillEffect.cfgId = skillEffectCfg.cfgId
    skillEffect.type = skillEffectCfg.type
    skillEffect.args = skillEffectCfg.args
    skillEffect.rangeType = skillEffectCfg.rangeType
    skillEffect.range = skillEffectCfg.range
    skillEffect.skillEffectCfgId = skillEffectCfg.skillEffectCfgId
    skillEffect.buffCfgId = skillEffectCfg.buffCfgId
    skillEffect.entityCfgId = skillEffectCfg.entityCfgId
    skillEffect.skillCfgId = skillEffectCfg.skillCfgId
    return skillEffect
end

function BattleBase.getSkill(skillCfg)
    if skillCfg == nil then
        return
    end
    local skill = {}
    skill.id = snowflake.uuid()
    skill.cfgId = skillCfg.cfgId
    skill.icon = skillCfg.icon
    skill.type = skillCfg.type
    skill.skillType = skillCfg.skillType
    skill.targetGroup = skillCfg.targetGroup
    skill.skillEffectCfgId = skillCfg.skillEffectCfgId
    skill.originCost = skillCfg.originCost
    skill.addCost = skillCfg.addCost
    skill.skillCd = skillCfg.skillCd
    skill.useArea = skillCfg.useArea
    skill.level = skillCfg.level
    skill.quality = skillCfg.quality
    skill.releaseDistance = skillCfg.releaseDistance
    skill.skillAnimTime = skillCfg.skillAnimTime
    skill.skillDelayTime = skillCfg.skillDelayTime

    skill.intArg1 = skillCfg.intArg1    
    skill.intArg2 = skillCfg.intArg2
    skill.intArg3 = skillCfg.intArg3
    skill.intArg4 = skillCfg.intArg4
    skill.intArg5 = skillCfg.intArg5
    skill.intArg6 = skillCfg.intArg6
    skill.intArg7 = skillCfg.intArg7
    skill.intArg8 = skillCfg.intArg8
    skill.intArg9 = skillCfg.intArg9
    skill.intArg10 = skillCfg.intArg10
    skill.intArg11 = skillCfg.intArg11
    skill.intArg12 = skillCfg.intArg12
    skill.intArg13 = skillCfg.intArg13
    skill.intArg14 = skillCfg.intArg14
    skill.intArg15 = skillCfg.intArg15

    skill.stringArg1 = skillCfg.stringArg1
    skill.stringArg2 = skillCfg.stringArg2
    skill.stringArg3 = skillCfg.stringArg3
    skill.stringArg4 = skillCfg.stringArg4
    skill.stringArg5 = skillCfg.stringArg5
    skill.stringArg6 = skillCfg.stringArg6
    skill.stringArg7 = skillCfg.stringArg7
    skill.stringArg8 = skillCfg.stringArg8
    skill.stringArg9 = skillCfg.stringArg9
    skill.stringArg10 = skillCfg.stringArg10

    return skill
end

function BattleBase.checkLoseSoliders(soliders, retSoliders)
    local soliderMap = {}
    local retSoliderMap = {}
    if soliders then
        for k, v in pairs(soliders) do
            soliderMap[v.id] = v.dieCount
        end
    end
    if retSoliders then
        for k, v in pairs(retSoliders) do
            retSoliderMap[v.id] = v.dieCount
        end
    end
    for k, v in pairs(soliderMap) do
        if not retSoliderMap[k] then
            return false
        end
        if v ~= retSoliderMap[k] then
            return false
        end
    end
    for k, v in pairs(retSoliderMap) do
        if not soliderMap[k] then
            return false
        end
        if v ~= soliderMap[k] then
            return false
        end
    end
    return true
end

function BattleBase.repeatCfgId(list, cfgId)
    if not list then
        error("repeatCfgId is nil cfgId="..tostring(cfgId) )
    end
    for _, v in pairs(list) do
        if v.cfgId == cfgId then
            return true
        end
    end
    return false
end

function BattleBase.getBuilds(builds, sanctuaryValue)
    local buildList = {}
    sanctuaryValue = sanctuaryValue or {}
    local allEnableAtk = sanctuaryValue.allEnableAtk or 0
    local allEnableHp = sanctuaryValue.allEnableHp or 0
    for k, v in pairs(builds) do
        local buildCfg = ggclass.Build.getBuildCfg(v.cfgId, v.quality or 0, v.level)
        if buildCfg and buildCfg.subType ~= constant.BUILD_SUBTYPE_MINE and buildCfg.subType ~= constant.BUILD_SUBTYPE_LIBERATORSHIP then
            local build = {}
            build.id = v.id
            build.quality = v.quality
            build.level = v.level
            build.cfgId = buildCfg.cfgId
            build.model = buildCfg.model
            build.wreckageModel = buildCfg.wreckageModel
            build.explosionEffect = buildCfg.explosionEffect
            build.pos = {}
            build.pos.x = v.pos.x
            build.pos.z = v.pos.z
            build.pos.y = v.pos.y
            build.x = v.pos.x + buildCfg.length / 2
            build.z = v.pos.z + buildCfg.width / 2
            build.maxHp = buildCfg.maxHp
            if v.hpAddRatio then
                build.maxHp = build.maxHp * (1 + v.hpAddRatio )
            end
            build.hp = buildCfg.maxHp
            if buildCfg.hpEnableRatio then
                build.maxHp = build.maxHp +  math.floor(allEnableHp * buildCfg.hpEnableRatio)
                build.hp = build.maxHp
            end
            build.atk = buildCfg.atk
            if v.atkAddRatio then
                build.atk = build.atk * (1 + v.atkAddRatio)
            end
            if buildCfg.attEnableRatio then
                build.atk = build.atk + math.floor(allEnableAtk * buildCfg.attEnableRatio)
            end
            build.atkSpeed = buildCfg.atkSpeed
            if v.atkSpeedAddRatio then
                build.atkSpeed = build.atkSpeed * (1 + v.atkSpeedAddRatio)
            end
            build.atkRange = buildCfg.atkRange
            build.radius = buildCfg.radius
            build.atkAir = buildCfg.atkAir
            build.atkSkillId = buildCfg.atkSkillCfgId
            build.direction = buildCfg.direction
            build.atkReadyTime = buildCfg.atkReadyTime
            build.inAtkRange = buildCfg.inAtkRange
            if v.cfgId == constant.BUILD_BASE or v.cfgId == constant.BUILD_BASE_PVE then
                build.isMain = 1
            else
                build.isMain = 0
            end
            
            build.type = buildCfg.type
            build.subType = buildCfg.subType
            build.center = buildCfg.center
            build.isConstruct = 0
            -- if v.lessTick and v.lessTick > 0 then
            --     build.isConstruct = 1
            -- else
            --     build.isConstruct = 0
            -- end
            build.floor = buildCfg.floor
            build.atkSkillShowRadius = buildCfg.atkSkillShowRadius
            build.deadSkillId = buildCfg.deadSkillCfgId
            build.bornSkillId = buildCfg.bornSkillCfgId
            build.race = buildCfg.race
            build.atkSkill1Id = buildCfg.atkSkill1CfgId
            build.firstAtk = buildCfg.firstAtk
            build.intArgs1 = buildCfg.intArgs1
            build.intArgs2 = buildCfg.intArgs2
            build.intArgs3 = buildCfg.intArgs3
            table.insert(buildList, build)
        end
    end
    return buildList
end

function BattleBase.getTraps(builds)
    local trapList = {}
    for k, v in pairs(builds) do
        local buildCfg = ggclass.Build.getBuildCfg(v.cfgId, v.quality, v.level)
        if buildCfg and buildCfg.type == constant.BUILD_TYPE_DEFEND and buildCfg.subType == constant.BUILD_SUBTYPE_MINE then
            local trap = {}
            trap.id = v.id
            trap.cfgId = buildCfg.cfgId
            trap.model = buildCfg.model
            trap.explosionEffect = buildCfg.explosionEffect
            trap.x = v.pos.x + buildCfg.length / 2
            trap.z = v.pos.z + buildCfg.width / 2
            trap.buffCfgId = buildCfg.buffCfgId
            trap.alertRange = buildCfg.alertRange
            trap.atkRange = buildCfg.atkRange
            trap.radius = buildCfg.radius
            trap.delayExplosionTime = buildCfg.delayExplosionTime
            table.insert(trapList, trap)
        end
    end
    return trapList
end

function BattleBase.getHero(heroData)
    local hero = {}
    if heroData == nil or not next(heroData) then
        return hero
    end
    local heroCfg = ggclass.Hero.getHeroCfg(heroData.cfgId, heroData.quality, heroData.level)
    if not heroCfg then
        return hero
    end
    hero.id = heroData.id
    hero.level = heroData.level
    hero.cfgId = heroCfg.cfgId 
    hero.model = heroCfg.model
    hero.icon = heroCfg.icon
    hero.moveSpeed = heroCfg.moveSpeed
    hero.maxHp = heroCfg.maxHp
    if heroData.hpAddRatio then
        hero.maxHp = hero.maxHp * (1 + heroData.hpAddRatio )
    end
    hero.hp = heroCfg.maxHp
    hero.atk = heroCfg.atk
    if heroData.atkAddRatio then
        hero.atk = hero.atk * (1 + heroData.atkAddRatio)
    end 
    hero.atkSpeed = heroCfg.atkSpeed
    if heroData.atkSpeedAddRatio then
        hero.atkSpeed = hero.atkSpeed * (1 + heroData.atkSpeedAddRatio)
    end
    hero.atkRange = heroCfg.atkRange
    hero.radius = heroCfg.radius
    hero.atkSkillId = heroCfg.atkSkillCfgId
    hero.center = heroCfg.center
    hero.deadEffect = heroCfg.deadEffect
    hero.isDeminer = heroCfg.isDeminer
    hero.atkReadyTime = heroCfg.atkReadyTime
    hero.atkSkillShowRadius = heroCfg.atkSkillShowRadius
    hero.isMedical = heroCfg.isMedical
    hero.inAtkRange = heroCfg.inAtkRange
    hero.deadSkillId = heroCfg.deadSkillCfgId
    hero.bornSkillId = heroCfg.bornSkillCfgId
    hero.aroundSkillId = heroCfg.aroundSkillCfgId
    hero.race = heroCfg.race
    hero.skill1 = heroData.skill1
    hero.skill2 = heroData.skill2
    hero.skill3 = heroData.skill3
    hero.quality = heroData.quality
    return hero
end

function BattleBase.getHeros(heros)
    local heroList = {}
    for k, v in pairs(heros) do
        local heroInfo = BattleBase.getHero(v)
        if heroInfo then
            heroInfo.index = v.index
            table.insert(heroList, heroInfo)
        end
    end
    return heroList
end

function BattleBase.getSoliders(soliders)
    local soliderList = {}
    for k,v in pairs(soliders) do
        local soliderCfg = ggclass.SoliderLevel.getSoliderCfg(v.cfgId, v.level)
        if soliderCfg then
            local solider = BattleBase.getSolider(soliderCfg)
            solider.id = v.id
            solider.amount = v.count
            solider.index = v.index
            if v.moveSpeedAddRatio then
                solider.moveSpeed = math.floor(solider.moveSpeed * (1 + v.moveSpeedAddRatio))
            end
            if v.hpAddRatio then
                solider.maxHp = math.floor(solider.maxHp * (1 + v.hpAddRatio))
                solider.hp = solider.maxHp
            end
            if v.atkAddRatio then
                solider.atk = math.floor(solider.atk * (1 + v.atkAddRatio))
            end
            if v.atkSpeedAddRatio then
                solider.atkSpeed = math.floor(solider.atkSpeed * (1 + v.atkSpeedAddRatio))
            end
            table.insert(soliderList, solider)
        end
    end
    return soliderList
end

function BattleBase.getMainShip(mainWarShip)
    local mainShip = {}
    if not mainWarShip then
        return mainShip
    end
    
    local mainShipCfg = ggclass.WarShip.getWarShipCfg(mainWarShip.cfgId, mainWarShip.quality, mainWarShip.level)
    if not mainShipCfg then
        return mainShip
    end
    mainShip.id = mainWarShip.id
    mainShip.cfgId = mainShipCfg.cfgId
    mainShip.model = mainShipCfg.model
    mainShip.skillPoint = mainShipCfg.skillPoint
    mainShip.maxHp = mainShipCfg.maxHp
    mainShip.atk = mainShipCfg.atk
    return mainShip
end

-- function BattleBase.getLandShip(liberatorShips)
--     local soliderCfg = ggclass.Build.getBuildCfg(liberatorShips[1].cfgId, liberatorShips[1].quality, liberatorShips[1].level)
--     if soliderCfg then
--         local solider = BattleBase.getSolider(soliderCfg)
--         solider.type = 3
--         return solider
--     end
-- end

function BattleBase.getMainShipSkills(mainWarShip, warShip)
    local skillList = {}
    if not mainWarShip or not next(mainWarShip) then
        return skillList
    end

    local skill1Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill1, 5, mainWarShip.skillLevel1)
    local skill1 = BattleBase.getSkill(skill1Cfg)
    if skill1 then
        warShip.skill1 = skill1.id
        table.insert( skillList,  skill1)
    end

    local skill2Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill2, 5, mainWarShip.skillLevel2)
    local skill2 = BattleBase.getSkill(skill2Cfg)
    if skill2 then
        warShip.skill2 = skill2.id
        table.insert( skillList,  skill2)
    end

    local skill3Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill3, 5, mainWarShip.skillLevel3)
    local skill3 = BattleBase.getSkill(skill3Cfg)
    if skill3 then
        warShip.skill3 = skill3.id
        table.insert( skillList,  skill3)
    end

    local skill4Cfg = ggclass.WarShip.getWarShipSkillCfg(mainWarShip.skill4, 5, mainWarShip.skillLevel4)
    local skill4 = BattleBase.getSkill(skill4Cfg)
    if skill4 then
        warShip.skill4 = skill4.id
        table.insert( skillList,  skill4)
    end
    
    return skillList
end

function BattleBase.getHeroSkill(heroData, heroSkills, hero)
    local skillCfgId1 = heroData["skill1"]
    local skillLevel1 = heroData["skillLevel1"]

    local skillCfgId2 = heroData["skill2"]
    local skillLevel2 = heroData["skillLevel2"]

    local skillCfgId3 = heroData["skill3"]
    local skillLevel3 = heroData["skillLevel3"]

    local heroskillCfg1 = gg.getExcelCfgByFormat("skillConfig", skillCfgId1, skillLevel1)
    local heroskillCfg2 = gg.getExcelCfgByFormat("skillConfig", skillCfgId2, skillLevel2)
    local heroskillCfg3 = gg.getExcelCfgByFormat("skillConfig", skillCfgId3, skillLevel3)

    if heroskillCfg1 then
        local heroSkill1 = BattleBase.getSkill(heroskillCfg1)  
        hero.skill1 = heroSkill1.id
        table.insert(heroSkills, heroSkill1)
    end

    if heroskillCfg2 then
        local heroSkill2 = BattleBase.getSkill(heroskillCfg2)   
        hero.skill2 = heroSkill2.id 
        table.insert(heroSkills, heroSkill2)
    end

    if heroskillCfg3 then
        local heroSkill3 = BattleBase.getSkill(heroskillCfg3)   
        hero.skill3 = heroSkill3.id
        table.insert(heroSkills, heroSkill3)
    end
end

function BattleBase.getHeroSkills(heroDatas, heros)
    local heroSkills = {}
    for k, v in pairs(heroDatas) do
        BattleBase.getHeroSkill(v, heroSkills, heros[k])
    end
    return heroSkills
end

function BattleBase.getBuffAndSkillEffect(skillEffect, buff, skill, skillEffects, buffs, skills)
    if skillEffect ~= nil then
        if skillEffect.buffCfgId ~= nil and skillEffect.buffCfgId ~= 0 then
            if BattleBase.repeatCfgId(buffs, skillEffect.buffCfgId) ~= true then
                local buffCfg = BattleBase.getBuffCfg(skillEffect.buffCfgId)
                if buffCfg then
                    local newBuff = BattleBase.getBuff(buffCfg)
                    table.insert(buffs, newBuff)
                    BattleBase.getBuffAndSkillEffect(nil, newBuff, nil, skillEffects, buffs, skills)
                end
            end
        end

        if skillEffect.skillEffectCfgId ~= nil and skillEffect.skillEffectCfgId ~= 0 then
            if BattleBase.repeatCfgId(skillEffects, skillEffect.skillEffectCfgId) ~= true then
                local skillEffectCfg = BattleBase.getSkillEffectCfg(skillEffect.skillEffectCfgId)
                if skillEffectCfg then
                    local newSkillEffect = BattleBase.getSkillEffect(skillEffectCfg)
                    table.insert(skillEffects, newSkillEffect)
                    BattleBase.getBuffAndSkillEffect(newSkillEffect, nil, nil, skillEffects, buffs, skills)
                end
                
            end
        end

        if skillEffect.skillCfgId ~= nil and skillEffect.skillCfgId ~= 0 then
            if BattleBase.repeatCfgId(skills, skillEffect.skillCfgId) ~= true then
                local skillCfg = BattleBase.getSkillCfg(skillEffect.skillCfgId)
                if skillCfg then
                    local newSkill = BattleBase.getSkill(skillCfg)
                    newSkill.id = skillEffect.skillCfgId
                    table.insert(skills, newSkill)

                    BattleBase.getBuffAndSkillEffect(nil, nil, newSkill, skillEffects, buffs, skills)
                end
                
            end
        end
    end

    if buff ~= nil then
        if buff.skillEffectCfgId ~= nil and buff.skillEffectCfgId ~= 0 then
            if BattleBase.repeatCfgId(skillEffects, buff.skillEffectCfgId) ~= true then
                local skillEffectCfg = BattleBase.getSkillEffectCfg(buff.skillEffectCfgId)
                if skillEffectCfg then
                    local newSkillEffect = BattleBase.getSkillEffect(skillEffectCfg)
                    table.insert(skillEffects, newSkillEffect)
                    BattleBase.getBuffAndSkillEffect(newSkillEffect, nil, nil, skillEffects, buffs, skills)
                end
                
            end
        end
    end

    if skill ~= nil then
        if skill.skillEffectCfgId ~= nil and skill.skillEffectCfgId ~= 0 then
            if BattleBase.repeatCfgId(skillEffects, skill.skillEffectCfgId) ~= true then
                local skillEffectCfg = BattleBase.getSkillEffectCfg(skill.skillEffectCfgId)
                if skillEffectCfg then
                    local newSkillEffect = BattleBase.getSkillEffect(skillEffectCfg);
                    table.insert(skillEffects, newSkillEffect)
                    BattleBase.getBuffAndSkillEffect(newSkillEffect, nil, nil, skillEffects, buffs, skills)
                end
                
            end
        end
    end
end

function BattleBase.getSkillSystem(builds, soliders, heros, skills, heroSkills, skillEffects, buffs, summonSoliders)
    if skillEffects == nil then
        skillEffects = {}
    end

    if buffs == nil then
        buffs = {}
    end

    if summonSoliders == nil then
        summonSoliders = {}
    end

    --""skill,""skill,""skill
    --builds atkSkill
    if builds and next(builds) then
        for k,v in pairs(builds) do
            if v.atkSkillId ~= nil and v.atkSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.atkSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.atkSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.atkSkillId
                    table.insert(skills, skill)
                end
            end

            if v.atkSkill1Id ~= nil and v.atkSkill1Id ~= 0 then
                if BattleBase.repeatCfgId(skills, v.atkSkill1Id) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.atkSkill1Id)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.atkSkill1Id
                    table.insert(skills, skill)
                end
            end

            if v.deadSkillId ~= nil and v.deadSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.deadSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.deadSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.deadSkillId
                    table.insert(skills, skill)
                end
            end

            if v.bornSkillId ~= nil and v.bornSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.bornSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.bornSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.bornSkillId
                    table.insert(skills, skill)
                end
            end
        end
    end

    --soliders atkSkill
    if soliders and next(soliders) then
        for k,v in pairs(soliders) do
            if v.atkSkillId ~= nil and v.atkSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.atkSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.atkSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.atkSkillId
                    table.insert(skills, skill)
                end
            end

            if v.deadSkillId ~= nil and v.deadSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.deadSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.deadSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.deadSkillId
                    table.insert(skills, skill)
                end
            end

            if v.bornSkillId ~= nil and v.bornSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.bornSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.bornSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.bornSkillId
                    table.insert(skills, skill)
                end
            end
        end
    end

    --heros atkSkill
    if heros and next(heros) then  
        for k,v in pairs(heros) do
            if v.atkSkillId ~= nil and v.atkSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.atkSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.atkSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.atkSkillId
                    table.insert(skills, skill)
                end
            end

            if v.deadSkillId ~= nil and v.deadSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.deadSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.deadSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.deadSkillId
                    table.insert(skills, skill)
                end
            end

            if v.bornSkillId ~= nil and v.bornSkillId ~= 0 then
                if BattleBase.repeatCfgId(skills, v.bornSkillId) ~= true then
                    local skillCfg = BattleBase.getSkillCfg(v.bornSkillId)
                    local skill = BattleBase.getSkill(skillCfg)
                    skill.id = v.bornSkillId
                    table.insert(skills, skill)
                end
            end
        end
    end

    --""skill""skillEff
    if skills and next(skills) then
        for k,v in pairs(skills) do
            if v.skillEffectCfgId ~= nil and v.skillEffectCfgId ~= 0 then
                if BattleBase.repeatCfgId(skillEffects, v.skillEffectCfgId) ~= true then
                    local skillEffectCfg = BattleBase.getSkillEffectCfg(v.skillEffectCfgId)
                    local skillEffect = BattleBase.getSkillEffect(skillEffectCfg)
                    table.insert(skillEffects, skillEffect)
                end
            end
        end
    end

    --""heroSkill""skef
    if heroSkills and next(heroSkills) then
        for k,v in pairs(heroSkills) do
            if v.skillEffectCfgId ~= nil and v.skillEffectCfgId ~= 0 then
                if BattleBase.repeatCfgId(skillEffects, v.skillEffectCfgId) ~= true then
                    local skillEffectCfg = BattleBase.getSkillEffectCfg(v.skillEffectCfgId)
                    local skillEffect = BattleBase.getSkillEffect(skillEffectCfg)
                    table.insert(skillEffects, skillEffect)
                end
            end
        end
    end

    --""skillEff ""buff ""skillEff
    if skillEffects and next(skillEffects) then
        for k,v in pairs(skillEffects) do
            BattleBase.getBuffAndSkillEffect(v, nil, nil, skillEffects, buffs, skills)
        end
    end

    --""
    for k,v in pairs(skillEffects) do
        if v.entityCfgId ~= nil and v.entityCfgId ~= 0 then
            local args = cjson.decode(v.args)
            if BattleBase.repeatCfgId(summonSoliders, v.entityCfgId) ~= true then 
                local soliderCfg = ggclass.SoliderLevel.getSoliderCfg(v.entityCfgId, args[1])
                local solider = BattleBase.getSolider(soliderCfg)
                solider.id = soliderCfg.cfgId
                solider.amount = args[2]
                table.insert(summonSoliders, solider)

                BattleBase.getSkillSystem(nil, summonSoliders, nil, skills, heroSkills, skillEffects, buffs, summonSoliders)
            end
        end
    end

    return skillEffects, buffs, summonSoliders
end

function BattleBase.setSigninPos(data)
    local signinPos = {}
    signinPos.x = data[1] --x""
    signinPos.y = data[2] --y""
    signinPos.z = data[3] --z""
    return signinPos
end

function BattleBase.setSigninScale(data)
    local signinScale = {}
    signinScale.length = data[1] --x""
    signinScale.width = data[2] --y""
    signinScale.hight = data[3] --z""
    return signinScale
end

function BattleBase.getMap(sceneId)
    local map = {}
    local mapCfg = BattleBase.getMapCfg(sceneId)
    if mapCfg ~= nil then
        map.sceneId = mapCfg.sceneId
        map.signinPos1 = BattleBase.setSigninPos(mapCfg.signinPos1)
        map.signinScale1 = BattleBase.setSigninScale(mapCfg.signinScale1)
        map.signinPos2 = BattleBase.setSigninPos(mapCfg.signinPos2)
        map.signinScale2 = BattleBase.setSigninScale(mapCfg.signinScale2)
        map.signinPos3 = BattleBase.setSigninPos(mapCfg.signinPos3)
        map.signinScale3 = BattleBase.setSigninScale(mapCfg.signinScale3)
        map.signinPos4 = BattleBase.setSigninPos(mapCfg.signinPos4)
        map.signinScale4 = BattleBase.setSigninScale(mapCfg.signinScale4)
        map.length = mapCfg.length
        map.width = mapCfg.width
        map.skillAreaPos = BattleBase.setSigninPos(mapCfg.skillAreaPos)
        map.skillAreaScale = BattleBase.setSigninScale(mapCfg.skillAreaScale)
    end
    return map
end

function BattleBase:ctor()
    self.battleId = snowflake.uuid()
    self.battleType = nil
    self.startBattleTime = gg.time.time()
    self.battleDeadlineTime = self.startBattleTime + constant.BATTLE_DURATION_SECOND
    self.clearTick = gg.time.time() + constant.BATTLE_OBJ_CACHE_SECOND
    self.battleInfo = nil
    self.attacker = nil
    self.enemy = nil
    self.builds = nil
    self.army = nil
    self.result = constant.BATTLE_RESULT_UNKNOW
    self.signinPosId = constant.BATTLE_SIGNIN_POS_UNKNOWN
    self.bVersion = ""
    self.endStep = 0
    self.operates = nil
    self.resInfo = nil
    self.dirty = false
end

function BattleBase:serialize()
    local data = {}
    data.battleId = self.battleId
    data.battleType = self.battleType
    data.startBattleTime = self.startBattleTime
    data.battleInfo = self.battleInfo
    data.attacker = self.attacker
    data.enemy = self.enemy
    data.result = self.result
    data.bVersion = self.bVersion
    data.signinPosId = self.signinPosId
    data.endStep = self.endStep
    data.operates = self.operates
    data.resInfo = self.resInfo
    data.gridCfgId = self.gridCfgId
    return data
end

function BattleBase:deserialize(data)
    if not data then
        return
    end
    self.battleId = data.battleId
    self.battleType = data.battleType
    self.startBattleTime = data.startBattleTime
    self.battleDeadlineTime = self.startBattleTime + constant.BATTLE_DURATION_SECOND
    self.battleInfo = data.battleInfo
    self.attacker = data.attacker
    self.enemy = data.enemy
    self.result = data.result
    self.bVersion = data.bVersion
    self.signinPosId = data.signinPosId
    self.endStep = data.endStep
    self.operates = data.operates
    self.resInfo = data.resInfo
    self.gridCfgId = data.gridCfgId
end

function BattleBase:save_to_db()
    local battleData = self:serialize()
    gg.mongoProxy:send("setBattleInfo", self.battleId, battleData)
    self.dirty = false
    return battleData
end

function BattleBase:createFightReport(extData)
    local report = {}
    report.fightId = self.battleId
    report.fightTime = self.startBattleTime
    report.fightType = self.battleType
    report.soliders = {}
    report.heros = {}
    report.result = self.result
    report.currencies = {}
    report.signinPosId = self.signinPosId
    report.bVersion = ""
    -- report.badge = 0
    report.atkBadge = 0
    report.defenBadge = 0
    for k, v in pairs(self.army.soliders) do
        table.insert(report.soliders, {
            id = v.id,
            cfgId = v.cfgId,
            count = v.count,
            level = v.level,
            dieCount = v.dieCount,
        })
    end

    for k, v in pairs(self.army.heros) do
        local hero = {
            id = v.id,
            cfgId = v.cfgId,
            quality = v.quality,
            level = v.level,
        }
        table.insert(report.heros, hero)
    end
    
    if extData.isAttacker then --""
        report.playerId =  self.attacker.playerId
        report.enemyPlayerId = self.enemy.playerId
        report.enemyPlayerName = self.enemy.playerName
        report.enemyPlayerLevel = self.enemy.playerLevel
        report.enemyPlayerScore = self.enemy.playerScore
        report.enemyPlayerHead = self.enemy.playerHead
        report.isAttacker = extData.isAttacker
    else
        report.playerId = self.enemy.enemyPlayerId
        report.enemyPlayerId = self.attacker.playerId
        report.enemyPlayerName = self.attacker.playerName
        report.enemyPlayerLevel = self.attacker.playerLevel
        report.enemyPlayerScore = self.attacker.playerScore
        report.enemyPlayerHead = self.attacker.playerHead
        report.isAttacker = extData.isAttacker
    end
    return report
end

function BattleBase:getBattleInfo()
    local battleInfo = {}
    battleInfo.enemy = self.enemy
    battleInfo.builds = BattleBase.getBuilds(self.builds, self.sanctuaryValue)
    battleInfo.traps = BattleBase.getTraps(self.builds)
    battleInfo.soliders = BattleBase.getSoliders(self.army.soliders)
    battleInfo.heros = BattleBase.getHeros(self.army.heros)
    battleInfo.mainShip = BattleBase.getMainShip(self.army.mainWarShip)
    battleInfo.skills = BattleBase.getMainShipSkills(self.army.mainWarShip, battleInfo.mainShip)
    battleInfo.heroSkills = BattleBase.getHeroSkills(self.army.heros, battleInfo.heros)
    battleInfo.skillEffects, battleInfo.buffs, battleInfo.summonSoliders =
        BattleBase.getSkillSystem(battleInfo.builds, battleInfo.soliders, battleInfo.heros, battleInfo.skills, battleInfo.heroSkills, nil, nil, nil)
    battleInfo.battleMapInfo = BattleBase.getMap(self.sceneId)
    return battleInfo
end

function BattleBase:initBattle(args)
    assert(args.battleType, "battleType is nil")
    assert(args.attacker, "attacker is nil")
    assert(args.defender, "defender is nil")
    assert(args.defenderBuilds, "defenderBuilds is nil")
    assert(args.attackerArmy, "attackerArmy is nil")
    self.battleType = args.battleType
    self.attacker = args.attacker
    self.enemy = args.defender
    self.builds = args.defenderBuilds
    self.army = args.attackerArmy
    self.bVersion = args.bVersion or ""
    self.clearTick = gg.time.time() + constant.BATTLE_OBJ_CACHE_SECOND
    self.sceneId = args.sceneId or 1
    self.sanctuaryValue = args.defender.sanctuaryValue or {}       -- ""
    self.battleInfo = self:getBattleInfo()
    self.dirty = true
end

function BattleBase:startBattle()
    return true
end

function BattleBase:checkBattleValid(battleResult)
    if skynet.config["checkBattleValid"] == true then
        local ok, retInfo, code, server = gg.shareProxy:call("checkBattleValid", 
            self.battleId, self.battleType, self.battleInfo, battleResult.signinPosId, battleResult.operates, battleResult.endStep)
        if not ok then
            return false, code
        end

        if retInfo.ret ~= battleResult.ret then
            logger.logf("error", "BattleBaseWarn", "checkBattleValid535 battleId=%s, battleType=%s, battleResult=%s, retInfo=%s, server=%s", tostring(self.battleId), tostring(self.battleType), cjson.encode(battleResult), cjson.encode(retInfo), cjson.encode(server))
            --return false, constant.BATTLE_CODE_535
            battleResult.ret = retInfo.ret
        end
        if not BattleBase.checkLoseSoliders(battleResult.soliders, retInfo.soliders) then
            logger.logf("error", "BattleBaseWarn", "checkBattleValid534 battleId=%s, battleType=%s, battleResult=%s, retInfo=%s, server=%s", tostring(self.battleId), tostring(self.battleType), cjson.encode(battleResult), cjson.encode(retInfo), cjson.encode(server))
            --return false, constant.BATTLE_CODE_534

            --""
            local deathDict = {}
            for k, v in pairs(retInfo.soliders) do
                deathDict[v.cfgId] = v.dieCount or 0
            end
            for kk,vv in pairs(battleResult.soliders) do
                local dieCount = deathDict[vv.cfgId] or 0
                vv.dieCount = dieCount
            end
        end
    end
    return true
end

function BattleBase:endBattle(battleResult, resInfo)
    self.result = battleResult.ret
    self.bVersion = battleResult.bVersion
    self.signinPosId = battleResult.signinPosId
    self.endStep = battleResult.endStep
    self.operates = battleResult.operates
    self.winlostResInfo = resInfo
    self.dirty = true
end

function BattleBase:execIncompleteBattle(battleResult)
    local ok, retInfo, code = gg.shareProxy:call("checkBattleValid", 
        self.battleId, self.battleType, self.battleInfo, battleResult.signinPosId, battleResult.operates, battleResult.endStep)
    if not ok then
        return false, code
    end
    return true, retInfo
end


return BattleBase