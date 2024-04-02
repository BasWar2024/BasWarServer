local DrawCardBag = class("DrawCardBag")

function DrawCardBag:ctor(param)
    self.player = param.player
    self.cardPool = {}
    self.cardGetRecords = {}
end

function DrawCardBag:serialize()
    local data = {}
    data.cardPool = {}
    for k, v in pairs(self.cardPool) do
        data.cardPool[tostring(k)] = v
    end
    data.cardGetRecords = self.cardGetRecords
    return data
end

function DrawCardBag:deserialize(data)
    if not data then
        return
    end
    for k, v in pairs(data.cardPool or {}) do
        self.cardPool[tonumber(k)] = v
    end
    self.cardGetRecords = data.cardGetRecords or {}
end

function DrawCardBag:_pack()
    local ret = {}
    for k, v in pairs(self.cardPool) do
        table.insert(ret, {
            cfgId = k,
            count = v.count,
            drawTime = v.drawTime,
        })
    end
    return ret
end

function DrawCardBag:_sendUpdate(op, data)
    local discount = constant.DRAW_CARD_DISCOUNT_DEFAULT
    if self.player.rechargeActivityBag:checkDrawCardDiscount() then
        discount = gg.getGlobalCfgFloatValue("DrawCardDiscount",0)
    end
    gg.client:send(self.player.linkobj,"S2C_Player_DrawCardData",{
        op_type = op,
        cardData = data,
        discount = discount
    })
end

function DrawCardBag:_initOne(cfgId)
    local cardCfg = gg.getExcelCfg("cardPool")
    if not cardCfg[cfgId] then
        return
    end
    if cardCfg[cfgId].available ~= 1 then
        return
    end
    if self.cardPool[cfgId] then
        return
    end
    self.cardPool[cfgId] = {
        cfgId = cfgId,
        count = 0,
        drawTime = 0,
        first = true,
    }
    return true
end

function DrawCardBag:_checkNew()
    local cardCfg = gg.getExcelCfg("cardPool")
    for k, v in pairs(cardCfg) do
        self:_initOne(k)
    end
end

function DrawCardBag:init()
    self:_checkNew()
    self:_sendUpdate(constant.OP_ADD, self:_pack())
end

function DrawCardBag:drawCard(cfgId, drawCount, isGm)
    if isGm and not gg.isInnerServer() then
        return
    end
    if drawCount < 1 then
        self.player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    local cardCfg = gg.getExcelCfg("cardPool")
    local cfg = cardCfg[cfgId]
    if not cfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    local cardData = self.cardPool[cfgId]
    if not cardData then
        self.player:say(util.i18nFormat(errors.DRAW_NOT_EXIST))
        return
    end

    if self.player.heroBag:checkHeroTotal() then
        self.player:say(util.i18nFormat(errors.HQ_NO_SPACE))
        return
    end
    if self.player.buildBag:checkBuildTotal() then
        self.player:say(util.i18nFormat(errors.HQ_NO_SPACE))
        return
    end
    if self.player.warShipBag:checkWarShipTotal() then
        self.player:say(util.i18nFormat(errors.HQ_NO_SPACE))
        return
    end
    
    local now = gg.time.time()
    local costCount = 0
    if drawCount == 1 then
        if cfg.freeTime > 0 then
            if cardData.drawTime > 0 then
                if (cardData.drawTime + cfg.freeTime) > now then--not free
                    costCount = 1
                end
            end
        else
            costCount = 1
        end
    else
        costCount = drawCount
    end
    -- ，""，""
    if costCount > 0 then
        local costRes
        local costItem
        if costCount == 1 then
            costRes = cfg.costRes
            costItem = cfg.costItem
        else
            costRes = cfg.costResInMuilt
            costItem = cfg.costItemInMuilt
        end
        if costRes[1] and costRes[2] then
            local resCfgId = costRes[1]
            local resCount = costRes[2] * costCount
            if resCfgId == constant.RES_TESSERACT and self.player.rechargeActivityBag:checkDrawCardDiscount() then
                local discount = gg.getGlobalCfgFloatValue("DrawCardDiscount",0)
                resCount = resCount * discount
            end
            if not self.player.resBag:enoughRes(resCfgId, resCount) then
                self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[resCfgId]))
                return
            end
            self.player.resBag:costRes(resCfgId, resCount, {logType=gamelog.DRAW_CARD})
        end
        
        if costItem[1] and costItem[2] then
            local itemCfgId = costItem[1]
            local itemCount = costItem[2] * costCount
            if not self.player.itemBag:isItemEnough(itemCfgId, itemCount) then
                return
            end
            self.player.itemBag:costItem(itemCfgId, itemCount, {logType=gamelog.DRAW_CARD})
        end
    end
    
    local toFileData
    if isGm then
        os.execute("mkdir -p drawCard")
        toFileData = {}
    end
    local itemIds = {}
    local guarantee = false
    local itemCfg = gg.getExcelCfg("item")
    local itemData = {}
    for i = 1, drawCount, 1 do
        if cfg.minimumCount > 0 and cardData.count+1 >= cfg.minimumCount then
            guarantee = true
        end
        local group = cfg.commonGroup  -- ""
        if guarantee then
            group = cfg.minimumGroup  -- ""
        end
        local randItemId
        if cardData.first then
            if table.count(cfg.firstReward) > 0 then
                randItemId = cfg.firstReward[1]
            end
            cardData.first = false
        end
        if not randItemId then
            local countCfg = table.chooseByValue(group, function(v)
                return v[2]
            end)
            randItemId = countCfg[1]
        end
        
        local _itemCfg = itemCfg[randItemId]
        if _itemCfg.itemType == constant.ITEM_HERO then
            local life = ggclass.Hero.randomHeroLife(_itemCfg.quality)
            local param = {
                cfgId = randItemId,
                quality = _itemCfg.quality,
                level = 1,
                life = life,
                curLife = life,
            }
            local hero = self.player.heroBag:newHero(param)
            self.player.heroBag:addHero(hero, { logType = gamelog.DRAW_CARD })
            itemData[randItemId] = { cfgId = randItemId , quality = _itemCfg.quality}
        elseif _itemCfg.itemType == constant.ITEM_BUILD or _itemCfg.itemType == constant.ITEM_WAR_SHIP then
            self.player.itemBag:addItem(randItemId, 1, {logType = gamelog.DRAW_CARD})
            itemData[randItemId] = { cfgId = randItemId, quality = _itemCfg.quality }
        else  -- ""
            self.player.itemBag:addItem(randItemId, 1, {logType = gamelog.DRAW_CARD})
            local skillCfgId = _itemCfg.skillCfgID[1]
            local skillLevel = _itemCfg.skillCfgID[2]
            local skillCfg = ggclass.Hero.getHeroSkillCfg(skillCfgId, 0, skillLevel)
            itemData[randItemId] = { cfgId = skillCfgId, quality = skillCfg.quality }
        end
        
        table.insert(itemIds, randItemId)
        if table.count(self.cardGetRecords) >= constant.DRAW_CARD_REC_SIZE then
            local diff = table.count(self.cardGetRecords) - constant.DRAW_CARD_REC_SIZE
            for i = 1, diff, 1 do
                table.remove(self.cardGetRecords, 1)
            end
        end
        table.insert(self.cardGetRecords, {
            drawTime = now,
            cfgId = cfgId,
            itemCfgId = randItemId,
        })
        cardData.count = cardData.count + 1
        --csv file
        if toFileData then
            local _tCfg = itemCfg[randItemId] or {}
            local _info = {}
            _info.count = i
            _info.cfgId = cfgId
            _info.quality = _tCfg.quality
            if guarantee then
                _info.guarantee = 1
            else
                _info.guarantee = 0
            end
            table.insert(toFileData, _info)
        end

        if guarantee then
            guarantee = false
            cardData.count = 0
        end
        local tmpCfg = itemCfg[randItemId]
        if tmpCfg then
            if tmpCfg.quality >= cfg.minQuality then
                cardData.count = 0
            end
        end
    end
    if cfg.freeTime > 0 and drawCount == 1 and (cardData.drawTime + cfg.freeTime) <= now then
        cardData.drawTime = now
    end
    self:_sendUpdate(constant.OP_MODIFY, {cardData})
    local new = self:isNewGet(itemData)
    gg.client:send(self.player.linkobj,"S2C_Player_DrawCardResult",{
        cfgIds = itemIds,
        newCfgIds = new
    })
    self.player.taskBag:update(constant.TASK_DRAW_CARD, { cfgId = cfgId, count = drawCount })
    --write file
    if isGm then
        local file = io.open("./drawCard/cardStatistics.csv", "w+")
        file:write(""",""id,"",""\n")
        for i, v in ipairs(toFileData or {}) do
            local fields = {}
            table.insert(fields, v.count or 0)
            table.insert(fields, v.cfgId or 0)
            table.insert(fields, v.quality or 0)
            table.insert(fields, v.guarantee or 0)
            file:write(table.concat(fields, ",") .. "\n")
        end
        file:close()
    end
end

function DrawCardBag:getDrawCardRecord()
    gg.client:send(self.player.linkobj,"S2C_Player_DrawCardRecords",{
        records = self.cardGetRecords
    })
end

function DrawCardBag:isNewGet(itemData)
    local data = gg.shareProxy:call("getItemNote", self.player.pid)
    local new = {}
    local ret = {}
    local temp = {}
    for k,v in pairs(data) do
        if v ~= 1 then
            temp[v] = 1
        end
    end
    for k,v in pairs(itemData) do
        local key = v.cfgId .. "_" .. v.quality
        if not temp[key] then
            table.insert(new, key)
            table.insert(ret, k)
        end
    end
    self:setItemNote(new)
    return ret
end

function DrawCardBag:setItemNote(data)
    if not data or not next(data) then
        return
    end
    gg.shareProxy:call("setItemNote", self.player.pid, data)
end

function DrawCardBag:setDiscount()

end
function DrawCardBag:onload()
end

function DrawCardBag:onlogin()
    self:_checkNew()
    self:_sendUpdate(constant.OP_ADD, self:_pack())
end

function DrawCardBag:onSecond()
end