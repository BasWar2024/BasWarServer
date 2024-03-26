local ChainBridgeBag = class("ChainBridgeBag")

local bson = require "bson"

function ChainBridgeBag:ctor(param)
    self.player = param.player                  -- ""
    self.rechargeToken = {}
    self.withdrawToken = {}
    self.rechargeNFT = {}
    self.payOrder = {}
    self.lastLaunchTick = gg.time.time()
end

function ChainBridgeBag:serialize()
    local data = {}
    data.rechargeToken = self.rechargeToken
    data.withdrawToken = self.withdrawToken
    data.rechargeNFT = self.rechargeNFT
    data.payOrder = self.payOrder
    data.lastLaunchTick = self.lastLaunchTick
    return data
end

function ChainBridgeBag:deserialize(data)
    if not data then
        return
    end
    self.rechargeToken = data.rechargeToken or {}
    self.withdrawToken = data.withdrawToken or {}
    self.rechargeNFT = data.rechargeNFT or {}
    self.payOrder = data.payOrder or {}
    self.lastLaunchTick = data.lastLaunchTick or 0
    if self.lastLaunchTick <= 0 then
        self.lastLaunchTick = gg.time.time()
    end
end

function ChainBridgeBag:loadNFTInfo(token_id)
    local doc = gg.mongoProxy.nftInfo:findOne({token_id=token_id})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

function ChainBridgeBag:syncNFTInfo(tokenId, entity)
    if not entity then
        return
    end
    local nftInfo = {}
    nftInfo.token_id = tokenId
    nftInfo.level = entity.level
    nftInfo.life = entity.life
    nftInfo.curLife = entity.curLife

    nftInfo.skill1 = entity.skill1
    nftInfo.skill2 = entity.skill2
    nftInfo.skill3 = entity.skill3
    nftInfo.skill4 = entity.skill4

    nftInfo.skillLevel1 = entity.skillLevel1
    nftInfo.skillLevel2 = entity.skillLevel2
    nftInfo.skillLevel3 = entity.skillLevel3
    nftInfo.skillLevel4 = entity.skillLevel4

    gg.mongoProxy.nftInfo:update({token_id = nftInfo.token_id}, {["$set"] = nftInfo }, false, false)
end

function ChainBridgeBag:dealRechargeToken(data)
    if not self.rechargeToken[data.order_num] then
        self.rechargeToken[data.order_num] = 1
        if data.token == "MIT" then
            self.player.resBag:addRes(constant.RES_MIT, data.value, { logType = gamelog.BRIDGE_RECHARGE_TOKEN })
        elseif data.token == "HYT" then
            self.player.resBag:addRes(constant.RES_CARBOXYL, data.value, { logType = gamelog.BRIDGE_RECHARGE_TOKEN })
        end
        logger.logf("info","ChainBridge","op=dealRechargeToken,order_num=%s,chain_id=%s,token=%s,value=%s,pid=%s",data.order_num,data.chain_id,data.token,data.value,self.player.pid)
    end
    gg.chainBridgeProxy:send("rechargeTokenFinish", data.order_num)
end



function ChainBridgeBag:dealPayOrder(data)
    if not self.payOrder[data.orderId] then
        self.payOrder[data.orderId] = 1

        local source = nil
        if data.payChannel == constant.PAYCHANNEL_LOCAL then
            source = { logType = gamelog.ORDER_PAY_LOCAL }
        elseif data.payChannel == constant.PAYCHANNEL_XSOLLA then
            source = { logType = gamelog.ORDER_PAY_XSOLLA }
        elseif data.payChannel == constant.PAYCHANNEL_INTERNATION then
            source = { logType = gamelog.ORDER_PAY_INTERNATION }
        elseif data.payChannel == constant.PAYCHANNEL_APPSTORE then
            source = { logType = gamelog.ORDER_PAY_APPSTORE }
        elseif data.payChannel == constant.PAYCHANNEL_GOOGLEPLAY then
            source = { logType = gamelog.ORDER_PAY_GOOGLEPLAY }
        end
        if source then
            if constant.IS_CUMULATIVE_FUNDS[data.productId] then
                self.player.rechargeActivityBag:setFunds(data.productId)
            end
            if constant.IS_RECHARGE[data.productId] then
                local dict = {}
                dict.res = constant.RES_TESSERACT
                dict.count = data.value
                self.player.mailBag:rebateToInviter(dict, constant.MAIL_TEMPLATE_REBATETOINVITER)
                -- ""
                if self.player.rechargeActivityBag:setDoubleRe(data.productId) then
                    data.value = data.value * constant.DOUBLE_RECHARGE_VALUE
                end
            end
            self.player.rechargeActivityBag:checkActProduct(data.productId) -- ""
            self.player.rechargeActivityBag:checkBuyGoodsByUsd(data.productId) -- ""
            self.player.vipBag:checkBuyVipLevel(data.productId)  -- ""vip
            self.player.resBag:addRes(constant.RES_TESSERACT, data.value, source)
            self.player.rechargeActivityBag:setDoubleRe(data.productId)
            self.player.rechargeActivityBag:addRechargeVal(data.price)
            self.player.mailBag:sendNotificationMail(data.productId)
            -- ""
            if data.value > 0 then
                local resInfo = {}
                table.insert(resInfo, { resCfgId = constant.RES_TESSERACT, count = data.value})
                gg.client:send(self.player.linkobj, "S2C_Player_TipNote",  { tipType = 1, resInfo = resInfo })
            end
            logger.logf("info","ChainBridge","op=dealPayOrderSuccess,orderId=%s,pid=%s,value=%s",data.orderId,data.pid,data.value)
        else
            logger.logf("info","ChainBridge","op=dealPayOrderFail,orderId=%s,pid=%s,value=%s",data.orderId,data.pid,data.value)
        end
        gg.internal:send(".gamelog", "api", "addPlayerPayOrderLog", self.player.pid, data.orderId, data.price, data.value, data.dayno)
    end
    gg.chainBridgeProxy:send("payOrderFinish", data.orderId)
end

function ChainBridgeBag:backWithdrawToken(data)
    local order_num = data.order_num
    if not order_num then
        return
    end
    order_num = tostring(order_num)
    if not self.withdrawToken[order_num] then
        self.withdrawToken[order_num] = 1
        if data.token == "MIT" then
            self.player.resBag:addRes(constant.RES_MIT, data.amount, { logType = gamelog.BRIDGE_WITHDRAW_REJECT })
        elseif data.token == "HYT" then
            self.player.resBag:addRes(constant.RES_CARBOXYL, data.amount, { logType = gamelog.BRIDGE_WITHDRAW_REJECT })
        end
    end
end

function ChainBridgeBag:doWithdrawToken(chain_id, token, amount, fee, flight_no, walletInfo)
    logger.logf("info","ChainBridge","op=doWithdrawToken step1 pid=%d chain_id=%s token=%s amount=%s flight_no=%s", self.player.pid, tostring(chain_id), tostring(token), tostring(amount), tostring(flight_no))

    amount = math.floor(tonumber(amount))
    if amount <= 0 then
        logger.logf("info","ChainBridge","op=doWithdrawToken step2 pid=%d chain_id=%s token=%s amount=%s flight_no=%s", self.player.pid, tostring(chain_id), tostring(token), tostring(amount), tostring(flight_no))
        return
    end

    --token"",""
    if token == "MIT" then
        if not self.player.resBag:enoughRes(constant.RES_MIT, amount) then
            self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_MIT]))
            logger.logf("info","ChainBridge","op=doWithdrawToken step3 pid=%d chain_id=%s token=%s amount=%s flight_no=%s", self.player.pid, tostring(chain_id), tostring(token), tostring(amount), tostring(flight_no))
            return
        end
    elseif token == "HYT" then
        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, amount) then
            self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_CARBOXYL]))
            logger.logf("info","ChainBridge","op=doWithdrawToken step4 pid=%d chain_id=%s token=%s amount=%s flight_no=%s", self.player.pid, tostring(chain_id), tostring(token), tostring(amount), tostring(flight_no))
            return
        end
    else
        self.player:say(util.i18nFormat(errors.BRIDGE_TOKEN_NOT_EXIST))
        logger.logf("info","ChainBridge","op=doWithdrawToken step5 pid=%d chain_id=%s token=%s amount=%s flight_no=%s", self.player.pid, tostring(chain_id), tostring(token), tostring(amount), tostring(flight_no))
        return
    end

    --""
    if token == "MIT" then
        self.player.resBag:costRes(constant.RES_MIT, amount, { logType=gamelog.BRIDGE_WITHDRAW_TOKEN })
    elseif token == "HYT" then
        self.player.resBag:costRes(constant.RES_CARBOXYL, amount, { logType=gamelog.BRIDGE_WITHDRAW_TOKEN })
    end

    local now = skynet.timestamp()
    local order_num = gg.shareProxy:call("genWithdrawId")

    --""
    local data = {}
    data.order_num = order_num
    data.token = token
    data.amount = amount - fee
    data.chain_id = chain_id
    data.to_address = walletInfo.walletAddress
    data.owner_mail = walletInfo.accountMail
    data.create_time = now
    data.claim_time = now + 5000
    data.update_time = now
    data.state = constant.CHAIN_BRIDGE_WITHDRAW_STATE_APPROVAL
    data.message = constant.CHAIN_BRIDGE_WITHDRAW_DES_APPROVAL
    data.flight_no = flight_no or "warship#0000"
    data.pid = self.player.pid
    data.platform = self.player.platform
    data.dayno = gg.time.dayno()
    data.weekno = gg.time.weekno()
    data.monthno = gg.time.monthno()
    data.createTime = bson.date(math.floor(now/1000))
    data.createDate = tonumber(os.date("%Y%m%d", math.floor(now/1000)))
    gg.mongoProxy.withdrawToken:insert(data)

    logger.logf("info","ChainBridge","op=doWithdrawToken step6 pid=%d chain_id=%s token=%s amount=%s flight_no=%s order_num=%s", self.player.pid, tostring(chain_id), tostring(token), tostring(amount), tostring(flight_no), tostring(order_num))
end

function ChainBridgeBag:dealRechargeNFT(data)
    logger.logf("info","ChainBridge","op=dealRechargeNFT step1 pid=%d data=%s", self.player.pid, table.dump(data))
    local success_ids = ""
    local fail_ids = ""
    for _, token_id in pairs(data.token_ids) do
        local order_num_unique = data.order_num .. "_" .. token_id
        if not self.rechargeNFT[order_num_unique] then
            local success = false
            local param = self:loadNFTInfo(token_id)
            if param then
                if param.kind then
                    param.kind = math.floor(param.kind)
                end
                if param.style then
                    param.style = math.floor(param.style)
                end
                if param.quality then
                    param.quality = math.floor(param.quality)
                end
                if param.level then
                    param.level = math.floor(param.level)
                end
                local entity = nil
                if param.kind == constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP then
                    entity = self.player.warShipBag:initialWarShipNFT(param)
                    if entity then
                        success = true
                    end
                elseif param.kind == constant.CHAIN_BRIDGE_NFT_KIND_HERO then
                    entity = self.player.heroBag:initialHeroNFT(param)
                    if entity then
                        success = true
                    end
                elseif param.kind == constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE then
                    entity = self.player.buildBag:initialBuildNFT(param)
                    if entity then
                        success = true
                    end
                elseif param.kind == constant.CHAIN_BRIDGE_NFT_KIND_ITEM_NFT then
                    local ret = self.player.itemBag:addItem(param.cfgId, 1, {logType=gamelog.BRIDGE_RECHARGE_NFT}, { id = param.token_id })
                    if ret == 1 then
                        success = true
                    end
                elseif param.kind == constant.CHAIN_BRIDGE_NFT_KIND_ITEM_ARTIFACT then
                    local ret = self.player.itemBag:addItem(param.cfgId, 1, {logType=gamelog.BRIDGE_RECHARGE_NFT}, { id = param.token_id })
                    if ret == 1 then
                        success = true
                    end
                end
                if success then
                    if entity then
                        self:syncNFTInfo(token_id, entity)
                    end
                end
            end

            if success then
                self.rechargeNFT[order_num_unique] = 1
                success_ids = success_ids .. token_id .. ","
            else
                fail_ids = fail_ids .. token_id .. ","
            end
        end
    end
    gg.chainBridgeProxy:send("rechargeNFTFinish", data.order_num, success_ids, fail_ids)
    logger.logf("info","ChainBridge","op=dealRechargeNFT step2 pid=%d order_num=%s", self.player.pid, data.order_num)
end

function ChainBridgeBag:doWithdrawNFT(chain_id, entityNfts, itemNfts, flight_no, walletInfo)
    logger.logf("info","ChainBridge","op=doWithdrawNFT step1 pid=%d chain_id=%s entityNfts=%s itemNfts=%s flight_no=%s", self.player.pid, tostring(chain_id), table.dump(entityNfts), table.dump(itemNfts), tostring(flight_no))
    
    --entityNfts
    local token_ids = {}
    for tokenId, tokenKind in pairs(entityNfts) do
        local entity = nil
        if tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP then
            entity = self.player.warShipBag:getWarShip(tokenId)
        elseif tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_HERO then
            entity = self.player.heroBag:getHero(tokenId)
        elseif tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE then
            entity = self.player.buildBag:getBuild(tokenId)
        else
            self.player:say(util.i18nFormat(errors.ARG_ERR))
            return
        end
        if not entity then
            self.player:say(util.i18nFormat(errors.BRIDGE_ITEM_NOT_EXIST))
            return
        end
        if entity.chain <= 0 then
            self.player:say(util.i18nFormat(errors.BRIDGE_NOT_NFT))
            return
        end
        -- nft""，""
        if entity:isUpgrade() then
            self.player:say(util.i18nFormat(errors.BRIDGE_LEVEL_OR_SKILL_UP))
            return
        end
        if not constant.IsRefNone(entity) then
            self.player:say(util.i18nFormat(errors.BRIDGE_ENTITY_BUSY))
            return
        end
        if entity.curLife < entity.life then
            self.player:say(util.i18nFormat(errors.BRIDGE_NEED_MAX_LIFE))
            return
        end
        table.insert(token_ids, tokenId)
        self:syncNFTInfo(tokenId, entity)
    end

    --itemNfts
    local item_ids = {}
    local item_cfgids = {}
    for itemId, kind in pairs(itemNfts) do
        local item = self.player.itemBag:getItem(itemId)
        if not item then
            self.player:say(util.i18nFormat(errors.BRIDGE_ITEM_NOT_EXIST))
            return
        end
        if not constant.CHAIN_BRIDGE_ITEM_NFT[item.itemType] then
            self.player:say(util.i18nFormat(errors.BRIDGE_NOT_NFT))
            return
        end
        table.insert(item_ids, item.id)
        table.insert(item_cfgids, item.cfgId)
    end

    local now = skynet.timestamp()

    if next(token_ids) then
        --""、""、""
        local order_num = gg.shareProxy:call("genWithdrawId")
        local data = {}
        data.order_num = order_num
        data.token_ids = token_ids
        data.item_ids = {0}
        data.item_cfgids = {0}
        data.chain_id = chain_id
        data.to_address = walletInfo.walletAddress
        data.owner_mail = walletInfo.accountMail
        data.create_time = now
        data.claim_time = now + 5000
        data.update_time = now
        data.state = constant.CHAIN_BRIDGE_WITHDRAW_STATE_APPROVAL
        data.message = constant.CHAIN_BRIDGE_WITHDRAW_DES_APPROVAL
        data.flight_no = flight_no or "warship#0000"
        data.pid = self.player.pid
        data.platform = self.player.platform
        data.dayno = gg.time.dayno()
        data.weekno = gg.time.weekno()
        data.monthno = gg.time.monthno()
        data.createTime = bson.date(math.floor(now/1000))
        data.createDate = tonumber(os.date("%Y%m%d", math.floor(now/1000)))
        gg.mongoProxy.withdrawNft:insert(data)
    end

    if next(item_ids) and next(item_cfgids) then
        --""
        local order_num = gg.shareProxy:call("genWithdrawId")
        local data = {}
        data.order_num = order_num
        data.token_ids = {0}
        data.item_ids = item_ids
        data.item_cfgids = item_cfgids
        data.chain_id = chain_id
        data.to_address = walletInfo.walletAddress
        data.owner_mail = walletInfo.accountMail
        data.create_time = now
        data.claim_time = now + 5000
        data.update_time = now
        data.state = constant.CHAIN_BRIDGE_WITHDRAW_STATE_APPROVAL
        data.message = constant.CHAIN_BRIDGE_WITHDRAW_DES_APPROVAL
        data.flight_no = flight_no or "warship#0000"
        data.pid = self.player.pid
        data.platform = self.player.platform
        data.dayno = gg.time.dayno()
        data.weekno = gg.time.weekno()
        data.monthno = gg.time.monthno()
        data.createTime = bson.date(math.floor(now/1000))
        data.createDate = tonumber(os.date("%Y%m%d", math.floor(now/1000)))
        gg.mongoProxy.withdrawNft:insert(data)
    end

    --""entity
    for tokenId, tokenKind in pairs(entityNfts) do
        if tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP then
            self.player.warShipBag:delWarShip(tokenId, {logType=gamelog.BRIDGE_WITHDRAW_NFT})
        elseif tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_HERO then
            self.player.heroBag:delHero(tokenId, {logType=gamelog.BRIDGE_WITHDRAW_NFT})
        elseif tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE then
            self.player.buildBag:delBuild(tokenId, {logType=gamelog.BRIDGE_WITHDRAW_NFT})
        end
    end

    --""item
    for itemId, kind in pairs(itemNfts) do
        self.player.itemBag:delItemObj(itemId, {logType=gamelog.BRIDGE_WITHDRAW_NFT})
    end

    logger.logf("info","ChainBridge","op=doWithdrawNFT step5 pid=%d chain_id=%s token_ids=%s item_ids=%s item_cfgids=%s flight_no=%s", self.player.pid, tostring(chain_id), table.dump(token_ids), table.dump(item_ids), table.dump(item_cfgids), tostring(flight_no))

    return token_ids, item_ids, item_cfgids
end

function ChainBridgeBag:reduceWithdraw(value)
    self.lastLaunchTick = math.max(self.lastLaunchTick - value, 0)
    gg.client:send(self.player.linkobj, "S2C_Player_LaunchBridgeFees", { fees = constant.CHAIN_BRIDGE_LAUNCH_FEE, lastTick = self.lastLaunchTick })
end

function ChainBridgeBag:getLaunchLess()
    local nowTick = gg.time.time()

    local originalCD = gg.getGlobalCfgIntValue("WithdrawCD", 2592000)
    --vip""
    local vipReduce = self.player.vipBag:getWithdrawReduce()
    --""
    local buildReduce = self.player.buildBag:getWithdrawReduce()

    local nowCD = math.max(originalCD - vipReduce - buildReduce, 0)
    
    local less = math.max(0, self.lastLaunchTick + nowCD - nowTick)

    return less
end

function ChainBridgeBag:launchToBridge(chainId, warShipId, mit, hyt, entityNfts, itemNfts)
    logger.logf("info","ChainBridge","op=launchToBridge step1 pid=%d chainId=%s warShipId=%s mit=%s hyt=%s entityNfts=%s itemNfts=%s", self.player.pid, tostring(chainId), tostring(warShipId), tostring(mit), tostring(hyt), table.dump(entityNfts), table.dump(itemNfts))

    --""
    local chainBridgeStatus = gg.shareProxy:call("getChainBridgeStatus")
    if chainBridgeStatus == "close" then  --""open
        self.player:say(util.i18nFormat(errors.BRIDGE_CHAIN_PAUSE_USE))
        return
    end

    --""nft"",""cd,nft""
    if next(itemNfts) then
        self.player:say(util.i18nFormat(errors.ARG_ERR))
        logger.logf("info","ChainBridge","op=launchToBridge step11 pid=%d chainId=%s warShipId=%s mit=%s hyt=%s entityNfts=%s itemNfts=%s", self.player.pid, tostring(chainId), tostring(warShipId), tostring(mit), tostring(hyt), table.dump(entityNfts), table.dump(itemNfts))
        return
    end
    if mit > 0 or hyt > 0 then
        if next(entityNfts) then
            self.player:say(util.i18nFormat(errors.ARG_ERR))
            logger.logf("info","ChainBridge","op=launchToBridge step12 pid=%d chainId=%s warShipId=%s mit=%s hyt=%s entityNfts=%s itemNfts=%s", self.player.pid, tostring(chainId), tostring(warShipId), tostring(mit), tostring(hyt), table.dump(entityNfts), table.dump(itemNfts))
            return
        end
        if mit > 0 then
            local WithdrawMinMIT = gg.getGlobalCfgIntValue("WithdrawMinMIT", 10000)
            if mit < WithdrawMinMIT then
                self.player:say(util.i18nFormat(errors.BRIDGE_MIT_MIN, math.floor(WithdrawMinMIT / 1000)))
                return
            end
        end
        if hyt > 0 then
            local WithdrawMinHYT = gg.getGlobalCfgIntValue("WithdrawMinHYT", 3000000)
            if hyt < WithdrawMinHYT then
                self.player:say(util.i18nFormat(errors.BRIDGE_HYT_MIN, math.floor(WithdrawMinHYT / 1000)))
                return
            end
        end
    end

    local ret = gg.shareProxy:call("isBanTransport", self.player.account)
    if ret then
        self.player:say(util.i18nFormat(errors.BRIDGE_CHAIN_BAN_TRANSPORT))
        return
    end
    
    --chainId""
    chainId = self.player.playerInfoBag:getChainId()
    if not chainId or chainId <= 0 then
        self.player:say(util.i18nFormat(errors.BRIDGE_NO_BIND_WALLET))
        return
    end

    local validChain = constant.getValidChain()
    --chain_id""
    if not validChain[chainId] then
        self.player:say(util.i18nFormat(errors.BRIDGE_CHAIN_ID_NOT_EXIST))
        logger.logf("info","ChainBridge","op=launchToBridge step2 pid=%d chainId=%s warShipId=%s mit=%s hyt=%s entityNfts=%s itemNfts=%s", self.player.pid, tostring(chainId), tostring(warShipId), tostring(mit), tostring(hyt), table.dump(entityNfts), table.dump(itemNfts))
        return
    end
    
    if mit <= 0 and hyt <= 0 and not next(entityNfts) and not next(itemNfts) then
        self.player:say(util.i18nFormat(errors.ARG_ERR))
        logger.logf("info","ChainBridge","op=launchToBridge step3 pid=%d chainId=%s warShipId=%s mit=%s hyt=%s entityNfts=%s itemNfts=%s", self.player.pid, tostring(chainId), tostring(warShipId), tostring(mit), tostring(hyt), table.dump(entityNfts), table.dump(itemNfts))
        return
    end

    --"",""。"",""
    local chainBridgeNeedShip = gg.shareProxy:call("getChainBridgeNeedShip")
    if chainBridgeNeedShip ~= "close" then
        local nfts = self.player.warShipBag:getNftWarShips()
        if #nfts < 1 then
            self.player:say(util.i18nFormat(errors.BRIDGE_OWN_NFT_WARSHIP))
            return
        end
    end

    --""cd""
    if mit > 0 or hyt > 0 then
        local launchLess = self:getLaunchLess()
        if launchLess > 0 then
            self.player:say(util.i18nFormat(errors.BRIDGE_CHAIN_COOLING, gg.time.strftime("%H:%M:%S", launchLess)))
            return
        end
    end
   
    --""
    --[[
    local launchWarShip = self.player.warShipBag:getWarShip(warShipId)
    if not launchWarShip then
        self.player:say(util.i18nFormat(errors.WARSHIP_NOT_EXIST))
        return
    end
    if launchWarShip.chain <= 0 then
        self.player:say(util.i18nFormat(errors.BRIDGE_NOT_NFT))
        return
    end
    if not constant.IsRefNone(launchWarShip) then
        self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
        return
    end
    ]]
    
    --""
    local walletInfo = gg.shareProxy:call("getWalletAddressByAccount", self.player.account)
    if not walletInfo then
        self.player:say(util.i18nFormat(errors.BRIDGE_NO_BIND_WALLET))
        return
    end
    
    if mit > 0 then
        if not self.player.resBag:enoughRes(constant.RES_MIT, mit) then
            self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_MIT]))
            return
        end
    end
    
    local rate = 2000
    local fee = 1000 * 1000
    if hyt > 0 then
        local fees = constant.CHAIN_BRIDGE_LAUNCH_FEE
        for k, v in pairs(fees) do
            if hyt >= v.min and (( v.max > 0 and hyt < v.max) or v.max == -1) then
                rate = v.fee
                break
            end
        end
        local calFee = math.ceil(hyt * rate / 10000)
        fee = math.max(calFee, fee)
        if hyt <= fee then
            self.player:say(util.i18nFormat(errors.BRIDGE_LAUNCH_HYT_LESS_FEE))
            return
        end

        if not self.player.resBag:enoughRes(constant.RES_CARBOXYL, hyt) then
            self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_CARBOXYL]))
            return
        end
    end
    
    for tokenId, tokenKind in pairs(entityNfts) do
        --[[
        if warShipId == tokenId then
            self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
            return
        end
        ]]
        local entity = nil
        if tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP then
            entity = self.player.warShipBag:getWarShip(tokenId)
            if entity then
                if self.player.warShipBag:isUseWarShip(entity.id) then
                    self.player:say(util.i18nFormat(errors.WARSHIP_REF_BUSY))
                    return
                end
            end
        elseif tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_HERO then
            entity = self.player.heroBag:getHero(tokenId)
        elseif tokenKind == constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE then
            entity = self.player.buildBag:getBuild(tokenId)
        else
            self.player:say(util.i18nFormat(errors.ARG_ERR))
            return
        end
        if not entity then
            self.player:say(util.i18nFormat(errors.BRIDGE_ITEM_NOT_EXIST))
            return
        end
        if entity.chain <= 0 or entity.chain == constant.BUILD_CHAIN_TOWER then
            self.player:say(util.i18nFormat(errors.BRIDGE_NOT_NFT))
            return
        end
        -- nft""
        if entity:isUpgrade() then
            self.player:say(util.i18nFormat(errors.BRIDGE_LEVEL_OR_SKILL_UP))
            return
        end
        if not constant.IsRefNone(entity) then
            self.player:say(util.i18nFormat(errors.BRIDGE_ENTITY_BUSY))
            return
        end
        if entity.curLife < entity.life then
            self.player:say(util.i18nFormat(errors.BRIDGE_NEED_MAX_LIFE))
            return
        end
    end

    for itemId, kind in pairs(itemNfts) do
        local item = self.player.itemBag:getItem(itemId)
        if not item then
            self.player:say(util.i18nFormat(errors.BRIDGE_ITEM_NOT_EXIST))
            return
        end
        if not constant.CHAIN_BRIDGE_ITEM_NFT[item.itemType] then
            self.player:say(util.i18nFormat(errors.BRIDGE_NOT_NFT))
            return
        end
    end

    local record = {}
    record.pid = self.player.pid
    record.time = os.time()
    record.mit = 0
    record.hyt = 0
    record.fee = 0
    record.tokenIds = {}
    record.itemIds = {}
    record.itemCfgIds = {}

    --launchWarShip:setLaunchTick()
    --local flightNo = launchWarShip:getName() .. "#" .. launchWarShip.id
    if mit > 0 or hyt > 0 then
        self.lastLaunchTick = gg.time.time()
    end
    
    local flightId = gg.shareProxy:call("genFlightId")
    local flightNo = "flight#" .. flightId
    if mit > 0 then
        self:doWithdrawToken(chainId, "MIT", mit, 0, flightNo, walletInfo)
        record.mit = mit
    end
    if hyt > 0 then
        self:doWithdrawToken(chainId, "HYT", hyt, fee, flightNo, walletInfo)
        record.hyt = hyt
        record.fee = fee
        --""
        local feeForLp = math.floor(fee * constant.FEE_FOR_LP_RATE)
        gg.redisProxy:call("incrby", constant.REDIS_FEE_FOR_LP, feeForLp)
    end
    if next(entityNfts) or next(itemNfts) then
        local token_ids, item_ids, item_cfgids = self:doWithdrawNFT(chainId, entityNfts, itemNfts, flightNo, walletInfo)
        record.tokenIds = token_ids
        record.itemIds = item_ids
        record.itemCfgIds = item_cfgids
    end
    
    gg.mongoProxy.withdrawRecord:insert(record)
    self.player.taskBag:update(constant.TASK_CASHOUT_COUNT, {})
    logger.logf("info","ChainBridge","op=launchToBridge step14 pid=%d chainId=%s warShipId=%s mit=%s hyt=%s entityNfts=%s itemNfts=%s", self.player.pid, tostring(chainId), tostring(warShipId), tostring(mit), tostring(hyt), table.dump(entityNfts), table.dump(itemNfts))

    self:synchInfo()
end

function ChainBridgeBag:getLaunchBridgeRecrods()
    local records = {}
    local docs = gg.mongoProxy.withdrawRecord:findSortLimit({ pid = self.player.pid }, {time=-1}, 10)
    for _, record in pairs(docs) do
        record._id = nil
        table.insert(records, { time = record.time, mit = record.mit, hyt = record.hyt, fee = record.fee, tokenIds = record.tokenIds , itemIds = record.itemIds, itemCfgIds = record.itemCfgIds})
    end
    gg.client:send(self.player.linkobj, "S2C_Player_GetLaunchBridgeRecrods", { records = records })
end

function ChainBridgeBag:synchInfo()
    local needShip = false
    local chainBridgeNeedShip = gg.shareProxy:call("getChainBridgeNeedShip")
    if chainBridgeNeedShip ~= "close" then
        needShip = true
    end
    gg.client:send(self.player.linkobj, "S2C_Player_LaunchBridgeFees", { fees = constant.CHAIN_BRIDGE_LAUNCH_FEE, lastTick = self.lastLaunchTick, needShip = needShip })
end

function ChainBridgeBag:onload()

end

function ChainBridgeBag:onlogin()
    self:synchInfo()
end


return ChainBridgeBag