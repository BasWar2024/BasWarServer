local HeroBag = class("HeroBag")

function HeroBag:ctor(param)
    self.player = param.player                  -- ""
    self.heros = {}                             -- ""
    self.useId = nil
end

function HeroBag:newHero(param)
    param.player = self.player
    return ggclass.Hero.create(param)
end

function HeroBag:serialize()
    local data = {}
    data.useId = self.useId
    data.heros = {}
    for _,hero in pairs(self.heros) do
        table.insert(data.heros, hero:serialize())
    end
    return data
end

function HeroBag:deserialize(data)
    if not data then
        return
    end
    self.useId = data.useId
    if data.heros and next(data.heros) then
        for _, heroData in ipairs(data.heros) do
            local hero = self:newHero(heroData)
            if hero then
                 hero:deserialize(heroData)
                self.heros[hero.id] = hero
            end
        end
    end
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

function HeroBag:getTotalHero()
    return table.count(self.heros)
end

function HeroBag:checkHeroTotal()
    local maxCount = gg.getGlobalCfgIntValue("HQBagMax", 100)
    return maxCount < self:getTotalHero()
end

-- ""，""
-- excludeHeros ""，""
function HeroBag:getSortHeros(excludeHeros)
    local heros =self.heros
    excludeHeros = excludeHeros or {}
    local temp = {}
    for k,hero in pairs(heros) do
        if not excludeHeros[hero.id] then
            table.insert(temp, {
                id = hero.id,
                cfgId = hero.cfgId,
                quality = hero.quality,
                level = hero.level,
                atk = hero.cfg.atk,
                maxHp = hero.cfg.maxHp,
            })
        end
    end
    local sortHeros = temp
    table.sort(sortHeros, function(a, b)
        if a.level > b.level then
            return true
        elseif a.level < b.level then
            return false
        end
        return a.quality > b.quality
    end)
    return sortHeros
end

--""NFT""
function HeroBag:getNftHeros()
    local heros = {}
    for k, v in pairs(self.heros) do
        if v.chain > 0 then
            table.insert(heros, v)
        end
    end
    return heros
end

--""
function HeroBag:getNormalHeros()
    local heros = {}
    for k, v in pairs(self.heros) do
        if v.chain <= 0 then
            table.insert(heros, v)
        end
    end
    return heros
end

function HeroBag:getCurrentHero()
    return self.heros[self.useId]
end

function HeroBag:initialHeroNFT(param)
    logger.logf("info","ChainBridge","op=HeroBag:initialHeroNFT step1 pid=%d data=%s", self.player.pid, table.dump(param))
    local heroCfg = ggclass.Hero.getNFTHeroCfg(param.race, param.style, param.quality, param.level)
    if not heroCfg then
        logger.logf("info","ChainBridge","op=HeroBag:initialHeroNFT step2 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    param.id = param.token_id
    param.cfgId = heroCfg.cfgId
    param.chain = param.mint_type
    if not param.life or param.life <= 0 then
        param.life = ggclass.Hero.randomHeroLife(param.quality)
        param.curLife = param.life
    else
        param.curLife = param.life
    end
    local hero = self:newHero(param)
    if not hero then
        logger.logf("info","ChainBridge","op=HeroBag:initialHeroNFT step4 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    hero:deserialize(param)
    local ret = self:addHero(hero, {logType=gamelog.BRIDGE_RECHARGE_NFT})
    if not ret then
        logger.logf("info","ChainBridge","op=HeroBag:initialHeroNFT step5 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    logger.logf("info","ChainBridge","op=HeroBag:initialHeroNFT step6 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
    return hero
end

--""
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
function HeroBag:addHero(hero, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=HeroBag:addHero " .. debug.traceback())
        return nil
    end
    self.heros[hero.id] = hero
    self.player.buildBag:autoAddSanctuary()
    if not source.notNotify then
        gg.client:send(self.player.linkobj, "S2C_Player_HeroAdd",{ hero = hero:pack() })
    end
    gg.internal:send(".gamelog", "api", "addEntityLog", self.player.pid, self.player.platform, "add", source.logType, gamelog[source.logType], constant.ITEM_HERO, hero:packToLog())
    self.player.autoPushBag:setAutoPushStatus(constant.AUTOPUSH_CFGID_NEW_HERO)
    if source.logType ~= gamelog.DRAW_CARD then
         local data = {}
        data[hero.cfgId] = { cfgId = hero.cfgId, quality = hero.quality}
        self.player.drawCardBag:isNewGet(data)
    end
   
    return hero
end

--""
function HeroBag:delHero(id, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=HeroBag:delHero " .. debug.traceback())
        return nil
    end
    local hero = self.heros[id]
    if not hero then
        return nil
    end
    self.heros[id] = nil
    local inSanctuaryHeros = self.player.buildBag:getInSanctuaryHeros()
    if inSanctuaryHeros[id] then
        self.player.buildBag:delSanctuaryHero(id)
    end
    gg.client:send(self.player.linkobj, "S2C_Player_HeroDel",{ id = id})
    gg.internal:send(".gamelog", "api", "addEntityLog", self.player.pid, self.player.platform, "del", source.logType, gamelog[source.logType], constant.ITEM_HERO, hero:packToLog())
    return hero
end

--""
function HeroBag:levelUpHero(id,speedUp)
    local hero = self.heros[id]
    if not hero then
        self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
        return
    end

    local curLevel = hero.level
    local nextLevel = curLevel + 1
    local nextCfg = ggclass.Hero.getHeroCfg(hero.cfgId, hero.quality, nextLevel)
    if not nextCfg then
        self.player:say(util.i18nFormat(errors.LEVEL_MAX))
        return
    end
    local cfg = ggclass.Hero.getHeroCfg(hero.cfgId, hero.quality, curLevel)
    if not cfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    -- ""
    if not constant.REF_CANLEVELUP[hero.ref] then
        self.player:say(util.i18nFormat(errors.HERO_REF_BUSY))
        return
    end

    --""
    local arrive, msg = self.player.buildBag:preBuildLevelAndCountEnough(cfg.levelUpNeedBuilds)
    if not arrive then
        self.player:say(msg)
        return
    end

    local resDict = {
        [constant.RES_STARCOIN] = cfg.levelUpNeedStarCoin or 0,
        [constant.RES_ICE] = cfg.levelUpNeedIce or 0,
        [constant.RES_TESSERACT] = cfg.levelUpNeedTesseract or 0,
        [constant.RES_TITANIUM] = cfg.levelUpNeedTitanium or 0,
        [constant.RES_GAS] = cfg.levelUpNeedGas or 0,
        [constant.RES_MIT] = cfg.levelUpNeedMit or 0,
    }
    --if constant.IsRefLevelUp(hero) then
    if hero:isLevelUp() then
        if speedUp == 0 then
            --"",""
            self.player:say(util.i18nFormat(errors.LEVELINGUP))
            return
        else
            --"",""
            local lessTick = hero:getLessTick()
            local timeTesseract = self.player.resBag:timeCostTesseract(lessTick)
            if not self.player.resBag:enoughRes(constant.RES_TESSERACT, timeTesseract) then
                self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
                return
            end
            self.player.resBag:costRes(constant.RES_TESSERACT, timeTesseract, {logType=gamelog.SPEED_HERO_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        end
    else
        if speedUp == 0 then
            --"",""
            local newResDict = upgradeUtil.calResCost(self, resDict, nil)
            if not self.player.resBag:enoughResDict(newResDict) then
                return
            end
            self.player.resBag:costResDict(newResDict, {logType=gamelog.HERO_LEVEL_UP})
        else
            --"",""
            local timeTesseract = self.player.resBag:timeCostTesseract(cfg.levelUpNeedTick)
            local resTesseract = self.player.resBag:resCostTesseract(resDict)
            local allTesseract = timeTesseract + resTesseract
            local newResDict = {
                [constant.RES_MIT] = resDict[constant.RES_MIT] or 0,
                [constant.RES_TESSERACT] = (resDict[constant.RES_TESSERACT] or 0) + allTesseract,
            }
            if not self.player.resBag:enoughResDict(newResDict) then
                return
            end
            self.player.resBag:costResDict(newResDict, {logType=gamelog.SOON_HERO_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    hero:setNextTick(levelUpNeedTick * 1000)

    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
end

--""
function HeroBag:heroSkillUp(id, skillUp, speedUp)
    local hero = self.heros[id]
    if not hero then
        self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
        return
    end
    local skillCfgId = hero["skill" .. skillUp] or 0
    if skillCfgId <= 0 then
        self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
        return
    end
    local curLevel = hero["skillLevel" .. skillUp]
    local nextLevel = hero["skillLevel" .. skillUp] + 1
    local nextCfg = ggclass.Hero.getHeroSkillCfg(skillCfgId, hero.quality, nextLevel)
    if not nextCfg then
        self.player:say(util.i18nFormat(errors.SKILL_LEVEL_MAX))
        return
    end
    local cfg = ggclass.Hero.getHeroSkillCfg(skillCfgId, hero.quality, curLevel)
    if not cfg then
        self.player:say(util.i18nFormat(errors.SKILL_CONFIG_NOT_EXIST))
        return
    end

    if not constant.REF_CANLEVELUP[hero.ref] then
        self.player:say(util.i18nFormat(errors.HERO_REF_BUSY))
        return
    end

    -- if constant.IsRefSkillUp(hero) and skillUp ~= hero.skillUp then
    --     self.player:say(util.i18nFormat(errors.LEVELINGUP))
    --     return
    -- end

    --""
    -- if curLevel >= hero.level then
    --     self.player:say(util.i18nFormat(errors.SKILL_LEVEL_HERO_LIMIT))
    --     return
    -- end

    local itemDict = {}
    for i, v in ipairs(cfg.levelUpShard or {}) do
        itemDict[v[1]] = v[2]
    end

    local resDict = {
        [constant.RES_STARCOIN] = cfg.levelUpNeedStarCoin or 0,
        [constant.RES_ICE] = cfg.levelUpNeedIce or 0,
        [constant.RES_TESSERACT] = cfg.levelUpNeedTesseract or 0,
        [constant.RES_TITANIUM] = cfg.levelUpNeedTitanium or 0,
        [constant.RES_GAS] = cfg.levelUpNeedGas or 0,
        [constant.RES_MIT] = cfg.levelUpNeedMit or 0,
    }
    --if constant.IsRefSkillUp(hero) then
    if hero:isSkillUp() then
        if speedUp == 0 then
            --"",""
            self.player:say(util.i18nFormat(errors.LEVELINGUP))
            return
        else
            --"",""
            local lessTick = hero:getSkillUpLessTick()
            local timeTesseract = self.player.resBag:timeCostTesseract(lessTick)
            if not self.player.resBag:enoughRes(constant.RES_TESSERACT, timeTesseract) then
                self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
                return
            end
            self.player.resBag:costRes(constant.RES_TESSERACT, timeTesseract, {logType=gamelog.SPEED_HERO_SKILL_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        end
    else
        if speedUp == 0 then
            --"",""
            local newResDict = upgradeUtil.calResCost(self, resDict, nil)
            if not self.player.resBag:enoughResDict(newResDict) then
                return
            end
            if not self.player.itemBag:isItemDictEnough(itemDict) then
                return
            end
            self.player.resBag:costResDict(newResDict, {logType=gamelog.HERO_SKILL_LEVEL_UP})
            self.player.itemBag:costItemDict(itemDict, {logType=gamelog.HERO_SKILL_LEVEL_UP})
        else
            --"",""
            local timeTesseract = self.player.resBag:timeCostTesseract(cfg.levelUpNeedTick)
            local resTesseract = self.player.resBag:resCostTesseract(resDict)
            local allTesseract = timeTesseract + resTesseract
            local newResDict = {
                [constant.RES_MIT] = resDict[constant.RES_MIT] or 0,
                [constant.RES_TESSERACT] = (resDict[constant.RES_TESSERACT] or 0) + allTesseract,
            }
            if not self.player.resBag:enoughResDict(newResDict) then
                return
            end
            if not self.player.itemBag:isItemDictEnough(itemDict) then
                return
            end
            self.player.resBag:costResDict(newResDict, {logType=gamelog.SOON_HERO_SKILL_LEVEL_UP})
            self.player.itemBag:costItemDict(itemDict, {logType=gamelog.SOON_HERO_SKILL_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        end
    end
    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    hero.skillUp = skillUp
    hero:setSkillUpNextTick(levelUpNeedTick * 1000)
    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate", { hero = hero:pack() })
end

function HeroBag:heroPutonSkill(id, skillIndex, itemCfgId)
    local hero = self.heros[id]
    if not hero then
        self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
        return
    end
    local skillCfgId = hero["skill" .. skillIndex]
    if (skillCfgId or 0) > 0 then
        self.player:say(util.i18nFormat(errors.SKILL_CANT_PUTON))
        return
    end
    local itemNum = self.player.itemBag:getItemNumByCfgId(itemCfgId)
    if itemNum < 1 then
        self.player:say(util.i18nFormat(errors.ITEM_NOT_EXIST))
        return
    end
    local itemCfg = gg.getExcelCfg("item")[itemCfgId]
    if not itemCfg then
        self.player:say(util.i18nFormat(errors.ITEM_CFG_NOT_EXIST))
        return
    end
    local skillCfg = gg.getExcelCfgByFormat("skillConfig", itemCfg.skillCfgID[1], itemCfg.skillCfgID[2])
    if skillCfg.skillEquitType ~= constant.SKILL_EQUIP_VARIABLE then
        self.player:say(util.i18nFormat(errors.SKILL_EQUIP_TYPE_ERR))
        return
    end
    if skillCfg.useSkillUnit ~= constant.SKILL_HERO_USE then
        self.player:say(util.i18nFormat(errors.SKILL_UNIT_ERR))
        return
    end
    self.player.itemBag:costItem(itemCfgId, 1, {logType=gamelog.HERO_PUTON_SKILL})
    hero["skill" .. skillIndex] = itemCfg.skillCfgID[1]
    hero["skillLevel" .. skillIndex] = itemCfg.skillCfgID[2]
    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate", { hero = hero:pack() })
end

function HeroBag:heroResetSkill(id, skillIndex)
    local hero = self.heros[id]
    if not hero then
        self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
        return
    end
    local skillCfgId = hero["skill" .. skillIndex]
    if not skillCfgId or skillCfgId == 0 then
        self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
        return
    end
    local curLevel = hero["skillLevel" .. skillIndex]
    if curLevel <= 1 then
        self.player:say(util.i18nFormat(errors.SKILL_CANT_RESET))
        return
    end
    local skillCfg = gg.getExcelCfgByFormat("skillConfig", skillCfgId, curLevel)
    if skillCfg.skillEquitType ~= constant.SKILL_EQUIP_FIXED then
        self.player:say(util.i18nFormat(errors.SKILL_CANT_RESET))
        return
    end
    for i, v in ipairs(skillCfg.forgetRewardShard) do
        local addItemId = v[1]
        local addCount = v[2]
        self.player.itemBag:addItem(addItemId, addCount, {logType = gamelog.HERO_RESET_SKILL})
    end
    local resDict = {}
    for i, v in ipairs(skillCfg.forgetRewardResources) do
        resDict[v[1]] = v[2]
    end
    self.player.resBag:addResDict(resDict, { logType = gamelog.HERO_RESET_SKILL })
    hero["skillLevel" .. skillIndex] = 1
    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate", { hero = hero:pack() })
end

function HeroBag:heroForgetSkill(id, skillIndex)
    local hero = self.heros[id]
    if not hero then
        self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
        return
    end
    local skillCfgId = hero["skill" .. skillIndex]
    if not skillCfgId or skillCfgId == 0 then
        self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
        return
    end
    local curLevel = hero["skillLevel" .. skillIndex]
    local skillCfg = gg.getExcelCfgByFormat("skillConfig", skillCfgId, curLevel)
    if skillCfg.skillEquitType ~= constant.SKILL_EQUIP_VARIABLE then
        self.player:say(util.i18nFormat(errors.SKILL_CANT_FORGET))
        return
    end
    for i, v in ipairs(skillCfg.forgetRewardShard) do
        local addItemId = v[1]
        local addCount = v[2]
        self.player.itemBag:addItem(addItemId, addCount, {logType = gamelog.HERO_FORGET_SKILL})
    end
    local resDict = {}
    for i, v in ipairs(skillCfg.forgetRewardResources) do
        resDict[v[1]] = v[2]
    end
    self.player.resBag:addResDict(resDict, { logType = gamelog.HERO_FORGET_SKILL })
    hero["skill" .. skillIndex] = 0
    hero["skillLevel" .. skillIndex] = 0
    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate", { hero = hero:pack() })
end

function HeroBag:heroRepair(id)
    local hero = self.heros[id]
    if not hero then
        self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
        return
    end
    if constant.IsRefUnion(hero) or constant.IsRefGrid(hero) then
        self.player:say(util.i18nFormat(errors.HERO_REF_BUSY))
        return
    end
    local repairLife = hero.life - hero.curLife
    if repairLife <= 0 then
        self.player:say(util.i18nFormat(errors.REPAIR_NOT_NEED))
        return
    end
    local repairCostCfg = gg.getExcelCfg("repairCost")
    local costTesseract = repairCostCfg[hero.level].cost
    if not self.player.resBag:enoughRes(constant.RES_STARCOIN, costTesseract) then
        self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_STARCOIN]))
        return
    end
    self.player.resBag:costRes(constant.RES_STARCOIN, costTesseract, { logType = gamelog.REPAIR_HERO_LIFE })
    self.player.taskBag:update(constant.TASK_REPAIR_COUNT, {})
    hero.curLife = hero.life
    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
end

--""
function HeroBag:heroSelectSkill(id, selectSkill)
    local hero = self.heros[id]
    if not hero then
        self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
        return
    end
    if hero.selectSkill == selectSkill then
        self.player:say(util.i18nFormat(errors.SKILL_SAME))
        return
    end
    local skillCfgId = hero["skill" .. selectSkill] or 0
    if skillCfgId <= 0 then
        self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
        return
    end
    hero.selectSkill = selectSkill
    self.player.taskBag:update(constant.TASK_HERO_SWITCH_SKILL, {skillId = hero.selectSkill})
    gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
end

function HeroBag:setUseHero(id)
    if self.useId == id then
        return
    end
    local hero = self.heros[id]
    if not hero then
        self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
        return
    end
    self.useId = id
    gg.client:send(self.player.linkobj,"S2C_Player_UseHeroUpdate",{useId = self.useId })
end

function HeroBag:dismantleHero(heroIds)
    local items = {}
    for _,heroId in ipairs(heroIds) do
        -- ""
        local hero = self.heros[heroId]
        if not hero then
            self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
            return
        end
        if hero.chain > 0 then
            self.player:say(util.i18nFormat(errors.NFT_CANNOT_DISMANTLING))
            return
        end
        if hero:isUpgrade() then
            self.player:say(util.i18nFormat(errors.HERO_LEVEL_OR_SKILL_UP))
            return
        end
        if not constant.IsRefNone(hero) then
            self.player:say(util.i18nFormat(errors.HERO_REF_BUSY))
            return
        end
        for i=1,3 do
            if i == 1 then
                if hero["skillLevel" .. i] > 1 then
                    self.player:say(util.i18nFormat(errors.HERO_NOT_FORGET_SKILL))
                    return
                end
            else
                if hero["skillLevel" .. i] > 0 then
                    self.player:say(util.i18nFormat(errors.HERO_NOT_FORGET_SKILL))
                    return
                end
            end
        end
        -- ""
        local skillCfg = ggclass.Hero.getHeroSkillCfg(hero.skill1, hero.quality, hero.skillLevel1)
        if not skillCfg then
            self.player:say(util.i18nFormat(errors.SKILL_CONFIG_NOT_EXIST))
            return
        end
        local itemCfgId = skillCfg.itemCfgId
        if not itemCfgId then
            self.player:say(util.i18nFormat(errors.ITEM_NOT_EXIST))
            return
        end
        local num = 0
        local res = {}
        num,res = self.player.itemBag:addItem(itemCfgId, 1, { logType=gamelog.DISMANTLING_HERO })
        for k,v in pairs(res) do
            local item = v:pack()
            table.insert(items, {id = item.id, cfgId = item.cfgId, num = num})
        end
        self:delHero(heroId, { logType=gamelog.DISMANTLING_HERO })
    end
    gg.client:send(self.player.linkobj,"S2C_Player_DismantleReward", { result = true, items = items})
end

-- ""
function HeroBag:sellHero(heroIds)
    local delIds = {}
    local rewardCount = 0
    for _,heroId in ipairs(heroIds) do
        -- ""
        local hero = self.heros[heroId]
        if not hero then
            self.player:say(util.i18nFormat(errors.HERO_NOT_EXIST))
            return
        end
        if hero.chain > 0 then
            self.player:say(util.i18nFormat(errors.NFT_CANNOT_SELL))
            return
        end
        if hero:isUpgrade() then
            self.player:say(util.i18nFormat(errors.HERO_LEVEL_OR_SKILL_UP))
            return
        end
        if not constant.IsRefNone(hero) then
            self.player:say(util.i18nFormat(errors.HERO_REF_BUSY))
            return
        end
        for i=1,3 do
            if i == 1 then
                if hero["skillLevel" .. i] > 1 then
                    self.player:say(util.i18nFormat(errors.HERO_NOT_FORGET_SKILL))
                    return
                end
            else
                if hero["skillLevel" .. i] > 0 then
                    self.player:say(util.i18nFormat(errors.HERO_NOT_FORGET_SKILL))
                    return
                end
            end
        end
        -- ""
        local sellingPrice = gg.getGlobalCfgTableValue("SellingPrice", {})
        local resNum = sellingPrice[hero.quality]
        rewardCount = rewardCount + resNum
        table.insert(delIds, heroId)
    end
    for _,Id in pairs(delIds) do
        self:delHero(Id, { logType=gamelog.SELL_HERO })
    end
    self.player.resBag:addRes(constant.RES_STARCOIN, rewardCount, {logType=gamelog.SELL_HERO})
    local resInfo = {}
    table.insert(resInfo, { resCfgId = constant.RES_STARCOIN, count = rewardCount})
    resInfo.resCfgId = constant.RES_STARCOIN
    gg.client:send(self.player.linkobj, "S2C_Player_TipNote",  { tipType = 1, resInfo = resInfo })
end

function HeroBag:returnFromUnion(idList, nftLifeDict)
    for i, id in ipairs(idList) do
        local hero = self:getHero(id)
        if hero then
            hero.ref = constant.REF_NONE
            hero.refBy = 0
            hero.donateTime = 0
            hero.ownerPid = 0
            if nftLifeDict[id] then
                hero.curLife = nftLifeDict[id]
            end
            gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
        end
    end
end

function HeroBag:oncreate()
    if not next(self.heros) then
        local cfgId = gg.getGlobalCfgIntValue("InitHeroCfgId", 2000001)
        local quality = gg.getGlobalCfgIntValue("InitHeroQuality", 1)
        local level = gg.getGlobalCfgIntValue("InitHeroLevel", 1)
        local life = ggclass.Hero.randomHeroLife(quality)
        local param = {
            cfgId = cfgId,
            quality = quality,
            level = level,
            life = life,
            curLife = life,
        }
        local hero = self:newHero(param)
        if hero then
            local ret = self:addHero(hero, { logType = gamelog.CREATE_PLAYER_GIFT, notNotify = true })
            if ret then
                self.useId = hero.id
            end
        end
    end
end

function HeroBag:onload()
    self:checkHeros(true)
    self:checkHerosSkillChange(true)
end

function HeroBag:resetData()
    for _,hero in pairs(self.heros) do
        hero.level = 1
        hero.nextTick = 0                                  -- ""
        hero.fightTick = 0                                -- ""
        hero.repairTick = 0

        hero.ref = 0                               
        hero.refBy = 0                           
        hero.donateTime = 0
        hero.ownerPid = 0
        hero.mintCount = 0
        hero.battleCd = 0                     -- ""cd""
    end
end

function HeroBag:onreset()
    self:resetData()
end

function HeroBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_HeroData",{ heroData = self:packHero(), useId = self.useId })
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

function HeroBag:checkHerosSkillChange(notNotify)
    for _,hero in pairs(self.heros) do
        hero:checkSkillChange(notNotify)
    end
end

return HeroBag