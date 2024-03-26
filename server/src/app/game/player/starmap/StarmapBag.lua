local StarmapBag = class("StarmapBag")

function StarmapBag:ctor(param)
    self.player = param.player
    self.favoriteGridIds = {}
    self.gridRewardRecords = {}
    self.gridReward = {
        unionMit = 0,
        unionCarboxyl = 0,
        otherUnionMit = 0,
        otherUnionCarboxyl = 0,
        personalUnionMit = 0,
        personalUnionCarboxyl = 0
    }
    self.matchRewardRecords = {}

    self.myGridIds = {} -- ""
    self.lastGetGridCount = nil
    self.gridCountInfo = {}
end

function StarmapBag:serialize()
    local data = {}
    data.favoriteGridIds = {}
    data.myGridIds = {}
    data.gridRewardRecords = self.gridRewardRecords
    data.gridReward = self.gridReward
    data.matchRewardRecords = self.matchRewardRecords
    for k, v in pairs(self.favoriteGridIds) do
        data.favoriteGridIds[tostring(k)] = v
    end
    for k, v in pairs(self.myGridIds) do
        data.myGridIds[tostring(k)] = v
    end

    return data
end

function StarmapBag:deserialize(data)
    if not data then
        return
    end

    if data.favoriteGridIds then
        for k, v in pairs(data.favoriteGridIds) do
            self.favoriteGridIds[tonumber(k)] = v
        end
    end
    if data.myGridIds then
        for k, v in pairs(data.myGridIds) do
            self.myGridIds[tonumber(k)] = v
        end
    end

    if data.gridRewardRecords then
        self.gridRewardRecords = data.gridRewardRecords
    end
    if data.gridReward then
        self.gridReward = data.gridReward
    end
    if data.matchRewardRecords then
        self.matchRewardRecords = data.matchRewardRecords
    end
end

function StarmapBag:calcProtectLessTime(gridData)
    if gridData.protectEndTick == 0 or skynet.timestamp() > gridData.protectEndTick then
        return 0
    end
    return math.floor((gridData.protectEndTick - gridData.nowTimestamp) / 1000)
end

function StarmapBag:packGridBuild(buildInfo)
    local data = {}
    data.id = buildInfo.id
    data.cfgId = buildInfo.cfgId
    data.level = buildInfo.level
    data.quality = buildInfo.quality
    data.life = buildInfo.life
    data.curLife = buildInfo.curLife
    data.pos = Vector3.New(buildInfo.x, 0, buildInfo.z)
    return data
end

function StarmapBag:packGridBuilds(buildInfos)
    local builds = {}
    if not buildInfos then
        return builds
    end
    for k, v in pairs(buildInfos) do
        table.insert(builds, self:packGridBuild(v))
    end
    return builds
end

function StarmapBag:packGridBelong(gridData)
    if not gridData.owner then
        return constant.STARMAP_BELONG_NONE
    end
    if gridData.owner.playerId == 0 then
        return constant.STARMAP_BELONG_NONE
    end
    if gridData.owner.playerId == self.player.pid and gridData.owner.isPrivate then
        return constant.STARMAP_BELONG_SELF
    end
    if gridData.owner.unionId and gridData.owner.unionId ~= 0
        and gridData.owner.unionId == self.player.unionBag:getMyUnionId() then
        return constant.STARMAP_BELONG_SELF_UNION
    end
    return constant.STARMAP_BELONG_OTHER
end

-- ""
function StarmapBag:packGridBrief(gridData)
    local data = {}
    data.cfgId = gridData.cfgId
    data.status = gridData.status
    data.belong = self:packGridBelong(gridData)
    data.isFavorite = self.favoriteGridIds[gridData.cfgId] and 1 or 0
    data.owner = gridData.owner
    data.unionNum = gridData.unionNum
    return data
end

-- ""
function StarmapBag:packGridBriefs(gridDataList)
    local list = {}
    for _, v in pairs(gridDataList) do
        local data = self:packGridBrief(v)
        table.insert(list, data)
    end
    return list
end

-- ""
function StarmapBag:packGridDetail(gridData)
    local data = {}
    data.cfgId = gridData.cfgId
    data.status = gridData.status
    data.belong = self:packGridBelong(gridData)
    data.carboxyl = gridData.carboxyl
    data.owner = gridData.owner
    data.attackers = gridData.attackers
    data.protectTime = math.floor(gridData.protectEndTick / 1000)  --self:calcProtectLessTime(gridData)
    -- data.builds = self:packGridBuilds(gridData.builds)
    data.battleEndTick = math.floor(gridData.battleEndTick / 1000)
    return data
end

---""
---@param gridData table
function StarmapBag:broadCastGridUpdate(gridData, subCmd)
    gg.client:send(self.player.linkobj, "S2C_Player_starmapGridUpdate", {
        grid = self:packGridDetail(gridData)
    })
end

-- ""
function StarmapBag:onMyGridDel(cfgId)
    if self.myGridIds[cfgId] then
        self.myGridIds[cfgId] = nil
    end
    gg.client:send(self.player.linkobj, "S2C_Player_MyGridDel", {
        cfgId = cfgId
    })
end

-- ""1""
function StarmapBag:onMyGridAdd(cfgId, gridData, carboxyl, resDict)
    self.myGridIds[cfgId] = cfgId
    if carboxyl then
        gg.unionProxy:send("personalCampaignReward", self.player.pid, self.player.unionBag:getMyUnionId(), cfgId,
            carboxyl, resDict)
    end
    gg.client:send(self.player.linkobj, "S2C_Player_MyGridAdd", {
        grid = gridData
    })
end

-- ""
function StarmapBag:onUnionGridDel(cfgId)
    gg.client:send(self.player.linkobj, "S2C_Player_UnionGridDel", {
        cfgId = cfgId
    })
end

function StarmapBag:onGridCountInfoUpdate(info)
    self.gridCountInfo = info
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapGridCount", self.gridCountInfo)
end

function StarmapBag:_checkPrivateGridsResInfo()
    local RES_KEY_ID = {}
    for k, v in pairs(constant.RES_JSON_KEYS) do
        RES_KEY_ID[v] = k
    end
    local resInfo = gg.shareProxy:call("getStarmapPrivateGridsResInfo", self.player.pid)
    local resDict = {}
    for k, v in pairs(resInfo) do
        local resId = RES_KEY_ID[k]
        resDict[resId] = tonumber(v)
    end
    local delN = gg.shareProxy:call("delStarmapPrivateGridsResInfo", self.player.pid)
    if delN == 0 then
        return
    end
    self.player.resBag:safeAddResDict(resDict, { logType = gamelog.STARMAP_DRAW_REWARD }, false)

    local increRankVal = 0
    if table.count(resDict) > 0 then
        for k, v in pairs(resDict) do
            if k == constant.RES_CARBOXYL then
                increRankVal = increRankVal + v
            end
        end
    end
    if increRankVal > 0 then
        local myUnionId = self.player.unionBag:getMyUnionId()
        if myUnionId then
            gg.rankProxy:send("increDifferentRankVal", constant.REDIS_RANK_UNION_GET_HYDROXYL, myUnionId, increRankVal)
        end
    end
    return true
end

-- ""
function StarmapBag:shareGridRes(cfgId, rewardInfo)
    local isMember = rewardInfo.isMember
    local isPersonal = rewardInfo.isPersonal
    if isPersonal then
        self.gridReward.personalUnionMit = (self.gridReward.personalUnionMit or 0) + (rewardInfo.rewards[1].mit or 0)
        self.gridReward.personalUnionCarboxyl = (self.gridReward.personalUnionCarboxyl or 0) + (rewardInfo.rewards[1].carboxyl or 0)
        -- local increRankVal = 0
        -- local getHy = (rewardInfo.rewards[1].carboxyl or 0)
        -- increRankVal = increRankVal + getHy
        -- local resDict = rewardInfo.rewards[1].resDict or {}
        -- if table.count(resDict) > 0 then
        --     for k, v in pairs(resDict) do
        --         if k == constant.RES_CARBOXYL then
        --             increRankVal = increRankVal + v
        --         end
        --     end
        --     self.player.resBag:safeAddResDict(resDict, { logType = gamelog.STARMAP_DRAW_REWARD }, false)
        -- end
        -- if increRankVal > 0 then
        --     local myUnionId = self.player.unionBag:getMyUnionId()
        --     if myUnionId then
        --         gg.rankProxy:send("increDifferentRankVal", constant.REDIS_RANK_UNION_GET_HYDROXYL, myUnionId, increRankVal)
        --     end
        -- end
        self:_checkPrivateGridsResInfo()
    else
        for i, v in ipairs(rewardInfo.rewards) do
            if isMember then
                self.gridReward.unionMit = self.gridReward.unionMit + (v.mit or 0)
                self.gridReward.unionCarboxyl = self.gridReward.unionCarboxyl + (v.carboxyl or 0)
            else
                self.gridReward.otherUnionMit = self.gridReward.otherUnionMit + (v.mit or 0)
                self.gridReward.otherUnionCarboxyl = self.gridReward.otherUnionCarboxyl + (v.carboxyl or 0)
            end
            local resDict = v.resDict or {}
            if table.count(resDict) > 0 then
                self.player.resBag:addResDict(resDict, { logType = gamelog.STARMAP_DRAW_REWARD }, false)
            end
        end
    end
    if isMember or isPersonal then
        if table.count(self.gridRewardRecords) >= constant.STARMAP_REWARD_RECORD_LIMIT then
            local diff = table.count(self.gridRewardRecords) - constant.STARMAP_REWARD_RECORD_LIMIT
            for i = 1, diff, 1 do
                table.remove(self.gridRewardRecords, 1)
            end
        end
        for i, v in ipairs(rewardInfo.rewards) do
            local resDict = v.resDict or {}
            if table.count(resDict) > 0 then
                local newDict = {}
                for kk, vv in pairs(resDict) do
                    newDict[tostring(kk)] = vv
                end
                v.resDict = newDict
            end
        end
        table.insert(self.gridRewardRecords, rewardInfo)
    end
end

function StarmapBag:starmapMatchRankReward(rewardInfo)
    local isMember = rewardInfo.isMember
    if isMember then
        self.gridReward.unionMit = self.gridReward.unionMit + (rewardInfo.mit or 0)
        self.gridReward.unionCarboxyl = self.gridReward.unionCarboxyl + (rewardInfo.carboxyl or 0)
    else
        self.gridReward.otherUnionMit = self.gridReward.otherUnionMit + (rewardInfo.mit or 0)
        self.gridReward.otherUnionCarboxyl = self.gridReward.otherUnionCarboxyl + (rewardInfo.carboxyl or 0)
    end
    if isMember then
        if table.count(self.matchRewardRecords) >= constant.STARMAP_REWARD_RECORD_LIMIT then
            local diff = table.count(self.matchRewardRecords) - constant.STARMAP_REWARD_RECORD_LIMIT
            for i = 1, diff, 1 do
                table.remove(self.matchRewardRecords, 1)
            end
        end
        table.insert(self.matchRewardRecords, rewardInfo)
    end
end

--------------------------------------------------

function StarmapBag:getGridsBrief(gridCfgIds, proto)
    local myUnionId = self.player.unionBag:getMyUnionId()
    local retInfo = gg.starmapProxy:call("enterStarmap", self.player.pid, myUnionId, gridCfgIds, self.player.name)
    local unionFavGrids = {}
    for k, v in pairs(retInfo.favoriteGridsDict) do
        table.insert(unionFavGrids, k)
    end
    local myFavGrids = {}
    for k, v in pairs(self.favoriteGridIds) do
        table.insert(myFavGrids, k)
    end
    self.player.unionBag:setBeginGridId(retInfo.beginGridId)
    gg.client:send(self.player.linkobj, proto, {
        grids = retInfo.list,
        beginGridId = retInfo.beginGridId,
        season = retInfo.season,
        lifeTime = retInfo.lifeTime,
        score = retInfo.score,
        unionFavGrids  = unionFavGrids,
        myFavGrids  = myFavGrids,
    })
end

-- ""
function StarmapBag:subscribeGrids(cfgIds)
    if not cfgIds or table.count(cfgIds) == 0 then
        return
    end
    -- gg.starmapProxy:unsubscribe(self.player.pid)
    gg.starmapProxy:subscribe(self.player.pid, cfgIds)
    self:getGridsBrief(cfgIds, "S2C_Player_SubscribeGrids")
end

-- ""
function StarmapBag:unsubscribeGrids(cfgIds)
    gg.starmapProxy:unsubscribe(self.player.pid, cfgIds)
end

-- ""
function StarmapBag:enterStarmap(gridCfgIds)
    if not gridCfgIds or table.count(gridCfgIds) == 0 then
        return
    end
    self:subscribeGrids(gridCfgIds)
    self:getGridsBrief(gridCfgIds, "S2C_Player_EnterStarmap")
end

function StarmapBag:getChainExclusiveGrids()
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

--""
function StarmapBag:notifyChainExclusiveGrids()
    local exclusiveDict = gg.dynamicCfg:get(constant.REDIS_STARMAP_CHAIN_EXCLUSIVE)
    local result = self:getChainExclusiveGrids()
    local data = {}
    for cfgId,chain in pairs(result) do
        table.insert(data, { cfgId = cfgId, chain = chain })
    end
    gg.client:send(self.player.linkobj, "S2C_Player_Starmap_Exclusive_Grids", { data = data })
end

-- ""
function StarmapBag:leaveStarmap()
    self:unsubscribeGrids()
end

-- ""
function StarmapBag:scoutGrid(cfgId)
    local myUnionId = self.player.unionBag:getMyUnionId()
    local grid = gg.starmapProxy:call("scoutGrid", self.player.pid, cfgId, myUnionId)
    gg.client:send(self.player.linkobj, "S2C_Player_ScoutStarmapGrid", {
        grid = grid or {}
    })
end

-- ""
function StarmapBag:putBuildOnGrid(cfgId, buildId, pos)
    if not pos then
        self.player:say(util.i18nFormat(errors.POS_ERR))
        return
    end
    local myUnionId = self.player.unionBag:getMyUnionId()
    gg.starmapProxy:send("putBuildOnGrid", self.player.pid, cfgId, buildId, pos, myUnionId)
end

function StarmapBag:addDefenseBuildOnGrid(cfgId, buildId, pos)
    local myUnionId = self.player.unionBag:getMyUnionId()
    gg.starmapProxy:send("addDefenseBuildOnGrid", self.player.pid, cfgId, buildId, pos, myUnionId)
end

-- ""
function StarmapBag:putBuildListOnGrid(cfgId, buildList, from)
    if table.count(buildList) == 0 then
        return
    end
    local myUnionId = self.player.unionBag:getMyUnionId()
    if from == constant.STARMAP_TO_GRID_BUILD_PERSON then
        for i, v in ipairs(buildList) do
            local build = self.player.buildBag:getBuild(v.id)
            if not build then
                self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
                return
            end
        end
    elseif from == constant.STARMAP_TO_GRID_BUILD_UNION then
        if not myUnionId then
            self.player:say(util.i18nFormat(errors.GRID_NOT_JOIN_UNION))
            return
        end
    else
        self.player:say(util.i18nFormat(errors.GRID_TO_GRID_BUILD_TYPE_ERR))
        return
    end

    gg.starmapProxy:send("putBuildListOnGrid", self.player.pid, cfgId, buildList, myUnionId, from)
end

-- ""
function StarmapBag:moveBuildOnGrid(cfgId, buildId, pos)
    gg.starmapProxy:send("moveBuildOnGrid", self.player.pid, cfgId, buildId, pos)
end

-- ""
function StarmapBag:delBuildOnGrid(cfgId, buildId)
    gg.starmapProxy:send("delBuildOnGrid", self.player.pid, cfgId, buildId)
end

-- ""
function StarmapBag:storeBuildOnGrid(cfgId, buildId)
    gg.starmapProxy:send("storeBuildOnGrid", self.player.pid, cfgId, buildId)
end

-- ""
function StarmapBag:startBattle(cfgId, args)
    local isInner
    if args.battleType == constant.BATTLE_TYPE_STAR_INNER then
        if not gg.isInnerServer() then
            return
        end
        isInner = true
    end
    local myUnionId = self.player.unionBag:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.GRID_BATTLE_REQUIRE_UNION))
        return
    end
    local chainId = self.player.playerInfoBag:getChainId()
    local result = self:getChainExclusiveGrids()
    local gridchain = result[cfgId]
    if gridchain and (gridchain < 0 or chainId ~= gridchain) then
        self.player:say(util.i18nFormat(errors.GRID_IS_EXCLUSIVE_STAR))
        return
    end
    -- if not chainId or chainId <= 0 then
    --     self.player:say(util.i18nFormat(errors.BRIDGE_MUST_IN_SAME_CHAIN))
    --     return
    -- end
    -- local myUnionChainId = self.player.unionBag:getMyUnionChainId()
    -- if chainId ~= myUnionChainId then
    --     self.player:say(util.i18nFormat(errors.BRIDGE_MUST_IN_SAME_CHAIN))
    --     return
    -- end
    local armyInfos
    if args.armyType == constant.BATTLE_ARMY_TYPE_SELF then --""
        armyInfos = self.player.armyBag:takeStarmapCampaignArmy(cfgId, args.armys)
        if not armyInfos or not next(armyInfos) then
            self.player:say(util.i18nFormat(errors.CAMPAIGN_ARMY_EMPTY))
            return
        end
    else  -- ""
        return
    end

    local battleInfo = {}
    battleInfo.attacker = {}
    battleInfo.attacker.playerId = self.player.pid
    battleInfo.attacker.playerName = self.player.name
    battleInfo.attacker.playerLevel = self.player.buildBag:getBuildLevelByCfgId(constant.BUILD_BASE)
    battleInfo.attacker.playerScore = self.player.pvpBag:getPlayerRankScore()
    battleInfo.attacker.playerHead = self.player.playerInfoBag.headIcon
    battleInfo.attacker.unionName = self.player.unionBag:getMyUnionName()
    battleInfo.attacker.unionFlag = self.player.unionBag:getMyUnionFlag()
    battleInfo.attacker.unionId = myUnionId
    battleInfo.attacker.presidentName = self.player.unionBag:getMyUnionPresidentName()
    battleInfo.attacker.chainId = chainId
    battleInfo.armyType = args.armyType
    battleInfo.fightArmys = args.armys

    battleInfo.bVersion = args.bVersion or "1"
    battleInfo.signinPosId = args.signinPosId
    battleInfo.operates = args.operates
    battleInfo.isInner = isInner
    battleInfo.armyInfos = armyInfos
    battleInfo.vipLevel = self.player.vipBag:getVipLevel()
    gg.starmapProxy:send("startBattle", self.player.pid, cfgId, battleInfo)
end

-- ""
function StarmapBag:endBattle(battleId, battleResult)
end

-- ""
function StarmapBag:getMyGridList()
    local myUnionId = self.player.unionBag:getMyUnionId()
    local grids = gg.starmapProxy:call("getMyGridList", self.player.pid, myUnionId)
    gg.client:send(self.player.linkobj, "S2C_Player_GetMyGirdList", {
        grids = grids
    })
end

-- ""
function StarmapBag:getMyFavoriteGridList()
    local myUnionId = self.player.unionBag:getMyUnionId()
    local ret = gg.starmapProxy:call("getFavoriteGridsInfo", self.player.pid, table.keys(self.favoriteGridIds), myUnionId)
    for i, v in ipairs(ret.list) do
        v.tag = self.favoriteGridIds[v.cfgId] or ""
    end
    gg.client:send(self.player.linkobj, "S2C_Player_GetMyFavoriteGridList", {
        grids = ret.list,
        unionGrids = ret.unionlist,
    })
end

-- ""
function StarmapBag:addMyFavoriteGrid(cfgId, tag)
    local limit = gg.getGlobalCfgIntValue("PersonCollectLimit", 0)
    local count = table.count(self.favoriteGridIds)
    if count >= limit then
        self.player:say(util.i18nFormat(errors.GRID_COLLECT_OVER_LIMIT))
        return
    end
    if self.favoriteGridIds[cfgId] then
        return
    end
    if string.len(tag) > constant.STARMAP_COLLECT_TAG_LEN then
        self.player:say(util.i18nFormat(errors.GRID_COLLECT_TAG_OVER))
        return
    end
    self.favoriteGridIds[cfgId] = tag
    gg.client:send(self.player.linkobj, "S2C_Player_MyFavoriteGridAdd", {
        cfgId = cfgId,
        tag = tag,
    })
end

-- ""
function StarmapBag:delMyFavoriteGrid(cfgId)
    if self.favoriteGridIds[cfgId] then
        self.favoriteGridIds[cfgId] = nil
    end
    gg.client:send(self.player.linkobj, "S2C_Player_MyFavoriteGridDel", {
        cfgId = cfgId
    })
end

-- ""
function StarmapBag:getUnionFavoriteGridList()
    local myUnionId = self.player.unionBag:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local grids = gg.starmapProxy:call("getUnionFavoriteGridList", self.player.pid, myUnionId)
    gg.client:send(self.player.linkobj, "S2C_Player_GetUnionFavoriteGridList", {
        grids = grids
    })
end

-- ""
function StarmapBag:addUnionFavoriteGrid(cfgId, tag)
    if string.len(tag) > constant.STARMAP_COLLECT_TAG_LEN then
        self.player:say(util.i18nFormat(errors.GRID_COLLECT_TAG_OVER))
        return
    end
    local myUnionId = self.player.unionBag:getMyUnionId()
    gg.starmapProxy:send("addUnionFavoriteGrid", self.player.pid, myUnionId, cfgId, tag)
end

-- ""
function StarmapBag:delUnionFavoriteGrid(cfgId)
    local myUnionId = self.player.unionBag:getMyUnionId()
    gg.starmapProxy:send("delUnionFavoriteGrid", self.player.pid, myUnionId, cfgId)
end

-- ""
function StarmapBag:giveUpMyGrid(cfgId)
    gg.starmapProxy:send("giveUpMyGrid", self.player.pid, cfgId)
end

-- ""
function StarmapBag:giftWithMyGrid(cfgId, toPid)
    gg.starmapProxy:send("giftWithMyGrid", self.player.pid, cfgId, toPid)
end

-- ""
function StarmapBag:getMyStarmapRewardList()
    local send = {
        gridReward = self.gridReward,
        gridRewardRecords = self.gridRewardRecords,
        matchRewards = self.matchRewardRecords
    }
    gg.client:send(self.player.linkobj, "S2C_Player_GetMyStarmapRewardList", send)
end

-- ""
function StarmapBag:drawMyStarmapReward()
    local resDict = {
        [constant.RES_MIT] = self.gridReward.unionMit + self.gridReward.otherUnionMit + (self.gridReward.personalUnionMit or 0),
        [constant.RES_CARBOXYL] = self.gridReward.unionCarboxyl + self.gridReward.otherUnionCarboxyl + (self.gridReward.personalUnionCarboxyl or 0)
    }
    self.player.resBag:addResDict(resDict, { logType = gamelog.STARMAP_DRAW_REWARD })
    self.gridReward.unionMit = 0
    self.gridReward.otherUnionMit = 0
    self.gridReward.personalUnionMit = 0
    self.gridReward.unionCarboxyl = 0
    self.gridReward.otherUnionCarboxyl = 0
    self.gridReward.personalUnionCarboxyl = 0

    gg.client:send(self.player.linkobj, "S2C_Player_DrawMyStarmapReward", {
        gridReward = self.gridReward
    })
end

function StarmapBag:getUnionStarmapCampaignReports(unionId, campaignIdList)
    local reports = gg.starmapProxy:call("getUnionStarmapCampaignReports", unionId, campaignIdList)
    return reports
end

function StarmapBag:getUnionStarmapBattleReports(unionId, campaignId, pageNo, pageSize)
    local reports = gg.starmapProxy:call("getUnionStarmapBattleReports", unionId, campaignId, pageNo, pageSize)
    return reports
end

function StarmapBag:getPersonalStarmapCampaignReports(campaignIdList)
    local reports = gg.starmapProxy:call("getPersonalStarmapCampaignReports", self.player.pid, campaignIdList)
    return reports
end

function StarmapBag:getPersonalStarmapBattleReports(campaignId, pageNo, pageSize)
    local reports = gg.starmapProxy:call("getPersonalStarmapBattleReports", campaignId, pageNo, pageSize)
    return reports
end

function StarmapBag:getStarmapCampaignPlyStatistics(unionId, campaignId)
    local reports = gg.starmapProxy:call("getStarmapCampaignPlyStatistics", unionId, campaignId)
    return reports
end

function StarmapBag:getStarmapMatchUnionGrids()
    local myUnionId = self.player.unionBag:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local retInfo = gg.starmapProxy:call("getUnionGrids", self.player.pid, myUnionId)
    local list = {}
    for gridCfgId, leftSec in pairs(retInfo.gridShareTime or {}) do
        table.insert(list, {gridCfgId = gridCfgId, leftTime = leftSec})
    end
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapMatchUnionGrids", {
        list = list,
        personScore = retInfo.personScore,
    })
end

function StarmapBag:getStarmapMatchPersonalGrids()
    local retInfo = gg.starmapProxy:call("getPersonalGrids", self.player.pid)
    local list = {}
    for gridCfgId, leftSec in pairs(retInfo.gridShareTime or {}) do
        table.insert(list, {gridCfgId = gridCfgId, leftTime = leftSec})
    end
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapMatchPersonalGrids", {
        list = list,
    })
end

function StarmapBag:transferBeginGrid(cfgId)
    local myUnionId = self.player.unionBag:getMyUnionId()
    if not myUnionId then
        self.player:say(util.i18nFormat(errors.UNION_NOT_JOIN))
        return
    end
    local beginGridId = gg.starmapProxy:call("transferBeginGrid", self.player.pid, myUnionId, cfgId)
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapTransferBeginGrid", {
        cfgId = beginGridId or 0,
    })
end

function StarmapBag:minimap()
    local myUnionId = self.player.unionBag:getMyUnionId()
    local list = gg.starmapProxy:call("getMinimapInfo", self.player.pid, myUnionId)
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapMinimap", {
        list = list
    })
end

function StarmapBag:firstGetGridRank()
    local ret = gg.activityProxy:call("actFirstGetGridRank", self.player.pid, constant.ACT_STARMAP_FIRST_GET)
    gg.client:send(self.player.linkobj, "S2C_Player_FirstGetGridRank", {
        list = ret.list,
        selfRank = ret.selfRank,
    })
end

function StarmapBag:onload()

end

function StarmapBag:onlogin()
    if not self.lastGetGridCount then
        local myUnionId = self.player.unionBag:getMyUnionId()
        local retInfo = gg.starmapProxy:call("getGridCountInfo", self.player.pid, myUnionId)
        self.gridCountInfo = retInfo
        self.lastGetGridCount = gg.time.time()
    end
    gg.client:send(self.player.linkobj, "S2C_Player_StarmapGridCount", self.gridCountInfo)
    self:_checkPrivateGridsResInfo()
    self:getStarmapMatchPersonalGrids()
end

function StarmapBag:onlogout()
    self:unsubscribeGrids()
end

function StarmapBag:onreset()
    self.favoriteGridIds = {}
    self.gridRewardRecords = {}
    self.gridReward = {
        unionMit = 0,
        unionCarboxyl = 0,
        otherUnionMit = 0,
        otherUnionCarboxyl = 0,
        personalUnionMit = 0,
        personalUnionCarboxyl = 0
    }
    self.matchRewardRecords = {}

    self.myGridIds = {} -- ""
    self.lastGetGridCount = nil
    self.gridCountInfo = {}
end

return StarmapBag
