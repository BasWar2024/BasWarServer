---""PVP""
--@module api.operation.setPvpSysCarboxyl
--@author sw
--@release 2022/6/17 11:05:00
--@usage
--api:      /api/operation/setPvpSysCarboxyl
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      carboxyl         [required] type=number help=carboxyl
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
--  curl -v 'http://127.0.0.1:4241/api/operation/setPvpSysCarboxyl' -d '{"carboxyl":200}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        carboxyl = {type="number"},
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

    local carboxyl = request.carboxyl
    -- gg.redisProxy:send("set", constant.REDIS_PVP_SYS_CARBOXYL, carboxyl)
    -- gg.opCfgProxy:send("updateOperationCfg", constant.REDIS_PVP_SYS_CARBOXYL, carboxyl)
    gg.dynamicCfg:set(constant.REDIS_PVP_SYS_CARBOXYL, carboxyl)

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = {}
    httpc.send_json(linkobj,200,response)
end

function handler.POST(linkobj,header,query,body)
    local args = {}
    if body and body ~= "" then
        body = string.trimBom(body)
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