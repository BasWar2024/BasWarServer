---""("")
--@module api.private.opStarmapMatchUnionData
--@author ly
--@release 2023/4/11 16:21:00
--@usage
--api:      /api/private/opStarmapMatchUnionData
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      op               [required] type=string help=""
--      opParam          [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/private/opStarmapMatchUnionData' -d '{"op":"backup", "opParam":""}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        op = {type="string"},
        opParam = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    
    -- if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE1) then
    --     return
    -- end
    local ret = gg.redisProxy:call("hget", constant.REDIS_PRIVATE_API_INFO, "opStarmapMatchUnionData")
    if not ret or ret ~= "1" then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "opStarmapMatchUnionData close"
        httpc.send_json(linkobj,200,response)
        return
    end
    
    local op = request.op
    local opParam = request.opParam
    local ret = gg.unionProxy:call("handleStarmapMatchUnionCmd", op, opParam)
    local response = httpc.answer.response(httpc.answer.code.OK)
    if not ret then
        response = httpc.answer.response(httpc.answer.code.FAIL)
    else
        response.data = "success"
    end
    httpc.send_json(linkobj,200,response)
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
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
