---
--@module api.account.vistorLogin
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/vistorLogin
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      account     [required] type=string help=,
--      passwd      [required] type=string help=
--      platform    [required] type=string help=
--      sdk         [required] type=string help=sdk
--      device      [required] type=json help=(login.protoDeviceType)
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=number help=
--      data = {
--          token =     [required] type=string help=TOKEN
--          account =   [optional] type=string help=
--          passwd =   [optional] type=string help=
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/vistorLogin' -d '{"sign":"debug","appid":"gg","account":"random_1","passwd":"1","platform":"local","sdk":"sdk","device":{}}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
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
    if platform == "local" then
        if not account then
            account, passwd = accountmgr.genrandomaccount(appid,appid)
            accountmgr.addaccount({
                account = account,
                passwd = passwd,
                sdk = sdk,
                openid = account,
                platform = platform,
                device = device,
                isVistor = 1,
            })
        else
            local accountobj = accountmgr.getaccount(account)
            if not accountobj then
                httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
                return
            end
            if passwd ~= accountobj.passwd then
                httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PASSWD_NOMATCH))
                return
            end
            if not accountobj.isVistor then
                httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.NOT_A_TEMP_ACCOUNT))
                return
            end
        end
    else
        error("invalid platform: " .. tostring(platform))
    end
    local token = accountmgr.gentoken()
    local data = {
        token = token,
        account = account,
    }
    accountmgr.addtoken(token,data)
    local response = httpc.answer.response(httpc.answer.code.OK)
    data.passwd = passwd
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
