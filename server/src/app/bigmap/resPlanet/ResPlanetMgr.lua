local ResPlanetMgr = class("ResPlanetMgr")

function ResPlanetMgr:ctor(param)
    self.resPlanets = {} --
    self:initResPlanets()
end

function ResPlanetMgr:serialize()

end

function ResPlanetMgr:deserialize()

end

function ResPlanetMgr:playerLogin(pid)
    for k, resPlanet in pairs(self.resPlanets) do
        if resPlanet.holdPlayerId == pid then
            resPlanet:setHoldPlayerOnline(true)
        elseif resPlanet.attackPlayerId == pid then
            resPlanet:setAttackPlayerOnline(true)
        end
    end
end

function ResPlanetMgr:playerLogout(pid)
    for k, resPlanet in pairs(self.resPlanets) do
        if resPlanet.holdPlayerId == pid then
            resPlanet:setHoldPlayerOnline(false)
        elseif resPlanet.attackPlayerId == pid then
            resPlanet:setAttackPlayerOnline(false)
        end
    end
end

function ResPlanetMgr:createResPlanet(data)
    local resPlanet = ggclass.ResPlanet.create(data)
    return resPlanet
end

function ResPlanetMgr:initResPlanets()
    local resPlanetCfg = cfg.get("etc.cfg.resPlanet")
    local db = gg.dbmgr:getdb()
    for i, v in pairs(resPlanetCfg) do
        local resPlanet
        local resPlanetData = db.res_planet:findOne({index=v.index})
        if not resPlanetData then --
            resPlanet = self:createDefaultResPlanet(i, v)
            resPlanet.dirty = true
            resPlanet:save_to_db()
        else
            resPlanetData.resPlanetMgr = self
            resPlanet = self:createResPlanet(resPlanetData)
            if resPlanet then
                resPlanet:deserialize(resPlanetData)
            end
        end
        self.resPlanets[v.index] = resPlanet
        gg.savemgr:autosave(resPlanet)
    end
end

-- 
function ResPlanetMgr:createDefaultResPlanet(index, planetCfg)
    assert(planetCfg, "planet cfg is nil")
    assert(planetCfg.initPlayer, "planet cfg initPlayer is nil")
    local data = {
        resPlanetMgr = self,
        id = skynet.config.id,
        index = index,
        isOpen = planetCfg.isOpen or 0,
        x = planetCfg.pos.x,
        z = planetCfg.pos.z,
        quality = planetCfg.quality,
        holdPlayerName = planetCfg.initPlayer.name,
        holdPlayerId = 0,
        holdPlayerLevel = planetCfg.initPlayer.level,
        holdPlayerScore = planetCfg.initPlayer.score,
        holdBeginTick = skynet.timestamp(),
        makeStarCoinBuildTick = skynet.timestamp(),
        makeIceBuildTick = skynet.timestamp(),
        makeCarboxylBuildTick = skynet.timestamp(),
        makeTitaniumBuildTick = skynet.timestamp(),
        makeGasBuildTick = skynet.timestamp(),
        builds = {},
    }
    local resPlanet = ggclass.ResPlanet.create(data)
    assert(planetCfg.initPlayer.builds, "init player builds is nil")
    assert(next(planetCfg.initPlayer.builds), "init player builds is empty")
    for k, v in pairs(planetCfg.initPlayer.builds) do
        local build = resPlanet:generateBuild(v.cfgId, v.quality, v.level)
        if build then
            build:setNewPos(v.pos.x, v.pos.z)
            resPlanet:addBuild(build)
        end
    end
    return resPlanet
end

--
function ResPlanetMgr:getResPlanet(planetId)
    return self.resPlanets[planetId]
end

--
function ResPlanetMgr:moveBuild(playerId, planetId, buildId, pos)
    local resPlanet = self:getResPlanet(planetId)
    if not resPlanet then
        return false, "no this resPlanet"
    end
    if not resPlanet:isPlanetOpen() then
        return false, "resPlanet not open"
    end
    if not resPlanet:isPlayerHold(playerId) then
        return false, "player not hold this planet"
    end
    local build = resPlanet:getBuild(buildId)
    if not build then
        return false, "build not exist"
    end
    local cfg = ggclass.Build.getBuildCfg(build.cfgId, build.quality, build.level)
    if not cfg then
        return false, "cfg not found"
    end
    local oldPos = {x=build.x, z=build.z}
    local ret = resPlanet:canPutDown(oldPos, pos, cfg.length, cfg.width, build.cfgId)
    if not ret then
        return false, "pos can not put down"
    end
    local ok, buildData = resPlanet:moveBuild(buildId, pos)
    resPlanet:updateVer()
    return ok, buildData
end

function ResPlanetMgr:buildMove2ResPlanet(pid, index, itemData, pos)
    if not pid then
        return false, "pid is nil"
    end
    if not index then
        return false, "index is nil"
    end
    if not itemData then
        return false, "build item is nil"
    end
    if not pos then
        return false, "pos is nil"
    end
    local resPlanet = self.resPlanets[index]
    if not resPlanet then
        return false, "no this planet"
    end
    if not resPlanet:isPlanetOpen() then
        return false, "resPlanet not open"
    end
    if resPlanet.holdPlayerId ~= pid then
        return false, "you not hold this planet"
    end
    if resPlanet:isPlanetAttacking() then
        return false, "your planet is attacking"
    end
    local cfg = ggclass.Build.getBuildCfg(itemData.targetCfgId, itemData.targetQuality, itemData.targetLevel)
    if not cfg then
        return false, "cfg not found"
    end
    local ok = resPlanet:canPutDown(nil, pos, cfg.length, cfg.width, itemData.targetCfgId)
    if not ok then
        return false, "pos can not put down"
    end
    local build = resPlanet:newBuild({
        id = itemData.id,
        cfgId = itemData.targetCfgId,
        quality = itemData.targetQuality,
        level = itemData.targetLevel,
        life = itemData.life,
        curLife = itemData.curLife,
    })
    local newBuildData = resPlanet:putBuild(build, pos)
    resPlanet:updateVer()
    return true, newBuildData
end

function ResPlanetMgr:queryResPlanetBuild(pid, index, buildId)
    if not pid then
        return false, "pid is nil"
    end
    if not index then
        return false, "index is nil"
    end
    if not buildId then
        return false, "buildId is nil"
    end
    local resPlanet = self.resPlanets[index]
    if not resPlanet then
        return false, "no this planet"
    end
    if not resPlanet:isPlanetOpen() then
        return false, "resPlanet not open"
    end
    if resPlanet.holdPlayerId ~= pid then
        return false, "you not hold this planet"
    end
    if resPlanet:isPlanetAttacking() then
        return false, "your planet is attacking"
    end
    local build = resPlanet:getBuild(buildId)
    if not build then
        return false, "build not exist"
    end
    local itemParam = build:toItemParam()
    if not itemParam then
        return false, "build can not convert to item"
    end
    return true, itemParam
end

function ResPlanetMgr:buildMove2ItemBag(pid, index, buildId)
    if not pid then
        return false, "pid is nil"
    end
    if not index then
        return false, "index is nil"
    end
    if not buildId then
        return false, "buildId is nil"
    end
    local resPlanet = self.resPlanets[index]
    if not resPlanet then
        return false, "no this planet"
    end
    if not resPlanet:isPlanetOpen() then
        return false, "resPlanet not open"
    end
    if resPlanet.holdPlayerId ~= pid then
        return false, "you not hold this planet"
    end
    if resPlanet:isPlanetAttacking() then
        return false, "your planet is attacking"
    end
    local build = resPlanet:getBuild(buildId)
    if not build then
        return false, "build not exist"
    end
    local itemParam = build:toItemParam()
    if not itemParam then
        return false, "build can not convert to item"
    end
    resPlanet:delBuild(build)
    resPlanet:updateVer()
    return true, itemParam
end

--
function ResPlanetMgr:queryAllResPlanetBrief(pid)
    local briefs = {}
    for _, resPlanet in pairs(self.resPlanets) do
        if resPlanet:isPlanetOpen() then
            table.insert(briefs, resPlanet:packBrief())
        end
    end
    return briefs
end

--
function ResPlanetMgr:queryResPlanet(pid, index)
    if not pid then
        return false, "pid is nil"
    end
    if not index then
        return false, "index is nil"
    end
    local resPlanet = self.resPlanets[index]
    if not resPlanet then
        return false, "no this planet"
    end
    if not resPlanet:isPlanetOpen() then
        return false, "resPlanet not open"
    end
    return true, resPlanet:pack()
end

--
function ResPlanetMgr:beginAttackResPlanet(pid, index, playerInfo, armyInfo, baseBuild, fightId)
    print("beginAttackResPlanet 111")
    if not pid then
        return false, "pid is nil"
    end
    if not index then
        return false, "index is nil"
    end
    local resPlanet = self.resPlanets[index]
    if not resPlanet then
        return false, "no this planet"
    end
    if not resPlanet:isPlanetOpen() then
        return false, "resPlanet not open"
    end
    if not armyInfo then
        return false, "armyInfo is nil"
    end
    if not armyInfo.warShip then
        return false, "your army no warShip"
    end
    if not armyInfo.soldiers or not next(armyInfo.soldiers) then
        return false, "your army no soldiers"
    end
    if not baseBuild then
        return false, "baseBuild is nil"
    end
    --
    if resPlanet:isHoldPlayerOnline() then
        return false, "planet owner is online"
    end
    --
    if resPlanet:isPlanetAttacking() then
        return false, "others attacking planet"
    end
    return true, resPlanet:startAttack(playerInfo, armyInfo, baseBuild, fightId)
end

--
function ResPlanetMgr:endAttackResPlanet(pid, index, result, soldiers)
    if not pid then
        return false, "pid is nil"
    end
    if not index then
        return false, "index is nil"
    end
    if not result then
        return false, "result is nil"
    end
    local resPlanet = self.resPlanets[index]
    if not resPlanet then
        return false, "no this planet"
    end
    if not resPlanet:isPlanetOpen() then
        return false, "resPlanet not open"
    end
    if not resPlanet:isPlanetAttacking() then
        return false, "attack is end"
    end
    if resPlanet.attackPlayerId ~= pid then
        return false, "you not current attacker"
    end
    return true, resPlanet:endAttack(pid, result, soldiers)
end

function ResPlanetMgr:updateMakeResRatio(pid, ratioInfo)
    for index, resPlanet in pairs(self.resPlanets) do
        if resPlanet.holdPlayerId == pid then
            gg.sync:once_do("resPlanet_"..index, resPlanet.updateMakeResRatio, resPlanet, pid, ratioInfo)
        end
    end
    return true
end

--
function ResPlanetMgr:onSecond()
    for k, resPlanet in pairs(self.resPlanets) do
        resPlanet:makeRes()
        resPlanet:checkAttackTimeout()
    end
end

return ResPlanetMgr