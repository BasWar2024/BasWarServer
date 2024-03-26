local ArmyBag = class("ArmyBag")

--""
function ArmyBag:ctor(param)
    self.player = param.player
    self.autoStatus = 1
    self.armys = {}
    self.guildReserveCount = 0    -- ""
    self.isUseGuildArmy = 0     -- ""
end


function ArmyBag:serialize()
    local data = {}
    data.armys = {}
    data.autoStatus = self.autoStatus
    data.guildReserveCount = self.guildReserveCount
    for _, army in pairs(self.armys) do
        table.insert(data.armys, army:serialize())
    end
    return data
end


function ArmyBag:deserialize(data)
    if data.armys and next(data.armys) then
        for _, armyData in ipairs(data.armys) do
            local army = self:newArmy(armyData)
            if army then
                army:deserialize(armyData)
                self.armys[army.armyId] = army
            end
        end
    end

    if data.autoStatus then
        self.autoStatus = data.autoStatus
    end
    if data.guildReserveCount then
        self.guildReserveCount = data.guildReserveCount
    end
end

function ArmyBag:_createStarmapBattleWarship()
    local cfgId = gg.getGlobalCfgIntValue("unionBattleWarshipCfgId", 1000001)
    local quality = gg.getGlobalCfgIntValue("unionBattleWarshipQuality", 0)
    local level = gg.getGlobalCfgIntValue("unionBattleWarshipLevel", 1)
    local life = ggclass.WarShip.randomWarShipLife(quality)
    local param = {
        cfgId = cfgId,
        quality = quality,
        level = level,
        life = life,
        curLife = life,
    }
    local warShip = ggclass.WarShip.create(param)
    return warShip
end

function ArmyBag:_checkArmyWarShip(army)
    if army.warShipId and army.warShipId ~= 0 then
        local warShip = self.player.warShipBag:getWarShip(army.warShipId)
        if not warShip then
            self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
            return
        end
        -- ""
        if not constant.IsRefNone(warShip) then
            self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
            return
        end
        local packdata = warShip:pack()
        -- self:setFightLevel(packdata)
        return packdata
    end
end

function ArmyBag:_checkArmyHero(team)
    if team.heroId and team.heroId ~= 0 then
        local hero = self.player.heroBag:getHero(team.heroId)
        if not hero then
            self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
            return
        end
        -- ""
        if  not constant.IsRefNone(hero) and not constant.IsRefArmy(hero) then
            self.player:say(util.i18nFormat(errors.HERO_REF_BUSY))
            return
        end
        if hero.curLife <= 0 then
            self.player:say(util.i18nFormat(errors.HERO_NOT_LIFE))
            return
        end
        local heroData = hero:pack()
        -- self:setFightLevel(heroData)
        return heroData
    end
end

function ArmyBag:_genStarmapCampaignSoldierId(armyId, index)
    return armyId * 10 + index
end

function ArmyBag:_decodeStarmapCampaignSoldierId(id)
    local armyId = math.floor(id / 10)
    local index = id % 10
    return {armyId = armyId, index = index}
end

function ArmyBag:checkUseGuildArmy()
    if self.isUseGuildArmy == 0 then
        return
    end
    local myUnionId = self.player.unionBag:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    return myUnionId
end

function ArmyBag:getGuildSoliderCount(heroId, soliderCfgId,soliderLevel, tmpTable)
    heroId = heroId or 0
    local armyTeamSpace = 0
    -- ""
    local baseSpace = self:getArmyTeamBaseSpace()
    -- ""，"" ""+""
    if heroId and heroId ~= 0 then
        local heroData = self.player.heroBag:getHero(heroId)
        local heroCfg = gg.getExcelCfgByFormat("heroConfig", heroData.cfgId, heroData.quality, heroData.level)
        local heroSoldierSpace = heroCfg.unionSoldierSpace
        armyTeamSpace = heroSoldierSpace + baseSpace
    else
        armyTeamSpace = baseSpace
    end
    local soliderCfgs = gg.getExcelCfgByFormat("soliderConfig", soliderCfgId, soliderLevel)
    local count = armyTeamSpace // soliderCfgs.trainSpace
    local needReserveSoliderCount = soliderCfgs.trainSpace * count
    local guildReserveCount = self.guildReserveCount - tmpTable.guildReserveCount
    if guildReserveCount < 0 then
        guildReserveCount = 0
    end
    if guildReserveCount < needReserveSoliderCount then
        count = guildReserveCount // soliderCfgs.trainSpace
        needReserveSoliderCount = count * soliderCfgs.trainSpace
    end
    tmpTable.guildReserveCount = tmpTable.guildReserveCount + needReserveSoliderCount
    return count
end

function ArmyBag:changeToGuildArmy(fightSoliders, myUnionId, id, heroId, tmpTable)
    local soliderComparisonCfg = cfg.get("etc.cfg.soliderComparison")
    local guildBaseSolider = gg.getGlobalCfgIntValue("GuildBaseSolider", 0)
    local unionSoliders = gg.unionProxy:call("getUnionSoliders", myUnionId)
    if not unionSoliders then
        self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    local soliders = {}
    for k,v in pairs(unionSoliders) do
        if v.level > 0 then
            soliders[v.cfgId] = v.level
        end
    end
    local guildCfgId = soliderComparisonCfg[fightSoliders[id].cfgId].guildcfgId
    if guildCfgId and soliders[guildCfgId] then
        fightSoliders[id].cfgId = guildCfgId
        fightSoliders[id].level = soliders[guildCfgId]
    else
        fightSoliders[id].cfgId = guildBaseSolider
        fightSoliders[id].level = 1
    end
    fightSoliders[id].count = self:getGuildSoliderCount(heroId,fightSoliders[id].cfgId,fightSoliders[id].level, tmpTable)
end

function ArmyBag:_getStarmapCampaignSoldier(team, fightSoliders, index, tmpTable)
    if not team.buildId or team.buildId == 0 then
        return
    end
    if team.soliderCfgId and team.soliderCfgId ~= 0 then
        local armyId = team.buildId
        local army = self:getArmy(armyId)
        if not army then
            return
        end
        local armyteam = army.teams[index]
        if armyteam.soliderCfgId ~= team.soliderCfgId then
            self.player:say(util.i18nFormat(errors.BATTLE_SOLIDER_NOT_ENOUGH))
            return
        end
        if armyteam.soliderCount < team.soliderCount then
            self.player:say(util.i18nFormat(errors.BATTLE_SOLIDER_NOT_ENOUGH))
            return
        end
        -- ""，""team""
        if self.autoStatus == 1 then
            self:fillUpSoliders(armyId, index)
            team.soliderCount = self.armys[armyId].teams[index].soliderCount
        end
        local level = self.player.buildBag:getSoliderLevel(team.soliderCfgId)
        local id = self:_genStarmapCampaignSoldierId(armyId, index)
        fightSoliders[id] = {
            id = id,
            cfgId = team.soliderCfgId,
            count = team.soliderCount,
            level = level,
            dieCount = 0
        }
        -- ""
        -- local myUnionId = self:checkUseGuildArmy()
        -- if myUnionId then
        --     self:changeToGuildArmy(fightSoliders, myUnionId, id, team.heroId, tmpTable)
        -- end
        return true
    end
end

--""
function ArmyBag:takeStarmapCampaignArmy(gridCfgId, personalArmys)
    local warShipCount = {}
    local fightWarShips = {}
    local heroCount = {}
    local fightHeros = {}
    local fightSoliders = {}
    local tmpTable = {
        guildReserveCount = 0
    }
    for i, v in ipairs(personalArmys) do
        local warShipData = self:_checkArmyWarShip(v)
        if warShipData then
            warShipCount[v.warShipId] = warShipCount[v.warShipId] or 0
            warShipCount[v.warShipId] = warShipCount[v.warShipId] + 1
            fightWarShips[i] = warShipData
        else
            local warShip = self:_createStarmapBattleWarship()
            warShipData = warShip:pack()
            -- self:setFightLevel(warShipData)
            warShipCount[warShipData.id] = warShipCount[warShipData.id] or 0
            warShipCount[warShipData.id] = warShipCount[warShipData.id] + 1
            fightWarShips[i] = warShipData
        end
        local landShipCount = {}
        for ii, vv in ipairs(v.teams) do
            local heroData = self:_checkArmyHero(vv)
            if heroData then
                if not self:checkHeroBattleCd(heroData.battleCd) then
                    self.player:say(util.i18nFormat(errors.HERO_IN_BATTLE_CD))
                    return
                end
                heroCount[vv.heroId] = heroCount[vv.heroId] or 0
                heroCount[vv.heroId] = heroCount[vv.heroId] + 1
                fightHeros[i] = fightHeros[i] or {}
                fightHeros[i][ii] = heroData
            end
            local ok = self:_getStarmapCampaignSoldier(vv, fightSoliders, ii, tmpTable)
            if ok then
                local _id = self:_genStarmapCampaignSoldierId(vv.buildId, ii)
                landShipCount[_id] = landShipCount[_id] or 0
                landShipCount[_id] = landShipCount[_id] + 1
            end
        end
        for id, count in pairs(landShipCount) do
            if count > 1 then
                self.player:say(util.i18nFormat(errors.CAMPAIGN_LANDSHIP_REPEAT))
                return
            end
        end
    end
    for id, count in pairs(warShipCount) do
        if count > 1 then
            self.player:say(util.i18nFormat(errors.CAMPAIGN_ARMY_REPEAT))
            return
        end
    end
    for id, count in pairs(heroCount) do
        if count > 1 then
            self.player:say(util.i18nFormat(errors.CAMPAIGN_ARMY_REPEAT))
            return
        end
    end

    local fightArmys = {}
    for i, v in ipairs(personalArmys) do
        local armyInfo = { heros = {}, mainWarShip  = nil, soliders = {}, liberatorShips = {} }
        armyInfo.mainWarShip = fightWarShips[i]
        for ii, vv in ipairs(v.teams) do
            local heroData = (fightHeros[i] or {})[ii]
            if heroData then
                heroData.index = ii
                table.insert(armyInfo.heros, heroData)
            end
            if vv.buildId and vv.buildId ~= 0 then
                local _id = self:_genStarmapCampaignSoldierId(vv.buildId, ii)
                local soliderInfo = fightSoliders[_id]
                if soliderInfo then
                    soliderInfo.index = ii
                    table.insert(armyInfo.soliders, soliderInfo)
                end
            end
            table.insert(armyInfo.liberatorShips, {
                cfgId = gg.getGlobalCfgIntValue("UnionLiberatorShipCfgId", 3000013),
                quality = gg.getGlobalCfgIntValue("UnionLiberatorShipQuality", 0),
                level = gg.getGlobalCfgIntValue("UnionLiberatorShipLevel", 1),
            })
        end
        if not armyInfo.mainWarShip then
            self.player:say(util.i18nFormat(errors.ARMY_NO_WARSHIP))
            return
        end
        -- if table.count(armyInfo.heros) == 0 then
        --     self.player:say(util.i18nFormat(errors.ARMY_NO_HERO))
        --     return
        -- end
        local minCount = table.count(armyInfo.heros) + table.count(armyInfo.soliders)
        if minCount == 0 then
            self.player:say(util.i18nFormat(errors.CAMPAIGN_ARMY_EMPTY))
            return
        end
        fightArmys[armyInfo.mainWarShip.id] = armyInfo
    end
    return fightArmys
end

function ArmyBag:returnBackCampaignArmy(pid, fightArmy)
    if not fightArmy then
        return
    end
    local num = 0
    for i, v in ipairs(fightArmy.soliders) do
        num = num + self:getNeedReserveSolider(v.count, v.cfgId, v.level)
        -- local build = self.player.buildBag:getBuild(v.id)
        -- if build then
        --     if v.cfgId == build.soliderCfgId then
        --         build.soliderCount = build.soliderCount + v.count
        --         gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
        --     end
        -- end
    end
    --self.player.buildBag:addReserveArmyCount(num)
end

--""  pvp""
function ArmyBag:getFightArmy(armyId, battleType)
    local armyInfo = {}
    local warShip = self:getFightWarShip()
    if not warShip then
        return armyInfo
    end
    armyInfo.mainWarShip = warShip

    local soliders = self:getFightSoliders(armyId)
    -- if not soliders or not next(soliders) then
    --     return armyInfo
    -- end
    armyInfo.armyId = armyId
    armyInfo.armyType = constant.BATTLE_ARMY_TYPE_SELF
    armyInfo.mainWarShip = warShip
    armyInfo.soliders = soliders
    armyInfo.heros = self:getFightHeros(armyId)
    return armyInfo
end

function ArmyBag:fillUpSoliders(armyId,index)
    local army = self.armys[armyId]
    local team = army.teams[index]
    local Teamspace = self:getArmyTeamSpace(team.heroId)        -- ""

    local soliderLevel = self.player.buildBag:getSoliderLevel(team.soliderCfgId)
    local soliderCfgs = gg.getExcelCfgByFormat("soliderConfig", team.soliderCfgId, soliderLevel)
    local soliderSpace = team.soliderCount * soliderCfgs.trainSpace    -- "" 
    local remainderSpace = Teamspace - soliderSpace   -- "" = ""  - ""
    local num = remainderSpace // soliderCfgs.trainSpace    -- ""
    local needReserveSolider = self:getNeedReserveSolider(num, team.soliderCfgId, soliderLevel)  -- num""
    local reserveSolider = self.player.buildBag:getReserveArmyCount()        -- ""
    if reserveSolider < 0 then
        reserveSolider = 0
    end
    -- "" ""
    if reserveSolider < needReserveSolider then
        num = reserveSolider // soliderCfgs.trainSpace
        needReserveSolider = self:getNeedReserveSolider(num, team.soliderCfgId, soliderLevel)
    end
    team.soliderCount = team.soliderCount + num
    self.player.buildBag:costReserveArmyCount(needReserveSolider)
end

--""
function ArmyBag:getFightSoliders(armyId)
    local soliders = {}
    local teams = self.armys[armyId].teams
    local i = 1
    for ii, v in pairs(teams) do
        if v.soliderCfgId > 0 and v.soliderCount >= 0 then
            if self.autoStatus == 1 then
                self:fillUpSoliders(armyId,ii)
            end
            local level = self.player.buildBag:getSoliderLevel(v.soliderCfgId)
            local race = 0
            local soldierCfg = ggclass.SoliderLevel.getSoliderCfg(v.soliderCfgId, level)
            if soldierCfg then
                race = soldierCfg.race
            end
            table.insert(soliders, {
                index = ii,
                id = armyId + ii,
                cfgId = v.soliderCfgId,
                count = v.soliderCount,
                level = level,
                race = race,
                dieCount = 0,
            })
            i = i + 1
            if i > constant.BATTLE_MAX_SOLIDER_TEAM then
                break
            end
        end
    end
    
    return soliders
end

function ArmyBag:setFightLevel(packdata)
    local baseBuildLv = self.player.buildBag:getBaseBuildLevel()
    if packdata.level > baseBuildLv then
        packdata.level = baseBuildLv
    end
    return packdata.level
end

function ArmyBag:checkHeroBattleCd(battleCd)
    local nowTime = skynet.timestamp()
    if nowTime < battleCd and constant.BATTLE_USE_HERO_CD then
        self.player:say(util.i18nFormat(errors.HERO_IN_BATTLE_CD))
        return
    end
    return true
end

--""
function ArmyBag:getFightHeros(armyId)
    local heros = {}
    local teams = self.armys[armyId].teams
    for ii,team in pairs(teams) do
        -- ""
        local heroData = self:_checkArmyHero(team)
        if heroData then
            -- self:setFightLevel(heroData)
            heroData.index = ii
            table.insert(heros, heroData)
        end
    end
    if not next(heros) then
        self.player:say(util.i18nFormat(errors.ARMY_NO_HERO))
    end
    return heros
end

--""
function ArmyBag:getFightWarShip()
    local warShip = self.player.warShipBag:getCurrentWarShip()
    if not warShip then
        self.player:say(util.i18nFormat(errors.ARMY_NO_WARSHIP))
        return nil
    end
    if warShip.curLife <= 0 then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_LIFE))
        return nil
    end
    -- ""
    if not constant.IsRefNone(warShip) and not constant.IsRefLaunch(warShip) then
        self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
        return
    end
    local packdata = warShip:pack()
    -- self:setFightLevel(packdata)
    return packdata
end

--""
function ArmyBag:setFightTick(tick)
    local hero = self.player.heroBag:getCurrentHero()
    if hero then
        hero:setFightTick(tick)
    end
    local warShip = self.player.warShipBag:getCurrentWarShip()
    if warShip then
        warShip:setFightTick(tick)
    end
    local builds = self.player.buildBag:getBuildsByCfgId(constant.BUILD_LIBERATORSHIP)
    if builds and next(builds) then
        for _, build in pairs(builds) do
            build:setFightTick(tick)
        end
    end
end

function ArmyBag:setHeroBattleCd( )
    local cdTime = gg.getGlobalCfgIntValue("LeagueHeroBattleCD", 0)
    return skynet.timestamp() + cdTime * 1000
end

function ArmyBag:_costHerosLife(heros)
    for k, v in pairs(heros or {}) do
        local hero = self.player.heroBag:getHero(v.id)
        if hero then
            hero.curLife = hero.curLife - v.costLife
            if hero.curLife < 0 then
                hero.curLife = 0
            end
            -- if battleType and battleType == constant.BATTLE_TYPE_STAR then
            --     hero.battleCd = self:setHeroBattleCd()
            -- end
            gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
        end
    end
end

function ArmyBag:_costWarShipsLife(warShips)
    for index, v in pairs(warShips or {}) do
        local warShip = self.player.warShipBag:getWarShip(v.id)
        if warShip then
            warShip.curLife = warShip.curLife - v.costLife
            if warShip.curLife < 0 then
                warShip.curLife = 0
            end
            gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
        end
    end
end

function ArmyBag:putInOrderArmyTeams(armyId)
    local army = self.armys[armyId]
    if not army then
        return
    end
    local oldTeams = army.teams
    local newTeams = {}
    for i,team in pairs(oldTeams) do
        if team.heroId and team.heroId ~= 0 then
            table.insert(newTeams,team)
        end
    end
    army.teams = newTeams
end

function ArmyBag:_costSolidersLife(soliders,leftSoliders)
    -- "" ""
    if not soliders or not next(soliders) then
        return
    end
    if self.isUseGuildArmy == 0 then
        local armyId = 0
        for k, v in pairs(soliders or {}) do
            if k and v.index ~= 0 then
                armyId = v.id - v.index
                local army = self.armys[armyId]
                if army then
                    local teams = army.teams
                    local count = (teams[v.index].soliderCount - v.dieCount > 0) and (teams[v.index].soliderCount - v.dieCount) or 0
                    if count < 0 then
                        count = 0
                    end
                    teams[v.index].soliderCount = count
                end
            end
        end
        if armyId ~= 0 then
            self:putInOrderArmyTeams(armyId)
        end
    elseif self.isUseGuildArmy == 1 then
        local costReserveCount = 0
        for k, v in pairs(soliders or {}) do
            if k and v.index ~= 0 then
                local costReserve = self:getNeedReserveSolider(v.dieCount, v.cfgId, v.level)
                costReserveCount = costReserveCount + costReserve
            end
        end
        self.guildReserveCount = self.guildReserveCount - costReserveCount
        if self.guildReserveCount < 0 then
            self.guildReserveCount = 0
        end
        self:queryGuildReserve()
    end
end

function ArmyBag:starmapCampaignCostArmyLife(costArmyInfo, dieSoliders, leftSoliders)
    if costArmyInfo.mainWarShip then
        local warShip = self.player.warShipBag:getWarShip(costArmyInfo.mainWarShip.id)
        if warShip then
            warShip.curLife = costArmyInfo.mainWarShip.curLife
            gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
        end
    end
    for k, v in pairs(costArmyInfo.heros or {}) do
        local hero = self.player.heroBag:getHero(v.id)
        if hero then
            hero.curLife = v.curLife
            hero.battleCd = self:setHeroBattleCd()
            gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
        end
    end
    for k, v in pairs(dieSoliders or {}) do
        v.id = (v.id // 10) + v.index
    end
    self:_costSolidersLife(dieSoliders,leftSoliders)
end

function ArmyBag:costArmyLife(costArmyInfo, battleType)
    if not costArmyInfo then
        return
    end
    self:_costWarShipsLife(costArmyInfo.warShips)
    self:_costSolidersLife(costArmyInfo.soliders)
    self:_costHerosLife(costArmyInfo.heros, battleType)
end

function ArmyBag:newArmy(param)
    return ggclass.Army.create(param)
end

--armyId=int
--armyName=string
--teams = {
--  {heroId=int, soliderCfgId=int, soliderCount=int},
--   ...
--  {heroId=int, soliderCfgId=int, soliderCount=int}
--}
function ArmyBag:getArmy(armyId)
    if not self.armys[armyId] then
        self.player:say(util.i18nFormat(errors.ARMY_FORMATION_NOT_EXIST))
        return
    end
    return self.armys[armyId]
end

-- ""
function ArmyBag:getInArmyFormationHeros()
    local armys = self.armys
    local heros = {}
    for _, army in pairs(armys) do
        for _,team in pairs(army.teams) do
            if team.heroId ~= 0 and team.heroId then
                heros[team.heroId] = 1
            end
        end
    end
    return heros
end

function ArmyBag:checkInArmy(heroId)
    local heros = self:getInArmyFormationHeros()
    if heros[heroId] then
        self:setHeroRef(heroId, constant.REF_ARMY)
    end
end

--""
--@param[type=int] soliderCfgId ""id
--@param[type=int] level "" ""0
--@param[type=int] num ""
function ArmyBag:getNeedReserveSolider(num, soliderCfgId, level)
    level = level or 0
    local soliderCfgs = gg.getExcelCfgByFormat("soliderConfig", soliderCfgId, level)
    local soliderSpace = soliderCfgs.trainSpace
    return soliderSpace * num
end

-- ""
function ArmyBag:getArmyTeamBaseSpace()
    -- ""
    local baseBuildLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
    local buildCfgs = gg.getExcelCfgByFormat("buildConfig", constant.BUILD_BASE, 0, baseBuildLevel)
    local buildSoldierSpace = buildCfgs.buildSoldierSpace
    return buildSoldierSpace
end

-- ""
function ArmyBag:getArmyTeamSpace(heroId)
    heroId = heroId or 0
    local armyTeamSpace = 0
    -- ""
    local baseSpace = self:getArmyTeamBaseSpace()
    -- ""，"" ""+""
    if heroId and heroId ~= 0 then
        local heroData = self.player.heroBag:getHero(heroId)
        local heroCfg = gg.getExcelCfgByFormat("heroConfig", heroData.cfgId, heroData.quality, heroData.level)
        local heroSoldierSpace = heroCfg.heroSoldierSpace
        armyTeamSpace = heroSoldierSpace + baseSpace
    -- ""，""
    else
        armyTeamSpace = baseSpace
    end
    return armyTeamSpace
end

function ArmyBag:verifyArmyTeam(team)
    -- "" ""
    if (not team.heroId or team.heroId == 0)  and (team.soliderCfgId and team.soliderCfgId ~= 0) then
        self.player:say(util.i18nFormat(errors.ARMY_FORMATION_MUST_HAVA_HERO))
        return
    end

    -- ""
    if team.heroId and team.heroId ~= 0 then
        local hero = self.player.heroBag:getHero(team.heroId)
        if not hero then
            self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
            return
        end

        -- ""
        if not constant.IsRefNone(hero) and not constant.IsRefArmy(hero) then
            self.player:say(util.i18nFormat(errors.HERO_REF_BUSY))
            return
        end

        if hero.curLife <= 0 then
            self.player:say(util.i18nFormat(errors.HERO_NOT_LIFE))
        end
    end
    -- ""
    if team.soliderCfgId and team.soliderCfgId ~= 0 then
        if not team.soliderCount or team.soliderCount < 0 then
            self.player:say(util.i18nFormat(errors.ARG_ERR))
            return
        end

        -- ""
        local soliderLevel = self.player.buildBag:getSoliderLevel(team.soliderCfgId)
        --""cfgId"",""
        if not soliderLevel or soliderLevel <= 0 then
            self.player:say(util.i18nFormat(errors.SOLIDER_NOT_UNLOCK))
            return
        end
        local soliderCfgs = gg.getExcelCfgByFormat("soliderConfig", team.soliderCfgId, soliderLevel)
        local soliderSpace = soliderCfgs.trainSpace
        -- ""
        local armyTeamSpace = self:getArmyTeamSpace(team.heroId)
        if armyTeamSpace < team.soliderCount * soliderSpace  then
            self.player:say(util.i18nFormat(errors.ARMY_FORMATION_TEAM_NOT_SPACE))
            return
        end
    end
    return true
end

function ArmyBag:updateAutomatic(autoStatus)
    self.autoStatus = autoStatus
end

function ArmyBag:addArmys(armyId, armyName, teams)
    local armyData = {}
    armyData.armyId = armyId
    armyData.armyName = armyName
    local needReserveSoliderCount = 0          -- ""

    if self.armys[armyId] then
        self.player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end

    if #armyName >= 1 then
        local errcode = gg.isValidName(armyName)
        local errmsg
        if errcode ~= httpc.answer.code.OK then
            -- local response = httpc.answer.response(errcode)
            -- errmsg = response.message
            self.player:say(util.i18nFormat(errors.ARMY_FORMATION_NAME_IS_ILLEGAL))
            return
        end
    end

    local inArmyFormationHeros = self:getInArmyFormationHeros()
    for i,team in ipairs(teams or {}) do
        if i > 5 then
            break
        end

        -- ""teams""
        if i == 1 then
            if team.heroId == 0 and team.soliderCfgId == 0 then
                self.player:say(util.i18nFormat(errors.ARG_ERR))
                return
            end
        else
            local cur = teams[i-1]
            local next = teams[i]
            if cur.heroId == 0 and cur.soliderCfgId == 0 and (next.heroId ~= 0 or next.soliderCfgId ~= 0 )then
                self.player:say(util.i18nFormat(errors.ARG_ERR))
                return
            end
        end

        -- ""team
        if not self:verifyArmyTeam(team) then
            return
        end

        -- ""
        if team.heroId and team.heroId ~= 0 then
            if inArmyFormationHeros[team.heroId] then
                self.player:say(util.i18nFormat(errors.HERO_USING))
                return
            end
            inArmyFormationHeros[team.heroId] = 1
        end

        -- "" ""
        if team.soliderCfgId and team.soliderCfgId ~= 0 then
            local soliderLevel = self.player.buildBag:getSoliderLevel(team.soliderCfgId)
            local needReserveSolider = self:getNeedReserveSolider(team.soliderCount, team.soliderCfgId, soliderLevel)
            needReserveSoliderCount = needReserveSoliderCount + needReserveSolider
        end
    end   -- end for

    if needReserveSoliderCount > 0 then
        -- ""
        if not self.player.buildBag:costReserveArmyCount(needReserveSoliderCount) then
            self.player:say(util.i18nFormat(errors.RESERVE_ARMY_NOT_ENOUGH))
            return
        end
    end

    armyData.teams = teams
    local army = self:newArmy(armyData)
    if not army then
        self.player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    -- ""
    self.armys[army.armyId] = army
    -- ""
    self:queryArmys()
end

function ArmyBag:setHeroRef(heroId, ref)
    if not heroId or heroId == 0 then
        return
    end
    local hero = self.player.heroBag:getHero(heroId)
    if not hero then
        return
    end
    constant.setRef(hero, ref)
    -- local nowTime = skynet.time()
    -- -- ""
    -- if hero.nextTick > nowTime then
    --     constant.setRef(hero, constant.REF_LEVELUP)
    -- end
    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
end

function ArmyBag:updateArmy(armyId, index, teams, armyName)
    local oldData = self.armys[armyId]
    if not oldData then
        self.player:say(util.i18nFormat(errors.ARMY_FORMATION_NOT_EXIST))
        return
    end
    if next(teams) then
        local oldTeams = oldData.teams
        local newTeam = teams[1] or {}
        -- ""
        local inArmyFormationHeros = self:getInArmyFormationHeros()
         -- ""
        if newTeam.heroId and newTeam.heroId ~= 0 then
            if oldTeams[index] and oldTeams[index].heroId then
                inArmyFormationHeros[oldTeams[index].heroId] = nil
            end
            if inArmyFormationHeros[newTeam.heroId] then
                self.player:say(util.i18nFormat(errors.HERO_USING))
                return
            end
            inArmyFormationHeros[newTeam.heroId] = 1

            local hero = self.player.heroBag:getHero(newTeam.heroId)
            -- ""
            if not constant.IsRefNone(hero) and not constant.IsRefArmy(hero) then
                self.player:say(util.i18nFormat(errors.HERO_REF_BUSY))
                return
            end
            
        end
        if not self:verifyArmyTeam(newTeam) then
            return
        end

        -- ""/""
        if (newTeam.soliderCfgId and newTeam.soliderCfgId ~= 0) or (oldTeams[index] and oldTeams[index].soliderCfgId ~= 0 and newTeam.soliderCfgId == 0) then
            local newNeedReserveSolider = 0
            if newTeam.soliderCfgId ~= 0 then
                local newSoliderLevel = self.player.buildBag:getSoliderLevel(newTeam.soliderCfgId)
                newNeedReserveSolider = self:getNeedReserveSolider(newTeam.soliderCount, newTeam.soliderCfgId, newSoliderLevel)
            end

            local oldNeedReserveSolider = 0
            if oldTeams[index] then
                if oldTeams[index].soliderCfgId and oldTeams[index].soliderCfgId ~= 0 then
                    local oldSoliderLevel = self.player.buildBag:getSoliderLevel(oldTeams[index].soliderCfgId)
                    oldNeedReserveSolider = self:getNeedReserveSolider(oldTeams[index].soliderCount, oldTeams[index].soliderCfgId, oldSoliderLevel)
                end
            end

            local count = oldNeedReserveSolider - newNeedReserveSolider
            if count > 0 then
                if not self.player.buildBag:addReserveArmyCount(count) then
                    self.player:say(util.i18nFormat(errors.RESERVE_ARMY_NOT_ENOUGH))
                    return
                end
            elseif count < 0 then
                if not self.player.buildBag:costReserveArmyCount(-count) then
                    self.player:say(util.i18nFormat(errors.RESERVE_ARMY_NOT_ENOUGH))
                    return
                end
            end
        end
    
        for k,v in pairs(oldTeams) do
            if (not newTeam[k] or newTeam[k] == 0) and (oldTeams[k] or oldTeams ~=0) then
                newTeam[k] = oldTeams[k]
            end
        end
    
        if not oldTeams[index] then
            oldTeams[index] = {}
        end
        self:setHeroRef(oldTeams[index].heroId, constant.REF_NONE)
        self:setHeroRef(newTeam.heroId, constant.REF_ARMY)
        oldTeams[index].heroId = newTeam.heroId
        oldTeams[index].soliderCfgId = newTeam.soliderCfgId
        oldTeams[index].soliderCount = newTeam.soliderCount
        self:putInOrderArmyTeams(armyId)
    else
        if #armyName >= 1 then
            local errcode = gg.isValidName(armyName)
            local errmsg
            if errcode ~= httpc.answer.code.OK then
                -- local response = httpc.answer.response(errcode)
                -- errmsg = response.message
                self.player:say(util.i18nFormat(errors.ARMY_FORMATION_NAME_IS_ILLEGAL))
                return
            end
        end
        self.armys[armyId].armyName = armyName
    end
    self.player.taskBag:update(constant.TASK_ARMY_ADD_HERO, {count = self:getArmyHeroCount(armyId) })
    -- ""
    self:queryArmys()
end

function ArmyBag:getArmyHeroCount(armyId)
    local heroCount = 0
    for k,v in pairs(self.armys[armyId].teams or {}) do
        if v.heroId  and v.heroId ~= 0 then
            heroCount = heroCount + 1
        end
    end
    return heroCount
end

function ArmyBag:deleteArmys(armyId)
    local army = self.armys[armyId]
    if not army then
        self.player:say(util.i18nFormat(errors.ARMY_FORMATION_NOT_EXIST))
        return
    end
    -- ""
    local needReserveSoliderCount = 0
    for i, team in pairs(army.teams) do
        if team.soliderCfgId and team.soliderCfgId ~= 0 and team.soliderCount ~=0 then
            local soliderLevel = self.player.buildBag:getSoliderLevel(team.soliderCfgId)
            needReserveSoliderCount = needReserveSoliderCount + self:getNeedReserveSolider(team.soliderCount, team.soliderCfgId, soliderLevel)
        end
        if team.heroId and team.heroId ~= 0 then
            self:setHeroRef(team.heroId, constant.REF_NONE)
        end
    end
    if needReserveSoliderCount ~= 0 then
        if not self.player.buildBag:addReserveArmyCount(needReserveSoliderCount) then
            self.player:say(util.i18nFormat(errors.RESERVE_ARMY_NOT_ENOUGH))
            return
        end
    end
    self.armys[armyId] = nil

    self:queryArmys()
end

function ArmyBag:editedArmy(armyId,index,team)
    local army = self.armys[armyId]
    local teams = army.teams

    if team.heroId and team.heroId ~= 0 then
        local hero = self.player.heroBag:getHero(team.heroId)
        if not hero then
            self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
            return
        end
        self:setHeroRef(hero.id, constant.REF_ARMY)
        if army.teams[index].heroId and army.teams[index].heroId ~= 0 then
            self:setHeroRef(army.teams[index].heroId, constant.REF_NONE)
        end
    end
    if team.soliderCfgId and team.soliderCfgId ~= 0 then
        local soldierCfg = ggclass.SoliderLevel.getSoliderCfg(team.soliderCfgId, 0)
        if not soldierCfg then
            self.player:say(util.i18nFormat(errors.SOLIDER_NOT_EXIST))
            return
        end
        if team.soliderCount < 0 or team.soliderCount > 99 then
            self.player:say(util.i18nFormat(errors.SOLIDER_COUNT_NOT_LEGAL))
            return
        end
    end
    teams[index] = team
    self:queryArmys()
end

function ArmyBag:queryArmys()
    local data = {}
    for _,armyData in pairs(self.armys) do
        table.insert(data,armyData:serialize())
    end
    -- ""
    if self.autoStatus ~= 1 then
        self.autoStatus = 1
    end
    gg.client:send(self.player.linkobj, "S2C_Player_ArmysQuery", { data = data,autoStatus=self.autoStatus})
end

function ArmyBag:getGuildReserveCount()
    return self.guildReserveCount
end

function ArmyBag:reduceGuildReserveCount(num)
    if num < 0 then
        return
    end
    if num > self.guildReserveCount then
        return
    end
    self.guildReserveCount = self.guildReserveCount - num
    return true
end

function ArmyBag:increGuildReserveCount(num)
    if num <= 0 then
        return
    end
    self.guildReserveCount = self.guildReserveCount + num
    self:queryGuildReserve()
end

function ArmyBag:addGuildReserveCount(num)
    if num <= 0 then
        return
    end
    local costRes = gg.getGlobalCfgTableValue("GuildReserveArmyCostRes", {})
    local armyLimit = gg.getGlobalCfgIntValue("GuildReserveArmyLimt", 0)
    local guildReserveCount = self.guildReserveCount
    guildReserveCount = guildReserveCount + num
    if guildReserveCount > armyLimit then
        num = num - (guildReserveCount - armyLimit)
        guildReserveCount = armyLimit
    end

    local resDict = {}
    for i, v in ipairs(costRes) do
        resDict[v[1]] = v[2] * num
    end
    if not self.player.resBag:enoughResDict(resDict) then
        return
    end
    self.player.resBag:costResDict(resDict, {logType=gamelog.TRAIN_GUILD_RESERVE_ARMY})
    self.guildReserveCount = guildReserveCount
    self:queryGuildReserve()
end

function ArmyBag:isPersonalUnionSoldierEnough(solidersDict)
    local need = 0
    for k, v in pairs(solidersDict) do
        need = need + self:getNeedReserveSolider(v.soliderCount, k, v.level)
    end
    if self.guildReserveCount < need then
        return false
    end
    return true
end

function ArmyBag:costPersonalUnionSoldier(solidersDict)
    local need = 0
    for k, v in pairs(solidersDict) do
        need = need + self:getNeedReserveSolider(v.soliderCount, k, v.level)
    end
    if not self:reduceGuildReserveCount(need) then
        return false
    end
    self:queryGuildReserve()
    return true
end

function ArmyBag:returnBackPersonalUnionSoldier(soliders)
    local need = 0
    for i, v in pairs(soliders) do
        need = need + self:getNeedReserveSolider(v.count, v.cfgId, v.level)
    end
    self.guildReserveCount = self.guildReserveCount + need
    self:queryGuildReserve()
end

function ArmyBag:oneKeyFillUpSoliders(armyIds)
    -- ""
    if not armyIds or not next(armyIds) then
        for k,army in pairs(self.armys) do
            for index,team  in pairs(army.teams) do
                if team.soliderCfgId and team.soliderCfgId ~= 0 then
                    self:fillUpSoliders(army.armyId, index)
                end
            end
        end
    else
        for _,armyId in pairs(armyIds) do
            local army = self.armys[armyId]
            if army and next(army) then
                for index,team in pairs(army.teams) do
                    if team.soliderCfgId and team.soliderCfgId ~= 0 then
                        self:fillUpSoliders(army.armyId, index)
                    end
                end
            end
        end
    end
    self:queryArmys()
end

-- ""
function ArmyBag:queryGuildReserve()
    gg.client:send(self.player.linkobj, "S2C_Player_GuildReserveArmy", { isUseGuildArmy = self.isUseGuildArmy,guildReserveCount = self.guildReserveCount})
end

function ArmyBag:cleanAllArmy()
    for k,v in pairs(self.armys) do
        for _,team in pairs(v.teams) do
            if team.heroId and team.heroId ~= 0 then
                self:setHeroRef(team.heroId ,constant.REF_NONE)
            end
            if team.soliderCfgId and team.soliderCfgId ~= 0 then
                local level = self.player.buildBag:getSoliderLevel(team.soliderCfgId)
                local count = self:getNeedReserveSolider(team.soliderCount, team.soliderCfgId, level)
                self.player.buildBag:addReserveArmyCount(count)
            end
        end
    end
    self.armys = {}
    self:queryArmys()
end

-- ""
function ArmyBag:cleanArmy()
    for k,v in pairs(self.armys) do
        for _,team in pairs(v.teams) do
            if team.heroId and team.heroId ~= 0 then
                self:setHeroRef(team.heroId ,constant.REF_NONE)
            end
        end
    end
    self.armys = {}
    self:queryArmys()
end

function ArmyBag:setIsUseGuidArmy(isUseGuidArmy)
    self.isUseGuildArmy = 0 --isUseGuidArmy  --""
    self:queryGuildReserve()
end

function ArmyBag:onlogin()
    self:queryGuildReserve()
end

function ArmyBag:onreset()
    self:cleanArmy()
end

return ArmyBag