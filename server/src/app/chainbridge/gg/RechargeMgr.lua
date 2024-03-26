local RechargeMgr = class("RechargeMgr")

local bson = require "bson"

local startDealInterval = 5                        --""

local checkRechargeTokenInterval = 5               --""Token""
local checkRechargeTokenCnt = 300                  --""Token""

local checkRechargeNFTInterval = 5                 --""NFT""
local checkRechargeNFTCnt = 300                    --""NFT""

local checkPayOrderInterval = 5                 --""
local checkPayOrderCnt = 300                    --"" 

function RechargeMgr:ctor()
    self.startDealTick = nil                     --""
    self.nextDealRechargeTokenTick = nil         --""Token""
    self.nextDealRechargeNFTTick = nil           --""NFT""
    self.nextDealPayOrderTick = nil              --""
end

function RechargeMgr:rechargeToken(params)
    gg.mongoProxy.rechargeToken:insert(params)
end

function RechargeMgr:rechargeNFT(params)
    gg.mongoProxy.rechargeNft:insert(params)
end

function RechargeMgr:onSecond()
    if not self.startDealTick then
        self.startDealTick = math.floor(skynet.timestamp() / 1000) + startDealInterval
        return
    end
    local nowTick = math.floor(skynet.timestamp() / 1000)
    if nowTick < self.startDealTick then
        return
    end
    self:checkRechargeToken()
    self:checkRechargeNFT()
    self:checkPayOrder()
end

function RechargeMgr:checkRechargeToken()
    local now = skynet.timestamp()
    local nowTick = math.floor(now / 1000)
    if not self.nextDealRechargeTokenTick or nowTick > self.nextDealRechargeTokenTick then
        self.nextDealRechargeTokenTick = nowTick + checkRechargeTokenInterval

        --""
        local validOrderList = {}
        local docs = gg.mongoProxy.rechargeToken:findSortLimit({state = constant.CHAIN_BRIDGE_RECHARGE_STATE_CONFIRM}, {create_time = 1}, checkRechargeTokenCnt)
        if #docs > 0 then
            for _, data in pairs(docs) do
                data._id = nil
                local createTime = math.floor((data.create_time or 0) / 1000)
                local dayno = gg.time.dayno(createTime)
                local weekno = gg.time.weekno(createTime)
                local monthno = gg.time.monthno(createTime)
                if not data.owner_mail or not data.pid then
                    local result = gg.shareProxy:call("getAccountByWalletAddress", data.from_address)
                    if not result then
                        gg.mongoProxy.rechargeToken:update({order_num = data.order_num}, {["$set"] = {state = constant.CHAIN_BRIDGE_RECHARGE_STATE_ERROR, message = constant.CHAIN_BRIDGE_RECHARGE_DES_ERROR_NO_ACCOUNT, update_time = now, dayno = dayno, weekno = weekno, monthno = monthno, createTime = bson.date(createTime), createDate = tonumber(os.date("%Y%m%d", createTime)) }})
                    elseif tonumber(result.chainId) ~= tonumber(data.chain_id) then
                        gg.mongoProxy.rechargeToken:update({order_num = data.order_num}, {["$set"] = {state = constant.CHAIN_BRIDGE_RECHARGE_STATE_ERROR, message = constant.CHAIN_BRIDGE_RECHARGE_DES_ERROR_DIFFERENT_CHAIN, update_time = now, dayno = dayno, weekno = weekno, monthno = monthno, createTime = bson.date(createTime), createDate = tonumber(os.date("%Y%m%d", createTime)) }})
                    else
                        data.owner_mail = result.accountMail
                        data.pid = result.pid
                        data.platform = result.platform
                        gg.mongoProxy.rechargeToken:update({order_num = data.order_num}, {["$set"] = {platform = result.platform, owner_mail = result.accountMail, pid = result.pid, update_time = now, dayno = dayno, weekno = weekno, monthno = monthno, createTime = bson.date(createTime), createDate = tonumber(os.date("%Y%m%d", createTime)) }})
                        table.insert(validOrderList, data)
                    end
                else
                    table.insert(validOrderList, data)
                end
            end
        end

        if next(validOrderList) then
            for _, data in pairs(validOrderList) do
                gg.playerProxy:send(data.pid, "dealRechargeToken", data)
            end
        end
    end
end

function RechargeMgr:rechargeTokenFinish(order_num)
    local now = skynet.timestamp()
    gg.mongoProxy.rechargeToken:update({order_num = order_num}, {["$set"] = {state = constant.CHAIN_BRIDGE_RECHARGE_STATE_SUCCESS, message = constant.CHAIN_BRIDGE_RECHARGE_DES_SUCCESS, update_time = now}})
end

function RechargeMgr:checkRechargeNFT()
    local now = skynet.timestamp()
    local nowTick = math.floor(now / 1000)
    if not self.nextDealRechargeNFTTick or nowTick > self.nextDealRechargeNFTTick then
        self.nextDealRechargeNFTTick = nowTick + checkRechargeNFTInterval

        --""
        local validOrderList = {}
        local docs = gg.mongoProxy.rechargeNft:findSortLimit({state = constant.CHAIN_BRIDGE_RECHARGE_STATE_CONFIRM}, {create_time = 1}, checkRechargeNFTCnt)
        if #docs > 0 then
            for _, data in pairs(docs) do
                data._id = nil
                local createTime = math.floor((data.create_time or 0) / 1000)
                local dayno = gg.time.dayno(createTime)
                local weekno = gg.time.weekno(createTime)
                local monthno = gg.time.monthno(createTime)
                if not data.owner_mail or not data.pid then
                    local result = gg.shareProxy:call("getAccountByWalletAddress", data.from_address)
                    if not result then
                        gg.mongoProxy.rechargeNft:update({order_num = data.order_num}, {["$set"] = {state = constant.CHAIN_BRIDGE_RECHARGE_STATE_ERROR, message = constant.CHAIN_BRIDGE_RECHARGE_DES_ERROR_NO_ACCOUNT, update_time = now, dayno = dayno, weekno = weekno, monthno = monthno, createTime = bson.date(createTime), createDate = tonumber(os.date("%Y%m%d", createTime)) }})
                    elseif tonumber(result.chainId) ~= tonumber(data.chain_id) then
                        gg.mongoProxy.rechargeNft:update({order_num = data.order_num}, {["$set"] = {state = constant.CHAIN_BRIDGE_RECHARGE_STATE_ERROR, message = constant.CHAIN_BRIDGE_RECHARGE_DES_ERROR_DIFFERENT_CHAIN, update_time = now, dayno = dayno, weekno = weekno, monthno = monthno, createTime = bson.date(createTime), createDate = tonumber(os.date("%Y%m%d", createTime)) }})
                    else
                        data.owner_mail = result.accountMail
                        data.pid = result.pid
                        data.platform = result.platform
                        gg.mongoProxy.rechargeNft:update({order_num = data.order_num}, {["$set"] = {platform = result.platform, owner_mail = result.accountMail, pid = result.pid, update_time = now, dayno = dayno, weekno = weekno, monthno = monthno, createTime = bson.date(createTime), createDate = tonumber(os.date("%Y%m%d", createTime)) }})
                        table.insert(validOrderList, data)
                    end
                else
                    table.insert(validOrderList, data)
                end
            end
        end

        if next(validOrderList) then
            for _, data in pairs(validOrderList) do
                gg.playerProxy:send(data.pid, "dealRechargeNFT", data)
            end
        end
    end
end

function RechargeMgr:rechargeNFTFinish(order_num, success_ids, fail_ids)
    local now = skynet.timestamp()
    gg.mongoProxy.rechargeNft:update({order_num = order_num}, {["$set"] = {state = constant.CHAIN_BRIDGE_RECHARGE_STATE_SUCCESS, message = constant.CHAIN_BRIDGE_RECHARGE_DES_SUCCESS, update_time = now, success_ids = success_ids, fail_ids = fail_ids}})
end

function RechargeMgr:checkPayOrder()
    local now = skynet.timestamp()
    local nowTick = math.floor(now / 1000)
    if not self.nextDealPayOrderTick or nowTick > self.nextDealPayOrderTick then
        self.nextDealPayOrderTick = nowTick + checkPayOrderInterval

        --""
        local validOrderList = {}
        local docs = gg.mongoProxy.order_settle:findSortLimit({state = constant.PAY_STATE_1}, {createTime = 1}, checkPayOrderCnt)
        if #docs > 0 then
            for _, data in pairs(docs) do
                data._id = nil
                data.tryCnt = (data.tryCnt or 0) + 1
                gg.mongoProxy.order_settle:update({orderId = data.orderId}, {["$set"] = {tryCnt = data.tryCnt, updateOrderTime = nowTick}})
                table.insert(validOrderList, data)
            end
        end

        if next(validOrderList) then
            for _, data in pairs(validOrderList) do
                gg.playerProxy:send(data.pid, "dealPayOrder", data)
            end
        end
    end
end

function RechargeMgr:payOrderFinish(orderId)
    local now = skynet.timestamp()
    local nowTick = math.floor(now / 1000)
    gg.mongoProxy.order_settle:update({orderId = orderId}, {["$set"] = {state = constant.PAY_STATE_2, updateOrderTime = nowTick}})
    gg.mongoProxy.order_ready:update({orderId = orderId}, {["$set"] = {state = constant.PAY_STATE_2, updateOrderTime = nowTick}})
end

return RechargeMgr