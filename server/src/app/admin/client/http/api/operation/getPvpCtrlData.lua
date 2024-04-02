---""pvp""
--@module api.operation.getPvpCtrlData
--@author sw
--@release 2022/6/16 19:30:00
--@usage
--api:      /api/operation/getPvpCtrlData
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      sign             [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=string help=""
--      data = {
--          PvpSysCarboxyl =     [required] type=number help=PVP""
--          PvpStageRatio    [required] type=json help=pvp""
--          {
--               {
--                   stage  [required] type=number help=""
--                   score  [required] type=json help=""
--                   ratio  [required] type=number help=""
--               }
--          }
--          PvpJackpotPlayerRatio =     [required] type=number help=pvp""
--          PvpJackpotShareRatio =     [required] type=number help=pvp""
--          PvpRankMitReward    [required] type=json help=pvp""mit""
--          {
--               {
--                   min_rank  [required] type=number help=""
--                   max_rank  [required] type=number help=""
--                   mit  [required] type=number help=""mit
--               }
--          }
--          PvpJackpotSysVal =     [required] type=number help=PVP""("")
--          PvpJackpotInfo    [required] type=json help=PVP""
--          {
--               sysCarboxyl  [required] type=number help=""
--               plyCarboxyl  [required] type=number help=""
--          }
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/operation/getPvpCtrlData' -d '{}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
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

    local data = operationmgr.getPvpCtrlData()
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = data
    httpc.send_json(linkobj, 200, response)
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