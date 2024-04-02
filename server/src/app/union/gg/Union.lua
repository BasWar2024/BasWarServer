local Union = class("Union")

function Union.getDaoPositionCfg(unionJob)
    local cfgMap = cfg.get("etc.cfg.daoPosition")
    for k,v in pairs(cfgMap) do
        if v.accessLevel == unionJob then
            return v
        end
    end
    return nil
end

function Union.getDaoLevelCfg(level)
    return gg.getExcelCfg("daoLevel")[level]
end

function Union.getUnionJobMaxCnt(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg or cfg.maxCound <= 0 then
        return 999999
    end
    return cfg.maxCound 
end

function Union.getUnionJobContribute(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return 0
    end
    return cfg.Contribute or 0
end

function Union.getUnionJobRewardRatio(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return 0
    end
    return (cfg.rewardRatio or 0) / 10000
end

--""
function Union.unionJobCanTransfer(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isTransfer == 1 
end

--""
function Union.unionJobCanAppointed(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isAppointed == 1 
end

--""
function Union.unionJobCanRemove(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isRemove == 1 
end

--""
function Union.unionJobCanOutgoing(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isOutgoing == 1
end

--""
function Union.unionJobCanKickOut(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isKickOut == 1
end

--""
function Union.unionJobCanAttack(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isAttack == 1
end

--""
function Union.unionJobCanTrainTroops(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isTrainTroops == 1
end

--""
function Union.unionJobCanBuildTowers(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isBuildTowers == 1
end

--""
function Union.unionJobCanResearch(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isResearch == 1
end

--""
function Union.unionJobCanPutBuild(unionJob)
    return unionJob > 0
end

--""
function Union.unionJobCanCollect(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.isCollect == 1
end

--""
function Union.unionJobCanMoveBeginGrid(unionJob)
    local cfg = Union.getDaoPositionCfg(unionJob)
    if not cfg then
        return false
    end
    return cfg.canMoveStartGrid == 1
end

function Union:ctor()
    self.dirty = false
    self.savetick = 300                                                                      --""
    if constant.STARMAP_USE_RAND_TIME_SAVE then
        self.savetick = 900 + math.random(constant.STARMAP_RAND_SAVE_TIME_MIN, constant.STARMAP_RAND_SAVE_TIME_MAX)
    end
    self.savename = "union"                                                                  --""
    
    --""
    self.unionId = 0                --""id
    self.unionName = ""             --""
    self.unionFlag = 0              --""
    self.unionNotice = ""           --""
    self.unionSharing = 100         --""
    self.unionChain = 0             --""
    self.enterType = 0              --""0-"",1-"" 2-""
    self.enterScore = 0             --""
    self.exp = 0                    --""
    self.unionLevel = 1             --""
    self.memberMax = 0              --""
    self.starCoin = 0               --""
    self.ice = 0                    --""
    self.titanium = 0               --""
    self.gas = 0                    --""
    self.carboxyl = 0               --""
    self.members = {}               --""
    self.applys = {}                --""
    self.applyVersion = 0           --""
    self.ownerGrids = {}            --""
    self.gridsScoreCount = {}       --""
    self.favoriteGrids = {}         --""
    self.items = {}                 --""NFT
    self.soliders = {}              --""
    self.builds = {}                --""
    self.techs = {}                 --""
    self.starCoinLimitAdd = 0       --""
    self.iceLimitAdd = 0            --""
    self.titaniumLimitAdd = 0       --""
    self.gasLimitAdd = 0            --""
    self.carboxylLimitAdd = 0       --""
    self.soliderSpaceAdd = 0        --""x
    self.editArmyPid = 0
    self.editArmyTick = 0
    self.campaignIdList = {}       --""id""
    self.campaignIdDict = {}       --""id""
    self.contriDegree = {}         --""
    self.nftsContriTick = {}       --""
    self.jobContriTick = {}        --""
    self.beginGridId = 0           --""
    self.transferBeginGridTime = 0 --""
    self.modifyNameTime = 0 --""
    self.combatDict = {}         --""
end

function Union:save_to_db()
    if not self.dirty then
        return
    end
    local data = self:serialize()
    gg.mongoProxy.union:update({unionId = self.unionId}, data, true, false)
    self.dirty = false
end

function Union:load_from_db()
    local data = gg.mongoProxy.union:findOne({unionId = self.unionId})
    if not data then
        return false
    end
    self:deserialize(data)
    return true
end

function Union:serialize()
    local data = {}
    data.unionId = self.unionId
    data.unionName = self.unionName
    data.unionFlag = self.unionFlag
    data.unionNotice = self.unionNotice
    data.unionSharing = self.unionSharing
    data.unionChain = self.unionChain
    data.enterType = self.enterType
    data.enterScore = self.enterScore
    data.memberMax = self.memberMax
    data.starCoin = self.starCoin
    data.ice = self.ice
    data.titanium = self.titanium
    data.gas = self.gas
    data.carboxyl = self.carboxyl
    data.starCoinLimitAdd = self.starCoinLimitAdd
    data.iceLimitAdd = self.iceLimitAdd
    data.titaniumLimitAdd = self.titaniumLimitAdd
    data.gasLimitAdd = self.gasLimitAdd
    data.carboxylLimitAdd = self.carboxylLimitAdd
    data.soliderSpaceAdd = self.soliderSpaceAdd
    data.editArmyPid = self.editArmyPid
    data.editArmyTick = self.editArmyTick
    data.beginGridId = self.beginGridId
    data.transferBeginGridTime = self.transferBeginGridTime
    data.modifyNameTime = self.modifyNameTime
    data.unionLevel = self.unionLevel
    data.exp = self.exp
    data.items = {}
    data.members = {}
    data.applys = {}
    data.applyVersion = self.applyVersion
    data.ownerGrids = {}
    data.gridsScoreCount = {}
    data.soliders = {}
    data.techs = {}
    data.builds = {}
    for k, v in pairs(self.items) do
        table.insert(data.items, v)
    end
    for k, v in pairs(self.members) do
        table.insert(data.members, v)
    end
    for k, v in pairs(self.applys) do
        table.insert(data.applys, v)
    end
    for k, v in pairs(self.ownerGrids) do
        data.ownerGrids[tostring(k)] = v
    end
    for k, v in pairs(self.gridsScoreCount) do
        data.gridsScoreCount[tostring(k)] = v
    end
    for k, v in pairs(self.soliders) do
        table.insert(data.soliders, v:serialize())
    end
    for k, v in pairs(self.techs) do
        table.insert(data.techs, v:serialize())
    end
    for k, v in pairs(self.builds) do
        table.insert(data.builds, v:serialize())
    end
    data.campaignIdList = {}
    for k, v in ipairs(self.campaignIdList) do
        table.insert(data.campaignIdList, v)
    end
    data.campaignIdDict = {}
    for k, v in pairs(self.campaignIdDict) do
        table.insert(data.campaignIdDict, k)
    end
    data.contriDegree = {}
    for k, v in pairs(self.contriDegree) do
        data.contriDegree[tostring(k)] = v
    end
    data.nftsContriTick = {}
    for k, v in pairs(self.nftsContriTick) do
        data.nftsContriTick[tostring(k)] = v
    end
    data.jobContriTick = {}
    for k, v in pairs(self.jobContriTick) do
        data.jobContriTick[tostring(k)] = v
    end
    data.favoriteGrids = {}
    for k, v in pairs(self.favoriteGrids) do
        data.favoriteGrids[tostring(k)] = v
    end
    data.combatDict = {}
    for k, v in pairs(self.combatDict) do
        data.combatDict[tostring(k)] = v
    end
    return data
end

function Union:deserialize(data)
    if not data then
        return
    end
    self.unionId = assert(data.unionId, "unionId is nil")
    self.unionName = data.unionName or ""
    self.unionFlag = data.unionFlag or 0
    self.unionNotice = data.unionNotice or ""
    self.unionSharing = data.unionSharing or 0
    self.unionChain = data.unionChain or 0
    self.enterType = data.enterType or 0
    self.enterScore = data.enterScore or 0
    self.memberMax = data.memberMax or 0
    self.starCoin = data.starCoin or 0
    self.ice = data.ice or 0
    self.titanium = data.titanium or 0
    self.gas = data.gas or 0
    self.carboxyl = data.carboxyl or 0
    self.starCoinLimitAdd = data.starCoinLimitAdd or 0
    self.iceLimitAdd = data.iceLimitAdd or 0
    self.titaniumLimitAdd = data.titaniumLimitAdd or 0
    self.gasLimitAdd = data.gasLimitAdd or 0
    self.carboxylLimitAdd = data.carboxylLimitAdd or 0
    self.soliderSpaceAdd = data.soliderSpaceAdd or 0
    self.editArmyPid = data.editArmyPid or 0
    self.editArmyTick = data.editArmyTick or 0
    self.beginGridId = data.beginGridId or 0
    self.transferBeginGridTime = data.transferBeginGridTime or 0
    self.modifyNameTime = data.modifyNameTime or 0
    self.unionLevel = data.unionLevel or 1
    self.exp = data.exp or 0
    self.items = {}
    self.soliders = {}
    self.builds = {}
    self.campaignIdList = {}
    if data.members and next(data.members) then
        for _, v in pairs(data.members) do
            v.online = 0
            self.members[v.playerId] = v
        end
    end
    if data.applys and next(data.applys) then
        for _, v in pairs(data.applys) do
            self.applys[v.playerId] = v
        end
    end
    self.applyVersion = data.applyVersion or 0
    if data.ownerGrids and next(data.ownerGrids) then
        for k, v in pairs(data.ownerGrids) do
            self.ownerGrids[tonumber(k)] = v
        end
    end
    for k, v in pairs(data.gridsScoreCount or {}) do
        self.gridsScoreCount[tonumber(k)] = v
    end
    if data.items and next(data.items) then
        for k, v in pairs(data.items) do
            self.items[v.id] = v
        end
    end
    if data.soliders and next(data.soliders) then
        for k, v in pairs(data.soliders) do
            local solider = ggclass.UnionSolider.new({union = self})
            solider:deserialize(v)
            self.soliders[v.cfgId] = solider
        end
    end
    if data.techs and next(data.techs) then
        for k, v in pairs(data.techs) do
            local tech = ggclass.UnionTech.new({union = self})
            tech:deserialize(v)
            self.techs[v.cfgId] = tech
        end
    end
    if data.builds and next(data.builds) then
        for k, v in pairs(data.builds) do
            local build = ggclass.UnionBuild.new({union = self})
            build:deserialize(v)
            self.builds[v.cfgId] = build
        end
    end
    for k, v in ipairs(data.campaignIdList or {}) do
        table.insert(self.campaignIdList, v)
    end
    for k, v in ipairs(data.campaignIdDict or {}) do
        self.campaignIdDict[v] = true
    end
    if data.contriDegree and next(data.contriDegree) then
        for k, v in pairs(data.contriDegree) do
            self.contriDegree[tonumber(k)] = v
        end
    end
    for k, v in pairs(data.nftsContriTick or {}) do
        self.nftsContriTick[tonumber(k)] = v
    end
    for k, v in pairs(data.jobContriTick or {}) do
        self.jobContriTick[tonumber(k)] = v
    end
    for k, v in pairs(data.favoriteGrids or {}) do
        self.favoriteGrids[tonumber(k)] = v
    end
    for k, v in pairs(data.combatDict or {}) do
        self.combatDict[tonumber(k)] = v
    end
end

function Union:packUnionInfo()
    local data = {}
    data.unionId = self.unionId
    data.unionName = self.unionName
    data.unionFlag = self.unionFlag
    data.unionChain = self.unionChain
    local president = self:getPresidentMember()
    if president then
        data.presidentName = president.playerName
    end
    return data
end

function Union:packUnionBase()
    local data = {}
    data.unionId = self.unionId
    data.unionName = self.unionName
    data.unionFlag = self.unionFlag
    data.unionNotice = self.unionNotice
    data.unionSharing = self.unionSharing
    data.unionChain = self.unionChain
    data.enterType = self.enterType
    data.memberMax = self:getMemberMax()
    data.memberCount = table.count(self.members)
    data.fightPower = self.fightPower
    data.starCoin = self.starCoin
    data.ice = self.ice
    data.titanium = self.titanium
    data.gas = self.gas
    data.carboxyl = self.carboxyl

    data.starCoinLimit = self:getStarCoinLimit()
    data.iceLimit = self:getIceLimit()
    data.gasLimit = self:getGasLimit()
    data.titaniumLimit = self:getTitaniumLimit()
    data.carboxylLimit = self:getCarboxylLimit()

    data.nftDefenseNum = self:getUnionNftDefenseNum()
    data.nftHeroNum = self:getUnionNftHeroNum()
    data.nftShipNum = self:getUnionNftShipNum()

    local president = self:getPresidentMember()
    if president then
        data.presidentName = president.playerName
        data.presidentPid = president.playerId
    end
    data.beginGridId = self.beginGridId
    data.score = self:getMatchScore()

    data.unionLevel = self.unionLevel
    data.exp = self.exp
    data.rank = self:getStarmapMatchRank()
    data.gridOutput = self:getGridOutput()
    data.plots = table.count(self.ownerGrids)
    return data
end

function Union:packUnionJoin()
    local data = {}
    data.unionId = self.unionId
    data.unionName = self.unionName
    data.unionFlag = self.unionFlag
    data.unionNotice = self.unionNotice
    data.unionSharing = self.unionSharing
    data.unionChain = self.unionChain
    data.enterType = self.enterType
    data.memberMax = self:getMemberMax()
    data.memberCount = table.count(self.members)
    data.fightPower = self.fightPower
    data.score = gg.shareProxy:call("getStarmapMatchUnionRankField", self.unionId, "score", 0)
    return data
end

function Union:packUnionRes(pid)
    local data = {}
    data.starCoin = self.starCoin
    data.ice = self.ice
    data.titanium = self.titanium
    data.gas = self.gas
    data.carboxyl = self.carboxyl
    data.contriDegree = math.floor((self.contriDegree[pid] or 0) * 1000)
    data.combatVal = math.floor((self.combatDict[pid] or 0) * 1000)
    return data
end

function Union:packUnionSoliders()
    local list = {}
    for k, v in pairs(self.soliders) do
        local info = {}
        info.cfgId = v.cfgId
        info.count = v.count
        info.level = v.level
        info.hpAddRatio = v.hpAddRatio
        info.atkAddRatio = v.atkAddRatio
        info.atkSpeedAddRatio = v.atkSpeedAddRatio
        info.genCount = v.genCount
        info.genTick = v:getLessTick()
        table.insert(list, info)
    end
    return list
end

function Union:packUnionBuilds()
    local list = {}
    for k, v in pairs(self.builds) do
        local info = {}
        info.cfgId = v.cfgId
        info.count = v.count
        info.level = v.level
        info.hpAddRatio = v.hpAddRatio
        info.atkAddRatio = v.atkAddRatio
        info.atkSpeedAddRatio = v.atkSpeedAddRatio
        info.genCount = v.genCount
        info.genTick = v:getLessTick()
        table.insert(list, info)
    end
    return list
end

function Union:packUnionNfts()
    local list = {}
    for k, v in pairs(self.items) do
        table.insert(list, v)
    end
    return list
end

function Union:packUnionMembers()
    local list = {}
    local pids = {}
    for k, v in pairs(self.members) do
        pids[v.playerId] = 0
    end
    local gridCounts = gg.starmapProxy:call("getPlayersGridCounts", pids)
    for k, v in pairs(self.members) do
        local info = {}
        info.playerId = v.playerId
        info.playerName = v.playerName
        info.playerHead = v.playerHead
        info.playerScore = v.playerScore
        info.matchScore = v.matchScore
        info.unionJob = v.unionJob
        info.fightPower = v.fightPower
        info.starCoin = v.starCoin
        info.ice = v.ice
        info.titanium = v.titanium
        info.gas = v.gas
        info.carboxyl = v.carboxyl
        info.chain = v.chain
        v.grids = gridCounts[v.playerId] or 0
        info.grids = v.grids
        if v.online and v.online > 0 then
            info.online = true
        else
            info.online = false
        end
        info.offline = v.offline or 0
        info.contriDegree = math.floor(self:getContriDegree(info.playerId) * 1000)
        info.combatVal = math.floor(self:getCombatVal(info.playerId) * 1000)
        table.insert(list, info)
    end
    return list
end

function Union:packUnionTechs()
    local list = {}
    for k, v in pairs(self.techs) do
        local info = {}
        info.cfgId = v.cfgId
        info.level = v.level
        info.levelUpTick = v:getLessTick()
        table.insert(list, info)
    end
    return list
end

function Union:packUnionApplyList()
    local list = {}
    for k, v in pairs(self.applys) do
        local info = {}
        info.playerId = v.playerId
        info.playerScore = v.playerScore
        info.fightPower = v.fightPower
        info.playerName = v.playerName
        info.playerHead = v.playerHead
        info.unionName = self.unionName
        info.unionId = self.unionId
        info.applyTime = v.applyTime
        info.answer = v.answer
        info.baseLevel = v.baseLevel
        info.chain = v.chain
        table.insert(list, info)
    end
    return list, self.applyVersion
end

function Union:getMemberMax()
    local cfg = Union.getDaoLevelCfg(self.unionLevel)
    if cfg then
        return cfg.memberMax
    end
    return 0
end

function Union:getSoldierSpace()
    local cfg = Union.getDaoLevelCfg(self.unionLevel)
    if cfg then
        return cfg.daoSoliderSpace or 0
    end
    return 0
end

function Union:getPresidentMember()
    for k, member in pairs(self.members) do
        if member.unionJob == constant.UNION_JOB_PRESIDENT then
            return member
        end
    end
    return nil
end

function Union:getCurUnionJobCnt(unionJob)
    local cnt = 0
    for k, member in pairs(self.members) do
        if member.unionJob == unionJob then
            cnt = cnt + 1
        end
    end
    return cnt
end

function Union:getUnionNftDefenseNum()
    local num = 0
    for i, v in pairs(self.items) do
        if v.itemType == constant.ITEM_BUILD then
            num = num + 1
        end
    end
    return num
end

function Union:getUnionNftHeroNum()
    local num = 0
    for i, v in pairs(self.items) do
        if v.itemType == constant.ITEM_HERO then
            num = num + 1
        end
    end
    return num
end

function Union:getUnionNftShipNum()
    local num = 0
    for i, v in pairs(self.items) do
        if v.itemType == constant.ITEM_WAR_SHIP then
            num = num + 1
        end
    end
    return num
end

function Union:getTechCurLevelUpCnt()
    local data = {}
    local num = 0
    for i, tech in pairs(self.techs) do
        if tech:getLessTick() > 0 then
            num = num + 1
            local mod = tech:getMod()
            if data[mod] then
                data[mod] = data[mod] + 1
            else
                data[mod] = 1
            end
        end
    end
    return data, num
end

function Union:getTechLevelUpMaxCnt()
    local maxCount = gg.getGlobalCfgIntValue("UnionTechLevelUpMaxCount", 1)
    return maxCount
end

function Union:getModTechLevelUpMaxCnt()
    local maxCount = gg.getGlobalCfgIntValue("UnionModTechLevelUpMaxCount", 1)
    return maxCount
end

--""
function Union:doRefresh()
    local initTechs = gg.getGlobalCfgTableValue("UnionInitTechs", {})
    for k, v in pairs(initTechs) do
        local techCfgId = v[1]
        local techLevel = v[2]
        if not self.techs[techCfgId] then
            local tech = ggclass.UnionTech.new({union = self})
            tech.cfgId = techCfgId
            tech.level = techLevel
            self.techs[techCfgId] = tech
        end
    end
    self:refreshUnlockTechs()
    self:initTechEffects()
    self:initJobMakeContributeTick()
end

function Union:initJobMakeContributeTick()
    for pid, member in pairs(self.members) do
        if not self.jobContriTick[pid] then
            self:setJobMakeContributeTick(member.unionJob, member.playerId)
        end
    end
    self.dirty = true
end

function Union:isEnoughPresetTechs(presetTechs)
    local isEnough = true
    if presetTechs and next(presetTechs) then
        for k, v in pairs(presetTechs) do
            local techCfgId = v[1]
            local techLevel = v[2]
            local targetTech = self.techs[techCfgId]
            if targetTech then
                if targetTech.level < techLevel then
                    isEnough = false
                    break
                end
            else
                isEnough = false
                break
            end
        end
    end
    return isEnough
end

function Union:refreshUnlockTechs()
    local techCfgs = cfg.get("etc.cfg.unionTech")
    for k, v in pairs(techCfgs) do
        local cfgId = v.cfgId
        local level = v.level
        local presetTechs = v.presetTechs
        if cfgId > 0 and level == 0 and not self.techs[cfgId] then --""
            if self:isEnoughPresetTechs(presetTechs) then
                local tech = ggclass.UnionTech.new({union = self})
                tech.cfgId = cfgId
                tech.level = level
                self.techs[cfgId] = tech
            end
        end
    end
end

function Union:unlockSolider(soliderCfgId, level)
    self.dirty = true
    local solider = ggclass.UnionSolider.new({union = self})
    solider.cfgId = soliderCfgId
    solider.level = level
    self.soliders[soliderCfgId] = solider
end

function Union:unlockBuild(buildCfgId, level)
    self.dirty = true
    local build = ggclass.UnionBuild.new({union = self})
    build.cfgId = buildCfgId
    build.level = level
    self.builds[buildCfgId] = build
end

function Union:getUnionSoliderCfg(soliderCfgId)
    local soliderCfgs = cfg.get("etc.cfg.unionSolider")
    return soliderCfgs[soliderCfgId]
end

function Union:getMember(pid)
    local member = self.members[pid]
    if not member then
        return nil
    end
    local memberInfo = gg.deepcopy(self.members[pid])
    memberInfo.unionId = self.unionId
    memberInfo.unionName = self.unionName
    memberInfo.unionFlag = self.unionFlag
    local president = self:getPresidentMember()
    if president then
        memberInfo.presidentName = president.playerName
    end
    return memberInfo
end

function Union:getRealMember(pid)
    return self.members[pid]
end

function Union:isMember(pid)
    if self.members[pid] then
        return true
    end
    return false
end

function Union:setMemberChain(pid, chain)
    local member = self.members[pid]
    if not member then
        return nil
    end
    member.chain = chain
    self.dirty = true
end

function Union:setMemberOnlineStatus(pid, status)
    local member = self.members[pid]
    if not member then
        return nil
    end
    member.online = status
    if status == 0 then
        member.offline = math.floor(skynet.timestamp() / 1000)
    else
        member.offline = 0
    end
end

function Union:getUnionShareInfo()
    local unionPercent = 5000
    local unionPowerInfo = { totalPower = 0, pidPowers = {} }
    return unionPercent, unionPowerInfo
end

function Union:setGridOwner(pid, cfgId)
    local member = self.members[pid]
    if not member then
        return
    end
    self.ownerGrids[cfgId] = pid
end

function Union:unsetGridOwner(pid, cfgId)
    if not self.ownerGrids[cfgId] then
        return
    end
    self.ownerGrids[cfgId] = nil
end

function Union:getMatchScore(matchCfgId)
    local starmapConfig = gg.getExcelCfg("starmapConfig")
    local score = 0
    -- local scoreDict = {}
    -- for cfgId, _ in pairs(self.ownerGrids) do
    --     local cfg = starmapConfig[cfgId]
    --     if cfg then
    --         score = score + cfg.point
    --         scoreDict[cfgId] = cfg.point
    --     end
    -- end
    for cfgId, v in pairs(self.gridsScoreCount) do
        local cfg = starmapConfig[cfgId]
        if cfg then
            score = score + v * cfg.point
        end
    end
    return score
end

function Union:getMatchChainScore(matchCfgId, chainIdx)
    local chainIndex = gg.getChainIndexById(self.unionChain)
    local starmapConfig = gg.getExcelCfg("starmapConfig")
    local score = 0
    -- local scoreDict = {}
    -- for cfgId, _ in pairs(self.ownerGrids) do
    --     local cfg = starmapConfig[cfgId]
    --     if cfg and cfg.chainID == chainIndex then
    --         score = score + cfg.point
    --         scoreDict[cfgId] = cfg.point
    --     end
    -- end
    for cfgId, v in pairs(self.gridsScoreCount) do
        local cfg = starmapConfig[cfgId]
        if cfg then
            score = score + v * cfg.point
        end
    end
    return score
end

function Union:getGridOutput()
    local starmapConfig = gg.getExcelCfg("starmapConfig")
    local output = 0
    for cfgId, _ in pairs(self.ownerGrids) do
        local cfg = starmapConfig[cfgId]
        if cfg then
            output = output + cfg.perMakeCarboxyl
            for i, v in ipairs(cfg.perMakeRes or {}) do
                if v[1] == constant.RES_CARBOXYL then
                    output = output + v[2]
                end
            end
        end
    end
    local makeResTime = gg.getGlobalCfgIntValue("LeagueMakeHYCD", 30)
    output = math.floor(output * gg.time.HOUR_SECS / makeResTime)
    return output
end

function Union:addGridScoreCount(cfgId, val)
    self.gridsScoreCount[cfgId] = (self.gridsScoreCount[cfgId] or 0) + val
end

function Union:reduceGridScoreCount(cfgId, val)
end

--""
function Union:distributeMatchReward(matchCfgId, rank, hyt, mit)
    if hyt == 0 and mit == 0 then
        return
    end
    local cfg
    local matchCfgs = gg.dynamicCfg:get("MatchConfig")
    for k, v in pairs(matchCfgs) do
        if v.cfgId == matchCfgId then
            cfg = v
            break
        end
    end
    local rewardMap = {}
    local valDict = {
        carboxyl = hyt,
        mit = mit,
    }
    local memValDict = self:_getMemValByContribute(valDict)
    for pid, pval in pairs(memValDict) do
        local rdata = {
            rank = rank,
            carboxyl = pval.carboxyl or 0,
            mit = pval.mit or 0,
            isMember = self:isMember(pid),
        }
        if cfg then
            rdata.type = cfg.matchType
            rdata.weekno = gg.time.weekno(string.totime(cfg.endTime))
        end
        rewardMap[pid] = rdata
    end
    self:_sendRankRewardRecord(rewardMap)
end

function Union:_sendRankRewardRecord(rewardMap)
    for pid, data in pairs(rewardMap) do
        skynet.fork(function(playerId, rewardInfo)
            gg.playerProxy:send(playerId, "starmapMatchRankReward", rewardInfo)
        end, pid, data)
    end
end

--""
function Union:initTechEffects()
    gg.techEffectMgr:resetEffect(self.techs, constant.UNION_TECH_DEFENSE_LEVEL_UP, self)
    gg.techEffectMgr:resetEffect(self.techs, constant.UNION_TECH_DEFENSE_ATTR_ADD, self)
    gg.techEffectMgr:resetEffect(self.techs, constant.UNION_TECH_SOLIDER_LEVEL_UP, self)
    gg.techEffectMgr:resetEffect(self.techs, constant.UNION_TECH_SOLIDER_ATTR_ADD, self)
    gg.techEffectMgr:resetEffect(self.techs, constant.UNION_TECH_RES_LIMIT, self)
    gg.techEffectMgr:resetEffect(self.techs, constant.UNION_TECH_SOLIDER_SPACE_ADD, self)

    gg.techEffectMgr:apply(self.techs, constant.UNION_TECH_DEFENSE_LEVEL_UP, self)
    gg.techEffectMgr:apply(self.techs, constant.UNION_TECH_DEFENSE_ATTR_ADD, self)
    gg.techEffectMgr:apply(self.techs, constant.UNION_TECH_SOLIDER_LEVEL_UP, self)
    gg.techEffectMgr:apply(self.techs, constant.UNION_TECH_SOLIDER_ATTR_ADD, self)
    gg.techEffectMgr:apply(self.techs, constant.UNION_TECH_RES_LIMIT, self)
    gg.techEffectMgr:apply(self.techs, constant.UNION_TECH_SOLIDER_SPACE_ADD, self)
end

function Union:getStarCoinLimit()
    return gg.getGlobalCfgIntValue("UnionStarCoinLimit", 100000000) + self.starCoinLimitAdd
end

function Union:getIceLimit()
    return gg.getGlobalCfgIntValue("UnionIceLimit", 100000000) + self.iceLimitAdd
end

function Union:getGasLimit()
    return gg.getGlobalCfgIntValue("UnionGasLimit", 100000000) + self.gasLimitAdd
end

function Union:getTitaniumLimit()
    return gg.getGlobalCfgIntValue("UnionTitaniumLimit", 100000000) + self.titaniumLimitAdd
end

function Union:getCarboxylLimit()
    return gg.getGlobalCfgIntValue("UnionCarboxylLimit", 100000000) + self.carboxylLimitAdd
end

function Union:getTrainQueueLimit()
    return gg.getGlobalCfgIntValue("UnionTrainQueueLimit", 8)
end

function Union:getNftMakeContributeCD()
    return gg.getGlobalCfgIntValue("nftMakeContributeCD", 14400)
end

function Union:getNftMakeContributeInterval()
    return gg.getGlobalCfgIntValue("nftMakeContributeInterval", 3600)
end

function Union:getNftMakeContributeTick(includeCD)
    local from = gg.time.time()
    if constant.STARMAP_CONTRI_USE_HOUR then
        from = gg.time.time() - (gg.time.minute() * 60 + gg.time.second())
    end
    local tick = from + self:getNftMakeContributeInterval()
    if includeCD then
        tick = tick + self:getNftMakeContributeCD()
    end
    return tick
end

function Union:getJobMakeContributeTick()
    local from = gg.time.time()
    if constant.UNION_CONTRI_USE_HOUR then
        from = gg.time.time() - (gg.time.minute() * 60 + gg.time.second())
    end
    local tick = from + gg.getGlobalCfgIntValue("unionPositionContributeCD", 3600)
    return tick
end

function Union.getNFTWarShipCfg(race, style, quality, level)
    return gg.getExcelCfgByFormat("warShipNftConfig", race, style, quality, level)
    -- local key = string.format("%s_%s_%s_%s", race, style, quality, level)
    -- local warShipCfgs = cfg.get("etc.cfg.warShipNftConfig")
    -- return warShipCfgs[key]
end

function Union.getNFTHeroCfg(race, style, quality, level)
    return gg.getExcelCfgByFormat("heroNftConfig", race, style, quality, level)
    -- local key = string.format("%s_%s_%s_%s", race, style, quality, level)
    -- local heroCfgs = cfg.get("etc.cfg.heroNftConfig")
    -- return heroCfgs[key]
end

function Union.getNFTBuildCfg(race, style, quality, level)
    return gg.getExcelCfgByFormat("buildNftConfig", race, style, quality, level)
    -- local key = string.format("%s_%s_%s_%s", race, style, quality, level)
    -- local buildCfgs = cfg.get("etc.cfg.buildNftConfig")
    -- return buildCfgs[key]
end

function Union:getNftConfig(id)
    local item = self.items[id]
    if not item then
        return
    end
    local cfg
    if item.itemType == constant.ITEM_WAR_SHIP then
        cfg = Union.getNFTWarShipCfg(item.race, item.style, item.quality, item.level)
    elseif item.itemType == constant.ITEM_HERO then
        cfg = Union.getNFTHeroCfg(item.race, item.style, item.quality, item.level)
    elseif item.itemType == constant.ITEM_BUILD then
        cfg = Union.getNFTBuildCfg(item.race, item.style, item.quality, item.level)
    end
    return cfg
end

function Union:getItemEntity(id)
    local item = self.items[id]
    if not item then
        return false
    end
    return item
end

function Union:getItemList(ids)
    local list = {}
    for i, v in ipairs(ids) do
        local item = self.items[v]
        if item then
            table.insert(list, item)
        end
    end
    return list
end

function Union:addableStarCoin(starCoin)
    local realStarCoin = starCoin
    if self.starCoin + starCoin > self:getStarCoinLimit() then --""
        realStarCoin = self:getStarCoinLimit() - self.starCoin
    end
    return realStarCoin
end

function Union:addableIce(ice)
    local realIce = ice
    if self.ice + ice > self:getIceLimit() then
        realIce = self:getIceLimit() - self.ice
    end
    return realIce
end

function Union:addableGas(gas)
    local realGas = gas
    if self.gas + gas > self:getGasLimit() then
        realGas = self:getGasLimit() - self.gas
    end
    return realGas
end

function Union:addableTitanium(titanium)
    local realTitanium = titanium
    if self.titanium + titanium > self:getTitaniumLimit() then
        realTitanium = self:getTitaniumLimit() - self.titanium
    end
    return realTitanium
end

function Union:addableCarboxyl(carboxyl)
    local realCarboxyl = carboxyl
    if self.carboxyl + carboxyl > self:getCarboxylLimit() then
        realCarboxyl = self:getCarboxylLimit() - self.carboxyl
    end
    return realCarboxyl
end

function Union:addableRes(resCfgId, val)
    local ADDABLE_RES_FUNC = {
        [constant.RES_STARCOIN] = "addableStarCoin",
        [constant.RES_ICE] = "addableIce",
        [constant.RES_CARBOXYL] = "addableCarboxyl",
        [constant.RES_TITANIUM] = "addableTitanium",
        [constant.RES_GAS] = "addableGas",
    }
    local func = ADDABLE_RES_FUNC[resCfgId]
    if not func then
        return val
    end
    local ret = Union[func](self, val)
    return ret
end

function Union:canTakeNft(id, itemType, pid)
    local item = self.items[id]
    if not item then
        return false
    end
    if item.itemType ~= itemType then
        return false
    end
    if item.ref ~= constant.REF_UNION then
        return false
    end
    if item.refBy > 0 then
        return false
    end
    if item.itemType == constant.ITEM_HERO then
        if (item.battleCd or 0) > gg.time.time() then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.HERO_IN_BATTLE_CD))
            return false
        end
    end
    return true
end

function Union:getDefenseBuildInfo(buildId, pid)
    local buildInfo = self.builds[buildId]
    if not buildInfo or buildInfo.count <=0 then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_NOT_EXIST))
        return false, -1
    end
    local build = {}
    buildInfo.count = buildInfo.count - 1
    build.cfgId = buildInfo.cfgId
    build.count = buildInfo.count
    build.level = buildInfo.level
    return build
end

function Union:takeNftForBattle(id, where, entire)
    local item = self.items[id]
    if not item then
        return false
    end
    item.refBy = where
    local cdTime = gg.getGlobalCfgIntValue("LeagueHeroBattleCD", 0)
    item.battleCd = gg.time.time() + cdTime
    if entire then
        return item
    end
    return item
end



function Union:returnBackNft(nftId)
    local item = self.items[nftId]
    if not item then
        return false
    end
    item.refBy = 0
    item.battleCd = 0
end

function Union:returnBackNftsWithEntity(nfts)
    for nftId, v in pairs(nfts) do
        local item = self.items[nftId]
        if item then
            item.refBy = 0
            item.curLife = v.curLife
        end
    end
    self.dirty = true
end

function Union:enoughSolider(soliderCfgId, soliderCount)
    if soliderCfgId == 0 or soliderCount == 0 then
        return true
    end
    local solider = self.soliders[soliderCfgId]
    if not solider then
        return false
    end
    if solider.count < soliderCount then
        return false
    end
    return true
end

function Union:isPersonalUnionSoldierEnough(pid, needSoliders)
    local solidersDict = {}
    for soliderCfgId, soliderCount in pairs(needSoliders) do
        local solider = self.soliders[soliderCfgId]
        if not solider then
            return false
        end
        if solider.level < 1 then
            return false
        end
        solidersDict[soliderCfgId] = {soliderCount = soliderCount, level = solider.level}
    end
    local isOk = gg.playerProxy:call(pid, "isPersonalUnionSoldierEnough", solidersDict)
    if not isOk then
        return false
    end
    return true
end

function Union:costPersonalUnionSoldier(pid, needSoliders)
    local solidersDict = {}
    for soliderCfgId, soliderCount in pairs(needSoliders) do
        local solider = self.soliders[soliderCfgId]
        if not solider then
            return false
        end
        if solider.level < 1 then
            return false
        end
        solidersDict[soliderCfgId] = {soliderCount = soliderCount, level = solider.level}
    end
    local isOk = gg.playerProxy:call(pid, "costPersonalUnionSoldier", solidersDict)
    if not isOk then
        return false
    end
    return true
end

function Union:takeSoliderForBattle(soliderCfgId, soliderCount)
    if soliderCfgId == 0 or soliderCount == 0 then
        return 
    end
    local solider = self.soliders[soliderCfgId]
    if not solider then
        return 
    end
    local soliderInfo = {}
    soliderInfo.id = snowflake.uuid()
    soliderInfo.cfgId = soliderCfgId
    soliderInfo.count = soliderCount
    soliderInfo.level = solider.level
    soliderInfo.hpAddRatio = solider.hpAddRatio
    soliderInfo.atkAddRatio = solider.atkAddRatio
    soliderInfo.atkSpeedAddRatio = solider.atkSpeedAddRatio
    -- solider.count = solider.count - soliderCount
    return soliderInfo
end

function Union:checkEditArmyTimeout()
    if self.editArmyTick == 0 or skynet.timestamp() < self.editArmyTick then
        return
    end
    self.dirty = true
    self.editArmyTick = 0
    self.editArmyPid = 0
end

function Union:_createStarmapBattleWarship()
    local cfgId = gg.getGlobalCfgIntValue("unionBattleWarshipCfgId", 1000001)
    local quality = gg.getGlobalCfgIntValue("unionBattleWarshipQuality", 0)
    local level = gg.getGlobalCfgIntValue("unionBattleWarshipLevel", 1)
    local life = ggclass.WarShip.randomWarShipLife(quality)
    local param = {
        cfgId = cfgId,
        quality = quality,
        level = level,
        life = life,
        curLife = life,
        skillLevel1 = 0,
        skillLevel2 = 0,
        skillLevel3 = 0,
        skillLevel4 = 0,
        skillLevel5 = 0,
    }
    local warShip = ggclass.WarShip.create(param)
    return warShip:serialize()
end

function Union:_getStarmapBattleSoliderCount(heroId)
    -- "" + "" +""
    local count = 0
    local baseCount = self:getSoldierSpace()
    -- local baseCount = gg.getGlobalCfgIntValue("unionBattleBaseSpace", 20)
    local techCount = self.soliderSpaceAdd
    local heroCount = 0
    local cfg = self:getNftConfig(heroId or 0)
    if cfg then
        heroCount = cfg.unionSoldierSpace
    end
    count = baseCount + techCount + heroCount
    local maxCount = gg.getGlobalCfgIntValue("unionBattleMaxSpace", 40)
    if count > maxCount then
        count = maxCount
    end
    return count
end

--""
function Union:takeStarmapCampaignArmy(pid, gridCfgId, unionArmys)
    -- if self.editArmyTick == 0 or skynet.timestamp() > self.editArmyTick then
    --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_YOU_NOT_LOCK_EDIT_ARMY))
    --     return 
    -- end
    -- if self.editArmyPid ~= pid then
    --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_OTHER_PLAYER_EDIT_ARMY))
    --     return 
    -- end
    local needItems = {}
    local needSoliders = {}
    for _, v in ipairs(unionArmys) do
        if v.warShipId and v.warShipId ~= 0 then
            needItems[v.warShipId] = needItems[v.warShipId] or 0
            needItems[v.warShipId] = needItems[v.warShipId] + 1
            if not self:canTakeNft(v.warShipId, constant.ITEM_WAR_SHIP, pid) then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
                return 
            end
        end
        for _, vv in ipairs(v.teams) do
            if vv.heroId and vv.heroId ~= 0 then
                needItems[vv.heroId] = needItems[vv.heroId] or 0
                needItems[vv.heroId] = needItems[vv.heroId] + 1
                if not self:canTakeNft(vv.heroId, constant.ITEM_HERO, pid) then
                    gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_NOT_AVALIABLE))
                    return 
                end
            end
            local countLimit = self:_getStarmapBattleSoliderCount(vv.heroId)
            if vv.soliderCount > countLimit then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_SOLIDER_BATTLE_NUM))
                return
            end
            if vv.soliderCfgId and vv.soliderCfgId ~= 0 then
                needSoliders[vv.soliderCfgId] = needSoliders[vv.soliderCfgId] or 0
                needSoliders[vv.soliderCfgId] = needSoliders[vv.soliderCfgId] + vv.soliderCount
            end
        end
    end
    for id, count in pairs(needItems) do
        if count > 1 then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NFT_HERO_REPEAT))
            return 
        end
    end
    if not self:isPersonalUnionSoldierEnough(pid, needSoliders) then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_SOLIDER_NOT_ENOUGH))
        return 
    end

    local fightArmys = {}
    for _, v in ipairs(unionArmys) do
        local armyInfo = { heros = {}, mainWarShip  = nil, soliders = {}, liberatorShips = {} }
        local warShip
        if v.warShipId and v.warShipId ~= 0 then
            warShip = self:takeNftForBattle(v.warShipId, gridCfgId)
        else
            warShip = self:_createStarmapBattleWarship()
        end
        if warShip then
            armyInfo.mainWarShip = warShip
        end
        for ii, vv in ipairs(v.teams) do
            if vv.heroId and vv.heroId ~= 0 then
                local hero = self:takeNftForBattle(vv.heroId, gridCfgId)
                if hero then
                    hero.index = ii
                    table.insert(armyInfo.heros, hero)
                end
            end
            local soliderInfo = self:takeSoliderForBattle(vv.soliderCfgId, vv.soliderCount)
            if soliderInfo then
                soliderInfo.index = ii
                table.insert(armyInfo.soliders, soliderInfo)
            end
            table.insert(armyInfo.liberatorShips, {
                cfgId = gg.getGlobalCfgIntValue("UnionLiberatorShipCfgId", 3000013),
                quality = gg.getGlobalCfgIntValue("UnionLiberatorShipQuality", 0),
                level = gg.getGlobalCfgIntValue("UnionLiberatorShipLevel", 1),
            })
        end
        if not armyInfo.mainWarShip then
            self:returnBackCampaignArmy(pid, armyInfo)
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.ARMY_NO_WARSHIP))
            return
        end
        if table.count(armyInfo.heros) == 0 then
            self:returnBackCampaignArmy(pid, armyInfo)
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.ARMY_NO_HERO))
            return
        end
        -- if table.count(armyInfo.soliders) == 0 then
        --     self:returnBackNftArmy(pid, armyInfo)
        --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.ARMY_NO_SOLIDER))
        --     return
        -- end
        local minCount = table.count(armyInfo.heros) + table.count(armyInfo.soliders)
        if minCount == 0 then
            self:returnBackNftArmy(pid, armyInfo)
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_BATTLE_NUM_LESS))
            return
        end
        fightArmys[armyInfo.mainWarShip.id] = armyInfo
    end
    if not self:costPersonalUnionSoldier(pid, needSoliders) then
        for k, v in pairs(fightArmys) do
            self:returnBackNftArmy(pid, v)
        end
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_SOLIDER_COST_ERR))
        return
    end
    self.dirty = true
    self.editArmyPid = 0
    self.editArmyTick = 0
    return fightArmys
end

function Union:returnBackNftArmy(pid, armyInfo)
    if armyInfo then
        if armyInfo.mainWarShip then
            self:returnBackNft(armyInfo.mainWarShip.id)
        end
        if armyInfo.heros and next(armyInfo.heros) then
            for k, v in pairs(armyInfo.heros) do
                self:returnBackNft(v.id)
            end
        end
        self.dirty = true
    end
end

function Union:starmapCampaignCostArmyLife(pid, armyInfo, leftSoliders)
    local nftDict = {}
    if armyInfo.mainWarShip then
        nftDict[armyInfo.mainWarShip.id] = armyInfo.mainWarShip
    end
    for k, v in pairs(armyInfo.heros or {}) do
        nftDict[v.id] = v
    end
    self:returnBackNftsWithEntity(nftDict)
    local idList = self:getZeroLifeNftsByPid(pid)
    self:doReturnNfts(pid, idList)
    -- for id, v in pairs(leftSoliders or {}) do
    --     local solider = self.soliders[v.cfgId]
    --     if solider then
    --         solider.count = solider.count + v.count
    --     end
    -- end
    self.dirty = true
    gg.playerProxy:call(pid, "returnBackPersonalUnionSoldier", leftSoliders or {})
end

function Union:returnBackCampaignArmy(pid, armyInfo)
    self:returnBackNftArmy(pid, armyInfo)
    if armyInfo then
        -- for i, v in ipairs(armyInfo.soliders) do
        --     local solider = self.soliders[v.cfgId]
        --     if solider then
        --         solider.count = solider.count + v.count
        --     end
        -- end
        -- self.dirty = true
        gg.playerProxy:call(pid, "returnBackPersonalUnionSoldier", armyInfo.soliders)
    end
end

function Union:getNftsByPid(pid)
    local idList = {}
    for id, item in pairs(self.items) do
        if item.ownerPid == pid then
            table.insert(idList, id)
        end
    end
    return idList
end

function Union:getZeroLifeNftsByPid(pid)
    local idList = {}
    for id, item in pairs(self.items) do
        if item.ownerPid == pid and item.curLife == 0 then
            table.insert(idList, id)
        end
    end
    return idList
end

function Union:handleMemZeroLifeNfts()
    for pid, member in pairs(self.members) do--""nft
        skynet.fork(function(playerId)
            local idList = self:getZeroLifeNftsByPid(playerId)
            self:doReturnNfts(playerId, idList)
        end, pid)
    end
end

function Union:addContriDegree(pid, val)
    local member = self.members[pid]
    if not member then
        return
    end
    -- if not member or member.chain ~= self.unionChain then
    --     return
    -- end
    self.contriDegree[pid] = self.contriDegree[pid] or 0
    self.contriDegree[pid] = self.contriDegree[pid] + val
    self.dirty = true
end

function Union:getContriDegree(pid)
    return self.contriDegree[pid] or 0
end

function Union:adjustContriDegree(pid, isTickOut)
    local degree = self.contriDegree[pid] or 0
    if isTickOut then
        local cfgVal = gg.getGlobalCfgIntValue("KickUnionLimit", 10)
        if degree < cfgVal then
            self.contriDegree[pid] = 0
        end
    else
        local cfgVal = gg.getGlobalCfgIntValue("QuitUnionLimit", 100)
        if degree >= cfgVal then
            self.contriDegree[pid] = self.contriDegree[pid] / 2
        else
            self.contriDegree[pid] = 0
        end
    end
    self.dirty = true
end

function Union:getNftPowerDict(ids)
    local nftPowerDict = {}
    for i, id in ipairs(ids) do
        local item = self.items[id]
        if item and item.ref == constant.REF_UNION then
            local cfg = self:getNftConfig(id)
            if cfg then
                nftPowerDict[item.ownerPid] = nftPowerDict[item.ownerPid] or 0
                nftPowerDict[item.ownerPid] = nftPowerDict[item.ownerPid] + (cfg.power or 0)
            end
        end
    end
    return nftPowerDict
end

function Union:addNftOwnerContribute(ids)
    local nftPowerDict = self:getNftPowerDict(ids)
    local cfgVal = gg.getGlobalCfgIntValue("powerToPerContribute", 1000)
    local playerPower = {}
    for pid, power in pairs(nftPowerDict) do
        playerPower[pid] = playerPower[pid] or 0
        playerPower[pid] = playerPower[pid] + power
    end
    for pid, power in pairs(playerPower) do
        local degree = power / cfgVal
        self:addContriDegree(pid, degree)
    end
    self.dirty = true
end

function Union:makeContriDegree()
    local now = gg.time.time()
    local nextTick = self:getNftMakeContributeTick()
    local nftNewTick = {}
    local nftIds = {}
    for id, tick in pairs(self.nftsContriTick) do
        if now >= tick then
            local item = self.items[id]
            if item and item.ref == constant.REF_UNION then
                local cfg = self:getNftConfig(id)
                if cfg then
                    nftNewTick[id] = nextTick
                    table.insert(nftIds, id)
                end
            end
        end
    end
    for id, tick in pairs(nftNewTick) do
        self.nftsContriTick[id] = tick
    end
    self:addNftOwnerContribute(nftIds)
    self.dirty = true
end

function Union:jobMakeContriDegree()
    local now = gg.time.time()
    local nextTick = self:getJobMakeContributeTick()
    local jobNewTick = {}
    local pids = {}
    for pid, tick in pairs(self.jobContriTick) do
        if now >= tick then
            local degree = self:getPlayerJobContribute(pid)
            self:addContriDegree(pid, degree)
            jobNewTick[pid] = nextTick
        end
    end
    for pid, tick in pairs(jobNewTick) do
        self.jobContriTick[pid] = tick
    end
    self.dirty = true
end

function Union:getPlayerJobContribute(pid)
    local member = self:getRealMember(pid)
    return Union.getUnionJobContribute(member.unionJob)
end

function Union:setJobMakeContributeTick(unionJob, pid)
    local degree = Union.getUnionJobContribute(unionJob)
    if degree > 0 then
        local tick = self:getJobMakeContributeTick()
        self:_setJobContriTick(pid, tick)
    end
end

function Union:updateJobMakeContributeTick(oldUnionJob, newUnionJob, pid)
    local newDegree = Union.getUnionJobContribute(newUnionJob)
    if newDegree == 0 then
        self:_setJobContriTick(pid, nil)
    elseif newDegree > 0 then
        self:setJobMakeContributeTick(newUnionJob, pid)
    end
end

function Union:addCombatVal(pid, val)
    local member = self.members[pid]
    if not member then
        return
    end
    -- if not member or member.chain ~= self.unionChain then
    --     return
    -- end
    self.combatDict[pid] = self.combatDict[pid] or 0
    self.combatDict[pid] = self.combatDict[pid] + val
    self.dirty = true
end

function Union:getCombatVal(pid)
    return self.combatDict[pid] or 0
end

function Union:adjustCombatVal(pid, isTickOut)
    local degree = self.combatDict[pid] or 0
    if isTickOut then
        local cfgVal = gg.getGlobalCfgIntValue("KickUnionLimit", 10)
        if degree < cfgVal then
            self.combatDict[pid] = 0
        end
    else
        local cfgVal = gg.getGlobalCfgIntValue("QuitUnionLimit", 100)
        if degree >= cfgVal then
            self.combatDict[pid] = self.combatDict[pid] / 2
        else
            self.combatDict[pid] = 0
        end
    end
    self.dirty = true
end

function Union:_getTotalCombatVal()
    local allVal = 0
    for k, v in pairs(self.combatDict) do
        allVal =  allVal + v
    end
    return allVal
end

function Union:_getMemValByCombatVal(valDict)
    local memValDict = {}
    local allVal = self:_getTotalCombatVal()
    if allVal == 0 then
        return memValDict
    end
    for pid, pval in pairs(self.combatDict) do
        if pval > 0 then
            local per = 1
            if allVal ~= 0 then
                per = pval / allVal
            end
            for kk, vv in pairs(valDict) do
                local reward = math.floor(vv * per)
                if reward > 0 then
                    memValDict[pid] = memValDict[pid] or {}
                    memValDict[pid][kk] = reward
                    memValDict[pid]["allVal"] = allVal
                end
            end
        else
            memValDict[pid] = memValDict[pid] or {}
            memValDict[pid]["allVal"] = allVal
        end
    end
    return memValDict
end

function Union:safeAddResDict(resDict)
    for k, v in pairs(resDict or {}) do
        local addVal = self:addableRes(k, v)
        local resKey = constant.RES_JSON_KEYS[k]
        self[resKey] = (self[resKey] or 0) + addVal
        if k == constant.RES_CARBOXYL then
            gg.rankProxy:send("increDifferentRankVal", constant.REDIS_RANK_UNION_GET_HYDROXYL, self.unionId, addVal)
        end
    end
    self.dirty = true
end

function Union:_getTotalContriDegree()
    local allDegree = 0
    for k, v in pairs(self.contriDegree) do
        allDegree =  allDegree + v
    end
    return allDegree
end

function Union:_getMemValByContribute(valDict)
    local memValDict = {}
    local allDegree = self:_getTotalContriDegree()
    if allDegree == 0 then
        return memValDict
    end
    for pid, pval in pairs(self.contriDegree) do
        if pval > 0 then
            local per = 1
            if allDegree ~= 0 then
                per = pval / allDegree
            end
            for kk, vv in pairs(valDict) do
                local reward = math.floor(vv * per)
                if reward > 0 then
                    memValDict[pid] = memValDict[pid] or {}
                    memValDict[pid][kk] = reward
                    memValDict[pid]["allDegree"] = allDegree
                end
            end
        else
            memValDict[pid] = memValDict[pid] or {}
            memValDict[pid]["allDegree"] = allDegree
        end
    end
    return memValDict
end

------------------------------------------------
function Union:onUnionCampaignUpdate(pid, battleId, campaignId, fightNftIds)
    local cfgVal = gg.getGlobalCfgIntValue("perFleetMakeContribute", 5)
    self:addContriDegree(pid, cfgVal)
    if self.campaignIdDict[campaignId] then
        return
    end
    self.dirty = true
    if self.editArmyPid == pid then
        self.editArmyPid = 0
        self.editArmyTick = 0
    end
    if table.count(self.campaignIdList) >= constant.UNION_CAMPAIGNREPORTS_LIMIT_COUNT then
        local delId = table.remove(self.campaignIdList, 1)
        self.campaignIdDict[delId] = nil
    end
    table.insert(self.campaignIdList, campaignId)
    self.campaignIdDict[campaignId] = true
    --fight report
    gg.playerProxy:call(pid, "onUnionCampaignUpdate", campaignId)
end

function Union:onUnionSoliderGen()
    self.dirty = true
end

function Union:onUnionBuildGen()
    self.dirty = true
end

function Union:onUnionTechLevelUp()
    self.dirty = true
    self:refreshUnlockTechs()
    self:initTechEffects() --""
end


----------------------------------------------

function Union:doDissolve(pid)
    self.dirty = false
    local ret = gg.starmapProxy:call("dissolveUnionHandle", self.unionId, self.ownerGrids)
    if not ret then
        logger.error("Union", "doDissolve call dissolveUnionHandle error unionId=%d", self.unionId)
    end
    gg.unionMgr:setUnionNameToUnionId(self.unionName, nil)
    gg.centerProxy:broadCast2Game("onUnionDel", self.unionId, pid)
    gg.mongoProxy.union:delete({unionId = self.unionId})
end

function Union:doCreate(unionId, data)
    self.dirty = true
    self.unionId = unionId
    self.unionName = data.unionName
    self.unionFlag = data.unionFlag
    self.unionNotice = data.unionNotice
    self.unionSharing = data.unionSharing
    self.enterType = data.enterType
    self.enterScore = data.enterScore
    self.unionChain = data.player.chain or 0
    data.player.fightPower = data.player.fightPower or 0
    data.player.starCoin = data.player.starCoin or 0
    data.player.ice = data.player.ice or 0
    data.player.titanium = data.player.titanium or 0
    data.player.gas = data.player.starCoin or 0
    data.player.carboxyl = data.player.carboxyl or 0
    data.player.online = 1
    self.members[data.player.playerId] = data.player
    self:setJobMakeContributeTick(data.player.unionJob, data.player.playerId)
    gg.unionMgr:setPidToUnionId(data.player.playerId, self.unionId)
    gg.unionMgr:setUnionNameToUnionId(self.unionName, self.unionId)
    self:doRefresh()
    self:doUpdatePersonalGrids(data.player.playerId, self.unionId, self.unionName)
    local unionBase = self:packUnionBase()
    gg.playerProxy:send(data.player.playerId, "onUnionJoinSucc", unionBase)
    gg.centerProxy:broadCast2Game("onUnionAdd", self:packUnionInfo(), data.player.playerId)

    local beginGridId = gg.starmapProxy:call("selectBeginGrid", data.player.playerId, unionId)
    self.beginGridId = beginGridId
end

function Union:doJoin(pid, data)
    if self.enterType == constant.UNION_JOIN_TYPE_NOT_ALLOW then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_FORBID))
        return
    end
    if table.count(self.members) >= self:getMemberMax() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_MEMBER_LIMIT))
        return
    end
    if data.playerScore < self.enterScore then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_SCORE_NOT_ENOUGH))
        return
    end
    self.dirty = true
    if self.enterType == constant.UNION_JOIN_TYPE_APPLY then --""
        local apply = {
            playerId = data.playerId,
            playerName = data.playerName,
            playerHead = data.playerHead,
            playerScore = data.playerScore,
            baseLevel = data.baseLevel,
            applyTime = os.time(),
            answer = 0, --""0-"", 1-"" 2-""
        }
        self.applys[pid] = apply
        self.applyVersion = self.applyVersion + 1
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_HAS_APPLY))
        self:sendMembers(self:getOnlineMemberPids(constant.UNION_JOB_VICEPRESIDENT), "onUnionNewApply")
    else
        data.fightPower = data.fightPower or 0
        data.starCoin = data.starCoin or 0
        data.ice = data.ice or 0
        data.titanium = data.titanium or 0
        data.gas = data.starCoin or 0
        data.carboxyl = data.carboxyl or 0
        data.online = 1
        self.members[pid] = data
        self:setJobMakeContributeTick(data.unionJob, data.playerId)
        gg.unionMgr:setPidToUnionId(pid, self.unionId)
        self:doUpdatePersonalGrids(pid, self.unionId, self.unionName)
        local unionBase = self:packUnionBase()
        gg.playerProxy:send(pid, "onUnionJoinSucc", unionBase)
    end
end

function Union:doJoinAnswer(pid, applyPid, answer)
    local apply = self.applys[applyPid]
    if not apply then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_JOIN_APPLY_INVALID))
        return
    end
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if member.unionJob < constant.UNION_JOB_VICEPRESIDENT then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    if apply.answer > constant.UNION_JOIN_NOT_DECIDE then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_JOIN_APPLY_INVALID))
        self.applys[applyPid] = nil
        self.dirty = true
        gg.playerProxy:send(pid, "onJoinUnionAnswerFinish")
        return
    end
    if answer == constant.UNION_JOIN_REJECT then
        --""
        self.applys[applyPid] = nil
        self.dirty = true
        gg.playerProxy:send(pid, "onJoinUnionAnswerFinish")
        return
    else
        local playerUnion = gg.unionMgr:getUnionByPlayerId(applyPid)
        if playerUnion then --""
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_JOINED))
            self.applys[applyPid] = nil
            self.dirty = true
            gg.playerProxy:send(pid, "onJoinUnionAnswerFinish")
            return
        end
        if table.count(self.members) >= self:getMemberMax() then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_MEMBER_LIMIT))
            return
        end
        local ret = gg.playerProxy:call(applyPid, "checkJoinUnionCD")
        if not ret then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_REJOIN_CD))
            return
        end
        --""
        local answerMember = {
            playerId = apply.playerId,
            playerName = apply.playerName,
            playerHead = apply.playerHead,
            playerScore = apply.playerScore,
            matchScore = 0,
            unionJob = constant.UNION_JOB_MEMBER,
            fightPower = apply.fightPower or 0,
            starCoin = apply.starCoin or 0,
            ice = apply.ice or 0,
            titanium = apply.titanium or 0,
            gas = apply.gas or 0,
            carboxyl = apply.carboxyl or 0,
        }
        self.members[applyPid] = answerMember
        answerMember.online = gg.playerProxy:getOnlineStatus(applyPid)
        self:setJobMakeContributeTick(answerMember.unionJob, answerMember.playerId)
        gg.unionMgr:setPidToUnionId(applyPid, self.unionId)
        self:doUpdatePersonalGrids(applyPid, self.unionId, self.unionName)
        local unionBase = self:packUnionBase()
        gg.playerProxy:send(applyPid, "onUnionJoinSucc", unionBase)

        self.applys[applyPid] = nil
        self.dirty = true
        gg.playerProxy:send(pid, "onJoinUnionAnswerFinish")
    end
end

function Union:doClearAllApply(pid)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if member.unionJob < constant.UNION_JOB_VICEPRESIDENT then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    self.applys = {}
    self.dirty = true
    gg.playerProxy:send(pid, "onClearAllApplyFinish")
end

function Union:doInviteJoin(pid, invitedPid)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if member.unionJob < constant.UNION_JOB_VICEPRESIDENT then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    if table.count(self.members) >= self:getMemberMax() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_MEMBER_LIMIT))
        return
    end
    local canInvited = gg.playerProxy:call(invitedPid, "canInvitedJoinUnion")
    if not canInvited then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.NOT_ALLOW_INVITE))
        return
    end
    local invite = {
        playerId = invitedPid,                   --""ID
        invitePlayer = member,
        time = os.time(),                        --""
        answer = 0,                              --""
    }
    gg.playerProxy:send(invitedPid, "onInvitedJoinUnion", self.unionId, invite)
    gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_HAS_INVITE))
end

function Union:doAnswerInvite(pid, answer, memberInfo)
    local playerUnion = gg.unionMgr:getUnionByPlayerId(pid)
    if playerUnion then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_JOINED))
        return
    end
    if answer == constant.UNION_JOIN_REJECT then
        return
    end
    local ret = gg.playerProxy:call(pid, "checkJoinUnionCD")
    if not ret then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_REJOIN_CD))
        return
    end
    self.dirty = true
    memberInfo.online = 1
    self.members[pid] = memberInfo
    self:setJobMakeContributeTick(memberInfo.unionJob, memberInfo.playerId)
    gg.unionMgr:setPidToUnionId(pid, self.unionId)
    self:doUpdatePersonalGrids(pid, self.unionId, self.unionName)
    local unionBase = self:packUnionBase()
    gg.playerProxy:send(pid, "onUnionJoinSucc", unionBase)
end

function Union:doModifyUnionInfo(pid, newInfo)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if member.unionJob < constant.UNION_JOB_VICEPRESIDENT then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    local oldName = self.unionName
    if newInfo.unionName ~= oldName then
        -- TODO: check
        local now = gg.time.time()
        if self.modifyNameTime > 0 then
            local modifyCDSec = gg.getGlobalCfgIntValue("UnionChangeNameCD", 0) * gg.time.DAY_SECS
            if (self.modifyNameTime + modifyCDSec) > now then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
                return
            end
        end
        local needRes = gg.getGlobalCfgTableValue("UnionChangeNameCost", {})
        if needRes[1] and needRes[2] then
            local costResDict = {}
            costResDict[needRes[1]] = needRes[2]
            local isEnough = gg.playerProxy:call(pid, "isResDictEnough", costResDict)
            if not isEnough then
                return
            end
            local isOk = gg.playerProxy:call(pid, "costResDict", costResDict, gamelog.MODIFY_UNION_NAME)
            if not isOk then
                return
            end
        end
        self.unionName = newInfo.unionName
        self.modifyNameTime = now
    end
    self.dirty = true
    self.unionFlag = newInfo.unionFlag
    self.enterType = newInfo.enterType
    self.enterScore = newInfo.enterScore
    self.unionSharing = newInfo.unionSharing
    self.unionNotice = newInfo.unionNotice
    -- self.unionName = newInfo.unionName

    --""
    gg.playerProxy:send(pid, "onModifyUnionInfoFinish")
    gg.centerProxy:broadCast2Game("onUnionUpdate", "onModifyUnionInfo", self.unionId, self:packUnionInfo())
end

function Union:doUpdateMemberInfo(pid, newInfo)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    self.dirty = true
    member.playerName = newInfo.playerName
    member.playerHead = newInfo.playerHead
    member.chain = newInfo.chain
end

function Union:doQuit(pid)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if member.unionJob > constant.UNION_JOB_MEMBER and member.unionJob < constant.UNION_JOB_PRESIDENT then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_TRANSFER_FIRST))
        return
    end
    if member.unionJob == constant.UNION_JOB_PRESIDENT and table.count(self.members) > 1 then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_TRANSFER_FIRST))
        return
    end
    self.dirty = true

    local idList = self:getNftsByPid(pid)
    self:doReturnNfts(pid, idList)
    self:doUpdatePersonalGrids(pid, 0, "")
    self.members[pid] = nil
    self:_setJobContriTick(pid, nil)
    self:adjustContriDegree(pid)
    gg.unionMgr:setPidToUnionId(pid, nil)
    gg.playerProxy:send(pid, "onUnionQuitSucc", self.unionId)
end

function Union:doTickOut(pid, tickedPid)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    local tickedMember = self.members[tickedPid]
    if not tickedMember then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_THIS_MEMBER))
        return
    end
    if not Union.unionJobCanKickOut(member.unionJob) then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    if member.unionJob <= tickedMember.unionJob then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    if tickedMember.unionJob > constant.UNION_JOB_MEMBER then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    self.dirty = true
    local idList = self:getNftsByPid(tickedPid)
    self:doReturnNfts(tickedPid, idList)
    self:doUpdatePersonalGrids(tickedPid, 0, "")
    self.members[tickedPid] = nil
    self:_setJobContriTick(tickedPid, nil)
    self:adjustContriDegree(tickedPid, true)
    gg.unionMgr:setPidToUnionId(tickedPid, nil)
    gg.playerProxy:send(tickedPid, "onUnionTickedSucc", self.unionId)
    gg.playerProxy:send(pid, "onTickOutUnionFinish", self.unionId, tickedPid)
end

function Union:doEditJob(pid, editedPid, unionJob, editType)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    local editedMember = self.members[editedPid]
    if not editedMember then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_THIS_MEMBER))
        return
    end
    local editJob
    if editType == constant.UNION_JOB_OP_OUTGOING then--""
        if pid ~= editedPid then
            return
        end
        --""
        if not Union.unionJobCanOutgoing(member.unionJob) then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
            return
        end
        self.dirty = true
        self:updateJobMakeContributeTick(member.unionJob, constant.UNION_JOB_MEMBER, pid)
        member.unionJob = constant.UNION_JOB_MEMBER
        gg.playerProxy:sendOnline(pid, "onUnionJobChange", member.unionJob)
    else
        --""
        -- if editedMember.chain ~= self.unionChain then
        --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BRIDGE_MUST_IN_SAME_CHAIN))
        --     return
        -- end
        if pid == editedPid then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_EDIT_SELF_JOB))
            return
        end
        if editType == constant.UNION_JOB_OP_TRANSFER then--""
            if member.unionJob ~= constant.UNION_JOB_PRESIDENT then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
                return
            end
            --""
            if not Union.unionJobCanTransfer(member.unionJob) then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
                return
            end
            --""
            if editedMember.unionJob < constant.UNION_JOB_VICEPRESIDENT then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_TRANSFER_INVALID))
                return
            end
            self.dirty = true
            self:updateJobMakeContributeTick(member.unionJob, editedMember.unionJob, pid)
            member.unionJob = editedMember.unionJob
            gg.playerProxy:sendOnline(pid, "onUnionJobChange", member.unionJob)
            self:updateJobMakeContributeTick(editedMember.unionJob, constant.UNION_JOB_PRESIDENT, editedPid)
            editedMember.unionJob = constant.UNION_JOB_PRESIDENT
            gg.playerProxy:sendOnline(editedPid, "onUnionJobChange", editedMember.unionJob)
            editJob = editedMember.unionJob
        elseif editType == constant.UNION_JOB_OP_APPOINTED then--""
            if unionJob == constant.UNION_JOB_PRESIDENT then
                return
            end
            --""
            if not Union.unionJobCanAppointed(member.unionJob) then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
                return
            end
            if member.unionJob <= editedMember.unionJob then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
                return
            end
            --""
            if self:getCurUnionJobCnt(unionJob) >= Union.getUnionJobMaxCnt(unionJob) then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_MAX_TITLE))
                return
            end

            self.dirty = true
            self:updateJobMakeContributeTick(editedMember.unionJob, unionJob, editedPid)
            editedMember.unionJob = unionJob
            gg.playerProxy:sendOnline(editedPid, "onUnionJobChange", editedMember.unionJob)
            editJob = editedMember.unionJob
        elseif editType == constant.UNION_JOB_OP_REMOVE then--""
            --""
            if not Union.unionJobCanRemove(member.unionJob) then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
                return
            end
            if member.unionJob <= editedMember.unionJob then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
                return
            end
            self.dirty = true
            self:updateJobMakeContributeTick(editedMember.unionJob, constant.UNION_JOB_MEMBER, editedPid)
            editedMember.unionJob = constant.UNION_JOB_MEMBER
            gg.playerProxy:sendOnline(editedPid, "onUnionJobChange", editedMember.unionJob)
        end
    end
    gg.playerProxy:send(pid, "onUnionEditJobFinish", editType, editJob, editedMember.playerName)
end

function Union:donate(pid, donateInfo)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    --""
    -- if member.chain ~= self.unionChain then
    --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BRIDGE_MUST_IN_SAME_CHAIN))
    --     return
    -- end
    
    local realDonateInfo = {}
    realDonateInfo.starCoin = self:addableStarCoin(donateInfo.starCoin)
    realDonateInfo.ice = self:addableIce(donateInfo.ice)
    realDonateInfo.titanium = self:addableTitanium(donateInfo.titanium)
    realDonateInfo.gas = self:addableGas(donateInfo.gas)
    realDonateInfo.carboxyl = self:addableCarboxyl(donateInfo.carboxyl)
    local ok = gg.playerProxy:call(pid, "onUnionDonate", self.unionId, realDonateInfo)
    if not ok then
        return
    end

    self.dirty = true
    member.starCoin = member.starCoin + realDonateInfo.starCoin
    member.ice = member.ice + realDonateInfo.ice
    member.titanium = member.titanium + realDonateInfo.titanium
    member.gas = member.gas + realDonateInfo.gas
    member.carboxyl = member.carboxyl + realDonateInfo.carboxyl

    self.starCoin = self.starCoin + realDonateInfo.starCoin
    self.ice = self.ice + realDonateInfo.ice
    self.titanium = self.titanium + realDonateInfo.titanium
    self.gas = self.gas + realDonateInfo.gas
    self.carboxyl = self.carboxyl + realDonateInfo.carboxyl

    local resDict = {
        [constant.RES_STARCOIN] = realDonateInfo.starCoin,
        [constant.RES_ICE] = realDonateInfo.ice,
        [constant.RES_CARBOXYL] = realDonateInfo.carboxyl,
        [constant.RES_TITANIUM] = realDonateInfo.titanium,
        [constant.RES_GAS] = realDonateInfo.gas,
    }
    local degree = self:calContriDegree(resDict)
    self:addContriDegree(pid, degree)
    --""
    gg.playerProxy:send(pid, "onUnionDonateFinish")
end

function Union:calContriDegree(resDict)
    local RES_TO_CFG_KEYS = {
        [constant.RES_STARCOIN] = "starcoinToPerContribute",
        [constant.RES_ICE] = "iceToPerContribute",
        [constant.RES_CARBOXYL] = "carboxylToPerContribute",
        [constant.RES_TITANIUM] = "titaniumToPerContribute",
        [constant.RES_GAS] = "gasToPerContribute",
    }
    local degree = 0
    for k, v in pairs(resDict) do
        local cfgVal = gg.getGlobalCfgIntValue(RES_TO_CFG_KEYS[k], 1000000)
        degree = degree + v / cfgVal
    end
    return degree
end

function Union:_setNftsContriTick(id, tick)
    self.nftsContriTick[id] = tick
end

function Union:_setJobContriTick(pid, tick)
    self.jobContriTick[pid] = tick
end

function Union:donateNft(pid, donateInfo)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    --""
    -- if member.chain ~= self.unionChain then
    --     gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BRIDGE_MUST_IN_SAME_CHAIN))
    --     return
    -- end
    local donateTime = gg.playerProxy:call(pid, "onUnionDonateNft", self.unionId, donateInfo)
    if not donateTime then
        return
    end

    local tick = self:getNftMakeContributeTick(true)
    for i, nftGO in ipairs(donateInfo) do
        nftGO.ref = constant.REF_UNION
        nftGO.donateTime = donateTime
        nftGO.ownerPid = pid
        self.items[nftGO.id] = nftGO
        self:_setNftsContriTick(nftGO.id, tick)
    end

    self.dirty = true

    --""
    gg.playerProxy:send(pid, "onUnionDonateNftFinish")
end

function Union:updateNft(pid, nftsInfo)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    for k,nft in pairs(nftsInfo) do
        local item = self.items[nft.id]
        if item.level < nft.level then
            item.level = nft.level
        end
    end
    self.dirty = true
    gg.playerProxy:send(pid, "onUnionDonateNftFinish") --""
end


function Union:doUpdatePersonalGrids(pid, unionId, unionName)
    return gg.starmapProxy:call("updatePersonalGrids", pid, unionId, unionName)
end

function Union:doReturnNfts(pid, idList)
    if table.count(idList) == 0 then
        return
    end
    --""nft"",""
    local storeList = {}
    for i, id in ipairs(idList) do
        local item = self.items[id]
        if item and item.refBy > 0 then
            table.insert(storeList, { buildId = id, cfgId = item.refBy })
        end
    end
    local result = {}
    if next(storeList) then
        result = gg.starmapProxy:call("storeUnionNftsOnGrid", pid, self.unionId, storeList)
    end
    local nftLifeDict = {}
    for i, id in ipairs(idList) do
        local item = self.items[id]
        if item then
            item.refBy = 0
            local data = result[id]
            if data then
                item.curLife = data.curLife
            end
            nftLifeDict[id] = item.curLife
        end
    end
    local ok = gg.playerProxy:call(pid, "onUnionTakeBackNft", self.unionId, idList, nftLifeDict)
    if not ok then
        return
    end
    for i, id in ipairs(idList) do
        self.items[id] = nil
    end
    self.dirty = true

    --""
    gg.playerProxy:send(pid, "onUnionTakeBackNftFinish")
end

function Union:doAddUnionFavoriteGrid(pid, cfgId, tag)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if not Union.unionJobCanCollect(member.unionJob) then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    local limit = gg.getGlobalCfgIntValue("GuildCollectLimit", 0)
    local count = table.count(self.favoriteGrids)
    if count >= limit then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_COLLECT_OVER_LIMIT))
        return
    end
    if self.favoriteGrids[cfgId] then
        return
    end
    self.favoriteGrids[cfgId] = tag
    self.dirty = true

    --""
    gg.playerProxy:send(pid, "onAddUnionFavoriteGridFinish", cfgId, tag)
    gg.centerProxy:broadCast2Game("onUnionUpdate", "onAddUnionFavoriteGrid", self.unionId, self:packUnionInfo())
end

function Union:doDelUnionFavoriteGrid(pid, cfgId)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if not Union.unionJobCanCollect(member.unionJob) then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    self.favoriteGrids[cfgId] = nil
    self.dirty = true

    --""
    gg.playerProxy:send(pid, "onDelUnionFavoriteGridFinish", cfgId)
    gg.centerProxy:broadCast2Game("onUnionUpdate", "onDelUnionFavoriteGrid", self.unionId, self:packUnionInfo())
end

function Union:getFavoriteGridState(inGrids)
    local outGrids = {}
    for k, v in pairs(inGrids) do
        if self.favoriteGrids[k] then
            outGrids[k] = self.favoriteGrids[k]
        end
    end
    return outGrids
end

function Union:getUnionFavoriteGrids()
    return self.favoriteGrids
end

function Union:getUnionDefenseBuild(pid, buildId)
    local build = self.builds[buildId]
    if not build then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    return build:pack()
end

function Union:takeBackNft(pid, idList)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    self:doReturnNfts(pid, idList)
end

function Union:trainSolider(pid, soliderCfgId, soliderCount)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    
    local solider = self.soliders[soliderCfgId]
    if not solider then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_SOLIDER_NOT_UNLOCK))
        return
    end
    local starCoin = solider:getGenStarCoin(soliderCount)
    if self.starCoin < starCoin then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "starCoin"))
        return
    end
    if not solider:canGenSolider(soliderCount) then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_SOLIDER_NUM_LIMIT))
        return
    end
    self.dirty = true
    self.starCoin = self.starCoin - starCoin
    solider:addGenSolider(soliderCount)

    --""
    gg.playerProxy:send(pid, "onUnionTrainSoliderFinish")
end

function Union:gmGenSolider(pid, soliderCfgId, soliderCount)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    
    if soliderCfgId then
        local solider = self.soliders[soliderCfgId]
        if not solider then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_SOLIDER_NOT_UNLOCK))
            return
        end
        if soliderCount then
            if not solider:canGenSolider(soliderCount) then
                gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_SOLIDER_NUM_LIMIT))
                return
            end
        end
    else
        for cfgId, solider in pairs(self.soliders) do
            solider:gmAddGenSolider()
        end
    end

    self.dirty = true
    gg.playerProxy:send(pid, "onUnionTrainSoliderFinish")
end

function Union:gmClearNFTRef(pid)
    for id, item in pairs(self.items) do
        if item.ownerPid == pid then
            if item.ref == constant.REF_UNION then
                if item.refBy > 0 then
                    item.refBy = 0
                end
            end
        end
    end
end

function Union:genDefenseBuild(pid, defenseCfgId, defenseCount)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    
    local build = self.builds[defenseCfgId]
    if not build then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_DEFENSE_NOT_UNLOCK))
        return
    end

    if not build:canGenBuilds(defenseCount) then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_DEFENSE_NUM_LIMIT))
        return
    end

    local starCoin = build:getGenStarCoin(defenseCount)
    if self.starCoin < starCoin then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "starCoin"))
        return
    end

    local ice = build:getGenIce(defenseCount)
    if self.ice < ice then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "ice"))
        return
    end

    local titanium = build:getGenTitanium(defenseCount)
    if self.titanium < titanium then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "titanium"))
        return
    end

    local gas = build:getGenGas(defenseCount)
    if self.gas < gas then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "gas"))
        return
    end

    local carboxyl = build:getGenCarboxyl(defenseCount)
    if self.carboxyl < carboxyl  then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "carboxyl"))
        return
    end 

    self.dirty = true
    self.starCoin = self.starCoin - starCoin
    self.ice = self.ice - ice
    self.titanium = self.titanium - titanium
    self.gas = self.gas - gas
    self.carboxyl = self.carboxyl - carboxyl
    build:addGenBuilds(defenseCount)

    --""
    gg.playerProxy:send(pid, "onUnionGenDefenseBuildFinish")
end

function Union:levelUpTech(pid, techCfgId)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if not Union.unionJobCanResearch(member.unionJob) then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    local tech = self.techs[techCfgId]
    if not tech then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_TECH_NOT_UNLOCK))
        return
    end
    if not tech:hasNextLevel() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_TECH_LEVEL_LIMIT))
        return
    end
    --""
    local queueData,queueNum = self:getTechCurLevelUpCnt()
    local modQueue = queueData[tech:getMod()] or 0
    if modQueue >= self:getModTechLevelUpMaxCnt() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_TECH_MOD_MAX))
        return
    end
    if queueNum >= self:getTechLevelUpMaxCnt() then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_TECH_MAX_COUNT))
        return
    end
    --""
    local presetTechs = tech:getPresetTechs()
    local isEnough = self:isEnoughPresetTechs(presetTechs)
    if not isEnough then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_PRESET_TECH_LEVEL_LIMIT))
        return
    end

    local starCoin = tech:getLevelUpStarCoin()
    if self.starCoin < starCoin then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "starCoin"))
        return
    end

    local ice = tech:getLevelUpIce()
    if self.ice < ice then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "ice"))
        return
    end

    local titanium = tech:getLevelUpTitanium()
    if self.titanium < titanium then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "titanium"))
        return
    end

    local gas = tech:getLevelUpGas()
    if self.gas < gas then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "gas"))
        return
    end

    local carboxyl = tech:getLevelUpCarboxyl()
    if self.carboxyl < carboxyl  then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, "carboxyl"))
        return
    end
    self.dirty = true
    self.starCoin = self.starCoin - starCoin
    self.ice = self.ice - ice
    self.titanium = self.titanium - titanium
    self.gas = self.gas - gas
    self.carboxyl = self.carboxyl - carboxyl
    tech:setLevelUpTick()

    --""
    gg.playerProxy:send(pid, "onUnionLevelUpTechFinish")
end

function Union:startEditUnionArmys(pid)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if self.editArmyTick and self.editArmyTick > 0 and skynet.timestamp() < self.editArmyTick and self.editArmyPid ~= pid then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_EDIT_ARMY_IS_LOCKED))
        return
    end
    if self.editArmyPid and self.editArmyPid > 0 and self.editArmyPid ~= pid then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_OTHER_LOCK_EDIT_ARMY))
        return
    end
    self.dirty = true
    self.editArmyPid = pid
    self.editArmyTick = skynet.timestamp() + gg.getGlobalCfgIntValue("UnionEditArmyLockTime", 600) * 1000
    gg.centerProxy:broadCast2Game("onUnionUpdate", "broadCastUnionArmyEditStart", self.unionId, self:serialize(), pid)
end

function Union:doTransferBeginGrid(pid, dstCfgId)
    local member = self.members[pid]
    if not member then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NOT_MEMBER))
        return
    end
    if not Union.unionJobCanMoveBeginGrid(member.unionJob) then --""
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_NO_AUTHORITY))
        return
    end
    if self.beginGridId == 0 then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_NOT_HAS_BEGIN_GRID))
        return
    end
    local now = gg.time.time()
    if self.transferBeginGridTime > 0 then
        local moveCD = gg.getGlobalCfgIntValue("GuildMoveCD", 0)
        if (self.transferBeginGridTime + moveCD) > now then
            local diff = self.transferBeginGridTime + moveCD - now
            local h = math.floor(diff / 3600)
            local m = math.floor((diff - h * 3600) / 60)
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.GRID_TRANSFER_BEGIN_CD, h, m))
            return
        end
    end
    local oldBeginGridId = self.beginGridId
    self.beginGridId = dstCfgId
    self.transferBeginGridTime = now
    self.dirty = true
    return oldBeginGridId
end

function Union:donateDaoItem(pid, contriDegree, exp)
    local daoLevel = gg.getExcelCfg("daoLevel")
    local maxLv = table.count(daoLevel)
    if self.unionLevel >= maxLv then
        gg.centerProxy:playerSay(pid, util.i18nFormat(errors.UNION_LEVEL_MAX))
        return
    end
    self:addContriDegree(pid, contriDegree)
    self.exp = self.exp + exp
    local cfg = daoLevel[self.unionLevel]
    while(self.unionLevel < maxLv and self.exp >= cfg.levelUpNeedExp)
    do
        self.unionLevel = self.unionLevel + 1
        cfg = daoLevel[self.unionLevel]
    end
    return {exp = self.exp, unionLevel = self.unionLevel, contriDegree = math.floor(self:getContriDegree(pid) * 1000)}
end

function Union:isUnionResDictEnough(resDict, pid)
    for k, v in pairs(resDict) do
        local resKey = constant.RES_JSON_KEYS[k]
        if self[resKey] < v then
            gg.centerProxy:playerSay(pid, util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[k]))
            return false
        end
    end
    return true
end

function Union:costUnionResDict(resDict, pid)
    for k, v in pairs(resDict) do
        local resKey = constant.RES_JSON_KEYS[k]
        self[resKey] = self[resKey] - v
    end
    return true
end

--""member
function Union:getOnlineMemberPids(minUnionJob)
    local pids = {}
    for _, member in pairs(self.members) do
        if (member.online or 0) > 0 and member.unionJob >= minUnionJob then
            table.insert(pids, member.playerId)
        end
    end
    return pids
end

function Union:sendMembers(pids, cmd, ...)
    for _, pid in pairs(pids) do
        gg.playerProxy:send(pid, cmd, ...)
    end
end

function Union:_createRewardInfo(rtype, percent, total, myVal, carboxyl, totalCarboxyl)
    local reward =  {
        rtype = rtype,
        percent = percent,
        total = total,
        myVal = myVal,
        carboxyl = carboxyl,
        totalCarboxyl = totalCarboxyl
    }
    return reward
end

function Union:_createRewardRecord(pid, gridCfgId, now)
    now = now or gg.time.time()
    return { cfgId = gridCfgId, rewards = {}, timestamp = now, isMember = self:isMember(pid) }
end

function Union:_sendGridRewardRecord(gridCfgId, rewardMap)
    for pid, data in pairs(rewardMap) do
        skynet.fork(function(playerId, rewardInfo)
            gg.playerProxy:send(playerId, "shareGridRes", gridCfgId, rewardInfo)
        end, pid, data)
    end
end

function Union:_createRewardMap(allVal, nftValDict, gridCfgId, carboxyl, rtype, percent)
    local now = gg.time.time()
    local rewardMap = {}
    local valDict = {
        carboxyl = carboxyl,
    }
    local memValDict = self:_getMemValByContribute(valDict)
    for pid, pval in pairs(memValDict) do
        rewardMap[pid] = self:_createRewardRecord(pid, gridCfgId, now)
        local rdata = self:_createRewardInfo(rtype, percent, allVal, nftValDict[pid], pval.carboxyl, carboxyl)
        table.insert(rewardMap[pid].rewards, rdata)
    end
    return rewardMap
end

function Union:distributeGridReward(allVal, nftValDict, gridCfgId, carboxyl, rtype, percent)
    if allVal <= 0 then
        return
    end
    local rewardMap = self:_createRewardMap(allVal, nftValDict, gridCfgId, carboxyl, rtype, percent)
    self:_sendGridRewardRecord(gridCfgId, rewardMap)
end

function Union:_addStarmapHyLog(allDegree, left, gridCfgId)
    local memHyDict = {}
    local valDict = {
        carboxyl = left,
    }
    local memValDict = self:_getMemValByContribute(valDict)
    for pid, pval in pairs(memValDict) do
        memHyDict[tostring(pid)] = pval.carboxyl
    end

    local logType = gamelog.UNION_SHARE_GRID_HY
    -- local cfg = gg.shareProxy:call("getRedisStarMapCfg", gridCfgId)
    local cfg = gg.getExcelCfg("starmapConfig")[gridCfgId]
    local x = 0
    local z = 0
    if cfg then
        x = cfg.pos.x
        z = cfg.pos.y
    end
    gg.internal:send(".gamelog", "api", "addStarmapHyLog", self.unionId, logType, gamelog[logType], gridCfgId, x, z, left, memHyDict)
end

function Union:gridRewardByContriDegree(left, gridCfgId, rtype)
    -- ""： "" * "" / ""
    local allDegree = self:_getTotalContriDegree()
    local percent = 100 - self.unionSharing
    self:distributeGridReward(allDegree, self.contriDegree, gridCfgId, left, rtype, percent)
    self:_addStarmapHyLog(allDegree, left, gridCfgId)
end

function Union:campaignReward(pid, gridCfgId, gridCarboxyl, resDict)
    -- "" = "" * ""
    -- local now = gg.time.time()
    -- local winnerReward = math.floor(gridCarboxyl * self.unionSharing / 100)
    -- local degree = self.contriDegree[pid] or 0
    -- local rewardMap = self:_createRewardMap(degree, {[pid] = degree}, gridCfgId, winnerReward, constant.STARMAP_CAMPAIGN_REWARD_UNION, self.unionSharing)
    -- self:_sendGridRewardRecord(gridCfgId, rewardMap)

    -- ""： "" * "" / ""
    local winnerReward = 0
    if gridCarboxyl > 0 then
        local left = gridCarboxyl - winnerReward
        if left > 0 then
            self:gridRewardByContriDegree(left, gridCfgId, constant.STARMAP_CAMPAIGN_REWARD_UNION)
            gg.rankProxy:send("increDifferentRankVal", constant.REDIS_RANK_UNION_GET_HYDROXYL, self.unionId, left)
        end
    end
    self:safeAddResDict(resDict)
end

function Union:personalCampaignReward(pid, gridCfgId, gridCarboxyl, resDict)
    local now = gg.time.time()
    local winnerReward = math.floor(gridCarboxyl)
    local degree = 1--self.contriDegree[pid] or 0
    local rewardMap = self:_createRewardMap(degree, {[pid] = degree}, gridCfgId, winnerReward, constant.STARMAP_CAMPAIGN_REWARD_PERSON, 100)
    for k, v in pairs(rewardMap) do
        v.isPersonal = true
    end
    self:_sendGridRewardRecord(gridCfgId, rewardMap)
    self:safeAddResDict(resDict)
end

function Union:starmapGridReward(ownerPid, gridCfgId, gridCarboxyl, nftBuilds, resDict)
    if gridCarboxyl > 0 then
        self.carboxyl = self.carboxyl + gridCarboxyl
        gg.rankProxy:send("increDifferentRankVal", constant.REDIS_RANK_UNION_GET_HYDROXYL, self.unionId, gridCarboxyl)
    end
    self:safeAddResDict(resDict)
end

function Union:starmapAddGridScoreCount(pid, gridCfgId, makeScoreCount)
    self:addGridScoreCount(gridCfgId, makeScoreCount)
end

function Union:onMatchStartTime()
    self:initJobMakeContributeTick()

    local nftTick = self:getNftMakeContributeTick(true)
    for k, v in pairs(self.items) do
        self:_setNftsContriTick(v.id, nftTick)
    end
    return true
end

function Union:matchSeasonEndHandle()
    gg.shareProxy:send("delStarmapMatchUnionRankInfo", self.unionId)
    self.starCoin = 0               --""
    self.ice = 0                    --""
    self.titanium = 0               --""
    self.gas = 0                    --""
    self.carboxyl = 0               --""

    if table.count(self.ownerGrids) > 0 then
    end
    self.ownerGrids = {}
    self.gridsScoreCount = {}
    for pid, member in pairs(self.members) do--""nft
        -- skynet.fork(function(playerId)
        --     local idList = self:getNftsByPid(playerId)
        --     self:doReturnNfts(playerId, idList)
        -- end, pid)
        local idList = self:getNftsByPid(pid)
        self:doReturnNfts(pid, idList)
    end
    self.soliders = {}             --""
    self.builds = {}               --""
    self.techs = {}                --""
    self.editArmyPid = 0
    self.editArmyTick = 0

    self.contriDegree = {}         --""
    self.combatDict = {}           --""
    self.nftsContriTick = {}       --""
    self.jobContriTick = {}        --""
    self.beginGridId = 0           --""

    self:doRefresh()
    self.dirty = true
    return true
end

function Union:getPersonalGridScore()
    return gg.starmapProxy:call("getPersonalGridScore", table.keys(self.members), self.unionChain)
end

function Union:getStarmapMatchRank()
    local rank = 0
    local chainIndex = gg.getChainIndexById(self.unionChain)
    local rankInfos = gg.matchProxy:call("getCurrentMatchSelfRank", constant.MATCH_BELONG_UNION, constant.MATCH_TYPE_SEASON, self.unionId)
    local info = rankInfos[1]
    if info then
        if info.selfRank then
            rank = info.selfRank.index
        end
    end
    return rank
end

function Union:attackGridContri(attackContriDict)
    for pid, val in pairs(attackContriDict) do
        self:addCombatVal(pid, val)
    end
end

function Union:_getStarmapRankReward(actCfgId, rank)
    local activities = gg.getExcelCfg("activities")
    local cfg = activities[actCfgId]
    if not cfg then
        return
    end
    if not cfg.rewardCfgId then
        return
    end
    local reward
    local activitiesReward = gg.getExcelCfg("activitiesReward")
    for k, v in pairs(activitiesReward) do
        if v.cfgId == cfg.rewardCfgId then
            if rank >= v.startRank and rank <= v.endRank then
                reward = {
                    resReward = v.resReward,
                    itemReward = v.itemReward,
                    resReward2 = v.resReward2,
                    itemReward2 = v.itemReward2,
                }
                break
            end
        end
    end
    return reward
end

function Union:_fomatMailItems(reward, itype, mailItems)
    for i, v in ipairs(reward or {}) do
        table.insert(mailItems, {
            cfgId = v[1],
            count = v[2],
            type = itype,
        })
    end
end

function Union:starmapUnionRankReward(rank, score, matchCfgId, actCfgId)
    local mailTemplate = gg.getExcelCfg("mailTemplate")
    local mailCfg = mailTemplate[constant.MAIL_TEMPLATE_ACTSTARMAPUNION]
    local sendId = 0
    local sendName = mailCfg.sendName
    local title = mailCfg.mailTitle
    local MORE_REWARD_JOB = {
        [constant.UNION_JOB_PRESIDENT] = true,
        [constant.UNION_JOB_VICEPRESIDENT] = true,
        [constant.UNION_JOB_COMMANDER] = true,
    }
    local memberPid = {}
    local moreRewardPid = {}
    for k, v in pairs(self.members) do
        if MORE_REWARD_JOB[v.unionJob] then
            table.insert(moreRewardPid, k)
        else
            table.insert(memberPid, k)
        end
    end
    local reward = self:_getStarmapRankReward(actCfgId, rank)
    if reward then
        local mailItems = {}
        self:_fomatMailItems(reward.resReward, constant.MAIL_ATTACH_RES, mailItems)
        self:_fomatMailItems(reward.itemReward, constant.MAIL_ATTACH_ITEM, mailItems)
        local mailData = {
            title = title,
            content = string.format(mailCfg.mailContent, rank),
            attachment = mailItems,
            logType = gamelog.ACT_STARMAP_UNION
        }
        if #memberPid > 0 then
            gg.mailProxy:send("gmSendMail", sendId, sendName, memberPid, mailData)
        end
        
        self:_fomatMailItems(reward.resReward2, constant.MAIL_ATTACH_RES, mailItems)
        self:_fomatMailItems(reward.itemReward2, constant.MAIL_ATTACH_ITEM, mailItems)
        if #moreRewardPid > 0 then
            gg.mailProxy:send("gmSendMail", sendId, sendName, moreRewardPid, mailData)
        end
    end
end
--------------------------------------------------------------
function Union:onSecond()
    for k, v in pairs(self.soliders) do
        v:onSecond()
    end
    for k, v in pairs(self.builds) do
        v:onSecond()
    end
    for k, v in pairs(self.techs) do
        v:onSecond()
    end
    self:checkEditArmyTimeout()
    self:makeContriDegree()
    self:jobMakeContriDegree()
end

function Union:onMinute()
    
end


function Union:onFiveMinute()
end


return Union