---
--@module api.account.server.update
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/server/update
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      serverid    [required] type=string help=ID
--      server      [required] type=table encode=json help=
--                  server={
--                      ip =                [optional] type=string help=ip
--                      tcp_port =          [optional] type=number help=tcp
--                      kcp_port =          [optional] type=number help=kcp
--                      websocket_port =    [optional] type=number help=websocket
--                      debug_port =        [optional] type=number help=debug
--                      name =              [optional] type=string help=
--                      type =              [optional] type=string help=
--                      zoneid =            [optional] type=string help=ID
--                      zonename =          [optional] type=string help=
--                      clusterid =         [optional] type=string help=id
--                      clustername =       [optional] type=string help=
--                      opentime =          [optional] type=number help=
--                      is_open =           [optional] type=number default=1 help=
--                      busyness =          [optional] type=number default=0.0 help=
--                  }
--  }
--return:
--  type=table encode=json
--  {
--      code =      [requied] type=number help=
--      message =   [required] type=string help=
--  }
--example:
-- curl -v 'http://127.0.0.1:4000/api/account/server/update' -d '{"appid": "appid","serverid": "game1", "sign": "debug", "server": "{\"kcp_port\": 8889,\"websocket_port\": 8890,\"tcp_port\": 8888}"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        serverid = {type="string"},
        server = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account
    local serverid = request.serverid
    local server = request.server
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
    server.id = serverid
    server.updatetime = os.time()
    local code = servermgr.updateserver(appid,server)
    local response = httpc.answer.response(code)
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
