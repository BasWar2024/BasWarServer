---""pvp""mit""
--@module api.operation.setPvpRankMitReward
--@author sw
--@release 2022/6/17 16:00:00
--@usage
--api:      /api/operation/setPvpRankMitReward
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign           [required] type=string help=""
--      reward         [required] type=json help=""
--      {
--          {
--              [required] min_rank=number help=""
--              [required] max_rank=number help=""
--              [required] mit=number help=mit""
--          }
--      }
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
--  curl -v 'http://127.0.0.1:4241/api/operation/setPvpRankMitReward' -d '{}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        reward = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local r, err = operationmgr.checkPvpRankMitReward(request.reward)
    if not r then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end

    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE1) then
        return
    end

    -- local text = cjson.encode(request.reward)
    -- gg.redisProxy:send("set", constant.REDIS_PVP_RANK_MIT_REWARD, text)
    -- gg.opCfgProxy:send("updateOperationCfg", constant.REDIS_PVP_RANK_MIT_REWARD, request.reward)
    gg.dynamicCfg:set(constant.REDIS_PVP_RANK_MIT_REWARD, request.reward)

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