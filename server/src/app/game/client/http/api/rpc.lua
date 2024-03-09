---rpc
--@module game.api.rpc
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/rpc
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      module     [optional] type=string help=,_G
--      cmd         [required] type=string help=
--      args        [required] type=list encode=json help=
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=number help=
--      result =    [required] type=list help=
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/rpc' -d '{"sign":"debug","cmd":"tonumber","args":"[\"10\"]"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        module = {type="string",optional=true},
        cmd = {type="string"},
        args = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appkey = skynet.config.appkey
    if not httpc.check_signature(args.sign,args,appkey) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    local module = request.module
    local cmd = request.cmd
    local args = request.args
    if module == nil then
        module = _G
    end
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.result = {
        gg.exec(module,cmd,table.unpack(args)),
    }
    httpc.send_json(linkobj,200,response)
end

--[[
function handler.GET(linkobj,header,query,body)
    local args = urllib.parse_query(query)
    handler.exec(linkobj,header,args)
end
]]

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
