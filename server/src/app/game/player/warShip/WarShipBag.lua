local WarShipBag = class("WarShipBag")

function WarShipBag:ctor(param)
    self.player = param.player                  -- ""
    self.warShips = {}                          -- ""
    self.useId = nil
end

function WarShipBag:newWarShip(param)
    param.player = self.player
    return ggclass.WarShip.create(param)
end

function WarShipBag:serialize()
    local data = {}
    data.useId = self.useId
    data.warShips = {}
    for _,warShip in pairs(self.warShips) do
        table.insert(data.warShips, warShip:serialize())
    end
    return data
end

function WarShipBag:deserialize(data)
    if not data then
        return
    end
    self.useId = data.useId
    if data.warShips and next(data.warShips) then
        for _, warShipData in ipairs(data.warShips) do
            local warShip = self:newWarShip(warShipData)
            if warShip then
                warShip:deserialize(warShipData)
                self.warShips[warShip.id] = warShip
            end
        end
    end
    --old data
    if not self.useId then
        local warShip = self:getCurrentWarShip()
        if warShip then
            self.useId = warShip.id
        end
    end
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

--""
function WarShipBag:getCurrentWarShip()
    return self.warShips[self.useId]
end

--""NFT""
function WarShipBag:getNftWarShips()
    local warShips = {}
    for k, v in pairs(self.warShips) do
        if v.chain > 0 then
            table.insert(warShips, v)
        end
    end
    return warShips
end

function WarShipBag:getTotalWarShip()
    return table.count(self.warShips)
end

function WarShipBag:checkWarShipTotal()
    local maxCount = gg.getGlobalCfgIntValue("HQBagMax", 100)
    return maxCount < self:getTotalWarShip()
end

--""
function WarShipBag:getNormalWarShips()
    local warShips = {}
    for k, v in pairs(self.warShips) do
        if v.chain <= 0 then
            table.insert(warShips, v)
        end
    end
    return warShips
end

function WarShipBag:initialWarShipNFT(param)
    logger.logf("info","ChainBridge","op=WarShipBag:initialWarShipNFT step1 pid=%d data=%s", self.player.pid, table.dump(param))
    local warShipCfg = ggclass.WarShip.getNFTWarShipCfg(param.race, param.style, param.quality, param.level)
    if not warShipCfg then
        logger.logf("info","ChainBridge","op=WarShipBag:initialWarShipNFT step2 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    param.id = param.token_id
    param.cfgId = warShipCfg.cfgId
    param.chain = param.mint_type
    if not param.life or param.life <= 0 then
        param.life = ggclass.WarShip.randomWarShipLife(param.quality)
        param.curLife = param.life
    else
        param.curLife = param.life
    end
    local warShip = self:newWarShip(param)
    if not warShip then
        logger.logf("info","ChainBridge","op=WarShipBag:initialWarShipNFT step4 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    warShip:deserialize(param)
    local ret = self:addWarShip(warShip, {logType=gamelog.BRIDGE_RECHARGE_NFT})
    if not ret then
        logger.logf("info","ChainBridge","op=WarShipBag:initialWarShipNFT step5 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
        return false
    end
    logger.logf("info","ChainBridge","op=WarShipBag:initialWarShipNFT step6 pid=%d token_id=%s", self.player.pid, tostring(param.token_id))
    return warShip
end

--""
--@param[type=table] source"" {logType = xxx, notNotify = xxx}
function WarShipBag:addWarShip(warShip, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=WarShipBag:addWarShip " .. debug.traceback())
        return nil
    end
    self.warShips[warShip.id] = warShip
    if not source.notNotify then
        gg.client:send(self.player.linkobj, "S2C_Player_WarShipAdd",{ warShip = warShip:pack() })
    end
    gg.internal:send(".gamelog", "api", "addEntityLog", self.player.pid, self.player.platform, "add", source.logType, gamelog[source.logType], constant.ITEM_WAR_SHIP, warShip:packToLog())
    self.player.autoPushBag:setAutoPushStatus(constant.AUTOPUSH_CFGID_NEW_WARSHIP)
    return warShip
end

--""
function WarShipBag:delWarShip(id, source)
    if not source or not source.logType or not gamelog[source.logType] then
        logger.logf("info","logType", "op=WarShipBag:delWarShip " .. debug.traceback())
        return nil
    end
    local warShip = self.warShips[id]
    if not warShip then
        return nil
    end
    self.warShips[id] = nil
    gg.client:send(self.player.linkobj, "S2C_Player_WarShipDel",{ id = id})
    gg.internal:send(".gamelog", "api", "addEntityLog", self.player.pid, self.player.platform, "del", source.logType, gamelog[source.logType], constant.ITEM_WAR_SHIP, warShip:packToLog())
    return warShip
end

--""
function WarShipBag:levelUpWarShip(id, speedUp)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
        return
    end
    local curLevel = warShip.level
    local nextLevel = curLevel + 1
    local nextCfg = ggclass.WarShip.getWarShipCfg(warShip.cfgId, warShip.quality, nextLevel)
    if not nextCfg then
        self.player:say(util.i18nFormat(errors.LEVEL_MAX))
        return
    end
    local cfg = ggclass.WarShip.getWarShipCfg(warShip.cfgId, warShip.quality, curLevel)
    if not cfg then
        self.player:say(util.i18nFormat(errors.CUR_LEVEL_CONFIG_NIL))
        return
    end
    if not constant.IsRefNone(warShip) and not constant.IsRefLevelUp(warShip) then
        self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
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
    --if constant.IsRefLevelUp(warShip) then
    if warShip:isLevelUp() then
        if speedUp == 0 then
            --"",""
            self.player:say(util.i18nFormat(errors.LEVELINGUP))
            return
        else
            --"",""
            local lessTick = warShip:getLessTick()
            local timeTesseract = self.player.resBag:timeCostTesseract(lessTick)
            if not self.player.resBag:enoughRes(constant.RES_TESSERACT, timeTesseract) then
                self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
                return
            end
            self.player.resBag:costRes(constant.RES_TESSERACT, timeTesseract, {logType=gamelog.SPEED_WARSHIP_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        end
    else
        if speedUp == 0 then
            --"",""
            local newResDict = upgradeUtil.calResCost(self, resDict, nil)
            if not self.player.resBag:enoughResDict(newResDict) then
                return
            end
            self.player.resBag:costResDict(newResDict, {logType=gamelog.WARSHIP_LEVEL_UP})
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
            self.player.resBag:costResDict(newResDict, {logType=gamelog.SOON_WARSHIP_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    warShip:setNextTick(levelUpNeedTick * 1000)

    gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
end

--""
function WarShipBag:warShipSkillUp(id, skillUp, speedUp)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
        return
    end
    local skillCfgId = warShip["skill" .. skillUp] or 0
    if skillCfgId <= 0 then
        self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
        return
    end
    local curLevel = warShip["skillLevel" .. skillUp]
    local nextLevel = warShip["skillLevel" .. skillUp] + 1
    local nextCfg = ggclass.WarShip.getWarShipSkillCfg(skillCfgId, warShip.quality, nextLevel)
    if not nextCfg then
        self.player:say(util.i18nFormat(errors.LEVEL_MAX))
        return
    end
    local cfg = ggclass.WarShip.getWarShipSkillCfg(skillCfgId, warShip.quality, curLevel)
    if not cfg then
        self.player:say(util.i18nFormat(errors.CUR_LEVEL_CONFIG_NIL))
        return
    end

    if not constant.IsRefNone(warShip) then
        self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
        return
    end

    -- if constant.IsRefSkillUp(warShip) and skillUp ~= warShip.skillUp then
    --     self.player:say(util.i18nFormat(errors.LEVELINGUP))
    --     return
    -- end

    -- if curLevel >= warShip.level then
    --     self.player:say(util.i18nFormat(errors.WARSHIP_BIG_SKILLLV))
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
    --if constant.IsRefSkillUp(warShip) then
    if warShip:isSkillUp() then
        if speedUp == 0 then
            --"",""
            self.player:say(util.i18nFormat(errors.LEVELINGUP))
            return
        else
            --"",""
            local lessTick = warShip:getSkillUpLessTick()
            local timeTesseract = self.player.resBag:timeCostTesseract(lessTick)
            if not self.player.resBag:enoughRes(constant.RES_TESSERACT, timeTesseract) then
                self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
                return
            end
            self.player.resBag:costRes(constant.RES_TESSERACT, timeTesseract, {logType=gamelog.SPEED_WARSHIP_SKILL_LEVEL_UP})
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
            self.player.resBag:costResDict(newResDict, {logType=gamelog.WARSHIP_SKILL_LEVEL_UP})
            self.player.itemBag:costItemDict(itemDict, {logType=gamelog.WARSHIP_SKILL_LEVEL_UP})
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
            self.player.resBag:costResDict(newResDict, {logType=gamelog.SOON_WARSHIP_SKILL_LEVEL_UP})
            self.player.itemBag:costItemDict(itemDict, {logType=gamelog.SOON_WARSHIP_SKILL_LEVEL_UP})
            self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
        end
    end

    local levelUpNeedTick = 0
    if speedUp <= 0 then
        levelUpNeedTick = cfg.levelUpNeedTick or 0
    end
    warShip.skillUp = skillUp
    warShip:setSkillUpNextTick(levelUpNeedTick * 1000)

    gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
end

function WarShipBag:warShipPutonSkill(id, skillIndex, itemCfgId)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
        return
    end
    local skillCfgId = warShip["skill" .. skillIndex]
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
    if skillCfg.useSkillUnit ~= constant.SKILL_WARSHIP_USE then
        self.player:say(util.i18nFormat(errors.SKILL_UNIT_ERR))
        return
    end
    self.player.itemBag:costItem(itemCfgId, 1, {logType=gamelog.WARSHIP_PUTON_SKILL})
    warShip["skill" .. skillIndex] = itemCfg.skillCfgID[1]
    warShip["skillLevel" .. skillIndex] = itemCfg.skillCfgID[2]
    gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
end

function WarShipBag:warShipResetSkill(id, skillIndex)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
        return
    end
    local skillCfgId = warShip["skill" .. skillIndex]
    if not skillCfgId or skillCfgId == 0 then
        self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
        return
    end
    local curLevel = warShip["skillLevel" .. skillIndex]
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
        self.player.itemBag:addItem(addItemId, addCount, {logType = gamelog.WARSHIP_RESET_SKILL})
    end
    local resDict = {}
    for i, v in ipairs(skillCfg.forgetRewardResources) do
        resDict[v[1]] = v[2]
    end
    self.player.resBag:addResDict(resDict, { logType = gamelog.WARSHIP_RESET_SKILL })
    warShip["skillLevel" .. skillIndex] = 1
    gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
end

function WarShipBag:warShipForgetSkill(id, skillIndex)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
        return
    end
    local skillCfgId = warShip["skill" .. skillIndex]
    if not skillCfgId or skillCfgId == 0 then
        self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
        return
    end
    local curLevel = warShip["skillLevel" .. skillIndex]
    local skillCfg = gg.getExcelCfgByFormat("skillConfig", skillCfgId, curLevel)
    if skillCfg.skillEquitType ~= constant.SKILL_EQUIP_VARIABLE then
        self.player:say(util.i18nFormat(errors.SKILL_CANT_FORGET))
        return
    end
    for i, v in ipairs(skillCfg.forgetRewardShard) do
        local addItemId = v[1]
        local addCount = v[2]
        self.player.itemBag:addItem(addItemId, addCount, {logType = gamelog.WARSHIP_FORGET_SKILL})
    end
    local resDict = {}
    for i, v in ipairs(skillCfg.forgetRewardResources) do
        resDict[v[1]] = v[2]
    end
    self.player.resBag:addResDict(resDict, { logType = gamelog.WARSHIP_FORGET_SKILL })
    warShip["skill" .. skillIndex] = 0
    warShip["skillLevel" .. skillIndex] = 0
    gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
end

function WarShipBag:warShipRepair(id)
    local warShip = self.warShips[id]
    if not warShip then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
        return
    end
    if constant.IsRefUnion(warShip) or constant.IsRefGrid(warShip) then
        self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
        return
    end
    local repairLife = warShip.life - warShip.curLife
    if repairLife <= 0 then
        self.player:say(util.i18nFormat(errors.REPAIR_NOT_NEED))
        return
    end
    local repairCostCfg = gg.getExcelCfg("repairCost")
    local costHyt = repairCostCfg[warShip.level].cost
    if not self.player.resBag:enoughRes(constant.RES_STARCOIN, costHyt) then
        self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_STARCOIN]))
        return
    end
    self.player.resBag:costRes(constant.RES_STARCOIN, costHyt, { logType = gamelog.REPAIR_WARSHIP_LIFE })
    self.player.taskBag:update(constant.TASK_REPAIR_COUNT, {})
    warShip.curLife = warShip.life
    gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
end

function WarShipBag:setUseWarShip(id)
    if self.useId == id then
        return
    end
    local warShip = self.warShips[id]
    if warShip.ref == constant.REF_UNION then
        self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
        return
    end
    if not warShip then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
        return
    end
    self.useId = id
    gg.client:send(self.player.linkobj,"S2C_Player_UseWarShipUpdate",{ useId = self.useId })
end

function WarShipBag:isUseWarShip(id)
    if self.useId == id then
        return true
    end
    return false
end

function WarShipBag:checkUseWarShip()
    local warShip = nil
    for k,v in pairs(self.warShips) do
        -- ""
        if constant.IsRefNone(v) then
            warShip = v
        end
        if v.id == self.useId then
            return
        end
    end
    self.useId = warShip.id
end

function WarShipBag:returnFromUnion(idList, nftLifeDict)
    for i, id in ipairs(idList) do
        local warShip = self:getWarShip(id)
        if warShip then
            warShip.ref = constant.REF_NONE
            warShip.refBy = 0
            warShip.donateTime = 0
            warShip.ownerPid = 0
            if nftLifeDict[id] then
                warShip.curLife = nftLifeDict[id]
            end
            gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
        end
    end
end

-- ""
function WarShipBag:dismantleWarShip(warShipIds)
    local items = {}
    for _,warShipId in ipairs(warShipIds) do
        -- ""
        local warShip = self.warShips[warShipId]
        if not warShip then
            self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
            return
        end
        if warShip.chain > 0 then
            self.player:say(util.i18nFormat(errors.NFT_CANNOT_DISMANTLING))
            return
        end
        if warShip:isUpgrade() then
            self.player:say(util.i18nFormat(errors.WARSHIP_LEVEL_OR_SKILL_UP))
            return
        end
        if not constant.IsRefNone(warShip) then
            self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
            return
        end
        if self.useId == warShipId then
            self.player:say(util.i18nFormat(errors.WARSHIP_IN_USE))
            return
        end
        for i=1,3 do
            if i == 1 then
                if warShip["skillLevel" .. i] > 1 then
                    self.player:say(util.i18nFormat(errors.WARSHIP_NOT_FORGET_SKILL))
                    return
                end
            else
                if warShip["skillLevel" .. i] > 0 then
                    self.player:say(util.i18nFormat(errors.WARSHIP_NOT_FORGET_SKILL))
                    return
                end
            end
        end
        -- ""
        local skillCfg = ggclass.WarShip.getWarShipSkillCfg(warShip.skill1, warShip.quality, warShip.skillLevel1)
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
        num,res = self.player.itemBag:addItem(itemCfgId, 1, { logType=gamelog.DISMANTLING_WARSHIP })
        for k,v in pairs(res) do
            local item = v:pack()
            table.insert(items, {id = item.id, cfgId = item.cfgId, num = num})
        end
        self:delWarShip(warShipId, { logType=gamelog.DISMANTLING_WARSHIP })
    end
    gg.client:send(self.player.linkobj,"S2C_Player_DismantleReward", { result = true, items = items})
end

-- ""
function WarShipBag:sellWarShip(warshipIds)
    local delIds = {}
    local rewardCount = 0
    for _,warShipId in ipairs(warshipIds) do
        -- ""
        local warShip = self.warShips[warShipId]
        if not warShip then
            self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
            return
        end
        if warShip.chain > 0 then
            self.player:say(util.i18nFormat(errors.NFT_CANNOT_SELL))
            return
        end
        if warShip:isUpgrade() then
            self.player:say(util.i18nFormat(errors.WARSHIP_LEVEL_OR_SKILL_UP))
            return
        end
        if not constant.IsRefNone(warShip) then
            self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
            return
        end
        if self.useId == warShipId then
            self.player:say(util.i18nFormat(errors.WARSHIP_IN_USE))
            return
        end
        for i=1,3 do
            if i == 1 then
                if warShip["skillLevel" .. i] > 1 then
                    self.player:say(util.i18nFormat(errors.WARSHIP_NOT_FORGET_SKILL))
                    return
                end
            else
                if warShip["skillLevel" .. i] > 0 then
                    self.player:say(util.i18nFormat(errors.WARSHIP_NOT_FORGET_SKILL))
                    return
                end
            end
        end
        -- ""
        local sellingPrice = gg.getGlobalCfgTableValue("SellingPrice", {})
        local resNum = sellingPrice[warShip.quality]
        rewardCount = rewardCount + resNum
        table.insert(delIds,warShipId)
    end
    for _,Id in pairs(delIds) do
        self:delWarShip(Id, { logType=gamelog.SELL_HERO })
    end
    self.player.resBag:addRes(constant.RES_STARCOIN, rewardCount, {logType=gamelog.SELL_WARSHIP})
    local resInfo = {}
    table.insert(resInfo, { resCfgId = constant.RES_STARCOIN, count = rewardCount})
    resInfo.resCfgId = constant.RES_STARCOIN
    gg.client:send(self.player.linkobj, "S2C_Player_TipNote",  { tipType = 1, resInfo = resInfo })
end

function WarShipBag:oncreate()
    if not next(self.warShips) then
        local cfgId = gg.getGlobalCfgIntValue("InitWarShipCfgId", 4000001)
        local quality = gg.getGlobalCfgIntValue("InitWarShipQuality", 1)
        local level = gg.getGlobalCfgIntValue("InitWarShipLevel", 1)
        local life = ggclass.WarShip.randomWarShipLife(quality)
        local param = {
            cfgId = cfgId,
            quality = quality,
            level = level,
            life = life,
            curLife = life,
        }
        local warship = self:newWarShip(param)
        if warship then
            local ret = self:addWarShip(warship, { logType = gamelog.CREATE_PLAYER_GIFT, notNotify = true })
            if ret then
                self.useId = warship.id
            end
        end
    end
end

function WarShipBag:onload()
    self:checkWarShips(true)
    self:checkWarShipsSkillChange(true)
end

function WarShipBag:resetData()
    for _,warShip in pairs(self.warShips) do
        warShip.level = 1
        warShip.nextTick = 0                                  -- ""
        warShip.fightTick = 0                                -- ""

        warShip.ref = 0
        warShip.refBy = 0
        warShip.donateTime = 0
        warShip.ownerPid = 0
    end
end

function WarShipBag:onlogin()
    self:checkUseWarShip()
    gg.client:send(self.player.linkobj,"S2C_Player_WarShipData",{ warShipData = self:packWarShip(), useId = self.useId })
end

function WarShipBag:onreset()
    self:resetData()
end

function WarShipBag:onSecond()
    self:checkWarShips()
end

function WarShipBag:checkWarShips(notNotify)
    for _,warShip in pairs(self.warShips) do
        warShip:checkLevelUp(notNotify)
        warShip:checkSkillUp(notNotify)
        warShip:checkLaunchFinish(notNotify)
    end
end

function WarShipBag:checkWarShipsSkillChange(notNotify)
    for _,warShip in pairs(self.warShips) do
        warShip:checkSkillChange(notNotify)
    end
end

return WarShipBag