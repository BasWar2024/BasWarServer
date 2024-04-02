---""+""
--@module api.account.login
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/login
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      account     [required] type=string help="",""openid
--      passwd      [required] type=string help="",""token
--      platform    [required] type=string help=""
--      sdk         [required] type=string help=""sdk
--      device      [required] type=json help=""(""login.proto""DeviceType)
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--          token =     [required] type=string help=""TOKEN
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/login' -d '{"sign":"debug","appid":"gg","account":"lgl","passwd":"1","platform":"local","sdk":"sdk","device":"{}"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        account = {type="string"},
        passwd = {type="string"},
        platform = {type="string"},
        sdk = {type="string"},
        device = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account
    local passwd = request.passwd
    local platform = request.platform
    local sdk = request.sdk
    local device = request.device
    account = string.lower(account)
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
    local openid = account
    local accountobj = nil
    local validPlatform = constant.getValidPlatform()
    if validPlatform[platform] then
        accountobj = accountmgr.getaccount(account)
        if not accountobj then
            httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
            return
        end
        local ret, pwdWrongTimes = gg.shareProxy:call("checkWrongTimes", constant.WRONG_TYPE_LOGIN, account)
        if not ret then
            httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.WRONG_TIMES_ERR))
            return
        end
        if passwd ~= accountobj.passwd then
            gg.shareProxy:call("setWrongTimes", constant.WRONG_TYPE_LOGIN, account, true)
            local ret, pwdWrongTimes = gg.shareProxy:call("checkWrongTimes", constant.WRONG_TYPE_LOGIN, account)
            local response = httpc.answer.response(httpc.answer.code.PASSWD_NOMATCH)
            response.message = string.format(response.message, pwdWrongTimes, 5-pwdWrongTimes)
            response.data = {pwdWrongTimes = pwdWrongTimes}
            httpc.send_json(linkobj, 200, response)
            return
        end
        gg.shareProxy:call("setWrongTimes", constant.WRONG_TYPE_LOGIN, account, false)
    else
        --[[
        account = string.format("%s@%s",openid,platform)
        local platform_token = passwd
        local accountobj = accountmgr.getaccount(account)
        if not accountobj then
            accountobj = {
                account = account,
                passwd = "1",
                sdk = sdk,
                openid = openid,
                platform = platform,
                device = device,
            }
            accountmgr.addaccount(accountobj)
        end
        ]]
        --error("invalid platform: " .. tostring(platform))
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.UNSUPPORT_PLATFORM))
        return
    end
    local result, reason = gg.shareProxy:call("checkWhiteList", account)
    if not result then
        httpc.send_json(linkobj,200,httpc.answer.response(reason))
        return
    end
    local token = accountmgr.gentoken()
    local data = {
        token = token,
        account = account,
    }
    accountmgr.addtoken(token,data)

    local accountData = {}
    local _openid = accountobj.openid
    if not accountobj.openid then
        accountData.openid = account
        _openid = accountData.openid
    end
    local _sdk = accountobj.sdk
    if not accountobj.sdk then
        accountData.sdk = sdk
        _sdk = accountData.sdk
    end
    local _platform = accountobj.platform
    if not accountobj.platform then
        accountData.platform = platform
        _platform = accountData.platform
    end
    local _device = accountobj.device
    if not accountobj.device then
        accountData.device = device
        _device = accountData.device
    end
    local _firstTime = accountobj.firstTime
    if not accountobj.firstTime then
        accountData.firstTime = os.time()
    end
    local _inviteCode = accountobj.inviteCode
    local _fatherInviteCode = accountobj.fatherInviteCode
    if not accountobj.createTime and accountobj.create_time then
        accountData.createTime = math.floor((accountobj.create_time or 0) / 1000)
    end
    if next(accountData) then
        accountData.account = account
        accountmgr.saveaccount(accountData)
    end

    if not _firstTime then
        gg.internal:call(".gamelog", "api", "addActiveAccountLog", account, _openid, _platform, _device, _sdk, _inviteCode, _fatherInviteCode) 
    end

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = data
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
