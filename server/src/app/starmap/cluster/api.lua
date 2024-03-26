gg.api = gg.api or {}

local api = gg.api

function api.onGameServerStart()
    gg.starmap:saveall()
end

function api.selectBeginGrid(pid, unionId)
    return gg.starmap:selectBeginGrid(pid, unionId)
end

function api.enterStarmap(pid, unionId, gridCfgIds, playerName)
    return gg.starmap:enterStarmap(pid, unionId, gridCfgIds, playerName)
end

function api.getMyGridList(pid, unionId)
    return gg.starmap:getMyGridList(pid, unionId)
end

function api.getFavoriteGridsInfo(pid, ids, unionId)
    return gg.starmap:getFavoriteGridsInfo(pid, ids, unionId)
end

function api.dissolveUnionHandle(unionId, ownerGrids)
    return gg.starmap:dissolveUnionHandle(unionId, ownerGrids)
end

function api.getPersonalGridScore(members, unionChain)
    return gg.starmap:getPersonalGridScore(members, unionChain)
end

function api.getGridScore(pid, unionId)
    return gg.starmap:getGridScore(pid, unionId)
end

function api.matchSeasonEndHandle()
    return gg.starmap:matchSeasonEndHandle()
end

function api.getPlayersGridCounts(pids)
    return gg.starmap:getPlayersGridCounts(pids)
end

function api.getUnionGrids(pid, unionId)
    return gg.starmap:getUnionGrids(pid, unionId)
end

function api.checkNftInGrid(pid, nfts)
    return gg.starmap:checkNftInGrid(pid, nfts)
end

function api.getPersonalGrids(pid)
    return gg.starmap:getPersonalGrids(pid)
end

function api.updatePersonalGrids(pid, unionId, unionName)
    return gg.starmap:updatePersonalGrids(pid, unionId, unionName)
end

function api.getGridCountInfo(pid, unionId)
    return gg.starmap:getGridCountInfo(pid, unionId)
end

function api.addUnionFavoriteGrid(pid, unionId, cfgId, tag)
    return gg.starmap:addUnionFavoriteGrid(pid, unionId, cfgId, tag)
end

function api.delUnionFavoriteGrid(pid, unionId, cfgId)
    return gg.starmap:delUnionFavoriteGrid(pid, unionId, cfgId)
end

function api.transferBeginGrid(pid, unionId, dstCfgId)
    return gg.starmap:transferBeginGrid(pid, unionId, dstCfgId)
end

function api.getMinimapInfo(pid, unionId)
    local list = gg.starmap:getMinimapInfo(pid, unionId)
    return list
end

function api.getUnionFavoriteGridList(pid, unionId)
    return gg.starmap:getUnionFavoriteGridList(pid, unionId)
end

function api.getUnionGridsPos(unionId)
    return gg.starmap:getUnionGridsPos(unionId)
end

function api.scoutGrid(pid, cfgId, unionId)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.scoutGrid, gg.starmap, pid, cfgId, unionId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.putBuildOnGrid(pid, cfgId, buildId, pos, unionId)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.putBuildOnGrid, gg.starmap, pid, cfgId, buildId, pos, unionId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.addDefenseBuildOnGrid(pid, cfgId, buildId, pos, unionId)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.addDefenseBuildOnGrid, gg.starmap, pid, cfgId, buildId, pos, unionId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.putBuildListOnGrid(pid, cfgId, buildList, unionId, from)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.putBuildListOnGrid, gg.starmap, pid, cfgId, buildList, unionId, from)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.moveBuildOnGrid(pid, cfgId, buildId, pos)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.moveBuildOnGrid, gg.starmap, pid, cfgId, buildId, pos)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.delBuildOnGrid(pid, cfgId, buildId)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.delBuildOnGrid, gg.starmap, pid, cfgId, buildId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.storeBuildOnGrid(pid, cfgId, buildId)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.storeBuildOnGrid, gg.starmap, pid, cfgId, buildId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.storeUnionNftsOnGrid(pid, unionId, storeList)
    local result = {}
    for k, v in pairs(storeList) do
        local cfgId = v.cfgId
        local buildId = v.buildId
        local ok, ret = gg.sync:once_do("Grid:"..cfgId, gg.starmap.storeUnionNftOnGrid, gg.starmap, pid, unionId, cfgId, buildId)
        if ok and ret then
            result[ret.id] = ret
        end
    end
    return result
end

function api.startBattle(pid, cfgId, battleInfo)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.startBattle, gg.starmap, pid, cfgId, battleInfo)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.endBattle(pid, cfgId, battleResult)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.endBattle, gg.starmap, pid, cfgId, battleResult)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.getUnionStarmapCampaignReports(unionId, campaignIdList)
    local reports = gg.campaignMgr:getUnionStarmapCampaignReports(unionId, campaignIdList)
    return reports
end

function api.getUnionStarmapBattleReports(unionId, campaignId, pageNo, pageSize)
    local reports = gg.campaignMgr:getUnionStarmapBattleReports(unionId, campaignId, pageNo, pageSize)
    return reports
end

function api.getPersonalStarmapCampaignReports(pid, campaignIdList)
    local reports = gg.campaignMgr:getPersonalStarmapCampaignReports(pid, campaignIdList)
    return reports
end

function api.getPersonalStarmapBattleReports(campaignId, pageNo, pageSize)
    local reports = gg.campaignMgr:getPersonalStarmapBattleReports(campaignId, pageNo, pageSize)
    return reports
end

function api.getStarmapCampaignPlyStatistics(unionId, campaignId)
    local reports = gg.campaignMgr:getStarmapCampaignPlyStatistics(unionId, campaignId)
    return reports
end


function api.giveUpMyGrid(pid, cfgId)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.giveUpMyGrid, gg.starmap, pid, cfgId)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

function api.giftWithMyGrid(pid, cfgId, toPid)
    local ok, ret1, ret2 = gg.sync:once_do("Grid:"..cfgId, gg.starmap.giftWithMyGrid, gg.starmap, pid, cfgId, toPid)
    if not ok then
        return gg.centerProxy:playerSay(pid, util.i18nFormat(errors.SERVER_INTERNAL_ERR, tostring(ret1)))
    end
    return ret1, ret2
end

return api