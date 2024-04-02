local RechargeActivityBag = class("RechargeActivityBag")

function RechargeActivityBag:ctor(param)
    self.player = param.player
    self.funds = param.funds or {}              -- ""
    self.costLevel = param.costLevel or 0       -- ""

    self.recharge = param.recharge or {         -- ""
        firstRec = 0,
        rechargeVal = 0,
        rechargeStat = 0
    }
    self.doubRecstat = param.doubRecstat or {}   -- ""
    self.moonCard = param.moonCard or {          -- "" ""
        status = 0,
        nextTime = 0,
        endTime = 0
    }

    self.moreBuilder = param.moreBuilder or {    -- ""
        status = 0,
        endTime = 0
    }
    self.dailyGiftBag = param.dailyGiftBag or {
        nextTime = self:nextDayZeroTime(),
        data = {}
    }    -- ""

    self.dailyCheck = param.dailyCheck or self:newDailyCheck()
    self.shoppingMall = {}
    self.shoppingMall.startTimes = self:initShoppingMallStartime()
    self.shoppingMall.overTimes = self:newShoppingMallOverTime()
    self.shoppingMall.data = self:newShoppingMall()
    self.shoppingMall.fresh = 1
    self.spmProductIds = {}     -- ""id
    -- ""
    self.loginActInfo = {
        endTime = self:initloginActEndTime(),
        data = self:initLoginActInfo(),
        nextDay = 1,
        nextTick = gg.time.dayzerotime()
    }

    -- ""
    self.starPack = {
        data = {},   -- cfgId,endTick
        nextTime = 0,
    }
    -- ""
    -- self.baseLevelPack = nil
end

function RechargeActivityBag:checkActProduct(productId)
    if constant.IS_PRO_MOON_CARD[productId] then
        self:setMoonCard(productId)
    end
    if constant.IS_GIFT_BAG[productId] then
        self:getGiftReward(productId)
    end
    -- if constant.IS_LOGIN_ACT[productId] then
    --     self:unLockLoginActAdv(productId)
    -- end
    if constant.IS_PRO_STARPACK[productId] then
        self:setStarPack(productId)
    end
end

function RechargeActivityBag:initLoginActInfo()
    local getLoginActCfg = self:getLoginActCfg()
    local data = {}
    for i=1,#getLoginActCfg do
        table.insert(data, { day = i, baseStatus = constant.LOGINACT_NOT_LOGIN, advStatus = constant.LOGINACT_LOCK })
    end
    return data
end

function RechargeActivityBag:initloginActEndTime()
    local loginCfg = self:getGiftActivities(constant.LOGIN_ACT)
    local endTime = gg.time.time() + constant.TIME_ONE_DAY_TO_SECONE * loginCfg.duration
    return endTime
end

function RechargeActivityBag:initShoppingMallStartime()
    local nowTime = gg.time.time()
    local actCfg = self:getGiftActivities(constant.SHOPING_MALL)
    local startTime = string.totime(actCfg.startTime)
    
    if (nowTime - startTime) > 0 then
        local period = constant.TIME_ONE_DAY_TO_SECONE * actCfg.duration + constant.TIME_ONE_DAY_TO_SECONE * actCfg.interval
        local num = (nowTime - startTime) // period
        if num > 0 then
            startTime = nowTime - (nowTime - startTime) % period
        end
    end
    return startTime
end

function RechargeActivityBag:newShoppingMallOverTime()
    local actCfg = self:getGiftActivities(constant.SHOPING_MALL)
    local startTime = self.shoppingMall.startTimes
    return startTime + constant.TIME_ONE_DAY_TO_SECONE * actCfg.duration
end

function RechargeActivityBag:newShoppingMall()
    local smCfg = gg.getExcelCfg("shoppingMall")
    local data = {}

    local group = {}
    local group2 = {}
    for k,v in pairs(smCfg) do
        if v.group and v.group == 6 then
            table.insert(group2, { v.cfgId, v.weight})
        else
            table.insert(group, { v.cfgId, v.weight})
        end
        
    end
    for i=1,6 do
        local countCfg
        if i == 6 and next(group2) then
            countCfg = table.chooseByValue(group2, function(v)
                return v[2]
            end)
        else
            countCfg = table.chooseByValue(group, function(v)
                return v[2]
            end)
        end
        table.insert(data, {index=i, cfgId = countCfg[1], num = smCfg[countCfg[1]].buyNum})
    end
    return data
end

function RechargeActivityBag:checkShoppingMallTime()
    local startTime = self.shoppingMall.startTimes
    local endTime = self.shoppingMall.overTimes
    local nowTime = gg.time.time()
    -- if nowTime < startTime or nowTime > endTime then
    --     self.shoppingMall.startTimes = self:initShoppingMallStartime()
    --     self.shoppingMall.overTimes = self:newShoppingMallOverTime()
    --     return
    -- end
    return true
end

function RechargeActivityBag:newDailyCheck ()
    local data = {}
    for i=1,7 do
        table.insert(data, {isFirst = 0, status = 0})
    end
    local dailyCheck = {
        nextDay = 1,
        lastTick = gg.time.dayzerotime(),
        data = data
    }
    return dailyCheck
end

function RechargeActivityBag:newRecharge(param)
    param.player = self.player
    return ggclass.Recharge.create(param)
end

function RechargeActivityBag:serialize()
    local data = {}
    data.costLevel = self.costLevel or 0
    data.baseLevelPack = self.baseLevelPack
    data.funds = {}
    for k,v in pairs(self.funds) do
        data.funds[tostring(k)] = v
    end

    data.recharge = {}
    for k,v in pairs(self.recharge) do
        data.recharge[k] = v
    end

    data.doubRecstat = {}
    for k,v in pairs(self.doubRecstat) do
        table.insert(data.doubRecstat, v)
    end

    data.moonCard = {}
    for k,v in pairs(self.moonCard) do
        data.moonCard[k] = v
    end

    data.moreBuilder = {}
    for k,v in pairs(self.moreBuilder) do
        data.moreBuilder[k] = v
    end

    data.dailyGiftBag = {}
    for k,v in pairs(self.dailyGiftBag) do
        data.dailyGiftBag[k] = v
    end

    data.dailyCheck = {}
    for k,v in pairs(self.dailyCheck) do
        data.dailyCheck[k] = v
    end

    data.loginActInfo = {}
    for k,v in pairs(self.loginActInfo) do
        data.loginActInfo[k] = v
    end
    data.starPack = {}
    for k,v in pairs(self.starPack) do
        data.starPack[k] = v
    end
    
    return data
end

function RechargeActivityBag:deserialize(data)
    self.costLevel = data.costLevel or 0
    self.baseLevelPack = data.baseLevelPack
    if data.funds and next(data.funds) then
        for k,v in pairs(data.funds) do
            self.funds[tonumber(k)] = v
        end
    end
    if data.recharge and next(data.recharge) then
        for k,v in pairs(data.recharge) do
            self.recharge[k] = v
        end
    else
        self.recharge = {
            firstRec = 0,
            rechargeVal = 0,
            rechargeStat = 0
        }
    end
    if data.doubRecstat and next(data.doubRecstat) then
        for k,v in pairs(data.doubRecstat) do
            table.insert(self.doubRecstat, v)
        end
    end
    if data.moonCard and next(data.moonCard) then
        for k,v in pairs(data.moonCard) do
            self.moonCard[k] = v
        end
    else
        self.moonCard = { endTime = 0 }
    end

    if data.moreBuilder and next(data.moreBuilder) then
        for k,v in pairs(data.moreBuilder) do
            self.moreBuilder[k] = v
        end
    else
        self.moreBuilder = { endTime = 0 , status = 0}
    end
    if data.dailyGiftBag and next(data.dailyGiftBag) then
        for k,v in pairs(data.dailyGiftBag) do
            self.dailyGiftBag[k] = v
        end
    end

    if data.dailyCheck and next(data.dailyCheck) then
        if not data.dailyCheck.nextDay and not data.dailyCheck.data then
            self:newDailyCheck()
        else
            for k,v in pairs(data.dailyCheck) do
                self.dailyCheck[k] = v
            end
        end
    end

    if data.loginActInfo and next(data.loginActInfo) then
        for k,v in pairs(data.loginActInfo) do
            self.loginActInfo[k] = v
        end
    end
    if data.starPack and next(data.starPack) then
        for k,v in pairs(data.starPack) do
            self.starPack[k] = v
        end
    end
end

function RechargeActivityBag:getLoginActCfg()
    local LoginActCfg = gg.getExcelCfg("loginActivity")
    return LoginActCfg
end

function RechargeActivityBag:getGiftActivities(cfgId)
    local giftActivitiesCfg = gg.getExcelCfg("giftActivities")
    return giftActivitiesCfg[cfgId]
end

function RechargeActivityBag:getCumulativeFunds(cfgId)
    local cumulativeFundsCfg = gg.getExcelCfg("cumulativeFunds")
    return cumulativeFundsCfg[cfgId]
end

function RechargeActivityBag:getRewardCfg(cfgId)
    local rewardCfg = gg.getExcelCfg("giftReward")
    return rewardCfg[cfgId]
end

function RechargeActivityBag:isValid(cfgId)
    local actCfg = self:getGiftActivities(cfgId)
    if not actCfg then
        return false
    end
    if actCfg.status == 0 then
        return false
    end
    return util.betweenCfgTime(actCfg, "startTime", "endTime")
end

function RechargeActivityBag:checkReward(fundsCfg, cfgId)
    local funds = self.funds
    for k,v in pairs(funds) do
        if v.cfgId == cfgId then
            self.player:say(util.i18nFormat(errors.FUNDS_AWARD_IS_GET))
            return
        end
    end
    if self.costLevel ~= fundsCfg.cost and self.costLevel ~= 400 then
        return
    end
    local baseLevel = self.player.buildBag:getBaseBuildLevel()
    if baseLevel < fundsCfg.baseLevel then
        return
    end
    return true
end

function RechargeActivityBag:getReward(cfgId, logType)
    local rewCfg = self:getRewardCfg(cfgId)
    if not rewCfg then
        return
    end
    if rewCfg.herosReward and next(rewCfg.herosReward) then
        for k,v in pairs(rewCfg.herosReward) do
            local life = ggclass.Hero.randomHeroLife(v[2])
            local param = {
                cfgId = v[1],
                quality = v[2],
                level = v[3],
                life = life,
                curLife = life,
            }
            local hero = self.player.heroBag:newHero(param)
            if hero then
                local ret = self.player.heroBag:addHero(hero, { logType = logType, notNotify = false })
            end
        end
    end
    if rewCfg.resReward and next(rewCfg.resReward) then
        local reward = {}
        for k,v in pairs(rewCfg.resReward) do
            reward[v[1]] = v[2]
        end
        self.player.resBag:addResDict(reward, { logType = logType })
    end
    -- if rewCfg.itemReward and next(rewCfg.itemReward) then
    --     local itemCfg = gg.getExcelCfg("item")
    --     local cardCfg = gg.getExcelCfg("cardPool")
    --     local cfg = cardCfg[cfgId]
    --     if not cfg then
    --         self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
    --         return
    --     end
    --     local group = cfg.minimumGroup
    --     for k,v in pairs(cfg.itemReward) do
    --         local countCfg = table.chooseByValue(group, function(v)
    --             return v[2]
    --         end)
    --         local randItemId = countCfg[1]
    --         local _itemCfg = itemCfg[v[1]]
    --         if _itemCfg.itemType == constant.ITEM_HERO then
    --             local life = ggclass.Hero.randomHeroLife(_itemCfg.quality)
    --             local param = {
    --                 cfgId = randItemId,
    --                 quality = _itemCfg.quality,
    --                 level = 1,
    --                 life = life,
    --                 curLife = life,
    --             }
    --             local hero = self.player.heroBag:newHero(param)
    --             self.player.heroBag:addHero(hero, { logType = gamelog.CUMULATIVE_FUNDS})
    --         else
    --             self.player.itemBag:addItem(v[1], v[2], {logType = gamelog.CUMULATIVE_FUNDS})
    --         end
    --     end
    -- end
    return true
end

function RechargeActivityBag:getCompensation(productId)  -- ""
    local comCfg = gg.getExcelCfg("compensation")
    local item = {}
    for k,v in pairs(comCfg) do
        if v.productId == productId then
            item = v.item
        end
    end

    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_COMPENSATION]
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle

    local mailItems = {}
    local itemInfo = ""
    local itemCfg = gg.getExcelCfg("item")
    for k,v in pairs(item) do
        table.insert(mailItems, {
            cfgId = v[1],
            count = v[2],
            type = constant.MAIL_ATTACH_ITEM,
        })
        if itemCfg[v[1]] then
            if itemInfo == "" then
                itemInfo = itemInfo .. itemCfg[v[1]].webName .. "*" .. v[2]
            else
                itemInfo = itemInfo .. ", " .. itemCfg[v[1]].webName .. "*" .. v[2]
            end
        end
    end

    local mailData = {
        title = title,
        content = string.format(mailCfg.mailContent, itemInfo),
        attachment = mailItems,
        logType = gamelog.REPEAT_RECHARGE_CPS
    }
    gg.mailProxy:send("gmSendMail", sendId, sendName, { self.player.pid }, mailData)
end

function RechargeActivityBag:getFundsReward(cfgId)
    if not self:isValid(constant.CUMULATIVE_FUNDS) then
        self.player:say(util.i18nFormat(errors.RECHARGEACTIVITY_NOT_EXIT))
        return
    end
    local fundsCfg = self:getCumulativeFunds(cfgId)
    if not fundsCfg then
        return
    end
    if not self:checkReward(fundsCfg, cfgId) then
        return
    end

    self:getReward(fundsCfg.reward, gamelog.CUMULATIVE_FUNDS)

    self.funds[cfgId] = {
        cfgId = cfgId,
        status = 1
    }
    self:sendCumulativeFunds()
end

function RechargeActivityBag:sendCumulativeFunds()
    local data = {}
    data.funds100 = 0
    data.funds300 = 0
    if self.costLevel == 100 then
        data.funds100 = 1
    end
    if self.costLevel == 300 then
        data. funds300 = 1
    end
    if  self.costLevel == 400 then
        data.funds100 = 1
        data.funds300 = 1
    end
    data.info = {}
    for k,v in pairs(self.funds) do
        table.insert(data.info,v)
    end
    gg.client:send(self.player.linkobj, "S2C_Player_CumulativeFunds",  { funds100 = data.funds100, funds300 = data.funds300, info = data.info})
end

function RechargeActivityBag:setFunds(productId)
    if not self:isValid(constant.CUMULATIVE_FUNDS) then
        return
    end
    if self.costLevel == constant.CUMULATIVE_FUNDS_100_300 or self.costLevel == constant.IS_CUMULATIVE_FUNDS[productId] then
        -- ""
        self:getCompensation(productId)
        return
    end

    if self.costLevel == 0 then
        self.costLevel = constant.IS_CUMULATIVE_FUNDS[productId]
    else
        self.costLevel = self.costLevel + constant.IS_CUMULATIVE_FUNDS[productId]
    end
    self:sendCumulativeFunds()
end


-- ""
function RechargeActivityBag:checkDrawCardDiscount()
    if not self:isValid(constant.DRAW_CARD_DISCOUNT) then
        return
    end
    return true
end

-- ""
function RechargeActivityBag:getFirstOrRechargeReward(giftCfgId)
    if giftCfgId == constant.FIREST_RECHARGE then
        self:getFirestRechargeReward()
    end
    if giftCfgId == constant.RECHARGE then
        self:getRechargeReward()
    end
end

function RechargeActivityBag:sendRechargeInfo()
    local firstRec = self.recharge.firstRec
    local rechargeVal = math.floor(self.recharge.rechargeVal * 1000)
    local rechargeStat =self.recharge.rechargeStat

    gg.client:send(self.player.linkobj, "S2C_Player_Recharge",  { firstRec = firstRec , rechargeVal = rechargeVal, rechargeStat = rechargeStat})
end

function RechargeActivityBag:addRechargeVal(val)
    if not self:isValid(constant.RECHARGE) then
        return
    end
    self.recharge.rechargeVal = self.recharge.rechargeVal + val
    self:sendRechargeInfo()
end

function RechargeActivityBag:checkRecharge()
    if not self:isValid(constant.RECHARGE) then
        self.player:say(util.i18nFormat(errors.RECHARGEACTIVITY_NOT_EXIT))
        return
    end
    return true
end

function RechargeActivityBag:checkFirstRecharge()
    if not self:isValid(constant.FIREST_RECHARGE) then
        self.player:say(util.i18nFormat(errors.RECHARGEACTIVITY_NOT_EXIT))
        return
    end
    return true
end

function RechargeActivityBag:getRechargeReward()
    if not self:isValid(constant.FIREST_RECHARGE) then
        self.player:say(util.i18nFormat(errors.RECHARGEACTIVITY_NOT_EXIT))
        return
    end
    if self.recharge.rechargeStat == 1 then
        return
    end
    local rechargeVal = self.recharge.rechargeVal
    local recCfg = ggclass.Recharge.getRechargeCfg()
    local value = gg.getGlobalCfgFloatValue("Recharge", 0)
    if rechargeVal < value then
        self.player:say(util.i18nFormat(errors.RECHARGE_NOT_ENOUGH))
        return
    end

    if not self:getReward(recCfg.reward, gamelog.RECHARGE_REWARD) then
        return
    end
    self.recharge.rechargeStat = 1
    self:sendRechargeInfo()
end

function RechargeActivityBag:getFirestRechargeReward()
    if not self:isValid(constant.FIREST_RECHARGE) then
        self.player:say(util.i18nFormat(errors.RECHARGEACTIVITY_NOT_EXIT))
        return
    end
    local rechargeVal = self.recharge.rechargeVal
    if self.recharge.firstRec == 1 then
        self.player:say(util.i18nFormat(errors.REWARD_AlREADY_ISSUED))
        return
    end
    local value = gg.getGlobalCfgFloatValue("FirstRecharge", 0)
    if rechargeVal < value then
        self.player:say(util.i18nFormat(errors.RECHARGE_NOT_ENOUGH))
        return
    end
    local firCfg = ggclass.Recharge.getFirestRechargeCfg()
    if not self:getReward(firCfg.reward, gamelog.FIREST_RECHARGE_REWARD) then
        return
    end
    self.recharge.firstRec = 1
    self:sendRechargeInfo()
end

-- ""
function RechargeActivityBag:setDoubleRe(productId)
    if not self:isValid(constant.DOUBLE_RECHARGE) then
        return
    end
    for k,v in pairs(self.doubRecstat) do
        if v.productId == productId then
            return
        end
    end
    table.insert(self.doubRecstat,{productId = productId} )
    self:sendDoubleRe()
    return true
end

function RechargeActivityBag:sendDoubleRe()
    local temp = gg.deepcopy(constant.IS_RECHARGE)
    for k,v in pairs(self.doubRecstat) do
        if temp[v.productId] then
            temp[v.productId] = nil
        end
    end
    local data = {}
    for k,v in pairs(temp) do
        table.insert(data, {productId = k})
    end
    gg.client:send(self.player.linkobj, "S2C_Player_DoubelRecharge",  {data=data})
end

-- ""
function RechargeActivityBag:checkMoonEndTime()
    local nowTime = gg.time.time()
    local endTime = self.moonCard.endTime
    if nowTime > endTime then
        return false
    end
    return true
end

function RechargeActivityBag:sendMoonRewardMail()
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MOON_REWARD_MAIL_TEMPLATE]
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle

    local actCfg = self:getGiftActivities(constant.MOON_CARD)
    local rewarCfg = self:getRewardCfg(actCfg.reward)
    local mailItems = {}
    for k,v in pairs(rewarCfg.resReward) do
        table.insert(mailItems, {
            cfgId = v[1],
            count = v[2],
            type = constant.MAIL_ATTACH_RES,
        })
    end

    local mailData = {
        title = title,
        content = mailCfg.mailContent,
        attachment = mailItems,
        logType = gamelog.MOON_CARD_REWARD
    }
    gg.mailProxy:send("gmSendMail", sendId, sendName, { self.player.pid }, mailData)
    self:sendMoonCard()
end

-- ""
function RechargeActivityBag:setMoonRewarNextTime()
    return gg.time.dayzerotime() + constant.TIME_ONE_DAY_TO_SECONE
end

function RechargeActivityBag:sendMoonCardReward()
    if self.moonCard.status == 0 then
        return
    end
    local nowTime = gg.time.time()

    if self.moonCard.endTime >= nowTime then
        -- ""
        self:sendMoonRewardMail()
    end
    if nowTime > self.moonCard.endTime then
        self.moonCard.status = 0
        return
    end
end

function RechargeActivityBag:sendMoonCard()
    local nowTime = gg.time.time()
    local endTime = self.moonCard.endTime
    local day = 0
    if nowTime < endTime then
        day = math.ceil((endTime - nowTime) / constant.TIME_ONE_DAY_TO_SECONE)
    end

    gg.client:send(self.player.linkobj, "S2C_Player_MoonCard",  {day=day})
end

function RechargeActivityBag:setMoonCard(product)
    local supplyPackCfg = gg.getExcelCfg("supplyPack")
    if not supplyPackCfg then
        return
    end
    local supplyPack
    for k,v in pairs(supplyPackCfg) do
        if v.product == product then
            supplyPack = v
            break
        end
    end
    if not supplyPack then
        return
    end
    local endTime = self.moonCard.endTime
    local nowTime = gg.time.time()
    if endTime >= nowTime then
        endTime = endTime +  supplyPack.duration * constant.TIME_ONE_DAY_TO_SECONE
    else    -- ""
        endTime = nowTime + supplyPack.duration * constant.TIME_ONE_DAY_TO_SECONE
        self:sendMoonRewardMail()   -- ""
        self.moonCard.nextTime = self:setMoonRewarNextTime()        -- ""
    end
    self.moonCard.status = 1
    self.moonCard.endTime = endTime
    self:sendMoonCard()
end

-- more build ""
function RechargeActivityBag:sendBuildQueue()
    local nowTime = gg.time.time()
    local endTime = self.moreBuilder.endTime
    local day = 0
    if nowTime < endTime then
        day = math.ceil((endTime - nowTime) / constant.TIME_ONE_DAY_TO_SECONE)
    end
    gg.client:send(self.player.linkobj, "S2C_Player_MoreBuilder",  {day=day})
end

function RechargeActivityBag:addBuildQueueTime(cfgId)
    local builderCfg = gg.getExcelCfg("moreBuilderQue")
    if not builderCfg then
        return
    end
    local resDict = {}
    local builder = builderCfg[cfgId]
    if not builder then
        return
    end
    resDict[builder.cost[1]] = builder.cost[2]
    if not self.player.resBag:enoughResDict(resDict) then
        return
    end
    self.player.resBag:costResDict(resDict, {logType=gamelog.BUY_BUILD_QUEUE})
    for k,v in pairs(builder.reward) do
        self.player.itemBag:addItem(v[1], v[2], { logType=gamelog.BUY_BUILD_QUEUE })
    end
    
    -- local endTime = self.moreBuilder.endTime
    -- local nowTime = gg.time.time()
    -- if endTime < nowTime then
    --     endTime = nowTime + constant.TIME_ONE_MONTH_TO_SECONE
    -- else
    --     endTime = endTime + constant.TIME_ONE_MONTH_TO_SECONE
    -- end
    -- self.moreBuilder.endTime = endTime
    self.moreBuilder.status = 1
    self:sendBuildQueue()
    gg.client:send(self.player.linkobj,"S2C_Player_BuildQueueData",{ buildQueueCount = self.player.buildBag:_getBuildQueueLimit()})
end

function RechargeActivityBag:addBuildQueueTimeByTime(time)
    time = time or 0
    local endTime = self.moreBuilder.endTime
    local nowTime = gg.time.time()
    if endTime < nowTime then
        endTime = nowTime + time
    else
        endTime = endTime + time
    end
    self.moreBuilder.endTime = endTime
    self.moreBuilder.status = 1
    self:sendBuildQueue()
    gg.client:send(self.player.linkobj,"S2C_Player_BuildQueueData",{ buildQueueCount = self.player.buildBag:_getBuildQueueLimit()})
end

function RechargeActivityBag:getBuildQueue()
    local endTime = self.moreBuilder.endTime
    local nowTime = gg.time.time()
    if endTime > nowTime then
        return 1
    end
    return 0
end

function RechargeActivityBag:getProductCfg(productId)
    local product = cfg.get("etc.cfg.product")
    for k,v in pairs(product) do
        if v.productId == productId then
            return v
        end
    end
    return nil
end


-- ""
function RechargeActivityBag:getDailyGiftBagCfg(productId)
    local dailyGiftBagCfg = cfg.get("etc.cfg.dailyGiftBag")
    for k,v in pairs(dailyGiftBagCfg) do
        if v.productId == productId then
            return v
        end
    end
    return nil
end

function RechargeActivityBag:sendDailyGiftBag()
    if not self:isValid(constant.DAILYGIFT) then
        return
    end
    local data = {}
    for productId,v in pairs(constant.IS_GIFT_BAG) do
        local dailyGiftBagCfg = self:getDailyGiftBagCfg(productId)
        local num = self.dailyGiftBag.data[productId] or 0
        data[dailyGiftBagCfg.sort] = {productId = productId, num = dailyGiftBagCfg.num - num}
    end
    gg.client:send(self.player.linkobj,"S2C_Player_DailyGift",{ data = data })
end

-- ""  ""
function RechargeActivityBag:getGiftReward(productId)
    local productCfg = self:getProductCfg(productId)
    local dailyGiftBagCfg = self:getDailyGiftBagCfg(productId)
    local data = self.dailyGiftBag.data
    if data[productId] then
        if dailyGiftBagCfg.num == data[productId] then
            -- ""
            self:getCompensation(productId)
            return
        end
        data[productId] = data[productId] + 1
    else
        data[productId] = 1
    end
    self.player.itemBag:addItem(productCfg.itemCfgId, 1, { logType=gamelog.BUY_GIFT_BAG_REWARD })
    self:sendDailyGiftBag()
end


-- ""
function RechargeActivityBag:flushBuyGiftBagNum()
    if not self:isValid(constant.DAILYGIFT) then
        return
    end
    local nowTIme = gg.time.time()
    if nowTIme >= self.dailyGiftBag.nextTime then
        self.dailyGiftBag.nextTime = self:nextDayZeroTime()
        self.dailyGiftBag.data = {}
        self:sendDailyGiftBag()
    end
end

-- ""

-- self.dailyCheck = param.dailyCheck or {
--     nextTime = self:nextDayZeroTime(),
--     nextFlushTime = self:nextWeekZeroTime(),
--     data = {}
-- }

function RechargeActivityBag:getDailyCheckRewardCfg()
    local dailyCheckCfg = gg.getExcelCfg("dailyCheck")
    return dailyCheckCfg[1]
end

function RechargeActivityBag:sendDailyCheck()
    local nowTime = gg.time.time()
    local flushTime = self:nextDayZeroTime() - nowTime
    gg.client:send(self.player.linkobj,"S2C_Player_DailyCheck",{ data = self.dailyCheck.data ,flushTime = flushTime})
end

function RechargeActivityBag:getDailyCheckReward(weekDay)
    if not self.dailyCheck.data[weekDay] then
        return
    end
    if self.dailyCheck.data[weekDay].status ~= 1 then
        return
    end
    if weekDay == 7 then
        for k,v in pairs(self.dailyCheck.data) do
            if v.status == 0 then
                return
            end
        end
    end
    --""
    local rewardCfg = self:getDailyCheckRewardCfg()
    self:getReward(rewardCfg.reward[weekDay], gamelog.DAILY_CHECK)
    self.dailyCheck.data[weekDay].status = 2
    self:sendDailyCheck()
end

function RechargeActivityBag:setDailyCheck()
    local day  = self.dailyCheck.nextDay
    if day >= 8 then
        day = 7
    end
    if self.dailyCheck.data[day].status == 0 then
        self.dailyCheck.data[day].isFirst = 1
        self.dailyCheck.data[day].status = 1
    end
    self:sendDailyCheck()
    self.dailyCheck.data[day].isFirst = 0
end

function RechargeActivityBag:flushDailyCheck()
    self.dailyCheck = self:newDailyCheck()
    self:setDailyCheck()
end

function RechargeActivityBag:fixDayliyCheck()
    if not self.dailyCheck.lastTick then
        self.dailyCheck.lastTick = gg.time.dayzerotime()
        if self.dailyCheck.nextDay == 1 then
            self.dailyCheck.nextDay = 2
        end
    end
end

function RechargeActivityBag:setCheckNextDay()
    local nowTime = gg.time.time()
    self:fixDayliyCheck()
    if nowTime - self.dailyCheck.lastTick >= constant.TIME_ONE_DAY_TO_SECONE   then
        self.dailyCheck.nextDay = self.dailyCheck.nextDay + 1
        self.dailyCheck.lastTick = gg.time.dayzerotime()
    end
end

-- ""
function RechargeActivityBag:sendShoppingMallInfo()
    if not self:checkShoppingMallTime() then
        return
    end
    gg.client:send(self.player.linkobj,"S2C_Player_ShoppingMall",{ overTimes = self.shoppingMall.overTimes, data = self.shoppingMall.data, freshNum = self.shoppingMall.fresh })
end

function RechargeActivityBag:buyGoodsByTesseract(index)
    self:checkShoppingMallTime()
    local data = self.shoppingMall.data[index]
    if not data then
        self.player:say(util.i18nFormat(errors.NOT_GOODS))
        return
    end
    if data.num >= 1 then
        local smCfg = gg.getExcelCfg("shoppingMall")
        local resDict = {}
        resDict[constant.RES_TESSERACT] = smCfg[data.cfgId].price
        if not self.player.resBag:enoughResDict(resDict) then
            return
        end
		data.num = data.num - 1
        self.player.resBag:costResDict(resDict, {logType=gamelog.BUY_GIFT_BAG_REWARD})
        self.player.itemBag:addItem(smCfg[data.cfgId].item, 1, { logType=gamelog.BUY_GIFT_BAG_REWARD })
        self:sendShoppingMallInfo()
    end
end

function RechargeActivityBag:initSpmProductIds()
    local smCfg = gg.getExcelCfg("shoppingMall")
    for k,v in pairs(smCfg) do
        if v.productId and v.productId ~= "" then
            self.spmProductIds[v.productId] = true
        end
    end
end

function RechargeActivityBag:checkBuyGoodsByUsd(productId)
    self:checkShoppingMallTime()
    if not self.spmProductIds or not next(self.spmProductIds) then
        self:initSpmProductIds()
    end
    if not self.spmProductIds[productId] then
        return
    end
    local goodsCfgs = {}
    local smCfg = gg.getExcelCfg("shoppingMall")
    for k,v in pairs(smCfg) do
        if v.productId == productId then
            goodsCfgs[v.cfgId] = v
        end
    end
    local data
    local item
    for cfgId,goodsCfg in pairs(goodsCfgs) do
        for k,v in pairs(self.shoppingMall.data or {}) do
            if v.cfgId == cfgId then
                data = v
                item = goodsCfg.item
            end
        end
    end
    if not data or data.num < 1 then
        self:getCompensation(productId)
        return
    end
    data.num = data.num - 1
    self.player.itemBag:addItem(item, 1, { logType=gamelog.BUY_GIFT_BAG_REWARD })
    self:sendShoppingMallInfo()
end

function RechargeActivityBag:freshShoppingMall(isfree)
    if not self:checkShoppingMallTime() then
        return
    end
    if not isfree then
        local freshCount = self.shoppingMall.fresh
        local flushShoppingMallNum = gg.getGlobalCfgIntValue("flushShoppingMallNum", 10)
        if freshCount > flushShoppingMallNum then
            self.player:say(util.i18nFormat(errors.NUM_FRESH_LIMIT))
            return
        end
        local freshCostCfg = gg.getGlobalCfgTableValue("FlushShoppingMallCost", {})
        if freshCount >= #freshCostCfg then
            freshCount = #freshCostCfg
        end
        local costCfg = freshCostCfg[freshCount]
        if not costCfg then
            self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
            return
        end
        local resDict = {}
        resDict[costCfg[1]] = costCfg[2]
        if not self.player.resBag:enoughResDict(resDict) then
            return
        end
        if not self.player.resBag:costResDict(resDict, { logType = gamelog.FRESH_SHOPPINGMALL }) then
            return
        end
        self.shoppingMall.fresh = self.shoppingMall.fresh + 1
    end
    self.shoppingMall.data = self:newShoppingMall()
    self:sendShoppingMallInfo()
end

function RechargeActivityBag:setShoppingMall()
    local nowTime = gg.time.time()
    if nowTime >= self.shoppingMall.overTimes  then
        local actCfg = self:getGiftActivities(constant.SHOPING_MALL)
        self.shoppingMall.startTimes = self:initShoppingMallStartime() --self.shoppingMall.overTimes + constant.TIME_ONE_DAY_TO_SECONE * actCfg.interval
        self.shoppingMall.overTimes = self:newShoppingMallOverTime() --self.shoppingMall.startTimes + constant.TIME_ONE_DAY_TO_SECONE * actCfg.duration
        self.shoppingMall.data = self:newShoppingMall()
        self.shoppingMall.fresh = 1
    end
end

-- ""
function RechargeActivityBag:isloginActEnd()
    local actCfg = self:getGiftActivities(constant.LOGIN_ACT)
    if not actCfg then
        return true
    end
    if actCfg.status == 0 then
        return true
    end
    local nowTime = gg.time.time()
    if self.loginActInfo.endTime < nowTime then
        return true
    end
    return false
end

function RechargeActivityBag:sendLoginActInfo()
    if self:isloginActEnd() then
       return
    end
    gg.client:send(self.player.linkobj,"S2C_Player_LoginActivityInfo",{ endTime = self.loginActInfo.endTime, data = self.loginActInfo.data })
end

function RechargeActivityBag:setLoginActNextDay()
    if self:isloginActEnd() then
        return
     end
    local nowTime = gg.time.time()
    if nowTime < self.loginActInfo.nextTick then
        return
    end
    self.loginActInfo.nextDay = self.loginActInfo.nextDay + 1
end

function RechargeActivityBag:setLoginActDay()
    if self:isloginActEnd() then
        return
    end
    local day  = self.loginActInfo.nextDay
    if day >= 8 then
        day = 7
    end
    local nowTime = gg.time.time()
    if nowTime < self.loginActInfo.nextTick then
        return
    end
    if self.loginActInfo.data[day].baseStatus == constant.LOGINACT_NOT_LOGIN then
        self.loginActInfo.data[day].baseStatus = constant.LOGINACT_LOGIN_NOT_GET
    end
    if self.loginActInfo.data[day].advStatus == constant.LOGINACT_NOT_LOGIN then
        self.loginActInfo.data[day].advStatus = constant.LOGINACT_LOGIN_NOT_GET
    end

    self.loginActInfo.nextTick = gg.time.dayzerotime() + constant.TIME_ONE_DAY_TO_SECONE
    self.loginActInfo.nextDay = self.loginActInfo.nextDay + 1
    self:sendLoginActInfo()
end

function RechargeActivityBag:unLockLoginActAdv(day)
    if self:isloginActEnd() then
        return
    end
    local loginActCfg = self:getLoginActCfg()
    -- for k,v in pairs(loginActCfg) do
    --     if v.costProductId == productId then
    --         day = v.day
    --     end
    -- end
    if not day or day < 0 or day > #loginActCfg then
        return
    end
    local loginAct = loginActCfg[day]
    if not loginAct then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    local resDict = {}
    resDict[constant.RES_TESSERACT] = loginAct.cost
    if not self.player.resBag:enoughResDict(resDict) then
        self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
        return
    end
    
    local data = self.loginActInfo.data
    if data[day].advStatus ~= constant.LOGINACT_LOCK then  -- ""
        -- self:getCompensation(productId)
        self.player:say(util.i18nFormat(errors.REPEAT_UNLOCK))
        return
    elseif data[day].baseStatus == constant.LOGINACT_NOT_LOGIN then
        data[day].advStatus = constant.LOGINACT_NOT_LOGIN
    else
        data[day].advStatus = constant.LOGINACT_LOGIN_NOT_GET
    end
    self.player.resBag:costResDict(resDict, {logType=gamelog.UNLOCK_LOGIN_ACT_ADV})
    self:sendLoginActInfo()
end

function RechargeActivityBag:getLoginActDayReward(day)
    if self:isloginActEnd() then
        return
    end
    if day < 1 or day > 7 then
        return
    end
    local advStats = self.loginActInfo.data[day].advStatus
    if not advStats then
        return
    end
    local baseStatus = self.loginActInfo.data[day].baseStatus
    if not baseStatus then
        return
    end
    local loginActInfo = self:getLoginActCfg()
    if not loginActInfo then
        return
    end
    if  baseStatus == constant.LOGINACT_LOGIN_NOT_GET then
        local rewardCfgId = loginActInfo[day].baseReward
        for k,v in pairs(rewardCfgId) do
            self.player.itemBag:addItem(v[1], v[2], { logType=gamelog.LOGIN_ACT })
        end
        self.loginActInfo.data[day].baseStatus = constant.LOGINACT_LOGIN_AND_GET
    end
    if advStats == constant.LOGINACT_LOGIN_NOT_GET then
        local rewardCfgId = loginActInfo[day].advReward
        for k,v in pairs(rewardCfgId) do
            self.player.itemBag:addItem(v[1], v[2], { logType=gamelog.LOGIN_ACT })
        end
        self.loginActInfo.data[day].advStatus = constant.LOGINACT_LOGIN_AND_GET
    end
    self:sendLoginActInfo()
end

-- ""
function RechargeActivityBag:sendStarPackRewardMail(rewardCfgId, starPackName)
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.STARPACK_REWARD_MAIL_TEMPLATE]
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle
    local rewarCfg = self:getRewardCfg(rewardCfgId)
    local mailItems = {}
    for k,v in pairs(rewarCfg.resReward) do
        table.insert(mailItems, {
            cfgId = v[1],
            count = v[2],
            type = constant.MAIL_ATTACH_RES,
        })
    end
    local mailData = {
        title = title,
        content = string.format(mailCfg.mailContent, starPackName),
        attachment = mailItems,
        logType = gamelog.STAR_PACK_REWARD
    }
    gg.mailProxy:send("gmSendMail", sendId, sendName, { self.player.pid }, mailData)

end

-- ""
function RechargeActivityBag:setStarPackRewarNextTime()
    return gg.time.dayzerotime() + constant.TIME_ONE_DAY_TO_SECONE
end

function RechargeActivityBag:sendStarPackReward()
    local nowTime = gg.time.time()
    if nowTime < self.starPack.nextTime then
        return
    end
    self.starPack.nextTime = self:setStarPackRewarNextTime()
    local supplyPackCfg = gg.getExcelCfg("starPack")
    if not supplyPackCfg then
        return
    end
    for k,v in pairs(self.starPack.data) do
        if v.endTime > nowTime then
            local rewardCfgId = supplyPackCfg[tonumber(k)].rewardCfgId
            local productId = supplyPackCfg[tonumber(k)].product
            local productCfg = self:getProductCfg(productId)
            -- ""
            self:sendStarPackRewardMail(rewardCfgId, productCfg.mailTips)
        end
    end
    self:sendStarPack()
end

function RechargeActivityBag:sendStarPack()
    local nowTime = gg.time.time()
    local data = {}
    for k,v in pairs(self.starPack.data) do
        local day = 0
        if nowTime < v.endTime then
            day = math.ceil((v.endTime - nowTime) / constant.TIME_ONE_DAY_TO_SECONE)
        end
        table.insert(data, {cfgId = tonumber(k), day = day})
    end
    gg.client:send(self.player.linkobj, "S2C_Player_StarPack",  {data=data})
end

function RechargeActivityBag:setStarPack(productId)
    local supplyPackCfg = gg.getExcelCfg("starPack")
    if not supplyPackCfg then
        return
    end
    local supplyPack
    for k,v in pairs(supplyPackCfg) do
        if v.product == productId then
            supplyPack = v
            break
        end
    end
    if not supplyPack then
        return
    end
    local data = self.starPack.data
    if not data[tostring(supplyPack.cfgId)] then
        data[tostring(supplyPack.cfgId)] = {}
    end
    local endTime = data[tostring(supplyPack.cfgId)].endTime or 0
    local nowTime = gg.time.time()
    if endTime >= nowTime then
        data[tostring(supplyPack.cfgId)].endTime = data[tostring(supplyPack.cfgId)].endTime +  supplyPack.duration * constant.TIME_ONE_DAY_TO_SECONE
    else    -- ""
        data[tostring(supplyPack.cfgId)].endTime = nowTime + supplyPack.duration * constant.TIME_ONE_DAY_TO_SECONE
        local productId = supplyPack.product
        print(productId)
        local productCfg = self:getProductCfg(productId)
        self:sendStarPackRewardMail(supplyPack.rewardCfgId, productCfg.mailTips)   -- ""
        self.starPack.nextTime = self:setStarPackRewarNextTime()        -- ""
    end
    self.starPack.endTime = endTime
    self:sendStarPack()
end

-- ""
-- ""
-- function RechargeActivityBag:sendbaseLevelPack()
--     if not self:isValid(constant.LEVEL_PACK) then
--         return
--     end
--     local mailTemplate = gg.getExcelCfg("mailTemplate")
--     local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_LEVEL_GIF_PACK]
--     local sendId = 0
--     local sendName = mailCfg.sendName
--     local title = mailCfg.mailTitle
--     local actCfg = self:getGiftActivities(constant.LEVEL_PACK)
--     local rewardCfgId = actCfg.reward
--     local rewarCfg = self:getRewardCfg(rewardCfgId)
--     local mailItems = {}
--     for k,v in pairs(rewarCfg.itemReward) do
--         table.insert(mailItems, {
--             cfgId = v[1],
--             count = v[2],
--             type = constant.MAIL_ATTACH_ITEM,
--         })
--     end
--     local mailData = {
--         title = title,
--         content = mailCfg.mailContent,
--         attachment = mailItems,
--         logType = gamelog.LEVEL_PACK_REWARD
--     }
--     gg.mailProxy:send("gmSendMail", sendId, sendName, { self.player.pid }, mailData)
-- end

-- function RechargeActivityBag:checkbaseLevelPack()
--     if self.baseLevelPack ~= 1 then
--         self.baseLevelPack = 1
--         self:sendbaseLevelPack()
--     end
-- end

-- ""
-- ""
function RechargeActivityBag:nextWeekZeroTime()
    return gg.time.weekzerotime() + constant.TIME_ONE_WEEK_TO_SECONE
end

-- ""
function RechargeActivityBag:nextDayZeroTime()
    return gg.time.dayzerotime() + constant.TIME_ONE_DAY_TO_SECONE
end

function RechargeActivityBag:checkBuilderTime()
    if self.moreBuilder.status == 0 then
        return
    end
    local endTime = self.moreBuilder.endTime
    local nowTime = gg.time.time()
    if endTime < nowTime then
        self.moreBuilder.status = 0
        gg.client:send(self.player.linkobj,"S2C_Player_BuildQueueData",{ buildQueueCount = self.player.buildBag:_getBuildQueueLimit()  })
    end
end

function RechargeActivityBag:onSecond()
    self:checkBuilderTime()
end

function RechargeActivityBag:onHourUpdate()
    self:flushBuyGiftBagNum()
	--self:checkBuilderTime()
end

-- ""
function RechargeActivityBag:onDayUpdate()
    self:setCheckNextDay()
    self:setDailyCheck()
    --self:setLoginActNextDay()
    self:setLoginActDay()
    self:setShoppingMall()
    self:freshShoppingMall(true)
    self:sendMoonCardReward()
    self:sendStarPackReward()
    self:sendBuildQueue()
    self:sendShoppingMallInfo()
end


function RechargeActivityBag:onMondayUpdate()
    self:flushDailyCheck()
end

function RechargeActivityBag:onlogin()
    -- self:queryFirstCharge()
    if self:isValid(constant.CUMULATIVE_FUNDS) then
        self:sendCumulativeFunds()
    end

    if self:isValid(constant.FIREST_RECHARGE) then
        self:sendRechargeInfo()
    end
    if self:isValid(constant.DOUBLE_RECHARGE) then
        self:sendDoubleRe()
    end
    self:sendMoonCard()
    self:sendStarPack()
    self:sendBuildQueue()
    self:sendDailyGiftBag()
    self:setDailyCheck()
	self:setShoppingMall()
    self:sendShoppingMallInfo()
    self:sendLoginActInfo()
    self:setLoginActDay()
    --self:checkbaseLevelPack()
end

return RechargeActivityBag