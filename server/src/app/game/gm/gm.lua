local cgm = reload_class("cgm")

function cgm:getplayer(pid)
    return gg.playermgr:getplayer(pid)
end

function cgm:_open()
    -- admin
    self:register_admin()
    self:register("echo",self.echo,self.TAG_NORMAL,"")

    -- player
    self:register("addRes",self.addRes,self.TAG_NORMAL,"")
    self:register("costRes",self.costRes,self.TAG_NORMAL,"")
    self:register("addItem",self.addItem,self.TAG_NORMAL,"")
    self:register("delItem",self.delItem,self.TAG_NORMAL,"")
    self:register("expandItemBagSpace",self.expandItemBagSpace,self.TAG_NORMAL,"")
    self:register("generateHero",self.generateHero,self.TAG_NORMAL,"")
    self:register("delHero",self.delHero,self.TAG_NORMAL,"")
    self:register("generateWarShip",self.generateWarShip,self.TAG_NORMAL,"")
    self:register("delWarShip",self.delWarShip,self.TAG_NORMAL,"")
    self:register("composeItem",self.composeItem,self.TAG_NORMAL,"")
    self:register("cancelComposeItem",self.cancelComposeItem,self.TAG_NORMAL,"")
    self:register("speedComposeItem",self.speedComposeItem,self.TAG_NORMAL,"")
    self:register("repairItems",self.repairItems,self.TAG_NORMAL,"")
    self:register("repairSpeed",self.repairSpeed,self.TAG_NORMAL,"")
    self:register("getRepairItems",self.getRepairItems,self.TAG_NORMAL,"")
    self:register("move2ItemBag",self.move2ItemBag,self.TAG_NORMAL,"")
    self:register("moveOutItemBag",self.moveOutItemBag,self.TAG_NORMAL,"")
    self:register("addItemLife",self.addItemLife,self.TAG_NORMAL,"")
    self:register("queryAllResPlanetBrief",self.queryAllResPlanetBrief,self.TAG_NORMAL,"")
    self:register("lookResPlanet",self.lookResPlanet,self.TAG_NORMAL,"")
    self:register("resPlanetBuild2ItemBag",self.resPlanetBuild2ItemBag,self.TAG_NORMAL,"")
    self:register("itemBagBuild2ResPlanet",self.itemBagBuild2ResPlanet,self.TAG_NORMAL,"")
    self:register("queryBoatRes",self.queryBoatRes,self.TAG_NORMAL,"")
    self:register("pickBoatRes",self.pickBoatRes,self.TAG_NORMAL,"")
    self:register("beginAttackResPlanet",self.beginAttackResPlanet,self.TAG_NORMAL,"")
    self:register("endAttackResPlanet",self.endAttackResPlanet,self.TAG_NORMAL,"")
    self:register("addBoatRes",self.addBoatRes,self.TAG_NORMAL,"")
    self:register("addBuild2ResBoat",self.addBuild2ResBoat,self.TAG_NORMAL,"")
end


function cgm:onlogin(player,replace)
    if player.isGm and not player:isGm() then
        return
    end
    local msg = [[HI,GM,,,:
    help   => '',
        help <=> 
        help  <=> 
    buildgmdoc => gm(svn)
    ]]
    self:say(msg,player.pid)
end

function __hotfix(module)
    gg.gm:open()
end

return cgm