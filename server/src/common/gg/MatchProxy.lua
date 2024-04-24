local MatchProxy = class("MatchProxy")

function MatchProxy:ctor()
    self.matchProxy = ggclass.Proxy.new("center",".match")
    self.matchs = {}
end

function MatchProxy:init()
    -- local docs = gg.mongoProxy.match:find({})
    -- for _, data in pairs(docs) do
    --     self.matchs[data.cfgId] = data
    -- end
end

function MatchProxy:getMatchCfg(cfgId)
    local matchCfgs = gg.shareProxy:call("getDynamicCfg", constant.REDIS_MATCH_CONFIG)
    -- local matchCfgs = gg.dynamicCfg:get("MatchConfig")
    return matchCfgs[cfgId]
end

--""
function MatchProxy:isMatchInShow(cfgId)
    local matchCfg = self:getMatchCfg(cfgId)
    if not matchCfg then
        return false
    end
    if matchCfg.status == 0 then
        return false
    end
    return util.betweenCfgTime(matchCfg, "noticeTime", "showEndTime")
end

--""
function MatchProxy:isMatchNoticeStage(cfgId)
    local matchCfg = self:getMatchCfg(cfgId)
    if not matchCfg then
        return false
    end
    return util.betweenCfgTime(matchCfg, "noticeTime", "startTime")
end

--""
function MatchProxy:isMatchStartStage(cfgId)
    local matchCfg = self:getMatchCfg(cfgId)
    if not matchCfg then
        return false
    end
    return util.betweenCfgTime(matchCfg, "startTime", "endTime")
end

--""
function MatchProxy:isMatchEndStage(cfgId)
    local matchCfg = self:getMatchCfg(cfgId)
    if not matchCfg then
        return false
    end
    return util.betweenCfgTime(matchCfg, "endTime", "showEndTime")
end

--""
--belong 1-"" 2-pvp
--matchType 1-"" 2-"" 3-""
function MatchProxy:getInStartMatchs(belong, matchType)
    local ret = {}
    local list = self:getMatchData(belong, matchType)
    for i, v in ipairs(list) do
        if self:isMatchStartStage(v.cfgId) then
            table.insert(ret, v)
        end
    end
    return ret
end

--""
--belong 1-"" 2-pvp
function MatchProxy:getInShowMatchs(belong, matchType)
    local ret = {}
    local list = self:getMatchData(belong, matchType)
    for i, v in ipairs(list) do
        if self:isMatchInShow(v.cfgId) then
            table.insert(ret, v)
        end
    end
    return ret
end

--""
--belong 1-"" 2-pvp
--matchType 1-"" 2-"" 3-""
function MatchProxy:getMatchData(belong, matchType)
    local list = self:call("getMatchData", belong, matchType)
    return list
end

--""
--belong 1-"" 2-pvp
--matchType 1-"" 2-"" 3-""
function MatchProxy:getCurrentMatchRank(belong, matchType, myUnionId)
    local list = self:call("getCurrentMatchRank", belong, matchType, myUnionId)
    return list
end

function MatchProxy:getCurrentMatchChainRank(belong, matchType, myUnionId, chainIndex)
    local list = self:call("getCurrentMatchChainRank", belong, matchType, myUnionId, chainIndex)
    return list
end


--""
function MatchProxy:onMatchUpdate(subCmd, cfgId, matchData)
end

function MatchProxy:call(cmd, ...)
    return self.matchProxy:call("api", cmd, ...)
end

function MatchProxy:send(cmd, ...)
    return self.matchProxy:send("api", cmd, ...)
end

function MatchProxy:start()
    -- self:call("onGameServerStart")
    -- self:init()
end

return MatchProxy