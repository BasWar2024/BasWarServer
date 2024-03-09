local cgm = reload_class("cgm")

--- : 
---@usage
---: addRes id 
---: addRes 101 100 <=> id101(MIT)100
---: addRes 102 200 <=> id102()200
function cgm:addRes(args)
    local ok,args = gg.checkargs(args,"int","int")
    if not ok then
        return self:say(":  id ")
    end
    local resCfgId = args[1]
    local count = args[2]
    if not self.master then
        return self:say(":  id ")
    end
    self.master.resBag:addRes(resCfgId, count)
end

--- : 
---@usage
---: costRes id 
---: costRes 101 100 <=> id101(MIT)100
---: costRes 102 200 <=> id102()200
function cgm:costRes(args)
    local ok,args = gg.checkargs(args,"int","int")
    if not ok then
        return self:say(":  id ")
    end
    local resCfgId = args[1]
    local count = args[2]
    if not self.master then
        return self:say(":  id ")
    end
    self.master.resBag:costRes(resCfgId, count)
end


--- : 
---@usage
---: addItem id  (id   1 2 3 4)
---: addItem 6101001 30 <=> 30
---: addItem 6204001 30 <=> 30
---: addItem 6301001 1 2101001 1 1 <=> 1 1
function cgm:addItem(args)
    local ok, args = gg.checkargs(args, "int", "int", "*")
    if not ok then
        return self:say(":  ID  id   1 2 3 4 5")
    end
    local param = {}
    local cfgId = args[1]
    local count = args[2]
    if #args > 2 then
        param.targetCfgId = tonumber(args[3])
        param.targetQuality = tonumber(args[4])
        param.targetLevel = tonumber(args[5])
        param.skillLevel1 = tonumber(args[6])
        param.skillLevel2 = tonumber(args[7])
        param.skillLevel3 = tonumber(args[8])
        param.skillLevel4 = tonumber(args[9])
        param.skillLevel5 = tonumber(args[10])
    end
    if not self.master then
        return self:say(":  ID  id   1 2 3 4 5")
    end
    self.master.itemBag:addItem(cfgId,count,param,{reason="gm"})
end

--- : 1
---@usage
---: addBuildItem ID  
---: addBuildItem 1301001 1 1
function cgm:addBuildItem(args)
    if not self.master then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    local ok, args = gg.checkargs(args, "int", "*")
    if not ok then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    local itemParam = {}
    local buildCfgId = args[1]
    itemParam.targetCfgId = buildCfgId
    itemParam.targetQuality = 1
    itemParam.targetLevel = 1
    itemParam.skillLevel1 = 0
    itemParam.skillLevel2 = 0
    itemParam.skillLevel3 = 0
    itemParam.skillLevel4 = 0
    itemParam.skillLevel5 = 0
    itemParam.num = 1
    if args[2] then
        itemParam.targetQuality = tonumber(args[2])
    end
    if args[3] then
        itemParam.targetLevel = tonumber(args[3])
    end
    local buildCfg = ggclass.Build.getBuildCfg(buildCfgId, itemParam.targetQuality, itemParam.targetLevel)
    if not buildCfg or not buildCfg.itemCfgId then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    itemParam.cfgId = buildCfg.itemCfgId
    self.master.itemBag:addItem(itemParam.cfgId,1,itemParam,{reason="gm"})
end

--- : 1
---@usage
---: addHeroItem ID   1 2 3
---: addHeroItem 2201001 1 1
function cgm:addHeroItem(args)
    if not self.master then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    local ok, args = gg.checkargs(args, "int", "*")
    if not ok then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    local itemParam = {}
    local cfgId = args[1]
    itemParam.targetCfgId = cfgId
    itemParam.targetQuality = 1
    itemParam.targetLevel = 1
    itemParam.skillLevel1 = 0
    itemParam.skillLevel2 = 0
    itemParam.skillLevel3 = 0
    itemParam.skillLevel4 = 0
    itemParam.skillLevel5 = 0
    itemParam.num = 1
    if args[2] then
        itemParam.targetQuality = tonumber(args[2])
    end
    if args[3] then
        itemParam.targetLevel = tonumber(args[3])
    end
    if args[4] then
        itemParam.skillLevel1 = tonumber(args[4])
    end
    if args[5] then
        itemParam.skillLevel2 = tonumber(args[5])
    end
    if args[6] then
        itemParam.skillLevel3 = tonumber(args[6])
    end
    local heroCfg = ggclass.Hero.getHeroCfg(cfgId, itemParam.targetQuality, itemParam.targetLevel)
    if not heroCfg or not heroCfg.itemCfgId then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    itemParam.cfgId = heroCfg.itemCfgId
    self.master.itemBag:addItem(itemParam.cfgId,1,itemParam,{reason="gm"})
end

--- : 1
---@usage
---: addWarShipItem ID   1 2 3 4
---: addWarShipItem 3401001 1
function cgm:addWarShipItem(args)
    if not self.master then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    local ok, args = gg.checkargs(args, "int", "*")
    if not ok then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    local itemParam = {}
    local cfgId = args[1]
    itemParam.targetCfgId = cfgId
    itemParam.targetQuality = 1
    itemParam.targetLevel = 1
    itemParam.skillLevel1 = 0
    itemParam.skillLevel2 = 0
    itemParam.skillLevel3 = 0
    itemParam.skillLevel4 = 0
    itemParam.skillLevel5 = 0
    itemParam.num = 1
    if args[2] then
        itemParam.targetQuality = tonumber(args[2])
    end
    if args[3] then
        itemParam.targetLevel = tonumber(args[3])
    end
    if args[4] then
        itemParam.skillLevel1 = tonumber(args[4])
    end
    if args[5] then
        itemParam.skillLevel2 = tonumber(args[5])
    end
    if args[6] then
        itemParam.skillLevel3 = tonumber(args[6])
    end
    local warShipCfg = ggclass.WarShip.getWarShipCfg(cfgId, itemParam.targetQuality, itemParam.targetLevel)
    if not warShipCfg or not warShipCfg.itemCfgId then
        return self:say(": 1 ID   1 2 3 4 5")
    end
    itemParam.cfgId = warShipCfg.itemCfgId
    self.master.itemBag:addItem(itemParam.cfgId,1,itemParam,{reason="gm"})
end

--- : 
---@usage
---: delItem id 
---: delItem 6101001 30 <=> 30
---: delItem 6204001 200 <=> 200
function cgm:delItem(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say(":  id ")
    end
    local cfgId = args[1]
    local count = args[2]
    if not self.master then
        return self:say(":  ID ")
    end
    self.master.itemBag:costItem(cfgId, count, {reason="gm"})
end

--- : 
---@usage
---: expandItemBagSpace
---: expandItemBagSpace
function cgm:expandItemBagSpace()
    if not self.master then
        return self:say(":  ID ")
    end
    self.master.itemBag:expandItemBag()
end

--- : 
---@usage
---: move2ItemBag ID 
---: move2ItemBag 25010013555552 9 <=> ID25010013555552
---: move2ItemBag 25010013555552 10 <=> ID25010013555552
---: move2ItemBag 25010013555552 11 <=> ID25010013555552
function cgm:move2ItemBag(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say(":  ID ")
    end
    local id = args[1]
    local itemType = args[2]
    if not self.master then
        return self:say(":  ID ")
    end
    if itemType == constant.ITEM_WAR_SHIP then
        self.master.warShipBag:warShipMove2ItemBag(id)
    elseif itemType == constant.ITEM_HERO then
        self.master.heroBag:heroMove2ItemBag(id)
    elseif itemType == constant.ITEM_BUILD then
        self.master.buildBag:buildMove2ItemBag(id)
    end
end

--- : 
---@usage
---: moveOutItemBag ID posX posZ
---: moveOutItemBag 25010013555552 9 9<=> ID25010013555552
---: moveOutItemBag 25010013555552 10 11<=> ID25010013555552
---: moveOutItemBag 25010013555552 11 122<=> ID25010013555552
function cgm:moveOutItemBag(args)
    local ok, args = gg.checkargs(args, "int", "int", "int")
    if not ok then
        return self:say(":  ID ")
    end
    local id = args[1]
    if not id then
        return self:say(":  ID ")
    end
    local posX = args[2]
    if not posX then
        return self:say(":  ID ")
    end
    local posZ = args[3]
    if not posZ then
        return self:say(":  ID ")
    end
    local item = self.master.itemBag:getItem(id)
    if not item then
        return self:say(":  ID ")
    end
    if self.master.repairBag:isItemInRepair(id) then
        return self:say(":  ID ")
    end
    if item.itemType == constant.ITEM_WAR_SHIP then
        self.master.warShipBag:warShipMoveOutItemBag(item)
    elseif item.itemType == constant.ITEM_HERO then
        self.master.heroBag:heroMoveOutItemBag(item)
    elseif item.itemType == constant.ITEM_BUILD then
        self.master.buildBag:buildMoveOutItemBag(item, {x=posX, z=posZ})
    end
end

--- : 
---@usage
---: generateHero id 
---: generateHero 2501001 1 <=> id2501001,1
---: generateHero 2501001 2 <=> id2501001,2
function cgm:generateHero(args)
    local ok,args = gg.checkargs(args,"int","int")
    if not ok then
        return self:say(":  id ")
    end
    local cfgId = args[1]
    local quality = args[2]
    if not self.master then
        return self:say(":  id ")
    end

    if self.master.heroBag:hasHero() then --
        local cfg = ggclass.Hero.getHeroCfg(cfgId, quality, 1)
        if not cfg then
            return self:say(":  id ")
        end
        --addItem 6301001 1 2101001 1 1
        local newArgs = {}
        newArgs[1] = cfg.itemCfgId
        newArgs[2] = 1
        newArgs[3] = cfgId
        newArgs[4] = quality
        newArgs[5] = 1
        self:addItem(newArgs)
    else
        local hero = self.master.heroBag:generateHero(cfgId, quality)
        self.master.heroBag:addHero(hero)
    end
end

--- : 
---@usage
---: delHero id
---: delHero 2225669887222  <=> id2225669887222
function cgm:delHero(args)
    local ok,args = gg.checkargs(args,"int")
    if not ok then
        return self:say(":  id")
    end
    local id = args[1]
    if not self.master then
        return self:say(":  id")
    end
    self.master.heroBag:delHero(id)
end

--- : 
---@usage
---: generateWarShip id 
---: generateWarShip 3501001 1 <=> id3501001,1
---: generateWarShip 3501001 2 <=> id3501001,2
function cgm:generateWarShip(args)
    local ok,args = gg.checkargs(args,"int","int")
    if not ok then
        return self:say(":  id ")
    end
    local cfgId = args[1]
    local quality = args[2]
    if not self.master then
        return self:say(":  id ")
    end
    if self.master.warShipBag:hasWarShip() then
        local cfg = ggclass.WarShip.getWarShipCfg(cfgId, quality, 1)
        if not cfg then
            return self:say(":  id ")
        end
        --addItem 6301001 1 2101001 1 1
        local newArgs = {}
        newArgs[1] = cfg.itemCfgId
        newArgs[2] = 1
        newArgs[3] = cfgId
        newArgs[4] = quality
        newArgs[5] = 1          --level
        newArgs[6] = 1          --skillLevel1
        self:addItem(newArgs)
    else
        local warShip = self.master.warShipBag:generateWarShip(cfgId, quality)
        self.master.warShipBag:addWarShip(warShip)
    end
end

--- : 
---@usage
---: delWarShip id
---: delWarShip 2225669887222  <=> id2225669887222
function cgm:delWarShip(args)
    local ok,args = gg.checkargs(args,"int")
    if not ok then
        return self:say(":  id")
    end
    local id = args[1]
    if not self.master then
        return self:say(":  id")
    end
    self.master.warShipBag:delWarShip(id)
end

--- : 
---@usage
---: composeItem ID 
---: composeItem 2225669887222 37 <=> 372225669887222
function cgm:composeItem(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say("  ID ")
    end
    if not self.master then
        return self.say("  ID ")
    end
    local id = args[1]
    local hour = args[2]
    self.master.itemBag:playerItemCompose(id, hour)
end

--- : 
---@usage
---: cancelComposeItem ID
---: cancelComposeItem 2225669887222 <=> 2225669887222
function cgm:cancelComposeItem(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("  ID")
    end
    local id = args[1]
    if not self.master then
        return self:say("  ID")
    end
    self.master.itemBag:playerItemComposeCancel(id)
end

--- : 
---@usage
---: speedComposeItem ID
---: speedComposeItem 2225669887222 <=> ID2225669887222
function cgm:speedComposeItem(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("  ID")
    end
    local id = args[1]
    if not self.master then
        return self:say("  ID")
    end
    self.master.itemBag:playerItemComposeSpeed(id)
end

--- : 
---@usage
---: repairItems IDs
---: repairItems 2225669887222
function cgm:repairItems(args)
    local ok, args = gg.checkargs(args, "table")
    local ids = args[1]
    if not self.master then
        return self:say("  ID")
    end
    self.master.repairBag:repair(ids)
end

--- : 
---@usage
---: repairSpeed ID
---: repairSpeed 2225669887222
function cgm:repairSpeed(args)
    local ok, args = gg.checkargs(args, "int")
    local id = args[1]
    if not self.master then
        return self:say("  ID")
    end
    self.master.repairBag:repairSpeed(id)
end

--- : 
---@usage
---: getRepairItems
---: getRepairItems
function cgm:getRepairItems(args)
    if not self.master then
        return self:say("  ID")
    end
    self.master.repairBag:getRepairItems()
end

--- : 
---@usage
---: addItemLife ID 
---: addItemLife 2225669887222 -20
function cgm:addItemLife(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say("  ID ")
    end
    local id = args[1]
    local addedLife = args[2]
    if not self.master then
        return self:say("  ID ")
    end
    local item = self.master.itemBag:getItem(id)
    if not item then
        return self:say("  ID ")
    end
    local newCurLife = item.curLife + addedLife
    if newCurLife <= 0 then
        return self:say("  ID ")
    end
    self.master.itemBag:update(id, {curLife = newCurLife})
end

--- : 
---@usage
---: queryAllResPlanetBrief
---: queryAllResPlanetBrief
function cgm:queryAllResPlanetBrief(args)
    if not self.master then
        return self:say(" ")
    end
    self.master.resPlanetBag:queryAllResPlanetBrief()
end

--- : 
---@usage
---: lookResPlanet 
---: lookResPlanet 1
function cgm:lookResPlanet(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("  ")
    end
    local index = args[1]
    if not self.master then
        return self:say("  ")
    end
    self.master.resPlanetBag:lookResPlanet(index)
end

--- : 
---@usage
---: resPlanetBuild2ItemBag  ID
---: resPlanetBuild2ItemBag 1 2225669887222
function cgm:resPlanetBuild2ItemBag(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say("   ID")
    end
    local index = args[1]
    local buildId = args[2]
    if not self.master then
        return self:say("   ID")
    end
    self.master.resPlanetBag:buildMove2ItemBag(index, buildId)
end

--- : 
---@usage
---: itemBagBuild2ResPlanet  ID x z
---: itemBagBuild2ResPlanet 1 2225669887222 22 22
function cgm:itemBagBuild2ResPlanet(args)
    local ok, args = gg.checkargs(args, "int", "int", "int", "int")
    if not ok then
        return self:say("   ID x z")
    end
    local index = args[1]
    local buildId = args[2]
    local posX = args[3]
    local posZ = args[4]
    if not self.master then
        return self:say("   ID x z")
    end
    self.master.resPlanetBag:buildMove2ResPlanet(index, buildId, {x=posX, z=posZ})
end

--- : 
---@usage
---: queryBoatRes
---: queryBoatRes
function cgm:queryBoatRes(args)
    if not self.master then
        return self:say("  ")
    end
    self.master.resPlanetBag:queryBoatRes()
end

--- : 
---@usage
---: pickBoatRes
---: pickBoatRes
function cgm:pickBoatRes(args)
    if not self.master then
        return self:say(" ")
    end
    self.master.resPlanetBag:pickBoatRes()
end

--- : 
---@usage
---: addBoatRes Id 
---: addBoatRes 101 100
function cgm:addBoatRes(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say("  Id ")
    end
    if not self.master then
        return self:say("  Id ")
    end
    local resCfgId = args[1]
    local count = args[2]
    self.master.resPlanetBag:addBoatCurrencyByGm(resCfgId, count)
end

--- : 
---@usage
---: addBuild2ResBoat ID  
---: addBuild2ResBoat 1301001 1
function cgm:addBuild2ResBoat(args)
    if not self.master then
        return self:say(":  ID  ")
    end
    local ok, args = gg.checkargs(args, "int", "*")
    if not ok then
        return self:say(":  ID  ")
    end
    local buildCfgId = args[1]
    local param = {}
    param.targetCfgId = buildCfgId
    param.targetQuality = 1
    param.targetLevel = 1
    param.skillLevel1 = 0
    param.skillLevel2 = 0
    param.skillLevel3 = 0
    param.skillLevel4 = 0
    param.skillLevel5 = 0
    param.num = 1
    if args[2] then
        param.targetQuality = tonumber(args[2])
    end
    if args[3] then
        param.targetLevel = tonumber(args[3])
    end
    local buildCfg = ggclass.Build.getBuildCfg(buildCfgId, param.targetQuality, param.targetLevel)
    if not buildCfg then
        return self:say(":  ID  ")
    end
    param.cfgId = buildCfg.itemCfgId
    self.master.resPlanetBag:addBoatBuildByGm(param)
end

--- : 
---@usage
---: beginAttackResPlanet 
---: beginAttackResPlanet 1
function cgm:beginAttackResPlanet(args)
    local ok, args = gg.checkargs(args, "int")
    if not ok then
        return self:say("  ")
    end
    local index = args[1]
    if not self.master then
        return self:say("  ")
    end
    self.master.resPlanetBag:beginAttackResPlanet(index)
end

--- : 
---@usage
---: endAttackResPlanet
---: endAttackResPlanet 1 1
function cgm:endAttackResPlanet(args)
    local ok, args = gg.checkargs(args, "int", "int")
    if not ok then
        return self:say("   ")
    end
    if not self.master then
        return self:say("   ")
    end
    local index = args[1]
    local result = args[2]
    self.master.resPlanetBag:endAttackResPlanet(index, result)
end

function __hotfix(module)
    gg.gm:hotfix_gm()
end