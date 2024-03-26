local Starmap = class("Starmap")

function Starmap:ctor()
    self.grids = {}
    self.playerGridIds = {}
    self.unionGridIds = {}
    self:init()
end

function Starmap:init()
    local n = 0
    local gridDatas = {}
    local starmapConfig = gg.getExcelCfg("starmapConfig")
    local docs = gg.mongoProxy.starmap:find({})
    for _, doc in pairs(docs) do
        local cfg = starmapConfig[doc.cfgId]
        if cfg then
            local gridData = doc
            local grid = self:createStarMapGrid(cfg)
            grid:deserialize(gridData)
            self.grids[cfg.cfgId] = grid
            gg.savemgr:autosave(grid)
            if gridData.owner and gridData.owner.playerId and gridData.owner.playerId ~= 0 then
                local playerId = gridData.owner.playerId
                self.playerGridIds[playerId] = self.playerGridIds[playerId] or {}
                self.playerGridIds[playerId][cfg.cfgId] = true
            end
            if gridData.owner and gridData.owner.unionId and gridData.owner.unionId ~= 0
             and not gridData.owner.isPrivate then
                local unionId = gridData.owner.unionId
                self.unionGridIds[unionId] = self.unionGridIds[unionId] or {}
                self.unionGridIds[unionId][cfg.cfgId] = true
            end
            n = n + 1
        end
        if n == 100 then
            skynet.sleep(1)
            n = 0
        end
    end

    print("Starmap:init ok")
end

function Starmap:createStarMapGrid(starmapCfg)
    if starmapCfg.type == constant.STARMAP_NORMAL_GRID then
        return ggclass.Grid.new(starmapCfg.cfgId)
    elseif starmapCfg.type == constant.STARMAP_NFT_GRID then
        return ggclass.NftGrid.new(starmapCfg.cfgId)
    elseif starmapCfg.type == constant.STARMAP_BEGIN_GRID then
        return ggclass.BeginGrid.new(starmapCfg.cfgId)
    end
end

function Starmap:getGridPlayerMax()
    return gg.getGlobalCfgIntValue("GridPlayerMax", 50)
end

function Starmap:getGridUnionMax()
    return gg.getGlobalCfgIntValue("GridUnionMax", 30)
end

function Starmap:pos2GridId(x, y)
    local prefix = ""
    if x >= 0 then
        prefix = prefix .. "1"
    else
        prefix = prefix .. "2"
    end
    if y >= 0 then
        prefix = prefix .. "1"
    else
        prefix = prefix .. "2"
    end
    prefix = tonumber(prefix) * 1000000
    return prefix + math.abs(x) * 1000 + math.abs(y)
end

function Starmap:getNearGrids(x, y)
    local gridIds = {}
    local nearPosList = {{x - 1, y}, {x - 1, y + 1}, {x, y - 1}, {x + 1, y - 1}, {x + 1, y}, {x, y + 1}}
    for _, v in ipairs(nearPosList) do
        local gridId = self:pos2GridId(v[1], v[2])
        gridIds[gridId] = v
    end
    return gridIds
end

function Starmap:addPlayerGridId(pid, gridCfgId)
    self.playerGridIds[pid] = self.playerGridIds[pid] or {}
    self.playerGridIds[pid][gridCfgId] = true
end

function Starmap:delPlayerGridId(pid, gridCfgId)
    if not self.playerGridIds[pid] then
        return
    end
    self.playerGridIds[pid][gridCfgId] = nil
end

function Starmap:addUnionGridId(unionId, gridCfgId)
    self.unionGridIds[unionId] = self.unionGridIds[unionId] or {}
    self.unionGridIds[unionId][gridCfgId] = true
end

function Starmap:delUnionGridId(unionId, gridCfgId)
    if not self.unionGridIds[unionId] then
        return
    end
    self.unionGridIds[unionId][gridCfgId] = nil
end

function Starmap:addGridOwnerCache(pid, unionId, isPrivate, gridCfgId)
    self:addPlayerGridId(pid, gridCfgId)
    if unionId and unionId ~= 0 and not isPrivate then
        self:addUnionGridId(unionId, gridCfgId)
    end
    self:pushGridCountInfo(pid, unionId)
    if isPrivate then
        self:firstGetGridAct(pid, gridCfgId)
    end
end

function Starmap:delGridOwnerCache(pid, unionId, isPrivate, gridCfgId)
    self:delPlayerGridId(pid, gridCfgId)
    if unionId and unionId ~= 0 and not isPrivate then
        self:delUnionGridId(unionId, gridCfgId)
    end
    self:pushGridCountInfo(pid, unionId)
end

function Starmap:getChainIndexById(chainId)
    return gg.getChainIndexById(chainId)
end

function Starmap:linkUnionToBeginGrid(pid, unionId, beginGridId)
    local beginGrid = self.grids[beginGridId]
    if not beginGrid then
        local ok = self:initGrid(beginGridId)
        if not ok then
            return
        end
        beginGrid = self.grids[beginGridId]
    end
    if beginGrid:hasUnionId(unionId) then
        return
    end
    local is_ok = gg.unionProxy:call("setUnionBeginGrid", pid, unionId, beginGridId)
    if is_ok then
        beginGrid:addUnionId(unionId)
    end
    return true
end

function Starmap:randBeginGrid(pid, unionId)
    -- local chainId = gg.unionProxy:call("getUnionChainId", pid, unionId)
    -- if not chainId or chainId == 0 then
    --     return
    -- end
    -- local chainIndex = self:getChainIndexById(chainId)
    -- if chainIndex == 0 then
    --     return
    -- end
    -- local idList = gg.getExcelCfg("starmapBegin")[chainIndex]
    local idList = gg.getExcelCfg("starmapBegin")
    local size = table.count(idList or {})
    if size == 0 then
        return
    end
    local index = math.random(1, size)
    local beginGridId = tonumber(idList[index])
    if not self:linkUnionToBeginGrid(pid, unionId, beginGridId) then
        return
    end
    return beginGridId
end

function Starmap:selectBeginGrid(pid, unionId)
    -- TODO: this code can be better
    local beginGridId = gg.unionProxy:call("getUnionBeginGridId", pid, unionId)
    if not beginGridId then
        return
    end
    if beginGridId > 0 then
        return beginGridId
    end
    beginGridId = self:randBeginGrid(pid, unionId)
    return beginGridId
end

function Starmap:getPlayerGridCount(pid)
    local cnt = 0
    local grids = self.playerGridIds[pid] or {}
    for cfgId, v in pairs(grids) do
        local grid = self.grids[cfgId]
        if grid and grid:isPrivate() then
            cnt = cnt + 1
        end
    end
    return cnt
end

function Starmap:getPlayersGridCounts(pids)
    local result = {}
    for pid, _ in pairs(pids) do
        result[pid] = self:getPlayerGridCount(pid)
    end
    return result
end

function Starmap:getUnionGridCount(unionId)
    local cnt = 0
    local grids = self.unionGridIds[unionId] or {}
    for cfgId, v in pairs(grids) do
        cnt = cnt + 1
    end
    return cnt
end

function Starmap:getGridCountInfo(pid, unionId)
    local pGridCount = self:getPlayerGridCount(pid)
    local uGridCount = 0
    if unionId then
        uGridCount = self:getUnionGridCount(unionId)
    end
    local pGridMax = self:getGridPlayerMax()
    local uGridMax = self:getGridUnionMax()
    return {
        pGridCount = pGridCount,
        uGridCount = uGridCount,
        pGridMax = pGridMax,
        uGridMax = uGridMax,
    }
end

function Starmap:pushGridCountInfo(pid, unionId)
    local info = self:getGridCountInfo(pid, unionId)
    gg.playerProxy:sendOnline(pid, "onGridCountInfoUpdate", info)
end

function Starmap:firstGetGridAct(pid, gridCfgId)
    local cfg = gg.getExcelCfg("starmapConfig")[gridCfgId]
    if cfg.level < constant.ACT_STARMAP_FIRST_GET_LV then
        return
    end
    if table.count(cfg.perMakeRes) == 0 then
        return
    end
    gg.activityProxy:send("updateActivityData", constant.ACT_STARMAP_FIRST_GET, {pid = pid})
end

function Starmap:_getUnionGridsScore(unionId)
    local score = 0
    local gridIds = self.unionGridIds[unionId]
    for gridId, _ in pairs(gridIds or {}) do
        local cfg = gg.getExcelCfg("starmapConfig")[gridId]
        if cfg then
            score = score + cfg.point
        end
    end
    return score
end

--""
function Starmap:enterStarmap(pid, unionId, gridCfgIds, playerName)
    local list = {}
    local inGrids = {}
    for i, cfgId in ipairs(gridCfgIds) do
        local grid = self.grids[cfgId]
        if grid then
            grid:updateOwnerInfo(pid, unionId, playerName)
            local data = grid:packGridBrief(pid, unionId)
            table.insert(list, data)
            inGrids[cfgId] = 1
        end
    end
    local favoriteGridsDict = gg.unionProxy:call("getUnionFavoriteGridState", pid, unionId, inGrids)
    local beginGridId = self:selectBeginGrid(pid, unionId)
    local season = 0
    local lifeTime = 0
    local info = gg.matchProxy:call("getCurrentMatchInfo", constant.MATCH_BELONG_UNION, constant.MATCH_TYPE_SEASON)
    if info then
        season = info.season
        local endTime = string.totime(info.endTime)
        lifeTime = math.max(endTime - gg.time.time(), 0)
    end
    local score = gg.shareProxy:call("getStarmapMatchUnionRankField", unionId, "score", 0)
    -- local score = self:_getUnionGridsScore(unionId)
    -- local personScore = gg.unionProxy:call("getPersonalGridScore", unionId)
    return {
        list = list,
        beginGridId = beginGridId,
        season = season,
        lifeTime = lifeTime,
        score = score,
        favoriteGridsDict = favoriteGridsDict,
    }
end

function Starmap:getGridScore(pid, unionId)
    local score = gg.shareProxy:call("getStarmapMatchUnionRankField", unionId, "score", 0)
    -- local score = self:_getUnionGridsScore(unionId)
    -- local personScore = gg.unionProxy:call("getPersonalGridScore", unionId)
    return score
end

--""
function Starmap:getMyGridList(pid, unionId)
    local dict = self.playerGridIds[pid]
    if not dict then
        return {}
    end
    local list = {}
    for cfgId in pairs(dict) do
        local grid = self.grids[cfgId]
        table.insert(list, grid:packGridBrief(pid, unionId))
    end
    return list
end

 --""
function Starmap:getFavoriteGridsInfo(pid, ids, unionId)
    local list = {}
    for i, v in ipairs(ids) do
        local grid = self.grids[v]
        if grid then
            table.insert(list, grid:packGridMini(pid, unionId))
        else
            table.insert(list, {cfgId = v})
        end
    end

    local unionlist = {}
    local favoriteGrids = gg.unionProxy:call("getUnionFavoriteGrids", pid, unionId)
    for k, v in pairs(favoriteGrids) do
        local grid = self.grids[k]
        if grid then
            local _info = grid:packGridMini(pid, unionId)
            _info.tag = v
            table.insert(unionlist, _info)
        else
            table.insert(unionlist, {cfgId = k, tag = v})
        end
    end
    return {list = list, unionlist = unionlist}
end

function Starmap:initGrid(cfgId)
    local gridCfg = gg.getExcelCfg("starmapConfig")[cfgId]
    if not gridCfg then
        return
    end
    local grid = self:createStarMapGrid(gridCfg)
    grid:init()
    self.grids[gridCfg.cfgId] = grid
    gg.savemgr:autosave(grid)
    return true
end

 --""
function Starmap:scoutGrid(pid, cfgId, unionId)
    local grid = self.grids[cfgId]
    if not grid then
        -- local ok = self:initGrid(cfgId)
        -- if not ok then
        --     return
        -- end
        -- grid = self.grids[cfgId]
        return
    end
    return grid:packDetail(pid, unionId)
end

--""
function Starmap:putBuildOnGrid(pid, cfgId, buildId, pos, unionId)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:putBuild(pid, buildId, pos, unionId)
end

-- ""
function Starmap:addDefenseBuildOnGrid(pid, cfgId, buildId, pos, unionId)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:addDefenselBuild(pid, buildId, pos, unionId)
end

--""
function Starmap:putBuildListOnGrid(pid, cfgId, buildList, unionId, from)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:putBuildList(pid, buildList, unionId, from)
end

--""
function Starmap:moveBuildOnGrid(pid, cfgId, buildId, pos)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:moveBuild(pid, buildId, pos)
end

--""
function Starmap:delBuildOnGrid(pid, cfgId, buildId)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:delBuild(pid, buildId)
end

--""
function Starmap:storeBuildOnGrid(pid, cfgId, buildId)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:storeBuild(pid, buildId)
end

--""nft""
function Starmap:storeUnionNftOnGrid(pid, unionId, cfgId, buildId)
    local grid = self.grids[cfgId]
    if not grid then
        return false
    end
    return grid:storeUnionNft(pid, unionId, buildId)
end

function Starmap:giveUpMyGrid(pid, cfgId)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:giveUpMyGrid(pid)
end

function Starmap:giftWithMyGrid(pid, cfgId, toPid)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:giftWithMyGrid(pid, toPid)
end


function Starmap:onCampaignBegin(cfgId, defender)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    grid:onCampaignBegin(defender)
end

function Starmap:onJoinCampaign(cfgId, pid)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    grid:onJoinCampaign()
end

function Starmap:onCampaignEnd(cfgId, result, winner, armyType, remainBuilds, joinPids, attackContriDegree, vipLevel)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    grid:onCampaignEnd(result, winner, armyType, remainBuilds, joinPids, attackContriDegree, vipLevel)
end

function Starmap:dissolveUnionHandle(unionId, ownerGrids)
    for cfgId, pid in pairs(ownerGrids) do
        local grid = self.grids[cfgId]
        assert(grid.owner.unionId == unionId, "starmap grid not belong union")
        grid:dissolveUnionHandle()
    end
    return true
end

function Starmap:getPersonalGridScore(members, unionChain)
    local chainIndex = gg.getChainIndexById(unionChain)
    local score = 0
    for i, pid in ipairs(members) do
        for cfgId, _ in pairs(self.playerGridIds[pid] or {}) do
            local grid = self.grids[cfgId]
            if grid then
                if grid.owner.playerId ~= 0 and grid.owner.isPrivate then
                    local cfg = gg.getExcelCfg("starmapConfig")[cfgId]
                    if cfg and cfg.chainID == chainIndex then
                        score = score + cfg.point
                    end
                end
            end
        end
    end
    return score
end

function Starmap:matchSeasonEndHandle()
    local gridIds = {}
    for cfgId, grid in pairs(self.grids) do
        -- skynet.fork(function(gridCfgId)
        --     local ok = self:doMatchSeasonEndClear(gridCfgId)
        --     if ok then
        --         table.insert(gridIds, cfgId)
        --     end
        -- end, cfgId)
        local ok = self:doMatchSeasonEndClear(cfgId)
        if ok then
            table.insert(gridIds, cfgId)
        end
    end
    return gridIds
end

function Starmap:doMatchSeasonEndClear(gridCfgId)
    local grid = self.grids[gridCfgId]
    if not grid then
        return
    end
    return grid:doMatchSeasonEndClear()
end

function Starmap:getUnionGrids(pid, unionId)
    local gridShareTime = {}
    local gridIds = self.unionGridIds[unionId]
    for gridId, _ in pairs(gridIds or {}) do
        local grid = self.grids[gridId]
        if grid then
            gridShareTime[gridId] = grid:getShareResLeftTime()
        end
    end
    local personScore = gg.shareProxy:call("getStarmapMatchUnionRankField", unionId, "personScore", 0)
    -- local personScore = gg.unionProxy:call("getPersonalGridScore", unionId)
    return {gridShareTime = gridShareTime, personScore = personScore}
end

function Starmap:getPersonalGrids(pid)
    local gridShareTime = {}
    for cfgId, _ in pairs(self.playerGridIds[pid] or {}) do
        local grid = self.grids[cfgId]
        if grid then
            if grid.owner.playerId ~= 0 and grid:isPrivate() then
                gridShareTime[cfgId] = grid:getShareResLeftTime()
            end
        end
    end
    return {gridShareTime = gridShareTime}
end

function Starmap:updatePersonalGrids(pid, unionId, unionName)
    for cfgId, _ in pairs(self.playerGridIds[pid] or {}) do
        local grid = self.grids[cfgId]
        if grid then
            if grid.owner.playerId ~= 0 and grid:isPrivate() then
                grid.owner.unionId = unionId
                grid.owner.unionName = unionName
            end
        end
    end
    return true
end

function Starmap:_checkNearGridBelong(x, y, attacker, parentGridId)
    local isCan = false
    local nearGrids = self:getNearGrids(x, y)
    for nCfgId, nPos in pairs(nearGrids) do
        local tmpCfg = gg.getExcelCfg("starmapConfig")[nCfgId]
        if tmpCfg then
            if tmpCfg.parentGrid ~= parentGridId then
                local tmpGrid
                if tmpCfg.parentGrid == 0 then
                    tmpGrid = self.grids[nCfgId]
                else
                    tmpGrid = self.grids[tmpCfg.parentGrid]
                end
                if tmpGrid then
                    if tmpGrid:isBeginGrid() then
                        if tmpGrid:hasUnionId(attacker.unionId) then
                            isCan = true
                            break
                        end
                    else
                        if tmpGrid.owner and
                        (tmpGrid.owner.unionId == attacker.unionId or
                        (tmpGrid.owner.isPrivate and tmpGrid.owner.playerId == attacker.playerId)) then
                            isCan = true
                            break
                        end
                    end
                else
                    --do nothing
                end
            end
        end
    end
    return isCan
end

function Starmap:canBattle(pid, gridCfgId, attacker, isInner, armyType)
    local gridCfg = gg.getExcelCfg("starmapConfig")[gridCfgId]
    if not gridCfg then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_EXIST))
        return
    end
    if gridCfg.type == constant.STARMAP_BEGIN_GRID then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_BATTLE_BEGIN_GRID))
        return
    end
    if gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF then
        if armyType ~= constant.BATTLE_ARMY_TYPE_SELF then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_BELONG_TYPE_SELF))
            return
        end
    end
    if gridCfg.parentGrid ~= 0 then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_BATTLE_SUB_GRID))
        return
    end
    -- local chainIndex = self:getChainIndexById(attacker.chainId)
    -- if chainIndex == 0 then
    --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_UNION_CHAINID_DIFF))
    --     return
    -- end
    -- if chainIndex ~= gridCfg.chainID then
    --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_UNION_CHAINID_DIFF))
    --     return
    -- end
    local matchInfos = gg.matchProxy:getInStartMatchs(constant.MATCH_BELONG_UNION, constant.MATCH_TYPE_SEASON)
    if table.count(matchInfos) == 0 and not constant.MATCH_STARMAP_TEST_START then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_MATCH_NOT_START))
        return
    end
    local isCan = false
    if isInner then--editor
        isCan = true
    else
        if table.count(gridCfg.groupGrid) == 0 then
            isCan = self:_checkNearGridBelong(gridCfg.pos.x, gridCfg.pos.y, attacker, gridCfgId)
        else
            for i, v in ipairs(gridCfg.groupGrid) do
                if v == gridCfgId then--parent
                    isCan = self:_checkNearGridBelong(gridCfg.pos.x, gridCfg.pos.y, attacker, gridCfgId)
                    if isCan then
                        break
                    end
                else
                    local tmpCfg = gg.getExcelCfg("starmapConfig")[v]
                    if tmpCfg then
                        isCan = self:_checkNearGridBelong(tmpCfg.pos.x, tmpCfg.pos.y, attacker, gridCfgId)
                        if isCan then
                            break
                        end
                    end
                end
            end
        end
    end
    if not isCan then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NEAR_NOT_BELONG))
    end
    return isCan
end

--""
function Starmap:startBattle(pid, cfgId, battleInfo)
    --""
    if not self:canBattle(pid, cfgId, battleInfo.attacker, battleInfo.isInner, battleInfo.armyType) then
        return
    end
    local grid = self.grids[cfgId]
    if not grid then
        local ok = self:initGrid(cfgId)
        if not ok then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_INIT_ERROR))
            return
        end
        grid = self.grids[cfgId]
    end
    if grid.status == constant.STARMAP_GRID_STATUS_PROTECT then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_PROTECTED))
        return
    end
    local gridCfg = gg.getExcelCfg("starmapConfig")[cfgId]
    if gridCfg.belongType == constant.STARMAP_BELONG_TYPE_SELF then
        if grid.owner and grid.owner.playerId == pid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_BATTLE_SELF))
            return
        end
    end
    if battleInfo.armyType == constant.BATTLE_ARMY_TYPE_UNION then  --""
        local armyInfos = gg.unionProxy:call("takeStarmapCampaignArmy", battleInfo.attacker.unionId, battleInfo.attacker.playerId, cfgId, battleInfo.fightArmys)
        if not armyInfos or not next(armyInfos) then
            gg.centerProxy:playerSay(battleInfo.attacker.playerId, util.i18nFormat(errors.CAMPAIGN_ARMY_EMPTY))
            return
        end
        battleInfo.armyInfos = armyInfos
    end
    gg.matchProxy:send("joinMatch", constant.MATCH_BELONG_UNION, battleInfo.attacker.playerId, battleInfo.attacker.unionId)

    return grid:startBattle(pid, battleInfo)
end

--""
function Starmap:endBattle(pid, cfgId, battleResult)
    local grid = self.grids[cfgId]
    if not grid then
        return
    end
    return grid:endBattle(pid, battleResult)
end

function Starmap:addUnionFavoriteGrid(pid, unionId, cfgId, tag)
    local gridCfg = gg.getExcelCfg("starmapConfig")[cfgId]
    if not gridCfg then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_EXIST))
        return
    end
    gg.unionProxy:send("addUnionFavoriteGrid", pid, unionId, cfgId, tag)
end

function Starmap:delUnionFavoriteGrid(pid, unionId, cfgId)
    local gridCfg = gg.getExcelCfg("starmapConfig")[cfgId]
    if not gridCfg then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_EXIST))
        return
    end
    gg.unionProxy:send("delUnionFavoriteGrid", pid, unionId, cfgId)
end

function Starmap:transferBeginGrid(pid, unionId, dstCfgId)
    local gridCfg = gg.getExcelCfg("starmapConfig")[dstCfgId]
    if not gridCfg then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_EXIST))
        return
    end
    if gridCfg.type ~= constant.STARMAP_BEGIN_GRID then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_BEGIN_GRID))
        return
    end
    local beginGridId = gg.unionProxy:call("getUnionBeginGridId", pid, unionId)
    if not beginGridId or beginGridId == 0 then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_HAS_BEGIN_GRID))
        return
    end
    local srcGridCfg = gg.getExcelCfg("starmapConfig")[beginGridId]
    if srcGridCfg.chainID ~= gridCfg.chainID then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_UNION_CHAINID_DIFF))
        return
    end
    local dstBeginGrid = self.grids[dstCfgId]
    if not dstBeginGrid then
        local ok = self:initGrid(dstCfgId)
        if not ok then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_INIT_ERROR))
            return
        end
        dstBeginGrid = self.grids[dstCfgId]
    end
    local srcBeginGridId = gg.unionProxy:call("transferBeginGrid", pid, unionId, dstCfgId)
    if not srcBeginGridId then
        return
    end
    local srcBeginGrid = self.grids[srcBeginGridId]
    if not srcBeginGrid then
        local is_ok = gg.unionProxy:call("setUnionBeginGrid", pid, unionId, 0)
        if is_ok then
        end
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_HAS_BEGIN_GRID))
        return
    end
    srcBeginGrid:delUnionId(unionId)
    dstBeginGrid:addUnionId(unionId)
    return dstCfgId
end

 --""
function Starmap:getMinimapInfo(pid, unionId)
    local list = {}
    local starmapMarkCfg = gg.getExcelCfg("StarMapMark")
    for k, v in pairs(starmapMarkCfg) do
        local grid = self.grids[k]
        if grid then
            table.insert(list, grid:packGridMini(pid, unionId))
        end
    end
    return list
end

--""
function Starmap:getUnionFavoriteGridList(pid, unionId)
    local list = {}
    local favoriteGrids = gg.unionProxy:call("getUnionFavoriteGrids", pid, unionId)
    for k, v in pairs(favoriteGrids) do
        local grid = self.grids[k]
        if grid then
            table.insert(list, grid:packGridMini(pid, unionId))
        end
    end
    return list
end

function Starmap:getUnionGridsPos(unionId)
    local ret = {}
    local starmapConfig = gg.getExcelCfg("starmapConfig")
    local gridIds = self.unionGridIds[unionId]
    for gridId, _ in pairs(gridIds or {}) do
        local cfg = starmapConfig[gridId]
        if cfg then
            ret[gridId] = {x = cfg.pos.x, y = cfg.pos.y}
        else
            ret[gridId] = {x = 0, y = 0}
        end
    end
    return ret
end

function Starmap:checkNftInGrid(pid, nfts)
    local ids = {}
    nfts = nfts or {}
    for nftId,v in pairs(nfts) do
        local grid = self.grids[v.refBy]
        if grid then    --nft""
            if not grid.builds[nftId] then  -- ""nft
                table.insert(ids, nftId)
            else
                local build = grid.builds[nftId]
                if build.level < v.level then
                    grid.builds[nftId].level = v.level -- ""
                end
            end
        else  --nft"",""nft
            if v.refBy ~= 0 then
                table.insert(ids,nftId)
            end
        end
    end
    gg.playerProxy:send(pid, "correctNftBuildData", ids)
end

function Starmap:onSecond()
    for _, grid in pairs(self.grids) do
        if grid.onSecond then
            grid:onSecond()
        end
    end
end

function Starmap:onMinute()
    -- for _, grid in pairs(self.grids) do
    --     if grid.onMinute then
    --         grid:onMinute()
    --     end
    -- end
end

function Starmap:shutdown()
    local n = 0
    for _, grid in pairs(self.grids) do
        if grid.shutdown then
            grid:shutdown()
            gg.savemgr:closesave(grid)
            n = n + 1
        end
        if n == 100 then
            skynet.sleep(1)
            n = 0
        end
    end
end

function Starmap:saveall()
    local n = 0
    for _, grid in pairs(self.grids) do
        grid:save_to_db()
        n = n + 1
        if n == 100 then
            skynet.sleep(1)
            n = 0
        end
    end
end


return Starmap