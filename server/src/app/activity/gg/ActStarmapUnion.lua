local ActStarmapUnion = class("ActStarmapUnion", ggclass.ActivityOnce)

function ActStarmapUnion:ctor(cfgId)
    ActStarmapUnion.super.ctor(self, cfgId)
end

function ActStarmapUnion:onStartTimeout()
end

function ActStarmapUnion:onEndTimeout()
    if self.isReward then
        return
    end
    self:starmapUnionRankReward()
    self.isReward = true
    return true
end

function ActStarmapUnion:starmapUnionRankReward()
    local rankInfos = gg.matchProxy:getCurrentMatchRank(constant.MATCH_BELONG_UNION, constant.MATCH_TYPE_SEASON, nil)
    local info = rankInfos[1]
    if not info then
        return
    end
    local cfg = self:getActCfg()
    local topN = cfg.rankTopN - 1
    local unionDict = {}
    for i, v in ipairs(info.rankMembers) do
        if v.score > 0 then
            unionDict[v.unionId] = {
                rank = i,
                score = v.score,
                matchCfgId = info.cfgId,
                actCfgId = self.cfgId,
            }
        end
        if i >= topN then
            break
        end
    end
    for k, data in pairs(unionDict) do
        gg.unionProxy:send("starmapUnionRankReward", k, data.rank, data.score, data.matchCfgId, data.actCfgId)
    end
end

function ActStarmapUnion:onMinute()
end

return ActStarmapUnion
