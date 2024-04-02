local GameLog = class("GameLog")

GameLog.SAVE_COUNT = 100

function GameLog:ctor()
    self.mitLogs = {}
    self.starCoinLogs = {}
    self.iceLogs = {}
    self.carboxylLogs = {}
    self.titaniumLogs = {}
    self.gasLogs = {}
    self.tesseractLogs = {}
    self.itemLogs = {}
    self.warShipLogs = {}
    self.heroLogs = {}
    self.buildLogs = {}
    self.starmapHyLogs = {}

    self.playerChatLogs = {}   --""
end

--""
function GameLog:batchInsert2DbByMonth(tableName, logs)
    local logsByDate = {}
    for k, v in pairs(logs) do
        local monthStr = os.date("%Y%m", v.timestamp)
        logsByDate[monthStr] = logsByDate[monthStr] or {}
        table.insert(logsByDate[monthStr], v)
    end
    for monthStr, list in pairs(logsByDate) do
        gg.mongoProxy[monthStr.."-"..tableName]:batch_insert(list)
    end
end

--""
function GameLog:batchInsert2Db(tableName, logs)
    gg.mongoProxy[tableName]:batch_insert(logs)
end

function GameLog:incrInstallAppCount(platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", os.time()))

    local updateDict = { 
        ["$set"] = {
            createDate = yearMonthDay,
            dayno = gg.time.dayno(),
            weekno = gg.time.weekno(),
            monthno = gg.time.monthno(),
            month = gg.time.month(),
            year = gg.time.year(),
            platform = platform,
        } ,
        ["$inc"] = {  
            installCount = 1,
        }
    }
    gg.mongoProxy.game_statistic_log:update({ createDate = yearMonthDay, platform = platform }, updateDict, true, false)
end

function GameLog:addActiveAccountLog(log)
    gg.mongoProxy.active_account_log:insert(log)

    local yearMonthDay = tonumber(os.date("%Y%m%d", os.time()))
    local updateDict = { 
        ["$set"] = {
            createDate = yearMonthDay,
            dayno = gg.time.dayno(),
            weekno = gg.time.weekno(),
            monthno = gg.time.monthno(),
            month = gg.time.month(),
            year = gg.time.year(),
            platform = log.platform
        } ,
        ["$inc"] = {  
            activeAccount = 1,
        }
    }
    gg.mongoProxy.game_statistic_log:update({ createDate = yearMonthDay,platform = log.platform}, updateDict, true, false)
end

function GameLog:addRegisterAccountLog(log)
    gg.mongoProxy.register_account_log:insert(log)

    local yearMonthDay = tonumber(os.date("%Y%m%d", os.time()))
    local updateDict = { 
        ["$set"] = {
            createDate = yearMonthDay,
            dayno = gg.time.dayno(),
            weekno = gg.time.weekno(),
            monthno = gg.time.monthno(),
            month = gg.time.month(),
            year = gg.time.year(),
            platform = log.platform
        } ,
        ["$inc"] = {  
            regAccount = 1,
        }
    }
    gg.mongoProxy.game_statistic_log:update({ createDate = yearMonthDay,platform = log.platform }, updateDict, true, false)
end

--""
function GameLog:addResLog(log)
    if log.resCfgId == constant.RES_MIT then
        self.mitLogs[#self.mitLogs+1] = log
    elseif log.resCfgId == constant.RES_STARCOIN then
        self.starCoinLogs[#self.starCoinLogs+1] = log
    elseif log.resCfgId == constant.RES_TITANIUM then
        self.titaniumLogs[#self.titaniumLogs+1] = log
    elseif log.resCfgId == constant.RES_CARBOXYL then
        self.carboxylLogs[#self.carboxylLogs+1] = log
    elseif log.resCfgId == constant.RES_GAS then
        self.gasLogs[#self.gasLogs+1] = log
    elseif log.resCfgId == constant.RES_ICE then
        self.iceLogs[#self.iceLogs+1] = log
    elseif log.resCfgId == constant.RES_TESSERACT then
        self.tesseractLogs[#self.tesseractLogs+1] = log
    end
    self:saveResLog()
end

--""
function GameLog:saveResLog(immediatelySave)
    if #self.mitLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.mitLogs
        self.mitLogs = {}
        self:batchInsert2Db("mit_log", logs)
    end
    if #self.starCoinLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.starCoinLogs
        self.starCoinLogs = {}
        self:batchInsert2Db("starcoin_log", logs)
    end
    if #self.titaniumLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.titaniumLogs
        self.titaniumLogs = {}
        self:batchInsert2Db("titanium_log", logs)
    end
    if #self.carboxylLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.carboxylLogs
        self.carboxylLogs = {}
        self:batchInsert2Db("carboxyl_log", logs)
    end
    if #self.gasLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.gasLogs
        self.gasLogs = {}
        self:batchInsert2Db("gas_log", logs)
    end
    if #self.iceLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.iceLogs
        self.iceLogs = {}
        self:batchInsert2Db("ice_log", logs)
    end
    if #self.tesseractLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.tesseractLogs
        self.tesseractLogs = {}
        self:batchInsert2Db("tesseract_log", logs)
    end
end

--""
function GameLog:addItemLog(log)
    self.itemLogs[#self.itemLogs+1] = log
    self:saveItemLog()
end

--""
function GameLog:saveItemLog(immediatelySave)
    if #self.itemLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.itemLogs
        self.itemLogs = {}
        self:batchInsert2Db("item_log", logs)
    end
end

--""
function GameLog:addWarShipLog(log)
    self.warShipLogs[#self.warShipLogs+1] = log
    self:saveWarShipLog()
end

--""
function GameLog:saveWarShipLog(immediatelySave)
    if #self.warShipLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.warShipLogs
        self.warShipLogs = {}
        self:batchInsert2Db("warship_log", logs)
    end
end

--""
function GameLog:addHeroLog(log)
    self.heroLogs[#self.heroLogs+1] = log
    self:saveHeroLog()
end

--""
function GameLog:saveHeroLog(immediatelySave)
    if #self.heroLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.heroLogs
        self.heroLogs = {}
        self:batchInsert2Db("hero_log", logs)
    end
end

--""
function GameLog:addBuildLog(log)
    self.buildLogs[#self.buildLogs+1] = log
    self:saveBuildLog()
end

--""
function GameLog:saveBuildLog(immediatelySave)
    if #self.buildLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.buildLogs
        self.buildLogs = {}
        self:batchInsert2Db("build_log", logs)
    end
end

function GameLog:addPlayerCreateLog(log)
    gg.mongoProxy.player_create_log:insert(log)

    local yearMonthDay = tonumber(os.date("%Y%m%d", os.time()))
    local updateDict = { 
        ["$set"] = {
            createDate = yearMonthDay,
            dayno = gg.time.dayno(),
            weekno = gg.time.weekno(),
            monthno = gg.time.monthno(),
            month = gg.time.month(),
            year = gg.time.year(),
            platform = log.platform
        } ,
        ["$inc"] = {  
            playerCount = 1,
        }
    }
    gg.mongoProxy.game_statistic_log:update({ createDate = yearMonthDay,platform = log.platform }, updateDict, true, false)
end

function GameLog:updatePlayerCreateLog(log)
    gg.mongoProxy.player_create_log:update({ pid = log.pid, platform = log.platform }, { ["$set"] = log}, false, false)
end

function GameLog:addPlayerLoginLog(log)
    gg.mongoProxy.player_login_log:insert(log)
end

function GameLog:updatePlayerLoginLog(log)
    gg.mongoProxy.player_login_log:update({ lid = log.lid }, { ["$set"] = log}, false, false)
end

function GameLog:addPlayerChatLog(log)
    self.playerChatLogs[#self.playerChatLogs+1] = log
    self:savePlayerChatLog()
end

function GameLog:savePlayerChatLog(immediatelySave)
    if #self.playerChatLogs > GameLog.SAVE_COUNT or immediatelySave then
        local logs = self.playerChatLogs
        self.playerChatLogs = {}
        self:batchInsert2Db("player_chat_log", logs)
    end
end

--""
function GameLog:addStarmapHyLog(log)
    self.starmapHyLogs[#self.starmapHyLogs+1] = log
    self:saveStarmapHyLog()
end

--""
function GameLog:saveStarmapHyLog(immediatelySave)
    if #self.starmapHyLogs > GameLog.SAVE_COUNT or immediatelySave == true then
        local logs = self.starmapHyLogs
        self.starmapHyLogs = {}
        self:batchInsert2Db("starmap_hy_log", logs)
    end
end

--""
function GameLog:addGmSendMailLog(log)
    gg.mongoProxy.gm_send_mail_log:insert(log)
end

function GameLog:saveAll(immediatelySave)
    self:saveResLog(immediatelySave)
    self:savePlayerChatLog(immediatelySave)
    self:saveItemLog(immediatelySave)
    self:saveWarShipLog(immediatelySave)
    self:saveHeroLog(immediatelySave)
    self:saveBuildLog(immediatelySave)
    self:saveStarmapHyLog(immediatelySave)
end

function GameLog:beginLog()
    self:clearOnlinePlayers()
end

function GameLog:shutdown()
    self:saveAll(true)
    self:clearOnlinePlayers()
end

function GameLog:clearOnlinePlayers()
    gg.mongoProxy.online_players:update({ server = skynet.config.id }, {["$set"] = { onlineStatus = 0, tuoguanStatus = 0 }}, false, true)
end

function GameLog:onSecond()

end

function GameLog:onMinuteUpdate()
    
end

function GameLog:onFiveMinuteUpdate()
    self:saveAll(true)
end

function GameLog:onHalfHourUpdate()

end

return GameLog