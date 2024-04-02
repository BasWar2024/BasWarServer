---""
--@module api.account.server.list
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/server/list
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      version     [required] type=string help=""
--      platform    [required] type=string help=""
--      account     [optional] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--          serverlist =    [required] type=list help="",""api/account/server/add
--          zonelist =      [required] type=list help=""
--          time =          [required] type=int help=""("")
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/server/list' -d '{"sign":"debug","appid":"gg","version":"0.0.1","platform":"local","account":"lgl"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        version = {type="string"},              -- ""
        platform = {type="string"},             -- ""
        account = {type="string",optional=true},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local version = request.version
    local platform = request.platform
    local account = request.account
    local ip = linkobj.ip
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
    local serverlist,zonelist = util.filter_serverlist(appid,version,ip,account,platform)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = {serverlist=serverlist,zonelist=zonelist,time=os.time()}
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
