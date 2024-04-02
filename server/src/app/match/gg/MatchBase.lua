local MatchBase = class("MatchBase")


function MatchBase:ctor(cfgId)
    self.dirty = false
    self.savetick = 300
    self.savename = "match"
    self.cfgId = cfgId
    self.isNotice = false
    self.isStart = false
    self.isEnd = false
    self.startVer = self:getStartVer()
    self.nowVer = self:getStartVer()
    self.members = {}       --""
    self.rankVersions = {}  --"" { ver : {ver, rankMembers} }
end

function MatchBase:init(matchCfg)
    local ok = self:load_from_db()
    if not ok then
        self.dirty = true
        self:save_to_db()
    end
end

function MatchBase:exit()
    self.dirty = true
    self:save_to_db()
end

function MatchBase:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    gg.mongoProxy.match:update({cfgId = self.cfgId}, data, true, false)
    self.dirty = false
end

function MatchBase:load_from_db()
    local data = gg.mongoProxy.match:findOne({ cfgId = self.cfgId })
    if not data then
        return false
    end
    self:deserialize(data)
    return true
end

function MatchBase:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.isNotice = self.isNotice
    data.isStart = self.isStart
    data.isEnd = self.isEnd
    data.members = {}
    data.rankVersions = {}
    data.startVer = self.startVer
    data.nowVer = self.nowVer
    for k, v in pairs(self.members) do
        data.members[tostring(k)] = v
    end
    for k, v in pairs(self.rankVersions) do
        local info = {}
        local chainRankData = {}
        local chainRankTime = {}
        for kk, vv in pairs(v) do
            if kk == "chainRankData" then
                for kkk, vvv in pairs(vv) do
                    chainRankData[tostring(kkk)] = vvv
                end
            elseif kk == "chainRankTime" then
                for kkk, vvv in pairs(vv) do
                    chainRankTime[tostring(kkk)] = vvv
                end
            else
                info[kk] = vv
            end
        end
        info.chainRankData = chainRankData
        info.chainRankTime = chainRankTime
        table.insert(data.rankVersions, info)
    end
    return data
end

function MatchBase:deserialize(data)
    if not data then
        return
    end
    self.isNotice = data.isNotice or false
    self.isStart = data.isStart or false
    self.isEnd = data.isEnd or false
    self.startVer = data.startVer or self:getStartVer()
    self.nowVer = data.nowVer or self.startVer
    self.members = {}
    self.rankVersions = {}
    if data.members and next(data.members) then
        for k, v in pairs(data.members) do
            self.members[tonumber(k)] = v
        end
    end
    for k, v in pairs(data.rankVersions or {}) do
        local info = {}
        local chainRankData = {}
        local chainRankTime = {}
        for kk, vv in pairs(v) do
            if kk == "chainRankData" then
                for kkk, vvv in pairs(vv) do
                    chainRankData[tonumber(kkk)] = vvv
                end
            elseif kk == "chainRankTime" then
                for kkk, vvv in pairs(vv) do
                    chainRankTime[tonumber(kkk)] = vvv
                end
            else
                info[kk] = vv
            end
        end
        info.chainRankData = chainRankData
        info.chainRankTime = chainRankTime
        self.rankVersions[v.ver] = info
    end
end

function MatchBase:getMatchCfg()
    local matchCfgs = gg.shareProxy:call("getDynamicCfg", constant.REDIS_MATCH_CONFIG)
    -- local matchCfgs = gg.dynamicCfg:get("MatchConfig")
    for k, v in pairs(matchCfgs) do
        if v.cfgId == self.cfgId then
            return v
        end
    end
end

function MatchBase:getMatchRewardCfg()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    local rewardCfgs = {}
    local cfgs = gg.dynamicCfg:get("MatchRewardConfig")
    for k, v in pairs(cfgs) do
        if v.cfgId == matchCfg.rewardCfgId then
            table.insert(rewardCfgs, v)
        end
    end
    return rewardCfgs
end

function MatchBase:isValid()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return false
    end
    if matchCfg.status == 0 then
        return false
    end
    return util.betweenCfgTime(matchCfg, "noticeTime", "showEndTime")
end

function MatchBase:isNoticeStage()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return false
    end
    return util.betweenCfgTime(matchCfg, "noticeTime", "startTime")
end

function MatchBase:isStartStage()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return false
    end
    return util.betweenCfgTime(matchCfg, "startTime", "endTime")
end

function MatchBase:isStopStage()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return false
    end
    local now = gg.time.time()
    local endTime = string.totime(matchCfg.endTime)
    if now < endTime then
        return false
    end
    return true
end

function MatchBase:getCanRewardVer()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    local nowTime = gg.time.time()
    if matchCfg.rewardType == constant.MATCH_REWARD_TYPE_DATE_TIME then --""
        local rewardTime = string.totime(matchCfg.rewardTime)
        for ver, rankInfo in pairs(self.rankVersions) do
            if not rankInfo.isDistribute and nowTime > rewardTime then  --""
                return ver
            end
        end
    elseif matchCfg.rewardType == constant.MATCH_REWARD_TYPE_DELAY_SEC then --""
        for k, v in pairs(self.rankVersions) do
            local rewardTime = v.rewardTime or 0
            if rewardTime == 0 then
                rewardTime = string.totime(matchCfg.endTime) + matchCfg.delayRewardTime
            else
                rewardTime = v.rewardTime
            end
            if not v.isDistribute and nowTime > rewardTime then
                return k
            end
        end
    end
end

function MatchBase:isRewardStage()
    local ver = self:getCanRewardVer()
    if not ver then
        return false
    end
    return true
end

function MatchBase:getStage()
    local stage = constant.MATCH_STATE.NONE
    if self:isNoticeStage() then
        stage = constant.MATCH_STATE.NOTICE
    elseif self:isStartStage() then
        stage = constant.MATCH_STATE.BEGIN
    elseif self:isStopStage() then
        stage = constant.MATCH_STATE.END
    elseif self:isRewardStage() then
        stage = constant.MATCH_STATE.REWARD
    end
    return stage
end

function MatchBase:_getTimeVersion(matchCfg, vtime)
    local version
    if matchCfg.matchType == constant.MATCH_TYPE_WEEK then
        version = gg.time.weekno(vtime)
    elseif matchCfg.matchType == constant.MATCH_TYPE_MONTH then
        version = gg.time.monthno(vtime)
    elseif matchCfg.matchType == constant.MATCH_TYPE_SEASON then
        version = matchCfg.season
    end
    return version
end

--""
function MatchBase:getCurrentVer()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    local now = gg.time.time()
    local startTime = string.totime(matchCfg.startTime)
    local endTime = string.totime(matchCfg.endTime)
    local verTime = now
    if now < startTime then
        verTime = startTime
    elseif now > endTime then
        verTime = endTime
    end
    return self:_getTimeVersion(matchCfg, verTime)
end

--""
function MatchBase:getStartVer()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    local startTime = string.totime(matchCfg.startTime)
    local endTime = string.totime(matchCfg.endTime)
    return self:_getTimeVersion(matchCfg, startTime)
end

function MatchBase:getCurVerRankInfo()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    local curVer = self:getCurrentVer()
    if not curVer then
        logger.logf("info","MatchBase","getCurVerRankInfo cfgId=%s, matchType=%s",  tostring(self.cfgId), tostring(matchCfg.matchType or ""))
        return
    end
    if not self.rankVersions[curVer] then
        self.nowVer = curVer
        local rankVersion = {
            ver = curVer,
            rankMembers = {}, 
            chainRankData = {}, 
            chainRankTime = {}, --""
            rankTime = 0,         --""
            rewardTime = 0,       --""
            isDistribute = false, --""
        }
        if matchCfg.matchType == constant.MATCH_TYPE_WEEK then --""
            rankVersion.rankTime = gg.time.weekzerotime() + gg.time.WEEK_SECS
        elseif matchCfg.matchType == constant.MATCH_TYPE_MONTH then
            rankVersion.rankTime = gg.time.nextmonthzerotime() --""1""
        end
        self.rankVersions[curVer] = rankVersion
        self.dirty = true
    end
    return self.rankVersions[curVer]
end

--""
function MatchBase:joinMatch(pid, id)
    if not self:isNoticeStage() and not self:isStartStage() then
        return
    end
    if self.members[id] then
        return
    end
    self.dirty = true
    self.members[id] = true
    return true
end

--""
function MatchBase:updateMatchRankInfo(rankMembers)
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    if not util.betweenCfgTime(matchCfg, "startTime", "endTime") then
        return
    end
    local rankVersion = self:getCurVerRankInfo()
    if rankVersion then
        rankVersion.rankMembers = rankMembers
        rankVersion.rankTime = gg.time.time()
    end
    self.dirty = true
    -- gg.centerProxy:broadCast2Game("onMatchUpdate", "onMatchUpdate", self.cfgId, self:serialize())
end

function MatchBase:updateMatchChainRankInfo(chainRankData)
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    if not util.betweenCfgTime(matchCfg, "startTime", "endTime") then
        return
    end
    local rankVersion = self:getCurVerRankInfo()
    if rankVersion then
        for k, v in pairs(chainRankData) do
            rankVersion.chainRankData[k] = v
            rankVersion.chainRankTime[k] = gg.time.time()
        end
    end
    self.dirty = true
    -- gg.centerProxy:broadCast2Game("onMatchUpdate", "onMatchUpdate", self.cfgId, self:serialize())
end


--""("")
function MatchBase:checkNoticeTimeout()
    if not self:isNoticeStage() then
        return
    end
    if self.isNotice then
        return
    end
    --""
    self.isNotice = true
    self:onNoticeTimeout()
    self.dirty = true
end

--""
function MatchBase:checkStartTimeout()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    if self.isStart then
        return
    end
    local startTime = string.totime(matchCfg.startTime)
    if gg.time.time() < startTime then
        return
    end
    self.isStart = true
    self:onStartTimeout()
    self.dirty = true
    -- gg.centerProxy:broadCast2Game("onMatchUpdate", "onMatchStart", self.cfgId, self:serialize())
end

--""
function MatchBase:checkEndTimeout()
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    if self.isEnd then
        return
    end
    local endTime = string.totime(matchCfg.endTime)
    if gg.time.time() < endTime then
        return
    end
    self.isEnd = true
    self:onEndTimeout()
    self.dirty = true
    -- gg.centerProxy:broadCast2Game("onMatchUpdate", "onMatchEnd", self.cfgId, self:serialize())
end

function MatchBase:getRewardByRank(rank)
    local matchRewardCfg = self:getMatchRewardCfg()
    if not matchRewardCfg then
        return
    end
    for k, v in pairs(matchRewardCfg) do
        if rank >= v.startRank and rank <= v.endRank then
            return v
        end
    end
end

--""
function MatchBase:distributeReward(rankVersion)
    local matchCfg = self:getMatchCfg()
    if not matchCfg then
        return
    end
    local matchRewardCfg = self:getMatchRewardCfg()
    if not matchRewardCfg then
        return
    end
    return self:onDistributeReward(rankVersion)
    -- gg.centerProxy:broadCast2Game("onMatchUpdate", "onMatchReward", self.cfgId, self:serialize())
end

--""
function MatchBase:checkRewardTimeout()
    local ver = self:getCanRewardVer()
    if not ver then
        return
    end
    local rankInfo = self.rankVersions[ver]
    if not rankInfo.isDistribute then
        rankInfo.isDistribute = true
        logger.logf("info","MatchBase","checkRewardTimeout cfgId=%s, ver=%s, ok=%s, startTime=%s",  tostring(self.cfgId), tostring(ver), tostring(ok), tostring(skynet.timestamp()))
        local ok = self:distributeReward(rankInfo)
        self.dirty = true
        logger.logf("info","MatchBase","checkRewardTimeout cfgId=%s, ver=%s, ok=%s, stopTime=%s",  tostring(self.cfgId), tostring(ver), tostring(ok), tostring(skynet.timestamp()))
    end
end


function MatchBase:onSecond()
    self:checkNoticeTimeout()
    self:checkStartTimeout()
    self:checkEndTimeout()
    self:checkRewardTimeout()
end

function MatchBase:onMinute()
end

function MatchBase:onFiveMinute()

end

return MatchBase