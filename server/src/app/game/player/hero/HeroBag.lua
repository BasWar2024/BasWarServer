local HeroBag = class("HeroBag")

function HeroBag:ctor(param)
    self.player = param.player                  -- 
    self.heros = {}                             -- 
    self.gift = false                           -- 
end

function HeroBag:newHero(param)
    param.player = self.player
    return ggclass.Hero.create(param)
end

function HeroBag:serialize()
    local data = {}
    data.heros = {}
    for _,hero in pairs(self.heros) do
        table.insert(data.heros, hero:serialize())
    end
    data.gift = self.gift
    return data
end

function HeroBag:deserialize(data)
    if not data then
        return
    end
    if data.heros and next(data.heros) then
        for _, heroData in ipairs(data.heros) do
            local hero = self:newHero(heroData)
            if hero then
                hero:deserialize(heroData)
                self.heros[hero.id] = hero
            end
        end
    end
    self.gift = data.gift or false
end

function HeroBag:packHero()
    local heroData = {}
    for id,hero in pairs(self.heros) do
        table.insert(heroData, hero:pack())
    end
    return heroData
end

function HeroBag:getHero(id)
    return self.heros[id]
end

function HeroBag:hasHero()
    return next(self.heros)
end

function HeroBag:getCurrentHero()
    local _, hero = next(self.heros)
    if not hero then
        return nil
    end
    return hero
end

--
function HeroBag:generateHero(cfgId, quality)
    local life = ggclass.Hero.randomHeroLife(quality)
    local curLife = life
    local param = { cfgId = cfgId, quality = quality, level = 1, life = life, curLife = curLife }
    return self:newHero(param)
end

--
function HeroBag:addHeroByParam(cfgId, quality, level, life, curLife, skillLevel1, skillLevel2, skillLevel3, notNotify)
    local param = { cfgId = cfgId, quality = quality, level = level, life = life, curLife = curLife, skillLevel1 = skillLevel1, skillLevel2 = skillLevel2, skillLevel3 = skillLevel3 }
    local hero = self:newHero(param)
    if hero and not next(self.heros) then
        self.heros[hero.id] = hero
        if not notNotify then
            gg.client:send(self.player.linkobj, "S2C_Player_HeroAdd",{ hero = hero:pack() })
        end
        return hero
    end
    return nil
end

--
function HeroBag:addHero(hero)
    if next(self.heros) then
        return nil
    end
    self.heros[hero.id] = hero
    gg.client:send(self.player.linkobj, "S2C_Player_HeroAdd",{ hero = hero:pack() })
    return hero
end

--
function HeroBag:delHero(id, source)
    local hero = self.heros[id]
    if not hero then
        return
    end
    self.heros[id] = nil
    gg.client:send(self.player.linkobj, "S2C_Player_HeroDel",{ id = id})
    return hero
end

--
function HeroBag:isHeroInFighting(id)
    local hero = self.heros[id]
    if not hero then
        return false
    end
    return hero:getLessTick() > 0
end

--
function HeroBag:isHeroInLevelUp(id)
    local hero = self.heros[id]
    if not hero then
        return false
    end
    return hero:getLessTick() > 0
end

--
function HeroBag:isHeroInSkillLevelUp(id)
    local hero = self.heros[id]
    if not hero then
        return false
    end
    return hero:getSkillUpLessTick() > 0
end

--
function HeroBag:isHeroHutBusy()
    local builds = self.player.buildBag:getBuildsByCfgId(constant.BUILD_HEROHUT)
    for _, build in pairs(builds) do
        if build:getLessTick() > 0 or build:getLessTrainTick() > 0 then
            return true
        end
    end
    return false
end

--
function HeroBag:isHeroBusy()
    for _,hero in pairs(self.heros) do
        if hero:getLessTick() > 0 or hero:getSkillUpLessTick() > 0 then
            return true
        end
    end
    return false
end

--
function HeroBag:levelUpHero(id,speedUp)
    local hero = self.heros[id]
    if not hero then
        self.player:say(i18n.format("no hero"))
        return
    end
    local curLevel = hero.level
    local nextLevel = curLevel + 1
    local nextCfg = ggclass.Hero.getHeroCfg(hero.cfgId, hero.quality, nextLevel)
    if not nextCfg then
        self.player:say(i18n.format("max level"))
        return
    end
    local cfg = ggclass.Hero.getHeroCfg(hero.cfgId, hero.quality, curLevel)
    if not cfg then
        self.player:say(i18n.format("error level"))
        return
    end

    if self:isHeroHutBusy() then
        self.player:say(i18n.format("error hero hut busy"))
        return
    end

    --
    if hero:getLessTick() > 0 or hero:getSkillUpLessTick() > 0 then
        self.player:say(i18n.format("error hero busy"))
        return
    end

    --
    local levelUpNeedBuilds = cfg.levelUpNeedBuilds or {}
    local arrive = true
    for _, info in ipairs(levelUpNeedBuilds) do
        local needCfgId = info[1]
        local needLevel = info[2]
        if self.player.buildBag:getBuildLevelByCfgId(needCfgId) < needLevel then
            arrive = false
            break
        end
    end
    if not arrive then
        self.player:say(i18n.format("less build level"))
        return
    end

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin) then
            self.player:say(i18n.format("less StarCoin"))
            return
        end
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        if not self.player.resBag:enoughRes(constant.RES_ICE, cfg.levelUpNeedIce) then
            self.player:say(i18n.format("less Ice"))
            return
        end
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl) then
            self.player:say(i18n.format("less Carboxyl"))
            return
        end
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        if not self.player.resBag:enoughRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium) then
            self.player:say(i18n.format("less Titanium"))
            return
        end
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        if not self.player.resBag:enoughRes(constant.RES_GAS, cfg.levelUpNeedGas) then
            self.player:say(i18n.format("less Gas"))
            return
        end
    end
    local SpeedUpNeedMit = 0
    if speedUp > 0 then
        local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
        local count = math.ceil((cfg.levelUpNeedTick or 0) / 60)
        SpeedUpNeedMit = SpeedUpPerMinute * count
        if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
            self.player:say(i18n.format("less Mit"))
            return
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    hero:setNextTick(levelUpNeedTick * 1000)

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin)
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        self.player.resBag:costRes(constant.RES_ICE, cfg.levelUpNeedIce)
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        self.player.resBag:costRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl)
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        self.player.resBag:costRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium)
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        self.player.resBag:costRes(constant.RES_GAS, cfg.levelUpNeedGas)
    end
    if speedUp > 0 then
        self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
    end

    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
end

--
function HeroBag:speedUpLevelUpHero(id)
    local hero = self.heros[id]
    if not hero then
        self.player:say(i18n.format("no hero"))
        return
    end
    local lessTick = hero:getLessTick()
    if lessTick <= 0 then
        self.player:say(i18n.format("error speedUp"))
        return
    end
    local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
    local count = math.ceil(lessTick / 60)
    local SpeedUpNeedMit = SpeedUpPerMinute * count
    if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
        self.player:say(i18n.format("less Mit"))
        return
    end
    hero:setNextTick(0)
    self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
end

--
function HeroBag:heroSkillUp(id, skillUp, speedUp)
    local hero = self.heros[id]
    if not hero then
        self.player:say(i18n.format("no hero"))
        return
    end
    local skillCfgId = hero["skill" .. skillUp] or 0
    if skillCfgId <= 0 then
        self.player:say(i18n.format("no skill"))
        return
    end
    local curLevel = hero["skillLevel" .. skillUp]
    local nextLevel = hero["skillLevel" .. skillUp] + 1
    local nextCfg = ggclass.Hero.getHeroSkillCfg(skillCfgId, nextLevel)
    if not nextCfg then
        self.player:say(i18n.format("max level"))
        return
    end
    local cfg = ggclass.Hero.getHeroSkillCfg(skillCfgId, curLevel)
    if not cfg then
        self.player:say(i18n.format("error level"))
        return
    end

    if self:isHeroHutBusy() then
        self.player:say(i18n.format("error hero hut busy"))
        return
    end

    --
    if hero:getLessTick() > 0 or hero:getSkillUpLessTick() > 0 then
        self.player:say(i18n.format("error hero busy"))
        return
    end

    --
    if curLevel >= hero.level then
        self.player:say(i18n.format("error skill level"))
        return
    end

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        if not self.player.resBag:enoughRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin) then
            self.player:say(i18n.format("less StarCoin"))
            return
        end
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        if not self.player.resBag:enoughRes(constant.RES_ICE, cfg.levelUpNeedIce) then
            self.player:say(i18n.format("less Ice"))
            return
        end
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl) then
            self.player:say(i18n.format("less Carboxyl"))
            return
        end
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        if not self.player.resBag:enoughRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium) then
            self.player:say(i18n.format("less Titanium"))
            return
        end
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        if not self.player.resBag:enoughRes(constant.RES_GAS, cfg.levelUpNeedGas) then
            self.player:say(i18n.format("less Gas"))
            return
        end
    end
    local SpeedUpNeedMit = 0
    if speedUp > 0 then
        local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
        local count = math.ceil((cfg.levelUpNeedTick or 0) / 60)
        SpeedUpNeedMit = SpeedUpPerMinute * count
        if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
            self.player:say(i18n.format("less Mit"))
            return
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    hero.skillUp = skillUp
    hero:setSkillUpNextTick(levelUpNeedTick * 1000)

    --
    if cfg.levelUpNeedStarCoin and cfg.levelUpNeedStarCoin > 0 then
        self.player.resBag:costRes(constant.RES_STARCOIN, cfg.levelUpNeedStarCoin)
    end
    if cfg.levelUpNeedIce and cfg.levelUpNeedIce > 0 then
        self.player.resBag:costRes(constant.RES_ICE, cfg.levelUpNeedIce)
    end
    if cfg.levelUpNeedCarboxyl and cfg.levelUpNeedCarboxyl > 0 then
        self.player.resBag:costRes(constant.RES_CARBOXYL, cfg.levelUpNeedCarboxyl)
    end
    if cfg.levelUpNeedTitanium and cfg.levelUpNeedTitanium > 0 then
        self.player.resBag:costRes(constant.RES_TITANIUM, cfg.levelUpNeedTitanium)
    end
    if cfg.levelUpNeedGas and cfg.levelUpNeedGas > 0 then
        self.player.resBag:costRes(constant.RES_GAS, cfg.levelUpNeedGas)
    end
    if speedUp > 0 then
        self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
    end

    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
end

--
function HeroBag:speedUpSkillUpHero(id)
    local hero = self.heros[id]
    if not hero then
        self.player:say(i18n.format("no hero"))
        return
    end
    local lessTick = hero:getSkillUpLessTick()
    if lessTick <= 0 then
        self.player:say(i18n.format("error speedUp"))
        return
    end
    local SpeedUpPerMinute = gg.getGlobalCgfIntValue("SpeedUpPerMinute")
    local count = math.ceil(lessTick / 60)
    local SpeedUpNeedMit = SpeedUpPerMinute * count
    if not self.player.resBag:enoughRes(constant.RES_MIT, SpeedUpNeedMit) then
        self.player:say(i18n.format("less Mit"))
        return
    end
    hero:setSkillUpNextTick(0)
    self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
end

--
function HeroBag:heroSelectSkill(id, selectSkill)
    local hero = self.heros[id]
    if not hero then
        self.player:say(i18n.format("no hero"))
        return
    end
    if hero.selectSkill == selectSkill then
        self.player:say(i18n.format("same skill"))
        return
    end
    local skillCfgId = hero["skill" .. selectSkill] or 0
    if skillCfgId <= 0 then
        self.player:say(i18n.format("no skill"))
        return
    end
    hero.selectSkill = selectSkill
    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
end

function HeroBag:heroMove2ItemBag(id)
    local hero = self.heros[id]
    if not hero then
        self.player:say(i18n.format("no hero"))
        return
    end

    if self:isHeroInLevelUp(id) then
        self.player:say(i18n.format("berth warship is level up"))
        return
    end

    if self:isHeroInSkillLevelUp(id) then
        self.player:say(i18n.format("berth warship is skill level up"))
        return
    end

    if self:isHeroInFighting(id) then
        self.player:say(i18n.format("berth warship is fighting"))
        return
    end

    local cfg = ggclass.Hero.getHeroCfg(hero.cfgId, hero.quality, hero.level)
    if not cfg then
        self.player:say(i18n.format("config not exist"))
        return
    end

    if not cfg.itemCfgId then
        self.player:say(i18n.format("hero can not move to itemBag"))
        return
    end

    if not self.player.itemBag:spaceIsEnough(1) then
        self.player:say(i18n.format("itemBag not engouh"))
        return
    end

    self:delHero(id, {reason = "move build to itemBag"})
    local targetParam = {
        targetCfgId = hero.cfgId,
        targetLevel = hero.level,
        targetQuality = hero.quality,
        skillLevel1 = hero.skillLevel1,
        skillLevel2 = hero.skillLevel2,
        skillLevel3 = hero.skillLevel3,
        skillLevel4 = hero.skillLevel4,
        skillLevel5 = hero.skillLevel5,
        life = hero.life,
        curLife = hero.curLife,
    }
    self.player.itemBag:addItem(cfg.itemCfgId,1,targetParam,{reason = "move warship to itemBag"})
end

function HeroBag:heroMoveOutItemBag(item, pos)
    assert(item, "item is not exist")
    local heros = table.values(self.heros)
    assert(#heros == 1 or #heros == 0, "must one warship can berth")
    local curHero = heros[1]
    local cfg
    if curHero then
        if self:isHeroInLevelUp(curHero.id) then
            self.player:say(i18n.format("hero is level up"))
            return
        end

        if self:isHeroInSkillLevelUp(curHero.id) then
            self.player:say(i18n.format("hero is skill level up"))
            return
        end

        if self:isHeroInFighting(curHero.id) then
            self.player:say(i18n.format("hero is fighting"))
            return
        end

        cfg = ggclass.Hero.getHeroCfg(curHero.cfgId, curHero.quality, curHero.level)
        if not cfg then
            self.player:say(i18n.format("hero not config"))
            return
        end
        self:delHero(curHero.id, {reason = "move hero to itemBag"})
    end

    self.player.itemBag:delItem(item.id, {reason="move hero out from itemBag"})

    if curHero then
        local targetParam = {
            targetCfgId = curHero.cfgId,
            targetLevel = curHero.level,
            targetQuality = curHero.quality,
            skillLevel1 = curHero.skillLevel1,
            skillLevel2 = curHero.skillLevel2,
            skillLevel3 = curHero.skillLevel3,
            skillLevel4 = curHero.skillLevel4,
            skillLevel5 = curHero.skillLevel5,
            life = curHero.life,
            curLife = curHero.curLife,
        }
        self.player.itemBag:addItem(cfg.itemCfgId,1,targetParam,{reason = "move hero to itemBag"})
    end

    local hero = self:addHeroByParam(item.targetCfgId, item.targetQuality, item.targetLevel,
        item.life, item.curLife, item.skillLevel1, item.skillLevel2, item.skillLevel3)
    assert(hero, "hero add failed")
end

function HeroBag:onload()
    if not self.gift then
        self.gift = true
        local cfgId = 2501001
        local quality = 1
        local level = 1
        local life = ggclass.Hero.randomHeroLife(quality)
        self:addHeroByParam(cfgId, quality, level, life, life, 0, 0, 0, true)
    end
    self:checkHeros(true)
end

function HeroBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_HeroData",{ heroData = self:packHero() })
end

function HeroBag:onSecond()
    self:checkHeros()
end

function HeroBag:checkHeros(notNotify)
    for _,hero in pairs(self.heros) do
        hero:checkLevelUp(notNotify)
        hero:checkSkillUp(notNotify)
    end
end

return HeroBag