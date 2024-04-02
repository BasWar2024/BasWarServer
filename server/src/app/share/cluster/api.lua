-- ""api
local md5 =	require	"md5" 
local queue = require "skynet.queue"
gg.api = gg.api or {}
local api = gg.api


local function getBattleServerConfig(doType)
    local list = skynet.config["battleServer_config"]
    local len = #list

    local indexStart = 1
    local indexEnd = len
    if doType == "calc" then
        indexStart = math.floor(len / 2 + 1)
        return list[math.random(indexStart, indexEnd)]
    else
        indexEnd = math.floor(len / 2)
        indexEnd = math.max(1, indexEnd)
        return list[math.random(indexStart, indexEnd)]
    end
end

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

-- ""id
local function genUniqueId(idkey)
    local seq = gg.redisProxy:call("hincrby", constant.REDIS_AUTOINCRID, idkey, 1)
    return seq
end

function api.genWithdrawId()
    local text = gg.time.secondno(nil, 1672531200) .. genUniqueId("withdraw")
    return math.floor(tonumber(text))
end

function api.genUnionId()
    return genUniqueId("unionId") + 100000
end

function api.genMailId()
    return genUniqueId("mailId")
end

function api.genFlightId()
    local flightId = genUniqueId("flightId")
    return math.floor(10000 + tonumber(flightId))
end

function api.genRobotAccountSeq(accountPrefix)
    return genUniqueId(accountPrefix)
end

function api.genRoleId()
    local doc = gg.mongoProxy.roleid:findAndModify({
        query = {appid=skynet.config.appid, idkey=skynet.config.appid},
        update = {["$inc"] = {sequence = 1}},
        new = true,
        upsert = true,
    })
    local minroleid = 1000000
    local maxroleid = 2000000000
    local range = doc.value.sequence
    local roleid = minroleid + range - 1
    return roleid
end

function api.sendMailVerification(mailAddress)
    local verifyCode = string.randomnumber(6)
    local ret, response = api.sendCodeByMail(mailAddress, verifyCode)
    if ret == 200 then
        local keyName = constant.REDIS_MAIL_VERIFICATION .. mailAddress
        gg.redisProxy:send("set", keyName, verifyCode)
        gg.redisProxy:send("expire", keyName, 600)
    end
    return ret, response
end

function api.sendCodeByMail(mailAddress, verifyCode)
    local params = {
        sendMail = mailAddress,
        code = verifyCode,
    }
    params.sign = md5.sumhexa(gg.makeSignContent(params, "STARWARUTILITYINTERFACE2021HAPPYFISH"))
    local header = {}
    local ret, response = httpc.req("https://www.galaxyblitz.net/mail/sendcode/game",nil,params,false,header)
    logger.logf("info","share",string.format("op=sendCodeByMail,mailAddress=%s,verifyCode=%s,ret=%s,response=%s",mailAddress,verifyCode,ret,response))
    return ret, response
end

function api.checkVerifyCode(mailAddress, verifyCode)
    local keyName = constant.REDIS_MAIL_VERIFICATION .. mailAddress
    local curCode = gg.redisProxy:call("get", keyName)
    if not curCode then
        return false
    end
    if curCode ~= verifyCode then
        return false
    end
    gg.redisProxy:send("del",keyName)
    return true
end

function api.checkWrongTimes(wrongType, mailAddress)
    local keyName = string.format(constant.REDIS_WRONG_TIMES, wrongType, mailAddress)
    local curTimes = gg.redisProxy:call("get",keyName)
    if not curTimes or tonumber(curTimes) < 5 then
        return true, curTimes
    end
    return false, curTimes
end

function api.setWrongTimes(wrongType, mailAddress, increase)
    local keyName = string.format(constant.REDIS_WRONG_TIMES, wrongType, mailAddress)
    if increase then
        local curTimes = gg.redisProxy:call("get",keyName)
        local newTimes = math.floor((tonumber(curTimes) or 0) + 1)
        gg.redisProxy:send("set",keyName, newTimes)
        if tonumber(gg.redisProxy:call("get",keyName)) >= 5 then
            gg.redisProxy:send("expire", keyName, 24*60*60)
        end
    else
        gg.redisProxy:send("del", keyName)
    end
end

function api.initialWhiteListStatus()
    local ret = gg.redisProxy:call("get", constant.REDIS_WHITELISTSTATUS)
    if not ret then
        gg.redisProxy:call("set", constant.REDIS_WHITELISTSTATUS, "close")
        gg.redisProxy:call("zadd", constant.REDIS_WHITELIST, "2", "test01@gmail.com")
    end
end

function api.checkWhiteList(account)
    local ret = gg.redisProxy:call("get", constant.REDIS_WHITELISTSTATUS)
    if ret ~= "open3" and ret ~= "open2" and ret ~= "open1" then
        return true
    end
    if ret == "open3" then
        return false, httpc.answer.code.OPEN_PREPARE
    end
    local result = gg.redisProxy:call("zscore", constant.REDIS_WHITELIST, account)
    if result then
        if ret == "open2" then
            if result == "2" then
                return true
            end
            return false, httpc.answer.code.OPEN_LATER
        elseif ret == "open1" then
            if result == "2" or result == "1" then
                return true
            end
        end
    end
    return false, httpc.answer.code.NOT_IN_WHITE_LIST
end

function api.getWhiteListStatus()
    local ret = gg.redisProxy:call("get", constant.REDIS_WHITELISTSTATUS)
    return ret or "close"
end

function api.setWhiteListStatus(status)
    if status == "close" or status == "open1" or status == "open2" or status == "open3" then
        gg.redisProxy:call("set", constant.REDIS_WHITELISTSTATUS, status)
    end
    return api.getWhiteListStatus()
end

function api.getWhiteListAccount(pageNo, pageSize)
    pageNo = pageNo or 1
    if pageNo <= 1 then
        pageNo = 1
    end
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.redisProxy:call("zcount", constant.REDIS_WHITELIST, "0", "99")
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}

    local start = (pageNo - 1) * pageSize
    local stop = start + pageSize - 1
    local ret = gg.redisProxy:call("zrevrange", constant.REDIS_WHITELIST, start, stop, "withscores")
    for i = 1, #ret, 2 do
        local info = {}
        info.account = ret[i]
        info.value = ret[i + 1]
        table.insert(result.rows, info)
    end
    return result
end

function api.setWhiteListAccount(account, value)
    if value == "1" or value == "2" then
        gg.redisProxy:call("zadd", constant.REDIS_WHITELIST, value, account)
    else
        gg.redisProxy:call("zrem", constant.REDIS_WHITELIST, account)
    end
end

function api.initialTransportBanList()
    local ret = gg.redisProxy:call("hget", constant.REDIS_TRANSPORT_BANLIST, "test01@gmail.com")
    if not ret then
        gg.redisProxy:call("hset", constant.REDIS_TRANSPORT_BANLIST, "test01@gmail.com", "1")
    end
end

function api.isBanTransport(account)
    local ret = gg.redisProxy:call("hget", constant.REDIS_TRANSPORT_BANLIST, account)
    if ret and ret == "1" then
        return true
    end
    return false
end

function api.initialPrivateApi()
    local ret = gg.redisProxy:call("hget", constant.REDIS_PRIVATE_API_INFO, "test")
    if not ret then
        gg.redisProxy:call("hset", constant.REDIS_PRIVATE_API_INFO, "test", "0")
    end
end

function api.initialChainBridgeStatus()
    local ret = gg.redisProxy:call("get", constant.REDIS_CHAIN_BRIDGE_STATUS)
    if not ret then
        gg.redisProxy:call("set", constant.REDIS_CHAIN_BRIDGE_STATUS, "open")
    end
end

function api.getChainBridgeStatus()
    local ret = gg.redisProxy:call("get", constant.REDIS_CHAIN_BRIDGE_STATUS)
    return ret or "open"
end

function api.setChainBridgeStatus(status)
    if status == "close" or status == "open" then
        gg.redisProxy:call("set", constant.REDIS_CHAIN_BRIDGE_STATUS, status)
    end
    return api.getChainBridgeStatus()
end

function api.getChainBridgeNeedShip()
    local ret = gg.redisProxy:call("get", constant.REDIS_CHAIN_BRIDGE_NEED_SHIP)
    return ret or "close"
end

function api.setChainBridgeNeedShip(status)
    if status == "close" or status == "open" then
        gg.redisProxy:call("set", constant.REDIS_CHAIN_BRIDGE_NEED_SHIP, status)
    end
    return api.getChainBridgeNeedShip()
end

function api.getResUseRatio(res, pid)
    local keyName = constant.REDIS_RES_USE_RATIO .. res .. constant.REDIS_RES_USE_ALL
    if pid and pid ~= -1 then -- -1 ""，0 "" ""id""
        keyName = constant.REDIS_RES_USE_RATIO .. res .. "::" .. pid
    end
    return gg.redisProxy:call("hgetall",keyName) or {}
end

function api.setResUseRatio(res, data, pid)
    local keyName = constant.REDIS_RES_USE_RATIO .. res .. constant.REDIS_RES_USE_ALL
    if pid and pid ~= -1 then
        keyName = constant.REDIS_RES_USE_RATIO .. res .. "::" .. pid
    end
    gg.redisProxy:send("hset",keyName, "data", cjson.encode(data))
    return api.getResUseRatio(res, pid)
end

function api.removeResUseRatio(res, pid)
    local keyName = constant.REDIS_RES_USE_RATIO .. res .. constant.REDIS_RES_USE_ALL
    if pid ~= 0 then
        keyName = constant.REDIS_RES_USE_RATIO .. res .. "::" .. pid
    end
    return gg.redisProxy:call("del", keyName)
end

function api.setItemNote(pid,data)
    local keyName = constant.REDIS_GET_ITEM_NOTE .. pid
    for k,v in pairs(data) do
        gg.redisProxy:call("hset", keyName, v, 1)
    end
    return api.getItemNote(pid)
end

function api.getItemNote(pid)
    local keyName = constant.REDIS_GET_ITEM_NOTE .. pid
    return gg.redisProxy:call("hgetall",keyName) or {}
end

function api.setUsedItem(pid,ItemCfgId)
    local keyName = constant.REDIS_USED_UNIQUE_ITEMS .. pid
    gg.redisProxy:call("hset", keyName, ItemCfgId, 1)
    return api.getUsedItem(pid, ItemCfgId)
end

function api.getUsedItem(pid, ItemCfgId)
    local keyName = constant.REDIS_USED_UNIQUE_ITEMS .. pid
    return gg.redisProxy:call("hget",keyName, ItemCfgId)
end

function api.getPurchaseStatistics()
    local keyName = constant.REDIS_PURCHASE_STATISTICS
    return gg.redisProxy:call("hgetall",keyName) or {}
end

function api.setPurchaseStatistics(data)
    local keyName = constant.REDIS_PURCHASE_STATISTICS
    gg.redisProxy:send("hset",keyName, "data", cjson.encode(data))
    return api.getPurchaseStatistics()
end

function api.removePurchaseStatistics()
    local keyName = constant.REDIS_PURCHASE_STATISTICS
    return gg.redisProxy:call("del", keyName)
end

function api.getAllNftsStatistic(chainId)
    local keyName = constant.REDIS_NFTS_STATISTIC
    if chainId ~= 0 then
        return gg.redisProxy:call("hget",keyName, tonumber(chainId)) or {}
    end
    return gg.redisProxy:call("hgetall",keyName) or {}
end

function api.setAllNftsStatistic(data, chainId)
    local keyName = constant.REDIS_NFTS_STATISTIC
    for k,v in pairs(data) do
        gg.redisProxy:send("hset",keyName, k, cjson.encode(v))
    end
    return api.getAllNftsStatistic(chainId)
end

function api.removeAllNftsStatistic()
    local keyName = constant.REDIS_NFTS_STATISTIC
    return gg.redisProxy:call("del", keyName)
end

function api.getAccountByWalletAddress(walletAddress)
    local resultText = gg.redisProxy:call("hget",constant.REDIS_WALLET_ADDRESS_TO_ACCOUNT, walletAddress)
    if not resultText then
        local dataOne = gg.mongoProxy.account:findOne({owner_address=walletAddress})
        if not dataOne then
            return nil
        end
        if not dataOne.account or not dataOne.owner_address then
            return nil
        end
        local dataTwo = gg.mongoProxy.role:findOne({account=dataOne.account})
        if not dataTwo then
            return nil
        end
        local result = {}
        result.walletAddress = dataOne.owner_address
        result.accountMail = dataOne.account
        result.chainId = dataOne.chain_id
        result.pid = dataTwo.roleid
        result.platform = dataOne.platform
        resultText = cjson.encode(result)
        gg.redisProxy:call("hset",constant.REDIS_WALLET_ADDRESS_TO_ACCOUNT, walletAddress, resultText)
        resultText = gg.redisProxy:call("hget",constant.REDIS_WALLET_ADDRESS_TO_ACCOUNT, walletAddress)
    end
    local result = cjson.decode(resultText)
    result.pid = math.floor(tonumber(result.pid))
    return result
end

function api.getWalletAddressByAccount(account)
    local resultText = gg.redisProxy:call("hget",constant.REDIS_ACCOUNT_TO_WALLET_ADDRESS, account)
    if not resultText then
        local dataOne = gg.mongoProxy.account:findOne({account=account})
        if not dataOne then
            return nil
        end
        if not dataOne.account or not dataOne.owner_address then
            return nil
        end
        local dataTwo = gg.mongoProxy.role:findOne({account=dataOne.account})
        if not dataTwo then
            return nil
        end
        local result = {}
        result.walletAddress = dataOne.owner_address
        result.accountMail = dataOne.account
        result.chainId = dataOne.chain_id
        result.pid = dataTwo.roleid
        result.platform = dataOne.platform
        resultText = cjson.encode(result)
        gg.redisProxy:call("hset",constant.REDIS_ACCOUNT_TO_WALLET_ADDRESS, account, resultText)
        resultText = gg.redisProxy:call("hget",constant.REDIS_ACCOUNT_TO_WALLET_ADDRESS, account)
    end
    local result = cjson.decode(resultText)
    result.pid = math.floor(tonumber(result.pid))
    return result
end

function api.delWalletInfo(account, walletAddress)
    if account then
        gg.redisProxy:call("hdel",constant.REDIS_ACCOUNT_TO_WALLET_ADDRESS, account)
    end
    if walletAddress then
        gg.redisProxy:call("hdel",constant.REDIS_WALLET_ADDRESS_TO_ACCOUNT, walletAddress)
    end
end

function api.getOrderDailyCount()
    local text = gg.redisProxy:call("get",constant.REDIS_ORDER_DAILY_COUNT)
    if not text then
        text = "-1"
        gg.redisProxy:send("set",constant.REDIS_ORDER_DAILY_COUNT, text)
    end
    return tonumber(text)
end

function api.getChainBridgeInfo()
    local text = gg.redisProxy:call("get",constant.REDIS_CHAIN_BRIDGE_INFO)
    if not text then
        local initialData = {
        {chainId = 1, chainName = "Ethereum", open = 1},
        {chainId = 4, chainName = "Rinkeby", open = 1},
        {chainId = 56, chainName = "BSCMainNet", open = 1},
        {chainId = 97, chainName = "BSCTestNet", open = 1},}
        text = cjson.encode(initialData)
        gg.redisProxy:send("set",constant.REDIS_CHAIN_BRIDGE_INFO, text)
    end
    return cjson.decode(text)
end

--""MIT
function api.isWalletAddressHoldTrueMIT(walletAddress)
    local text = gg.redisProxy:call("get",constant.REDIS_HOLD_TRUE_MIT_WALLET_ADDRESS)
    if not text then
        return false
    end
    local walletAddressDict = cjson.decode(text)
    if walletAddressDict[walletAddress] then
        return true
    end
    return false
end

function api.setHoldTrueMitWalletAddress(text)
    gg.redisProxy:send("set",constant.REDIS_HOLD_TRUE_MIT_WALLET_ADDRESS, text)
end

function api.getHoldTrueMitWalletAddress()
    return gg.redisProxy:call("get",constant.REDIS_HOLD_TRUE_MIT_WALLET_ADDRESS)
end

function api.getPlayerProxy(pid)
    if not pid or pid < 1000 then
        return
    end
    gg.pidToNode = gg.pidToNode or {}
    local node = gg.pidToNode[pid]
    if node then
        return gg.getProxy(node, ".game")
    end
    node = api.getPlayerNodeByPid(pid)
    if not node then
        return nil
    end
    gg.pidToNode[pid] = node
    return gg.getProxy(node,".game")
end

function api.playerProxyCall(pid, cmd, ...)
    local proxy = api.getPlayerProxy(pid)
    if not proxy then
        return
    end
    return proxy:call("api", "doPlayerCmd", pid, cmd, ...)
end

--""
function api.getPlayerInfoByQueue(pid)
    if not pid then
        return
    end
    gg.lock = gg.lock or queue()    
    return gg.lock(api.playerProxyCall, pid, "getPlayerInfoByAdmin")
end

function api.checkBattleValid(battleId, battleType, battleInfo, signinPosId, operates, endStep)
    local config = getBattleServerConfig("check")
    if not config then
        return false, "battle server not config", constant.BATTLE_CODE_526, config
    end
    local postInfo = {
        battleId = battleId,
        battleType = battleType,
        battleInfo = battleInfo,
        signinPosId = signinPosId,
        operates = operates,
        endStep = endStep,
    }
    local respheader = {}
    local recvheader = {}
    local postInfoStr = cjson.encode(postInfo)
    local ok, status, body = xpcall(function(host, url, rheader, sheader, str)
        return httpc.request("POST", host, url, rheader, sheader, str)
    end, debug.traceback, config.host, "/checkBattleVaild", recvheader, respheader, postInfoStr)
    if not ok then
        if status == sockethelper.socket_error then
            logger.logf("error", "StarBattle", "checkBattleValid error=socket_error")
            return false, "battle server error", constant.BATTLE_CODE_527, config
        else
            logger.logf("error", "StarBattle", "checkBattleValid error="..tostring(status))
            return false, "battle server error", constant.BATTLE_CODE_528, config
        end
    end
    if status ~= 200 then
        logger.logf("error", "StarBattle", "checkBattleValid status="..tostring(status))
        return false, "battle server exec failed", constant.BATTLE_CODE_529, config
    end
    body = string.trimBom(body)
    local result = cjson.decode(body)
    if result.code ~= 0 then
        return false, "battle server error", constant.BATTLE_CODE_530, config
    end
    return true, result, 0, config
end

function api.calcBattleResult(battleId, battleType, battleInfo, signinPos, operates)
    local config = getBattleServerConfig("calc")
    if not config then
        return false, "battle server not config"
    end
    local req = {
        battleId = battleId,
        battleType = battleType,
        battleInfo = battleInfo,
        signinPosId = signinPos,
        operates = operates,
    }
    local respheader = {}
    local recvheader = {}
    local reqStr = cjson.encode(req)

    local ok, status, body = xpcall(function(host, url, rheader, sheader, str)
        return httpc.request("POST", host, url, rheader, sheader, str)
    end, debug.traceback, config.host, "/calcBattleResult", recvheader, respheader, reqStr)
    if not ok then
        if status == sockethelper.socket_error then
            logger.logf("error", "StarBattle", "calcBattleResult error=socket_error")
            return false, "battle server error"
        else
            logger.logf("error", "StarBattle", "calcBattleResult error="..tostring(status))
            return false, "battle server error"
        end
    end
    if status ~= 200 then
        logger.logf("error", "StarBattle", "calcBattleResult status="..tostring(status))
        return false, "battle server exec failed"
    end
    body = string.trimBom(body)
    local ok1, result = pcall(cjson.decode, body)
    if not ok1 then
        logger.logf("error", "StarBattle", "calcBattleResult json decode error, body="..body)
        return false, "body decode error"
    end
    if result.code ~= 0 then
        logger.logf("error", "StarBattle", "calcBattleResult result.code="..result.code)
        return false, "battle server result code error"
    end
    return true, result
end

function api.initialChainExclusive()
    api.getDynamicCfg(constant.REDIS_STARMAP_CHAIN_EXCLUSIVE)
end

function api.initialUrlConfig()
    api.getDynamicCfg(constant.REDIS_URL_CONFIG_BASE)
    api.getDynamicCfg(constant.REDIS_URL_CONFIG_MARKET)
end

-----------------------------------

function api.getPlayerNodeByPid(pid)
    local node = api.getPlayerBaseInfo(pid, "currentServerId", nil)
    if not node then
        local doc = gg.mongoProxy.role:findOne({roleid = pid})
        if not doc then
            return
        end
        node = doc.currentServerId
        api.setPlayerBaseInfo(pid, { currentServerId = node })
    end
    return node
end

function api.setPlayerBaseInfo(pid, infoDict)
    local keyName = constant.REDIS_PLAYER_BASE_INFO .. pid
    for k,v in pairs(infoDict) do
        gg.redisProxy:send("hset",keyName, k, v)
    end
    infoDict.playerId = pid
    gg.redisProxy:call("publish", constant.REDIS_CHAN_PLAYER_BASE_INFO..pid, cjson.encode(infoDict))
end

function api.getPlayerBaseInfo(pid, key, defaultValue)
    local keyName = constant.REDIS_PLAYER_BASE_INFO .. pid
    return gg.redisProxy:call("hget",keyName, key) or defaultValue
end

function api.getPlayerAllBaseInfo(pid)
    local ret = {}
    local keyName = constant.REDIS_PLAYER_BASE_INFO .. pid
    local info = gg.redisProxy:call("hgetall",keyName) or {}
    for i = 1, #info, 2 do
        ret[info[i]] = info[i+1]
    end
    return ret
end

function api.removePlayerBaseInfoKey(pid, key)
    local keyName = constant.REDIS_PLAYER_BASE_INFO .. pid
    return gg.redisProxy:call("hdel",keyName, key)
end

function api.getSystemNoticeInfo()
    return gg.redisProxy:call("get",constant.REDIS_SYSTEM_NOTICE)
end

function api.getUnionMemberInfos(playerIds)
    local script = [[
        local badgeRankPrefix = KEYS[1]
        local playerBaseInfoPrefix = KEYS[2]
        local list = {}
        for _, pid in ipairs(ARGV) do
            local score = redis.call("zscore", badgeRankPrefix, pid) 
            local rets = redis.call("hmget", playerBaseInfoPrefix..pid, "headIcon")
            local info = {}
            info.pid = pid
            info.score = score or 0
            info.headIcon = rets[1] or ""
            table.insert(list, cjson.encode(info))
        end
        return list
    ]]
    local playerInfos = {}
    local list = gg.redisProxy:call("eval", script, 2, constant.REDIS_RANK_BADGE, constant.REDIS_PLAYER_BASE_INFO, table.unpack(playerIds))
    if list and next(list) then
        for k, v in pairs(list) do
            local info = cjson.decode(v)
            table.insert(playerInfos, info)
        end
    end
    return playerInfos
end

-- function api.setPvpMatchJackpot(data)
--     local keyName = constant.REDIS_PVP_JACKPOT_INFO
--     local info
--     local db = gg.mongoProxy.redisdb
--     local value = db:get(keyName)
--     if not value or value == "" then
--         value = {
--             sysCarboxyl = data.sysCarboxyl or 0,
--             plyCarboxyl = data.plyCarboxyl or 0,
--         }
--         info = cjson.encode(value)
--     else
--         info = cjson.decode(value)
--         info.sysCarboxyl = info.sysCarboxyl + (data.sysCarboxyl or 0)
--         info.plyCarboxyl = info.plyCarboxyl + (data.plyCarboxyl or 0)
--         info = cjson.encode(info)
--     end
--     gg.redisProxy:send("set",keyName, info)
-- end


function api.getOpCfg(key)
    local ret
    local value = gg.redisProxy:call("get", key)
    if key == constant.REDIS_PVP_SYS_CARBOXYL then
        if not value then
            value = constant.PVP_SYS_CARBOXYL
            gg.redisProxy:send("set",constant.REDIS_PVP_SYS_CARBOXYL, value)
        end
        ret = tonumber(value)
    elseif key == constant.REDIS_PVP_STAGE_RATIO then
        if not value or value == "" then
            value = cjson.encode(constant.PVP_STAGE_RATIO)
            gg.redisProxy:send("set",constant.REDIS_PVP_STAGE_RATIO, value)
        end
        ret = cjson.decode(value)
    elseif key == constant.REDIS_PVP_JACKPOT_PLAYER_RATIO then
        if not value then
            value = constant.PVP_JACKPOT_PLAYER_RATIO
            gg.redisProxy:send("set",constant.REDIS_PVP_JACKPOT_PLAYER_RATIO, value)
        end
        ret = tonumber(value)
    elseif key == constant.REDIS_PVP_JACKPOT_SHARE_RATIO then
        if not value then
            value = constant.PVP_JACKPOT_SHARE_RATIO
            gg.redisProxy:send("set",constant.REDIS_PVP_JACKPOT_SHARE_RATIO, value)
        end
        ret = tonumber(value)
    elseif key == constant.REDIS_PVP_RANK_MIT_REWARD then
        if not value or value == "" then
            value = cjson.encode(constant.PVP_RANK_MIT_REWARD)
            gg.redisProxy:send("set",constant.REDIS_PVP_RANK_MIT_REWARD, value)
        end
        ret = cjson.decode(value)
    elseif key == constant.REDIS_PVP_JACKPOT_SYSVAL then
        if not value then
            value = constant.PVP_JACKPOT_SYSVAL
            gg.redisProxy:send("set",constant.REDIS_PVP_JACKPOT_SYSVAL, value)
        end
        ret = tonumber(value)
    elseif key == constant.REDIS_PVP_JACKPOT_INFO then
        if not value or value == "" then
            value = cjson.encode(constant.PVP_JACKPOT_INFO)
            gg.redisProxy:send("set",constant.REDIS_PVP_JACKPOT_INFO, value)
        end
        ret = cjson.decode(value)
    elseif key == constant.REDIS_STARMAP_BACKUP_UNION then
        if not value then
            value = constant.STARMAP_UNION_USE_BACKUP
            gg.redisProxy:send("set",constant.REDIS_STARMAP_BACKUP_UNION, value)
        end
        ret = tonumber(value)
    elseif key == constant.REDIS_STARMAP_JACKPOT_PLAYER_RATIO then
        if not value then
            value = constant.STARMAP_JACKPOT_PLAYER_RATIO
            gg.redisProxy:send("set",constant.REDIS_STARMAP_JACKPOT_PLAYER_RATIO, value)
        end
        ret = tonumber(value)
    elseif key == constant.REDIS_STARMAP_JACKPOT_INFO then
        if not value or value == "" then
            value = cjson.encode(constant.STARMAP_JACKPOT_INFO)
            gg.redisProxy:send("set",constant.REDIS_STARMAP_JACKPOT_INFO, value)
        end
        ret = cjson.decode(value)
    elseif key == constant.REDIS_STARMAP_JACKPOT_SHARE_RATIO then
        if not value then
            value = constant.STARMAP_JACKPOT_SHARE_RATIO
            gg.redisProxy:send("set",constant.REDIS_STARMAP_JACKPOT_SHARE_RATIO, value)
        end
        ret = tonumber(value)
    else
        ret = value
    end
    return ret
end

--""(web"")
local InitDynamicConfig = {
    [constant.REDIS_TESSERACT_TO_RES] = { data = constant.TESSERACT_TO_RES, type = "json" },
    [constant.REDIS_HYDROXYL_TO_TESSERACT] = { data = constant.HYDROXYL_TO_TESSERACT, type = "json" },
    [constant.REDIS_PVP_SYS_CARBOXYL] = { data = constant.PVP_SYS_CARBOXYL, type = "number" },
    [constant.REDIS_PVP_STAGE_RATIO] = { data = constant.PVP_STAGE_RATIO, type = "json" },
    [constant.REDIS_PVP_JACKPOT_PLAYER_RATIO] = { data = constant.PVP_JACKPOT_PLAYER_RATIO, type = "number" },
    [constant.REDIS_PVP_JACKPOT_SHARE_RATIO] = { data = constant.PVP_JACKPOT_SHARE_RATIO, type = "number" },
    [constant.REDIS_PVP_RANK_MIT_REWARD] = { data = constant.PVP_RANK_MIT_REWARD, type = "json" },
    [constant.REDIS_PVP_JACKPOT_SYSVAL] = { data = constant.PVP_JACKPOT_SYSVAL, type = "number" },
    [constant.REDIS_PVP_JACKPOT_INFO] = { data = constant.PVP_JACKPOT_INFO, type = "json" },
    [constant.REDIS_PVP_PLUNDER_RATIO] = { data = constant.PVP_PLUNDER_DEFAULT_RATIO, type = "number" },
    [constant.REDIS_PVP_NEW_PROTECT] = { data = constant.NEW_HAND_PVP_PROTECT_RATIO, type = "json" },
    [constant.REDIS_MATCH_CONFIG] = { data = "etc.cfg.match", type="cfg" },
    [constant.REDIS_MATCH_REWARD_CONFIG] = { data = "etc.cfg.matchReward", type = "cfg" },
    [constant.REDIS_CHAIN_BRIDGE_INFO] = { data = constant.CHAIN_BRIDGE_CONFIG, type = "json" },
    [constant.REDIS_PAY_CURRENCY_INFO] = { data = constant.PAY_CURRENCY_INFO, type = "json" },
    [constant.REDIS_PAY_CHANNEL_INFO] = { data = constant.PAY_CHANNEL_INFO, type = "json" },
    [constant.REDIS_STARMAP_JACKPOT_PLAYER_RATIO] = { data = constant.STARMAP_JACKPOT_PLAYER_RATIO, type = "number" },
    [constant.REDIS_STARMAP_JACKPOT_INFO] = { data = constant.STARMAP_JACKPOT_INFO, type = "json" },
    [constant.REDIS_STARMAP_CHAIN_EXCLUSIVE] = { data = constant.STARMAP_CHAIN_EXCLUSIVE, type = "json" },
    [constant.REDIS_URL_CONFIG_BASE] = { data = constant.URL_CONFIG_BASE, type = "string" },
    [constant.REDIS_URL_CONFIG_MARKET] = { data = constant.URL_CONFIG_MARKET, type = "string" },
}

function api.getDynamicCfg(key)
    local initConfig = InitDynamicConfig[key]
    if not initConfig then
        error("dynamic config("..key..") not init")
        return
    end
    local value = gg.redisProxy:call("get", key)
    if not value or value == "" then
        if initConfig.type == "cfg" then
            value = gg.deepcopy(cfg.get(initConfig.data))
        else
            value = initConfig.data
        end
        if initConfig.type == "json" or initConfig.type == "cfg" then
            gg.redisProxy:send("set", key, cjson.encode(value))
        else
            gg.redisProxy:send("set", key, value)
        end
        return value
    else
        if initConfig.type == "json" or initConfig.type == "cfg" then
            return cjson.decode(value)
        elseif initConfig.type == "number" then
            return tonumber(value)
        else
            return value
        end
    end
end

function api.setDynamicCfg(key, data)
    local initConfig = InitDynamicConfig[key]
    if not initConfig then
        error("dynamic config not init")
        return
    end
    if initConfig.type == "json" or initConfig.type == "cfg" then
        if type(data) == "table" then
            gg.redisProxy:send("set", key, cjson.encode(data))
        else
            error("dynamic config data format error")
        end
    else
        assert(type(data) == "string" or type(data) == "number", "dynamic config data format error")
        gg.redisProxy:send("set", key, data)
    end
end

---------------------------------------------
local function getRedisStarMapAllCfgDebug()
    local hasKey = constant.REDIS_STARMAP_H_KEY
    local setKey = constant.REDIS_STARMAP_SET_KEY
    local setMems = gg.redisProxy:call("smembers", setKey)
    if table.count(setMems) == 0 then--do init
        -- gg.starMapExcel:init()
    end
    local fields = {}
    for i, v in ipairs(setMems) do
        local fieldKey = hasKey .. v
        local fieldValStr = gg.redisProxy:call("hget", fieldKey, "fieldData")
        -- local fieldVal = gg.redisProxy:call("hgetall", fieldKey)
        table.insert(fields, v)
        table.insert(fields, fieldValStr)
    end
    return fields
end

function api.getRedisStarMapAllCfg()
    local script = [[
        local REDIS_STARMAP_H_KEY = KEYS[1]
        local REDIS_STARMAP_SET_KEY = KEYS[2]

        local ret = {}
        local setMems = redis.call('SMEMBERS', REDIS_STARMAP_SET_KEY)
        if #setMems == 0 then
            return ret
        end
        for i = 1, #setMems, 1 do
            local fieldKey = REDIS_STARMAP_H_KEY .. setMems[i]
            local fieldValStr = redis.call('HGET', fieldKey, 'fieldData')
            table.insert(ret, setMems[i])
            table.insert(ret, fieldValStr)
        end
        return ret
    ]]

    local ret = gg.execRedisScript(
        script,
        2,
        constant.REDIS_STARMAP_H_KEY,
        constant.REDIS_STARMAP_SET_KEY
    )
    -- local ret = getRedisStarMapAllCfgDebug()
    local cfgs = {}
    if ret and #ret > 0 then
        for i=1, #ret, 2 do
            cfgs[ret[i]] = cjson.decode(ret[i+1])
        end
    end
    return cfgs
end

function api.getRedisStarMapCfg(field)
    local hasKey = constant.REDIS_STARMAP_H_KEY
    if field then
        local fieldKey = hasKey .. field
        -- local value = gg.redisProxy:call("hgetall", fieldKey)
        local fieldValStr = gg.redisProxy:call("hget", fieldKey, "fieldData")
        if fieldValStr then
            return cjson.decode(fieldValStr)
        end
    else
        return api.getRedisStarMapAllCfg()
    end
end

function api.getRedisStarMapBeginGrids()
    local setMems = gg.redisProxy:call("smembers", constant.REDIS_STARMAP_BEGIN_GRIDS)
    return setMems
end

function api.setRedisStarMapOneCfg(cfgId, fieldValStr)
    local script = [[
        local REDIS_STARMAP_H_KEY = KEYS[1]
        local REDIS_STARMAP_SET_KEY = KEYS[2]
        local cfgId = ARGV[1]
        local fieldValStr = ARGV[2]

        local ret = 0
        local fieldKey = REDIS_STARMAP_H_KEY .. cfgId
        local curFieldValStr = redis.call('HGET', fieldKey, 'fieldData')
        if not curFieldValStr or curFieldValStr == "" then
            redis.call('HSET', fieldKey, 'fieldData', fieldValStr)
            ret = 1
        end
        return ret
    ]]

    local ret = gg.execRedisScript(
        script,
        2,
        constant.REDIS_STARMAP_H_KEY,
        constant.REDIS_STARMAP_SET_KEY,
        cfgId,
        fieldValStr
    )
    return ret
end
-------------------------------------------------

local REDIS_CMD = {
    ["EVAL"] = "eval",
    ["EVALSHA"] = "evalsha",
    ["SCRIPT"] = "script",
}
local REDIS_SCRIPT_SUBCMD = {
    ["LOAD"] = "LOAD",
    ["EXISTS"] = "EXISTS",
    ["FLUSH"] = "FLUSH",
    ["KILL"] = "KILL",
}
function api.exeRedisCmd(cmd, ...)
    local ret
    local cmdKey = REDIS_CMD[cmd]
    if not cmdKey then
        error("redis command "..tostring(cmd).." is error")
        return
    end
    local cmdArgs = {...}
    if cmdKey == "script" then
        local subcommand = cmdArgs[1]
        local subCmdKey = REDIS_SCRIPT_SUBCMD[subcommand]
        if not subCmdKey then
            error("redis command "..tostring(cmd).." sub command is error")
            return
        end
        ret = gg.redisProxy:call(cmdKey, subcommand, select(2, ...)) 
    else
        ret =  gg.redisProxy:call(cmdKey, select(1, ...))
    end
    return ret
end



return api