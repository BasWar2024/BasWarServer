---""
--@module api.account.sendCode
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/sendCode
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      account     [required] type=string help=""
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
--          account =   [optional] type=string help=""
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/sendCode' -d '{"sign":"debug","appid":"gg","account":"xxx@gmail.com","platform":"local","sdk":"sdk","device":{}}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        platform = {type="string"},
        sdk = {type="string"},
        device = {type="json"},
        account = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account
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

    if not account or not string.checkEmail(account) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_FMT_ERR))
        return
    end

    local ret, response = gg.shareProxy:call("sendMailVerification", account)
    if ret ~= 200 then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.NETWOEK_ERR))
        return
    end

    local args = cjson.decode(response)
    if args.error ~= "0" then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end

    local data = {
        account = account,
    }
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
