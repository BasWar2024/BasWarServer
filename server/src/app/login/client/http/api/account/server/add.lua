---""
--@module api.account.server.add
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/server/add
--protocol: http/https
--method: post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      serverid    [required] type=string help=""ID
--      server      [required] type=table encode=json help=""
--                  server = {
--                      //id =              [required] type=string help=""ID
--                      ip =                [required] type=string help=ip
--                      tcp_port =          [required] type=number help=tcp""
--                      kcp_port =          [required] type=number help=kcp""
--                      websocket_port =    [required] type=number help=websocket""
--                      debug_port =        [required] type=number help=debug""
--                      name =              [required] type=string help=""
--                      type =              [required] type=string help=""
--                      zoneid =            [required] type=string help=""ID
--                      zonename =          [required] type=string help=""
--                      clusterid =         [required] type=string help=""id
--                      clustername =       [required] type=string help=""
--                      env =               [required] type=string help=""ID
--                      envname =           [required] type=string help=""("","","")
--                      opentime =          [required] type=number help=""("",""<=7"")
--                      is_open =           [optional] type=number default=1 help=""(is_open==0"")
--                      busyness =          [optional] type=number default=0.0 help=""(is_down==0"",""：[0,0.7),"":[0.7,1),"":[1,max))
--                      is_new =            [optional] type=number default=0 help=""(1="")
--                      is_down =           [optional] type=number default=0 help=""(1="")
--                  }
--  }
--return:
--  type=table encode=json
--  {
--      code =      [requied] type=number help=""
--      message =   [required] type=string help=""
--  }
--example:
-- curl -v 'http://127.0.0.1:4000/api/account/server/add' -d '{"appid": "appid","serverid": "game1", "sign": "debug", "server": "{\"zoneid\": \"dev1\", \"opentime\": 1536659100, \"name\": \"""1""\", \"clusterid\": \"alpha\", \"kcp_port\": 8889, \"ip\": \"127.0.0.1\", \"websocket_port\": 8890, \"envname\": \"""\", \"env\": \"alpha\", \"tcp_port\": 8888, \"debug_port\": 18888, \"type\": \"gameserver\", \"id\": \"game1\", \"index\": 1,\"clustername\": \"""\", \"zonename\": \"""1""\"}"}'


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
    local serverid = request.serverid
    local server = request.server
    local app = util.get_app(appid)
    if not app then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.APPID_NOEXIST))
        return
    end
    
    local appkey = skynet.getenv("appkey")
    if not httpc.check_signature(args.sign,args,appkey) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    server.id = serverid
    local code,err = servermgr.addserver(appid,server)
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
