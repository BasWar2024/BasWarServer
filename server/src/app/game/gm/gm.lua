local cgm = reload_class("cgm")

function cgm:getplayer(pid)
    local player = gg.playermgr:getplayer(pid)
    if not player then
        return
    end
    if player.isGm and not player:isGm() then
        return
    end
    return player
end

function cgm:_open()
    -- admin
    self:register_admin()
    self:register("echo",self.echo,self.TAG_NORMAL,"echo")

    -- player
    self:register("addRes",self.addRes,self.TAG_NORMAL,"addRes")
    self:register("costRes",self.costRes,self.TAG_NORMAL,"costRes")
    self:register("addItem",self.addItem,self.TAG_NORMAL,"addItem")
    self:register("costItem",self.costItem,self.TAG_NORMAL,"costItem")
    self:register("fullItem",self.fullItem,self.TAG_NORMAL,"fullItem")
    self:register("changeAllLife",self.changeAllLife,self.TAG_NORMAL,"changeAllLife")
    self:register("addWarShip",self.addWarShip,self.TAG_NORMAL,"addWarShip")
    self:register("delWarShip",self.delWarShip,self.TAG_NORMAL,"delWarShip")
    self:register("addHero",self.addHero,self.TAG_NORMAL,"addHero")
    self:register("delHero",self.delHero,self.TAG_NORMAL,"delHero")
    self:register("addBuild",self.addBuild,self.TAG_NORMAL,"addBuild")
    self:register("delBuild",self.delBuild,self.TAG_NORMAL,"delBuild")
    self:register("finishGuides",self.finishGuides,self.TAG_NORMAL,"finishGuides")
    self:register("buyBattleNum",self.buyBattleNum,self.TAG_NORMAL,"buyBattleNum")
    self:register("queryOwnerAddress",self.queryOwnerAddress,self.TAG_NORMAL,"queryOwnerAddress")
    self:register("pledgeMit",self.pledgeMit,self.TAG_NORMAL,"pledgeMit")
    self:register("reapGuideRes",self.reapGuideRes,self.TAG_NORMAL,"reapGuideRes")
    self:register("oneKeyGenerateNfts",self.oneKeyGenerateNfts,self.TAG_NORMAL,"oneKeyGenerateNfts")
    self:register("sendGuide",self.sendGuide,self.TAG_NORMAL,"sendGuide")
    self:register("drawCard",self.drawCard,self.TAG_NORMAL,"drawCard")
    self:register("reduceWithdraw",self.reduceWithdraw,self.TAG_NORMAL,"reduceWithdraw")
    -- bridge
    self:register("bridgeBindWallet",self.bridgeBindWallet,self.TAG_NORMAL,"bridgeBindWallet")
    self:register("bridgeRechargeToken",self.bridgeRechargeToken,self.TAG_NORMAL,"bridgeRechargeToken")
    self:register("bridgeWithdrawToken",self.bridgeWithdrawToken,self.TAG_NORMAL,"bridgeWithdrawToken")
    self:register("bridgeChangeTokenWithdraw",self.bridgeChangeTokenWithdraw,self.TAG_NORMAL,"bridgeChangeTokenWithdraw")
    self:register("bridgeAddNFT",self.bridgeAddNFT,self.TAG_NORMAL,"bridgeAddNFT")
    self:register("bridgeRechargeNFT",self.bridgeRechargeNFT,self.TAG_NORMAL,"bridgeRechargeNFT")
    self:register("bridgeAddAndRechargeNFT",self.bridgeAddAndRechargeNFT,self.TAG_NORMAL,"bridgeAddAndRechargeNFT")
    self:register("bridgeWithdrawNFT",self.bridgeWithdrawNFT,self.TAG_NORMAL,"bridgeWithdrawNFT")

    -- union
    self:register("genUnionSolider",self.genUnionSolider,self.TAG_NORMAL,"genUnionSolider")
    self:register("clearUnionNFTRef",self.clearUnionNFTRef,self.TAG_NORMAL,"clearUnionNFTRef")
    self:register("donateNft",self.donateNft,self.TAG_NORMAL,"donateNft")
    
    --""
    self:register("generateBuildLayout",self.generateBuildLayout,self.TAG_NORMAL,"generateBuildLayout")
    self:register("generatePlayerData",self.generatePlayerData,self.TAG_NORMAL,"generatePlayerData")

    --""json""
    self:register("genLanguageJson",self.genLanguageJson,self.TAG_NORMAL,"genLanguageJson")
end


function cgm:onlogin(player,replace)
    if player.isGm and not player:isGm() then
        return
    end
    local msg = [[HI,GM,welcome:
    help key  => 
        help <=> look all the help command
        help resource <=> look resouce command
    buildgmdoc => build the gm doc
    ]]
    self:say(msg,player.pid)
end

function __hotfix(module)
    gg.gm:open()
end

return cgm