local MatchMgr = class("MatchMgr")

function MatchMgr:ctor()
    self.matchs = {}
end

function MatchMgr:init(bInit)
    self:addNewMatchs()
end

function MatchMgr:addNewMatchs()
    local pa = ggclass.cparallel.new()
    local matchCfgs = gg.shareProxy:call("getDynamicCfg", constant.REDIS_MATCH_CONFIG)
    -- local matchCfgs = gg.dynamicCfg:get("MatchConfig")
    for k, v in pairs(matchCfgs or {}) do
        if not self.matchs[v.cfgId] then
            pa:add(function(matchCfg)
                local match
                if v.belong == constant.MATCH_BELONG_UNION then
                    match = ggclass.StarmapMatch.new(matchCfg.cfgId)
                elseif v.belong == constant.MATCH_BELONG_PVP then
                    match = ggclass.PvpMatch.new(matchCfg.cfgId)
                end
                if match:isValid() then
                    match:init(matchCfg)
                    self.matchs[matchCfg.cfgId] = match
                    gg.savemgr:autosave(match)
                else
                    match = nil
                end
            end, v)
        end
    end
    pa:wait()
end

--""
function MatchMgr:clearInvalidMatchs()
    local pa = ggclass.cparallel.new()
    local invalidMatchIds = {}
    for cfgId, v in pairs(self.matchs) do
        pa:add(function(match)
            if not match:isValid() then
                table.insert(invalidMatchIds, cfgId)
                match:exit()
                gg.savemgr:closesave(match)
            end
        end, v)
    end
    pa:wait()
    for _, cfgId in pairs(invalidMatchIds) do
        local match = self.matchs[cfgId]
        if match then
            self.matchs[cfgId] = nil
            match = nil
        end
    end
end

--"", ""
function MatchMgr:joinMatch(belong, pid, id)
    local ret = false
    local matchInfo = self:getCurrentMatchInfo(belong, constant.MATCH_TYPE_SEASON)
    if matchInfo then
        local match = self.matchs[matchInfo.cfgId]
        ret = match:joinMatch(pid, id)
    end
    local weekMatchIds = self:getMatchCfgId(belong, constant.MATCH_TYPE_WEEK)
    for i, v in ipairs(weekMatchIds) do
        local match = self.matchs[v]
        if match then
            ret = ret or match:joinMatch(pid, id)
        end
    end
    local monthMatchIds = self:getMatchCfgId(belong, constant.MATCH_TYPE_MONTH)
    for i, v in ipairs(monthMatchIds) do
        local match = self.matchs[v]
        if match then
            ret = ret or match:joinMatch(pid, id)
        end
    end
    
    return ret
end

--""
function MatchMgr:updateMatchRankInfo(cfgId, rankMembers)
    local match = self.matchs[cfgId]
    if not match then
        return
    end
    match:updateMatchRankInfo(rankMembers)
end

function MatchMgr:updateMatchChainRankInfo(cfgId, chainRankData)
    local match = self.matchs[cfgId]
    if not match then
        return
    end
    match:updateMatchChainRankInfo(chainRankData)
end

--"", ""
function MatchMgr:refreshAllMatchs()
    self:clearInvalidMatchs()
    self:addNewMatchs()
end

function MatchMgr:getMatchStage(belong)
    local ret = {}
    for cfgId, match in pairs(self.matchs) do
        local matchCfg = match:getMatchCfg()
        if matchCfg then
            if matchCfg.belong == constant.MATCH_BELONG_PVP then
                ret[cfgId] = match:getStage()
            end
        end
    end
    return ret
end

function MatchMgr:getMatchData(belong, matchType)
    local list = {}
    for cfgId, match in pairs(self.matchs) do
        local matchCfg = match:getMatchCfg()
        if matchCfg and matchCfg.belong == belong then
            if matchType then
                if matchCfg.matchType == matchType then
                    table.insert(list, match:serialize())
                end
            else
                table.insert(list, match:serialize())
            end
        end
    end
    return list
end

function MatchMgr:getMatchCfgId(belong, matchType)
    local list = {}
    for cfgId, match in pairs(self.matchs) do
        local matchCfg = match:getMatchCfg()
        if matchCfg and matchCfg.belong == belong then
            if matchType then
                if matchCfg.matchType == matchType then
                    table.insert(list, match.cfgId)
                end
            else
                table.insert(list, match.cfgId)
            end
        end
    end
    return list
end

function MatchMgr:findSelfCurrentMatchRank(rankMembers, myUnionId, cfgId)
    if not myUnionId then
        return
    end
    local match = self.matchs[cfgId]
    for iii, vvv in ipairs(rankMembers) do
        if vvv.unionId == myUnionId then
            local cpy = gg.deepcopy(vvv)
            cpy.index = iii
            local rewardCfg = match:getRewardByRank(iii)
            if rewardCfg then
                cpy.ratio = rewardCfg.gvgPercentage
                cpy.hyt = rewardCfg.hyt
                cpy.mit = rewardCfg.mit
            end
            return cpy
        end
    end
end

function MatchMgr:findSelfCurrentMatchChainRank(chainRankData, myUnionId, chainIdx)
    if not myUnionId then
        return
    end
    for iii, vvv in ipairs(chainRankData[chainIdx] or {}) do
        if vvv.unionId == myUnionId then
            local cpy = gg.deepcopy(vvv)
            cpy.index = iii
            return cpy
        end
    end
end

function MatchMgr:getCurrentMatchRank(belong, matchType, myUnionId)
    local list = {}
    for cfgId, match in pairs(self.matchs) do
        local matchCfg = match:getMatchCfg()
        if matchCfg.belong == belong and matchCfg.matchType == matchType and match:isValid() then
            if match.nowVer then
                local rankInfo = {}
                rankInfo.cfgId = match.cfgId
                for kk, vv in pairs(match.rankVersions) do
                    if vv.ver == match.nowVer then
                        rankInfo.rankMembers = {}
                        for iii, vvv in ipairs(vv.rankMembers) do
                            local cpy = gg.deepcopy(vvv)
                            cpy.index = iii
                            local rewardCfg = match:getRewardByRank(iii)
                            if rewardCfg then
                                cpy.ratio = rewardCfg.gvgPercentage
                                cpy.hyt = rewardCfg.hyt
                                cpy.mit = rewardCfg.mit
                            end
                            table.insert(rankInfo.rankMembers, cpy)
                            if iii >= constant.MATCH_STARMAP_RANK_SIZE then
                                break
                            end
                        end
                        rankInfo.rankTime = vv.rankTime
                        rankInfo.rewardTime = vv.rewardTime
                        rankInfo.version = vv.ver
                        rankInfo.selfRank = self:findSelfCurrentMatchRank(vv.rankMembers, myUnionId, match.cfgId)
                        break
                    end
                end
                table.insert(list, rankInfo)
            end
        end
    end
    return list
end

function MatchMgr:getCurrentMatchChainRank(belong, matchType, myUnionId, chainIdx)
    local list = {}
    for cfgId, match in pairs(self.matchs) do
        local matchCfg = match:getMatchCfg()
        if matchCfg.belong == belong and matchCfg.matchType == matchType and match:isValid() then
            if match.nowVer then
                local rankInfo = {}
                rankInfo.cfgId = match.cfgId
                for kk, vv in pairs(match.rankVersions) do
                    if vv.ver == match.nowVer then
                        rankInfo.rankMembers = {}
                        for iii, vvv in ipairs(vv.chainRankData[chainIdx] or {}) do
                            local cpy = gg.deepcopy(vvv)
                            cpy.index = iii
                            table.insert(rankInfo.rankMembers, cpy)
                            if iii >= constant.MATCH_STARMAP_RANK_SIZE then
                                break
                            end
                        end
                        rankInfo.rankTime = vv.chainRankTime[chainIdx] or gg.time.time()
                        rankInfo.rewardTime = vv.rewardTime
                        rankInfo.version = vv.ver
                        rankInfo.selfRank = self:findSelfCurrentMatchChainRank(vv.chainRankData, myUnionId, chainIdx)
                        break
                    end
                end
                table.insert(list, rankInfo)
            end
        end
    end
    return list
end

function MatchMgr:getCurrentMatchSelfRank(belong, matchType, myUnionId)
    local list = {}
    for cfgId, match in pairs(self.matchs) do
        local matchCfg = match:getMatchCfg()
        if matchCfg.belong == belong and matchCfg.matchType == matchType and match:isValid() then
            if match.nowVer then
                local rankInfo = {}
                rankInfo.cfgId = match.cfgId
                for kk, vv in pairs(match.rankVersions) do
                    if vv.ver == match.nowVer then
                        rankInfo.rankTime = vv.rankTime
                        rankInfo.rewardTime = vv.rewardTime
                        rankInfo.version = vv.ver
                        rankInfo.selfRank = self:findSelfCurrentMatchRank(vv.rankMembers, myUnionId, match.cfgId)
                        break
                    end
                end
                table.insert(list, rankInfo)
            end
        end
    end
    return list
end

function MatchMgr:getCurrentMatchChainSelfRank(belong, matchType, myUnionId, chainIdx)
    local list = {}
    for cfgId, match in pairs(self.matchs) do
        local matchCfg = match:getMatchCfg()
        if matchCfg.belong == belong and matchCfg.matchType == matchType and match:isValid() then
            if match.nowVer then
                local rankInfo = {}
                rankInfo.cfgId = match.cfgId
                for kk, vv in pairs(match.rankVersions) do
                    if vv.ver == match.nowVer then
                        rankInfo.rankTime = vv.chainRankTime[chainIdx] or gg.time.time()
                        rankInfo.rewardTime = vv.rewardTime
                        rankInfo.version = vv.ver
                        rankInfo.selfRank = self:findSelfCurrentMatchChainRank(vv.chainRankData, myUnionId, chainIdx)
                        break
                    end
                end
                table.insert(list, rankInfo)
            end
        end
    end
    return list
end

function MatchMgr:getCurrentMatchInfo(belong, matchType)
    local info
    for cfgId, match in pairs(self.matchs) do
        local matchCfg = match:getMatchCfg()
        if matchCfg.belong == belong and matchCfg.matchType == matchType and match:isValid() then
            info = {
                cfgId = matchCfg.cfgId,
                name = matchCfg.name,
                season = matchCfg.season,
                noticeTime = matchCfg.noticeTime,
                startTime = matchCfg.startTime,
                endTime = matchCfg.endTime,
                showEndTime = matchCfg.showEndTime,
                rewardTime = matchCfg.rewardTime,
            }
        end
    end
    return info
end

function MatchMgr:handleMatchDataCmd(cfgId, op, opParam)
    local cfg
    local matchCfgs = gg.shareProxy:call("getDynamicCfg", constant.REDIS_MATCH_CONFIG)
    for k, v in pairs(matchCfgs or {}) do
        if v.cfgId == cfgId then
            cfg = v
            break
        end
    end
    if not cfg then
        return false, "cfg is not exist"
    end
    if op == "add" then
        if not self.matchs[cfg.cfgId] then
            local className = constant.MATCH_BELONG_CLASS[cfg.belong]
            if not className then
                return false, "className is not define"
            end
            local match = ggclass[className].new(cfg.cfgId)
            if not match:isValid() then
                return false, "match is not valid"
            end
            match:init(cfg)
            self.matchs[cfg.cfgId] = match
            gg.savemgr:autosave(match)
        else
            return false, "match already exist"
        end
    elseif op == "remove" then
        if not self.matchs[cfg.cfgId] then
            return false, "match is not exist"
        end
        local match = self.matchs[cfg.cfgId]
        match:exit()
        gg.savemgr:closesave(match)
        self.matchs[cfg.cfgId] = nil
    elseif op == "modify" then
        if not self.matchs[cfg.cfgId] then
            return false, "match is not exist"
        end
        local match = self.matchs[cfg.cfgId]
        if not opParam or opParam == "" then
            return false, "opParam is error"
        end
        if opParam == "restart" then
            if match.isEnd then
                match.isEnd = false
                match.dirty = true
            end
        elseif opParam == "reDistribute" then
            for k, v in pairs(match.rankVersions) do
                if v.ver == match.nowVer then
                    v.rewardTime = 0
                    v.isDistribute = false
                    break
                end
            end
            match.dirty = true
        elseif opParam == "stop" then
            if not match.isEnd then
                match.isEnd = true
                match.dirty = true
            end
        end
    else
        return false, "op is error"
    end
    return true
end

function MatchMgr:onSecond()
    for _, match in pairs(self.matchs) do
        skynet.fork(function()
            match:onSecond()
        end)
    end
end

function MatchMgr:onMinuteUpdate()
    for _, match in pairs(self.matchs) do
        skynet.fork(function()
            match:onMinute()
        end)
    end
    self:refreshAllMatchs()
end

function MatchMgr:onFiveMinuteUpdate()
    for _, match in pairs(self.matchs) do
        skynet.fork(function()
            match:onFiveMinute()
        end)
    end
end

function MatchMgr:exit()
    for _, match in pairs(self.matchs) do
        match:exit()
        gg.savemgr:closesave(match)
    end
end

function MatchMgr:saveall()
    for _, match in pairs(self.matchs) do
        match:save_to_db()
    end
end


return MatchMgr