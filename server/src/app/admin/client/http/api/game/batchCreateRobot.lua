---""
--@module api.game.batchCreateRobot
--@author sw
--@release 2022/7/14 15:10:00
--@usage
--api:      /api/game/batchCreateRobot
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign          [required] type=string help=""
--      gm            [required] type=number help=""gm""    
--      count         [required] type=number help=""
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
--  curl -v 'http://127.0.0.1:4241/api/game/batchCreateRobot' -d '{"gm" : 2, "count" : 20,"adminAccount":"admin", "sign":"debug"  }'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        gm = {type="number"},
        count = {type="number"},
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
    local count = request.count
    local robotList = gamemgr.batchCreateRobot(gm, count)

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = robotList
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