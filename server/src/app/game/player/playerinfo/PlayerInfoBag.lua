local PlayerInfoBag = class("PlayerInfoBag")

function PlayerInfoBag:ctor(param)
    self.player = param.player
    self.loginId = 0                                       --""loginId,""loginId""
    self.text = param.text or ""
    self.canInvite = param.canInvite or true
    self.canVisit = param.canVisit or true
    self.modifyNameNum = param.modifyNameNum or 0
    self.totalGameTime = 0
    self.lastGameTime = 0
    self.loginCount = 0
    self.inviteCode = param.inviteCode or math.int2AnyStr(self.player.pid, 62)
    self.modifyNameTick = 0
    self.levelFiveTime = 0
    self.walletInfo = nil

    self.firstLid = 0                       --""id,""
    self.firstLoginTime = 0                 --""
    self.firstLogoutTime = 0                --"" (firstLogoutTime""firstLoginTime)""
    self.daynoTemp = gg.time.dayno()

    self.chainId = 0
    self.walletAddress = ""

    self.correct = nil
end

function PlayerInfoBag:getRandomHeadIcon()
    local headCfg = cfg.get("etc.cfg.PlayerHead")
    local tb = table.chooseFromDict(headCfg)
    return tb.iconName
end

function PlayerInfoBag:serialize()
    local data = {}
    data.text = self.text
    data.canInvite = self.canInvite
    data.canVisit = self.canVisit
    data.modifyNameNum = self.modifyNameNum
    data.loginCount = self.loginCount
    data.totalGameTime = self.totalGameTime
    data.modifyNameTick = self.modifyNameTick
    data.levelFiveTime = self.levelFiveTime
    data.firstLid = self.firstLid
    data.firstLoginTime = self.firstLoginTime
    data.firstLogoutTime = self.firstLogoutTime
    data.correct = self.correct
    return data
end

function PlayerInfoBag:deserialize(data)
    self.text = data.text or ""
    self.canInvite = data.canInvite or true
    self.canVisit = data.canVisit or true
    self.modifyNameNum = data.modifyNameNum or 0
    self.loginCount = data.loginCount or 0
    self.totalGameTime = data.totalGameTime or 0
    self.inviteCode = data.inviteCode or math.int2AnyStr(self.player.pid, 62)
    self.modifyNameTick = data.modifyNameTick or 0
    self.levelFiveTime = data.levelFiveTime or 0
    self.firstLid = data.firstLid or 0
    self.firstLoginTime = data.firstLoginTime or 0
    self.firstLogoutTime = data.firstLogoutTime or 0
    self.correct = data.correct
end

function PlayerInfoBag:pack()
    local data = {}
    data.pid = self.player.pid
    data.name = self.player.name
    data.race = self.player.race
    data.headIcon = self.player.headIcon
    data.text = self.text
    data.canInvite = self.canInvite
    data.canVisit = self.canVisit
    data.modifyNameNum = self.modifyNameNum
    data.vipLevel = self.player.vipBag:getVipLevel()
    data.badge = self.player.pvpBag:getPlayerRankScore()
    data.inviteCode = self.inviteCode
    data.modifyNameLessTick = self:getModifyNameLessTick()
    data.unionId = self.player.unionBag:getMyUnionId()
    data.unionName = self.player.unionBag:getMyUnionName()
    data.unionFlag = self.player.unionBag:getMyUnionFlag()
    data.language = self.player.lang
    return data
end

function PlayerInfoBag:getModifyNameLessTick()
    return 0
end

-- ""
function PlayerInfoBag:canVisitFoundation()
    return self.canVisit
end

--""
function PlayerInfoBag:canInvitedJoinUnion()
    return self.canInvite
end

function PlayerInfoBag:refreshWalletInfo()
    if self.chainId > 0 and self.walletAddress ~= "" then
        return
    end
    local result = gg.shareProxy:call("getWalletAddressByAccount", self.player.account)
    if not result then
        return
    end
    self.chainId = math.floor(tonumber(result.chainId or 0))
    self.walletAddress = result.walletAddress
end

function PlayerInfoBag:getOwnerAddress()
    return self.walletAddress
end

function PlayerInfoBag:getChainId()
    return self.chainId
end

function PlayerInfoBag:queryWallet()
    gg.client:send(self.player.linkobj, "S2C_Player_Wallet", { chainId = self:getChainId(), ownerAddress = self:getOwnerAddress() })
end

function PlayerInfoBag:queryPlayerInfo()
    gg.client:send(self.player.linkobj, "S2C_Player_PlayerInfo", self:pack())
end

function PlayerInfoBag:modifyPlayerName(name)
    if not name then
        self.player:say(util.i18nFormat(errors.ARG_ERR))
        return
    end
    if name == self.player.name then
        self.player:say(util.i18nFormat(errors.NAME_MODIFY_ERR))
        return
    end
    --[[
    if self.modifyNameTick > 0 and skynet.timestamp() < self.modifyNameTick then
        self.player:say(util.i18nFormat(errors.NAME_MODIFY_LOCK, gg.time.strftime("%dDay %H:%M:%S", self:getModifyNameLessTick())))
        return
    end
    ]]
    local costHyt = 0
    if self.modifyNameNum > 0 then
        costHyt = gg.getGlobalCfgIntValue("ModifyPlayerNameCostHy", 1000)
        if not self.player.resBag:enoughRes(constant.RES_TESSERACT, costHyt) then
            self.player:say(util.i18nFormat(errors.RES_NOT_ENOUGH, constant.RES_NAME[constant.RES_TESSERACT]))
            return
        end
    end
    if gg.nameFilter:isValidText(name, 0, 20) ~= ggclass.WordFilter.CODE_OK then
        self.player:say(util.i18nFormat(errors.POLITE_LANGUAGE))
        return
    end
    if self.modifyNameNum > 0 then
        self.player.resBag:costRes(constant.RES_TESSERACT, costHyt, {logType=gamelog.MODIFY_PLAYER_NAME})
    end
    self.player.name = name
    self.modifyNameNum = self.modifyNameNum + 1
    --[[
    self.modifyNameTick = skynet.timestamp() + gg.getGlobalCfgIntValue("ModifyNameUnlockHour", 72) * 3600 * 1000
    ]]
    gg.client:send(self.player.linkobj, "S2C_Player_PlayerInfo", self:pack())
    gg.shareProxy:send("setPlayerBaseInfo", self.player.pid, { name = self.player.name } )
    self.player.taskBag:update(constant.TASK_CHANGE_NAME, {})
    self.player.unionBag:updateMemberInfo()
end

function PlayerInfoBag:modifyPlayerLanguage(language)
    if language ~= "zh_CN" and language ~= "en_US" and language ~= "zh_TW" then
        return
    end
    self.player.lang = language
    gg.client:send(self.player.linkobj, "S2C_Player_PlayerInfo", self:pack())
end

function PlayerInfoBag:modifyPlayerInfo(info)
    if info.canInvite ~= nil then
        self.canInvite = info.canInvite
    end
    if info.canVisit ~= nil then
        self.canVisit = info.canVisit
    end
    if info.text == "" then
        self.text = info.text
    else
        if info.text ~= nil then
            if gg.chatFilter:isValidText(info.text, 0, 60) ~= ggclass.WordFilter.CODE_OK then
                self.player:say(util.i18nFormat(errors.POLITE_LANGUAGE))
                return
            end
            self.text = info.text
        end
    end
    if info.race and info.race ~= 0 then
        self.player.race = info.race
    end
    
    if info.headIcon ~= nil then
        self.player.headIcon = info.headIcon
        gg.shareProxy:send("setPlayerBaseInfo", self.player.pid, { headIcon = self.player.headIcon })
    end
    gg.client:send(self.player.linkobj, "S2C_Player_PlayerInfo", self:pack())
end

function PlayerInfoBag:setPlayerUp5Level()
    self.levelFiveTime = os.time()
end

function PlayerInfoBag:isRegDayLevelFive()
    if os.date("%Y%m%d", self.player.createTime) == os.date("%Y%m%d", self.levelFiveTime) then
        return true
    end
    return false
end

function PlayerInfoBag:getPlayerInfo()
    local baseLevel = gg.shareProxy:call("getPlayerBaseInfo", self.player.pid, "level", 1)
    local info = {
        name = self.player.name,
        fightPower = 0,
        baseLevel = baseLevel,
        chain = self.player.playerInfoBag:getChainId() or 0,
    }
    return info
end

function PlayerInfoBag:getPlayerInfoByAdmin(isDetail)
    local result = {}
    result.account = self.player.account
    result.pid = self.player.pid
    result.platform = self.player.platform
    result.inviteCode = math.int2AnyStr(self.player.pid, 62)
    result.chainId = self:getChainId()
    result.walletAddress = self:getOwnerAddress()
    result.name = self.player.name
    result.headIcon = self.player.headIcon
    result.mit = self.player.resBag:getRes(constant.RES_MIT) / 1000
    result.carboxyl = self.player.resBag:getRes(constant.RES_CARBOXYL) / 1000
    result.starCoin = self.player.resBag:getRes(constant.RES_STARCOIN) / 1000
    result.titanium = self.player.resBag:getRes(constant.RES_TITANIUM) / 1000
    result.gas = self.player.resBag:getRes(constant.RES_GAS) / 1000
    result.ice = self.player.resBag:getRes(constant.RES_ICE) / 1000
    result.tesseract = self.player.resBag:getRes(constant.RES_TESSERACT) / 1000
    local pvpRankInfo = self.player.pvpBag:getPlayerRankInfo()
    result.badge = pvpRankInfo.score
    result.pvpRank = pvpRankInfo.index

    result.baseLevel = self.player.buildBag:getBaseBuildLevel()
    result.levelFiveTime = self.levelFiveTime
    result.vipLevel = self.player.vipBag:getVipLevel()
    result.pledgeMit = self.player.vipBag:getPledgeMit()

    result.createTime = self.player.createTime
    result.firstLoginTime = self.firstLoginTime
    result.firstLogoutTime = self.firstLogoutTime
    result.loginTime = self.player.loginTime
    result.logoutTime = self.player.logoutTime
    result.loginCount = self.loginCount or 0
    result.totalGameTime = self.totalGameTime

    result.server = skynet.config.id
    result.ip = (self.player.ip or self.player.logoutIp) or "0.0.0.0"
    result.onlineStatus = (self.player:isdisconnect()==true) and 0 or 1

    result.isRegDayLevel5 = self:isRegDayLevelFive()
    result.maxPVE = self.player.pveBag:getMaxPveWin()

    result.nftTotal = 0
    result.nftBuilds = {}
    result.nftHeros = {}
    result.nftWarShips = {}
    local nftBuilds = self.player.buildBag:getNftBuilds()
    local nftHeros = self.player.heroBag:getNftHeros()
    local nftWarShips = self.player.warShipBag:getNftWarShips()
    result.nftTotal = #nftBuilds + #nftHeros + #nftWarShips
    for k, build in pairs(nftBuilds) do
        table.insert(result.nftBuilds, build:packToLog())
    end
    for k, hero in pairs(nftHeros) do
        table.insert(result.nftHeros, hero:packToLog())
    end
    for k, warShip in pairs(nftWarShips) do
        table.insert(result.nftWarShips, warShip:packToLog())
    end

    if isDetail then
        local normalBuilds = self.player.buildBag:getNormalBuilds()
        local normalHeros = self.player.heroBag:getNormalHeros()
        local normalWarShips = self.player.warShipBag:getNormalWarShips()
        result.normalBuilds = {}
        result.normalHeros = {}
        result.normalWarShips = {}
        for k, build in pairs(normalBuilds) do
            table.insert(result.normalBuilds, build:packToLog())
        end
        for k, hero in pairs(normalHeros) do
            table.insert(result.normalHeros, hero:packToLog())
        end
        for k, warShip in pairs(normalWarShips) do
            table.insert(result.normalWarShips, warShip:packToLog())
        end

        result.items = {}
        for k, item in pairs(self.player.itemBag:getAllItems()) do
            table.insert(result.items, { id = item.id, cfgId = item.cfgId, num = item.num })
        end
    end
    return result
end

function PlayerInfoBag:onSecond()

end

function PlayerInfoBag:oncreate()
    if self.player.headIcon == "" then
        self.player.headIcon = self:getRandomHeadIcon()
    end
    gg.shareProxy:send("setPlayerBaseInfo", self.player.pid, { 
        name = self.player.name,
        currentServerId = skynet.config.id,
        headIcon = self.player.headIcon,
        createTime = self.player.createTime,
    } )
    gg.internal:send(".gamelog", "api", "addPlayerCreateLog", self.player.pid, self.player.name, self.player.account, self.inviteCode, self.player.platform)
end

function PlayerInfoBag:aftercreate()
    local detail = self:getPlayerInfoByAdmin()
    detail.onlineStatus = 0
    detail.tuoguanStatus = 1
    gg.internal:send(".gamelog", "api", "savePlayerOnlineInfo", self.player.pid, nil, detail)
end

function PlayerInfoBag:onload()

end

function PlayerInfoBag:onPlayerMgrAdd()
    local section = {}
    section.tuoguanStatus = 1
    gg.internal:send(".gamelog", "api", "savePlayerOnlineInfo", self.player.pid, section)
end

function PlayerInfoBag:onPlayerMgrDel()
    local detail = self:getPlayerInfoByAdmin()
    detail.onlineStatus = 0
    detail.tuoguanStatus = 0
    gg.internal:send(".gamelog", "api", "savePlayerOnlineInfo", self.player.pid, nil, detail)
end

function PlayerInfoBag:doLogin()
    self.loginId = snowflake.uuid()
    self.player.loginTime = os.time()
    --"",""
    if self.firstLid <= 0 then
        self.firstLid = self.loginId
        self.firstLoginTime = os.time()
    end

    self.lastGameTime = os.time()
    self.player.logoutTime = 0
    self.loginCount = self.loginCount + 1

    local section = {}
    section.onlineStatus = 1
    gg.internal:send(".gamelog", "api", "savePlayerOnlineInfo", self.player.pid, section)

    local lid = self.loginId
    local remainTime = 0
    gg.internal:send(".gamelog", "api", "addPlayerLoginLog", lid, self.player.pid, self.player.platform, self.player.name, self.player.loginTime, remainTime, self.player.logoutTime, self.firstLid, self.firstLoginTime, self.firstLogoutTime, self.totalGameTime, self.loginCount)

    gg.client:send(self.player.linkobj, "S2C_Player_PlayerInfo", self:pack())
end

function PlayerInfoBag:correctData(kind)
    if kind == 1 then
        self.player.buildBag:correctBuilds()
    end
end

function PlayerInfoBag:onlogin()
    if self.loginId > 0 then
        --"",""
        self:doLogout()
    end
    assert(self.loginId <= 0, "loginId error")
    self:doLogin()

    self:queryWallet()

    if self.correct ~= 2 then
        self.correct = 2
        self:correctData(1)
    end
end

--"","",""
function PlayerInfoBag:onDayUpdate()
    local daynoCur = gg.time.dayno()
    if self.loginId > 0 and self.daynoTemp ~= daynoCur then
        --"","" 
        self.daynoTemp = daynoCur
        self:doLogout(true)
        assert(self.loginId <= 0, "loginId error")
        self:doLogin()
    end
end

function PlayerInfoBag:doLogout(isNewDay)
    if self.loginId > 0 then
        --"",""
        self:settleGameTime()
        self.lastGameTime = 0

        local lid = self.loginId
        self.loginId = 0

        --"",""。
        if not isNewDay and self.firstLogoutTime <= 0 then
            self.firstLogoutTime = os.time()
        end
        self.player.logoutTime = os.time()
        local detail = self:getPlayerInfoByAdmin()
        detail.onlineStatus = 0
        detail.tuoguanStatus = 1
        gg.internal:send(".gamelog", "api", "savePlayerOnlineInfo", self.player.pid, nil, detail)
    
        local remainTime = os.time() - self.player.loginTime
        gg.internal:send(".gamelog", "api", "updatePlayerLoginLog", lid, self.player.pid, self.player.platform, remainTime, self.player.logoutTime, self.firstLid, self.firstLoginTime, self.firstLogoutTime, self.totalGameTime, self.loginCount)
    end
end

function PlayerInfoBag:onlogout()
    self:doLogout()
end

function PlayerInfoBag:settleGameTime()
    if self.lastGameTime > 0 and self.loginId > 0 then
        local tempGameTime = os.time() - self.lastGameTime
        self.totalGameTime = self.totalGameTime + math.abs(tempGameTime)
        self.lastGameTime = os.time()
    end
end

function PlayerInfoBag:updatePlayerLogin()
    if self.loginId > 0 then
        local lid = self.loginId
        local remainTime = os.time() - self.player.loginTime
        gg.internal:send(".gamelog", "api", "updatePlayerLoginLog", lid, self.player.pid, self.player.platform, remainTime, self.player.logoutTime, self.firstLid, self.firstLoginTime, self.firstLogoutTime, self.totalGameTime, self.loginCount)
    end
end

function PlayerInfoBag:onMinuteUpdate()
    self:settleGameTime()
end

function PlayerInfoBag:onFiveMinuteUpdate()
    self:updatePlayerLogin()
end

return PlayerInfoBag