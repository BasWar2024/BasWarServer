local WithdrawMgr = class("WithdrawMgr")

function WithdrawMgr:ctor()

end

function WithdrawMgr:getWithdrawTokenInfo(order_num)
    local doc = gg.mongoProxy.withdrawToken:findOne({order_num=order_num})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

function WithdrawMgr:dealWithdrawToken(order_num, state, message)
    local orderInfo = self:getWithdrawTokenInfo(order_num)
    if not orderInfo then
        return
    end

    if orderInfo.state == constant.CHAIN_BRIDGE_WITHDRAW_STATE_WAITING and state == constant.CHAIN_BRIDGE_WITHDRAW_STATE_ERROR and message == constant.CHAIN_BRIDGE_WITHDRAW_DES_ERROR_REJECT then
        --"",""
        gg.playerProxy:call(orderInfo.pid, "backWithdrawToken", orderInfo)
    end

    local now = skynet.timestamp()
    gg.mongoProxy.withdrawToken:update({order_num = order_num}, {["$set"] = {state = state, message = message, update_time = now}})
end

return WithdrawMgr