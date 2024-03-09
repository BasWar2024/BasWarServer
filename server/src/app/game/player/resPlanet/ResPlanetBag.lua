local ResPlanetBag = class("ResPlanetBag")

function ResPlanetBag:ctor(param)
    self.player = assert(param.player, "param.player is nil")
    self.boats = {} --repeat boats
    self.costResPacks = {}
    self.resPlanetIds = {}
    self.attackTick = 0   --
    self.attackResPlanetId = 0  --
    self.fightId = 0            --id
end

function ResPlanetBag:serialize()
    local data = {}
    data.boats = {}
    data.costResPacks = {}
    data.resPlanetIds = {}
    for k, v in pairs(self.boats) do
        table.insert(data.boats, v)
    end
    for k,v in pairs(self.costResPacks) do
        table.insert(data.costResPacks, v)
    end
    for id in pairs(self.resPlanetIds) do
        table.insert(data.resPlanetIds, id)
    end
    return data
end

function ResPlanetBag:deserialize(data)
    self.boats = {}
    self.costResPacks = {}
    if data.boats then
        for k, v in pairs(data.boats) do
            self.boats[v.boatId] = v
        end
    end
    if data.costResPacks then
        for k, v in pairs(data.costResPacks) do
            self.costResPacks[v.costId] = v
        end
    end
    if data.resPlanetIds then
        for k, v in pairs(data.resPlanetIds) do
            self.resPlanetIds[v] = true
        end
    end
end

function ResPlanetBag:syncPlanetData()
    local briefs = gg.bigmapMgr:queryAllResPlanetBrief(self.player.pid)
    if not briefs or not next(briefs) then
        return
    end
    self.resPlanetIds = {}
    for k, v in pairs(briefs) do
        if v.holdPlayerId == self.player.pid then
            self.resPlanetIds[v.index] = true
        end
    end
    self:updateMakeResRatio(self.player.pledgeBag:getMakeResRatioInfo())
end

function ResPlanetBag:updateMakeResRatio(ratioInfo)
    if not next(self.resPlanetIds) then
        return
    end
    gg.bigmapMgr:updateMakeResRatio(self.player.pid, ratioInfo)
end

function ResPlanetBag:createBoat(currencies, items)
    local data = {boatId=snowflake.uuid()}
    if currencies and next(currencies) then
        data.currencies = currencies
    end
    if items and next(items) then
        data.items = items
    end
    return data
end

function ResPlanetBag:addBoat(boat)
    if not boat then
        return
    end
    if not self.boats[boat.boatId] then
        self.boats[boat.boatId] = boat
    end
    local notifyBoats = self:getNotifyBoats()
    if notifyBoats and next(notifyBoats) then
        gg.client:send(self.player.linkobj,"S2C_Player_PickBoatResNotify", {boats = table.values(notifyBoats)})
    end
end

function ResPlanetBag:getNotifyBoats()
    local notifyBoats ={}
    if self.boats and next(self.boats) then
        for k, v in pairs(self.boats) do
            if (v.currencies and next(v.currencies)) or (v.items and next(v.items)) then
                notifyBoats[v.boatId] = v
            end
        end
    end
    return notifyBoats
end

--
function ResPlanetBag:addCurrency(resCfgId, count, source)
    local succCount = count
    if resCfgId == constant.RES_STARCOIN then
        if self.player.resBag:getRes(constant.RES_STARCOIN) + count > self.player.buildBag:getStoreStarCoin() then
            succCount = self.player.buildBag:getStoreStarCoin() - self.player.resBag:getRes(constant.RES_STARCOIN)
        end
    elseif resCfgId == constant.RES_ICE then
        if self.player.resBag:getRes(constant.RES_ICE) + count > self.player.buildBag:getStoreIce() then
            succCount = self.player.buildBag:getStoreIce() - self.player.resBag:getRes(constant.RES_ICE)
        end
    elseif resCfgId == constant.RES_CARBOXYL then
        if self.player.resBag:getRes(constant.RES_CARBOXYL) + count > self.player.buildBag:getStoreCarboxyl() then
            succCount = self.player.buildBag:getStoreCarboxyl() - self.player.resBag:getRes(constant.RES_CARBOXYL)
        end
    elseif resCfgId == constant.RES_TITANIUM then
        if self.player.resBag:getRes(constant.RES_TITANIUM) + count > self.player.buildBag:getStoreTitanium() then
            succCount = self.player.buildBag:getStoreTitanium() - self.player.resBag:getRes(constant.RES_TITANIUM)
        end
    elseif resCfgId == constant.RES_GAS then
        if self.player.resBag:getRes(constant.RES_GAS) + count > self.player.buildBag:getStoreGas() then
            succCount = self.player.buildBag:getStoreGas() - self.player.resBag:getRes(constant.RES_GAS)
        end
    end
    if succCount > 0 then
        self.player.resBag:addRes(resCfgId, succCount, source)
        return true, succCount
    end
    return false, 0
end

function ResPlanetBag:doPickBoatRes()
    local succBoats = {}
    local delItemIds = {}
    for _, boat in pairs(self.boats) do
        if boat.currencies and next(boat.currencies) then
            local delIndexs = {}
            for k, v in pairs(boat.currencies) do
                local ok, succCount = self:addCurrency(v.resCfgId, v.count, "pick boat res")
                if ok then
                    v.count = v.count - succCount
                    if v.count <= 0 then --
                        table.insert(delIndexs, k)
                    end
                    if succCount > 0 then
                        succBoats[boat.boatId] = succBoats[boat.boatId] or {boatId = boat.boatId, currencies={}, items = {}}
                        table.insert(succBoats[boat.boatId].currencies, {resCfgId=v.resCfgId, count=succCount})
                    end
                end
            end
            for _, index in pairs(delIndexs) do
                boat.currencies[index] = nil
            end
            if not next(boat.currencies) then
                boat.currencies = nil
            end
        end
        if boat.items and next(boat.items) then
            local delIndexs = {}
            for k, v in pairs(boat.items) do
                local item = self.player.itemBag:getItem(v.id)
                if not item then
                    local newItemParam = gg.deepcopy(v)
                    newItemParam.id = nil
                    local succCount = self.player.itemBag:addItem(v.cfgId, v.num, newItemParam, "pick item from boat")
                    if succCount > 0 then
                        v.num = v.num - succCount
                        succBoats[boat.boatId] = succBoats[boat.boatId] or {boatId = boat.boatId, currencies={}, items = {}}
                        local succItem = gg.deepcopy(v)
                        succItem.num = succCount
                        table.insert(succBoats[boat.boatId].items, succItem)
                    end
                else
                    v.num = 0
                    item:setAttr("curLife", v.curLife)
                    item:setRef(constant.ITEM_REF_NONE)
                    if item.curLife <= 0 then
                        table.insert(delItemIds, item.id)
                    end
                end
                if v.num == 0 then
                    table.insert(delIndexs, k)
                end
            end
            for _, index in pairs(delIndexs) do
                boat.items[index] = nil
            end
            if not next(boat.items) then
                boat.items = nil
            end
        end
    end
    for _, id in pairs(delItemIds) do
        self.player.itemBag:delItem(id, {reason = "resPlanet fight fail, cost curlife"})
    end

    if next(succBoats) then
        gg.client:send(self.player.linkobj,"S2C_Player_PickBoatRes", {boats = table.values(succBoats)})
    end

    local notifyBoats = self:getNotifyBoats()
    if next(notifyBoats) then
        gg.client:send(self.player.linkobj, "S2C_Player_PickBoatResNotify", {boats = table.values(notifyBoats)})
    end
end

-- ()
function ResPlanetBag:addBoatCurrencyByGm(resCfgId, count)
    local currencies = {{resCfgId=resCfgId, count=count}}
    local boat = self:createBoat(currencies)
    self:addBoat(boat)
end

-- ()
function ResPlanetBag:addBoatBuildByGm(itemParam)
    local item = self.player.itemBag:newItem(itemParam)
    if not item then
        return
    end
    local items = {item:pack()}
    local boat = self:createBoat(nil, items)
    self:addBoat(boat)
end

function ResPlanetBag:packSyncData()
    local data = {}
    data.boatIds = {}
    data.costIds = {}
    for k, v in pairs(self.boats) do
        table.insert(data.boatIds, v.boatId)
    end
    for k, v in pairs(self.costResPacks) do
        table.insert(data.costIds, v.costId)
    end
    return data
end

function ResPlanetBag:getResPlanetCfg(index)
    local resPlanetCfg = cfg.get("etc.cfg.resPlanet")
    return resPlanetCfg[index]
end

--
function ResPlanetBag:onBuildAdd(index, buildData)
    gg.client:send(self.player.linkobj,"S2C_Player_ResPlanet_BuildAdd", { build = buildData, index = index })
end

--
function ResPlanetBag:onBuildDel(index, buildId)
    gg.client:send(self.player.linkobj,"S2C_Player_ResPlanet_BuildDel", { buildId = buildId, index = index })
end

--
function ResPlanetBag:onBuildUpdate(index, buildData)
    gg.client:send(self.player.linkobj,"S2C_Player_ResPlanet_BuildUpdate", { build = buildData, index = index})
end

--
function ResPlanetBag:onAttackBegin(index, beginData)
    -- print("recv center onAttackBegin data=", table.dump(beginData))
    -- gg.client:send(self.player.linkobj, "S2C_Player_ResPlanetFightBegin", beginData)
end

--
function ResPlanetBag:onAttackEnd(index, endData)
    if endData and endData.isWin == constant.FIGHT_RESULT_WIN then
        self.resPlanetIds[index] = true
    end
    gg.client:send(self.player.linkobj, "S2C_Player_ResPlanetFightEnd", endData)
end

--
function ResPlanetBag:onResPlanetAdd(index)
    self.resPlanetIds[index] = true
end

--
function ResPlanetBag:onResPlanetDel(index)
    if self.resPlanetIds[index] then
        self.resPlanetIds[index] = nil
    end
end

-- id
--@param[type=integer]
function ResPlanetBag:getFightId()
    return self.fightId
end

-- 
--@param[type=integer]
function ResPlanetBag:getFightPlanet()
    return self.attackResPlanetId
end

-- 
--@param[type=table]
function ResPlanetBag:queryBoatRes()
    local notifyBoats = self:getNotifyBoats()
    if notifyBoats and next(notifyBoats) then
        gg.client:send(self.player.linkobj,"S2C_Player_PickBoatResNotify", {boats = table.values(notifyBoats)})
    end
end

-- 
--@param[type=table] ids id
function ResPlanetBag:pickBoatRes(ids)
    self:doPickBoatRes()
end

-- 
--@param[type=integer] index 
--@param[type=integer] id Id
--@param[type=table] pos 
--@return resData 
function ResPlanetBag:moveBuild(index, buildId, pos)
    local ok, msg = gg.bigmapMgr:moveBuild(self.player.pid, index, buildId, pos)
    if not ok then
        self.player:say(i18n.format(msg))
        return
    end
end

-- 
--@param[type=integer] index 
--@param[type=integer] id Id
--@return resData 
function ResPlanetBag:buildMove2ItemBag(index, buildId)
    local item = self.player.itemBag:getItem(buildId)
    if not item then
        self.player:say(i18n.format("you not have this item"))
        return false
    end
    -- --
    local ok, msg = gg.bigmapMgr:buildMove2ItemBag(self.player.pid, index, buildId)
    if not ok then
        self.player:say(i18n.format(msg))
        return false
    end
    item:setRef(constant.ITEM_REF_NONE)
    gg.client:send(self.player.linkobj,"S2C_Player_ItemUpdate",{item=item:pack()})
    return true
end

--
--@param[type=integer] index 
--@param[type=integer] itemId ID
--@param[type=integer] pos 
function ResPlanetBag:buildMove2ResPlanet(index, itemId, pos)
    local item = self.player.itemBag:getItem(itemId)
    if not item then
        self.player:say(i18n.format("item not exist"))
        return
    end
    if item:getRef() > constant.ITEM_REF_NONE then
        self.player:say(i18n.format("item use by other place"))
        return
    end
    if item.itemType ~= constant.ITEM_BUILD and item.itemType ~= constant.ITEM_MINING_MACHINE then
        self.player:say(i18n.format("item cannot move to res planet"))
        return
    end
    local cfg = ggclass.Build.getBuildCfg(item.targetCfgId, item.targetQuality, item.targetLevel)
    if not cfg then
        self.player:say(i18n.format("this build config is not exist"))
        return
    end
    local itemData = item:pack()
    local ok, msg = gg.bigmapMgr:buildMove2ResPlanet(self.player.pid, index, itemData, pos)
    if not ok then
        self.player:say(i18n.format(msg))
        return
    end
    item:setRef(constant.ITEM_REF_RESPLANET)
    gg.client:send(self.player.linkobj,"S2C_Player_ItemUpdate",{item=item:pack()})
end

-- ()
function ResPlanetBag:queryAllResPlanetBrief()
    local buildLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_PLANETARYEYE)
    local briefs = gg.bigmapMgr:queryAllResPlanetBrief(self.player.pid)
    if not briefs then
        return
    end
    local planets = {}
    for _, v in pairs(briefs) do
        local planetCfg = self:getResPlanetCfg(v.index)
        if buildLevel >= planetCfg.radarLevel then
            table.insert(planets, v)
        end
    end
    gg.client:send(self.player.linkobj, "S2C_Player_AllResPlanetBrief", { planets = planets })
    return briefs
end

-- 
--@param[type=integer] index 
function ResPlanetBag:lookResPlanet(index)
    local ok, msg  = gg.bigmapMgr:queryResPlanet(self.player.pid, index)
    if not ok then
        self.player:say(i18n.format(msg))
        return
    end
    local planetData = msg
    gg.client:send(self.player.linkobj, "S2C_Player_ResPlanetData", { planet = planetData} )
end

-- 
--@param[type=integer] index 
function ResPlanetBag:beginAttackResPlanet(index, fightId)
    fightId = fightId or snowflake.uuid()
    --
    local armyInfo = self.player.armyBag:getFightArmy()
    if not armyInfo.warShip then
        self.player:say(i18n.format("you need a warship"))
        return
    end
    if not armyInfo.soldiers or not next(armyInfo.soldiers) then
        self.player:say(i18n.format("you need train some soldiers"))
        return
    end

    --
    local playerInfo = {
        playerId = self.player.pid,
        playerName = self.player.name,
        playerLevel = self.player.level,
        playerScore = 0,
        resRatio = self.player.pledgeBag:getMakeResRatioInfo(),
    }
    local builds = self.player.buildBag:getBuildsByCfgId(constant.BUILD_BASE)
    local baseBuild = assert(builds[1], "base build not exist")
    local ok, msg  = gg.bigmapMgr:beginAttackResPlanet(self.player.pid, index, playerInfo, armyInfo, baseBuild:pack(), fightId)
    if not ok then
        self.player:say(i18n.format(msg))
        return
    end

    self.fightId = fightId
    local beginData = msg

    --
    return beginData
end

-- 
--@param[type=integer] index 
--@param[type=integer] result 
function ResPlanetBag:endAttackResPlanet(index, result, soldiers)
    if not index then
        self.player:say(i18n.format("battle is end"))
        return
    end
    if not ret then
        self.player:say(i18n.format("end battle need result"))
        return
    end
    local ok, msg  = gg.bigmapMgr:endAttackResPlanet(self.player.pid, index, result, soldiers)
    if not ok then
        self.player:say(i18n.format(msg))
        return
    end
    local endInfo = msg
    return endInfo
end

function ResPlanetBag:onload()
    self:syncPlanetData()
end

function ResPlanetBag:onlogin()
    self:queryBoatRes()
    gg.bigmapMgr:playerLogin(self.player.pid)
end

function ResPlanetBag:onlogout()
    gg.bigmapMgr:playerLogout(self.player.pid)
end

return ResPlanetBag