---""
--@module adminaccountmgr
--@usage
--mongo""
--"": adminAccount => {adminAccount=xxx,adminPassword=xxx,...}

adminaccountmgr = adminaccountmgr or {}

function adminaccountmgr.initialadminaccount()
    local adminAccount = "admin"
    local accountobj = adminaccountmgr.getadminaccount(adminAccount)
    if accountobj then
        return
    end
    local accountobj = {}
    accountobj.adminAccount = adminAccount
    accountobj.adminPassword = string.lower(md5.sumhexa("123456"))
    accountobj.authority = constant.ADMIN_AUTHORITY_ROOT
    adminaccountmgr.addadminaccount(accountobj)
end

function adminaccountmgr.saveadminaccount(accountobj)
    local adminAccount = assert(accountobj.adminAccount)
    gg.mongoProxy.adminaccount:update({adminAccount=adminAccount},accountobj,true,false)
end

function adminaccountmgr.getadminaccount(adminAccount)
    local doc = gg.mongoProxy.adminaccount:findOne({adminAccount=adminAccount})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

--/*
-- accountobj: {adminAccount="",adminPassword="",...}
--*/
function adminaccountmgr.addadminaccount(accountobj)
    local adminAccount = assert(accountobj.adminAccount)
    local has_accountobj = adminaccountmgr.getadminaccount(adminAccount)
    if has_accountobj then
        return httpc.answer.code.ACCT_EXIST
    end
    accountobj.createTime = os.time()
    logger.logf("info","adminaccount",string.format("op=addadminaccount,accountobj=%s",cjson.encode(accountobj)))
    adminaccountmgr.saveadminaccount(accountobj)
    return httpc.answer.code.OK
end

function adminaccountmgr.deladminaccount(adminAccount)
    local accountobj = adminaccountmgr.getadminaccount(adminAccount)
    if accountobj then
        logger.logf("info","adminaccount",string.format("op=deladminaccount,adminAccount=%s",adminAccount))
        gg.mongoProxy.adminaccount:delete({adminAccount=adminAccount})
        return httpc.answer.code.OK
    end
    return httpc.answer.code.ACCT_NOEXIST
end

function adminaccountmgr.gentoken()
    local token = string.randomkey(32)
    return token
end

function adminaccountmgr.settoken(adminAccount, token)
    local keyName = constant.REDIS_ADMIN_ACCOUNT_TOKEN .. adminAccount
    gg.redisProxy:send("set", keyName, token)
    gg.redisProxy:send("expire", keyName, 1800)
end

function adminaccountmgr.gettoken(adminAccount)
    local keyName = constant.REDIS_ADMIN_ACCOUNT_TOKEN .. adminAccount
    return gg.redisProxy:call("get", keyName)
end

function adminaccountmgr.deltoken(adminAccount)
    local keyName = constant.REDIS_ADMIN_ACCOUNT_TOKEN .. adminAccount
    gg.redisProxy:send("del", keyName)
end

return adminaccountmgr
