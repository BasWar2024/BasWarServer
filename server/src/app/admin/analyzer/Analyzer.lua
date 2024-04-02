local Analyzer = class("Analyzer")
local bson = require "bson"
local queue = require "skynet.queue"

function Analyzer:ctor()
    self:onStart()
    self:onFiveMinuteUpdate()
    self:onTenMinuteUpdate()
end


--""
function Analyzer:getFirstAccountRegTimestamp()
    local docs = gg.mongoProxy.register_account_log:findSortLimit({}, {timestamp = 1}, 1)
    if #docs == 0 then
        return 0
    end
    local timestamp = docs[1].timestamp
    return gg.time.dayzerotime(timestamp)
end


--""
function Analyzer:getLastAccountRegTimestamp()
    local docs = gg.mongoProxy.register_account_log:findSortLimit({}, {timestamp = -1}, 1)
    if #docs == 0 then
        return 0
    end
    return docs[1].timestamp
end


--"" 
function Analyzer:getServerTotalOnlineInfo(platform)
    local curdate = tonumber(os.date("%Y%m%d", os.time()))
    local beginTimeStamp = os.time() - 300
    local endTimeStamp = os.time()
    local pipeline = {
        {
            ["$match"] = {
                createDate = curdate,
                timestamp = { 
                    ["$lte"] = endTimeStamp, 
                    ["$gt"] = beginTimeStamp 
                },
            }
        },
        {
            ["$sort"] = {
                timestamp = -1
            }
        },
        {
            ["$group"] = {
                _id = "$_id",
                min_onlinenum = { ["$first"] = "$"..platform..".min_onlinenum" },
                max_onlinenum = { ["$first"] = "$"..platform..".max_onlinenum"},
                linknum = { ["$first"] = "$linknum" },
                onlinenum = { ["$first"] = "$"..platform..".onlinenum" },
            }
        },
        {
            ["$group"] = {
                _id = "total",
                min_onlinenum = { ["$min"] = "$min_onlinenum" },
                max_onlinenum = { ["$max"] = "$max_onlinenum"},
                linknum = { ["$avg"] = "$linknum" },
                onlinenum = { ["$avg"] = "$onlinenum" },
            }
        }
    }
    
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "server_status_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return {
            min_onlinenum  = 0,
            max_onlinenum = 0,
            linknum = 0,
            onlinenum = 0,
        }
    end
    return ret.cursor.firstBatch[1]
end


function Analyzer:getTotalGameTime(time1,platform)
    local dayno = gg.time.dayno(time1)
    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                platform = platform,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                num = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$onlineMinute", 0 }
                    },
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_login_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    return ret.cursor.firstBatch[1].num or 0
end

--""
function Analyzer:getPlayerTotalResInfo()
    local pipeline = {
		{
			["$group"] = {
				_id = 0,
				mit = {
                    ["$sum"] = "$resBag.resources.101.num"
                }, 
                starCoin = { 
                    ["$sum"] = "$resBag.resources.102.num"
                },
                ice = {
                    ["$sum"] = "$resBag.resources.103.num"
                },
                carboxyl = {
                    ["$sum"] = "$resBag.resources.104.num"
                },
                titanium = {
                    ["$sum"] = "$resBag.resources.105.num"
                },
                gas = {
                    ["$sum"] = "$resBag.resources.106.num"
                },
                tesseract = {
                    ["$sum"] = "$resBag.resources.107.num"
                },
                bindMit = {
                    ["$sum"] = "$resBag.resources.101.bindNum"
                }, 
                bindStarCoin = { 
                    ["$sum"] = "$resBag.resources.102.bindNum"
                },
                bindIce = {
                    ["$sum"] = "$resBag.resources.103.bindNum"
                },
                bindCarboxyl = {
                    ["$sum"] = "$resBag.resources.104.bindNum"
                },
                bindTitanium = {
                    ["$sum"] = "$resBag.resources.105.bindNum"
                },
                bindGas = {
                    ["$sum"] = "$resBag.resources.106.bindNum"
                },
                bindTesseract = {
                    ["$sum"] = "$resBag.resources.107.bindNum"
                },
			}
		}
	}
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "player", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return
    end
    local result = {
        mitTotal = (ret.cursor.firstBatch[1].mit or 0) + (ret.cursor.firstBatch[1].bindMit or 0),
        starCoinTotal = (ret.cursor.firstBatch[1].starCoin or 0) + (ret.cursor.firstBatch[1].bindStarCoin or 0),
        iceTotal = (ret.cursor.firstBatch[1].ice or 0) + (ret.cursor.firstBatch[1].bindIce or 0),
        carboxylTotal = (ret.cursor.firstBatch[1].carboxyl or 0) + (ret.cursor.firstBatch[1].bindCarboxyl or 0),
        titaniumTotal = (ret.cursor.firstBatch[1].titanium or 0) + (ret.cursor.firstBatch[1].bindTitanium or 0),
        gasTotal = (ret.cursor.firstBatch[1].gas or 0) + (ret.cursor.firstBatch[1].bindGas or 0),
        tesseractTotal = (ret.cursor.firstBatch[1].tesseract or 0) + (ret.cursor.firstBatch[1].bindTesseract or 0),
    }
    return result
end

--""nft""
function Analyzer:getGameNftHeroTotalNum()
    local pipeline = {
		{
            ["$unwind"] = "$heroBag.heros",
        },
        {
            ["$match"] = {
                ["heroBag.heros.chain"] = {
                    ["$gt"] = 0,
                }
            }
        },
        {
            ["$count"] = "num",
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "player", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return
    end
    return ret.cursor.firstBatch[1].num or 0
end

--""nft""
function Analyzer:getGameNftWarshipTotalNum()
    local pipeline = {
		{
            ["$unwind"] = "$warShipBag.warShips",
        },
        {
            ["$match"] = {
                ["warShipBag.warShips.chain"] = {
                    ["$gt"] = 0,
                }
            }
        },
        {
            ["$count"] = "num",
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "player", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return
    end
    return ret.cursor.firstBatch[1].num or 0
end

--""nft""
function Analyzer:getGameNftGunTurretNum()
    local pipeline = {
		{
            ["$unwind"] = "$buildBag.builds",
        },
        {
            ["$match"] = {
                ["buildBag.builds.chain"] = {
                    ["$gt"] = 0,
                },
                --["$buildBag.builds.type"] = constant.BUILD_TYPE_DEFEND,
                --["$buildBag.builds.subType"] = constant.BUILD_SUBTYPE_CANNON,
            }
        },
        {
            ["$count"] = "num",
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "player", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return
    end
    return ret.cursor.firstBatch[1].num or 0
end

--""NFT""
function Analyzer:getGameNftArtifactTotalNum()
    local pipeline = {
		{
            ["$unwind"] = "$itemBag.items",
        },
        {
            ["$match"] = {
                ["itemBag.items.cfgId"] = {
                    ["$in"] = constant.ITEM_ARTIFACT_LISTS,
                },
            }
        },
        {
            ["$count"] = "num",
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "player", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return
    end
    return ret.cursor.firstBatch[1].num or 0
end

--""
function Analyzer:getSameTimeOnlineNumInfo(time1,platform)
    local dayno = gg.time.dayno(time1)
    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                platform = platform
            }
        },
        {
            ["$group"] = {
                _id = 0,
                onlineNum = { 
                    ["$avg"] = { 
                        ["$ifNull"] = { "$onlineNum", 0 } 
                    } 
                },
                maxOnlineNum = { 
                    ["$max"] = { 
                        ["$ifNull"] = { "$maxOnlineNum", 0 } 
                    } 
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "server_status_statistic_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local onlineNum = ret.cursor.firstBatch[1].onlineNum or 0
    local maxOnlineNum = ret.cursor.firstBatch[1].maxOnlineNum or 0
    return onlineNum, maxOnlineNum
end

function Analyzer:getTotalUseMit(time1, platform)
    local dayno = gg.time.dayno(time1)
    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                changeValue = { ["$lt"] = 0 },
                platform = platform,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                num = { 
                    ["$sum"] = {
                        ["$ifNull"] = {"$changeValue", 0}
                    },
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "mit_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local num = ret.cursor.firstBatch[1].num or 0
    num = math.abs(num)
    return num
end

function Analyzer:getTotalUseCarboxyl(time1, platform)
    local dayno = gg.time.dayno(time1)
    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                changeValue = { ["$lt"] = 0 },
                platform = platform,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                num = { 
                    ["$sum"] = {
                        ["$ifNull"] = {"$changeValue", 0}
                    },
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "carboxyl_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local num = ret.cursor.firstBatch[1].num or 0
    num = math.abs(num)
    return num
end

--""dau
--time1 "" 
function Analyzer:getDayActiveUserNum(time1,platform)
    local dayno = gg.time.dayno(time1)
    local pipeline = {
		{
            ["$match"] = { dayno = dayno ,platform = platform},
        },
        {
            ["$group"] = {
                _id = "$pid",
                loginCount = { ["$sum"] = 1 },
            }
        },
        {
            ["$group"] = {
                _id = "0",
                userNum = { ["$sum"] = 1 },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_login_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    return ret.cursor.firstBatch[1].userNum or 0
end

--""
--time1 ""
function Analyzer:getWeekActiveUserNum(time1,platform)
    local dayno = gg.time.dayno(time1)
    local pipeline = {
		{
            ["$match"] = { 
                dayno = { ["$gte"] = dayno-6, ["$lte"] = dayno } ,
                platform = platform
            },
        },
        {
            ["$group"] = {
                _id = "$pid",
                loginCount = { ["$sum"] = 1 },
            }
        },
        {
            ["$group"] = {
                _id = "0",
                userNum = { ["$sum"] = 1 },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_login_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    return ret.cursor.firstBatch[1].userNum or 0
end

--""
--time1 ""
function Analyzer:getMonthActiveUserNum(time1,platform)
    local dayno = gg.time.dayno(time1)
    local pipeline = {
		{
            ["$match"] = { 
                dayno = { ["$gte"] = dayno - 29, ["$lte"] = dayno } ,
                platform = platform
            },
        },
        {
            ["$group"] = {
                _id = "$pid",
                loginCount = { ["$sum"] = 1 },
            }
        },
        {
            ["$group"] = {
                _id = "0",
                userNum = { ["$sum"] = 1 },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_login_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    return ret.cursor.firstBatch[1].userNum or 0
end


--""
--time1 ""
function Analyzer:getDayAddUserNum(time1,platform)
    local dayno = gg.time.dayno(time1)

    local pipeline = {
		{
            ["$match"] = { 
                dayno = dayno ,
                platform = platform
            },
        },
        {
            ["$group"] = {
                _id = 0,
                num = { ["$sum"] = 1 },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    return ret.cursor.firstBatch[1].num or 0
end

--""
function Analyzer:getUserFirstGameTimeAvg(time1, platform)
    local dayno = gg.time.dayno(time1)
    local pipeline = {
		{
            ["$match"] = { dayno = dayno ,platform = platform},
        },
        {
            ["$group"] = {
                _id = 0,
                num = {
                    ["$avg"] = {
                        ["$ifNull"] = { "$firstGameTime", 0 }
                    } 
                },
            },
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})

    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    return ret.cursor.firstBatch[1].num or 0
end

--""7""
--time1 ""
function Analyzer:getNewAddValidUserNum(time1, needLoginDay, beginDayDiff, endDayDiff,platform)
    needLoginDay = needLoginDay or 2
    beginDayDiff = beginDayDiff or 0
    endDayDiff = endDayDiff or 7

    local dayno = gg.time.dayno(time1)

    local beginDayno = dayno + beginDayDiff
    local endDayno = dayno + endDayDiff

    local pipeline = {
		{
            ["$match"] = { dayno = dayno ,platform = platform
            },
        },
        {
            ["$lookup"] = {
                from = "player_login_log",
                localField = "pid",
                foreignField = "pid",
                as = "logs",
            }
        },
        {
            ["$unwind"] = "$logs",
        },
        {
            ["$match"] = {
                ["logs.dayno"] = { ["$gte"] = beginDayno, ["$lte"] = endDayno },
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                loginDays = { ["$addToSet"] = "$logs.dayno" },
            }
        },
        {
            ["$project"] = {
                _id = 1,
                loginDayCnt = { ["$size"] = "$loginDays" },
            }
        },
        {
            ["$match"] = {
                loginDayCnt = { ["$gte"] = needLoginDay },
            }
        },
        {
            ["$group"] = {
                _id = "$_id",
                num = { ["$sum"] = 1 }
            }
        },
        {
            ["$count"] =  "num"
        }
    }
    
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    
    return ret.cursor.firstBatch[1].num or 0
end

--""1""
--time1 ""
function Analyzer:getRegStayUserNum1(key, time1, beginDiff, endDiff,platform)
    beginDiff = beginDiff or 1
    endDiff = endDiff or 7

    local keyNo
    if key == "dayno" then
        keyNo = gg.time.dayno(time1)
    elseif key == "weekno" then
        keyNo = gg.time.weekno(time1)
    elseif key == "monthno" then
        keyNo = gg.time.monthno(time1)
    else
        error("key error")
    end
    local beginKeyNo = keyNo + beginDiff
    local endKeyNo = keyNo + endDiff

    local pipeline = {
		{
            ["$match"] = { [key] = keyNo,
                platform = platform
            },
        },
        {
            ["$lookup"] = {
                from = "player_login_log",
                localField = "pid",
                foreignField = "pid",
                as = "logs",
            }
        },
        {
            ["$unwind"] = "$logs",
        },
        {
            ["$match"] = {
                ["logs."..key] = { ["$gte"] = beginKeyNo, ["$lte"] = endKeyNo },
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                ["login"..key] = { ["$addToSet"] = "$logs."..key },
            }
        },
        {
            ["$count"] = "num",
        },
        
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    
    return ret.cursor.firstBatch[1].num or 0
end

--""2""
--time1 ""
function Analyzer:getRegStayUserNum2(key, time1, beginDiff, endDiff, secondEndDiff,platform)
    beginDiff = beginDiff or 1
    endDiff = endDiff or 7
    secondEndDiff = secondEndDiff or 14

    local keyNo
    if key == "dayno" then
        keyNo = gg.time.dayno(time1)
    elseif key == "weekno" then
        keyNo = gg.time.weekno(time1)
    elseif key == "monthno" then
        keyNo = gg.time.monthno(time1)
    else
        error("key error")
    end
    local beginKeyNo = keyNo + beginDiff
    local endKeyNo = keyNo + endDiff
    local secondEndKeyNo = keyNo + secondEndDiff

    local pipeline = {
		{
            ["$match"] = { [key] = keyNo ,
            platform = platform
             },
        },
        {
            ["$lookup"] = {
                from = "player_login_log",
                localField = "pid",
                foreignField = "pid",
                as = "logs",
            }
        },
        {
            ["$unwind"] = "$logs",
        },
        {
            ["$group"] = {
                _id = "$pid",
                [key.."1"] = { ["$addToSet"] = "$logs."..key },
                [key.."2"] = { ["$addToSet"] = "$logs."..key },
            }
        },
        {
            ["$unwind"] = "$"..key.."1",
        },
        {
            ["$match"] = {
                [key.."1"] = { ["$gte"] = beginKeyNo, ["$lte"] = endKeyNo },
            }
        },
        {
            ["$unwind"] = "$"..key.."2",
        },
        {
            ["$match"] = {
                [key.."2"] = { ["$gt"] = endKeyNo, ["$lte"] = secondEndKeyNo },
            }
        },
        {
            ["$group"] = {
                _id = "$_id",
                num = { ["$sum"] = 1 },
            }
        },
        {
            ["$count"] = "num",
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    return ret.cursor.firstBatch[1].num or 0
end

function Analyzer:getRegDayStayUserNum(time1, beginDiff, endDiff,platform)
    return self:getRegStayUserNum1("dayno", time1, beginDiff, endDiff,platform)
end

--""
function Analyzer:getRegDayLostUserNum(time1, beginDiff, endDiff, secondEndDiff,platform)
    local firstStayNum = self:getRegStayUserNum1("dayno", time1, beginDiff, endDiff,platform)
    if firstStayNum == 0 then
        return 0
    end
    local secondStayNum = self:getRegStayUserNum2("dayno", time1, beginDiff, endDiff, secondEndDiff,platform)
    if secondStayNum >= firstStayNum then
        return 0
    end
    return firstStayNum - secondStayNum
end

-- ""pid
function Analyzer:getLoginPidByTime(time1, key,beginDiff, endDiff,platform)
    local keyNo
    if key == "dayno" then
        keyNo = gg.time.dayno(time1)
    elseif key == "weekno" then
        keyNo = gg.time.weekno(time1)
    elseif key == "monthno" then
        keyNo = gg.time.monthno(time1)
    else
        error("key error")
    end

    local startTime = keyNo + beginDiff
    local endTime = keyNo + endDiff
    local pipeline = {
        {
            ["$match"] = {
                [key] = {
                    ["$lte"] = endTime, 
                    ["$gte"] = startTime 
                },
                platform = platform
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                num = { ["$sum"] = 1 }, 
            }
        },{
            ["$project"] = {
                _id= 0,
                pid = "$_id"
            }
        }
    }

    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_login_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return {}
    end
    return ret.cursor.firstBatch
end
--""。

function Analyzer:getLoginByTimeAndPid(time1, key,beginDiff, endDiff,platform,pids)
    local pidArr = {}
    for _,v in pairs(pids) do
        table.insert(pidArr,v.pid)
    end
    local keyNo
    if key == "dayno" then
        keyNo = gg.time.dayno(time1)
    elseif key == "weekno" then
        keyNo = gg.time.weekno(time1)
    elseif key == "monthno" then
        keyNo = gg.time.monthno(time1)
    else
        error("key error")
    end

    local startTime = keyNo + beginDiff
    local endTime = keyNo + endDiff
    local pipeline = {
        {
            ["$match"] = {
                [key] = {
                    ["$lte"] = endTime, 
                    ["$gte"] = startTime 
                },
                platform = platform,
                pid = {
                    ["$in"] = pidArr
                }
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                num = { ["$sum"] = 1 }, 
            }
        },{
            ["$project"] = {
                _id= 0,
                pid = "$_id"
            }
        }
    }

    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_login_log", "pipeline", pipeline, "cursor", {})

    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return {}
    end
    return ret.cursor.firstBatch
end

--""
function Analyzer:getLoginDayLostUserNum(time1,platform)
    local pids = self:getLoginPidByTime(time1, "dayno",0, 0,platform)
  
    if not pids or not next(pids) then
        return 0
    end
 
    local secPids = self:getLoginByTimeAndPid(time1,"dayno",  1, 7,platform,pids)
    local firstStayNum = #pids
    local secondStayNum = #secPids
    if secondStayNum >= firstStayNum then
        return 0
    end
    return firstStayNum - secondStayNum
end

--""
function Analyzer:getLoginWeekLostUserNum(time1,platform)
    local pids = self:getLoginPidByTime(time1-6*gg.time.DAY_SECS, "dayno",0, 6,platform)
    if not pids or not next(pids) then
        return 0
    end
 
    local secPids = self:getLoginByTimeAndPid(time1,"dayno",  1, 7,platform,pids)
    local firstStayNum = #pids
    local secondStayNum = #secPids
    if secondStayNum >= firstStayNum then
        return 0
    end
    return firstStayNum - secondStayNum
end

--""
function Analyzer:getLoginMonthLostUserNum(time1,platform)
    local pids = self:getLoginPidByTime(time1-29*gg.time.DAY_SECS, "dayno",0, 29,platform)
    if not pids or not next(pids) then
        return 0
    end
 
    local secPids = self:getLoginByTimeAndPid(time1,"dayno",  1, 30,platform,pids)
    local firstStayNum = #pids
    local secondStayNum = #secPids
    if secondStayNum >= firstStayNum then
        return 0
    end
    return firstStayNum - secondStayNum
end

--""5""
function Analyzer:onFiveMinuteUpdate(updateTime)
    updateTime = updateTime or os.time()
    local yearMonthDay = tonumber(os.date("%Y%m%d", updateTime))
    local hourMin = tonumber(os.date("%H%M", updateTime))

    local allPlatform = constant.getAllPlatform()
    for _,platform in ipairs(allPlatform) do
        local onlineInfo = self:getServerTotalOnlineInfo(platform)
        gg.mongoProxy.server_status_statistic_log:update({ 
            createDate = yearMonthDay, 
            hourMin = hourMin,
            platform = platform
        }, {
            ["$set"] = { 
                onlineNum = onlineInfo.onlinenum, 
                linkNum = onlineInfo.linknum,
                maxOnlineNum = onlineInfo.max_onlinenum,
                minOnlineNum = onlineInfo.min_onlinenum,
                dayno = gg.time.dayno(updateTime),
                weekno = gg.time.weekno(updateTime),
                monthno = gg.time.monthno(updateTime), 
                month = gg.time.month(updateTime),
                createTime = bson.date(updateTime),
                platform = platform
            }
        }, true, false)
    end
end

function Analyzer:onTenMinuteUpdate()
    local updateTime = os.time()

    local pa = ggclass.cparallel.new()

    --""10""
    pa:add( self.savePlayerTotalResInfo, self, updateTime )
    pa:wait()

    --""10""
    pa:add( self.saveGameNftHeroTotalNum, self, updateTime )
    pa:wait()

    --""10""
    pa:add( self.saveGameNftWarshipTotalNum, self, updateTime )
    pa:wait()

    --""10""
    pa:add( self.saveGameNftGunTurretNum, self, updateTime )
    pa:wait()

    --""10""
    pa:add( self.saveGameNftArtifactTotalNum, self, updateTime )
    pa:wait()
end

function Analyzer:savePlayerTotalResInfo(updateTime)
    local yearMonthDay = tonumber(os.date("%Y%m%d", updateTime))
    local hourMin = tonumber(os.date("%H%M", updateTime))
    local resTotalInfo = self:getPlayerTotalResInfo()
    if not resTotalInfo then
        return
    end
    gg.mongoProxy.game_statistic_minute_log:update(
        { 
            createDate = yearMonthDay, 
            hourMin=hourMin,
        }, 
        {
            ["$set"] = { 
                dayno = gg.time.dayno(updateTime),
                weekno = gg.time.weekno(updateTime),
                monthno = gg.time.monthno(updateTime),
                month = gg.time.month(updateTime),
                mitTotal = resTotalInfo.mitTotal,
                starCoinTotal = resTotalInfo.starCoinTotal,
                iceTotal = resTotalInfo.iceTotal,
                carboxylTotal = resTotalInfo.carboxylTotal,
                titaniumTotal = resTotalInfo.titaniumTotal,
                gasTotal = resTotalInfo.gasTotal,
                tesseractTotal = resTotalInfo.tesseractTotal,
                createTime = bson.date(updateTime),
                timestamp = updateTime,
            }
        }, 
    true, false)
end

function  Analyzer:saveGameNftHeroTotalNum(updateTime)
    local yearMonthDay = tonumber(os.date("%Y%m%d", updateTime))
    local hourMin = tonumber(os.date("%H%M", updateTime))
    local heroTotal = self:getGameNftHeroTotalNum()
    if not heroTotal then
        return
    end
    gg.mongoProxy.game_statistic_minute_log:update({ 
            createDate = yearMonthDay, 
            hourMin=hourMin 
        }, {
            ["$set"] = { 
                heroTotal = heroTotal,
                dayno = gg.time.dayno(updateTime),
                weekno = gg.time.weekno(updateTime),
                monthno = gg.time.monthno(updateTime),
                month = gg.time.month(updateTime),
                createTime = bson.date(updateTime),
                timestamp = updateTime,
            }
        }, 
    true, false)
end

function Analyzer:saveGameNftWarshipTotalNum(updateTime)
    local yearMonthDay = tonumber(os.date("%Y%m%d", updateTime))
    local hourMin = tonumber(os.date("%H%M", updateTime))
    local warShipTotal = self:getGameNftWarshipTotalNum()
    if not warShipTotal then
        return
    end
    gg.mongoProxy.game_statistic_minute_log:update({ 
        createDate = yearMonthDay, 
        hourMin=hourMin 
    }, {
        ["$set"] = { 
            warShipTotal = warShipTotal,
            dayno = gg.time.dayno(updateTime),
            weekno = gg.time.weekno(updateTime),
            monthno = gg.time.monthno(updateTime),
            month = gg.time.month(updateTime),
            createTime = bson.date(updateTime),
            timestamp = updateTime,
        }
    }, true, false)
end

function Analyzer:saveGameNftGunTurretNum(updateTime)
    local yearMonthDay = tonumber(os.date("%Y%m%d", updateTime))
    local hourMin = tonumber(os.date("%H%M", updateTime))
    local gunTurretTotal = self:getGameNftGunTurretNum()
    if not gunTurretTotal then
        return
    end
    gg.mongoProxy.game_statistic_minute_log:update({ 
        createDate = yearMonthDay, 
        hourMin=hourMin 
    }, {
        ["$set"] = {
            gunTurretTotal = gunTurretTotal,
            dayno = gg.time.dayno(updateTime),
            weekno = gg.time.weekno(updateTime),
            monthno = gg.time.monthno(updateTime),
            month = gg.time.month(updateTime),
            createTime = bson.date(updateTime),
            timestamp = updateTime,
        }
    }, true, false)
end

function Analyzer:saveGameNftArtifactTotalNum(updateTime)
    local yearMonthDay = tonumber(os.date("%Y%m%d", updateTime))
    local hourMin = tonumber(os.date("%H%M", updateTime))
    local artifactTotal = self:getGameNftArtifactTotalNum()
    if not artifactTotal then
        return
    end
    gg.mongoProxy.game_statistic_minute_log:update({ 
        createDate = yearMonthDay, 
        hourMin=hourMin 
    }, {
        ["$set"] = {
            artifactTotal = artifactTotal,
            dayno = gg.time.dayno(updateTime),
            weekno = gg.time.weekno(updateTime),
            monthno = gg.time.monthno(updateTime),
            month = gg.time.month(updateTime),
            createTime = bson.date(updateTime),
            timestamp = updateTime,
        }
    }, true, false)
end

--""
function Analyzer:saveUserFirstGameTimeAvg(timestamp, platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local firstGameTime = self:getUserFirstGameTimeAvg(timestamp,platform)
    if not firstGameTime then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            firstGameTime = firstGameTime,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform= platform,
        }
    }, true, false)
    logger.logf("info","analyzer", string.format("op=firstGameTime, yearMonthDay=%d, value=%s ,platform = %s", yearMonthDay, tostring(firstGameTime),platform))
end

--""
function Analyzer:saveTotalGameTime(timestamp,platform)
    local totalGameTime = self:getTotalGameTime(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    if not totalGameTime then
        return
    end
    gg.mongoProxy.game_statistic_log:update({
        createDate = yearMonthDay,
        platform = platform,
    }, {
        ["$set"] = {
            totalGameTime = totalGameTime,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp),
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=totalGameTime, yearMonthDay=%d, value=%s ,platform = %s", yearMonthDay, tostring(totalGameTime),platform))
end

--""
function Analyzer:saveSameTimeOnlineNumInfo(timestamp,platform)
    local sameTimeOnlineNum, maxSameTimeOnlineNum = self:getSameTimeOnlineNumInfo(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    if not sameTimeOnlineNum and not maxSameTimeOnlineNum then
        return
    end

    gg.mongoProxy.game_statistic_log:update({
        createDate = yearMonthDay,
        platform = platform,
    }, {
        ["$set"] = {
            sameTimeOnlineNum = sameTimeOnlineNum,
            maxSameTimeOnlineNum = maxSameTimeOnlineNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp),
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=sameTimeOnlineNum, yearMonthDay=%d, sameTimeOnlineNum=%s maxSameTimeOnlineNum=%s platform=%s", 
        yearMonthDay, 
        tostring(sameTimeOnlineNum),
        tostring(maxSameTimeOnlineNum)
        ,platform
    ))
end

--""MIT""
function Analyzer:saveTotalUseMit(timestamp,platform)
    local totalUseMit = self:getTotalUseMit(timestamp,platform)
    if not totalUseMit then
        return
    end
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    gg.mongoProxy.game_statistic_log:update({
        createDate = yearMonthDay,
        platform = platform,
    }, {
        ["$set"] = {
            totalUseMit = totalUseMit,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp),
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=totalUseMit, yearMonthDay=%d, value=%s, platform = %s ", yearMonthDay, tostring(totalUseMit),platform))
end

--""MIT""
function Analyzer:saveTotalUseCarboxyl(timestamp,platform)
    local totalUseCarboxyl = self:getTotalUseCarboxyl(timestamp,platform)
    if not totalUseCarboxyl then
        return
    end
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    gg.mongoProxy.game_statistic_log:update({
        createDate = yearMonthDay,
        platform = platform,
    }, {
        ["$set"] = {
            totalUseCarboxyl = totalUseCarboxyl,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp),
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=saveTotalUseCarboxyl, yearMonthDay=%d, value=%s platform=%s", yearMonthDay, tostring(totalUseCarboxyl),platform))
end

--""
function Analyzer:saveDayAddUserNum(timestamp, platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local regUserNum = self:getDayAddUserNum(timestamp, platform)
    if not regUserNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform,
    }, {
        ["$set"] = { 
            regUserNum = regUserNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=regUserNum, yearMonthDay=%d, value=%s,platform=%s", yearMonthDay, tostring(regUserNum),platform))
end

--""
function Analyzer:saveValidNewAddNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local validNewAddNum = self:getNewAddValidUserNum(timestamp, 2, 0, 6,platform) --login2DayAfterReg
    if not validNewAddNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform,
    }, {
        ["$set"] = { 
            validNewAddNum = validNewAddNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=validNewAddNum, yearMonthDay=%d, value=%s ,platform=%s", yearMonthDay, tostring(validNewAddNum),platform))
end

--""
function Analyzer:saveLoginStayNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local loginStayNum = self:getNewAddValidUserNum(timestamp, 3, 0, 6,platform)
    if not loginStayNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform,
    }, {
        ["$set"] = { 
            loginStayNum = loginStayNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=loginStayNum, yearMonthDay=%d, value=%d , platform = %s", yearMonthDay, tonumber(loginStayNum),platform))
end

--""
function Analyzer:saveLoginStayNumV2(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local loginStayNumV2 = self:getNewAddValidUserNum(timestamp, 1, 7, 13,platform)
    if not loginStayNumV2 then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform,
    }, {
        ["$set"] = { 
            loginStayNumV2 = loginStayNumV2,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=loginStayNumV2, yearMonthDay=%d, value=%s ,platform =%s", yearMonthDay, tostring(loginStayNumV2),platform))
end

--""
function Analyzer:saveDayActiveNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local dayActiveNum = self:getDayActiveUserNum(timestamp,platform)
    if not dayActiveNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform,
    }, {
        ["$set"] = { 
            dayActiveNum = dayActiveNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=dayActiveNum, yearMonthDay=%d, value=%s,platform=%s", yearMonthDay, tostring(dayActiveNum),platform))
end

--""
function Analyzer:saveWeekActiveNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local weekActiveNum = self:getWeekActiveUserNum(timestamp,platform)
    if not weekActiveNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform,
    }, {
        ["$set"] = { 
            weekActiveNum = weekActiveNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=weekActiveNum, yearMonthDay=%d, value=%s,platform = %s", yearMonthDay, tostring(weekActiveNum),platform))
end

--""
function Analyzer:saveMonthActiveNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local monthActiveNum = self:getMonthActiveUserNum(timestamp,platform)
    if not monthActiveNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            monthActiveNum = monthActiveNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=monthActiveNum, yearMonthDay=%d, value=%s,platform = %s", yearMonthDay, tostring(monthActiveNum),platform))
end

--""
function Analyzer:saveStayUserNumInReg2d(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local stayUserNumInReg2d = self:getRegDayStayUserNum(timestamp, 1, 1,platform)
    if not stayUserNumInReg2d then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            stayUserNumInReg2d = stayUserNumInReg2d,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=stayUserNumInReg2d, yearMonthDay=%d, value=%s,platform = %s", yearMonthDay, tostring(stayUserNumInReg2d),platform))
end

--""3""
function Analyzer:saveStayUserNumInReg3d(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local stayUserNumInReg3d = self:getRegDayStayUserNum(timestamp, 2, 2,platform)
    if not stayUserNumInReg3d then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay,
        platform = platform
    }, {
        ["$set"] = { 
            stayUserNumInReg3d = stayUserNumInReg3d,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=stayUserNumInReg3d, yearMonthDay=%d, value=%s,platform=%s", yearMonthDay, tostring(stayUserNumInReg3d),platform))
end

--""7""
function Analyzer:saveStayUserNumInReg7d(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local stayUserNumInReg7d = self:getRegDayStayUserNum(timestamp, 6, 6,platform)
    if not stayUserNumInReg7d then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            stayUserNumInReg7d = stayUserNumInReg7d,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=stayUserNumInReg7d, yearMonthDay=%d, value=%s ,platform=%s", yearMonthDay, tostring(stayUserNumInReg7d),platform))
end

--""14""
function Analyzer:saveStayUserNumInReg14d(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local stayUserNumInReg14d = self:getRegDayStayUserNum(timestamp, 13, 13,platform)
    if not stayUserNumInReg14d then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            stayUserNumInReg14d = stayUserNumInReg14d,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=stayUserNumInReg14d, yearMonthDay=%d, value=%s ,platform =%s", yearMonthDay, tostring(stayUserNumInReg14d),platform))
end

--""30""
function Analyzer:saveStayUserNumInReg30d(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local stayUserNumInReg30d = self:getRegDayStayUserNum(timestamp, 29, 29,platform)
    if not stayUserNumInReg30d then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            stayUserNumInReg30d = stayUserNumInReg30d,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=stayUserNumInReg30d, yearMonthDay=%d, value=%s ,platform = %s", yearMonthDay, tostring(stayUserNumInReg30d),platform))
end

--""
function Analyzer:saveRegDayLostUserNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local regDayLostUserNum = self:getRegDayLostUserNum(timestamp, 0, 0, 7,platform)
    if not regDayLostUserNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            regDayLostUserNum = regDayLostUserNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=regDayLostUserNum, yearMonthDay=%d, value=%s ,platform = %s", yearMonthDay, tostring(regDayLostUserNum),platform))
end

--""
function Analyzer:saveRegWeekLostUserNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local regWeekLostUserNum = self:getRegDayLostUserNum(timestamp, 1, 7, 14,platform)
    if not regWeekLostUserNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            regWeekLostUserNum = regWeekLostUserNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=regWeekLostUserNum, yearMonthDay=%d, value=%s ,platform = %s", yearMonthDay, tostring(regWeekLostUserNum),platform ))
end

--""
function Analyzer:saveRegMonthLostUserNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local regMonthLostUserNum = self:getRegDayLostUserNum(timestamp, 1, 30, 60,platform)
    if not regMonthLostUserNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            regMonthLostUserNum = regMonthLostUserNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=regMonthLostUserNum, yearMonthDay=%d, value=%s ,platform = %s", yearMonthDay, tostring(regMonthLostUserNum),platform))
end

--""
function Analyzer:saveDayActiveLostUserNum(timestamp,platform)

    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local dayActiveLostUserNum = self:getLoginDayLostUserNum(timestamp,platform)
    if not dayActiveLostUserNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            dayActiveLostUserNum = dayActiveLostUserNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=dayActiveLostUserNum, yearMonthDay=%d, value=%s ,platform = %s", yearMonthDay, tostring(dayActiveLostUserNum),platform))
end

--""
function Analyzer:saveWeekActiveLostUserNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local weekActiveLostUserNum = self:getLoginWeekLostUserNum(timestamp,platform)
    if not weekActiveLostUserNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            weekActiveLostUserNum = weekActiveLostUserNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp),
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=weekActiveLostUserNum, yearMonthDay=%d, value=%s,platform = %s", yearMonthDay, tostring(weekActiveLostUserNum),platform))
end

--""
function Analyzer:saveMonthActiveLostUserNum(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local monthActiveLostUserNum = self:getLoginMonthLostUserNum(timestamp,platform)
    if not monthActiveLostUserNum then
        return
    end
    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform
    }, {
        ["$set"] = { 
            monthActiveLostUserNum = monthActiveLostUserNum,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp),
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=monthActiveLostUserNum, yearMonthDay=%d, value=%s,platform = %s", yearMonthDay, tostring(monthActiveLostUserNum),platform))
end

--"",""
function Analyzer:saveDayBasePaymentData(timestamp, platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    local dayno = gg.time.dayno(timestamp)

    --""
    local orderSettleUser = analyzermgr.getOrderSettlePids(dayno, platform)
    local dayOrderSettleUser = table.count(orderSettleUser)

    --""
    local hydroxylExchangeUser = analyzermgr.getHydroxylExchangePids(dayno, platform)
    local dayHydroxylExchangeUser = table.count(hydroxylExchangeUser)

    --""
    local paymentUser = {}
    for pid, cnt in pairs(orderSettleUser) do
        paymentUser[pid] = 1
    end
    for pid, cnt in pairs(hydroxylExchangeUser) do
        paymentUser[pid] = 1
    end
    local dayPaymentUser = table.count(paymentUser)

    --""
    local firstPaymentUser = analyzermgr.getTotalFirstPaymentUser(dayno, platform)

    --""
    local registerPaymentUser = analyzermgr.getTotalRegisterPaymentUser(dayno, platform)

    --""
    local orderTesseract = analyzermgr.getTotalOrderTesseract(dayno, platform, nil)

    --""
    local exchangeTesseract = analyzermgr.getTotalExchangeTesseract(dayno, platform, nil)

    --""
    local chainRechargeHYT = analyzermgr.getTotalChainRechargeToken(dayno, "HYT", platform, nil)

    --""
    local chainWithdrawHYT = analyzermgr.getTotalChainWithdrawToken(dayno, "HYT", platform, nil)

    --""MIT""
    local chainRechargeMIT = analyzermgr.getTotalChainRechargeToken(dayno, "MIT", platform, nil)

    --""MIT""
    local chainWithdrawMIT = analyzermgr.getTotalChainWithdrawToken(dayno, "MIT", platform, nil)

    --""
    local orderReadyCnt = analyzermgr.getTotalOrderReadyCnt(dayno, platform)

    --""
    local orderSettleCnt = analyzermgr.getTotalOrderSettleCnt(dayno, platform)

    --""
    local orderReadyPrice = analyzermgr.getTotalOrderReadyPrice(dayno, platform)

    --""
    local orderSettlePrice = analyzermgr.getTotalOrderSettlePrice(dayno, platform)

    --""
    local orderFirstPrice = analyzermgr.getTotalOrderFirstPrice(dayno, platform)

    --""
    local orderRegisterPrice = analyzermgr.getTotalOrderRegisterPrice(dayno, platform)

    --""
    local exchangeCnt = analyzermgr.getTotalExchangeCnt(dayno, platform)

    --""
    local exchangeHydroxyl = analyzermgr.getTotalExchangeHydroxyl(dayno, platform, nil)

    gg.mongoProxy.game_statistic_log:update({ 
        createDate = yearMonthDay ,
        platform = platform,
    }, {
        ["$set"] = { 
            dayOrderSettleUser = dayOrderSettleUser,
            dayHydroxylExchangeUser = dayHydroxylExchangeUser,
            dayPaymentUser = dayPaymentUser,
            firstPaymentUser = firstPaymentUser,
            registerPaymentUser = registerPaymentUser,
            orderTesseract = orderTesseract,
            exchangeTesseract = exchangeTesseract,
            chainRechargeHYT = chainRechargeHYT,
            chainWithdrawHYT = chainWithdrawHYT,
            chainRechargeMIT = chainRechargeMIT,
            chainWithdrawMIT = chainWithdrawMIT,
            orderReadyCnt = orderReadyCnt,
            orderSettleCnt = orderSettleCnt,
            orderReadyPrice = orderReadyPrice,
            orderSettlePrice = orderSettlePrice,
            orderFirstPrice = orderFirstPrice,
            orderRegisterPrice = orderRegisterPrice,
            exchangeCnt = exchangeCnt,
            exchangeHydroxyl = exchangeHydroxyl,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp), 
            month = gg.time.month(timestamp),
            year = gg.time.year(timestamp),
            platform = platform,
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=saveDayBasePaymentData, yearMonthDay=%d, platform=%s", yearMonthDay, platform))
end

function Analyzer:saveAnalyzerDayCheck(timestamp,platform)
    local yearMonthDay = tonumber(os.date("%Y%m%d", timestamp))
    gg.mongoProxy.analyzer_day_check:update({ 
        createDate = yearMonthDay,
        platform = platform
    }, {
        ["$set"] = {
            updateTime = timestamp,
            dayno = gg.time.dayno(timestamp),
            weekno = gg.time.weekno(timestamp),
            monthno = gg.time.monthno(timestamp),
            month = gg.time.month(timestamp),
            createTime = bson.date(timestamp),
            platform = platform
        }
    }, true, false)
    logger.logf("info","analyzer",string.format("op=analyzer_day_check, yearMonthDay=%s,platform = %s", yearMonthDay,platform))
end

--""("")
function Analyzer:onDayUpdate(updateTime, firstTimestamp, lastTimestamp, platform)

    local function _onDayUpdate ()
        updateTime = updateTime or os.time()
        firstTimestamp = firstTimestamp or self:getFirstAccountRegTimestamp()
        lastTimestamp = lastTimestamp or self:getLastAccountRegTimestamp()
        local updateDayno = gg.time.dayno(updateTime)
        local firstDayno = gg.time.dayno(firstTimestamp)
        local lastDayno = gg.time.dayno(lastTimestamp)
        local nowDayno = gg.time.dayno(os.time())

        logger.logf("info", "DayUpdate", string.format("op=_onDayUpdate, updateTime=%s, datetime=%s, platform=%s", updateTime, gg.time.MsToString(updateTime), platform))
    
        local pa = ggclass.cparallel.new()
    
        --""("")
        local saveTimestamp = updateTime - 86400
        local saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveUserFirstGameTimeAvg, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""("")
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveTotalGameTime, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveSameTimeOnlineNumInfo, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""MIT""
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveTotalUseMit, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""HYT""
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveTotalUseCarboxyl, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveDayAddUserNum, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""(7"")
        saveTimestamp = updateTime - 86400 * 7
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveValidNewAddNum, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""
        saveTimestamp = updateTime - 86400 * 7
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveLoginStayNum, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""
        saveTimestamp = updateTime - 86400 * 14
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveLoginStayNumV2, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --"" ("")
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveDayActiveNum, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --"" （""）
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveWeekActiveNum, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --"" （""）
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveMonthActiveNum, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""
        saveTimestamp = updateTime - 86400 * 2
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveStayUserNumInReg2d, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --3""
        saveTimestamp = updateTime - 86400 * 3
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveStayUserNumInReg3d, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --7""
        saveTimestamp = updateTime - 86400 * 7
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveStayUserNumInReg7d, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --14""
        saveTimestamp = updateTime - 86400 * 14
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveStayUserNumInReg14d, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --30""
        saveTimestamp = updateTime - 86400 * 30
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveStayUserNumInReg30d, self, saveTimestamp, platform)
            pa:wait()
        end
        
        --""
        saveTimestamp = updateTime - 86400 * 8
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveRegDayLostUserNum, self, saveTimestamp, platform)
            pa:wait()
        end
        
        --""
        saveTimestamp = updateTime - 86400 * 15
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveRegWeekLostUserNum, self, saveTimestamp, platform)
            pa:wait()
        end
        
        --""
        saveTimestamp = updateTime - 86400 * 31
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveRegMonthLostUserNum, self, saveTimestamp, platform)
            pa:wait()
        end
        
        --""
        saveTimestamp = updateTime - 86400 * 8
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveDayActiveLostUserNum, self, saveTimestamp, platform)
            pa:wait()
        end
        
        --""
        saveTimestamp = updateTime - 86400 * 7
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveWeekActiveLostUserNum, self, saveTimestamp, platform)
            pa:wait()
        end
    
        --""
        saveTimestamp = updateTime - 86400 * 30
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveMonthActiveLostUserNum, self, saveTimestamp, platform)
            pa:wait()
        end

        --""
        saveTimestamp = updateTime - 86400
        saveDayno = gg.time.dayno(saveTimestamp)
        if saveDayno >= firstDayno and saveDayno < nowDayno then
            pa:add( self.saveDayBasePaymentData, self, saveTimestamp, platform)
            pa:wait()
        end
    
        pa:add( self.saveAnalyzerDayCheck, self, updateTime, platform)
        pa:wait()
    end

    --""
    if not updateTime and not firstTimestamp and not lastTimestamp and not platform then  
        local allPlatform = constant.getAllPlatform()
        for _, newPlatform in ipairs(allPlatform) do
            platform = newPlatform
            local ok,err = xpcall(_onDayUpdate,debug.traceback)
        end
    else -- ""
        _onDayUpdate()
    end 
end

function Analyzer:saveStatisticByDay(updateTime, firstTimestamp, lastTimestamp)
    local yearMonthDay = tonumber(os.date("%Y%m%d", updateTime))
    logger.logf("info", "DayUpdate", string.format("op=saveStatisticByDayCheck, updateTime=%s, datetime=%s,", updateTime, gg.time.MsToString(updateTime)))
    for i = constant.PLATFORM_MIN,constant.PLATFORM_MAX,1 do
        local platform = constant["PLATFORM_"..i]
        local info = gg.mongoProxy.analyzer_day_check:findOne({createDate = yearMonthDay,platform = platform})
        if not info then
            self:onDayUpdate(updateTime, firstTimestamp, lastTimestamp, platform)
        end
    end
end

function Analyzer:onStart()
    local firstTimestamp = self:getFirstAccountRegTimestamp()
    local lastTimestamp = self:getLastAccountRegTimestamp()
    if not firstTimestamp or firstTimestamp == 0 then
        print("analyzer start ok 1")
        return
    end
    if os.time() < firstTimestamp + 86400 then
        print("analyzer start ok 2")
        return
    end
    local pa = ggclass.cparallel.new()
    local timestamp = firstTimestamp
    while true do
        pa:add(function(...)
            self:saveStatisticByDay(...)
        end, timestamp, firstTimestamp, lastTimestamp)
        timestamp = timestamp + 86400
        if timestamp > os.time() then
            break
        end
    end
    pa:wait()
    print("analyzer start ok 3")
end

function Analyzer:onSecond()

end

function Analyzer:onHalfHourUpdate()

end

function Analyzer:onMinuteUpdate(updateTime)
    
end

return Analyzer