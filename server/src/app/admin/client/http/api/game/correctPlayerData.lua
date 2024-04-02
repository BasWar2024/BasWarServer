---""nft""
--@module api.game.correctPlayerData
--@author hyd
--@release 2023/6/1 10:30:00
--@usage
--api:      /api/game/correctPlayerData
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {    
--      adminAccount     [required] type=string help=""
--      sign             [required] type=string help=""
--      pid              [required] type=number help=""pid
--      kind             [required] type=number help="" 1|build，2|hero，3|warShip
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
--  curl -v 'http://127.0.0.1:4241/api/game/correctPlayerData' -d '{"adminAccount":"admin","sign":"e10adc3949ba59abbe56e057f20f883e",pid=1001755,kind=1}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        pid = {type="number"},
        kind = {type="number"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end

    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE2) then
        return
    end

    local pid = request.pid
    local kind = request.kind
    if not kind or kind < 1 or kind > 3 then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "args kind error"
        httpc.send_json(linkobj,200,response)
        return
    end

    if kind == 1 then -- ""nft build ""
        gg.playerProxy:send(pid, "correctBuilds")
    end

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = "success"
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