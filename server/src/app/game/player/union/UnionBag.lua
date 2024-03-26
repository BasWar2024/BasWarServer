local UnionBag = class("UnionBag")

--""
function UnionBag:ctor(param)
    self.player = param.player
    self.invites = {}
    self.mints = {}
    self.applyVersion = 0
    self.leaveUnionTick = 0

    self.unionId = nil
    self.beginGridId = nil
    self.unionLevel = nil
    self.lastGetUnionIdTick = nil
end

function UnionBag:serialize()
    local data = {}
    data.invites = {}
    for k, v in pairs(self.invites) do
        table.insert(data.invites, v)
    end
    data.applyVersion = self.applyVersion
    data.leaveUnionTick = self.leaveUnionTick
    data.mints = {}
    for k, v in pairs(self.mints) do
        table.insert(data.mints, v)
    end
    return data
end

function UnionBag:deserialize(data)
    if data.invites then
        for k, v in pairs(data.invites) do
            self.invites[v.unionId] = v
        end
    end
    self.applyVersion = data.applyVersion or 0
    self.leaveUnionTick = data.leaveUnionTick or 0
    for k, v in pairs(data.mints or {}) do
        table.insert(self.mints, v)
    end
end

function UnionBag:packJoinApply(apply)
    local data = {}
    data.playerId = apply.playerId
    data.playerName = apply.playerName
    data.playerHead = apply.playerHead
    data.playerScore = apply.playerScore
    data.applyTime = apply.applyTime
    data.answer = apply.answer
    data.unionId = apply.unionId
    data.unionName = ""
    return data
end

function UnionBag:packUnionBrief(unionData)
    local data = {}
    data.unionId = unionData.unionId
    data.unionName = unionData.unionName
    data.unionFlag = unionData.unionFlag
    data.unionNotice = unionData.unionNotice
    data.unionSharing = unionData.unionSharing
    data.enterType = unionData.enterType
    data.enterScore = unionData.enterScore
    data.memberMax = unionData.memberMax
    data.memberCount = #unionData.members
    data.starCoin = unionData.starCoin
    data.ice = unionData.ice
    data.titanium = unionData.titanium
    data.gas = unionData.gas
    data.carboxyl = unionData.carboxyl
    data.editArmyPid = unionData.editArmyPid
    data.editArmyTick = self:calcLessTick(self.editArmyTick)
    data.starCoinLimitAdd = self.starCoinLimitAdd
    data.gasLimitAdd = self.gasLimitAdd
    data.iceLimitAdd = self.iceLimitAdd
    data.titaniumLimitAdd = self.titaniumLimitAdd
    data.carboxylLimitAdd = self.carboxylLimitAdd
    data.nftDefenseNum = self:getUnionNftDefenseNum(unionData)
    data.nftHeroNum = self:getUnionNftHeroNum(unionData)
    data.normalDefenseNum = self:getUnionNormalDefenseNum(unionData)
    data.normalHeroNum = self:getUnionNormalHeroNum(unionData)
    data.fightPower = unionData.fightPower
    return data
end

function UnionBag:checkJoinUnionCD()
    local leaveUnionTick = self.leaveUnionTick or 0
    local rejoinUnionCD = gg.getGlobalCfgIntValue("RejoinUnionCD",300)
    local nowTick = math.floor(skynet.timestamp() / 1000)
    if (leaveUnionTick + rejoinUnionCD) > nowTick then
        return false
    end
    return true
end

function UnionBag:setLeaveUnionTick()
    self.leaveUnionTick = math.floor(skynet.timestamp() / 1000)
end

function UnionBag:packInvites()
    local invites = {}
    for k, v in pairs(self.invites) do
        local unionBase = gg.unionProxy:call("getUnionBase", v.unionId)
        if unionBase then
            local invite = {}
            invite.union = unionBase
            invite.invitePlayer = v.invitePlayer
            invite.answer = v.answer
            table.insert(invites, invite)
        end
    end
    return invites
end

function UnionBag:getMyUnionInfo()
    return gg.unionProxy:getUnionInfo(self.unionId)
end

function UnionBag:getMyUnionId()
    if not self.lastGetUnionIdTick then
        local baseInfo = gg.unionProxy:call("getUnionBaseInfoByPid", self.player.pid)
        if baseInfo then
            self.unionId = baseInfo.unionId
            self.beginGridId = baseInfo.beginGridId
            self.unionLevel = baseInfo.unionLevel
        end
        self.lastGetUnionIdTick = skynet.timestamp()
    end
    return self.unionId
end

function UnionBag:getMyUnionName()
    local myUnionInfo = self:getMyUnionInfo()
    if not myUnionInfo then
        return nil
    end
    return myUnionInfo.unionName
end

function UnionBag:getMyUnionFlag()
    local myUnionInfo = self:getMyUnionInfo()
    if not myUnionInfo then
        return nil
    end
    return myUnionInfo.unionFlag
end

function UnionBag:getMyUnionPresidentName()
    local myUnionInfo = self:getMyUnionInfo()
    if not myUnionInfo then
        return nil
    end
    return myUnionInfo.presidentName
end

function UnionBag:getMyUnionChainId()
    local myUnionInfo = self:getMyUnionInfo()
    if not myUnionInfo then
        return nil
    end
    return myUnionInfo.unionChain
end

function UnionBag:getMyUnionJob()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        return 0
    end
    return gg.unionProxy:call("getUnionJob", myUnionId, self.player.pid)
end

function UnionBag:queryJoinableUnionList()
    local result = gg.unionProxy:call("getJoinableUnionList")
    gg.client:send(self.player.linkobj, "S2C_Player_JoinableUnionList", { unions = result } )
end

function UnionBag:getUnionMatchRank(matchType, unionChain)
    if matchType < constant.MATCH_TYPE_WEEK or matchType > constant.MATCH_TYPE_SEASON then
        self.player:say(util.i18nFormat(errors.GRID_MATCH_RANK_ERROR))
        return
    end
    local chainIndex = gg.getChainIndexById(unionChain)
    -- if not chainIndex then
    --     self.player:say(util.i18nFormat(errors.BRIDGE_CHAIN_ID_NOT_EXIST))
    --     return
    -- end
    local myUnionId = self:getMyUnionId()
    local rankInfos = gg.matchProxy:getCurrentMatchRank(constant.MATCH_BELONG_UNION, matchType, myUnionId)
    local info = rankInfos[1]
    if not info then
        -- self.player:say(util.i18nFormat(errors.GRID_MATCH_RANK_EMPTY))
        gg.client:send(self.player.linkobj, "S2C_Player_StarmapRankList", {chainId = unionChain} )
        return
    end
    local shareRatio = gg.shareProxy:call("getOpCfg", constant.REDIS_STARMAP_JACKPOT_SHARE_RATIO) or 0
    local send = {
        rankType = matchType,
        version = info.version,
        rankList = info.rankMembers,
        selfRank = info.selfRank,
        matchCfgId = info.cfgId,
        chainId = unionChain,
        shareRatio = shareRatio * 100,
    }
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapRankList", send )
end

function UnionBag:getStarmapScore()
    local score = 0
    local myUnionId = self.player.unionBag:getMyUnionId()
    if myUnionId then
        score = gg.starmapProxy:call("getGridScore", self.player.pid, myUnionId)
    end
    gg.client:send(self.player.linkobj,"S2C_Player_StarmapScore",{
        starScore = score,
    })
end

function UnionBag:queryStarmapHyJackpot()
    local jackpot = gg.shareProxy:call("getOpCfg", constant.REDIS_STARMAP_JACKPOT_INFO)
    local carboxyl = jackpot.sysCarboxyl + jackpot.plyCarboxyl
    gg.client:send(self.player.linkobj,"S2C_Player_StarmapHyJackpot",{
        jackpot = carboxyl,
    })
end
-------------------------------------------------------------------
--mint
-------------------------------------------------------------------
function UnionBag:_sendMintsUpdate(op, list)
    gg.client:send(self.player.linkobj,"S2C_Player_MintsUpdate",{
        op_type = op,
        list = list,
    })
end

function UnionBag:getMints()
    self:_sendMintsUpdate(0, self.mints)
end

function UnionBag:_findMintNft(nftId)
    for i, v in ipairs(self.mints) do
        if v.nftId1 == nftId or v.nftId1 == nftId then
            return v
        end
    end
end

function UnionBag:_getMintNft(nftId1, nftId2, nftType)
    local NFT_TYPE_BAG = {
        [constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP] = {"warShipBag", "getWarShip", "warShip"},
        [constant.CHAIN_BRIDGE_NFT_KIND_HERO] = {"heroBag", "getHero", "hero"},
        [constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE] = {"buildBag", "getBuild", "build"},
    }
    local ret = {}
    local getParam = NFT_TYPE_BAG[nftType]
    if not getParam then
        return ret
    end
    local bag = getParam[1]
    local getFun = getParam[2]
    local key = getParam[3]
    local obj1 = self.player[bag][getFun](self.player[bag], nftId1)
    local obj2 = self.player[bag][getFun](self.player[bag], nftId2)
    if obj1 and obj2 then
        ret[key.."1"] = obj1
        ret[key.."2"] = obj2
    end
    return ret
end

function UnionBag:_getObjMintCfg(nfts, checkRef)
    local NFT_KEYS_ERROR = {
        ["warShip1"] = errors.WARSHIP_REF_BUSY,
        ["warShip2"] = errors.WARSHIP_REF_BUSY,
        ["hero1"] = errors.HERO_REF_BUSY,
        ["hero2"] = errors.HERO_REF_BUSY,
        ["build1"] = errors.BUILD_REF_BUSY,
        ["build2"] = errors.BUILD_REF_BUSY,
    }
    local mintLimt = gg.getGlobalCfgIntValue("NFTMintMaxTime", 9)
    local maxMintCount = -1
    local maxObj
    local maxKey
    for key, obj in pairs(nfts) do
        if obj:isUpgrade() then
            self.player:say(util.i18nFormat(NFT_KEYS_ERROR[key]))
            return
        end
        if checkRef and not (constant.IsRefNone(obj) or constant.IsRefBattle(obj)) then
            self.player:say(util.i18nFormat(NFT_KEYS_ERROR[key]))
            return
        end
        if (obj.mintCount + 1) > mintLimt then
            self.player:say(util.i18nFormat(errors.UNION_MINT_COUNT_LIMIT))
            return
        end
        if obj.mintCount > maxMintCount then
            maxMintCount = obj.mintCount
            maxObj = obj
            maxKey = key
        end
    end
    local NFT_KEYS_CFG = {
        ["warShip1"] = "warShipNftConfig",
        ["warShip2"] = "warShipNftConfig",
        ["hero1"] = "heroNftConfig",
        ["hero2"] = "heroNftConfig",
        ["build1"] = "buildNftConfig",
        ["build2"] = "buildNftConfig",
    }
    local cfgName = NFT_KEYS_CFG[maxKey]
    local cfg = gg.getExcelCfgByFormat(cfgName, maxObj.race, maxObj.style, maxObj.quality, maxObj.level)
    if not cfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    return {mintCfgId = cfg.mintCfgId, maxMintCount = maxMintCount}
end

function UnionBag:_getMintCostCfg(mintCfgId, maxMintCount)
    local cfg
    local mintCost = gg.getExcelCfg("mintCost")
    for k, v in pairs(mintCost) do
        if v.cfgId == mintCfgId and v.mintTime == maxMintCount then
            cfg = v
            break
        end
    end
    return cfg
end

function UnionBag:addMint(nftId1, nftId2, nftType)
    if constant.UNION_DISABLE_FUNC["addMint"] then
        return
    end
    if nftId1 == nftId2 then
        self.player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    local myUnionId = self.player.unionBag:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local NFT_TYPE_CFG = {
        [constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP] = true,
        [constant.CHAIN_BRIDGE_NFT_KIND_HERO] = true,
        [constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE] = true,
    }
    if not NFT_TYPE_CFG[nftType] then
        self.player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    local score = gg.starmapProxy:call("getGridScore", self.player.pid, myUnionId)
    local unlockScore = gg.getGlobalCfgIntValue("NFTMintUnlockLeaguePoint", 0)
    if score < unlockScore then
        self.player:say(util.i18nFormat(errors.UNION_MINT_SCORE_NOT_ENOUGH))
        return
    end
    if self:_findMintNft(nftId1) or self:_findMintNft(nftId2) then
        self.player:say(util.i18nFormat(errors.UNION_MINT_REPEAT))
        return
    end
    local nfts = self:_getMintNft(nftId1, nftId2, nftType)
    if table.count(nfts) < 2 then
        self.player:say(util.i18nFormat(errors.NFT_NOT_EXIST))
        return
    end
    for key, obj in pairs(nfts) do
        if obj.chain <= 0 or obj.chain == constant.BUILD_CHAIN_TOWER then
            self.player:say(util.i18nFormat(errors.BRIDGE_NOT_NFT))
            return
        end
        if obj.level < constant.UNION_NFT_MINT_MIN_LEVEL then
            self.player:say(util.i18nFormat(errors.NFT_LEVEL_NOT_ENOUGH))
            return
        end
    end
    local costCfg = self:_getObjMintCfg(nfts, true)
    if not costCfg then
        return
    end
    local cfg = self:_getMintCostCfg(costCfg.mintCfgId, costCfg.maxMintCount)
    if not cfg then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    --""
    local resDict = {
        [constant.RES_TESSERACT] = cfg.tesseractCost or 0,
        [constant.RES_MIT] = cfg.mitCost or 0,
    }
    local source = {logType = gamelog.UNION_NFT_MINT}
    if not self.player.resBag:enoughResDict(resDict) then
        return
    end
    self.player.resBag:costResDict(resDict, source)
    local newMint = {
        nftId1 = nftId1,
        nftId2 = nftId2,
        status = 0,
        startTime = gg.time.time(),
        mintCfgId = cfg.cfgId,
        nftType = nftType,
    }
    table.insert(self.mints, newMint)
    self:_sendMintsUpdate(constant.OP_ADD, {newMint})
    for k, v in pairs(nfts) do
        constant.setRef(v, constant.REF_MINT)
    end
end

function UnionBag:_updateMintNfts(nfts)
    local NFT_KEYS_UPDATE = {
        ["warShip1"] = {"S2C_Player_WarShipUpdate", "warShip"},
        ["warShip2"] = {"S2C_Player_WarShipUpdate", "warShip"},
        ["hero1"] = {"S2C_Player_HeroUpdate", "hero"},
        ["hero2"] = {"S2C_Player_HeroUpdate", "hero"},
        ["build1"] = {"S2C_Player_BuildUpdate", "build"},
        ["build2"] = {"S2C_Player_BuildUpdate", "build"},
    }
    for key, obj in pairs(nfts) do
        local update_proto = NFT_KEYS_UPDATE[key][1]
        local update_key = NFT_KEYS_UPDATE[key][2]
        gg.client:send(self.player.linkobj, update_proto ,{ [update_key] = obj:pack()})
    end
end

function UnionBag:receiveMintItem(index)
    if constant.UNION_DISABLE_FUNC["receiveMintItem"] then
        return
    end
    local mint = self.mints[index]
    if not mint then
        self.player:say(util.i18nFormat(errors.UNION_MINT_NOT_EXIST))
        return
    end
    if mint.status ~= 1 then
        self.player:say(util.i18nFormat(errors.UNION_MINT_NOT_DONE))
        return
    end
    local nfts = self:_getMintNft(mint.nftId1, mint.nftId2, mint.nftType)
    local costCfg = self:_getObjMintCfg(nfts)
    local cfg = self:_getMintCostCfg(costCfg.mintCfgId, costCfg.maxMintCount)
    if not cfg or not cfg.itemCfgId then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    for key, obj in pairs(nfts) do
        obj.mintCount = obj.mintCount + 1
    end
    local countCfg = table.chooseByValue(cfg.countWeight, function(v)
        return v[2]
    end)
    local count = countCfg[1]
    local addNum = self.player.itemBag:addItem(cfg.itemCfgId, count, {logType = gamelog.MINT_RECEIVE_ITEM})
    if addNum < count then
        logger.logf("error","UnionMint","op=receiveMintItem pid=%d itemCfgId=%s nftId1=%s nftId2=%s mintCfgId=%s maxMintCount=%s", self.player.pid, tostring(cfg.itemCfgId), tostring(mint.nftId1), tostring(mint.nftId2), tostring(costCfg.mintCfgId), tostring(costCfg.maxMintCount))
    end
    table.remove(self.mints, index)
    self:_sendMintsUpdate(constant.OP_DEL, {mint})
    for k, v in pairs(nfts) do
        constant.cancelRef(v, constant.REF_MINT)
    end
    self:_updateMintNfts(nfts)
    self:_completeMintsAutoPush()
end

function UnionBag:_handleCompleteMints()
    local newMints = {}
    local delMints = {}
    local mailItems = {}
    for i, mint in ipairs(self.mints) do
        if mint.status == 1 then
            local nfts = self:_getMintNft(mint.nftId1, mint.nftId2, mint.nftType)
            local costCfg = self:_getObjMintCfg(nfts)
            local cfg = self:_getMintCostCfg(costCfg.mintCfgId, costCfg.maxMintCount)
            if not cfg or not cfg.itemCfgId then
                logger.logf("error","UnionMint","op=_handleCompleteMints cfg not exist itemCfgId=%s nftId1=%s nftId2=%s mintCfgId=%s maxMintCount=%s", tostring(cfg.itemCfgId), tostring(mint.nftId1), tostring(mint.nftId2), tostring(costCfg.mintCfgId), tostring(costCfg.maxMintCount))
            else
                for key, obj in pairs(nfts) do
                    obj.mintCount = obj.mintCount + 1
                    constant.cancelRef(obj, constant.REF_MINT)
                end
                self:_updateMintNfts(nfts)
                local countCfg = table.chooseByValue(cfg.countWeight, function(v)
                    return v[2]
                end)
                table.insert(mailItems, {
                    cfgId = cfg.itemCfgId,
                    count = countCfg[1],
                    type = constant.MAIL_ATTACH_ITEM,
                })
                table.insert(delMints, mint)
            end
        else
            table.insert(newMints, mint)
        end
    end
    self:_sendMintsUpdate(constant.OP_DEL, delMints)
    self.mints = newMints
    if table.count(mailItems) > 0 then
        local mailTemplate = gg.getExcelCfg("mailTemplate")
        local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_COMPLETE_MINTS]
        self.player.mailBag:localAddMyMail({
            sendPid = 0,
            sendName = mailCfg.sendName,
            title = mailCfg.mailTitle,
            content = mailCfg.mailContent,
            attachment = mailItems,
            logType = gamelog.UNION_NFT_MINT
        }, true)
    end
end

function UnionBag:_handleIncompleteMints()
    local resDict = {
        [constant.RES_TESSERACT] = 0,
        [constant.RES_MIT] = 0,
    }
    for i, mint in ipairs(self.mints) do
        local nfts = self:_getMintNft(mint.nftId1, mint.nftId2, mint.nftType)
        local costCfg = self:_getObjMintCfg(nfts)
        local cfg = self:_getMintCostCfg(costCfg.mintCfgId, costCfg.maxMintCount)
        if not cfg or not cfg.itemCfgId then
            logger.logf("error","UnionMint","op=_handleIncompleteMints cfg not exist itemCfgId=%s nftId1=%s nftId2=%s mintCfgId=%s maxMintCount=%s", tostring(cfg.itemCfgId), tostring(mint.nftId1), tostring(mint.nftId2), tostring(costCfg.mintCfgId), tostring(costCfg.maxMintCount))
        else
            if mint.status ~= 1 then
                resDict[constant.RES_TESSERACT] = resDict[constant.RES_TESSERACT] + (cfg.tesseractCost or 0)
                resDict[constant.RES_MIT] = resDict[constant.RES_MIT] + (cfg.mitCost or 0)
            else
                logger.logf("error","UnionMint","op=_handleIncompleteMints mint status==1 itemCfgId=%s nftId1=%s nftId2=%s mintCfgId=%s maxMintCount=%s", tostring(cfg.itemCfgId), tostring(mint.nftId1), tostring(mint.nftId2), tostring(costCfg.mintCfgId), tostring(costCfg.maxMintCount))
            end
        end
        for key, obj in pairs(nfts) do
            constant.cancelRef(obj, constant.REF_MINT)
        end
        self:_updateMintNfts(nfts)
    end
    local mailRes = {}
    local sendMail = false
    for k, v in pairs(resDict) do
        if v > 0 then
            table.insert(mailRes, {
                cfgId = k,
                count = v,
                type = constant.MAIL_ATTACH_RES,
            })
            sendMail = true
        end
    end
    if sendMail then
        local mailTemplate = gg.getExcelCfg("mailTemplate")
        local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_INCOMPLETE_MINTS]
        self.player.mailBag:localAddMyMail({
            sendPid = 0,
            sendName = mailCfg.sendName,
            title = mailCfg.mailTitle,
            content = mailCfg.mailContent,
            attachment = mailRes,
            logType = gamelog.UNION_NFT_MINT
        }, true)
    end
    self:_sendMintsUpdate(constant.OP_DEL, self.mints)
    self.mints = {}
end

function UnionBag:quitUnionHandleMints()
    self:_handleCompleteMints()
    self:_handleIncompleteMints()
end

function UnionBag:_checkCompleteMints()
    local mintTime = gg.getGlobalCfgIntValue("NFTMintNeedTime", 1)
    local now = gg.time.time()
    local update = {}
    for i, v in ipairs(self.mints) do
        if v.status == 0 then
            if (v.startTime + mintTime) <= now then
                v.status = 1
                table.insert(update, v)
            end
        end
    end
    if table.count(update) > 0 then
        self:_sendMintsUpdate(constant.OP_MODIFY, update)
        self:_completeMintsAutoPush()
    end
end

function UnionBag:_completeMintsAutoPush()
    local mintTime = gg.getGlobalCfgIntValue("NFTMintNeedTime", 1)
    local now = gg.time.time()
    local needPush = false
    for i, v in ipairs(self.mints) do
        if v.status == 1 then
            needPush = true
            break
        end
    end
    if needPush then
        self.player.autoPushBag:setAutoPushStatus(constant.AUTOPUSH_CFGID_MINT_NEW)
    else
        self.player.autoPushBag:delAutoPushStatus(constant.AUTOPUSH_CFGID_MINT_NEW)
    end
end

function UnionBag:donateDaoItem(id, count)
    local myUnionId = self.player.unionBag:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local item = self.player.itemBag:getItem(id)
    if not item then
        self.player:say(util.i18nFormat(errors.ITEM_NOT_EXIST))
        return
    end
    if item.num < count then
        self.player:say(util.i18nFormat(errors.ITEM_NOT_ENOUGH))
        return
    end
    local itemCfg = gg.getExcelCfg("item")
    local cfg = itemCfg[item.cfgId]
    if cfg.itemType ~= constant.ITEM_ARTIFACT then
        self.player:say(util.i18nFormat(errors.ITEM_NOT_DAO))
        return
    end

    local exp = 0
    local contriDegree = 0
    local itemEffectCfg = gg.getExcelCfg("itemEffect")
    for i, v in ipairs(cfg.effect or {}) do
        local effectCfg = itemEffectCfg[v]
        if effectCfg then
            if effectCfg.effectType == constant.ITEM_EFFECT_UNION_EXP then
                exp = effectCfg.value[1] * count
            elseif effectCfg.effectType == constant.ITEM_EFFECT_UNION_CONTRI then
                contriDegree = effectCfg.value[1] * count
            end
        end
    end
    if exp == 0 or contriDegree == 0 then
        self.player:say(util.i18nFormat(errors.ITEM_DAO_EFFECT_ERR))
        return
    end
    local ret = gg.unionProxy:call("donateDaoItem", self.player.pid, myUnionId, contriDegree, exp)
    if not ret then
        return
    end
    self.player.itemBag:costItemNum(item, count, {logType = gamelog.DONATE_DAO_ITEM})
    gg.client:send(self.player.linkobj, "S2C_Player_DonateDaoItem", {
        exp = ret.exp,
        unionLevel = ret.unionLevel,
        contriDegree = ret.contriDegree,
    } )
end

-------------------------------------------------------------------
function UnionBag:setBeginGridId(beginGridId)
    self.beginGridId = beginGridId
end
-------------------------------------------------------------------
--""
function UnionBag:onUnionJoinSucc(unionBase)
    if self.player.pid == unionBase.presidentPid then--create
        local createCost = gg.getGlobalCfgIntValue("CreateDAONeedTesseract", 0)
        if createCost > 0 then
            self.player.resBag:costRes(constant.RES_TESSERACT, createCost, {logType = gamelog.CREATE_UNION})
        end
    end
    self.unionId = unionBase.unionId
    gg.client:send(self.player.linkobj, "S2C_Player_MyUnionInfo", { union = unionBase })
    gg.client:send(self.player.linkobj, "S2C_Player_UnionJob", { unionJob = self:getMyUnionJob() } )
    self.player.taskBag:update(constant.TASK_JION_GUILD, {})
    self.invites = {}
    self.player.autoPushBag:delAutoPushStatus(constant.AUTOPUSH_CFGID_UNION_NEW_INVITE)

    gg.chatProxy:sendSysMsg({
        channelType = constant.CHAT_CHANNEL_UNION,
        text = "Welcome "..self.player.name.." joined the DAO",
        unionId = unionBase.unionId,
        unionName = unionBase.unionName,
    })
end

--""
function UnionBag:onUnionQuitSucc(unionId)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionMemberDel", { unionId = unionId, playerId = self.player.pid } )
    --""unionId
    self:quitUnionHandleMints()
    self.unionId = nil
    self:setLeaveUnionTick()
end

--""
function UnionBag:onUnionTickedSucc(unionId)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionMemberDel", { unionId = unionId, playerId = self.player.pid } )
    --""unionId
    self:quitUnionHandleMints()
    self.unionId = nil
    -- self:setLeaveUnionTick()
end

--""
function UnionBag:onInvitedJoinUnion(unionId, inviteInfo)
    inviteInfo.unionId = unionId
    self.invites[unionId] = inviteInfo
    --""
    self.player.autoPushBag:setAutoPushStatus(constant.AUTOPUSH_CFGID_UNION_NEW_INVITE)
end

--""
function UnionBag:onClearAllApplyFinish()
    self:getUnionApplyList()
end

--""
function UnionBag:onUnionNewApply()
    self.player.autoPushBag:setAutoPushStatus(constant.AUTOPUSH_CFGID_UNION_NEW_APPLY)
end

--""
function UnionBag:onUnionDonate(unionId, realDonateInfo)
    --""
    local resDict = {
        [constant.RES_STARCOIN] = realDonateInfo.starCoin,
        [constant.RES_ICE] = realDonateInfo.ice,
        [constant.RES_CARBOXYL] = realDonateInfo.carboxyl,
        [constant.RES_TITANIUM] = realDonateInfo.titanium,
        [constant.RES_GAS] = realDonateInfo.gas,
    }
    if not self.player.resBag:enoughResDict(resDict) then
        return false
    end
    self.player.resBag:costResDict(resDict, {logType=gamelog.UNION_DONATE})
    return true
end

--""
function UnionBag:onUnionDonateFinish()
    self:queryUnionRes()
end

--""NFT
function UnionBag:onUnionDonateNft(unionId, realDonateInfo)
    local donateTime = math.floor(skynet.timestamp() / 1000)
    for i, nftGO in ipairs(realDonateInfo) do
        local warShip = self.player.warShipBag:getWarShip(nftGO.id)
        if warShip then
            warShip.ref = constant.REF_UNION
            warShip.donateTime = donateTime
            warShip.ownerPid = self.player.pid
            gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
        end
        local hero = self.player.heroBag:getHero(nftGO.id)
        if hero then
            hero.ref = constant.REF_UNION
            hero.donateTime = donateTime
            hero.ownerPid = self.player.pid
            gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
        end
        local build = self.player.buildBag:getBuild(nftGO.id)
        if build then
            build.ref = constant.REF_UNION
            build.donateTime = donateTime
            build.ownerPid = self.player.pid
            gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
        end
    end
    return donateTime
end

--""NFT""
function UnionBag:onUnionDonateNftFinish()
    self:queryUnionNfts()
end

function UnionBag:getPlayerBrief()
    local brief = {}
    brief.playerId = self.player.pid
    brief.playerName = self.player.name
    brief.playerHead = self.player.headIcon
    brief.playerLevel = self.player.buildBag:getBaseBuildLevel()
    brief.playerScore = self.player.pvpBag:getPlayerRankScore()
    brief.unionId = self.player.unionBag:getMyUnionId()
    brief.unionName = self.player.unionBag:getMyUnionName()
    brief.donateTime = math.floor(skynet.timestamp() / 1000)
    return brief
end

--""NFT
function UnionBag:onUnionTakeBackNft(unionId, idList, nftLifeDict)
    self.player.warShipBag:returnFromUnion(idList, nftLifeDict)
    self.player.heroBag:returnFromUnion(idList, nftLifeDict)
    self.player.buildBag:returnFromUnion(idList, nftLifeDict)
    return true
end

--""NFT""
function UnionBag:onUnionTakeBackNftFinish()
    self:queryUnionNfts()
end

--- ""
---@param unionInfo any
---@param updatePid any
function UnionBag:broadCastUnionArmyEditStart(unionInfo, updatePid)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionStartEditArmy", {
        editArmyPid = unionInfo.editArmyPid,
        editArmyTick = unionInfo.editArmyTick,
    })
end

-------------------------------------------------------

--""
function UnionBag:visitFoundation(playerId)
    local info = gg.playerProxy:call(playerId, "visitFoundationInfo")
    if not info then
        self.player:say(util.i18nFormat(errors.NOT_ALLOW_VISIT))
        return
    end
    gg.client:send(self.player.linkobj, "S2C_Player_UnionVisitFoundation", {info = info})
end

------------------------------------------------------------------
function UnionBag:queryUnionBaseInfo(unionId)
    local unionBase = gg.unionProxy:call("getUnionBase", unionId)
    if not unionBase then
        self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    gg.client:send(self.player.linkobj, "S2C_Player_UnionBaseInfo", { union = unionBase } )
end

function UnionBag:queryMyUnionInfo()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local unionBase = gg.unionProxy:call("getUnionBase", myUnionId)
    if not unionBase then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    gg.client:send(self.player.linkobj, "S2C_Player_MyUnionInfo", { union = unionBase } )
end

--"",""
function UnionBag:searchUnion(keyWord)
    local unions = gg.unionProxy:searchUnionNameOrUnionIdLike(keyWord)
    gg.client:send(self.player.linkobj, "S2C_Player_SearchUnionResult", {unions = unions} )
end

--""
function UnionBag:queryUnionStarmapCampaignReports(pageNo, pageSize)
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    pageSize = math.max(pageSize, 5)
    local campaignIdList = gg.unionProxy:call("getUnionCampaignIdList", myUnionId, pageNo, pageSize)
    local reports = self.player.starmapBag:getUnionStarmapCampaignReports(myUnionId, campaignIdList)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionStarmapCampaignReports", { reports = reports})
end

--""
function UnionBag:queryUnionStarmapBattleReports(campaignId, pageNo, pageSize)
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    pageSize = math.max(pageSize, 5)
    local reports = self.player.starmapBag:getUnionStarmapBattleReports(myUnionId, campaignId, pageNo, pageSize)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionStarmapBattleReports", { reports = reports })
end

--""
function UnionBag:queryStarmapCampaignPlyStatistics(campaignId)
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local reports = self.player.starmapBag:getStarmapCampaignPlyStatistics(myUnionId, campaignId)
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapCampaignPlyStatistics", { campaignId = campaignId, reports = reports })
end

function UnionBag:createUnionMemberInfo(unionJob)
    local baseLevel = gg.shareProxy:call("getPlayerBaseInfo", self.player.pid, "level", 1)
    local info = {
        playerId = self.player.pid,
        playerName = self.player.name,
        playerHead = self.player.playerInfoBag.headIcon,
        baseLevel = baseLevel,
        playerScore = self.player.pvpBag:getPlayerRankScore(),
        matchScore = 0,
        unionJob = unionJob,
        starCoin = 0,
        ice = 0,
        titanium = 0,
        gas = 0,
        carboxyl = 0,
        fightPower = 0,
        chain = self.player.playerInfoBag:getChainId(),
    }
    return info
end

--""dao""
function UnionBag:createUnion(data)
    local createCost = gg.getGlobalCfgIntValue("CreateDAONeedTesseract", 0)
    if not self.player.resBag:enoughRes(constant.RES_TESSERACT, createCost) then
        self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
        return
    end
    --""
    -- local chain = self.player.playerInfoBag:getChainId()
    -- if not chain or chain <= 0 then
    --     self.player:say(util.i18nFormat(errors.BRIDGE_NO_BIND_WALLET))
    --     return
    -- end
    if not data.unionName then
        self.player:say(util.i18nFormat(errors.UNION_NAME_ERR))
        return
    end
    if not data.unionNotice then
        self.player:say(util.i18nFormat(errors.UNION_INVALID_NOTICE))
        return
    end
    if not data.enterScore or data.enterScore < 0 then
        self.player:say(util.i18nFormat(errors.UNION_ENTER_SCORE_ERR))
        return
    end
    if not data.unionFlag or data.unionFlag < 0 then
        self.player:say(util.i18nFormat(errors.UNION_INVALID_FLAG))
        return
    end
    if not data.unionSharing or data.unionSharing < 0 or data.unionSharing > 100 then
        self.player:say(util.i18nFormat(errors.UNION_INVALID_SHARING))
        return
    end
    if data.enterType < constant.UNION_JOIN_TYPE_UNLIMIT or data.enterType > constant.UNION_JOIN_TYPE_NOT_ALLOW then
        self.player:say(util.i18nFormat(errors.UNION_INVALID_ENTERTYPE))
        return
    end
    local ret = gg.nameFilter:isValidText(data.unionName, 3, 16)
    if ret ~= ggclass.WordFilter.CODE_OK then
        self.player:say(util.i18nFormat(errors.UNION_NAME_ERR))
        return
    end
    --"",""
    local myUnionId = self:getMyUnionId()
    if myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_REPEAT_JOIN))
        return
    end
    --""
    if not self:checkJoinUnionCD() then
        self.player:say(util.i18nFormat(errors.UNION_REJOIN_CD))
        return
    end

    data.player = self:createUnionMemberInfo(constant.UNION_JOB_PRESIDENT)
    gg.unionProxy:send("createUnion", self.player.pid, data)
end

--""dao""
function UnionBag:joinUnion(unionId)
    --""
    if not self:checkJoinUnionCD() then
        self.player:say(util.i18nFormat(errors.UNION_REJOIN_CD))
        return
    end
    local data = self:createUnionMemberInfo(constant.UNION_JOB_MEMBER)
    gg.unionProxy:send("joinUnion", self.player.pid, unionId, data)
end

--""
function UnionBag:joinUnionAnswer(unionId, answerPid, answer)
    gg.unionProxy:send("joinUnionAnswer", self.player.pid, unionId, answerPid, answer)
end

--""
function UnionBag:unionClearAllApply()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    gg.unionProxy:send("unionClearAllApply", self.player.pid, myUnionId)
end

--""
function UnionBag:onJoinUnionAnswerFinish()
    self:getUnionApplyList()
end

--""
function UnionBag:getUnionApplyList(unionId)
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local applys, applyVersion = gg.unionProxy:call("getUnionApplyList", myUnionId)
    if not applys then
        self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    self.applyVersion = applyVersion
    self.player.autoPushBag:delAutoPushStatus(constant.AUTOPUSH_CFGID_UNION_NEW_APPLY)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionApplyList", { applys = applys })
end

--""
function UnionBag:getInviteList()
    self.player.autoPushBag:delAutoPushStatus(constant.AUTOPUSH_CFGID_UNION_NEW_INVITE)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionInviteList", { invites = self:packInvites() })
end

--""
function UnionBag:inviteJoinUnion(unionId, invitedPid)
    gg.unionProxy:send("inviteJoinUnion", self.player.pid, unionId, invitedPid)
end

--""
function UnionBag:answerUnionInvite(unionId, answer)
    local invite = self.invites[unionId]
    if not invite then
        self.player:say(util.i18nFormat(errors.UNION_INVITE_INVALID))
        return
    end
    local memberInfo = self:createUnionMemberInfo(constant.UNION_JOB_MEMBER)
    gg.unionProxy:send("answerUnionInvite", self.player.pid, unionId, answer, memberInfo)
    self.invites[unionId] = nil
    self:getInviteList()
end

--""
function UnionBag:modifyUnionInfo(unionId, data)
    gg.unionProxy:send("modifyUnionInfo", self.player.pid, unionId, data)
end

--""
function UnionBag:onModifyUnionInfoFinish()
    self:queryMyUnionInfo()
end

--""
function UnionBag:quitUnion(unionId)
    gg.unionProxy:send("quitUnion", self.player.pid, unionId)
end

--""
function UnionBag:tickOutUnion(unionId, tickedPid)
    if self.tickedPid == self.player.pid then
        self.player:say(util.i18nFormat(errors.UNION_KICK_SELF))
        return
    end
    gg.unionProxy:send("tickOutUnion", self.player.pid, unionId, tickedPid)
end

--""
function UnionBag:onTickOutUnionFinish(unionId, tickedPid)
    self:queryUnionMembers()
end

--""
function UnionBag:editUnionJob(unionId, editedPid, unionJob, editType)
    gg.unionProxy:send("editUnionJob", self.player.pid, unionId, editedPid, unionJob, editType)
end

--""
function UnionBag:onUnionJobChange(unionJob)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionJob", { unionJob = unionJob } )
end

--""
function UnionBag:onUnionEditJobFinish(editType, editJob, editedPlayerName)
    self:queryUnionMembers()
    --"" xxx（""） become xxx（""）
    if editType == constant.UNION_JOB_OP_TRANSFER or editType == constant.UNION_JOB_OP_APPOINTED then
        gg.chatProxy:sendSysMsg({
            channelType = constant.CHAT_CHANNEL_UNION,
            text = editedPlayerName.." become "..constant.UNION_JOB_NAME[editJob],
            unionId = self:getMyUnionId(),
            unionName = self:getMyUnionName(),
        })
    end
end

--""
function UnionBag:donate(unionId, donateInfo)
    if constant.UNION_DISABLE_FUNC["donate"] then
        return
    end
    local resDict = {
        [constant.RES_STARCOIN] = donateInfo.starCoin,
        [constant.RES_ICE] = donateInfo.ice,
        [constant.RES_CARBOXYL] = donateInfo.carboxyl,
        [constant.RES_TITANIUM] = donateInfo.titanium,
        [constant.RES_GAS] = donateInfo.gas,
    }
    if not self.player.resBag:enoughResDict(resDict) then
        return false
    end
    gg.unionProxy:send("donate", self.player.pid, unionId, donateInfo)
    self.player.taskBag:update(constant.TASK_DONATE_IN_GUILD, { count = 1 })
end

function UnionBag:_getNftList(idList)
    local nftList = {}
    for i, id in ipairs(idList) do
        local warShip = self.player.warShipBag:getWarShip(id)
        if warShip then
            local cpyData = warShip:packToDonate()
            cpyData.itemType = constant.ITEM_WAR_SHIP
            table.insert(nftList, cpyData)
        end
        local hero = self.player.heroBag:getHero(id)
        if hero then
            local cpyData = hero:packToDonate()
            cpyData.itemType = constant.ITEM_HERO
            table.insert(nftList, cpyData)
        end
        local build = self.player.buildBag:getBuild(id)
        if build then
            local cpyData = build:packToDonate()
            cpyData.itemType = constant.ITEM_BUILD
            table.insert(nftList, cpyData)
        end
        --------------------
        -- local item = self.player.itemBag:getItem(id)
        -- if item then
        --     table.insert(nftList, item:serialize())
        -- end
    end
    return nftList
end

--""NFT
function UnionBag:donateNft(unionId, idList)
    local nftList = self:_getNftList(idList)
    if table.count(nftList) ~= table.count(idList) then
        self.player:say(util.i18nFormat(errors.NFT_NOT_EXIST))
        return
    end
    if not self:canDonateNft(nftList) then
        self.player:say(util.i18nFormat(errors.NFT_NOT_AVAILABLE))
        return
    end
    gg.unionProxy:send("donateNft", self.player.pid, unionId, nftList)
end

function UnionBag:canDonateNft(nftList)
    local inArmyHeros =  self.player.armyBag:getInArmyFormationHeros()
    local warShip = self.player.warShipBag:getCurrentWarShip()
    
    for i, v in ipairs(nftList) do
        if v.isUpgrade then
            return false
        end
        if not constant.IsRefNone(v) then
            return false
        end
        if v.itemType ~= constant.ITEM_BUILD then
            if not gg.isInnerServer() then
                return false
            end
        end
        if v.fightTick > 0 then
            return false
        end
        if v.chain <= 0 then
            return false
        end
        if v.curLife <= 0 then
            return false
        end
        if inArmyHeros[v.id] == 1 then
            return false
        end
        if v.id  == warShip.id then
            return false
        end
    end
    return true
end

function UnionBag:gmDonateNft(nftType, id)
    if not gg.isInnerServer() then
        return
    end
    local idList = {}
    local unionId = self.unionId
    if not unionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
    end

    if nftType == constant.ITEM_HERO then
        local heros = self.player.heroBag:getNftHeros()
        if id then
            table.insert(idList, id)
        else
            for k,v in pairs(heros) do
                table.insert(idList, v.id)
            end
        end
    end
    if nftType == constant.ITEM_BUILD then
        local builds = self.player.buildBag:getNftBuilds()
        if id then
            table.insert(idList, id)
        else
            for k,v in pairs(builds) do
                table.insert(idList, v.id)
            end
        end
    end
    if nftType == constant.ITEM_WAR_SHIP then
        local warships = self.player.warShipBag:getNftWarShips()
        if id then
            table.insert(idList, id)
        else
            for k,v in pairs(warships) do
                table.insert(idList, v.id)
            end
        end
    end
    self:donateNft(unionId, idList)
end

--""NFT
function UnionBag:takeBackNft(unionId, idList)
    local nftList = self:_getNftList(idList)
    if table.count(nftList) ~= table.count(idList) then
        self.player:say(util.i18nFormat(errors.NFT_NOT_EXIST))
        return
    end
    if not self:canTakeBackNft(nftList) then
        return
    end
    gg.unionProxy:send("takeBackNft", self.player.pid, unionId, idList)
end

function UnionBag:canTakeBackNft(nftList)
    local now = math.floor(skynet.timestamp() / 1000)
    local cd = gg.getGlobalCfgIntValue("nftTakeBackCD", 259200)
    for i, v in ipairs(nftList) do
        if v.ref ~= constant.REF_UNION then
            return false
        end
        if v.donateTime then
            if v.donateTime == 0 then
                return false
            else
                if (v.donateTime + cd) > now then
                    self.player:say(util.i18nFormat(errors.NFT_GET_NOT_CD))
                    return false
                end
            end
        else
            return false
        end
    end
    return true
end

--""
function UnionBag:trainSolider(unionId, soliderCfgId, soliderCount)
    gg.unionProxy:send("trainSolider", self.player.pid, unionId, soliderCfgId, soliderCount)
end

function UnionBag:onUnionTrainSoliderFinish()
    self:queryUnionSoliders()
end

--gm""
function UnionBag:gmGenSolider()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    gg.unionProxy:send("gmGenSolider", self.player.pid, myUnionId)
end

--gm""NFT""
function UnionBag:gmClearNFTRef()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    gg.unionProxy:send("gmClearNFTRef", self.player.pid, myUnionId)
end

function UnionBag:genDefenseBuild(unionId, defenseCfgId, defenseCount)
    gg.unionProxy:send("genDefenseBuild", self.player.pid, unionId, defenseCfgId, defenseCount)
end

function UnionBag:onUnionGenDefenseBuildFinish()
    self:queryUnionBuilds()
end

--""
function UnionBag:levelUpTech(unionId, techCfgId)
    if constant.UNION_DISABLE_FUNC["levelUpTech"] then
        return
    end
    gg.unionProxy:send("levelUpTech", self.player.pid, unionId, techCfgId)
end

function UnionBag:onUnionLevelUpTechFinish()
    self:queryUnionTechs()
end

--""
function UnionBag:onAddUnionFavoriteGridFinish(cfgId, tag)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionFavoriteGridAdd", {
        cfgId = cfgId,
        tag = tag,
    })
end

--""
function UnionBag:onDelUnionFavoriteGridFinish(cfgId)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionFavoriteGridDel", {
        cfgId = cfgId,
    })
end

--""
function UnionBag:onUnionCampaignUpdate(campaignId)
    local myUnionId = self:getMyUnionId()
    local reports = self.player.starmapBag:getUnionStarmapCampaignReports(myUnionId, {campaignId})
    if table.count(reports) > 0 then
        gg.client:send(self.player.linkobj, "S2C_Player_UnionStarmapCampaignReportUpdate", { op_type = constant.OP_ADD, report = reports[1] })
    end
end

--""
function UnionBag:startEditUnionArmys(unionId)
    gg.unionProxy:send("startEditUnionArmys", self.player.pid, unionId)
end

--""
function UnionBag:updateMemberInfo()
    local myUnionId = self:getMyUnionId()
    if myUnionId then
        local memberInfo = self:createUnionMemberInfo()
        gg.unionProxy:send("updateMemberInfo", self.player.pid, myUnionId, memberInfo)
    end
end

function UnionBag:queryUnionRes()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local result = gg.unionProxy:call("getUnionRes", myUnionId, self.player.pid)
    if not result then
        self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    local data = {}
    data.starCoin = result.starCoin
    data.ice = result.ice
    data.titanium = result.titanium
    data.gas = result.gas
    data.carboxyl = result.carboxyl
    data.contriDegree = result.contriDegree
    gg.client:send(self.player.linkobj, "S2C_Player_UnionRes", data)
end

function UnionBag:queryUnionSoliders()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local soliders = gg.unionProxy:call("getUnionSoliders", myUnionId)
    if not soliders then
        self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    gg.client:send(self.player.linkobj, "S2C_Player_UnionSoliders", { soliders = soliders })
end

function UnionBag:queryUnionBuilds()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local builds = gg.unionProxy:call("getUnionBuilds", myUnionId)
    if not builds then
        self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    gg.client:send(self.player.linkobj, "S2C_Player_UnionBuilds", { builds = builds })
end

function UnionBag:queryUnionNfts(fromClient)
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local nfts = gg.unionProxy:call("getUnionNfts", myUnionId)
    if not nfts then
        if fromClient then
            self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        end
        return
    end
    local items = {}
    for i, v in ipairs(nfts) do
        v.ownerName = gg.shareProxy:call("getPlayerBaseInfo", v.ownerPid, "name", "" )
        table.insert(items, v)
    end
    local unionRes = gg.unionProxy:call("getUnionRes", myUnionId, self.player.pid)
    local contriDegree = (unionRes or {}).contriDegree or 0
    gg.client:send(self.player.linkobj, "S2C_Player_UnionNfts", { items = items, contriDegree = contriDegree })
end

function UnionBag:queryUnionMembers()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local members = gg.unionProxy:call("getUnionMembers", myUnionId)
    if not members then
        self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    gg.client:send(self.player.linkobj, "S2C_Player_UnionMembers", { members = members })
end

function UnionBag:queryUnionTechs()
    local myUnionId = self:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local techs = gg.unionProxy:call("getUnionTechs", myUnionId)
    if not techs then
        self.player:say(util.i18nFormat(errors.UNION_NOT_EXIST))
        return
    end
    gg.client:send(self.player.linkobj, "S2C_Player_UnionTechs", { techs = techs })
end

function UnionBag:queryUnionRank(rankKey, pid, version)
    local myUnionId = self:getMyUnionId()
    local result = gg.rankProxy:getRankList(rankKey, myUnionId, version)
    return result
end

function UnionBag:onload()
    
end

function UnionBag:onlogin()
    local unionId = self:getMyUnionId()
    if unionId then
        local data = {}
        data.applyVersion = self.applyVersion
        data.chain = self.player.playerInfoBag:getChainId() or 0
        gg.unionProxy:playerLogin(self.player.pid, data)
        local info = { unionId = unionId, beginGridId = self.beginGridId or 0, unionLevel = self.unionLevel or 0 }
        gg.client:send(self.player.linkobj, "S2C_Player_MyUnionInfo", { union = info } )
        gg.client:send(self.player.linkobj, "S2C_Player_UnionJob", { unionJob = self:getMyUnionJob() } )
        gg.matchProxy:send("joinMatch", constant.MATCH_BELONG_UNION, self.player.pid, unionId)

        --mint
        self:_completeMintsAutoPush()
    end
end

function UnionBag:onlogout()
    local unionId = self:getMyUnionId()
    if unionId then
        local data = {}
        gg.unionProxy:playerLogout(self.player.pid, data)
    end
end

function UnionBag:onreset()
    self.invites = {}
    self.mints = {}
    self.applyVersion = 0
    self.leaveUnionTick = 0

    self.unionId = nil
    self.beginGridId = nil
    self.unionLevel = nil
    self.lastGetUnionIdTick = nil
end

function UnionBag:onSecond()
    self:_checkCompleteMints()
end

return UnionBag