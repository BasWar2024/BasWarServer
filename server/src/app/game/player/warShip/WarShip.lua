local WarShip = class("WarShip")

function WarShip.getWarShipSkillCfg(cfgId, level)
    local skillCfg = cfg.get("etc.cfg.skill")
    for k,v in pairs(skillCfg) do
        if v.cfgId == cfgId and v.level == level then
            return v
        end
    end
    return nil
end

function WarShip.randomWarShipLife(quality)
    local lifeInfo = nil
    local lifeCfg = cfg.get("etc.cfg.life")
    for k,v in pairs(lifeCfg) do
        if v.cfgId == constant.LIFE_TYPE_WAR_SHIP and v.quality == quality then
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

function WarShip.getWarShipCfg(cfgId, quality, level)
    local warShipCfg = cfg.get("etc.cfg.warShip")
    for k,v in pairs(warShipCfg) do
        if v.cfgId == cfgId and v.quality == quality and v.level == level then
            return v
        end
    end
    return nil
end

function WarShip.create(param)
    local cfgId = param.cfgId
    local level = param.level
    local quality = param.quality
    if not cfgId then
        return nil
    end
    level = level or 1
    quality = quality or 1
    local cfg = WarShip.getWarShipCfg(cfgId, quality, level)
    if not cfg then
        --
        return nil
    end
    param.cfg = cfg
    return WarShip.new(param)
end

function WarShip:ctor(param)
    self.player = param.player
    self.id = param.id or snowflake.uuid()                               -- uuid
    self.cfgId = param.cfgId                                             -- id
    self.level = param.level                                             --                                                -- 
    self.quality = param.quality                                         -- 
    self.life = param.life or constant.DEFAULT_LIFT                      -- 
    self.curLife = param.curLife or constant.DEFAULT_LIFT                -- 

    self.skillLevel1 = 0                                                 -- 1
    self.skillLevel2 = 0                                                 -- 2
    self.skillLevel3 = 0                                                 -- 3
    self.skillLevel4 = 0                                                 -- 4
    self.skillLevel5 = 0                                                 -- 5

    self.nextTick = param.nextTick or 0                                  -- 

    self.fightTick = param.fightTick or 0                                -- 

    self.skillUp = 0                                                     --
    self.skillUpNextTick = 0                                             --

    self:refreshConfig(param.cfg)
end

function WarShip:refreshConfig(cfg)
    local cfg = cfg or WarShip.getWarShipCfg(self.cfgId, self.quality, self.level)
    assert(cfg)

    self.skill1 = cfg.skill1 or 0                                       -- 1id
    self.skill2 = cfg.skill2 or 0                                       -- 2id
    self.skill3 = cfg.skill3 or 0                                       -- 3id
    self.skill4 = cfg.skill4 or 0                                       -- 4id
    self.skill5 = cfg.skill5 or 0                                       -- 5id

    if self.skill1 > 0 and self.skillLevel1 <= 0 then
        self.skillLevel1 = 1
    end
    if self.skill2 > 0 and self.skillLevel2 <= 0 then
        self.skillLevel2 = 1
    end
    if self.skill3 > 0 and self.skillLevel3 <= 0 then
        self.skillLevel3 = 1
    end
    if self.skill4 > 0 and self.skillLevel4 <= 0 then
        self.skillLevel4 = 1
    end
    if self.skill5 > 0 and self.skillLevel5 <= 0 then
        self.skillLevel5 = 1
    end
end

function WarShip:serialize()
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
    data.skillLevel4 = self.skillLevel4
    data.skillLevel5 = self.skillLevel5
    data.nextTick = self.nextTick
    data.skillUp = self.skillUp
    data.skillUpNextTick = self.skillUpNextTick
    return data
end

function WarShip:deserialize(data)
    self.cfgId = data.cfgId
    self.quality = data.quality or 1
    self.level = data.level
    self.life = data.life or -1
    self.curLife = data.curLife or -1
    self.skillLevel1 = data.skillLevel1 or 0
    self.skillLevel2 = data.skillLevel2 or 0
    self.skillLevel3 = data.skillLevel3 or 0
    self.skillLevel4 = data.skillLevel4 or 0
    self.skillLevel5 = data.skillLevel5 or 0
    self.nextTick = data.nextTick or 0
    self.skillUp = data.skillUp or 0
    self.skillUpNextTick = data.skillUpNextTick or 0

    self:refreshConfig()
end

function WarShip:pack()
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
    data.skill4 = self.skill4
    data.skill5 = self.skill5
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.skillLevel4 = self.skillLevel4
    data.skillLevel5 = self.skillLevel5
    data.lessTick = self:getLessTick()
    data.skillUp = self.skillUp
    data.skillUpLessTick = self:getSkillUpLessTick()
    return data
end

function WarShip:packToBattle()
    local data = {}


    return data
end

function WarShip:toItemParam()
    local warShipCfg = WarShip.getWarShipCfg(self.cfgId, self.quality, self.level)
    if not warShipCfg then
        return
    end
    if not warShipCfg.itemCfgId then
        return
    end
    local data = {}
    data.cfgId = warShipCfg.itemCfgId
    data.targetCfgId = self.cfgId
    data.targetLevel = self.level
    data.targetQuality = self.quality
    data.life = self.life
    data.curLife = self.curLife
    data.skillLevel1 = self.skillLevel1
    data.skillLevel2 = self.skillLevel2
    data.skillLevel3 = self.skillLevel3
    data.skillLevel4 = self.skillLevel4
    data.skillLevel5 = self.skillLevel5
    data.num = 1
    data.ref = 0
    return data
end

function WarShip:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick
end

function WarShip:getLessTick()
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

function WarShip:checkLevelUp(notNotify)
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
        gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = self:pack() })
    end
end

function WarShip:setSkillUpNextTick(needTick)
    self.skillUpNextTick = skynet.timestamp() + needTick
end

function WarShip:getSkillUpLessTick()
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

function WarShip:checkSkillUp(notNotify)
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
        gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = self:pack() })
    end
end

function WarShip:setFightTick(fightTick)
    self.fightTick = fightTick
end


return WarShip