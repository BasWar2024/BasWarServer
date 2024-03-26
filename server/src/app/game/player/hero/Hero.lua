local Hero = class("Hero")

function Hero.getHeroSkillCfg(cfgId, quality, level)
    local key = string.format("%s_%s", cfgId, level)
    local skillCfgs = cfg.get("etc.cfg.skillConfig")
    return skillCfgs[key]
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
    return gg.getExcelCfgByFormat("heroConfig", cfgId, quality, level)
    -- local key = string.format("%s_%s_%s", cfgId, quality, level)
    -- local heroCfgs = cfg.get("etc.cfg.heroConfig")
    -- return heroCfgs[key]
end

function Hero.getNFTHeroCfg(race, style, quality, level)
    return gg.getExcelCfgByFormat("heroNftConfig", race, style, quality, level)
    -- local key = string.format("%s_%s_%s_%s", race, style, quality, level)
    -- local heroCfgs = cfg.get("etc.cfg.heroNftConfig")
    -- return heroCfgs[key]
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
        --""
        return nil
    end
    param.cfg = cfg
    return Hero.new(param)
end

function Hero:ctor(param)
    self.player = param.player
    self.id = param.id or snowflake.uuid()                               -- ""uuid
    self.cfgId = param.cfgId                                             -- ""id                                               -- ""
    self.quality = param.quality or constant.HERO_INIT_QUALITY           -- ""
    self.race = param.race
    self.style = param.style
    self.level = param.level or constant.HERO_INIT_LEVEL                 -- ""
    self.life = param.life or constant.DEFAULT_LIFT                      -- ""
    self.curLife = param.curLife or constant.DEFAULT_LIFT                -- ""

    self.skill1 = param.skill1 or 0
    self.skill2 = param.skill2 or 0
    self.skill3 = param.skill3 or 0

    self.skillLevel1 = param.skillLevel1 or 0                            -- ""1""
    self.skillLevel2 = param.skillLevel2 or 0                            -- ""2""
    self.skillLevel3 = param.skillLevel3 or 0                            -- ""3""
    self.selectSkill = param.selectSkill or 1                            -- ""

    self.nextTick = param.nextTick or 0                                  -- ""
    self.fightTick = param.fightTick or 0                                -- ""
    self.repairTick = param.repairTick or 0

    self.skillUp = 0                                                     --""
    self.skillUpNextTick = 0                                             --""
    self.chain = param.chain or 0                                        --NFT""id,0""

    self.ref = param.ref or 0                                --0-"" 1-"" 2-"" 3-"" 4-"" 5-""("")
    self.refBy = param.refBy or 0                            --""ref>0"","", ""item"", ""ref=4, refBy=0, "", ""refBy>0
    self.donateTime = param.donateTime or 0
    self.ownerPid = param.ownerPid or 0
    self.mintCount = param.mintCount or 0
    self.battleCd = param.battleCd or 0                     -- ""cd""
    self:refreshConfig(param.cfg)
end

function Hero:refreshConfig(cfg)
    self.cfg = cfg or Hero.getHeroCfg(self.cfgId, self.quality or 1, self.level or 1)
    assert(self.cfg, "config not found")
    self.race = self.race or self.cfg.race
    self.style = self.style or self.cfg.style

    -- init skill
    for i, v in ipairs(self.cfg.initSkill or {}) do
        if v ~= 0 and self["skill"..i] == 0 then
            self["skill"..i] = v
            self["skillLevel"..i] = 1
        end
    end

end

function Hero:serialize()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.quality = self.quality
    data.race = self.race
    data.style = self.style
    data.level = self.level
    data.life = self.life
    data.curLife = self.curLife
    data.skill1 = util.getSaveVal(self.skill1)
    data.skill2 = util.getSaveVal(self.skill2)
    data.skill3 = util.getSaveVal(self.skill3)
    data.skillLevel1 = util.getSaveVal(self.skillLevel1)
    data.skillLevel2 = util.getSaveVal(self.skillLevel2)
    data.skillLevel3 = util.getSaveVal(self.skillLevel3)
    data.nextTick = util.getSaveVal(self.nextTick)
    data.skillUp = util.getSaveVal(self.skillUp)
    data.skillUpNextTick = util.getSaveVal(self.skillUpNextTick)
    data.selectSkill = util.getSaveVal(self.selectSkill)
    data.fightTick = util.getSaveVal(self.fightTick)
    data.chain = self.chain

    data.ref = util.getSaveVal(self.ref)
    data.refBy = util.getSaveVal(self.refBy)
    data.donateTime = util.getSaveVal(self.donateTime)
    data.ownerPid = util.getSaveVal(self.ownerPid)
    data.mintCount = util.getSaveVal(self.mintCount)
    data.battleCd = self.battleCd or 0
    return data
end

function Hero:deserialize(data)
    self.cfgId = data.cfgId or 0
    self.quality = data.quality or 1
    self.race = data.race
    self.style = data.style
    self.level = data.level or 1
    self.life = data.life or -1
    self.curLife = data.curLife or -1
    self.skill1 = data.skill1 or 0
    self.skill2 = data.skill2 or 0
    self.skill3 = data.skill3 or 0
    self.skillLevel1 = data.skillLevel1 or 0
    self.skillLevel2 = data.skillLevel2 or 0
    self.skillLevel3 = data.skillLevel3 or 0
    self.nextTick = data.nextTick or 0
    self.skillUp = data.skillUp or 0
    self.skillUpNextTick = data.skillUpNextTick or 0
    self.selectSkill = data.selectSkill or 1
    self.fightTick = data.fightTick or 0
    self.chain = data.chain or 0
    self:refreshConfig()

    self.ref = data.ref or 0
    self.refBy = data.refBy or 0
    self.donateTime = data.donateTime or 0
    self.ownerPid = data.ownerPid or 0
    self.mintCount = data.mintCount or 0
    self.battleCd = data.battleCd or 0
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
    data.chain = self.chain

    data.ref = self.ref
    data.refBy = self.refBy
    data.donateTime = self.donateTime
    data.ownerPid = self.ownerPid
    data.mintCount = self.mintCount
    data.battleCd = self.battleCd
    return data
end

function Hero:packToLog()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.quality = self.quality
    data.race = self.race
    data.style = self.style
    data.level = self.level
    data.life = self.life
    data.curLife = self.curLife
    data.skill1 = self.skill1
    data.skill2 = self.skill2
    data.skill3 = self.skill3
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.chain = self.chain
    return data
end

function Hero:packToDonate()
    local data = {}
    data.id = self.id
    data.cfgId = self.cfgId
    data.quality = self.quality
    data.race = self.race
    data.style = self.style
    data.level = self.level
    data.life = self.life
    data.curLife = self.curLife
    data.skill1 = self.skill1
    data.skill2 = self.skill2
    data.skill3 = self.skill3
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.nextTick = self.nextTick
    data.skillUp = self.skillUp
    data.skillUpNextTick = self.skillUpNextTick
    data.selectSkill = self.selectSkill
    data.fightTick = self.fightTick
    data.chain = self.chain

    data.ref = self.ref
    data.refBy = self.refBy
    data.donateTime = self.donateTime
    data.ownerPid = self.ownerPid
    data.mintCount = self.mintCount
    data.isLevelUp = self:isLevelUp()
    data.isSkillUp = self:isSkillUp()
    data.isUpgrade = self:isUpgrade()
    return data
end

function Hero:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick
    --constant.setRef(self, constant.REF_LEVELUP)
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
    -- ""
    if constant.IsRefLevelUp(self) then
        local inArmyHeros = self.player.armyBag:getInArmyFormationHeros()
        if inArmyHeros[self.id] then
            constant.setRef(self, constant.REF_ARMY)
        else
            constant.cancelRef(self, constant.REF_LEVELUP)
        end
    end
    --self.player.armyBag:checkInArmy(self.id)
    self.level = self.level + 1
    self:refreshConfig()
    self.player.taskBag:update(constant.TASK_HERO_LV, {cfgId = self.cfgId, lv = self.level})
    self.player.taskBag:update(constant.TASK_HERO_LVUP, {cfgId = 3000002})
    self.player.buildBag:updateSanctuary(self.id)
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = self:pack() })
    end
end

function Hero:isLevelUp()
    local nowTick = skynet.timestamp()
    if nowTick > self.nextTick then
        return false
    end
    return true
end

function Hero:isUpgrade()
    if self:isLevelUp() then
        return true
    end
    if self:isSkillUp() then
        return true
    end
    return false
end

function Hero:setSkillUpNextTick(needTick)
    self.skillUpNextTick = skynet.timestamp() + needTick
    --constant.setRef(self, constant.REF_SKILLUP)
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

function Hero:isSkillUp()
    local nowTick = skynet.timestamp()
    if nowTick > self.skillUpNextTick then
        return false
    end
    return true
end

function Hero:checkSkillUp(notNotify)
    if self.skillUpNextTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.skillUpNextTick then
        return
    end
    local skillUp = self.skillUp
    self.skillUpNextTick = 0
    --constant.cancelRef(self, constant.REF_SKILLUP)
    self.player.armyBag:checkInArmy(self.id)
    self["skillLevel" .. self.skillUp] = self["skillLevel" .. self.skillUp] + 1
    self.skillUp = 0
    self:refreshConfig()
    self.player.taskBag:update(constant.TASK_HERO_SKILL_LV, {skillId = skillUp, lv = self["skillLevel" .. skillUp]})
    self.player.taskBag:update(constant.TASK_HERO_SKILL_LVUP, {skillId = skillUp})
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = self:pack() })
    end
end

function Hero:setFightTick(fightTick)
    self.fightTick = fightTick
end

function Hero:setRefBy(refBy)
    self.refBy = refBy
end

function Hero:checkSkillChange(notNotify)
    local cfg = gg.getExcelCfgByFormat("heroConfig", self.cfgId, self.quality, self.level)
    if not cfg then
        return
    end
    local skillId = (cfg.initSkill or {})[1]
    if skillId == 0 then
        return
    end
    if skillId == self["skill"..1] then
        return
    end
    self["skill"..1] = skillId
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = self:pack() })
    end
end

return Hero