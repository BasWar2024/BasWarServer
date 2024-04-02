local bson = require "bson"

analyzermgr = analyzermgr or {}

function analyzermgr.getYestdayUseMit()
    local time = os.time() - 86400
    return analyzermgr.getTotalDecResByDay("MIT", time)
end

function analyzermgr.getYestdayUseCarboxyl()
    local time = os.time() - 86400
    return analyzermgr.getTotalDecResByDay("HYT", time)
end

--"",""
function analyzermgr.getTotalIncResByDay(res, time)
    local tempTime = time or os.time()
    local dayno = gg.time.dayno(tempTime)
    local value = gg.mongoProxy:call("getGameTotalResByCondition",  res, dayno, 1, nil, nil, nil)
    return value
end

--"",""
function analyzermgr.getTotalDecResByDay(res, time)
    local tempTime = time or os.time()
    local dayno = gg.time.dayno(tempTime)
    local value = gg.mongoProxy:call("getGameTotalResByCondition", res, dayno, -1, nil, nil, nil)
    return value
end

-- ""reason""
function analyzermgr.getGameResByReason(res, change ,pid)
    local whiteList = {}
    if pid == 0 then
        whiteList = analyzermgr:getWhiteLevelTwoList()
    end
    local value = gg.mongoProxy:call("getGameResByReason", res, change, pid, whiteList)
    if value == 0 then
        return
    end
    return value
end

--""
function analyzermgr.getOrderStatistics()
    local pipeline = {
        {
            ["$group"] = {
                _id = "$productId",
                num = {
                    ["$sum"] = 1,
                }
            }
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "order_settle", "pipeline", pipeline, "cursor", {})

    if not ret or not ret.cursor or not ret.cursor.firstBatch then
        return
    end
    local data = {
        productInfo = {},
        totalNum = 0
    }
    local countRet = gg.mongoProxy.order_settle:findCount()
    if not countRet or countRet == 0 then
        return {}
    end
    data.totalNum = countRet
    local result = ret.cursor.firstBatch
    for k,v in pairs(result) do
        local ratio = v.num / data.totalNum
        ratio = ratio - ratio % 0.0000000001
        local temp = {}
        --temp[v._id] =  {v.num , ratio }
        temp.productId = v._id
        temp.num = v.num
        temp.ratio = ratio
        table.insert(data.productInfo, temp)
    end
   
    -- local data = {}
    -- for k,v in pairs(result.productInfo) do
    --     local ratio = v.num / result.totalNum
    --     ratio = ratio - ratio % 0.0000000001
    --     data[v._id] =  {v.num , ratio }
    -- end
    return data
end

function analyzermgr.getAllNfts()
    --""nft
    local ret = gg.mongoProxy.online_players:find()

    if not ret then
        return
    end
    --""id,0""。""ID"" "" ""，""，""，""，""。"",""。
    local data = {}
    local count = {}
    for k, v in pairs(ret) do
        for kk,nft in pairs(v) do
            if v.chainId > 0 then
                if kk == "nftBuilds" or kk == "nftHeros" or kk == "nftWarShips" then
                    for kkk,vvv in pairs(nft) do
                        if vvv.chain > 0 then
                            --table.insert(data[tostring(v.chainId)], {type="build", level=vvv.level, quality=vvv.quality, chain=vvv.chain})
                            data[tostring(v.chainId)] = data[tostring(v.chainId)] or  {}
                            data[tostring(v.chainId)][kk] = data[tostring(v.chainId)][kk] or  {}

                            -- ""
                            data[tostring(v.chainId)][kk].total = data[tostring(v.chainId)][kk].total or 0
                            data[tostring(v.chainId)][kk].total = data[tostring(v.chainId)][kk].total + 1
                            -- ""
                            data[tostring(v.chainId)][kk].level = data[tostring(v.chainId)][kk].level or {}
                            data[tostring(v.chainId)][kk].level.count = data[tostring(v.chainId)][kk].level.count or {}
                            data[tostring(v.chainId)][kk].level.ratio = data[tostring(v.chainId)][kk].level.ratio or {}
                            data[tostring(v.chainId)][kk].level.count[tostring(vvv.level)] = data[tostring(v.chainId)][kk].level.count[tostring(vvv.level)] or 0
                            data[tostring(v.chainId)][kk].level.ratio[tostring(vvv.level)] = data[tostring(v.chainId)][kk].level.ratio[tostring(vvv.level)] or 0
                            data[tostring(v.chainId)][kk].level.count[tostring(vvv.level)] = data[tostring(v.chainId)][kk].level.count[tostring(vvv.level)] + 1

                            -- ""
                            data[tostring(v.chainId)][kk].quality = data[tostring(v.chainId)][kk].quality or {}
                            data[tostring(v.chainId)][kk].quality.count = data[tostring(v.chainId)][kk].quality.count or {}
                            data[tostring(v.chainId)][kk].quality.ratio = data[tostring(v.chainId)][kk].quality.ratio or {}
                            data[tostring(v.chainId)][kk].quality.count[tostring(vvv.quality)] = data[tostring(v.chainId)][kk].quality.count[tostring(vvv.quality)] or 0
                            data[tostring(v.chainId)][kk].quality.ratio[tostring(vvv.quality)] = data[tostring(v.chainId)][kk].quality.ratio[tostring(vvv.quality)] or 0
                            data[tostring(v.chainId)][kk].quality.count[tostring(vvv.quality)] = data[tostring(v.chainId)][kk].quality.count[tostring(vvv.quality)] + 1
                        end
                    end
                end
            end
        end
    end
    return data
end
--""
function analyzermgr.getTotalOrderPrice(dayno, platform, pid)
    local pipeline = {
        {
            ["$match"] = {
                settledayno = dayno,
                state = constant.PAY_STATE_2,
                platform = platform,
                pid = pid,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalPrice = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$price", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "order_settle", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalPrice = ret.cursor.firstBatch[1].totalPrice or 0
    totalPrice = math.abs(totalPrice)
    return totalPrice
end

--""
function analyzermgr.getTotalOrderTesseract(dayno, platform, pid)
    local pipeline = {
        {
            ["$match"] = {
                settledayno = dayno,
                state = constant.PAY_STATE_2,
                platform = platform,
                pid = pid,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalValue = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$value", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "order_settle", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalValue = ret.cursor.firstBatch[1].totalValue or 0
    totalValue = math.abs(totalValue)
    return totalValue
end

--""
function analyzermgr.getTotalChainRechargeToken(dayno, token, platform, pid)
    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                token = token,
                state = constant.CHAIN_BRIDGE_RECHARGE_STATE_SUCCESS,
                platform = platform,
                pid = pid,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalValue = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$value", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.commondb:runCommand("aggregate", "rechargeToken", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalValue = ret.cursor.firstBatch[1].totalValue or 0
    totalValue = math.abs(totalValue)
    return totalValue
end

--""
function analyzermgr.getTotalChainWithdrawToken(dayno, token, platform, pid)
    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                token = token,
                state = { ["$gte"] = constant.CHAIN_BRIDGE_WITHDRAW_STATE_APPROVAL },
                platform = platform,
                pid = pid,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalValue = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$amount", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.commondb:runCommand("aggregate", "withdrawToken", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalValue = ret.cursor.firstBatch[1].totalValue or 0
    totalValue = math.abs(totalValue)
    return totalValue
end

--""
function analyzermgr.getTotalExchangeCnt(dayno, platform)
    local cnt = gg.mongoProxy.carboxyl_log:findCount({dayno=dayno, platform=platform, changeValue={["$lt"] = 0}, reason=gamelog[gamelog.EXCHANGE_RES]})
    return cnt
end

--""
function analyzermgr.getTotalExchangeHydroxyl(dayno, platform, pid)
    local value = gg.mongoProxy:call("getGameTotalResByCondition", "HYT", dayno, -1, gamelog[gamelog.EXCHANGE_RES], platform, pid)
    return value
end

--""
function analyzermgr.getTotalExchangeTesseract(dayno, platform, pid)
    local value = gg.mongoProxy:call("getGameTotalResByCondition", "TESSERACT", dayno, 1, gamelog[gamelog.EXCHANGE_RES], platform, pid)
    return value
end

--""
function analyzermgr.getTotalOrderReadyCnt(dayno, platform)
    local cnt = gg.mongoProxy.order_ready:findCount({dayno=dayno, platform=platform})
    return cnt
end

--""
function analyzermgr.getTotalOrderSettleCnt(dayno, platform)
    local cnt = gg.mongoProxy.order_ready:findCount({settledayno=dayno, platform=platform, state=constant.PAY_STATE_2})
    return cnt
end

--""
function analyzermgr.getTotalOrderReadyPrice(dayno, platform)
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
                totalPrice = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$price", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "order_ready", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalPrice = ret.cursor.firstBatch[1].totalPrice or 0
    totalPrice = math.abs(totalPrice)
    return totalPrice
end

--""
function analyzermgr.getTotalOrderSettlePrice(dayno, platform)
    local pipeline = {
        {
            ["$match"] = {
                settledayno = dayno,
                platform = platform,
                state = constant.PAY_STATE_2,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalPrice = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$price", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "order_ready", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalPrice = ret.cursor.firstBatch[1].totalPrice or 0
    totalPrice = math.abs(totalPrice)
    return totalPrice
end

--""
function analyzermgr.getOrderSettlePids(dayno, platform)
    local pipeline = {
		{
            ["$match"] = { 
                settledayno = dayno,
                platform = platform,
                state = constant.PAY_STATE_2,
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                settleCount = { ["$sum"] = 1 },
            }
        }
    }

    local data = {}
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "order_ready", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return data
    end
    for k,v in pairs(ret.cursor.firstBatch) do
        data[v._id] = v.settleCount
    end
    return data
end

--""
function analyzermgr.getHydroxylExchangePids(dayno, platform)
    local pipeline = {
		{
            ["$match"] = { 
                dayno = dayno,
                platform = platform,
                reason = gamelog[gamelog.EXCHANGE_RES],
                changeValue = { ["$lt"] = 0 },
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                exchangeCount = { ["$sum"] = 1 },
            }
        }
    }

    local data = {}
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "carboxyl_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return data
    end
    for k,v in pairs(ret.cursor.firstBatch) do
        data[v._id] = v.exchangeCount
    end
    return data
end

--"", ""player_create_log""
function analyzermgr.getTotalFirstPaymentUser(dayno, platform)
    local pipeline = {
		{
            ["$match"] = {
                firstPaymentDayno = dayno,
                platform = platform,
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                PaymentCount = { ["$sum"] = 1 },
            }
        },
        {
            ["$group"] = {
                _id = "0",
                userNum = { ["$sum"] = 1 },
            }
        }
    }

    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local userNum = ret.cursor.firstBatch[1].userNum or 0
    userNum = math.abs(userNum)
    return userNum
end

--"", ""player_create_log""
function analyzermgr.getTotalRegisterPaymentUser(dayno, platform)
    local pipeline = {
		{
            ["$match"] = {
                dayno = dayno,
                firstPaymentDayno = dayno,
                platform = platform,
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                PaymentCount = { ["$sum"] = 1 },
            }
        },
        {
            ["$group"] = {
                _id = "0",
                userNum = { ["$sum"] = 1 },
            }
        }
    }

    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local userNum = ret.cursor.firstBatch[1].userNum or 0
    userNum = math.abs(userNum)
    return userNum
end

--""
function analyzermgr.getTotalOrderFirstPrice(dayno, platform)
    local pipeline = {
		{
            ["$match"] = {
                firstOrderDayno = dayno,
                platform = platform,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalFirstOrderPrice = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$firstOrderPrice", 0 }
                    },
                }
            }
        }
    }

    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalFirstOrderPrice = ret.cursor.firstBatch[1].totalFirstOrderPrice or 0
    totalFirstOrderPrice = math.abs(totalFirstOrderPrice)
    return totalFirstOrderPrice
end

--""
function analyzermgr.getTotalOrderRegisterPrice(dayno, platform)
    local pipeline = {
		{
            ["$match"] = {
                dayno = dayno,
                firstOrderDayno = dayno,
                platform = platform,
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                PaymentCount = { ["$sum"] = 1 },
            }
        }
    }

    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_create_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end

    --""
    local pids = {}
    for k,v in pairs(ret.cursor.firstBatch) do
        table.insert(pids, v._id)
    end

    local pipeline = {
        {
            ["$match"] = {
                settledayno = dayno,
                platform = platform,
                state = constant.PAY_STATE_2,
                pid = { ["$in"] = pids } ,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalPrice = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$price", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "order_ready", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not ret.cursor.firstBatch[1] then
        return 0
    end
    local totalPrice = ret.cursor.firstBatch[1].totalPrice or 0
    totalPrice = math.abs(totalPrice)
    return totalPrice
end

function analyzermgr.getTotalPlayerCount()
    local cnt = gg.mongoProxy.online_players:findCount({})
    return cnt
end

function analyzermgr.getYestdayActivePlayerCount()
    local dayno = gg.time.dayno(os.time())
    local docs = gg.mongoProxy.game_statistic_log:find({dayno=dayno-1})
    local count = 0
    for k,v in pairs(docs) do
        count = count + v.dayActiveNum
    end
    return count
end

function analyzermgr.getCurrentOnlineCount()
    return gg.mongoProxy.online_players:findCount({onlineStatus = 1})
end

function analyzermgr.getGameTotalRes()
    local result = {}
    local docs = gg.mongoProxy.game_statistic_minute_log:findSortLimit({}, {createDate=-1, hourMin=-1}, 5)
    local info = docs[1] or {}
    result.mitTotal = (info.mitTotal or 0) / 1000
    result.iceTotal = (info.iceTotal or 0) / 1000
    result.starCoinTotal = (info.starCoinTotal or 0) / 1000
    result.carboxylTotal = (info.carboxylTotal or 0) / 1000
    result.titaniumTotal = (info.titaniumTotal or 0) / 1000
    result.gasTotal = (info.gasTotal or 0) / 1000
    result.heroTotal = (info.heroTotal or 0) + (info.heroItemTotal or 0)
    result.warShipTotal = (info.warShipTotal or 0) + (info.warShipItemTotal or 0)
    result.gunTurretTotal = (info.gunTurretTotal or 0) + (info.gunTurretItemTotal or 0)
    result.artifactTotal = (info.artifactTotal or 0)
    result.tesseractTotal = (info.tesseractTotal or 0) / 1000
    return result
end

function analyzermgr.getGameResStatisticHistory(beginDate, endDate)
    local pipeline = {
        {
            ["$match"] = {
                createDate = { ["$gte"] = beginDate, ["$lte"] = endDate },
            }
        },
        {
            ["$project"] = {
                _id = 0,
                hourMin = "$hourMin",
                createDate = "$createDate",
                mitTotal = "$mitTotal",
                tesseractTotal = "$tesseractTotal",
                iceTotal = "$iceTotal",
                starCoinTotal = "$starCoinTotal",
                carboxylTotal = "$carboxylTotal",
                titaniumTotal = "$titaniumTotal",
                gasTotal = "$gasTotal",
                heroTotal = {
                    ["$add"] = {
                        {
                            ["$ifNull"] = { "$heroTotal", 0 },
                        },
                        {
                            ["$ifNull"] = { "$heroItemTotal", 0 },
                        }
                    }
                },
                warShipTotal = {
                    ["$add"] = {
                        {
                            ["$ifNull"] = { "$warShipTotal", 0 },
                        },
                        {
                            ["$ifNull"] = { "$warShipItemTotal", 0 },
                        }
                    }
                },
                gunTurretTotal = {
                    ["$add"] = {
                        {
                            ["$ifNull"] = { "$gunTurretTotal", 0 },
                        },
                        {
                            ["$ifNull"] = { "$gunTurretItemTotal", 0 },
                        }
                    }
                },

            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "game_statistic_minute_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        for kk, vv in pairs(v) do
            if vv == "\0\n" then
               v[kk] = "-"
            elseif kk == "mitTotal" or kk == "iceTotal" or kk == "starCoinTotal" or kk=="carboxylTotal" or kk=="titaniumTotal" or kk=="gasTotal" or kk=="tesseractTotal" then
                v[kk] = v[kk] / 1000
            end
        end
    end
    return ret.cursor.firstBatch
end

function analyzermgr.getPlayerList(pageNo, pageSize, condition)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.mongoProxy.online_players:findCount(condition)
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local list = {}
    local docs = gg.mongoProxy.online_players:findSortSkipLimit(condition, {loginTime = 1}, pageSize*(pageNo - 1), pageSize)
    for k, info in pairs(docs) do
        info._id = nil
        if info.tuoguanStatus == 1 then
            --"",""
            local playerInfo = gg.playerProxy:call(info.pid, "getPlayerInfoByAdmin", true)
            if playerInfo then
                info = playerInfo
            end
        end
        info.nftBuilds = nil
        info.nftWarShips = nil
        info.nftHeros = nil
        info.normalBuilds = nil
        info.normalWarShips = nil
        info.normalHeros = nil
        info.items = nil
        table.insert(result.rows, info)
    end
    return result
end

function analyzermgr.getPlayerDataList(condition, isDetail)
    local reslut = {}
    local docs = gg.mongoProxy.online_players:find(condition)
    for k, info in pairs(docs) do
        info._id = nil
        if info.tuoguanStatus == 1 then
            --"",""
            local playerInfo = gg.playerProxy:call(info.pid, "getPlayerInfoByAdmin", true)
            if playerInfo then
                info = playerInfo
            end
        end
        if not isDetail then
            info.nftBuilds = nil
            info.nftWarShips = nil
            info.nftHeros = nil
            info.normalBuilds = nil
            info.normalWarShips = nil
            info.normalHeros = nil
            info.items = nil
        end
        table.insert(reslut, info)
    end
    return reslut
end

function analyzermgr.getNewAddUserStatisticByMonth(platform,year,month,pageNo,pageSize)
    platform = platform and platform ~= "all" and platform or nil
    local monthno = gg.time.monthno(os.time( {year=year, month=month, day=1, hour=0, min=0, sec=0 } ))
    local pipeline = {
        {
            ["$match"] = {
                monthno = { ["$gte"] = monthno },
                platform = platform
            }
        },
        {
            ["$group"] = {
                _id = "$monthno",
                year = {
                    ["$first"] = {
                        ["$ifNull"] = { "$year", 0 },
                    }
                },
                month = {
                    ["$first"] = {
                        ["$ifNull"] = { "$month", 0 },
                    }
                },
                installCount = {
                    ["$avg"] = "$installCount"
                },
                activeAccount = {
                    ["$avg"] = "$activeAccount"
                },
                regAccount = {
                    ["$avg"] = "$regAccount"
                },
                firstGameTime = {
                    ["$avg"] = "$firstGameTime"
                },
                regActiveRatio = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$activeAccount", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$regAccount", "$activeAccount" },
                            }
                        }
                    }
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "game_statistic_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        for kk, vv in pairs(v) do
            if vv == "\0\n" then
               v[kk] = "-" 
            end
        end
    end
    local cmp = function(a,b)
        if a._id == b._id then
            local sortA = constant[constant.PLATFORM_SORT_PRE..string.upper(a.platform)] or 100000
            local sortB = constant[constant.PLATFORM_SORT_PRE..string.upper(b.platform)] or 100000
            if sortA == sortB then
                return false
            else
                return sortA<sortB
            end
        end
        return a._id < b._id
    end
    local result = analyzermgr._sortAndPage(ret.cursor.firstBatch,pageNo,pageSize,cmp)
    return result
end

function analyzermgr.getActiveUserStatisticByMonth(platform,year,month,pageNo,pageSize)
    platform = platform and platform ~= "all" and platform or nil
    local monthno = gg.time.monthno(os.time( {year=year, month=month, day=1, hour=0, min=0, sec=0 } ))
    local pipeline = {
        {
            ["$match"] = {
                monthno = { ["$gte"] = monthno },
                platform = platform
            }
        },
        {
            ["$group"] = {
                _id = "$monthno",
                year = {
                    ["$first"] = {
                        ["$ifNull"] = { "$year", 0 },
                    }
                },
                month = {
                    ["$first"] = {
                        ["$ifNull"] = { "$month", 0 },
                    }
                },
                dayActiveNum = { 
                    ["$avg"] = "$dayActiveNum",
                },
                weekActiveNum = { 
                    ["$avg"] = "$weekActiveNum",
                },
                monthActiveNum = { 
                    ["$avg"] = "$monthActiveNum",
                },
                activeRatio = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$monthActiveNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = {
                                    "$dayActiveNum", "$monthActiveNum"
                                }
                            }
                        },  
                    },
                    
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "game_statistic_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        for kk, vv in pairs(v) do
            if vv == "\0\n" then
               v[kk] = "-" 
            end
        end
    end
    local cmp = function(a,b)
        if a._id == b._id then
            local sortA = constant[constant.PLATFORM_SORT_PRE..string.upper(a.platform)] or 100000
            local sortB = constant[constant.PLATFORM_SORT_PRE..string.upper(b.platform)] or 100000
            if sortA == sortB then
                return false
            else
                return sortA<sortB
            end
        end
        return a._id < b._id
    end
    local result = analyzermgr._sortAndPage(ret.cursor.firstBatch,pageNo,pageSize,cmp)
    return result
end

function analyzermgr.getValidNewAddUserStatisticByMonth(platform,year,month,pageNo,pageSize)
    local monthno = gg.time.monthno(os.time( {year=year, month=month, day=1, hour=0, min=0, sec=0 }))
    platform = platform and platform ~= "all" and platform or nil
    local pipeline = {
        {
            ["$match"] = {
                monthno = { ["$gte"] = monthno },
                platform = platform 
            }
        },
        {
            ["$group"] = {
                _id = "$monthno",
                year = {
                    ["$first"] = {
                        ["$ifNull"] = { "$year", 0 },
                    }
                },
                month = {
                    ["$first"] = {
                        ["$ifNull"] = { "$month", 0 },
                    }
                },
                validNewAddNum = { 
                    ["$avg"] = "$validNewAddNum",
                },
                loginStayNum = { 
                    ["$avg"] =  "$loginStayNum"
                },
                loginStayNumV2 = { 
                    ["$avg"] = "$loginStayNumV2"
                },

                --""
                regUserValidRatio = { 
                    ["$avg"] =  {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$regUserNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = {
                                    "$validNewAddNum", "$regUserNum",
                                }
                            }
                        },
                         
                    }
                },
                --""
                loginStayValidRatio = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$validNewAddNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = {"$loginStayNum", "$validNewAddNum"}
                            }
                        },
                        
                    } 
                },
                --""
                loginStayValidRatioV2 = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$loginStayNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$loginStayNumV2", "$loginStayNum" },
                            }
                        },
                        
                    }
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "game_statistic_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        for kk, vv in pairs(v) do
            if vv == "\0\n" then
               v[kk] = "-" 
            end
        end
    end
    local cmp = function(a,b)
        if a._id == b._id then
            local sortA = constant[constant.PLATFORM_SORT_PRE..string.upper(a.platform)] or 100000
            local sortB = constant[constant.PLATFORM_SORT_PRE..string.upper(b.platform)] or 100000
            if sortA == sortB then
                return false
            else
                return sortA<sortB
            end
        end
        return a._id < b._id
    end
    local result = analyzermgr._sortAndPage(ret.cursor.firstBatch,pageNo,pageSize,cmp)
    return result
end

function analyzermgr.getOnlineUserStatisticByMonth(platform,year,month,pageNo,pageSize)
    local monthno = gg.time.monthno(os.time( {year=year, month=month, day=1, hour=0, min=0, sec=0 }))
    platform = platform and platform ~= "all" and platform or nil
    local pipeline = {
        {
            ["$match"] = {
                monthno = { ["$gte"] = monthno },
                platform = platform 
            }
        },
        {
            ["$group"] = {
                _id = "$monthno",
                year = {
                    ["$first"] = {
                        ["$ifNull"] = { "$year", 0 },
                    }
                },
                month = {
                    ["$first"] = {
                        ["$ifNull"] = { "$month", 0 },
                    }
                },
                sameTimeOnlineNum = { 
                    ["$avg"] = "$maxSameTimeOnlineNum"
                },
                maxSameTimeOnlineNum = { 
                    ["$max"] = "$maxSameTimeOnlineNum"
                },
                avgOnlineTime = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$dayActiveNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$totalGameTime", "$dayActiveNum" }
                            }
                        }, 
                    }
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "game_statistic_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        for kk, vv in pairs(v) do
            if vv == "\0\n" then
               v[kk] = "-" 
            end
        end
    end
    local cmp = function(a,b)
        if a._id == b._id then
            local sortA = constant[constant.PLATFORM_SORT_PRE..string.upper(a.platform)] or 100000
            local sortB = constant[constant.PLATFORM_SORT_PRE..string.upper(b.platform)] or 100000
            if sortA == sortB then
                return false
            else
                return sortA<sortB
            end
        end
        return a._id < b._id
    end
    local result = analyzermgr._sortAndPage(ret.cursor.firstBatch,pageNo,pageSize,cmp)
    return result
end

function analyzermgr.getLostUserStatisticByMonth(platform,year,month,pageNo,pageSize)
    local monthno = gg.time.monthno(os.time( {year=year, month=month, day=1, hour=0, min=0, sec=0 }))
    platform = platform and platform ~= "all" and platform or nil
    local pipeline = {
        {
            ["$match"] = {
                monthno = { ["$gte"] = monthno },
                platform = platform 
            }
        },
        {
            ["$group"] = {
                _id = "$monthno",
                year = {
                    ["$first"] = {
                        ["$ifNull"] = { "$year", 0 },
                    }
                },
                month = {
                    ["$first"] = {
                        ["$ifNull"] = { "$month", 0 },
                    }
                },
                regDayLostUserNum = {
                    ["$avg"] = "$regDayLostUserNum"
                },
                regWeekLostUserNum = {
                    ["$avg"] = "$regWeekLostUserNum"
                },
                regMonthLostUserNum = {
                    ["$avg"] = "$regMonthLostUserNum"
                },

                
                dayActiveLostUserRatio = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$dayActiveNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$dayActiveLostUserNum", "$dayActiveNum" }
                            }
                        },
                        
                    }
                },
                weekActiveLostUserRatio = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$weekActiveNum", 0}
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$weekActiveLostUserNum", "$weekActiveNum" },
                            }
                        },
                        
                    }
                },
                monthActiveLostUserRatio = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$monthActiveNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$weekActiveLostUserNum", "$monthActiveNum" }
                            }
                        },
                        
                    }
                }, 
                --[[ ]]
            }
            
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "game_statistic_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        for kk, vv in pairs(v) do
            if vv == "\0\n" then
               v[kk] = "-" 
            end
        end
    end
    local cmp = function(a,b)
        if a._id == b._id then
            local sortA = constant[constant.PLATFORM_SORT_PRE..string.upper(a.platform)] or 100000
            local sortB = constant[constant.PLATFORM_SORT_PRE..string.upper(b.platform)] or 100000
            if sortA == sortB then
                return false
            else
                return sortA<sortB
            end
        end
        return a._id < b._id
    end
    local result = analyzermgr._sortAndPage(ret.cursor.firstBatch,pageNo,pageSize,cmp)
    return result
end


function analyzermgr.getStayUserStatisticByMonth(platform,year,month,pageNo,pageSize)
    local monthno = gg.time.monthno(os.time( {year=year, month=month, day=1, hour=0, min=0, sec=0 }))
    platform = platform and platform ~= "all" and platform or nil
    local pipeline = {
        {
            ["$match"] = {
                monthno = { ["$gte"] = monthno },
                platform = platform
            }
        },
        {
            ["$group"] = {
                _id = "$monthno",
                year = {
                    ["$first"] = {
                        ["$ifNull"] = { "$year", 0 },
                    },
            
                },
                month = {
                    ["$first"] = {
                        ["$ifNull"] = { "$month", 0 },
                    },
            
                },
                --""
                stayUserNumInReg2d = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$regUserNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$stayUserNumInReg2d", "$regUserNum" }
                            }
                        }
                    }
                },
                stayUserNumInReg3d = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$regUserNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$stayUserNumInReg3d", "$regUserNum" }
                            }
                        },
                    }
                },
                stayUserNumInReg7d = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$regUserNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$stayUserNumInReg7d",  "$regUserNum" }
                            }
                        },
                    }
                },

                stayUserNumInReg14d = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$regUserNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$stayUserNumInReg14d", "$regUserNum" }
                            }
                        },
                    }
                },
                stayUserNumInReg30d = {
                    ["$avg"] = {
                        ["$cond"] = {
                            ["if"] = {
                                ["$eq"] = { "$regUserNum", 0 }, 
                            },
                            ["then"] = 0,
                            ["else"] = {
                                ["$divide"] = { "$stayUserNumInReg30d", "$regUserNum" }
                            }
                        },
                    }
                },

            }
        }
    }

    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "game_statistic_log", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        for kk, vv in pairs(v) do
            if vv == "\0\n" then
               v[kk] = "-" 
            end
        end
    end
    local cmp = function(a,b)
        if a._id == b._id then
            local sortA = constant[constant.PLATFORM_SORT_PRE..string.upper(a.platform)] or 100000
            local sortB = constant[constant.PLATFORM_SORT_PRE..string.upper(b.platform)] or 100000
            if sortA == sortB then
                return false
            else
                return sortA<sortB
            end
        end
        return a._id < b._id
    end
    local result = analyzermgr._sortAndPage(ret.cursor.firstBatch,pageNo,pageSize,cmp)
    return result
end

function analyzermgr.getUserStatisticByDay(beginDate, endDate, platform, pageNo, pageSize)

    platform = platform and platform ~= "all" and platform or nil

    local pipeline = {
        {
            ["$match"] = {
                createDate = { ["$gte"] = beginDate, ["$lte"] = endDate },
                platform = platform and  { ["$eq"] = platform } or nil ,
            }
        },
        {
            ["$project"] = {
                _id = 0,
                createDate = "$createDate",
                -- ""
                platform = 
                {
                    ["$ifNull"] = { "$platform", "-" },
                },
                --""
                installCount = {
                    ["$ifNull"] = { "$installCount", 0 },
                },
                --""
                activeAccount = {
                    ["$ifNull"] = { "$activeAccount", 0 },
                },
                --""
                regAccount = {
                    ["$ifNull"] = { "$regAccount", 0 },
                },
                --""
                firstGameTime = {
                    ["$ifNull"] = { "$firstGameTime", 0 },
                },
                --""
                regActiveRatio = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$activeAccount", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$regAccount", "$activeAccount"
                            }
                        }
                    }                    
                },

                --""
                dayActiveNum = { 
                    ["$ifNull"] = { "$dayActiveNum", 0 }  
                },
                --""
                weekActiveNum = { 
                    ["$ifNull"] = { "$weekActiveNum", 0 }  
                },
                --""
                monthActiveNum = { 
                    ["$ifNull"] = { "$monthActiveNum", 0 }  
                },
                --""
                activeRatio = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$monthActiveNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$dayActiveNum", "$monthActiveNum",
                            }
                        }
                    }
                },

                --""
                validNewAddNum = { 
                    ["$ifNull"] = { "$validNewAddNum", 0 }  
                },
                --""
                loginStayNum = { 
                    ["$ifNull"] = { "$loginStayNum", 0 } 
                },
                --""
                loginStayNumV2 = { 
                    ["$ifNull"] = { "$loginStayNumV2", 0 }  
                },
                --""
                regUserValidRatio = { 
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$regUserNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$validNewAddNum", "$regUserNum"
                            }
                        }
                    }
                },

                
                --""
                loginStayValidRatio = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$validNewAddNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$loginStayNum", "$validNewAddNum"
                            }
                        }
                    }
                },

                --""
                loginStayValidRatioV2 = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$loginStayNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$loginStayNumV2", "$loginStayNum"
                            }
                        }
                    }
                },

                

                --""
                sameTimeOnlineNum = { 
                    ["$avg"] = { 
                        ["$ifNull"] = { "$sameTimeOnlineNum", 0 } 
                    } 
                },
                --""
                maxSameTimeOnlineNum = { 
                    ["$max"] = { 
                        ["$ifNull"] = { "$maxSameTimeOnlineNum", 0 } 
                    } 
                },
                --""
                avgOnlineTime = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$dayActiveNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$totalGameTime", "$dayActiveNum"
                            }
                        }
                    }
                },

                
                --""
                regDayLostUserNum = {
                    ["$ifNull"] = { "$regDayLostUserNum", 0 },
                },
                --""
                regWeekLostUserNum = {
                    ["$ifNull"] = { "$regWeekLostUserNum", 0 },
                },
                --""
                regMonthLostUserNum = {
                    ["$ifNull"] = { "$regMonthLostUserNum", 0 },
                },

                --""
                dayActiveLostUserRatio = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$dayActiveNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$dayActiveLostUserNum", "$dayActiveNum"
                            }
                        }
                    }
                },
                --""
                weekActiveLostUserRatio = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$weekActiveNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$weekActiveLostUserNum", "$weekActiveNum"
                            }
                        }
                    }
                },
                --""
                monthActiveLostUserRatio = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$monthActiveNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$monthActiveLostUserNum", "$monthActiveNum"
                            }
                        }
                    }
                },

                --""
                stayUserNumInReg2d = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$regUserNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = { "$stayUserNumInReg2d", "$regUserNum" }
                        }
                    }
                },
                --3""
                stayUserNumInReg3d = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$regUserNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$stayUserNumInReg3d", "$regUserNum"
                            }
                        }
                    },

                },
                --7""
                stayUserNumInReg7d = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$regUserNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$stayUserNumInReg7d",
                                "$regUserNum"
                            }
                        }
                    },
                },
                --14""
                stayUserNumInReg14d = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$regUserNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$stayUserNumInReg14d",
                                "$regUserNum"
                            }
                        }
                    },
                },
                --30""
                stayUserNumInReg30d = {
                    ["$cond"] = {
                        ["if"] = {
                            ["$eq"] = { "$regUserNum", 0 }, 
                        },
                        ["then"] = 0,
                        ["else"] = {
                            ["$divide"] = {
                                "$stayUserNumInReg30d",
                                "$regUserNum"
                            }
                        }
                    },
                },
            }
   }
    }
 
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "game_statistic_log", "pipeline", pipeline, "cursor", {})

    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return {}
    end

    for k, v in pairs(ret.cursor.firstBatch) do
        for kk, vv in pairs(v) do
            if vv == "\0\n" then
               v[kk] = "-" 
            end
        end
    end
    local cmp = function(a,b)
        if a.createDate == b.createDate then
            local sortA = constant[constant.PLATFORM_SORT_PRE..string.upper(a.platform)] or 100000
            local sortB = constant[constant.PLATFORM_SORT_PRE..string.upper(b.platform)] or 100000
            if sortA == sortB then
                return false
            else
                return sortA<sortB
            end
        else
            return a.createDate < b.createDate
        end
    end
    local result = analyzermgr._sortAndPage(ret.cursor.firstBatch, pageNo, pageSize, cmp)
    return result
end

function analyzermgr.getPaymentStatisticByDay(beginDate, endDate, platform, pageNo, pageSize)
    if platform == "all" then
        platform = nil
    end
    local docs = gg.mongoProxy.game_statistic_log:find({ createDate = { ["$gte"] = beginDate, ["$lte"] = endDate }, platform = platform })
    local cmp = function(a,b)
        if a.createDate == b.createDate then
            local sortA = constant[constant.PLATFORM_SORT_PRE..string.upper(a.platform)] or 100000
            local sortB = constant[constant.PLATFORM_SORT_PRE..string.upper(b.platform)] or 100000
            if sortA == sortB then
                return false
            else
                return sortA<sortB
            end
        else
            return a.createDate < b.createDate
        end
    end
    local result = analyzermgr._sortAndPage(docs, pageNo, pageSize, cmp)
    local data = {}
    for k, v in pairs(result.rows) do
        --""
        local regAccount = v.regAccount or 0
        --""
        local dayActiveNum = v.dayActiveNum or 0

        local info = {}
        info.createDate = v.createDate
        info.platform = v.platform

        --""
        info.dayOrderSettleUser = v.dayOrderSettleUser or 0
        --""
        info.dayHydroxylExchangeUser = v.dayHydroxylExchangeUser or 0
        --""
        info.dayPaymentUser = v.dayPaymentUser or 0
        --""
        info.firstPaymentUser = v.firstPaymentUser or 0
        --""
        info.registerPaymentUser = v.registerPaymentUser or 0
        --""
        info.firstDayPaymentRate = 0
        if regAccount > 0 then
            info.firstDayPaymentRate = info.registerPaymentUser / regAccount
        end
        --""
        info.dayPaymentRate = 0
        if dayActiveNum > 0 then
            info.dayPaymentRate = info.dayPaymentUser / dayActiveNum
        end
        --""
        info.orderTesseract = (v.orderTesseract or 0) / 1000
        --""
        info.exchangeTesseract = (v.exchangeTesseract or 0) / 1000
        --""
        info.chainRechargeHYT = (v.chainRechargeHYT or 0) / 1000
        --""
        info.chainWithdrawHYT = (v.chainWithdrawHYT or 0) / 1000
        --""MIT""
        info.chainRechargeMIT = (v.chainRechargeMIT or 0) / 1000
        --""MIT""
        info.chainWithdrawMIT = (v.chainWithdrawMIT or 0) / 1000
        --""
        info.orderReadyCnt = v.orderReadyCnt or 0
        --""
        info.orderSettleCnt = v.orderSettleCnt or 0
        --""
        info.orderReadyPrice = v.orderReadyPrice or 0
        --""
        info.orderSettlePrice = v.orderSettlePrice or 0
        --""ARPU
        info.orderARPU = 0
        if dayActiveNum > 0 then
            info.orderARPU = info.orderSettlePrice / dayActiveNum
        end
        --""ARPPU
        info.orderARPPU = 0
        if info.dayOrderSettleUser > 0 then
            info.orderARPPU = info.orderSettlePrice / info.dayOrderSettleUser
        end
        --""
        info.orderFirstPrice = v.orderFirstPrice or 0
        --""
        info.orderRegisterPrice = v.orderRegisterPrice or 0
        --""
        info.exchangeCnt = v.exchangeCnt or 0
        --""
        info.exchangeHydroxyl = (v.exchangeHydroxyl or 0) / 1000
        --""ARPU
        info.exchangeARPU = 0
        if dayActiveNum > 0 then
            info.exchangeARPU = info.exchangeHydroxyl / dayActiveNum
        end
        --""ARPPU
        info.exchangeARPPU = 0
        if info.dayHydroxylExchangeUser > 0 then
            info.exchangeARPPU = info.exchangeHydroxyl / info.dayHydroxylExchangeUser
        end

        table.insert(data, info)
    end

    result.rows = data

    return result
end

-- "" rawData [""] ，""，""
--args: pageNo "" pageSize "" ,cmp ""("")
-- return  ：  {
--    totalRows : rawData ""
--    totalPage ： rawData""
--    pageNo ： ""
--    pageSize ： ""
-- }
function analyzermgr._sortAndPage(rawData,pageNo,pageSize,cmp)

    assert(type(rawData)=="table" and pageNo and pageSize , "_sortAndPage args error")
    if cmp then
        table.sort(rawData,cmp)
    end

    local result = {}
    result.pageSize = pageSize
    result.totalRows = #rawData
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.pageNo = pageNo<= result.totalPage and pageNo or result.totalPage
    local realRows = {}
    for i = (result.pageNo -1) * pageSize + 1, result.pageNo * pageSize ,1 do
        local cell =  rawData[i]
        if cell then
            table.insert(realRows,cell)
        else
            break
        end
    end
    result.rows = realRows
    return result
end

function analyzermgr.getPlayerPVEStatistic()
    -- local sortCond = bson.encode_order( "pveLevel", -1, "timestamp", 1)
    -- local pipeline = {
    --     {
    --         ["$sort"] = sortCond
    --     },
    --     {
    --         ["$limit"] = 2000,
    --     },
    --     {
    --         ["$group"] = {
    --             _id = "$pid",
    --             pid = { ["$first"] = "$pid" },
    --             name = { ["$first"] = "$name" },
    --             account = { ["$first"] = "$account" },
    --             pveScore = { ["$first"] = "$pveScore" },
    --             pveLevel = { ["$first"] = "$pveLevel" },
    --             level = { ["$first"] = "$level" },
    --             timestamp = { ["$first"] = "$timestamp" },
    --             createTime = {["$first"] = "$timestamp" },
    --         }
    --     },
    --     {
    --         ["$sort"] = sortCond
    --     },
    --     {
    --         ["$limit"] = 100,
    --     }
    -- }
    -- local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "player_pve_log", "pipeline", pipeline, "cursor", {})
    -- if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
    --     return {}
    -- end
    -- return ret.cursor.firstBatch
    return gg.mongoProxy:call("getPlayerPVEStatistic")
end

--""
function analyzermgr.getUserInviteInfoByAccount(pageNo, pageSize, account)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = 0
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    result.myself = {}

    local accountDoc = gg.mongoProxy.inviteAccount:findOne({ account = account })
    if accountDoc then
        result.myself.account = account
        result.myself.pid = 0
        --""
        local ret1 = analyzermgr.getPlayerDataList({ account = account }, false)
        if ret1[1] then
            result.myself = ret1[1]
        end

        --""
        local inviteCode = accountDoc.inviteCode
        result.totalRows = gg.mongoProxy.inviteAccount:findCount({fatherInviteCode = inviteCode})
        result.totalPage = math.ceil(result.totalRows / pageSize)
        local sonPids = {}
        local sonAccounts = {}
        local docs = gg.mongoProxy.inviteAccount:findSortSkipLimit({fatherInviteCode = inviteCode}, {pid = -1}, pageSize*(pageNo - 1), pageSize)
        for _, v in pairs(docs) do
            if v.pid then
                table.insert(sonPids, v.pid)
            end
            sonAccounts[v.account] = true
        end
        if next(sonPids) then
            local sonCondition = {["pid"] = {["$in"] = sonPids}}
            local ret2 = analyzermgr.getPlayerDataList(sonCondition, false)
            for k,v in pairs(ret2) do
                table.insert(result.rows, v)
                sonAccounts[v.account] = nil
            end
        end
        for k,v in pairs(sonAccounts) do
            table.insert(result.rows, { account = k, pid = 0 })
        end
        table.sort(result.rows, function (a, b) 
            if a.pid and b.pid and a.pid > b.pid then
                return true
            end
            return false
        end)
    end
    return result
end


function analyzermgr.writeInviteInfo(file, inviteInfo, playerInfo, isSonAccount)
    playerInfo = playerInfo or {}
    local fields = {}
    if isSonAccount then
        table.insert(fields, "")
        table.insert(fields, "")
        table.insert(fields, "")
    else
        table.insert(fields, inviteInfo.fatherAccount or "GalaxyBlitz")
        table.insert(fields, inviteInfo.fatherWalletAddress or "")
        table.insert(fields, inviteInfo.fatherPid or 0)
    end

    table.insert(fields, inviteInfo.account or "")
    table.insert(fields, inviteInfo.myWalletAddress or "")
    table.insert(fields, inviteInfo.pid or 0)

    table.insert(fields, playerInfo.name or "")
    table.insert(fields, playerInfo.headIcon or "")
    table.insert(fields, playerInfo.baseLevel or 0)
    table.insert(fields, playerInfo.maxPVE or 0)
    table.insert(fields, playerInfo.vipLevel or 0)
    table.insert(fields, playerInfo.badge or 0)
    table.insert(fields, playerInfo.mit or 0)
    table.insert(fields, playerInfo.starCoin or 0)
    table.insert(fields, playerInfo.gas or 0)
    table.insert(fields, playerInfo.carboxyl or 0)
    table.insert(fields, playerInfo.titanium or 0)
    table.insert(fields, playerInfo.ice or 0)
    table.insert(fields, playerInfo.nftTotal or 0)
    table.insert(fields, playerInfo.ip or "0.0.0.0")
    table.insert(fields, playerInfo.onlineStatus or 0)
    if playerInfo.createTime and playerInfo.createTime > 0 then
        table.insert(fields, gg.UnixStampToDateTime(playerInfo.createTime))
    else
        table.insert(fields, "")
    end
    if playerInfo.loginTime and playerInfo.loginTime > 0 then
        table.insert(fields, gg.UnixStampToDateTime(playerInfo.loginTime or 0))
    else
        table.insert(fields, "")
    end
    if playerInfo.logoutTime and playerInfo.logoutTime > 0 then
        table.insert(fields, gg.UnixStampToDateTime(playerInfo.logoutTime or 0))
    else
        table.insert(fields, "")
    end
    local totalTimeStr = gg.time.strftime("%D""%H""%M""", playerInfo.totalGameTime or 0)
    table.insert(fields, totalTimeStr)
    if playerInfo.levelFiveTime and playerInfo.levelFiveTime > 0 then
        table.insert(fields, gg.UnixStampToDateTime(playerInfo.levelFiveTime or 0))
    else
        table.insert(fields, "")
    end
    local lineStr = table.concat(fields, ",") .. "\n"
    file:write(lineStr)
end

function analyzermgr.writeSonAccountStatisticFile(file, account, pid, walletAddress, count)
    local fields = {}
    table.insert(fields, account or "GalaxyBlitz")
    table.insert(fields, pid or 0)
    table.insert(fields, walletAddress or "")
    table.insert(fields, count or 0)
    local lineStr = table.concat(fields, ",") .. "\n"
    file:write(lineStr)
end


function analyzermgr.getNewInviteInfoStatistic()
    local pa = ggclass.cparallel.new()
    local inviteInfoMap = {}
    local docs = gg.mongoProxy.inviteAccount:find({})
    for _, doc in pairs(docs) do
        doc.sonPlayers = {}
        inviteInfoMap[doc.account] = doc
        if doc.pid then
            pa:add(function(account, pid, fatherAccount)
                if fatherAccount then
                    local walletAddressInfo =  gg.shareProxy:call("getWalletAddressByAccount", fatherAccount)
                    if walletAddressInfo then
                        inviteInfoMap[account].fatherWalletAddress = walletAddressInfo.walletAddress
                    end
                end

                local myWalletInfo = gg.shareProxy:call("getWalletAddressByAccount", account)
                if myWalletInfo then
                    inviteInfoMap[account].myWalletAddress = myWalletInfo.walletAddress
                end

                local playerInfo = gg.shareProxy:call("getPlayerInfoByQueue", pid)
                if playerInfo then
                    assert(pid == playerInfo.pid, "getPlayerInfoByQueue error 111")
                    inviteInfoMap[account].playerInfo = playerInfo
                end
                
            end, doc.account, doc.pid, doc.fatherAccount)
        end
    end
    pa:wait()

    for k, v in pairs(inviteInfoMap) do
        local fatherAccount = v.fatherAccount
        if fatherAccount and v.playerInfo then
            local fatherInviteInfo = inviteInfoMap[fatherAccount]
            if fatherInviteInfo then
                table.insert(fatherInviteInfo.sonPlayers, v.playerInfo)
            end
        end
    end

    local countFile = io.open("/tmp/InviteCountInfoStatistic.csv", "w+")
    countFile:write(""",""ID,"",""\n")

    local file = io.open("/tmp/InviteInfoStatistic.csv", "w+")
    file:write(""","",""ID,"","",""ID,"","","",""PVE"",VIP"","",MIT,"","","","","",NFT"",IP"","","","","",""\n")
    for k, v in pairs(inviteInfoMap) do
        analyzermgr.writeInviteInfo(file, v, v.playerInfo, false)
        if #v.sonPlayers > 0 and v.account then
            analyzermgr.writeSonAccountStatisticFile(countFile, v.account, v.pid, v.myWalletAddress, #v.sonPlayers)
        end
    end
    file:close()
    countFile:close()

    return { "/tmp/InviteInfoStatistic.csv", "/tmp/InviteCountInfoStatistic.csv" }
end

--""game""
function analyzermgr.getInviteInfoStatistic()
    local pa = ggclass.cparallel.new()
    local inviteInfoMap = {}
    local docs = gg.mongoProxy.inviteAccount:find({})
    for _, doc in pairs(docs) do
        doc.sonPlayers = {}
        inviteInfoMap[doc.account] = doc
        if doc.pid then
            pa:add(function(account, pid, fatherAccount)
                if fatherAccount then
                    local walletAddressInfo =  gg.shareProxy:call("getWalletAddressByAccount", fatherAccount)
                    if walletAddressInfo then
                        inviteInfoMap[account].fatherWalletAddress = walletAddressInfo.walletAddress
                    end
                end

                local myWalletInfo = gg.shareProxy:call("getWalletAddressByAccount", account)
                if myWalletInfo then
                    inviteInfoMap[account].myWalletAddress = myWalletInfo.walletAddress
                end

                local playerInfo = gg.mongoProxy.online_players:findOne({pid = pid})
                if not playerInfo then
                    playerInfo = gg.shareProxy:call("getPlayerInfoByQueue", pid)
                end

                if playerInfo then
                    assert(pid == playerInfo.pid, "getPlayerInfoByQueue error 111")
                    inviteInfoMap[account].playerInfo = playerInfo
                end
                
            end, doc.account, doc.pid, doc.fatherAccount)
        end
    end
    pa:wait()

    for k, v in pairs(inviteInfoMap) do
        local fatherAccount = v.fatherAccount
        if fatherAccount and v.playerInfo then
            local fatherInviteInfo = inviteInfoMap[fatherAccount]
            if fatherInviteInfo then
                table.insert(fatherInviteInfo.sonPlayers, v.playerInfo)
            end
        end
    end

    local countFile = io.open("/tmp/InviteCountInfoStatistic.csv", "w+")
    countFile:write(""",""ID,"",""\n")

    local file = io.open("/tmp/InviteInfoStatistic.csv", "w+")
    file:write(""","",""ID,"","",""ID,"","","",""PVE"",VIP"","",MIT,"","","","","",NFT"",IP"","","","","","",""5""\n")
    for k, v in pairs(inviteInfoMap) do
        analyzermgr.writeInviteInfo(file, v, v.playerInfo, false)
        if #v.sonPlayers > 0 and v.account then
            analyzermgr.writeSonAccountStatisticFile(countFile, v.account, v.pid, v.myWalletAddress, #v.sonPlayers)
        end
    end
    file:close()
    countFile:close()

    return { "/tmp/InviteInfoStatistic.csv", "/tmp/InviteCountInfoStatistic.csv" }
end

--""ID""
function analyzermgr.getPlayerInviteListBySonPid(beginTime, endTime, sonPid)
    local pa = ggclass.cparallel.new()
    local players = {}
    local fatherPlayers = {}
    local docs
    if beginTime > 0 and endTime > 0 then
        docs = gg.mongoProxy.online_players:find({ levelFiveTime = {["$gte"] = beginTime, ["$lt"] = endTime}, pid = sonPid })
    else
        docs = gg.mongoProxy.online_players:find({ pid = sonPid })
    end
    for _, doc in pairs(docs) do
        players[doc.pid] = doc
        pa:add(function(pid, account)
            local inviteDoc = gg.mongoProxy.inviteAccount:findOne({account = account})
            if inviteDoc and inviteDoc.fatherPid then
                local player = players[pid]
                local fatherPlayer = fatherPlayers[inviteDoc.fatherPid]
                if not fatherPlayer then
                    fatherPlayer = gg.mongoProxy.online_players:findOne({ pid = inviteDoc.fatherPid })
                    fatherPlayers[inviteDoc.fatherPid] = fatherPlayer
                end
                player.fatherPid = inviteDoc.fatherPid
                player.fatherAccount = inviteDoc.fatherAccount
                player.fatherInviteCode = inviteDoc.fatherInviteCode
                if fatherPlayer then
                    player.fatherBaseLevel = fatherPlayer.baseLevel
                    player.fatherWalletAddress = fatherPlayer.walletAddress
                end
            end
        end, doc.pid, doc.account)
    end
    pa:wait()
    local retPlayers = {}
    for k, v in pairs(players) do
        if v.fatherPid and v.fatherAccount then
            table.insert(retPlayers, v)
        end
    end
    return retPlayers
end

--""ID""
function analyzermgr.getPlayerInviteListByFatherPid(beginTime, endTime, fatherPid)
    local pa = ggclass.cparallel.new()    
    local players = {}
    local fatherPlayer = gg.mongoProxy.online_players:findOne({ pid = fatherPid })
    if fatherPlayer then
        local docs = gg.mongoProxy.inviteAccount:find({fatherPid = fatherPid})
        for _, doc in pairs(docs) do
            pa:add(function(pid)
                local player
                if beginTime > 0 and endTime > 0 then
                    player = gg.mongoProxy.online_players:findOne({ levelFiveTime = {["$gte"] = beginTime, ["$lt"] = endTime}, pid = pid })
                else
                    player = gg.mongoProxy.online_players:findOne({ pid = pid })
                end
                if player then
                    player.fatherPid = fatherPid
                    player.fatherAccount = fatherPlayer.account
                    player.fatherInviteCode = fatherPlayer.inviteCode
                    player.fatherBaseLevel = fatherPlayer.baseLevel
                    player.fatherWalletAddress = fatherPlayer.walletAddress
                    players[pid] = player
                end
            end, doc.pid)
        end
        pa:wait()
    end
    return table.values(players)
end

--""
function analyzermgr.getGameResLog(pageNo, pageSize, pid, res, reason, change)
    return gg.mongoProxy:call("getGameResLog", pageNo, pageSize, pid, res, reason, change)
end

--""
function analyzermgr.getGameItemLog(pageNo, pageSize, pid, id, cfgId, reason)
    return gg.mongoProxy:call("getGameItemLog", pageNo, pageSize, pid, id, cfgId, reason)
end

--""
function analyzermgr.getGameEntityLog(pageNo, pageSize, pid, entity, id, cfgId, reason)
    return gg.mongoProxy:call("getGameEntityLog", pageNo, pageSize, pid, entity, id, cfgId, reason)
end

-- ""
function analyzermgr.getPayOrderList(pageNo, pageSize, condition)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.mongoProxy.order_ready:findCount(condition)
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local list = {}
    local docs = gg.mongoProxy.order_ready:findSortSkipLimit(condition, {createOrderTime = -1}, pageSize*(pageNo - 1), pageSize)
    for k, info in pairs(docs) do
        local data = {}
        data.account = info.account
        data.pid = info.pid
        data.platform = info.platform
        data.payChannel = info.payChannel
        data.orderId = info.orderId
        data.productId = info.productId
        data.price = info.price
        data.value = math.floor(info.value / 1000)
        data.state = info.state
        data.createOrderTime = info.createOrderTime
        data.settleOrderTime = info.settleOrderTime
        data.op = info.op or ""
        data.receiptData = info.receiptData or ""
        data.signtureData = info.signtureData  or ""
        data.signture = info.signture or ""
        data.ext = info.ext or ""
        table.insert(result.rows, data)
    end
    return result
end

-- ""(TOKEN)""
function analyzermgr.getChainRechargeTokenList(pageNo, pageSize, condition)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.mongoProxy.rechargeToken:findCount(condition)
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local list = {}
    local docs = gg.mongoProxy.rechargeToken:findSortSkipLimit(condition, {create_time = -1}, pageSize*(pageNo - 1), pageSize)
    for k, info in pairs(docs) do
        local data = {}
        data.owner_mail = info.owner_mail
        data.pid = info.pid
        data.platform = info.platform
        data.chain_id = info.chain_id
        data.from_address = info.from_address
        data.order_num = info.order_num
        data.token = info.token
        data.value = math.floor(info.value / 1000)
        data.state = info.state
        data.message = info.message
        data.create_time = math.floor(info.create_time / 1000) 
        data.update_time = math.floor(info.update_time / 1000)
        data.transaction_hash = info.transaction_hash
        table.insert(result.rows, data)
    end
    return result
end

-- ""(NFT)""
function analyzermgr.getChainRechargeNftList(pageNo, pageSize, condition)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.mongoProxy.rechargeNft:findCount(condition)
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local list = {}
    local docs = gg.mongoProxy.rechargeNft:findSortSkipLimit(condition, {create_time = -1}, pageSize*(pageNo - 1), pageSize)
    for k, info in pairs(docs) do
        local data = {}
        data.owner_mail = info.owner_mail
        data.pid = info.pid
        data.platform = info.platform
        data.chain_id = info.chain_id
        data.from_address = info.from_address
        data.order_num = info.order_num
        data.token_ids = info.token_ids
        data.state = info.state
        data.message = info.message or ""
        data.success_ids = info.success_ids or ""
        data.fail_ids = info.fail_ids or ""
        data.create_time = math.floor(info.create_time / 1000) 
        data.update_time = math.floor(info.update_time / 1000)
        data.transaction_hash = info.transaction_hash
        table.insert(result.rows, data)
    end
    return result
end

-- ""(TOKEN)""
function analyzermgr.getChainWithdrawTokenList(pageNo, pageSize, condition)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.mongoProxy.withdrawToken:findCount(condition)
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local list = {}
    local docs = gg.mongoProxy.withdrawToken:findSortSkipLimit(condition, {create_time = -1}, pageSize*(pageNo - 1), pageSize)
    for k, info in pairs(docs) do
        local data = {}
        data.owner_mail = info.owner_mail
        data.pid = info.pid
        data.platform = info.platform
        data.chain_id = info.chain_id
        data.to_address = info.to_address
        data.order_num = info.order_num
        data.token = info.token
        data.amount = math.floor(info.amount / 1000)
        data.state = info.state
        data.message = info.message
        data.create_time = math.floor((info.create_time or 0) / 1000) 
        data.update_time = math.floor((info.update_time or 0) / 1000)
        data.transaction_hash = info.transaction_hash or ""
        table.insert(result.rows, data)
    end
    return result
end

-- ""(NFT)""
function analyzermgr.getChainWithdrawNftList(pageNo, pageSize, condition)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.mongoProxy.withdrawNft:findCount(condition)
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local list = {}
    local docs = gg.mongoProxy.withdrawNft:findSortSkipLimit(condition, {create_time = -1}, pageSize*(pageNo - 1), pageSize)
    for k, info in pairs(docs) do
        local data = {}
        data.owner_mail = info.owner_mail
        data.pid = info.pid
        data.platform = info.platform
        data.chain_id = info.chain_id
        data.to_address = info.to_address
        data.order_num = info.order_num
        data.token_ids = info.token_ids
        data.item_ids = info.item_ids
        data.item_cfgids = info.item_cfgids
        data.state = info.state
        data.message = info.message
        data.create_time = math.floor((info.create_time or 0) / 1000) 
        data.update_time = math.floor((info.update_time or 0) / 1000)
        data.transaction_hash = info.transaction_hash or ""
        table.insert(result.rows, data)
    end
    return result
end

--""
function analyzermgr.getSendMailLogs(pageNo, pageSize, sendId, sendName, receivePid, beginDate, endDate)
    return gg.mongoProxy:call("getSendMailLogs", pageNo, pageSize, sendId, sendName, receivePid, beginDate, endDate)
end

function analyzermgr.getDayUserPaymentInfo(dayno)
    --""
    local pipeline = {
        {
            ["$match"] = {
                settledayno = dayno,
                state = constant.PAY_STATE_2,
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                orderTesseract = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$value", 0 }
                    },
                },
                orderPrice = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$price", 0 }
                    },
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamedb:runCommand("aggregate", "order_settle", "pipeline", pipeline, "cursor", {})
    local data = {}
    if ret and ret.cursor and ret.cursor.firstBatch then
        for k,v in pairs(ret.cursor.firstBatch) do
            local info = data[v._id] or {}
            info.orderTesseract = v.orderTesseract or 0
            info.orderPrice = v.orderPrice or 0
            data[v._id] = info
        end
    end

    --""
    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                changeValue = { ["$lt"] = 0 },
                reason = gamelog[gamelog.EXCHANGE_RES],
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                exchangeHydroxyl = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$changeValue", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "carboxyl_log", "pipeline", pipeline, "cursor", {})
    if ret and ret.cursor and ret.cursor.firstBatch then
        for k,v in pairs(ret.cursor.firstBatch) do
            local info = data[v._id] or {}
            info.exchangeHydroxyl = math.abs(v.exchangeHydroxyl or 0)
            data[v._id] = info
        end
    end

    --""
    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                changeValue = { ["$gt"] = 0 },
                reason = gamelog[gamelog.EXCHANGE_RES],
            }
        },
        {
            ["$group"] = {
                _id = "$pid",
                exchangeTesseract = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$changeValue", 0 }
                    },
                }
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "tesseract_log", "pipeline", pipeline, "cursor", {})
    if ret and ret.cursor and ret.cursor.firstBatch then
        for k,v in pairs(ret.cursor.firstBatch) do
            local info = data[v._id] or {}
            info.exchangeTesseract = v.exchangeTesseract or 0
            data[v._id] = info
        end
    end
    return data
end

function analyzermgr.checkAndSaveDayUserPaymentInfo(timestamp)
    local dayno = gg.time.dayno(timestamp)
    local curdayno = gg.time.dayno()
    if dayno < curdayno then
        local doc = gg.mongoProxy.invite_day_pay_check:findOne({ dayno=dayno })
        if doc then
            return
        end
    end
    local data = analyzermgr.getDayUserPaymentInfo(dayno)
    local totalOrderTesseract = 0
    local totalOrderPrice = 0
    local totalExchangeHydroxyl = 0
    local totalExchangeTesseract = 0
    for pid, info in pairs(data) do
        local fatherAccount = nil
        local fatherInviteCode = nil
        local account = nil
        local accountDoc = gg.mongoProxy.inviteAccount:findOne({ pid=pid })
        if accountDoc then
            fatherAccount = accountDoc.fatherAccount
            fatherInviteCode = accountDoc.fatherInviteCode
            account = accountDoc.account
        end
        local orderTesseract = info.orderTesseract or 0
        local orderPrice = info.orderPrice or 0
        local exchangeHydroxyl = info.exchangeHydroxyl or 0
        local exchangeTesseract = info.exchangeTesseract or 0
        totalOrderTesseract = totalOrderTesseract + orderTesseract
        totalOrderPrice = totalOrderPrice + orderPrice
        totalExchangeHydroxyl = totalExchangeHydroxyl + exchangeHydroxyl
        totalExchangeTesseract = totalExchangeTesseract + exchangeTesseract
        gg.mongoProxy.invite_day_pay_detail:update({ 
            pid = pid,
            dayno = dayno
        }, {
            ["$set"] = { 
                pid = pid,
                account = account,
                dayno = dayno,
                fatherAccount = fatherAccount,
                fatherInviteCode = fatherInviteCode,
                orderTesseract = orderTesseract,
                orderPrice = orderPrice,
                exchangeHydroxyl = exchangeHydroxyl,
                exchangeTesseract = exchangeTesseract,
                weekno = gg.time.weekno(timestamp),
                monthno = gg.time.monthno(timestamp),
                payDate = tonumber(os.date("%Y%m%d", timestamp)),
            }
        }, true, false)
    end

    if dayno < curdayno then
        gg.mongoProxy.invite_day_pay_check:update({ 
            dayno = dayno 
        }, {
            ["$set"] = { 
                orderTesseract = totalOrderTesseract,
                orderPrice = tonumber(string.format("%.3f", totalOrderPrice)),
                exchangeHydroxyl = totalExchangeHydroxyl,
                exchangeTesseract = totalExchangeTesseract,
                dayno = dayno,
                weekno = gg.time.weekno(timestamp),
                monthno = gg.time.monthno(timestamp),
                payDate = tonumber(os.date("%Y%m%d", timestamp)),
            }
        }, true, false)
    end
end

-- ""
function analyzermgr.getInviteDayPaymentInfo(pageNo, pageSize, dayno, fatherAccount, sonAccount)

    local totalOrderTesseract = 0
    local totalOrderPrice = 0
    local totalExchangeHydroxyl = 0
    local totalExchangeTesseract = 0
    local count = 0

    local pipeline = {
        {
            ["$match"] = {
                dayno = dayno,
                fatherAccount = fatherAccount,
                account = sonAccount,
            }
        },
        {
            ["$group"] = {
                _id = 0,
                totalOrderTesseract = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$orderTesseract", 0 }
                    },
                },
                totalOrderPrice = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$orderPrice", 0 }
                    },
                },
                totalExchangeHydroxyl = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$exchangeHydroxyl", 0 }
                    },
                },
                totalExchangeTesseract = { 
                    ["$sum"] = {
                        ["$ifNull"] = { "$exchangeTesseract", 0 }
                    },
                },
                count = { 
                    ["$sum"] = 1 
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "invite_day_pay_detail", "pipeline", pipeline, "cursor", {})
    if ret and ret.cursor and ret.cursor.firstBatch and ret.cursor.firstBatch[1] then
        totalOrderTesseract = ret.cursor.firstBatch[1].totalOrderTesseract or 0
        totalOrderPrice = ret.cursor.firstBatch[1].totalOrderPrice or 0
        totalExchangeHydroxyl = ret.cursor.firstBatch[1].totalExchangeHydroxyl or 0
        totalExchangeTesseract = ret.cursor.firstBatch[1].totalExchangeTesseract or 0
        count = ret.cursor.firstBatch[1].count or 0
    end

    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = count
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local docs = gg.mongoProxy.invite_day_pay_detail:findSortSkipLimit({ dayno = dayno, fatherAccount = fatherAccount, account = sonAccount }, {orderPrice = -1}, pageSize*(pageNo - 1), pageSize)
    for k, info in pairs(docs) do
        local data = {}
        data.pid = info.pid
        data.account = info.account
        data.fatherAccount = info.fatherAccount
        data.orderPrice = info.orderPrice or 0
        data.orderTesseract = (info.orderTesseract or 0) / 1000
        data.exchangeHydroxyl = (info.exchangeHydroxyl or 0) / 1000
        data.exchangeTesseract = (info.exchangeTesseract or 0) / 1000
        table.insert(result.rows, data)
    end
    result.totalOrderTesseract = totalOrderTesseract / 1000
    result.totalOrderPrice = totalOrderPrice
    result.totalExchangeHydroxyl = totalExchangeHydroxyl / 1000
    result.totalExchangeTesseract = totalExchangeTesseract / 1000
    return result
end

--""cfgId""
function analyzermgr.generateGiftCode(cfgId, cnt)
    local giftCodeCfg = gg.getExcelCfg("giftCode")
    local info = giftCodeCfg[cfgId]
    if not info then
        return false, "cfgId not exist"
    end
    if info.style ~= constant.GIFT_CODE_STYLE_RANDOM then
        return false, "style error"
    end
    if cnt > 2000 then
        return false, "max 2000"
    end
    local secondno = gg.time.secondno()
    local giftCodes = {}
    for i = 1, cnt do
        local one = math.random(10000, 99999)
        local two = math.random(1000, 9999)
        local random = tonumber(one .. secondno .. i .. two)
        table.insert(giftCodes, cfgId .. math.int2AnyStr(random, 62))
    end

    local batchCodes = {}
    for k,v in pairs(giftCodes) do
        table.insert(batchCodes, { cfgId = cfgId, code = v })
    end

    gg.mongoProxy.gift_code:batch_insert(batchCodes)

    return true, giftCodes
end

--""
function analyzermgr.getGiftCodes(pageNo, pageSize, condition)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.mongoProxy.gift_code:findCount(condition)
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local list = {}
    local docs = gg.mongoProxy.gift_code:findSortSkipLimit(condition, {}, pageSize*(pageNo - 1), pageSize)
    for k, info in pairs(docs) do
        local data = {}
        data.cfgId = info.cfgId
        data.code = info.code
        data.pid = info.pid or 0
        data.rewardTime = info.rewardTime or 0
        table.insert(result.rows, data)
    end
    return result
end

function analyzermgr.getPlayerLvDistribution()
    local result = {}
    result.plyTotalCount = gg.mongoProxy.online_players:findCount({})
    result.plyTotalOnlineTime = 0
    result.rows = {}
    local pipeline = {
        {
            ["$match"] = {
            }
        },
        {
            ["$group"] = {
                _id = "$baseLevel",
                count = { ["$sum"] = 1 },
                totalOnlineTime = { ["$sum"] = "$totalGameTime" },
                avgTotalOnlineTime = {
                    ["$avg"] = "$totalGameTime"
                },
            }
        }
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "online_players", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return result
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        if v._id and tonumber(v._id) then
            local info = {
                _id = v._id,
                level = v._id,
                count = v.count,
                totalOnlineTime = v.totalOnlineTime,
                avgTotalOnlineTime = v.avgTotalOnlineTime,
                countPercent = v.count / result.plyTotalCount,
            }
            table.insert(result.rows, info)
            result.plyTotalOnlineTime = result.plyTotalOnlineTime + info.totalOnlineTime
        end
    end
    table.sort(result.rows, function (a, b) 
        return a.level < b.level
    end)
    return result
end

function analyzermgr.exportAllNftData()
    local ret = gg.mongoProxy.online_players:find()
    if not ret then
        return
    end
    --""nft：  ""  "" ""  pid chainid walletaddress
    local data = {}
    for k, v in pairs(ret) do
        for kk,nft in pairs(v) do
            if kk == "nftBuilds" then
                for kkk,vvv in pairs(nft) do
                    table.insert(data, {type="build", level=vvv.level, quality=vvv.quality, pid=v.pid, chainId=v.chainId, walletAddress=v.walletAddress})
                end
            end
            if kk == "nftHeros" then
                for kkk,vvv in pairs(nft) do
                    table.insert(data, {type="hero", level=vvv.level, quality=vvv.quality, pid=v.pid, chainId=v.chainId, walletAddress=v.walletAddress})
                end
            end
            if kk == "nftWarShips" then
                for kkk,vvv in pairs(nft) do
                    table.insert(data, {type="warShip", level=vvv.level, quality=vvv.quality, pid=v.pid, chainId=v.chainId, walletAddress=v.walletAddress})
                end
            end
        end
    end
    local file = io.open("./nftData.csv", "w+")
    file:write("type,pid,level,chainId,quality,walletAddress\n")
    for i, v in ipairs(data or {}) do
        local fields = {}
        table.insert(fields, v.type)
        table.insert(fields, v.pid)
        table.insert(fields, v.level)
        table.insert(fields, v.chainId)
        table.insert(fields, v.quality)
        table.insert(fields, v.walletAddress)
        file:write(table.concat(fields, ",") .. "\n")
    end
    file:close()
end

function analyzermgr.getLeagueMatchRankList(cfgId, chainIndex)
    local result = {}
    local matchCfgs = gg.shareProxy:call("getDynamicCfg", "MatchConfig")
    if not matchCfgs then
        return false, "matchCfgs is not exist"
    end
    local cfg
    for k, v in pairs(matchCfgs) do
        if v.cfgId == cfgId then
            cfg = v
            break
        end
    end
    if not cfg then
        return false, "match config is not exist"
    end
    result.cfgId = cfg.cfgId
    result.belong = cfg.belong
    result.matchType = cfg.matchType
    result.name = cfg.name
    local matchdoc = gg.mongoProxy.match:findOne({ cfgId = cfg.cfgId })
    if not matchdoc then
        return false, "match doc is not exist"
    end
    local maxVer = 0
    local maxData
    for k, v in pairs(matchdoc.rankVersions or {}) do
        if v.ver > maxVer then
            maxVer = v.ver
            maxData = v
        end
    end
    if not maxData then
        return false, "rankVersions data is not exist"
    end
    result.rankList = {}
    if result.belong == 1 then--union
        if not chainIndex then
            return false, "union rank need chainIndex"
        end
        local rankMembers
        if not maxData.chainRankData or chainIndex == 0 then
            rankMembers = maxData.rankMembers
        else
            rankMembers = maxData.chainRankData[tostring(chainIndex)] or {}
        end
        for i, v in ipairs(rankMembers) do
            local info = {
                rank = i,
                unionId = v.unionId,
                unionName = v.unionName,
                score = v.score,
            }
            table.insert(result.rankList, info)
        end
        result.chainIndex = chainIndex
    elseif result.belong == 2 then--pvp
        for i, v in ipairs(maxData.rankMembers) do
            local info = {
                rank = i,
                playerId = v.playerId,
                unionName = v.unionName,
                playerScore = v.playerScore,
                playerLevel = v.playerLevel,
                playerName = v.playerName,
            }
            table.insert(result.rankList, info)
        end
    end
    
    return true, result
end

function analyzermgr.getPVPRankRealTimeData(count)
    local result = {}
    local pidDict = {}
    local from = 0
    local to = count - 1
    local list = gg.shareProxy:call("getPvpMatchRankList", from, to)
    for rank, data in ipairs(list) do
        if data.score > 0 then
            pidDict[data.pid] = {
                rank = rank,
                score = data.score,
            }
        end
    end
    local stageData = {}
    local stageRatio = gg.shareProxy:call("getDynamicCfg", constant.REDIS_PVP_STAGE_RATIO)
    for i = 1, #stageRatio, 1 do
        local psr = stageRatio[i]
        local scoreList = psr.score
        stageData[i] = {
            plyStage = tonumber(psr.stage),
            plyRatio = tonumber(psr.ratio),
            minScore = tonumber(scoreList[1]),
            maxScore = tonumber(scoreList[#scoreList]),
        }
    end
    
    for k, v in pairs(stageData) do
        local stageCount = {}
        local stageList = {}
        for kk, vv in pairs(pidDict) do
            if vv.score >= v.minScore and vv.score <= v.maxScore then
                stageCount[v.plyStage] = (stageCount[v.plyStage] or 0) + 1
                table.insert(stageList, {
                    rank = vv.rank,
                    pid = kk,
                })
            end
        end
        table.sort(stageList, function (a, b) 
            return a.rank < b.rank
        end)
        table.insert(result, {
            stage = v.plyStage,
            count = stageCount[v.plyStage],
            list = stageList,
        })
    end
    return result
end

function analyzermgr.getPlayerResRankList(sortKey, count)
    local result = {}
    result.rankCount = 0
    result.rows = {}
    local pipeline = {
        {
            ["$match"] = {
            }
        },
        {
            ["$project"] = {
                _id = 0,
                account = "$account",
                pid = "$pid",
                name = "$name",
                baseLevel = "$baseLevel",
                mit = "$mit",
                starCoin = "$starCoin",
                ice = "$ice",
                carboxyl = "$carboxyl",
                titanium = "$titanium",
                gas = "$gas",
                tesseract = "$tesseract",
                totalGameTime = "$totalGameTime",
                pvpRank = "$pvpRank",
                ip = "$ip",
            }
        },
        {
            ["$sort"] = {
                [sortKey] = -1,
            }
        },
        {
            ["$limit"] = count,
        },
    }
    local ret = gg.mongoProxy.gamelogdb:runCommand("aggregate", "online_players", "pipeline", pipeline, "cursor", {})
    if not ret or not ret.cursor or not next(ret.cursor.firstBatch) then
        return result
    end
    for k, v in pairs(ret.cursor.firstBatch) do
        table.insert(result.rows, v)
    end
    result.rankCount = table.count(result.rows)
    return result
end

--""
function analyzermgr.getWhiteLevelTwoDict()
    local data = gg.redisProxy:call("zrangebyscore", constant.REDIS_WHITELIST, 2, 2)
    local whiteDict = {}
    for k, v in pairs(data) do
        local playerInfo = gg.mongoProxy.online_players:findOne({account = v},{ _id = false, pid = true, account = true })
        if playerInfo then
            whiteDict[playerInfo.pid] = playerInfo.account
        end 
    end
    return whiteDict
end

--""
function analyzermgr.getWhiteLevelTwoList()
    local data = gg.redisProxy:call("zrangebyscore", constant.REDIS_WHITELIST, 2, 2)
    local whiteList = {}
    for k, v in pairs(data) do
        local playerInfo = gg.mongoProxy.online_players:findOne({account = v},{ _id = false, pid = true, account = true })
        if playerInfo then
            table.insert(whiteList, playerInfo.pid)
        end 
    end
    return whiteList
end

--""
function analyzermgr.isThirdAddress(address)
    local addressDict = {}
    addressDict[string.lower("0x5Ab11cA2124DEE2f8Ba90688B77af585bB31c03f")] = true

    return addressDict[address]
end