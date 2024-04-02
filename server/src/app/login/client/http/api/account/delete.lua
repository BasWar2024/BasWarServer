---""
--@module api.account.delete
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/delete
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      account     [required] type=string help=""
--      passwd      [requried] type=string help=""(md5"")
--      sdk         [required] type=string help=""SDK
--      platform    [required] type=string help=""
--      device      [required] type=table encode=json help=""(""login.proto""DeviceType)
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--              account =   [optional] type=string help=""
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/delete' -d '{"sign":"debug","appid":"gg","account":"lgl","passwd":"1","sdk":"local","platform":"local"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        account = {type="string"},
        passwd = {type="string"},
        sdk = {type="string"},
        platform = {type="string"},
        device = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account or ''
    local passwd = request.passwd
    local sdk = request.sdk
    local platform = request.platform
    local device = request.device

    account = string.trim(account)

    local app = util.get_app(appid)
    if not app then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.APPID_NOEXIST))
        return
    end
    local appkey = app.appkey
    if not httpc.check_signature(args.sign,args,appkey) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    if not string.checkEmail(account) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_FMT_ERR))
        return
    end
    if #account < constant.ACCOUNT_MIN_LEN or #account > constant.ACCOUNT_MAX_LEN then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_FMT_ERR))
        return
    end
    if #passwd < constant.PASSWD_MIN_LEN or #passwd > constant.PASSWD_MAX_LEN then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PASSWD_FMT_ERR))
        return
    end
    local accountobj = accountmgr.getaccount(account)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    if passwd ~= accountobj.passwd then
        local response = httpc.answer.response(httpc.answer.code.PASSWD_NOMATCH)
        response.message = "password error"
        httpc.send_json(linkobj, 200, response)
        return
    end

    --""
    local tempAccount = "(" .. account .. ")" .. "_" .. accountobj.accountid
    gg.mongoProxy.account:update({ account = account },{["$unset"] = {chain_id=true, owner_address=true}},false,true)
    gg.mongoProxy.account:update({ account = account },{["$set"] = {account=tempAccount, openid=tempAccount, oldAccount = account, delTime = os.time()}},false,true)
    gg.mongoProxy.inviteAccount:update({ account = account },{["$set"] = {account=tempAccount}},false,true)
    gg.mongoProxy.inviteAccount:update({ fatherAccount = account },{["$set"] = {fatherAccount=tempAccount}},false,true)

    gg.mongoProxy.account_roles:update({ account = account },{["$set"] = {account=tempAccount}},false,true)
    gg.mongoProxy.role:update({ account = account },{["$set"] = {account=tempAccount}},false,true)

    gg.mongoProxy.active_account_log:update({ account = account },{["$set"] = {account=tempAccount, openid=tempAccount}},false,true)
    gg.mongoProxy.register_account_log:update({ account = account },{["$set"] = {account=tempAccount}},false,true)

    --""token

    --"",""
    if accountobj.roleid then
        gg.playerProxy:call(accountobj.roleid, "kickPlayer", "DelAccount")
    end

    --""redis""
    gg.shareProxy:call("delWalletInfo", account, accountobj.owner_address)

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = {
        account = account,
    }
    httpc.send_json(linkobj,200,response)
    return
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
