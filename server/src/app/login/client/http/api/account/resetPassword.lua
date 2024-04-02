---""
--@module api.account.resetPassword
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/resetPassword
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      account     [required] type=string help=""
--      passwd      [requried] type=string help=""(md5"")
--      verifyCode  [required] type=string help=""
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
--  curl -v 'http://127.0.0.1:4000/api/account/resetPassword' -d '{"sign":"debug","appid":"gg","account":"lgl","passwd":"1","verifyCode":"112233","sdk":"local","platform":"local"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        account = {type="string"},
        passwd = {type="string"},
        verifyCode = {type="string"},
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
    local verifyCode = request.verifyCode
    local sdk = request.sdk
    local platform = request.platform
    local device = request.device
    local app = util.get_app(appid)
    account = string.trim(account)
    verifyCode = string.trim(verifyCode)
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
    local ret, curTimes = gg.shareProxy:call("checkWrongTimes", constant.WRONG_TYPE_VERIFYCODE, account)
    if not ret then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.WRONG_TIMES_ERR))
        return
    end
    local ret = gg.shareProxy:call("checkVerifyCode", account, verifyCode)
    if not ret then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.VERIFY_CODE_ERR))
        gg.shareProxy:call("setWrongTimes", constant.WRONG_TYPE_VERIFYCODE, account, true)
        return
    end
    gg.shareProxy:call("setWrongTimes", constant.WRONG_TYPE_VERIFYCODE, account, false)
    local accountobj = accountmgr.getaccount(account)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    gg.shareProxy:call("setWrongTimes", constant.WRONG_TYPE_LOGIN, account, false)
    local ret, curTimes = gg.shareProxy:call("checkWrongTimes", constant.WRONG_TYPE_VERIFYCODE, account)
    accountmgr.updatepasswd(account, passwd)
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
