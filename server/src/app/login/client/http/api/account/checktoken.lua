---TOKEN""
--@module api.account.checktoken
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/checktoken
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      account     [required] type=string help=""
--      token       [required] type=string help=""TOKEN
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/checktoken' -d '{"appid":"gg","account":"lgl","token":"0de3595c4666e9ce8c5b64534d811460","sign":"debug"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        account = {type="string"},
        token = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account
    local token = request.token
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
    local data = accountmgr.gettoken(token)
    if not data then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.TOKEN_TIMEOUT))
        return
    end
    if data.account ~= account then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.TOKEN_UNAUTH))
        return
    end
    local accountobj = accountmgr.getaccount(account)

    local response = httpc.answer.response(httpc.answer.code.OK)
    httpc.send_json(linkobj,200,response)
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
