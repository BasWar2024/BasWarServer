---""pvp""
--@module api.config.setDynamicCfg
--@author sw
--@release 2022/6/16 19:30:00
--@usage
--api:      /api/config/setDynamicCfg
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string ""
--      sign             [required] type=string help=""
--      configName              [required] type=string help=""
--      data             [required] type=json help""
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
--  curl -v 'http://127.0.0.1:4241/api/config/setDynamicCfg' -d '{"key":"MatchConfig"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        configName = {type="string"},
        data = {type="json"},
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

    local configName = request.configName
    local data = request.data
    gg.dynamicCfg:set(configName, data)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = "Success"
    httpc.send_json(linkobj, 200, response)
end

function handler.POST(linkobj,header,query,body)
    local args = {}
    if query and query ~= "" then
        local param = urllib.parse_query(query)
        table.update(args, param)
    end
    if body and body ~= "" then
        args.data = string.trimBom(body)
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