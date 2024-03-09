local Hero = class("Hero")

function Hero.getHeroSkillCfg(cfgId, level)
    local skillCfg = cfg.get("etc.cfg.skill")
    for k,v in pairs(skillCfg) do
        if v.cfgId == cfgId and v.level == level then
            return v
        end
    end
    return nil
end

function Hero.randomHeroLife(quality)
    local lifeInfo = nil
    local lifeCfg = cfg.get("etc.cfg.life")
    for k,v in pairs(lifeCfg) do
        if v.cfgId == constant.LIFE_TYPE_HERO and v.quality == quality then
            lifeInfo =  v
            break
        end
    end
    if not lifeInfo then
        return constant.DEFAULT_LIFT
    end
    local minLift = lifeInfo.minLift
    local maxLift = lifeInfo.maxLift
    return math.random(minLift, maxLift)
end

function Hero.getHeroCfg(cfgId, quality, level)
    local heroCfg = cfg.get("etc.cfg.hero")
    for k,v in pairs(heroCfg) do
        if v.cfgId == cfgId and v.quality == quality and v.level == level then
            return v
        end
    end
    return nil
end

function Hero.create(param)
    local cfgId = param.cfgId
    local level = param.level
    local quality = param.quality
    if not cfgId then
        return nil
    end
    level = level or 1
    quality = quality or 1
    local cfg = Hero.getHeroCfg(cfgId, quality, level)
    if not cfg then
        --
        return nil
    end
    param.cfg = cfg
    return Hero.new(param)
end

function Hero:ctor(param)
    self.player = param.player
    self.id = param.id or snowflake.uuid()                               -- uuid
    self.cfgId = param.cfgId                                             -- id                                               -- 
    self.quality = param.quality                                         -- 
    self.level = param.level                                             -- 
    self.life = param.life or constant.DEFAULT_LIFT                      -- 
    self.curLife = param.curLife or constant.DEFAULT_LIFT                -- 

    self.skillLevel1 = param.skillLevel1 or 0                            -- 1
    self.skillLevel2 = param.skillLevel2 or 0                            -- 2
    self.skillLevel3 = param.skillLevel3 or 0                            -- 3
    self.selectSkill = param.selectSkill or 1                            -- 

    self.nextTick = param.nextTick or 0                                  -- 

    self.fightTick = param.fightTick or 0                                -- 

    self.skillUp = 0                                                     --
    self.skillUpNextTick = 0                                             --

    self:refreshConfig(param.cfg)
end

function Hero:refreshConfig(cfg)
    local cfg = cfg or Hero.getHeroCfg(self.cfgId, self.quality, self.level)
    assert(cfg)

    self.skill1 = cfg.skill1 or 0                                       -- 1id
    self.skill2 = cfg.skill2 or 0                                       -- 2id
    self.skill3 = cfg.skill3 or 0                                       -- 3id

    if self.skill1 > 0 and self.skillLevel1 <= 0 then
        self.skillLevel1 = 1
    end
    if self.skill2 > 0 and self.skillLevel2 <= 0 then
        self.skillLevel2 = 1
    end
    if self.skill3 > 0 and self.skillLevel3 <= 0 then
        self.skillLevel3 = 1
    end
end

function Hero:serialize()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.quality = self.quality
    data.level = self.level
    data.life = self.life
    data.curLife = self.curLife
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.nextTick = self.nextTick
    data.skillUp = self.skillUp
    data.skillUpNextTick = self.skillUpNextTick
    data.selectSkill = self.selectSkill
    data.fightTick = self.fightTick
    return data
end

function Hero:deserialize(data)
    self.cfgId = data.cfgId
    self.quality = data.quality or 1
    self.level = data.level
    self.life = data.life or -1
    self.curLife = data.curLife or -1
    self.skillLevel1 = data.skillLevel1 or 0
    self.skillLevel2 = data.skillLevel2 or 0
    self.skillLevel3 = data.skillLevel3 or 0
    self.nextTick = data.nextTick or 0
    self.skillUp = data.skillUp or 0
    self.skillUpNextTick = data.skillUpNextTick or 0
    self.selectSkill = data.selectSkill or 1
    self.fightTick = data.fightTick

    self:refreshConfig()
end

function Hero:pack()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.quality = self.quality
    data.level = self.level
    data.life = self.life
    data.curLife = self.curLife
    data.skill1 = self.skill1
    data.skill2 = self.skill2
    data.skill3 = self.skill3
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.lessTick = self:getLessTick()
    data.skillUp = self.skillUp
    data.skillUpLessTick = self:getSkillUpLessTick()
    data.selectSkill = self.selectSkill
    return data
end

function Hero:toItemParam()
    local heroCfg = Hero.getHeroCfg(self.cfgId, self.quality, self.level)
    if not heroCfg then
        return
    end
    if not heroCfg.itemCfgId then
        return
    end
    local data = {}
    data.cfgId = heroCfg.itemCfgId
    data.targetCfgId = self.cfgId
    data.targetLevel = self.level
    data.targetQuality = self.quality
    data.life = self.life
    data.curLife = self.curLife
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.skillLevel4 = 0
    data.skillLevel5 = 0
    data.num = 1
    data.ref = 0
    return data
end

function Hero:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick
end

function Hero:getLessTick()
    if self.nextTick <= 0 then
        return 0
    end
    local nowTick = skynet.timestamp()
    local lessTick = math.floor((self.nextTick - nowTick) / 1000)
    if lessTick <= 0 then
        return 0
    end
    return lessTick
end

function Hero:checkLevelUp(notNotify)
    if self.nextTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.nextTick then
        return
    end
    self.nextTick = 0
    self.level = self.level + 1
    self:refreshConfig()
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = self:pack() })
    end
end

function Hero:setSkillUpNextTick(needTick)
    self.skillUpNextTick = skynet.timestamp() + needTick
end

function Hero:getSkillUpLessTick()
    if self.skillUpNextTick <= 0 then
        return 0
    end
    local nowTick = skynet.timestamp()
    local lessTick = math.floor((self.skillUpNextTick - nowTick) / 1000)
    if lessTick <= 0 then
        return 0
    end
    return lessTick
end

function Hero:checkSkillUp(notNotify)
    if self.skillUpNextTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.skillUpNextTick then
        return
    end
    self.skillUpNextTick = 0
    self["skillLevel" .. self.skillUp] = self["skillLevel" .. self.skillUp] + 1
    self.skillUp = 0
    self:refreshConfig()
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = self:pack() })
    end
end

function Hero:setFightTick(fightTick)
    self.fightTick = fightTick
end

return Hero