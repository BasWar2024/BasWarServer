---
--@module api.account.register
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/register
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      account     [required] type=string help=
--      passwd      [requried] type=string help=(md5)
--      sdk         [required] type=string help=SDK
--      platform    [required] type=string help=
--      device      [required] type=table encode=json help=(login.protoDeviceType)
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=number help=
--      data = {
--              account =   [optional] type=string help=
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/register' -d '{"sign":"debug","appid":"gg","account":"lgl","passwd":"1","sdk":"local","platform":"local"}'


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

    if #passwd == 0 then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PASSWD_FMT_ERR))
        return
    end

    local accountobj = accountmgr.getaccount(account)
    if accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_EXIST))
        return
    end
    local code = accountmgr.addaccount({
        account = account,
        passwd = passwd,
        sdk = sdk,
        openid = account,
        platform = platform,
        device = device,
    })
    local response = httpc.answer.response(code)
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
