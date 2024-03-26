-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

function api.bindWallet(params)
    gg.bridgeMgr:bindWallet(params)
end

function api.AddNFT(params)
    return gg.bridgeMgr:AddNFT(params)
end

function api.rechargeToken(params)
    gg.rechargeMgr:rechargeToken(params)
end

function api.rechargeNFT(params)
    return gg.rechargeMgr:rechargeNFT(params)
end

function api.rechargeTokenFinish(order_num)
    gg.rechargeMgr:rechargeTokenFinish(order_num)
end

function api.rechargeNFTFinish(order_num, success_ids, fail_ids)
    gg.rechargeMgr:rechargeNFTFinish(order_num, success_ids, fail_ids)
end

function api.changeTokenWithdraw(params)
    gg.withdrawMgr:dealWithdrawToken(params.order_num, params.state, params.message)
end

function api.payOrderFinish(orderId)
    gg.rechargeMgr:payOrderFinish(orderId)
end

return api