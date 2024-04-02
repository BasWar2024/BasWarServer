local md5 =	require	"md5"
local cgm = reload_class("cgm")

--- "": ""
---@usage
---"": addRes ""id ""
---"": addRes 101 100 <=> ""id""101(MIT)""100
---"": addRes 102 200 <=> ""id""102("")""200
function cgm:addRes(args)
    local ok,args = gg.checkargs(args,"int","int","*")
    if not ok then
        return self:say(""": "" ""id """)
    end
    local resCfgId = args[1]
    local count = args[2]
    local bind = args[3] and true or false
    if not self.master then
        return self:say(""": "" ""id """)
    end
    self.master.resBag:addRes(resCfgId, count, {logType=gamelog.GM})
end

--- "": ""
---@usage
---"": costRes ""id ""
---"": costRes 101 100 <=> ""id""101(MIT)""100
---"": costRes 102 200 <=> ""id""102("")""200
function cgm:costRes(args)
    local ok,args = gg.checkargs(args,"int","int")
    if not ok then
        return self:say(""": "" ""id """)
    end
    local resCfgId = args[1]
    local count = args[2]
    if not self.master then
        return self:say(""": "" ""id """)
    end
    self.master.resBag:costRes(resCfgId, count, {logType=gamelog.GM})
end

--- "": ""
---@usage
---"": addItem ""id "" 
---"": addItem 3800001 1 <=> ""
function cgm:addItem(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say(""": "" ""id """)
    end
    local cfgId = args[1]
    local count = args[2]
    if not self.master then
        return self:say(""": "" ""id """)
    end
    self.master.itemBag:addItem(cfgId, count, {logType = gamelog.GM})
end

--- "": ""
---@usage
---"": costItem ""id ""
---"": costItem 3800001 1 <=> ""
function cgm:costItem(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say(""": "" ""id """)
    end
    local cfgId = args[1]
    local count = args[2]
    if not self.master then
        return self:say(""": "" ""id """)
    end
    self.master.itemBag:costItem(cfgId, count, {logType=gamelog.GM})
end

--- "": ""
---@usage
---"": fullItem "" ""
---"": fullItem 10 10     <=> ""，""10""
function cgm:fullItem(args)
    local itemType = tonumber(args[1])
    local num = tonumber(args[2]) or 1
    if num > 100 then
        num = 100
    end
    if not self.master then
        return self:say(""": """)
    end
    local itemCfgs = cfg.get("etc.cfg.item")
    for _, v in pairs(itemCfgs) do
        if not itemType then
            self.master.itemBag:addItem(v.cfgId, num or 1, {logType=gamelog.GM})
        elseif v.itemType == itemType then
            self.master.itemBag:addItem(v.cfgId, num or 1, {logType=gamelog.GM})
        end
    end
end

--- "": ""1"" nft
---@usage
---"": addBuild ""cfgId "" "" chain
---"": addBuild 3201001 2 1 97
function cgm:addBuild(args)
    if not self.master then
        return self:say(""": addBuild ""cfgId "" "" chain")
    end
    local ok, args = gg.checkargs(args, "int", "*")
    if not ok then
        return self:say(""": addBuild ""cfgId "" "" chain")
    end
    local itemParam = {}
    local buildCfgId = args[1]
    itemParam.cfgId = buildCfgId
    itemParam.quality = 0
    itemParam.level = 1
    itemParam.life = 50
    itemParam.curLife = 50
    itemParam.chain = 0
    if args[2] then
        itemParam.quality = tonumber(args[2])
    end
    if args[3] then
        itemParam.level = tonumber(args[3])
    end
    if args[4] then
        itemParam.chain = tonumber(args[4])
    end
    itemParam.life = ggclass.Build.randomBuildLife(itemParam.quality)
    itemParam.curLife = itemParam.life
    local build = self.master.buildBag:newBuild(itemParam)
    if build then
        self.master.buildBag:addBuild(build, {logType=gamelog.GM})
    end
end

--- "": "" nft
---@usage
---"": delBuild ""id
---"": delBuild 6993085740053696514  <=> ""id""6993085740053696514"" nft
function cgm:delBuild(args)
    local ok,args = gg.checkargs(args,"int")
    if not ok then
        return self:say(""": "" ""id")
    end
    local id = args[1]
    if not self.master then
        return self:say(""": "" ""id")
    end
    self.master.buildBag:delBuild(id, {logType=gamelog.GM})
end

--- "": ""1""
---@usage
---"": addHero ""cfgId "" "" chain
---"": addHero 2101001 1 1 97
function cgm:addHero(args)
    if not self.master then
        return self:say(""": ""1"" ""cfgId "" "" chain")
    end
    local ok, args = gg.checkargs(args, "int", "*")
    if not ok then
        return self:say(""": ""1"" ""cfgId "" "" chain")
    end
    local itemParam = {}
    local cfgId = args[1]
    itemParam.cfgId = cfgId
    itemParam.quality = 0
    itemParam.level = 1
    itemParam.life = 50
    itemParam.curLife = 50
    itemParam.chain = 0
    if args[2] then
        itemParam.quality = tonumber(args[2])
    end
    if args[3] then
        itemParam.level = tonumber(args[3])
    end
    if args[4] then
        itemParam.chain = tonumber(args[4])
    end
    itemParam.life = ggclass.Hero.randomHeroLife(itemParam.quality)
    itemParam.curLife = itemParam.life
    local hero = self.master.heroBag:newHero(itemParam)
    if hero then
        self.master.heroBag:addHero(hero, {logType=gamelog.GM})
    end
end

--- "": ""
---@usage
---"": delHero ""id
---"": delHero 2225669887222  <=> ""id""2225669887222""
function cgm:delHero(args)
    local ok,args = gg.checkargs(args,"int")
    if not ok then
        return self:say(""": "" ""id")
    end
    local id = args[1]
    if not self.master then
        return self:say(""": "" ""id")
    end
    self.master.heroBag:delHero(id, {logType=gamelog.GM})
end

--- "": ""1""
---@usage
---"": addWarShip ""cfgId "" "" chain
---"": addWarShip 1001001 2 2 97
function cgm:addWarShip(args)
    if not self.master then
        return self:say(""": ""1"" ""cfgId "" "" chain")
    end
    local ok, args = gg.checkargs(args, "int", "*")
    if not ok then
        return self:say(""": ""1"" ""cfgId "" "" chain")
    end
    local itemParam = {}
    local cfgId = args[1]
    itemParam.cfgId = cfgId
    itemParam.quality = 0
    itemParam.level = 1
    itemParam.life = 50
    itemParam.curLife = 50
    itemParam.chain = 0
    if args[2] then
        itemParam.quality = tonumber(args[2])
    end
    if args[3] then
        itemParam.level = tonumber(args[3])
    end
    if args[4] then
        itemParam.chain = tonumber(args[4])
    end
    itemParam.life = ggclass.WarShip.randomWarShipLife(itemParam.quality)
    itemParam.curLife = itemParam.life
    local warship = self.master.warShipBag:newWarShip(itemParam)
    if warship then
        self.master.warShipBag:addWarShip(warship, {logType=gamelog.GM})
    end
end

--- "": ""
---@usage
---"": delWarShip ""id
---"": delWarShip 2225669887222  <=> ""id""2225669887222""
function cgm:delWarShip(args)
    local ok,args = gg.checkargs(args,"int")
    if not ok then
        return self:say(""": "" ""id")
    end
    local id = args[1]
    if not self.master then
        return self:say(""": "" ""id")
    end
    self.master.warShipBag:delWarShip(id, {logType=gamelog.GM})
end

--- "": ""nft""
---@usage
---"": changeAllLife "","",""
---"": changeAllLife -20
---"": changeAllLife 10
function cgm:changeAllLife(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say(""" ""nft"" """)
    end
    local value = args[1]
    if not self.master then
        return self:say(""" ""nft"" """)
    end
    local nftBuilds = self.master.buildBag:getNftBuilds()
    for _, build in pairs(nftBuilds) do
        build.curLife = build.curLife + value
        if build.curLife < 0 then
            build.curLife = 0
        end
        if build.curLife > build.life then
            build.curLife = build.life
        end
        gg.client:send(self.master.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
    end

    local nftHeros = self.master.heroBag:getNftHeros()
    for _, hero in pairs(nftHeros) do
        hero.curLife = hero.curLife + value
        if hero.curLife < 0 then
            hero.curLife = 0
        end
        if hero.curLife > hero.life then
            hero.curLife = hero.life
        end
        gg.client:send(self.master.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
    end

    local nftWarShips = self.master.warShipBag:getNftWarShips()
    for _, warShip in pairs(nftWarShips) do
        warShip.curLife = warShip.curLife + value
        if warShip.curLife < 0 then
            warShip.curLife = 0
        end
        if warShip.curLife > warShip.life then
            warShip.curLife = warShip.life
        end
        gg.client:send(self.master.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
    end
end


--- "": ""
---@usage
---"": finishGuides guidId 
---"": finishGuides 1
function cgm:finishGuides(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("useage: finishGuides guidId")
    end
    local guideId = args[1]
    self.master.guideBag:testFinish(guideId)
end

--- "": ""
---@usage
---"": bridgeBindWallet chain_id(""97) ownerMail("") ownerAddress("")
---"": bridgeBindWallet
---"": bridgeBindWallet 97
---"": bridgeBindWallet 97 test100@gmail.com
---"": bridgeBindWallet 97 test100@gmail.com 0x61eb0adc3b7bc556ad4a228a77ca917b23514f7a
function cgm:bridgeBindWallet(args)
    if not self.master then
        return self:say("no master")
    end
    self.master.playerInfoBag:refreshWalletInfo()
    local my_chain_id = self.master.playerInfoBag:getChainId()
    if my_chain_id > 0 then
        return self:say("has bind chain")
    end 

    local chain_id = math.floor(tonumber(args[1] or 97))
    local ownerMail = args[2] or self.master.account
    local ownerAddress = args[3] or util.randomWalletAddress()
    local params = {}
    params.owner_address = ownerAddress
    params.owner_mail = ownerMail
    params.chain_id = chain_id
    params.update_time = skynet.timestamp()
    gg.chainBridgeProxy:call("bindWallet", params)

    self.master.playerInfoBag:refreshWalletInfo()
    self.master.playerInfoBag:queryWallet()
end

--- "": ""Token""
---@usage
---"": bridgeRechargeToken chain_id block_no transaction_hash sequence from_address to_address token value state message
---"": bridgeRechargeToken 97 18158725 0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada5370920f 1 0x61eb0adc3b7bc556ad4a228a77ca917b23514f7a 0x45c9c28f01f975d92606886FCb178757c73204c1 HYT 100000 1 confirm
function cgm:bridgeRechargeToken(args)
    local ok, args = gg.checkargs(args, "int", "int", "string", "int", "string", "string", "string", "int", "int", "string")
    if not ok then
        return self:say("useage: bridgeRechargeToken chain_id block_no transaction_hash sequence from_address to_address token value state message")
    end
    local params = {}
    params.chain_id = args[1]
    params.block_no = args[2]
    params.transaction_hash = args[3]
    params.sequence = args[4]
    params.order_num = md5.sumhexa(params.chain_id .. "_" .. params.block_no .. "_" .. params.transaction_hash .. "_" .. params.sequence)
    params.from_address = args[5]
    params.to_address = args[6]
    params.token = args[7]
    params.value = args[8]
    params.create_time = skynet.timestamp()
    params.update_time = skynet.timestamp()
    params.state = args[9]
    params.message = args[10]
    gg.chainBridgeProxy:send("rechargeToken", params)
end

--- "": ""Token""
---@usage
---"": bridgeWithdrawToken chain_id token amount
---"": bridgeWithdrawToken 56 MIT 100
function cgm:bridgeWithdrawToken(args)
    local ok, args = gg.checkargs(args, "int", "string", "int")
    if not ok then
        return self:say("useage: bridgeWithdrawToken chain_id token amount")
    end
    local chain_id = args[1]
    local token = args[2]
    local amount = args[3]
    if not self.master then
        return self:say("no master")
    end
    self.master.chainBridgeBag:doWithdrawToken(chain_id, token, amount)
end

--- "": ""Token""
---@usage
---"": bridgeChangeTokenWithdraw order_num state message
---"": bridgeChangeTokenWithdraw 1 1 approval
function cgm:bridgeChangeTokenWithdraw(args)
    local ok, args = gg.checkargs(args, "int", "int", "string")
    if not ok then
        return self:say("useage: bridgeChangeTokenWithdraw order_num state message")
    end
    local order_num = args[1]
    local state = args[2]
    local message = args[3]
    local params = {}
    params.order_num = order_num
    params.state = state
    params.message = message
    gg.chainBridgeProxy:send("changeTokenWithdraw", params)
end

--- "": ""nft""mongo""
---@usage
---"": bridgeAddNFT chain_id owner_address kind quality race style level 
---"": bridgeAddNFT 97 0x61eb0adc3b7bc556ad4a228a77ca917b23514f7a 1 2 2 1 1
function cgm:bridgeAddNFT(args)
    local ok, args = gg.checkargs(args, "int", "string", "int", "int", "int", "int", "int")
    if not ok then
        return self:say("useage: bridgeAddNFT chain_id owner_address quality race style level")
    end
    local params = {}
    params.mint_type = args[1]
    params.kind = args[3]
    params.owner_address = args[2]
    params.style = args[6]
    params.level = args[7] or 1
    params.quality = args[4]
    params.race = args[5]
    params.life = 0
    params.tonnage = 0
    params.gene = util.combinedGene(params.quality,params.race,params.style)
    params.show_type = 0
    params.create_time = skynet.timestamp()
    params.update_time = skynet.timestamp()
    params.deleted = 0
    local token_id = gg.chainBridgeProxy:call("AddNFT", params)
    if self.master then
        self.master:say(util.i18nFormat(errors.BRIDGE_ADDNFT_SUCCESS, token_id))
    end
end

--- "": ""NFT""
---@usage
---"": bridgeRechargeNFT chain_id block_no transaction_hash sequence from_address to_address state message token_id1 token_id2
---"": bridgeRechargeNFT 97 18158445 0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada5370920f 1 0x61eb0adc3b7bc556ad4a228a77ca917b23514f7a 0x45c9c28f01f975d92606886FCb178757c73204c1 1 confirm 1002
function cgm:bridgeRechargeNFT(args)
    local ok, args = gg.checkargs(args, "int", "int", "string", "int", "string", "string", "int", "string", "int", "*")
    if not ok then
        return self:say("useage: bridgeRechargeNFT chain_id block_no transaction_hash sequence from_address to_address state message token_id1 token_id2")
    end
    local params = {}
    params.chain_id = args[1]
    params.block_no = args[2]
    params.transaction_hash = args[3]
    params.sequence = args[4]
    params.order_num = md5.sumhexa(params.chain_id .. "_" .. params.block_no .. "_" .. params.transaction_hash .. "_" .. params.sequence)
    params.from_address = args[5]
    params.to_address = args[6]
    params.state = args[7]
    params.message = args[8]
    params.create_time = skynet.timestamp()
    params.update_time = skynet.timestamp()
    params.token_ids = {}
    for i = 9, 20 do
        if args[i] then
            table.insert(params.token_ids, math.floor(tonumber(args[i])))
        end
    end
    gg.chainBridgeProxy:send("rechargeNFT", params)
end

--- "": ""nft""mongo""，""nft""
---@usage
---"": bridgeAddAndRechargeNFT kind quality race style level chain_id(""chain_id) owner_address("")
---"": bridgeAddAndRechargeNFT 1 2 2 1 1
---"": bridgeAddAndRechargeNFT 1 2 2 1 1 97 0x61eb0adc3b7bc556ad4a228a77ca917b23514f7a
---"": bridgeAddAndRechargeNFT 14 0 0 0 3800001   --dao"", level""cfgId
---"": bridgeAddAndRechargeNFT 13 0 0 0 8340001   --""NFT, level""cfgId
function cgm:bridgeAddAndRechargeNFT(args)
    local ok, args = gg.checkargs(args, "int", "int", "int", "int", "int")
    if not ok then
        return self:say("useage: bridgeAddAndRechargeNFT kind quality race style level chain_id owner_address")
    end
    
    local kind = args[1]
    if kind ~= constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP and kind ~= constant.CHAIN_BRIDGE_NFT_KIND_HERO and
        kind ~= constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE and kind ~= constant.CHAIN_BRIDGE_NFT_KIND_ITEM_NFT and
            kind ~= constant.CHAIN_BRIDGE_NFT_KIND_ITEM_ARTIFACT then
                return self:say("kind error")
    end

    local quality = args[2]
    local race = args[3]
    local style = args[4]
    local level = args[5]
    local chain_id = args[6]
    local owner_address = args[7]

    if not chain_id then
        if not self.master then
            return self:say("no master")
        end
        local my_chain_id = self.master.playerInfoBag:getChainId()
        if not my_chain_id or my_chain_id <= 0 then
            return self:say("no chain_id")
        end
        chain_id = my_chain_id
    end
    chain_id = math.floor(tonumber(chain_id))

    if not owner_address then
        if not self.master then
            return self:say("no master")
        end
        local my_owner_address = self.master.playerInfoBag:getOwnerAddress()
        if not my_owner_address or my_owner_address == "" then
            return self:say("no owner_address")
        end
        owner_address = my_owner_address
    end

    local params = {}
    params.mint_type = chain_id
    params.owner_address = owner_address
    params.kind = kind
    params.quality = quality
    params.race = race
    params.style = style
    params.level = level
    params.life = 0
    params.tonnage = 0
    params.gene = util.combinedGene(params.quality,params.race,params.style)
    params.show_type = 0
    params.create_time = skynet.timestamp()
    params.update_time = skynet.timestamp()
    params.deleted = 0
    if kind == constant.CHAIN_BRIDGE_NFT_KIND_ITEM_NFT or kind == constant.CHAIN_BRIDGE_NFT_KIND_ITEM_ARTIFACT then
        params.quality = 0
        params.race = 0
        params.style = 0
        params.level = 0
        params.gene = util.combinedGene(params.quality,params.race,params.style)
        params.cfgId = level
    end
    local token_id = gg.chainBridgeProxy:call("AddNFT", params)

    local rechargeData = {}
    rechargeData[1] = chain_id
    rechargeData[2] = math.random(10000000,18158445)
    rechargeData[3] = "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada53" .. math.random(100000, 999999)
    rechargeData[4] = math.random(1, 3)
    rechargeData[5] = owner_address
    rechargeData[6] = "0x45c9c28f01f975d92606886FCb178757c73204c1"
    rechargeData[7] = 1
    rechargeData[8] = "confirm"
    rechargeData[9] = token_id
    self:bridgeRechargeNFT(rechargeData)

    if self.master then
        self.master:say(util.i18nFormat(errors.BRIDGE_ADDNFT_SUCCESS, token_id))
    end
end

--- "": ""NFT""
---@usage
---"": bridgeWithdrawNFT chain_id token_id1 token_id2
---"": bridgeWithdrawNFT 56 2002 3002
function cgm:bridgeWithdrawNFT(args)
    local ok, args = gg.checkargs(args, "int", "int", "*")
    if not ok then
        return self:say("useage: bridgeWithdrawNFT chain_id token_id1 token_id2")
    end
    local chain_id = args[1]
    local token_ids = {}
    for i = 2, 20 do
        if args[i] then
            table.insert(token_ids, math.floor(tonumber(args[i])))
        end
    end
    if not self.master then
        return self:say("no master")
    end
    self.master.chainBridgeBag:doWithdrawNFT(chain_id, token_ids)
end

--- ""：""
---@usage
---"": buyBattleNum battleNum
---"": buyBattleNum 3
function cgm:buyBattleNum(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("useage: buyBattleNum battleNum")
    end
    if not self.master then
        return self:say("no master")
    end
    self.master.pvpBag:addBattleNum(args[1])
end

--- "": ""
---@usage
---"": queryOwnerAddress 
---"": queryOwnerAddress
function cgm:queryOwnerAddress(args)
    self.master.playerInfoBag:queryOwnerAddress()
end

--- "": ""nft, ""quality"", ""quality""quality
---@usage
---"": oneKeyGenerateNfts chain quality
---"": oneKeyGenerateNfts chain quality
function cgm:oneKeyGenerateNfts(args)
    local ok, args = gg.checkargs(args, "int", "*")
    if not ok then
        return self:say("useage: oneKeyGenerateNfts 0")
    end
    local chain = args[1]
    local my_chain_id = self.master.playerInfoBag:getChainId()
    if not my_chain_id or my_chain_id <= 0 then
        self:bridgeBindWallet({chain})
    end
    local quality = args[2] or nil
    if quality then
        quality = tonumber(quality)
    end
    local buildCfgs = cfg.get("etc.cfg.build")
    for k,v in pairs(buildCfgs) do
        if (not quality or quality == v.quality) and v.level == 1 and v.quality > 0 and v.race > 0 and v.style > 0 then
            self:bridgeAddAndRechargeNFT({3, v.quality, v.race, v.style, v.level})
        end
    end

    local heroCfgs = cfg.get("etc.cfg.hero")
    for k,v in pairs(heroCfgs) do
        if (not quality or quality == v.quality) and v.level == 1 and v.quality > 0 and v.race > 0 and v.style > 0 then
            self:bridgeAddAndRechargeNFT({2, v.quality, v.race, v.style, v.level})
        end
    end

    local warShipCfgs = cfg.get("etc.cfg.warShip")
    for k,v in pairs(warShipCfgs) do
        if (not quality or quality == v.quality) and v.level == 1 and v.quality > 0 and v.race > 0 and v.style > 0 then
            self:bridgeAddAndRechargeNFT({1, v.quality, v.race, v.style, v.level})
        end
    end
end

--- "": ""
---@usage
---"": generateBuildLayout
---"": generateBuildLayout
function cgm:generateBuildLayout()
    local list = {}
    local builds = self.master.buildBag.builds
    for k, v in pairs(builds) do
        local info = {}
        info.cfgId = v.cfgId
        info.quality = v.quality
        info.level = v.level
        info.life = v.life
        info.curLife = v.curLife
        info.x = v.x
        info.z = v.z
        table.insert(list, info)
    end
    local content = cjson.encode(list)
    self:say(content)
    logger.logf("error","JsonOutput", content)
end

--- ""：""mit
---@usage
---"": pledgeMit value
---"": pledgeMit 60000
function cgm:pledgeMit(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("useage: pledgeMit 60000")
    end
    if not self.master then
        return self:say("no master")
    end
    local my_chain_id = self.master.playerInfoBag:getChainId()
    if not my_chain_id or my_chain_id <= 0 then
        return self:say("no chain")
    end
    local value = args[1] or 0
    value = math.abs(value)
    self.master.vipBag:pledge(value)
end

--- ""：""
---@usage
---"": reapGuideRes id resId
---"": reapGuideRes 
function cgm:reapGuideRes(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say("useage: reapGuideRes id resId")
    end
    if not self.master then
        return self:say("no master")
    end
    local id = args[1]
    local resId = args[2]
    if resId == constant.RES_ICE then
        self.master.guideBag:reapGuideIce(id)
    elseif resId == constant.RES_STARCOIN then
        self.master.guideBag:reapGuideStarCoin(id)
    end
end

--- "": ""
---@usage
---"": generatePlayerData
---"": generatePlayerData
function cgm:generatePlayerData()
    local playerData = self.master:serialize()
    
    local accountData = gg.mongoProxy.account:findOne({account = playerData.property.account})
    accountData._id = nil

    local accountRoleData = gg.mongoProxy.account_roles:findOne({account = playerData.property.account})
    accountRoleData._id = nil

    local roleData = gg.mongoProxy.role:findOne({account = playerData.property.account})
    roleData._id = nil

    local briefData = gg.mongoProxy.brief:findOne({account = playerData.property.account})
    briefData._id = nil

    local allData = {}
    allData.player = playerData
    allData.account = accountData
    allData.account_roles = accountRoleData
    allData.role = roleData
    allData.brief = briefData
    local content = cjson.encode(allData)
    logger.logf("info","JsonOutput", content)
end

--- ""：""
---@usage
---"": sendGuide guideId skipOthers
---"": sendGuide 1006 1 
function cgm:sendGuide(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say("useage: sendGuide 1006 1")
    end
    if not self.master then
        return self:say("no master")
    end
    local guideId = args[1]
    local skipOthers = args[2]
    local guides = {{guideId = guideId, skipOthers = skipOthers}}
    self.master.guideBag:checkFinish(guides)
end

--- ""：""
---@usage
---"": genUnionSolider 
---"": genUnionSolider 
function cgm:genUnionSolider(args)
    local ok, args = gg.checkargs(args, "*")
    if not ok then
        return self:say("useage: genUnionSolider")
    end
    if not self.master then
        return self:say("no master")
    end
    self.master.unionBag:gmGenSolider()
end

--- ""：""NFT""
---@usage
---"": clearUnionNFTRef 
---"": clearUnionNFTRef 
function cgm:clearUnionNFTRef(args)
    local ok, args = gg.checkargs(args, "*")
    if not ok then
        return self:say("useage: clearUnionNFTRef")
    end
    if not self.master then
        return self:say("no master")
    end
    self.master.unionBag:gmClearNFTRef()
end

--- ""：""
---@usage
---"": drawCard cfgId drawCount
---"": drawCard 1 100
function cgm:drawCard(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say("useage: drawCard 1 100")
    end
    if not self.master then
        return self:say("no master")
    end
    local cfgId = args[1]
    local drawCount = args[2]
    self.master.drawCardBag:drawCard(cfgId, drawCount, true)
end

--- ""：""
---@usage
---"": reduceWithdraw value
---"": reduceWithdraw 86400
---"": reduceWithdraw 3600
function cgm:reduceWithdraw(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("useage: reduceWithdraw 86400")
    end
    if not self.master then
        return self:say("no master")
    end
    local value = args[1] or 0
    self.master.chainBridgeBag:reduceWithdraw(value)
end

--- ""：""nft""，
--- ""：nftType: warShip 9, hero 10, build 11，id""type""nft""
---@usage
---"": donateNft type id 
---"": donateNft 10 10003 
---"": donateNft 10       
function cgm:donateNft(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("useage: donateNfts hero 3")
    end
    if not self.master then
        return self:say("no master")
    end
    
    local nftType = args[1] or "hero"
    local id = args[2]
    self.master.unionBag:gmDonateNft(nftType,id)
end

--- ""
---@usage
---"": genLanguageJson
---"": genLanguageJson ""errors""etc\i18n""3"",""
function cgm:genLanguageJson(args)
    local infoList = {}
    for k, v in pairs(errors) do
        table.insert(infoList, v)
    end
    table.sort(infoList,function (a,b)
        if a.id == b.id then
            return false
        end
        return a.id < b.id
    end)

    os.execute("mkdir -p language")

    local en_US_text = "{"
    local zh_TW_text = "{"
    local zh_CN_text = "{"
    local curLanguage = gg.genI18nTexts()
    for k, v in pairs(infoList) do
        if curLanguage[v.msg] and curLanguage[v.msg].en_US then
            if en_US_text ~= "{" then
                en_US_text = en_US_text .. ","
            end
            en_US_text = en_US_text .. "\n" .. '\t' .. '"' .. v.msg .. '"' .. " : " .. '"' .. curLanguage[v.msg].en_US .. '"'
        else
            if en_US_text ~= "{" then
                en_US_text = en_US_text .. ","
            end
            en_US_text = en_US_text .. "\n" .. '\t' .. '"' .. v.msg .. '"' .. " : " .. '"' .. v.msg .. '"'
        end

        if curLanguage[v.msg] and curLanguage[v.msg].zh_TW then
            if zh_TW_text ~= "{" then
                zh_TW_text = zh_TW_text .. ","
            end
            zh_TW_text = zh_TW_text .. "\n" .. '\t' .. '"' .. v.msg .. '"' .. " : " .. '"' .. curLanguage[v.msg].zh_TW .. '"'
        else
            if zh_TW_text ~= "{" then
                zh_TW_text = zh_TW_text .. ","
            end
            zh_TW_text = zh_TW_text .. "\n" .. '\t' .. '"' .. v.msg .. '"' .. " : " .. '"' .. v.msg .. '"'
        end

        if curLanguage[v.msg] and curLanguage[v.msg].zh_CN then
            if zh_CN_text ~= "{" then
                zh_CN_text = zh_CN_text .. ","
            end
            zh_CN_text = zh_CN_text .. "\n" .. '\t' .. '"' .. v.msg .. '"' .. " : " .. '"' .. curLanguage[v.msg].zh_CN .. '"'
        else
            if zh_CN_text ~= "{" then
                zh_CN_text = zh_CN_text .. ","
            end
            zh_CN_text = zh_CN_text .. "\n" .. '\t' .. '"' .. v.msg .. '"' .. " : " .. '"' .. v.msg .. '"'
        end
    end
    en_US_text = en_US_text .. "\n}"
    zh_TW_text = zh_TW_text .. "\n}"
    zh_CN_text = zh_CN_text .. "\n}"

    local docfilename = "language/en_US.json"
    local fdout = io.open(docfilename,"wb")
    fdout:write(en_US_text)
    fdout:close()

    local docfilename = "language/zh_TW.json"
    local fdout = io.open(docfilename,"wb")
    fdout:write(zh_TW_text)
    fdout:close()

    local docfilename = "language/zh_CN.json"
    local fdout = io.open(docfilename,"wb")
    fdout:write(zh_CN_text)
    fdout:close()
end

function __hotfix(module)
    gg.gm:hotfix_gm()
end