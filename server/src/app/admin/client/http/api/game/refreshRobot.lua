---""
--@module api.game.createRobot
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/game/refreshRobot
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      pid              [required] type=number help=""ID    
--      sign             [required] type=string help=""
--      gm               [required] type=number help=gm""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=string help=""
--      data = {
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/game/refreshRobot' -d '{ "gm" : 1, "adminAccount":"admin", "sign":"debug" }'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        gm = {type="number"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    
    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE1) then
        return
    end
    
    local gm = request.gm
    gamemgr.refreshRobot(gm)

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = "Success"
    httpc.send_json(linkobj, 200, response)
end

function handler.POST(linkobj,header,query,body)
    local args = {}
    if body and body ~= "" then
        args = cjson.decode(body)
    end
    handler.exec(linkobj,header,args)
end

function handler.GET(linkobj,header,query,body)
    local args = {}
    if query and query ~= "" then
        local param = urllib.parse_query(query)
        table.update(args, param)
    end
    handler.exec(linkobj,header, args)
end

function __hotfix(module)
    gg.client:open()
end

return handler