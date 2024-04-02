-- ""api
gg.api = gg.api or {}
local bson = require "bson"
local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

--""
function api.incrInstallAppCount(platform)
    gg.gameLog:incrInstallAppCount(platform)
end

--""
function api.registerWithInviteCode(accountid, account, inviteCode, fatherInviteCode)
    local fatherAccount = nil
    local fatherPid = nil
    local fatherInviteDoc = nil
    if fatherInviteCode then
        fatherInviteDoc = gg.mongoProxy.inviteAccount:findOne({inviteCode = fatherInviteCode})
    end
    if not fatherInviteDoc then
        fatherInviteCode = nil
    else
        fatherAccount = fatherInviteDoc.account
        fatherPid = fatherInviteDoc.pid
    end
    local doc = {
        accountid = accountid,
        account = account,
        inviteCode = inviteCode,
        fatherInviteCode = fatherInviteCode,
        timestamp = math.floor(skynet.timestamp()/1000),
        sonCount = 0,
        fatherAccount = fatherAccount,
        fatherPid = fatherPid,
    }
    gg.mongoProxy.inviteAccount:safe_insert(doc)

    if fatherInviteDoc then
        gg.mongoProxy.inviteAccount:findAndModify({
            query = { account=fatherAccount, sonCount = { ["$gte"] = 0 } },
            update = {["$inc"] = {sonCount = 1}},
            new = false,
            upsert = false,
        })
    end
end

--""
function api.bindAccountWithInviteCode(account, pid, inviteCode)
    gg.mongoProxy.inviteAccount:update({account = account}, {["$set"] = { inviteCode = inviteCode, pid = pid }} , false, false)
    if inviteCode then
        gg.mongoProxy.inviteAccount:update({fatherInviteCode = inviteCode}, {["$set"] = { fatherAccount = account, fatherPid = pid }} , false, true)
    end
end

--""
function api.addActiveAccountLog(account, openid, platform, device, sdk, inviteCode, fatherInviteCode)
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        account = account,
        openid = openid,
        platform = platform,
        device = device,
        sdk = sdk,
        timestamp = nowTime,
        dayno = gg.time.dayno(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        month = gg.time.month(),
        createTime = bson.date(nowTime),
        inviteCode = inviteCode,
        fatherInviteCode = fatherInviteCode,
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
    }
    gg.gameLog:addActiveAccountLog(log)
end

--""
function api.addRegisterAccountLog(account, pid, serverId,platform)
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        account = account,
        pid = pid,
        serverId = serverId,
        timestamp = nowTime,
        dayno = gg.time.dayno(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        month = gg.time.month(),
        createTime = bson.date(nowTime),
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
        platform = platform
    }
    gg.gameLog:addRegisterAccountLog(log)
end

--""
function api.addResLog(pid, platform, resCfgId, changeValue, beforeValue, afterValue, logType, reason, loseValue, extraId)
    assert(pid, "pid require")
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        pid = pid,
        platform = platform,
        extraId = extraId or 0, --0-system/PVP_PLUNDER""id/ITEM_USE""id
        resCfgId = resCfgId,
        changeValue = changeValue,
        beforeValue = beforeValue,
        afterValue = afterValue,
        logType = logType,  --""
        reason = reason,
        loseValue = loseValue or 0, --""
        dayno = gg.time.dayno(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        month = gg.time.month(),
        timestamp = nowTime,
        createTime = bson.date(nowTime),
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
    }
    gg.gameLog:addResLog(log)
end

--""
function api.addItemLog(pid, platform, id, cfgId, op, beforeNum, changeNum, afterNum, logType, reason)
    assert(pid, "pid require")
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        pid = pid,
        platform = platform,
        id = id,
        cfgId = cfgId,
        op = op,
        beforeNum = beforeNum,
        changeNum = changeNum,
        afterNum = afterNum,
        logType = logType,
        reason = reason,
        dayno = gg.time.dayno(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        month = gg.time.month(),
        timestamp = nowTime,
        createTime = bson.date(nowTime),
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
    }
    gg.gameLog:addItemLog(log)
end

--""
function api.addEntityLog(pid, platform, op, logType, reason, entityType, data)
    assert(pid, "pid require")
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        pid = pid,
        platform = platform,
        op = op,
        logType = logType,
        reason = reason,
        dayno = gg.time.dayno(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        month = gg.time.month(),
        timestamp = nowTime,
        createTime = bson.date(nowTime),
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
    }
    for k, v in pairs(data) do
        log[k] = v
    end
    if entityType == constant.ITEM_WAR_SHIP then
        gg.gameLog:addWarShipLog(log)
    elseif entityType == constant.ITEM_HERO then
        gg.gameLog:addHeroLog(log)
    elseif entityType == constant.ITEM_BUILD then
        gg.gameLog:addBuildLog(log)
    end
end

function api.addPlayerCreateLog(pid, playerName, account, inviteCode, platform)
    assert(pid, "pid require")
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        pid = pid,
        account = account,
        playerName = playerName,
        serverIndex = skynet.config.index,
        dayno = gg.time.dayno(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        month = gg.time.month(),
        timestamp = nowTime,
        createTime = bson.date(nowTime),
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
        platform = platform,
    }
    gg.gameLog:addPlayerCreateLog(log)
end

function api.addPlayerPayOrderLog(pid, orderId, price, value, dayno)
    gg.mongoProxy.player_create_log:update({ pid = pid, firstPaymentDayno = { ["$exists"] = false } }, { ["$set"] = { firstPaymentDayno = dayno }}, false, false)
    gg.mongoProxy.player_create_log:update({ pid = pid, firstOrderDayno = { ["$exists"] = false } }, { ["$set"] = { firstOrderDayno = dayno, firstOrderId = orderId, firstOrderPrice = price, firstOrderValue = value }}, false, false)
end

function api.addPlayerHydroxylExchangeLog(pid, hydroxyl, tesseract)
    local dayno = gg.time.dayno()
    gg.mongoProxy.player_create_log:update({ pid = pid, firstPaymentDayno = { ["$exists"] = false } }, { ["$set"] = { firstPaymentDayno = dayno }}, false, false)
    gg.mongoProxy.player_create_log:update({ pid = pid, firstExchangeDayno = { ["$exists"] = false } }, { ["$set"] = { firstExchangeDayno = dayno, firstExchangeHydroxyl = hydroxyl, firstExchangeTesseract = tesseract }}, false, false)
end

function api.addPlayerLoginLog(lid, pid, platform, playerName, loginTime, remainTime, logoutTime, firstLid, firstLoginTime, firstLogoutTime, totalGameTime, onlineCount)
    assert(lid > 0, "lid require")
    assert(pid > 0, "pid require")
    assert(platform, "platform require")
    assert(loginTime > 0, "loginTime require")
    local onlineMinute = math.ceil(remainTime / 60)
    local yearMonthDay = tonumber(os.date("%Y%m%d", os.time()))
    local log = {
        lid = lid,
        pid = pid,
        platform = platform,
        playerName = playerName,
        serverIndex = skynet.config.index,
        timestamp = loginTime,
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        dayno = gg.time.dayno(),
        month = gg.time.month(),
        loginTime = loginTime,
        loginTimeDate = bson.date(loginTime),
        loginDate = tonumber(os.date("%Y%m%d", loginTime)),
        logoutTime = logoutTime,
        logoutTimeDate = (logoutTime > 0) and bson.date(logoutTime) or nil,
        remainTime = remainTime,
        onlineMinute = onlineMinute,
        isFristLogin = (lid == firstLid) and true or false,
        createDate = yearMonthDay
    }
    gg.gameLog:addPlayerLoginLog(log)

    local firstGameTime = 0
    if firstLogoutTime > 0 then
        firstGameTime = firstLogoutTime - firstLoginTime
    else
        firstGameTime = os.time() - firstLoginTime
    end
    local updatelog = {
        pid = pid,
        platform = platform,
        onlineCount = onlineCount,
        totalGameTime = totalGameTime,
        firstGameTime = firstGameTime,
        totalGameMinute = math.ceil(totalGameTime / 60)
    }
    gg.gameLog:updatePlayerCreateLog(updatelog)
end

function api.updatePlayerLoginLog(lid, pid, platform, remainTime, logoutTime, firstLid, firstLoginTime, firstLogoutTime, totalGameTime, onlineCount)
    local onlineMinute = math.ceil(remainTime / 60)
    local log = {
        lid = lid,
        pid = pid,
        platform = platform,
        logoutTime = logoutTime,
        logoutTimeDate = (logoutTime > 0) and bson.date(logoutTime) or nil,
        remainTime = remainTime,
        onlineMinute = onlineMinute
    }
    gg.gameLog:updatePlayerLoginLog(log)

    local firstGameTime = 0
    if firstLogoutTime > 0 then
        firstGameTime = firstLogoutTime - firstLoginTime
    else
        firstGameTime = os.time() - firstLoginTime
    end
    local updatelog = {
        pid = pid,
        platform = platform,
        onlineCount = onlineCount,
        totalGameTime = totalGameTime,
        firstGameTime = firstGameTime,
        totalGameMinute = math.ceil(totalGameTime / 60)
    }
    gg.gameLog:updatePlayerCreateLog(updatelog)
end

function api.addPlayerChatLog(pid, platform,playerName, text)
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        pid = pid,
        platform = platform,
        playerName = playerName,
        text = text,
        timestamp = nowTime,
        createTime = bson.date(nowTime),
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
    }
    gg.gameLog:addPlayerChatLog(log)
end

function api.addPlayerPVELog(log)
    local nowTime = math.floor(skynet.timestamp()/1000)
    log.createTime = bson.date(nowTime)
    log.timestamp = nowTime
    gg.mongoProxy.player_pve_log:safe_insert(log)
end

function api.savePlayerOnlineInfo(pid, section, detail)
    if detail then
        gg.mongoProxy.online_players:update({pid = pid}, detail, true, false)
    end
    if section then
        gg.mongoProxy.online_players:update({pid = pid},{["$set"] = section},false,false)
    end
end

function api.addServerStatusLog(log)
    log.timestamp = os.time()
    log.createDate = tonumber(os.date("%Y%m%d", os.time()))
    local doc = {
        id = log.id,
        name = log.name,
        type = log.type,
        linknum = log.linknum,
        onlinenum = log.onlinenum,
        max_onlinenum = log.max_onlinenum,
        min_onlinenum = log.min_onlinenum,
        tuoguannum = log.tuoguannum,
        onlinelimit = log.onlinelimit,
        task = log.task,
        message = log.message,
        cpu = log.cpu,
        mqlen = log.mqlen,
        busyness = log.busyness,
        timestamp = os.time(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        dayno = gg.time.dayno(),
        createDate = tonumber(os.date("%Y%m%d", os.time())),
        opentime = log.opentime,
    }
    for _, platform in ipairs(constant.getAllPlatform()) do
        doc[platform] = log[platform]
    end
    gg.mongoProxy.server_status_log:safe_insert(doc)
end

--""
function api.addStarmapHyLog(unionId, logType, reason, gridCfgId, x, z, curHydroxyl, memHyDict)
    assert(unionId, "unionId require")
    if curHydroxyl <= 0 then
        return
    end
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        unionId = unionId,
        logType = logType,
        reason = reason,
        gridCfgId = gridCfgId,
        x = x,
        z = z,
        curHydroxyl = curHydroxyl,
        memHyDict = memHyDict,
        dayno = gg.time.dayno(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        month = gg.time.month(),
        timestamp = nowTime,
        createTime = bson.date(nowTime),
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
    }
    gg.gameLog:addStarmapHyLog(log)
end

--""
function api.addGmSendMailLog(sendId, sendName, toPidList, mailData)
    assert(sendId, "sendId require")
    local nowTime = math.floor(skynet.timestamp()/1000)
    local log = {
        sendId = sendId,
        sendName = sendName,
        toPidList = toPidList,
        mailData = mailData,
        dayno = gg.time.dayno(),
        weekno = gg.time.weekno(),
        monthno = gg.time.monthno(),
        month = gg.time.month(),
        timestamp = nowTime,
        createTime = bson.date(nowTime),
        createDate = tonumber(os.date("%Y%m%d", nowTime)),
    }
    gg.gameLog:addGmSendMailLog(log)
end

return api