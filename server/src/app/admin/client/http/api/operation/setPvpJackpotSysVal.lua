---""PVP""("")
--@module api.operation.setPvpJackpotSysVal
--@author sw
--@release 2022/6/17 16:42:00
--@usage
--api:      /api/operation/setPvpJackpotSysVal
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      op            [required] type=string help=""("set""","add""")
--      value         [required] type=number help=""("","")
--      sign          [required] type=string help=""
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
--  curl -v 'http://127.0.0.1:4241/api/operation/setPvpJackpotSysVal' -d '{"op":"set","value":100}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        op = {type="string"},
        value = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    if request.op ~= "set" and request.op ~= "add" then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,"op is error")
        httpc.send_json(linkobj,200,response)
        return
    end
    local value = tonumber(request.value)
    if not value then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,"value is error")
        httpc.send_json(linkobj,200,response)
        return
    end
    if request.op == "set" and value < 0 then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,"can not set negative numnber")
        httpc.send_json(linkobj,200,response)
        return
    end

    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE1) then
        return
    end

    local jackpotInfo
    local info = gg.redisProxy:call("get", constant.REDIS_PVP_JACKPOT_INFO)
    if not info or info == "" then
        jackpotInfo = {
            sysCarboxyl = 0,
            plyCarboxyl = 0,
        }
    else
        jackpotInfo = cjson.decode(info)
    end
    if request.op == "set" then
        jackpotInfo.sysCarboxyl = value
    elseif request.op == "add" then
        jackpotInfo.sysCarboxyl = jackpotInfo.sysCarboxyl + value
    end
    if jackpotInfo.sysCarboxyl < 0 then
        jackpotInfo.sysCarboxyl = 0
    end
    -- info = cjson.encode(jackpotInfo)
    -- gg.redisProxy:send("set", constant.REDIS_PVP_JACKPOT_INFO, info)
    -- gg.opCfgProxy:send("updateOperationCfg", constant.REDIS_PVP_JACKPOT_INFO, jackpotInfo)
    gg.dynamicCfg:set(constant.REDIS_PVP_JACKPOT_INFO, jackpotInfo)

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