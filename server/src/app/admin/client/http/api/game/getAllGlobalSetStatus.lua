---""
--@module api.game.getAllGlobalSetStatus
--@author hyd
--@release 2023/1/11 10:30:00
--@usage
--api:      /api/game/getAllGlobalSetStatus
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
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/game/getAllGlobalSetStatus' -d '{"adminAccount":"admin","sign":"e10adc3949ba59abbe56e057f20f883e"}'


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
    
    local data = {}
    local chainBridgeStatus = gg.shareProxy:call("getChainBridgeStatus")

    if chainBridgeStatus then
        table.insert(data, { chainBridgeStatus = chainBridgeStatus})
    end

    local chainBridgeNeedShip = gg.shareProxy:call("getChainBridgeNeedShip")
    if chainBridgeNeedShip then
        table.insert(data, { chainBridgeNeedShip = chainBridgeNeedShip})
    end
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = data
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