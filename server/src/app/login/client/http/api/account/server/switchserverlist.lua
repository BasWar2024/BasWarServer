---""AB""
--@module api.account.server.switchserverlist
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/server/switchserverlist
--protocol: http/https
--method: post
--params:
--  type=table encode=json
--  {
--      sign                [required] type=string help=""
--      appid               [required] type=string help=appid
--      serverlist_name     [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [requied] type=number help=""
--      message =   [required] type=string help=""
--  }
--example:
-- curl -v 'http://127.0.0.1:4000/api/account/server/switchserverlist' -d '{"appid": "appid","sign": "debug","serverlist_name": "server"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        serverlist_name = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
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
    local code,err = servermgr.switchserverlist(appid,args.serverlist_name)
    local response = httpc.answer.response(code)
    if err then
        response.message = string.format("%s|%s",response.message,err)
    end
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
