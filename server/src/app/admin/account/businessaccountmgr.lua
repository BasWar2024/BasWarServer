---""
--@module businessaccountmgr
--@usage
--""

businessaccountmgr = businessaccountmgr or {}

function businessaccountmgr.getbusinessaccount(businessAccount)
    local doc = gg.mongoProxy.account:findOne({account=businessAccount})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

function businessaccountmgr.getallinviteaccount(pageNo, pageSize, account)
    local result = {}
    result.pageNo = pageNo
    result.pageSize = pageSize
    result.totalRows = gg.mongoProxy.inviteAccount:findCount({account = account, business = 1})
    result.totalPage = math.ceil(result.totalRows / pageSize)
    result.rows = {}
    local list = {}
    local docs = gg.mongoProxy.inviteAccount:findSortSkipLimit({account = account, business = 1}, {timestamp = 1}, pageSize*(pageNo - 1), pageSize)
    for k, v in pairs(docs) do
        local info = {}
        info.account = v.account
        info.business = v.business
        info.PHONE = v.PHONE or ""
        info.DISCORD = v.DISCORD or ""
        info.TELEGRAM = v.TELEGRAM or ""
        info.PAYPAL = v.PAYPAL or ""
        info.ERC20 = v.ERC20 or ""
        info.TRC20 = v.TRC20 or ""
        info.BEP20 = v.BEP20 or ""
        table.insert(result.rows, info)
    end
    return result
end

function businessaccountmgr.getinviteaccount(account)
    local doc = gg.mongoProxy.inviteAccount:findOne({account=account})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

function businessaccountmgr.updateinviteaccount(account, data)
    gg.mongoProxy.inviteAccount:update({ account = account },{["$set"] = data},false,false)
end

function businessaccountmgr.gentoken(businessAccount)
    local token = string.randomkey(32)
    local keyName = constant.REDIS_BUSINESS_ACCOUNT_TOKEN .. businessAccount
    gg.redisProxy:send("set", keyName, token)
    gg.redisProxy:send("expire",keyName, 1800)
    return token
end

function businessaccountmgr.gettoken(businessAccount)
    local keyName = constant.REDIS_BUSINESS_ACCOUNT_TOKEN .. businessAccount
    return gg.redisProxy:call("get", keyName)
end

return businessaccountmgr