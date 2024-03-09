local WarShipBag = class("WarShipBag")

function WarShipBag:ctor(param)
    self.player = param.player                  -- 
    self.warShips = {}                          -- 
    self.gift = false                           -- 
end

function WarShipBag:newWarShip(param)
    param.player = self.player
    return ggclass.WarShip.create(param)
end

function WarShipBag:serialize()
    local data = {}
    data.warShips = {}
    for _,warShip in pairs(self.warShips) do
        table.insert(data.warShips, warShip:serialize())
    end
    data.gift = self.gift
    return data
end

function WarShipBag:deserialize(data)
    if not data then
        return
    end
    if data.warShips and next(data.warShips) then
        for _, warShipData in ipairs(data.warShips) do
            local warShip = self:newWarShip(warShipData)
            if warShip then
                warShip:deserialize(warShipData)
                self.warShips[warShip.id] = warShip
            end
        end
    end
    self.gift = data.gift or false
end

function WarShipBag:packWarShip()
    local warShipData = {}
    for id,warShip in pairs(self.warShips) do
        table.insert(warShipData, warShip:pack())
    end
    return warShipData
end

function WarShipBag:getWarShip(id)
    return self.warShips[id]
end

function WarShipBag:hasWarShip()
    return next(self.warShips)
end

--
function WarShipBag:getCurrentWarShip()
    local _, warShip = next(self.warShips)
    if not warShip then
        return nil
    end
    return warShip
end

--
function WarShipBag:generateWarShip(cfgId, quality)
    local life = ggclass.WarShip.randomWarShipLife(quality)
    local curLife = life
    local param = { cfgId = cfgId, quality = quality, level = 1, life = life, curLife = curLife }
    return self:newWarShip(param)
end

--
function WarShipBag:addWarShipByParam(cfgId, quality, level, life, curLife, skillLevel1, skillLevel2, skillLevel3, skillLevel4, skillLevel5, notNotify)
    local param = { cfgId = cfgId, quality = quality, level = level, life = life, curLife = curLife, skillLevel1 = skillLevel1, skillLevel2 = skillLevel2, skillLevel3 = skillLevel3, skillLevel4 = skillLevel4, skillLevel5 = skillLevel5 }
    local warShip = self:newWarShip(param)
    if warShip and not next(self.warShips) then
        self.warShips[warShip.id] = warShip
        if not notNotify then
            gg.client:send(self.player.linkobj, "S2C_Player_WarShipAdd",{ warShip = warShip:pack() })
        end
        return warShip
    end
    return nil
end

--
function WarShipBag:addWarShip(warShip)
    if next(self.warShips) then
        return nil
    end
    self.warShips[warShip.id] = warShip
    gg.client:send(self.player.linkobj, "S2C_Player_WarShipAdd",{ warShip = warShip:pack() })
    return warShip
end

--
function WarShipBag:delWarShip(id, source)
    local warShip = self.warShips[id]
    if not warShip then
        return
    end
    self.warShips[id] = nil
    gg.client:send(self.player.linkobj, "S2C_Player_WarShipDel",{ id = id})
    return warShip
end

--
function WarShipBag:isWarShipInFighting(id)
    local warShip = self.warShips[id]
    if not warShip then
        return
    end
end

--
function WarShipBag:isWarShipInLevelUp(id)
    local warShip = self.warShips[id]
    if not warShip then
        return
    end
    return warShip:getLessTick() > 0
end

--
function WarShipBag:isWarShipInSkillLevelUp(id)
    local warShip = self.warShips[id]
    if not warShip then
        return
    end
    return warShip:getSkillUpLessTick() > 0
end

--
function WarShipBag:levelUpWarShip(id, speedUp)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(i18n.format("no warShip"))
        return
    end
    local curLevel = warShip.level
    local nextLevel = curLevel + 1
    local nextCfg = ggclass.WarShip.getWarShipCfg(warShip.cfgId, warShip.quality, nextLevel)
    if not nextCfg then
        self.player:say(i18n.format("max level"))
        return
    end
    local cfg = ggclass.WarShip.getWarShipCfg(warShip.cfgId, warShip.quality, curLevel)
    if not cfg then
        self.player:say(i18n.format("error level"))
        return
    end

    --
    if warShip:getLessTick() > 0 or warShip:getSkillUpLessTick() > 0 then
        self.player:say(i18n.format("error warShip busy"))
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
    warShip:setNextTick(levelUpNeedTick * 1000)

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

    gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
end

--
function WarShipBag:speedUpLevelUpWarShip(id)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(i18n.format("no warShip"))
        return
    end
    local lessTick = warShip:getLessTick()
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
    warShip:setNextTick(0)
    self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
end

--
function WarShipBag:warShipSkillUp(id, skillUp, speedUp)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(i18n.format("no warShip"))
        return
    end
    local skillCfgId = warShip["skill" .. skillUp] or 0
    if skillCfgId <= 0 then
        self.player:say(i18n.format("no skill"))
        return
    end
    local curLevel = warShip["skillLevel" .. skillUp]
    local nextLevel = warShip["skillLevel" .. skillUp] + 1
    local nextCfg = ggclass.WarShip.getWarShipSkillCfg(skillCfgId, nextLevel)
    if not nextCfg then
        self.player:say(i18n.format("max level"))
        return
    end
    local cfg = ggclass.WarShip.getWarShipSkillCfg(skillCfgId, curLevel)
    if not cfg then
        self.player:say(i18n.format("error level"))
        return
    end

    --
    if warShip:getLessTick() > 0 or warShip:getSkillUpLessTick() > 0 then
        self.player:say(i18n.format("error warShip busy"))
        return
    end

    --
    if curLevel >= warShip.level then
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
    warShip.skillUp = skillUp
    warShip:setSkillUpNextTick(levelUpNeedTick * 1000)

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

    gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
end

--
function WarShipBag:speedUpSkillUpWarShip(id)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(i18n.format("no warShip"))
        return
    end
    local lessTick = warShip:getSkillUpLessTick()
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
    warShip:setSkillUpNextTick(0)
    self.player.resBag:costRes(constant.RES_MIT, SpeedUpNeedMit)
end

--
function WarShipBag:warShipMove2ItemBag(id)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(i18n.format("no warShip"))
        return
    end

    if self:isWarShipInLevelUp(warShip.id) then
        self.player:say(i18n.format("berth warship is level up"))
        return
    end

    if self:isWarShipInSkillLevelUp(warShip.id) then
        self.player:say(i18n.format("berth warship is skill level up"))
        return
    end

    if self:isWarShipInFighting(warShip.id) then
        self.player:say(i18n.format("berth warship is fighting"))
        return
    end

    local cfg = ggclass.WarShip.getWarShipCfg(warShip.cfgId, warShip.quality, warShip.level)
    if not cfg then
        self.player:say(i18n.format("config not exist"))
        return
    end

    if not cfg.itemCfgId then
        self.player:say(i18n.format("warShip can not move to itemBag"))
        return
    end

    if not self.player.itemBag:spaceIsEnough(1) then
        self.player:say(i18n.format("itemBag not engouh"))
        return
    end

    self:delWarShip(id, {reason = "move build to itemBag"})
    local targetParam = {
        targetCfgId = warShip.cfgId,
        targetLevel = warShip.level,
        targetQuality = warShip.quality,
        skillLevel1 = warShip.skillLevel1,
        skillLevel2 = warShip.skillLevel2,
        skillLevel3 = warShip.skillLevel3,
        skillLevel4 = warShip.skillLevel4,
        skillLevel5 = warShip.skillLevel5,
        life = warShip.life,
        curLife = warShip.curLife,
    }
    self.player.itemBag:addItem(cfg.itemCfgId,1,targetParam,{reason = "move warship to itemBag"})
end

--
function WarShipBag:warShipMoveOutItemBag(item, pos)
    assert(item, "item is not exist")
    local berthWarShip = self:getCurrentWarShip()
    local cfg
    --
    if berthWarShip then
        if self:isWarShipInLevelUp(berthWarShip.id) then
            self.player:say(i18n.format("berth warship is level up"))
            return
        end

        if self:isWarShipInSkillLevelUp(berthWarShip.id) then
            self.player:say(i18n.format("berth warship is skill level up"))
            return
        end

        if self:isWarShipInFighting(berthWarShip.id) then
            self.player:say(i18n.format("berth warship is fighting"))
            return
        end

        cfg = ggclass.WarShip.getWarShipCfg(berthWarShip.cfgId, berthWarShip.quality, berthWarShip.level)
        if not cfg then
            self.player:say(i18n.format("warship not config"))
            return
        end

        self:delWarShip(berthWarShip.id, {reason = "move build to itemBag"})
    end

    self.player.itemBag:delItem(item.id, {reason = "move warship out from itemBag"})

    --,
    if berthWarShip then
        local targetParam = {
            targetCfgId = berthWarShip.cfgId,
            targetLevel = berthWarShip.level,
            targetQuality = berthWarShip.quality,
            skillLevel1 = berthWarShip.skillLevel1,
            skillLevel2 = berthWarShip.skillLevel2,
            skillLevel3 = berthWarShip.skillLevel3,
            skillLevel4 = berthWarShip.skillLevel4,
            skillLevel5 = berthWarShip.skillLevel5,
            life = berthWarShip.life,
            curLife = berthWarShip.curLife,
        }
        self.player.itemBag:addItem(cfg.itemCfgId,1,targetParam,{reason = "move warship to itemBag"})
    end

    local warShip = self:addWarShipByParam(item.targetCfgId, item.targetQuality, item.targetLevel, item.life,
        item.curLife, item.skillLevel1, item.skillLevel2, item.skillLevel3, item.skillLevel4, item.skillLevel5)
end

function WarShipBag:onload()
    if not self.gift then
        self.gift = true
        local cfgId = 3501001
        local quality = 1
        local level = 1
        local life = ggclass.WarShip.randomWarShipLife(quality)
        self:addWarShipByParam(cfgId, quality, level, life, life, 0, 0, 0, 0, 0, true)
    end
    self:checkWarShips(true)
end

function WarShipBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_WarShipData",{ warShipData = self:packWarShip() })
end

function WarShipBag:onSecond()
    self:checkWarShips()
end

function WarShipBag:checkWarShips(notNotify)
    for _,warShip in pairs(self.warShips) do
        warShip:checkLevelUp(notNotify)
        warShip:checkSkillUp(notNotify)
    end
end

return WarShipBag