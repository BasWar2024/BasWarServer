local BridgeMgr = class("BridgeMgr")

function BridgeMgr:ctor()

end

function BridgeMgr:initial()
    gg.shareProxy:send("getChainBridgeInfo")
end

function BridgeMgr:bindWallet(params)
    local owner_address = params.owner_address
    local owner_mail = params.owner_mail
    local chain_id = params.chain_id
    local update_time = params.update_time
    if owner_address and owner_mail and update_time then
        gg.mongoProxy.account:update({ account = owner_mail },{["$set"] = { owner_address = owner_address, update_time = update_time, chain_id = chain_id } },false,false)
    end
end

function BridgeMgr:AddNFT(params)
    local curTokenId = 0
    local docs = gg.mongoProxy.nftInfo:findSortLimit({}, {token_id = -1}, 1)
    if #docs > 0 then
        local data = docs[1]
        local token_id = math.floor(data.token_id / 1000)
        curTokenId = token_id + 1
    else
        curTokenId = 1
    end
    curTokenId = curTokenId * 1000 + 2
    params.token_id = curTokenId
    gg.mongoProxy.nftInfo:insert(params)
    return params.token_id
end

return BridgeMgr