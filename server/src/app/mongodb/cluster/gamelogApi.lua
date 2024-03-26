local bson = require "bson"
gg.api = gg.api or {}
local api = gg.api

function api.getPlayerPVEStatistic()
    local db = gg.getdb("gamelog")
    if not db then
        return {}
    end
    local sortCond = bson.encode_order( "pveLevel", -1, "timestamp", 1)
    local pipeline = {
        {
            ["$sort"] = sortCond
        },
        {
            ["$limit"] = 2000,
        },
        {
            ["$group"] = {
                _id = "$pid",
                pid = { ["$first"] = "$pid" },
                name = { ["$first"] = "$name" },
                account = { ["$first"] = "$account" },
                pveScore = { ["$first"] = "$pveScore" },
                pveLevel = { ["$first"] = "$pveLevel" },
                level = { ["$first"] = "$level" },
                timestamp = { ["$first"] = "$timestamp" },
                createTime = {["$first"] = "$timestamp" },
            }
        },
        {
            ["$sort"] = sortCond
        },
        {
            ["$limit"] = 100,
        }
    }
    local ret = db:runCommand("aggregate", "player_pve_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end
    return ret.cursor.firstBatch
end

function api.getGameResLog(pageNo, pageSize, pid, res, reason, change)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = 0
    result.totalPage = 0
    result.rows = {}

    local db = gg.getdb("gamelog")
    if not db then
        return result
    end

    local tableName = nil
    if res == "MIT" then
        tableName = "mit_log"
    elseif res == "HYT" then
        tableName = "carboxyl_log"
    elseif res == "STARCOIN" then
        tableName = "starcoin_log"
    elseif res == "ICE" then
        tableName = "ice_log"
    elseif res == "TITANIUM" then
        tableName = "titanium_log"
    elseif res == "GAS" then
        tableName = "gas_log"
    elseif res == "TESSERACT" then
        tableName = "tesseract_log"
    else
        return result
    end
    local changeValue = { ["$gt"] = 0 }
    if change < 0 then
        changeValue = { ["$lt"] = 0 }
    end
    local query = { pid = pid, reason = reason, changeValue = changeValue}
    if change == 0 then
        query = { pid = pid, reason = reason}
    end
    result.totalRows = db[tableName]:find(query):count()
    result.totalPage = math.ceil(result.totalRows / pageSize)

    local docs = {}
    local cursor = db[tableName]:find(query):sort({ timestamp = -1 }):skip(pageSize*(pageNo - 1)):limit(pageSize)
    while cursor:hasNext() do
        local doc = cursor:next()
        table.insert(result.rows, { pid = doc.pid, platform = doc.platform, beforeValue = (doc.beforeValue or 0) / 1000, changeValue = (doc.changeValue or 0) / 1000, afterValue = (doc.afterValue or 0) / 1000, loseValue = (doc.loseValue or 0) / 1000, timestamp = doc.timestamp, reason = doc.reason, resCfgId = doc.resCfgId, extraId = doc.extraId })
    end

    return result
end

function api.getGameItemLog(pageNo, pageSize, pid, id, cfgId, reason)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = 0
    result.totalPage = 0
    result.rows = {}

    local db = gg.getdb("gamelog")
    if not db then
        return result
    end

    local tableName = "item_log"

    local query = { pid = pid, id = id, cfgId = cfgId, reason = reason }

    result.totalRows = db[tableName]:find(query):count()
    result.totalPage = math.ceil(result.totalRows / pageSize)

    local docs = {}
    local cursor = db[tableName]:find(query):sort({ timestamp = -1 }, { _id = -1 }):skip(pageSize*(pageNo - 1)):limit(pageSize)
    while cursor:hasNext() do
        local doc = cursor:next()
        table.insert(result.rows, { pid = doc.pid, platform = doc.platform, id = tostring(doc.id), cfgId = doc.cfgId, op = doc.op, beforeNum = (doc.beforeNum or 0), changeNum = (doc.changeNum or 0), afterNum = (doc.afterNum or 0), reason = doc.reason, timestamp = doc.timestamp})
    end
    return result
end

function api.getGameEntityLog(pageNo, pageSize, pid, entity, id, cfgId, reason)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = 0
    result.totalPage = 0
    result.rows = {}

    local db = gg.getdb("gamelog")
    if not db then
        return result
    end

    local tableName = nil
    if entity == "warship" then
        tableName = "warship_log"
    elseif entity == "hero" then
        tableName = "hero_log"
    elseif entity == "build" then
        tableName = "build_log"
    else
        return result
    end
    
    local query = { pid = pid, id = id, cfgId = cfgId, reason = reason }

    result.totalRows = db[tableName]:find(query):count()
    result.totalPage = math.ceil(result.totalRows / pageSize)

    local docs = {}
    local cursor = db[tableName]:find(query):sort({ timestamp = -1 }, { _id = -1 }):skip(pageSize*(pageNo - 1)):limit(pageSize)
    while cursor:hasNext() do
        local doc = cursor:next()
        local info = {}
        info.pid = doc.pid
        info.platform = doc.platform
        info.entity = entity
        info.chain = doc.chain
        info.id = tostring(doc.id)
        info.cfgId = doc.cfgId
        info.op = doc.op
        info.reason = doc.reason
        info.quality = doc.quality
        info.race = doc.race
        info.style = doc.style
        info.level = doc.level
        info.curLife = doc.curLife
        info.life = doc.life
        info.timestamp = doc.timestamp
        info.skill1 = doc.skill1
        info.skillLevel1 = doc.skillLevel1
        info.skill2 = doc.skill2
        info.skillLevel2 = doc.skillLevel2
        info.skill3 = doc.skill3
        info.skillLevel3 = doc.skillLevel3
        info.skill4 = doc.skill4
        info.skillLevel4 = doc.skillLevel4
        table.insert(result.rows, info)
    end
    return result
end

--res,"",MIT HYT STARCOIN ICE TITANIUM GAS
--dayno, dayno
--change""1,""; change""-1,""
--reason, "", nil""
--platform, platform
--pid, pid
function api.getGameTotalResByCondition(res, dayno, change, reason, platform, pid)
    local db = gg.getdb("gamelog")
    if not db then
        return 0
    end

    local tableName = nil
    if res == "MIT" then
        tableName = "mit_log"
    elseif res == "HYT" then
        tableName = "carboxyl_log"
    elseif res == "STARCOIN" then
        tableName = "starcoin_log"
    elseif res == "ICE" then
        tableName = "ice_log"
    elseif res == "TITANIUM" then
        tableName = "titanium_log"
    elseif res == "GAS" then
        tableName = "gas_log"
    elseif res == "TESSERACT" then
        tableName = "tesseract_log"
    else
        return 0
    end

    local changeValue = { ["$gt"] = 0 }
    if change < 0 then
        changeValue = { ["$lt"] = 0 }
    end

    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                changeValue = changeValue,
                reason = reason,
                platform = platform,
                pid = pid,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalValue = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$changeValue", 0 }
                    },
                }
            }
        }
    }
    local ret = db:runCommand("aggregate", tableName, "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalValue = ret.cursor.firstBatch[1].totalValue or 0
    totalValue = math.abs(totalValue)
    return totalValue
end

--res,"",MIT HYT STARCOIN ICE TITANIUM GAS
--change""1,""; change""-1,""
function api.getGameResByReason(res, change, pid, whiteList)
    local db = gg.getdb("gamelog")
    if not db then
        return 0
    end

    local tableName = nil
    if res == "MIT" then
        tableName = "mit_log"
    elseif res == "HYT" then
        tableName = "carboxyl_log"
    elseif res == "STARCOIN" then
        tableName = "starcoin_log"
    elseif res == "ICE" then
        tableName = "ice_log"
    elseif res == "TITANIUM" then
        tableName = "titanium_log"
    elseif res == "GAS" then
        tableName = "gas_log"
    elseif res == "TESSERACT" then
        tableName = "tesseract_log"
    else
        return 0
    end

    local changeValue = { ["$gt"] = 0 }
    if change < 0 then
        changeValue = { ["$lt"] = 0 }
    end
    local pipeline = {    -- ""
        {
            ["$match"] = {
                changeValue = changeValue,
            }
        },
        {
            ["$group"] = {
                _id = "$reason",
                totalValue = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$changeValue", 0 }
                    },
                }
            }
        }
    }
    if pid == 0 and next(whiteList) then
        pipeline[1] = {
            ["$match"] = {
                changeValue = changeValue,
                pid = {
                    ["$nin"] = whiteList
                }
            }
        }
    end
    if pid ~= 0 and pid ~= -1 then
        pipeline = {
            {
                ["$match"] = {
                    changeValue = changeValue,
                    pid = pid
                }
            },
            {
                ["$group"] = {
                    _id = "$reason",
                    totalValue = { 
                        ["$sum"] = {
                            ["$ifNull"] = { "$changeValue", 0 }
                        },
                    }
                }
            }
        }
    end
    local ret = db:runCommand("aggregate", tableName, "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch then
        return 0
    end
    local value = ret.cursor.firstBatch
    return value
end

function api.getSendMailLogs(pageNo, pageSize, sendId, sendName, receivePid, beginDate, endDate)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = 0
    result.totalPage = 0
    result.rows = {}

    local db = gg.getdb("gamelog")
    if not db then
        return result
    end

    local tableName = "gm_send_mail_log"

    local query = { sendId = sendId, sendName = sendName, createDate = { ["$gte"] = beginDate, ["$lte"] = endDate } }

    result.totalRows = db[tableName]:find(query):count()
    result.totalPage = math.ceil(result.totalRows / pageSize)

    local docs = {}
    local cursor = db[tableName]:find(query):sort({ timestamp = -1 }, { _id = -1 }):skip(pageSize*(pageNo - 1)):limit(pageSize)
    while cursor:hasNext() do
        local doc = cursor:next()
        if receivePid and receivePid > 0 then
            for i, v in ipairs(doc.toPidList) do
                if v == receivePid then
                    table.insert(result.rows, {
                        sendId = doc.sendId,
                        sendName = doc.sendName,
                        toPidList = doc.toPidList,
                        mailData = doc.mailData,
                    })
                end
            end
        else
            table.insert(result.rows, {
                sendId = doc.sendId,
                sendName = doc.sendName,
                toPidList = doc.toPidList,
                mailData = doc.mailData,
            })
        end
    end
    return result
end

return api