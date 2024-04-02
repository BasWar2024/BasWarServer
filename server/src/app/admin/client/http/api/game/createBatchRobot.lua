---""
--@module api.game.createBatchRobot
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/game/createBatchRobot
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign             [required] type=string help=""
--      cfgId            [required] type=number help=""ID    
--      count            [required] type=number help=""
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
--  curl -v 'http://127.0.0.1:4241/api/game/createBatchRobot' -d '{ "cfgId":1, "count":900, "adminAccount":"admin", "sign":"debug" }'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        cfgId = {type="number"},
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
    
    local cfgId = request.cfgId or 1
    local count = request.count or 1
    local robotInfos = gamemgr.createBatchRobot(cfgId, count)

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = robotInfos
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