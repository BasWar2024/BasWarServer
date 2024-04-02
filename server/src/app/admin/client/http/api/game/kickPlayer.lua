---""
--@module api.game.kickPlayer
--@author sw
--@release 2023/3/8 16:35:00
--@usage
--api:      /api/game/kickPlayer
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      pid              [required] type=number help=""ID    
--      sign             [required] type=string help=""
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
--  curl -v 'http://127.0.0.1:4241/api/game/kickPlayer' -d '{ "pid":1000000 }'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        pid = {type="number"},
        reason = {type="string"},
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
    
    local pid = request.pid
    local reason = request.reason
    reason = reason or "gm"
    if pid and pid ~= 0 then
        gg.playerProxy:send(pid, "kickPlayer", reason)
    else
        gg.centerProxy:send("broadCast2Game", "kickAllPlayer", reason)
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