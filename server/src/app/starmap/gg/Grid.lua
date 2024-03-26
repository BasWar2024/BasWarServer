local Grid = class("Grid")

function Grid.getPresetBuildLayoutCfg(presetLayoutId)
    if not presetLayoutId then
        return
    end
    local presetBuilds = nil
    local presetLayoutCfgs = cfg.get("etc.cfg.presetBuildLayout")
    for k, v in pairs(presetLayoutCfgs) do
        if v.cfgId == presetLayoutId then
            presetBuilds = v.presetBuilds
            break
        end
    end
    return presetBuilds
end

function Grid:ctor(gridId)
    self.dirty = false
    self.savetick = 300
    if constant.STARMAP_USE_RAND_TIME_SAVE then
        self.savetick = 900 + math.random(constant.STARMAP_RAND_SAVE_TIME_MIN, constant.STARMAP_RAND_SAVE_TIME_MAX)
    end
    self.savename = "Grid"
    self.cfgId = gridId

    -- ""
    self.carboxyl = 0 -- ""
    self.res = {}
    self.makeResTick = 0
    self.makeContriTick = 0
    self.shareTick = 0
    self.makeScoreTick = 0
    self.makeScoreCount = 0
    self.builds = {}
    self.owner = nil
    self.status = 0 -- 0."" 1."" 2.""
    self.protectEndTick = 0 -- ""
    self.battleEndTick = 0 -- ""
    self.canGiveUpTick = 0 -- ""
end

function Grid:getGridCfg()
    local key = self.cfgId
    local cfg = gg.getExcelCfg("starmapConfig")[key]
    return cfg
end

function Grid:createPresetBuilds()
    local gridCfg = self:getGridCfg()
    assert(gridCfg, "gridCfg not exist")
    local builds = {}
    if gridCfg.presetLayoutId then
        local presetBuilds = Grid.getPresetBuildLayoutCfg(gridCfg.presetLayoutId)
        for _, v in pairs(presetBuilds) do
            local buildData = {
                cfgId = v.cfgId,
                quality = v.quality,
                level = v.level,
                x = v.x,
                z = v.z,
                life = v.life,
                curLife = v.curLife
            }
            local build = self:createBuild(buildData)
            builds[build.id] = build
        end
    end
    return builds
end

function Grid:createCaptureBuilds()
    local gridCfg = self:getGridCfg()
    assert(gridCfg, "gridCfg not exist")
    local builds = {}
    if gridCfg.captureLayoutId then
        local layoutBuilds = Grid.getPresetBuildLayoutCfg(gridCfg.captureLayoutId)
        for _, v in pairs(layoutBuilds) do
            local buildData = {
                cfgId = v.cfgId,
                quality = v.quality,
                level = v.level,
                x = v.x,
                z = v.z,
                life = v.life,
                curLife = v.curLife
            }
            local build = self:createBuild(buildData)
            builds[build.id] = build
        end
    end
    return builds
end

function Grid:initOwner()
    self.owner = {}
    self.owner.playerId = 0
    self.owner.playerScore = 0
    self.owner.playerLevel = 1
    self.owner.playerName = ""
    self.owner.playerHead = ""
    self.owner.unionName = ""
    self.owner.unionId = 0
    self.owner.unionFlag = 0
    self.owner.presidentName = ""
    self.owner.isPrivate = false
end

function Grid:createOwner(info)
    local newOwner = {}
    newOwner.playerId = info.playerId
    newOwner.playerScore = info.playerScore
    newOwner.playerLevel = info.playerLevel
    newOwner.playerName = info.playerName
    newOwner.playerHead = info.playerHead
    newOwner.unionName = info.unionName
    newOwner.unionId = info.unionId
    newOwner.unionFlag = info.unionFlag
    newOwner.presidentName = info.presidentName
    newOwner.isPrivate = info.isPrivate
    return newOwner
end

function Grid:init()
    local gridCfg = self:getGridCfg()
    assert(gridCfg, "gridCfg not exist")
    local startTime = os.time()
    local ok = self:load_from_db()
    if not ok then
        self:initOwner()
        self.builds = self:createPresetBuilds()
        self.dirty = true
        self:save_to_db()
    end
end

function Grid:createBuild(data)
    return ggclass.Build.create(data)
end

function Grid:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    gg.mongoProxy.starmap:update({
        cfgId = self.cfgId
    }, data, true, false)
    self.dirty = false
end

function Grid:load_from_db()
    local data = gg.mongoProxy.starmap:findOne({
        cfgId = self.cfgId
    })
    if not data then
        return false
    end
    self:deserialize(data)
    return true
end

function Grid:deserialize(data)
    if not data then
        return
    end
    if data.builds and next(data.builds) then
        for _, v in pairs(data.builds) do
            local build = self:createBuild(v)
            if build then
                build:deserialize(v)
                self.builds[build.id] = build
            end
        end
    end
    self.carboxyl = data.carboxyl or 0
    for k, v in pairs(data.res or {}) do
        self.res[tonumber(k)] = v
    end
    self.makeResTick = data.makeResTick or 0
    self.makeContriTick = data.makeContriTick or 0
    self.shareTick = data.shareTick or 0
    self.makeScoreTick = data.makeScoreTick or 0
    self.makeScoreCount = data.makeScoreCount or 0
    self.status = data.status or 0
    self.owner = data.owner
    self.battleEndTick = data.battleEndTick or 0
    self.protectEndTick = data.protectEndTick or 0
    self.canGiveUpTick = data.canGiveUpTick or 0
end

function Grid:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.carboxyl = self.carboxyl
    data.res = {}
    for k, v in pairs(self.res) do
        data.res[tostring(k)] = v
    end
    data.makeResTick = self.makeResTick
    data.makeContriTick = self.makeContriTick
    data.shareTick = self.shareTick
    data.makeScoreTick = self.makeScoreTick
    data.makeScoreCount = self.makeScoreCount
    data.owner = self.owner
    data.status = self.status
    data.battleEndTick = self.battleEndTick
    data.protectEndTick = self.protectEndTick
    data.canGiveUpTick = self.canGiveUpTick
    data.nowTimestamp = os.time()
    data.builds = {}
    for k, v in pairs(self.builds) do
        table.insert(data.builds, v:serialize())
    end
    return data
end

function Grid:isPosValid(pos)
    local sceneId = self:getSceneId(self.cfgId)
    local battleMapCfg = gg.getExcelCfg("battleMap")[sceneId]
    local minX = constant.MAP_GRID_MIN
    local minZ = constant.MAP_GRID_MIN
    local maxX = (battleMapCfg.length / 1000) + 5
    local maxZ = (battleMapCfg.width / 1000) + 5
    if pos.x < minX or pos.x > maxX or pos.z < minZ or pos.z > maxZ then
        return false
    end
    return true
end

function Grid:getBattleBuilds()
    local builds = {}
    for k, v in pairs(self.builds) do
        local pos = {x = v.x, z = v.z}
        if self:isPosValid(pos) then
            table.insert(builds, v:pack())
        end
    end
    return builds
end

function Grid:hasUnionCount()
    return 0
end

function Grid:isBeginGrid()
    return false
end

function Grid:isPrivate()
    return self.owner.playerId ~= 0 and self.owner.isPrivate
end

function Grid:isUnion()
    return (not self:isPrivate() and self.owner.unionId ~= 0)
end

function Grid:isNatural()
    return self.owner.playerId == 0
end

function Grid:isBelongTypePersonal()
    local gridCfg = self:getGridCfg()
    return gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF
end

function Grid:isBelongTypeUnion()
    local gridCfg = self:getGridCfg()
    return gridCfg.belongType == constant.STARMAP_BELONG_TYPE_UNION
end

function Grid:isBelongToSomeBody(pid)
    return self.owner.playerId == pid and self:isPrivate()
end

function Grid:resetRes()
    self.carboxyl = 0
    self.res = {}
end

function Grid:resetScoreCount()
    self.makeScoreCount = 0
end

function Grid:updateOwnerInfo(pid, unionId, playerName)
    if self.owner.playerId == pid then
        if self.owner.playerName ~= playerName then
            self.owner.playerName = playerName
            self.dirty = true
        end
    end
    if self:isBelongToSomeBody(pid) then
        if self.owner.unionId ~= unionId then
            self.owner.unionName = ""
            self.owner.unionId = 0
            self.owner.unionFlag = 0
            self.owner.presidentName = ""
            self.dirty = true
        end
    end
end

-----------------------------------------------
function Grid:packBelong(pid, unionId)
    if not self.owner then
        return constant.STARMAP_BELONG_NONE
    end
    if self.owner.playerId == 0 then
        return constant.STARMAP_BELONG_NONE
    end
    if self.owner.playerId == pid and self:isPrivate() then
        return constant.STARMAP_BELONG_SELF
    end
    if self.owner.unionId and self.owner.unionId ~= 0 and self.owner.unionId == unionId then
        return constant.STARMAP_BELONG_SELF_UNION
    end
    return constant.STARMAP_BELONG_OTHER
end

function Grid:calcProtectLessTime()
    local nowTimestamp = skynet.timestamp()
    if self.protectEndTick == 0 or nowTimestamp > self.protectEndTick then
        return 0
    end
    return math.floor((self.protectEndTick - nowTimestamp) / 1000)
end

function Grid:packBuild(buildInfo)
    local data = {}
    data.id = buildInfo.id
    data.cfgId = buildInfo.cfgId
    data.level = buildInfo.level
    data.quality = buildInfo.quality
    data.life = buildInfo.life
    data.curLife = buildInfo.curLife
    data.pos = Vector3.New(buildInfo.x, 0, buildInfo.z)
    data.chain = buildInfo.chain
    data.isNormal = buildInfo.isNormal
    return data
end

function Grid:packBuilds()
    local builds = {}
    if not self.builds then
        return builds
    end
    for k, v in pairs(self.builds) do
        table.insert(builds, self:packBuild(v))
    end
    return builds
end

-- ""
function Grid:packGridBrief(pid, unionId)
    local data = {}
    data.cfgId = self.cfgId
    data.status = self.status
    data.belong = self:packBelong(pid, unionId)
    data.owner = self.owner
    data.unionNum = self:hasUnionCount()
    data.isFavorite = 0
    data.battleEndTick = math.floor(self.battleEndTick / 1000)
    data.protectTime = math.floor(self.protectEndTick / 1000)  --self:calcProtectLessTime()
    return data
end

function Grid:getSceneId(gridCfgId)
    local sceneId = 1
    local cfg = gg.getExcelCfg("starmapConfig")[gridCfgId]
    if not cfg then
        return sceneId
    end
    local presetLayoutId = cfg.presetLayoutId
    if presetLayoutId then
        local pblCfg = gg.getExcelCfg("presetBuildLayout")
        if pblCfg[presetLayoutId] then
            sceneId = pblCfg[presetLayoutId].sceneId
        end
    end
    return sceneId
end

-- ""
function Grid:packDetail(pid, unionId)
    local data = {}
    data.cfgId = self.cfgId
    data.status = self.status
    data.belong = self:packBelong(pid, unionId)
    data.carboxyl = self.carboxyl
    data.owner = self.owner
    data.attackers = self.attackers
    data.protectTime = math.floor(self.protectEndTick / 1000)  --self:calcProtectLessTime()
    data.builds = self:packBuilds()
    data.sceneId = self:getSceneId(self.cfgId)
    return data
end

-- ""
function Grid:packGridMini(pid, unionId)
    local data = {}
    data.cfgId = self.cfgId
    data.status = self.status
    data.belong = self:packBelong(pid, unionId)
    data.unionName = self.owner.unionName
    return data
end
-----------------------------------------------

-- ""
function Grid:canPutdown(buildId, oldPos, newPos, length, width)
    if not self:isPosValid(newPos) then
        return false
    end
    buildId = buildId or 0
    local newRect = {
        id = buildId,
        x = newPos.x,
        z = newPos.z,
        length = length,
        width = width
    }
    local overlapBuilds = {}
    for k, v in pairs(self.builds) do
        if v.id ~= buildId then
            if math.isRectOverlap(newRect, v) then -- ""
                table.insert(overlapBuilds, v)
            end
        end
    end
    
    if #overlapBuilds > 1 then
        return false
    elseif #overlapBuilds == 0 then
        return true
    end
    local overlapBuild = overlapBuilds[1]
    if oldPos and oldPos.x > 0 and oldPos.z > 0 then -- ""
        local overlapBuildRect = {
            id = overlapBuild.id,
            x = oldPos.x,
            z = oldPos.z,
            length = overlapBuild.length,
            width = overlapBuild.width
        }
        for k, v in pairs(self.builds) do
            if v.id ~= overlapBuildRect.id then
                if v.id == buildId then
                    if math.isRectOverlap(newRect, overlapBuildRect) then
                        return false
                    end
                else
                    if math.isRectOverlap(overlapBuildRect, v) then
                        return false
                    end
                end
            end
        end
        return true, overlapBuild
    else
        return false
    end
end

function Grid:putBuild(pid, buildId, pos, unionId)
    if self:isNatural() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    local gridCfg = self:getGridCfg()
    local plyBuildCount = self:getPlyBuildCount()
    if plyBuildCount >= gridCfg.towerCount then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_PLY_BUILD_LIMIT))
        return
    end

    local itemInfo
    local ownerPid
    if self:isPrivate() then
        if self.owner.playerId ~= pid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
            return
        end

        -- ""
        local nftInfo = gg.playerProxy:call(pid, "getNftItemOnGrid", self.cfgId, buildId)
        if not nftInfo then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
            return
        end
        local buildCfg = gg.getExcelCfgByFormat("buildConfig", nftInfo.cfgId, nftInfo.quality, nftInfo.level)
        if not buildCfg then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
            return
        end
        local ok = self:canPutdown(nil, nil, pos, buildCfg.length, buildCfg.width)
        if not ok then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.POS_ERR))
            return
        end

        itemInfo = gg.playerProxy:call(pid, "useNftItemOnGrid", self.cfgId, buildId)
        itemInfo.ownerPid =  itemInfo.ownerPid or pid
        if not itemInfo then
            return
        end
    elseif self:isUnion() then
        --""
        if unionId ~= self.owner.unionId then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
            return
        end
        --""
        local ret = gg.unionProxy:call("checkUnionJobCanPutBuild", self.owner.unionId, pid)
        if not ret then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
            return
        end
        --""nft""
        local nftInfo = gg.unionProxy:call("getNftInfo", self.owner.unionId, buildId)
        if not nftInfo then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
            return
        end
        local result = self:getChainExclusiveGrids()
        local gridchain = result[self.cfgId]
        if gridchain and nftInfo.chain ~= gridchain then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_MUST_PUT_EXCLUSIVE_DEFENSE))
            return
        end
        local buildCfg = gg.getExcelCfgByFormat("buildConfig", nftInfo.cfgId, nftInfo.quality, nftInfo.level)
        if not buildCfg then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
            return
        end
        local ok = self:canPutdown(nil, nil, pos, buildCfg.length, buildCfg.width)
        if not ok then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.POS_ERR))
            return
        end

        itemInfo = gg.unionProxy:call("starMapTakeNft", self.owner.unionId, buildId, self.cfgId)
        if not itemInfo then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
            return
        end
    else
        return
    end
    local buildData = itemInfo
    if not buildData then
        return
    end
    local build = self:createBuild(buildData)
    if not build then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_CREATE_ERR))
        return
    end
    build.ownerPid = itemInfo.ownerPid
    build:setNewPos(pos.x, pos.z)
    self.builds[build.id] = build
    self.dirty = true
    local buildPack = build:pack()
    
    local builds = {}
    table.insert(builds, {buildId = itemInfo.id, cfgId = self.cfgId})
    gg.playerProxy:send(build.ownerPid, "updateBuildRefBy", builds)

    gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridAdd", {
        cfgId = self.cfgId,
        build = buildPack
    })
end

function Grid:putBuildList(pid, buildList, unionId, from)
    if self:isNatural() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    local gridCfg = self:getGridCfg()
    local plyBuildCount = self:getPlyBuildCount()
    if plyBuildCount >= gridCfg.towerCount then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_PLY_BUILD_LIMIT))
        return
    end

    local freeSpace = gridCfg.towerCount - plyBuildCount
    local getBuildIds = {}
    local getBuildDict = {}
    for i = 1, freeSpace, 1 do
        local _build = buildList[i]
        if _build then
            table.insert(getBuildIds, _build.id)
            getBuildDict[_build.id] = _build.pos
        end
    end
    local itemInfo
    local ownerPid
    local builds = {}
    if self:isPrivate() then
        if from ~= constant.STARMAP_TO_GRID_BUILD_PERSON then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_TO_GRID_BUILD_TYPE_ERR))
            return
        end
        if self.owner.playerId ~= pid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
            return
        end

        -- ""
        local buildObjList = gg.playerProxy:call(pid, "getBuildListToGrid", self.cfgId, getBuildIds)
        if not buildObjList or table.count(buildObjList) ==0 then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
            return
        end
        --""getBuildIds
        local buildObjDict = {}
        getBuildIds = {}
        for i, v in ipairs(buildObjList) do
            table.insert(getBuildIds, v.id)
            buildObjDict[v.id] = v
        end
        local failBuildIds = {}
        local useBuildIds = gg.playerProxy:call(pid, "useBuildListToGrid", self.cfgId, getBuildIds)
        for i, v in ipairs(useBuildIds) do
            local isSucce = false
            local buildObj = buildObjDict[v]
            local buildCfg = gg.getExcelCfgByFormat("buildConfig", buildObj.cfgId, buildObj.quality, buildObj.level)
            if buildCfg then
                local pos = getBuildDict[buildObj.id]
                local ok = self:canPutdown(nil, nil, pos, buildCfg.length, buildCfg.width)
                if ok then
                    buildObj.ref = constant.REF_GRID
                    buildObj.refBy = self.cfgId
                    buildObj.ownerPid =  buildObj.ownerPid or pid

                    local build = self:createBuild(buildObj)
                    if build then
                        build.ownerPid = buildObj.ownerPid
                        build:setNewPos(pos.x, pos.z)
                        self.builds[build.id] = build
                        self.dirty = true
                        local buildPack = build:pack()

                        builds[build.ownerPid] = builds[build.ownerPid] or {}
                        table.insert(builds[build.ownerPid], {buildId = build.id, cfgId = build.refBy})
                        gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridAdd", {
                            cfgId = self.cfgId,
                            build = buildPack
                        })
                        isSucce = true
                    end
                end
            end
            if not isSucce then
                table.insert(failBuildIds, v)
            end
        end
        --""nft""
        if table.count(failBuildIds) > 0 then
            local notUseNftIds = gg.playerProxy:call(pid, "notUseBuildListToGrid", self.cfgId, failBuildIds)
        end
    elseif self:isUnion() then
        if from ~= constant.STARMAP_TO_GRID_BUILD_UNION then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_TO_GRID_BUILD_TYPE_ERR))
            return
        end
        --""
        if unionId ~= self.owner.unionId then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
            return
        end
        --""
        local ret = gg.unionProxy:call("checkUnionJobCanPutBuild", self.owner.unionId, pid)
        if not ret then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
            return
        end
        --""nft""
        local nftList = gg.unionProxy:call("getNftList", self.owner.unionId, getBuildIds)
        if not nftList or table.count(nftList) ==0 then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
            return
        end

        local exclusiveGrids = self:getChainExclusiveGrids()
        local nftDict = {}
        local nftBuildIds = {}
        for i, v in ipairs(nftList or {}) do
            local gridchain = exclusiveGrids[self.cfgId]
            if not gridchain or v.chain == gridchain then
                table.insert(nftBuildIds, v.id)
                nftDict[v.id] = v
            end
        end
        local failNftIds = {}
        local useNftIds = gg.unionProxy:call("starMapUseNftListToGrid", self.owner.unionId, nftBuildIds, self.cfgId)
        
        for i, v in ipairs(useNftIds) do
            local isSucce = false
            local nft = nftDict[v]
            local buildCfg = gg.getExcelCfgByFormat("buildConfig", nft.cfgId, nft.quality, nft.level)
            if buildCfg then
                local pos = getBuildDict[nft.id]
                local ok = self:canPutdown(nil, nil, pos, buildCfg.length, buildCfg.width)
                if ok then
                    nft.refBy = self.cfgId
                    local build = self:createBuild(nft)
                    if build then
                        build.ownerPid = nft.ownerPid
                        build:setNewPos(pos.x, pos.z)
                        self.builds[build.id] = build
                        self.dirty = true
                        local buildPack = build:pack()

                        builds[build.ownerPid] = builds[build.ownerPid] or {}
                        table.insert(builds[build.ownerPid], {buildId = build.id, cfgId = build.refBy})
                        gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridAdd", {
                            cfgId = self.cfgId,
                            build = buildPack
                        })
                        isSucce = true
                    end
                end
            end
            if not isSucce then
                table.insert(failNftIds, v)
            end
        end
        --""nft""
        if table.count(failNftIds) > 0 then
            local notUseNftIds = gg.unionProxy:call("starMapNotUseNftListToGrid", self.owner.unionId, failNftIds, self.cfgId)
        end
        for pid,v in pairs(builds) do
            gg.playerProxy:send(pid, "updateBuildRefBy", v)
        end
        
    else
        return
    end
end

function Grid:getChainExclusiveGrids()
    local exclusiveDict = gg.dynamicCfg:get(constant.REDIS_STARMAP_CHAIN_EXCLUSIVE)
    local result = {}
    for k,v in pairs(exclusiveDict) do
        local cfgId = math.floor(tonumber(k) or 0)
        local chain = math.floor(tonumber(v) or 0)
        if cfgId > 0 then
            result[cfgId] = chain
        end
    end
    return result
end

function Grid:addDefenselBuild(pid, buildId, pos, unionId)
    -- ""
    if self:isNatural() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    local gridCfg = self:getGridCfg()
    local plyBuildCount = self:getPlyBuildCount()
    if plyBuildCount >= gridCfg.towerCount then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_PLY_BUILD_LIMIT))
        return
    end
    local buildData =  gg.unionProxy:call("getUnionDefenseBuild", pid, unionId, buildId)
    if not buildData then
        return
    end
    local buildCfg = gg.getExcelCfgByFormat("buildConfig", buildId, 0, buildData.level)
    if not buildCfg then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NORMAL_NOT_AVALIABLE))
        return
    end
    if buildCfg.belong ~= constant.BUILD_BELONG_UNION then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_BUILD_BELONG_ERR))
        return
    end
    local ok = self:canPutdown(nil, nil, pos, buildCfg.length, buildCfg.width)
    if not ok then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.POS_ERR))
        return
    end
    local costResDict = {}
    for i, v in ipairs(buildCfg.gridBuildCostRes or {}) do
        costResDict[v[1]] = v[2]
    end

    local build
    if self:isPrivate() then
        if self.owner.playerId ~= pid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
            return
        end
        local isEnough = gg.playerProxy:call(pid, "isResDictEnough", costResDict)
        if not isEnough then
            return
        end
        build = self:createBuild(buildData)
        if not build then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_CREATE_ERR))
            return
        end
        local isOk = gg.playerProxy:call(pid, "costResDict", costResDict, gamelog.GRID_BUILD_CREATE)
        if not isOk then
            return
        end
    elseif self:isUnion() then
        --""
        if unionId ~= self.owner.unionId then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
            return
        end
        --""
        local ret = gg.unionProxy:call("checkUnionJobCanPutBuild", self.owner.unionId, pid)
        if not ret then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
            return
        end
        local isEnough = gg.unionProxy:call("isUnionResDictEnough", unionId, costResDict, pid)
        if not isEnough then
            return
        end
        build = self:createBuild(buildData)
        if not build then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_CREATE_ERR))
            return
        end
        local isOk = gg.unionProxy:call("costUnionResDict", unionId, costResDict, pid)
        if not isOk then
            return
        end
    else
        return
    end
    build:setNewPos(pos.x, pos.z)
    build.isNormal = true
    self.builds[build.id] = build
    self.dirty = true
    local buildPack = build:pack()
    gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridAdd", {
        cfgId = self.cfgId,
        build = buildPack
    })
end

function Grid:getPlyBuildCount()
    local count = 0
    for k, build in pairs(self.builds) do
        if build.isNormal then
            count = count + 1
        end
        if build.chain > 0 then
            count = count + 1
        end
    end
    return count
end

function Grid:moveBuild(pid, buildId, pos)
    if self:isNatural() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    if not pos then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.POS_ERR))
        return
    end
    local build = self.builds[buildId]
    if not build then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if self:isPrivate() then
        if self.owner.playerId ~= pid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
            return
        end
    elseif self:isUnion() then
        --""
        local playerUnionId = gg.unionProxy:call("getUnionIdByPid", pid)
        if playerUnionId ~= self.owner.unionId then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
            return
        end
        --""
        local ret = gg.unionProxy:call("checkUnionJobCanPutBuild", self.owner.unionId, pid)
        if not ret then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
            return
        end
    else
        return
    end
    local oldPos = {
        x = build.x,
        z = build.z
    }
    local ok, overlapBuild = self:canPutdown(buildId, oldPos, pos, build.length, build.width)
    if not ok then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.POS_ERR))
        return
    end
    if overlapBuild then
        overlapBuild:setNewPos(oldPos.x, oldPos.z)
    end
    build:setNewPos(pos.x, pos.z)
    self.dirty = true
    gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridUpdate", {
        cfgId = self.cfgId,
        buildId = buildId,
        pos = pos
    })
    if overlapBuild then
        local tPos = {
            x = overlapBuild.x,
            y = overlapBuild.y,
            z = overlapBuild.z
        }
        gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridUpdate", {
            cfgId = self.cfgId,
            buildId = overlapBuild.id,
            pos = tPos
        })
    end

    --[[
    if not self.owner then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    if self.owner.playerId ~= pid then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    if not pos then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.POS_ERR))
        return
    end
    local build = self.builds[buildId]
    if not build then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    local oldPos = {
        x = build.x,
        z = build.z
    }
    local ok, overlapBuild = self:canPutdown(buildId, oldPos, pos, build.length, build.width)
    if not ok then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.POS_ERR))
        return
    end
    if overlapBuild then
        overlapBuild:setNewPos(oldPos.x, oldPos.z)
    end
    build:setNewPos(pos.x, pos.z)
    gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridUpdate", {
        cfgId = self.cfgId,
        buildId = buildId,
        pos = pos
    })
    if overlapBuild then
        local tPos = {
            x = overlapBuild.x,
            y = overlapBuild.y,
            z = overlapBuild.z
        }
        gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridUpdate", {
            cfgId = self.cfgId,
            buildId = overlapBuild.id,
            pos = tPos
        })
    end
    ]]
end

function Grid:delBuild(pid, buildId)
    if self:isNatural() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    local build = self.builds[buildId]
    if not build then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end

    if build.cfgId == constant.BUILD_BASE then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_BASE_CANNOT_DELETE))
        return
    end

    if build.chain > 0 then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_CANNOT_DELETE))
        return
    end
    if self:isPrivate() then
        if self.owner.playerId ~= pid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
            return
        end
    elseif self:isUnion() then
        --""
        local playerUnionId = gg.unionProxy:call("getUnionIdByPid", pid)
        if playerUnionId ~= self.owner.unionId then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
            return
        end
        --""
        local ret = gg.unionProxy:call("checkUnionJobCanPutBuild", self.owner.unionId, pid)
        if not ret then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
            return
        end
    else
        return
    end
    self.builds[buildId] = nil
    self.dirty = true
    gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridDel", {
        cfgId = self.cfgId,
        buildId = buildId
    })
end

function Grid:storeBuild(pid, buildId)
    if self:isNatural() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    local build = self.builds[buildId]
    if not build then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if build.chain <= 0 then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_IS_NOT_NFT))
        return
    end
    if self:isPrivate() then
        if self.owner.playerId ~= pid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
            return
        end
        --""
        gg.playerProxy:call(pid, "storeNftItemInBag", self.cfgId, {[buildId] = build:serialize()})
    elseif self:isUnion() then
        --""
        local playerUnionId = gg.unionProxy:call("getUnionIdByPid", pid)
        if playerUnionId ~= self.owner.unionId then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
            return
        end
        --""
        local ret = gg.unionProxy:call("checkUnionJobCanPutBuild", self.owner.unionId, pid)
        if not ret then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
            return
        end
        --""
        gg.unionProxy:call("starMapBackNfts", self.owner.unionId, {[buildId] = build:serialize()})
    else
        return
    end

    self.builds[buildId] = nil
    self.dirty = true
    gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridDel", {
        cfgId = self.cfgId,
        buildId = buildId
    })
end

function Grid:storeUnionNft(pid, unionId, buildId)
    local build = self.builds[buildId]
    if not build then
        return false
    end
    if build.chain <= 0 then
        return false
    end
    self.builds[buildId] = nil
    self.dirty = true
    --[[
    gg.centerProxy:send2Client(pid, "S2C_Player_buildOnGridDel", {
        cfgId = self.cfgId,
        buildId = buildId
    })
    ]]
    return build:serialize()
end

function Grid:giveUpMyGrid(pid)
    if self:isNatural() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    if self.status == constant.STARMAP_GRID_STATUS_BATTLE then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_STATUS_BATTLE))
        return
    end
    if self.status == constant.STARMAP_GRID_STATUS_PROTECT then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_STATUS_PROTECT))
        return
    end
    local nowTick = skynet.timestamp()
    if self.canGiveUpTick > nowTick then
        local needTime = math.floor((self.canGiveUpTick - nowTick) / 1000)
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_CAN_NOT_GIVE_UP, needTime))
        return
    end
    if self:isPrivate() then
        if self.owner.playerId ~= pid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
            return
        end
        --""
        self:_storeNftBuilds()
        gg.playerProxy:send(pid, "onStarmapMyGridDel", self.cfgId)
    elseif self:isUnion() then
        --""
        local playerUnionId = gg.unionProxy:call("getUnionIdByPid", pid)
        if playerUnionId ~= self.owner.unionId then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
            return
        end
        --""
        local ret = gg.unionProxy:call("checkUnionJobCanPutBuild", self.owner.unionId, pid)
        if not ret then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
            return
        end
        --""
        self:_storeNftBuilds()
        gg.unionProxy:send("unsetGridOwner", self.owner.playerId, self.owner.unionId, self.cfgId)
        gg.playerProxy:send(pid, "onStarmapUnionGridDel", self.cfgId)
    else
        return
    end
    self.status = constant.STARMAP_GRID_STATUS_IDLE
    self:resetRes()
    self:resetScoreCount()
    self:changeOwner()
    self.dirty = true
    gg.centerProxy:broadCast2Game("onGridUpdate", "", self.cfgId, self:serialize())
end

function Grid:giftWithMyGrid(pid, toPid)
    if not self.owner then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    if self.owner.playerId ~= pid then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_OWNER_NOT_YOU))
        return
    end
    if self.owner.unionId == 0 then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_JOIN_UNION))
        return
    end
    if self.status == constant.STARMAP_GRID_STATUS_BATTLE then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_STATUS_BATTLE))
        return
    end
    local memberInfo = gg.unionProxy:call("getUnionMember", pid, self.owner.unionId, toPid)
    if not memberInfo then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_JOIN_UNION))
        return
    end
    self.status = constant.STARMAP_GRID_STATUS_IDLE
    local nftBuilds = self:getNftBuilds()
    local newOwner = self:createOwner(memberInfo)
    self:changeOwner(newOwner)
    self.dirty = true
    gg.playerProxy:send(pid, "onStarmapMyGridDel", self.cfgId)
    gg.playerProxy:send(toPid, "onStarmapMyGridAdd", self.cfgId, self:packGridBrief(toPid, self.owner.unionId), self.carboxyl, self.res)
end

function Grid:setBattleTick(defender)
    local battleCostTime
    if self:isBelongTypeUnion() then
        battleCostTime = gg.getGlobalCfgIntValue("LeagueBattleTime", 480)
    elseif self:isBelongTypePersonal() then
        battleCostTime = gg.getGlobalCfgIntValue("LeaguePersonBattleTime", 300)
    end
    self.battleEndTick = skynet.timestamp() + battleCostTime * 1000

    self.status = constant.STARMAP_GRID_STATUS_BATTLE
    gg.centerProxy:broadCast2Game("onGridUpdate", "onBattleStart", self.cfgId, self:serialize())

    if self:isUnion() then
        local gridCfg = self:getGridCfg()
        gg.chatProxy:sendSysMsg({
            channelType = constant.CHAT_CHANNEL_UNION,
            text = "Your "..gridCfg.name.."(".."x:"..gridCfg.pos.x.."y:"..gridCfg.pos.y..")".." is being attacked",
            unionId = self.owner.unionId,
            unionName = self.owner.unionName,
        })
    end
end

function Grid:setProtectTick()
    self.battleEndTick = 0
    self.canGiveUpTick = 0
    local abandonGridCD = gg.getGlobalCfgIntValue("HyAbandonGridCD", 15000)
    local protectTime = gg.getGlobalCfgIntValue("GridProtectTime", 3600)
    if self:isBelongTypePersonal() then  -- ""
        protectTime = gg.getGlobalCfgIntValue("GridPersonProtectTime", 3600)
        abandonGridCD = gg.getGlobalCfgIntValue("ResAbandonGridCD", 15000)
    end
    self.protectEndTick = skynet.timestamp() + protectTime * 1000
    self.canGiveUpTick = skynet.timestamp() + abandonGridCD * 1000
    self.status = constant.STARMAP_GRID_STATUS_PROTECT
    gg.centerProxy:broadCast2Game("onGridUpdate", "onGridProtect", self.cfgId, self:serialize())
end

function Grid:changeOwner(newOwner)
    local gridCfg = self:getGridCfg()
    assert(gridCfg, "gridCfg not exist")
    local oldOwner = self.owner
    if oldOwner and oldOwner.playerId ~= 0 then
        gg.starmap:delGridOwnerCache(oldOwner.playerId, oldOwner.unionId, oldOwner.isPrivate, self.cfgId)
    end
    if newOwner then
        self.owner = newOwner
        if newOwner and newOwner.playerId ~= 0 then
            gg.starmap:addGridOwnerCache(newOwner.playerId, newOwner.unionId, newOwner.isPrivate, self.cfgId)
        end
        self.builds = self:createCaptureBuilds()
    else
        self:initOwner()
        self.builds = self:createPresetBuilds()
    end
    self.makeResTick = 0
    self.shareTick = 0
    self.makeScoreTick = 0
    self.makeScoreCount = 0
    self.status = constant.STARMAP_GRID_STATUS_IDLE
    self.dirty = true
end

-- ""
function Grid:calcWinRes()
    local currencies = {}
    local rate = gg.getGlobalCfgIntValue("battleWinResRate", 10000) / 10000
    table.insert(currencies, {
        resCfgId = constant.RES_CARBOXYL,
        count = math.floor(self.carboxyl * rate)
    })
    for k, v in pairs(self.res) do
        table.insert(currencies, {
            resCfgId = k,
            count = math.floor(v * rate)
        })
    end
    return currencies
end

function Grid:getNftBuilds()
    local nftBuilds = {}
    for k, v in pairs(self.builds) do
        if v.chain > 0 then
            table.insert(nftBuilds, v:serialize())
        end
    end
    return nftBuilds
end

function Grid:onCampaignBegin(defender)
    self:setBattleTick(defender)
end

function Grid:onJoinCampaign()

end

function Grid:_costDefenceBuildLife(remainBuilds)
    if self:isNatural() then
        return
    end
    local costLife = gg.getGlobalCfgIntValue("LeagueDefenceCostLife", 0)
    if costLife == 0 then
        return
    end
    local remainDict = table.toset(remainBuilds)
    for id, build in pairs(self.builds) do
        if not remainDict[id] then
            build.curLife = build.curLife - costLife
            if build.curLife < 0 then
                build.curLife = 0
            end
        end
    end
    self.dirty = true
end

function Grid:_storeNftBuilds()
    if self:isPrivate() then
        local nftBuilds = {}
        for id, build in pairs(self.builds) do
            if build.ownerPid ~= 0 then
                nftBuilds[build.ownerPid] = nftBuilds[build.ownerPid] or {}
                nftBuilds[build.ownerPid][id] = build:serialize()
            end
        end
        for pid, value in pairs(nftBuilds) do
            --TODO: fork
            gg.playerProxy:call(pid, "storeNftItemInBag", self.cfgId, value)
        end
    elseif self:isUnion() then
        local nfts = {}
        for id, build in pairs(self.builds) do
            if build.chain > 0 then
                nfts[id] = build:serialize()
            end
        end
        gg.unionProxy:call("starMapBackNfts", self.owner.unionId, nfts)
    end
end

function Grid:getGridPlayerMax(vipLevel)
    vipLevel = vipLevel or 0
    local vipCfgs = cfg.get("etc.cfg.vip")
    local vip = vipCfgs[vipLevel]
    return vip.gridPlayerMax or 30
end

function Grid:onCampaignEnd(result, attacker, armyType, remainBuilds, joinPids, attackContriDegree, vipLevel)
    self.dirty = true
    self.battleEndTick = 0
    local ownerPid = self.owner.playerId
    local ownerUnionId = self.owner.unionId
    if constant.STARMAP_GRID_TEST_RES then
        self.carboxyl = self.carboxyl + constant.STARMAP_GRID_TEST_RES
        local gridCfg = self:getGridCfg()
        for i, v in ipairs(gridCfg.perMakeRes or {}) do
            self.res[v[1]] = (self.res[v[1]] or 0) + constant.STARMAP_GRID_TEST_RES
        end
    end
    local newOwner = nil
    if result == constant.BATTLE_RESULT_WIN and attacker then
        self:_costDefenceBuildLife(remainBuilds)
        self:_storeNftBuilds()
        if self:isBelongTypePersonal() then
            if self:isPrivate() then
                gg.playerProxy:send(ownerPid, "onStarmapMyGridDel", self.cfgId)
            else
                gg.unionProxy:send("unsetGridOwner", ownerPid, ownerUnionId, self.cfgId)
            end
            if gg.starmap:getPlayerGridCount(attacker.playerId) < self:getGridPlayerMax(vipLevel) then
                gg.playerProxy:send(attacker.playerId, "onStarmapMyGridAdd", self.cfgId, self:packGridBrief(attacker.playerId, attacker.unionId), self.carboxyl, self.res)
                attacker.isPrivate = true
                newOwner = attacker
            else
                newOwner = nil
                gg.centerProxy:playerSay(attacker.playerId, util.i18nFormat(errors.GRID_NUM_LIMIT))
            end
        else
            if gg.starmap:getUnionGridCount(attacker.unionId) < gg.starmap:getGridUnionMax() then
                local attackContriDict = {}
                for k, v in pairs(attackContriDegree) do
                    if joinPids[k] == attacker.unionId then
                        attackContriDict[k] = v
                    end
                end
                gg.unionProxy:send("changeGridOwner", ownerPid, ownerUnionId, attacker.playerId, attacker.unionId, self.cfgId, self.carboxyl, self.res, attackContriDict)
                newOwner = attacker
            else
                gg.unionProxy:send("unsetGridOwner", ownerPid, ownerUnionId, self.cfgId)
                newOwner = nil
            end
        end
        self:resetRes()
        self:resetScoreCount()
        self:changeOwner(newOwner)
        if newOwner then
            self:setProtectTick()
        end
    elseif result == constant.BATTLE_RESULT_UNKNOW then
        self:_handleNftsLife(remainBuilds)
        self.status = constant.STARMAP_GRID_STATUS_IDLE
        if self:isNatural() then
            self:changeOwner(newOwner)
        end
    end
    gg.centerProxy:broadCast2Game("onGridUpdate", "onCampaignEnd", self.cfgId, self:serialize())
end

function Grid:_handleNftsLife(remainBuilds)
    if self:isNatural() then
        return
    end
    local costLife = gg.getGlobalCfgIntValue("LeagueDefenceCostLife", 0)
    if costLife == 0 then
        return
    end
    local remainDict = table.toset(remainBuilds)
    local delBuilds = {}
    local personalNfts = {}
    local unionNfts = {}
    for id, build in pairs(self.builds) do
        if not remainDict[id] then
            build.curLife = build.curLife - costLife
            if build.curLife < 0 then
                build.curLife = 0
            end
            if build.curLife == 0 then
                if build.chain == 0 then--normal build not del
                    -- delBuilds[id] = true
                else
                    if self:isPrivate() then
                        if build.ownerPid ~= 0 then
                            personalNfts[build.ownerPid] = personalNfts[build.ownerPid] or {}
                            personalNfts[build.ownerPid][id] = build:serialize()
                            delBuilds[id] = true
                        end
                    elseif self:isUnion() then
                        unionNfts[id] = build:serialize()
                        delBuilds[id] = true
                    end
                end
            end
        end
    end
    for pid, value in pairs(personalNfts) do
        --TODO: fork
        gg.playerProxy:call(pid, "storeNftItemInBag", self.cfgId, value)
    end
    gg.unionProxy:call("starMapBackNfts", self.owner.unionId, unionNfts)
    for id, _ in pairs(delBuilds) do
        self.builds[id] = nil
    end
    self.dirty = true
end

function Grid:dissolveUnionHandle()
    self:_storeNftBuilds()
    self:changeOwner()
    return true
end

function Grid:doMatchSeasonEndClear()
    self:_storeNftBuilds()
    if self.owner.playerId ~= 0 then
        if self:isPrivate() then--personal
            gg.playerProxy:send(self.owner.playerId, "onStarmapMyGridDel", self.cfgId)
        else
            gg.unionProxy:send("delUnionOwnGrid", self.owner.playerId, self.owner.unionId, self.cfgId)
        end
    end
    self:changeOwner()
    return true
end

function Grid:startBattle(pid, battleInfo)
    local campaign = gg.campaignMgr:getGridOnGoingCampaign(self.cfgId)
    if not campaign then
        local defender = {}
        defender.playerId = self.owner.playerId
        defender.playerName = self.owner.playerName
        defender.playerLevel = self.owner.playerLevel
        defender.playerScore = self.owner.playerScore
        defender.playerHead = self.owner.playerHead

        defender.unionName = self.owner.unionName
        defender.unionFlag = self.owner.unionFlag
        defender.unionId = self.owner.unionId
        defender.presidentName = self.owner.presidentName

        local builds = self:getBattleBuilds()
        campaign = gg.campaignMgr:createCampaign(self.cfgId, defender, builds)
    end
    campaign:startBattle(battleInfo.attacker, battleInfo.armyType, battleInfo.fightArmys, battleInfo.bVersion,
        battleInfo.signinPosId, battleInfo.operates, battleInfo.armyInfos, battleInfo.vipLevel)
end

function Grid:endBattle(pid, battleResult)
    -- if self.battleEndTick == 0 then
    --     return
    -- end
    -- self.battleEndTick = 0
    -- self.status = constant.STARMAP_GRID_STATUS_IDLE
    -- self.dirty = true
end

function Grid:checkBattleTimeout()
end

function Grid:checkProtectTimeout()
    if self.protectEndTick == 0 or skynet.timestamp() < self.protectEndTick then
        return
    end
    self.protectEndTick = 0
    self.status = constant.STARMAP_GRID_STATUS_IDLE
    self.dirty = true
end

function Grid:makeRes()
    if self:isNatural() then
        return
    end
    local gridCfg = self:getGridCfg()
    assert(gridCfg, "gridCfg not exist")
    self.makeResTick = self.makeResTick + 1
    local makeResTime = 0
    if self:isPrivate() then
        makeResTime = gg.getGlobalCfgIntValue("LeagueMakeResCD", 30)
    elseif self:isUnion() then
        makeResTime = gg.getGlobalCfgIntValue("LeagueMakeHYCD", 30)
    else
        return
    end
    local cycleCount = math.floor(self.makeResTick / makeResTime)
    if cycleCount <= 0 then
        return
    end
    if gridCfg.perMakeCarboxyl > 0 then
        self.carboxyl = self.carboxyl + cycleCount * gridCfg.perMakeCarboxyl
    end
    for i, v in ipairs(gridCfg.perMakeRes or {}) do
        self.res[v[1]] = (self.res[v[1]] or 0) + v[2]
    end
    self.makeResTick = self.makeResTick - cycleCount * makeResTime
    self.dirty = true
end

function Grid:makeContributeDegree()
    local gridCfg = self:getGridCfg()
    assert(gridCfg, "gridCfg not exist")
    self.makeContriTick = self.makeContriTick + 1
    local makeContriCD = gg.getGlobalCfgIntValue("StarMakeContributeCD", 3600)
    local cycleCount = math.floor(self.makeContriTick / makeContriCD)
    if cycleCount <= 0 then
        return
    end
    if gridCfg.perMakeContribute and gridCfg.perMakeContribute > 0 then
        local contriDegree = cycleCount * gridCfg.perMakeContribute
        gg.unionProxy:send("starmapGridContribute", self.owner.playerId, self.cfgId, contriDegree)
    end
    self.makeContriTick = self.makeContriTick - cycleCount * makeContriCD
    self.dirty = true
end

-- ""
function Grid:getBuildPower(cfgId)
    return 0
end

function Grid:getShareResLeftTime()
    local now = gg.time.time()
    local settleTime = gg.getGlobalCfgIntValue("GridSettleTime", 8 * 60 * 60)
    local leftTime = now + settleTime - self.shareTick
    return leftTime
end

function Grid:_canShareRes()
    if self:isNatural() then
        return
    end
    local settleTime = gg.getGlobalCfgIntValue("GridSettleTime", 0)
    if settleTime == 0 then
        settleTime = 1
    end
    self.shareTick = self.shareTick + 1
    local cycleCount = math.floor(self.shareTick / settleTime)
    if cycleCount <= 0 then
        return
    end
    local hasRes = false
    for k, v in pairs(self.res) do
        if v > 0 then
            hasRes = true
        end
    end
    if not hasRes and self.carboxyl == 0 then
        return
    end
    self.shareTick = self.shareTick - cycleCount * settleTime
    self.dirty = true
    return true
end

function Grid:_sharePrivateRes()
    local resInfo = {}
    local resDict = {}
    resDict[constant.RES_CARBOXYL] = self.carboxyl
    for k, v in pairs(self.res) do
        resDict[k] = (resDict[k] or 0) + v
    end
    for k, v in pairs(resDict) do
        local resKey = constant.RES_JSON_KEYS[k]
        resInfo[resKey] = v
    end
    gg.shareProxy:call("incrbyStarmapPrivateGridsResInfo", self.owner.playerId, resInfo)

    local reward = {
        rtype = constant.STARMAP_GRID_REWARD_PERSON,
        percent = 100,
        total = 1,
        myVal = 1,
        carboxyl = self.carboxyl,
        totalCarboxyl = self.carboxyl,
        resDict = self.res,
    }
    local rewardMap = {
        cfgId = self.cfgId,
        rewards = {[1] = reward},
        timestamp = gg.time.time(),
        isMember = false,
        isPersonal = true
    }
    gg.playerProxy:sendOnline(self.owner.playerId, "shareGridRes", self.cfgId, rewardMap)
    self:resetRes()
end

function Grid:_shareUnionRes()
    local nftBuilds = {}
    for id, build in pairs(self.builds) do
        if build.chain > 0 and build.ownerPid > 0 then
            nftBuilds[build.ownerPid] = nftBuilds[build.ownerPid] or {}
            table.insert(nftBuilds[build.ownerPid], id)
        end
    end
    gg.unionProxy:send("starmapGridReward", self.owner.playerId, self.owner.unionId, self.cfgId, self.carboxyl,
        nftBuilds, self.res)
    self:resetRes()
end

-- ""
function Grid:checkShareTimeout()
    if not self:_canShareRes() then
        return
    end
    if self:isPrivate() then
        self:_sharePrivateRes()
    elseif self:isUnion() then
        self:_shareUnionRes()
    end
end

function Grid:makeScore()
    if not self:isUnion() then
        return
    end
    local gridCfg = self:getGridCfg()
    assert(gridCfg, "gridCfg not exist")
    self.makeScoreTick = self.makeScoreTick + 1
    if gridCfg.point <= 0 then
        return
    end
    local makeScoreTime =  gg.getGlobalCfgIntValue("StarMakePointCD", 30)
    local cycleCount = math.floor(self.makeScoreTick / makeScoreTime)
    if cycleCount <= 0 then
        return
    end
    if gridCfg.point > 0 then
        self.makeScoreCount = self.makeScoreCount + cycleCount
    end
    self.makeScoreTick = self.makeScoreTick - cycleCount * makeScoreTime
    self.dirty = true
end

function Grid:checkScoreCountTimeout()
    if not self:isUnion() then
        return
    end
    if self.makeScoreCount <= 0 then
        return
    end
    gg.unionProxy:send("starmapAddGridScoreCount", self.owner.playerId, self.owner.unionId, self.cfgId, self.makeScoreCount)
    self:resetScoreCount()
end

function Grid:shutdown()
    self.dirty = true
    self:save_to_db()
end

function Grid:onSecond()
    self:makeRes()
    self:makeScore()
    if self.owner.playerId ~= 0 and self:isPrivate() then
        self:makeContributeDegree()
    end
    self:checkShareTimeout()
    self:checkScoreCountTimeout()
    self:checkBattleTimeout()
    self:checkProtectTimeout()
end

function Grid:onMinute()
    -- self:save_to_db()
end

return Grid
