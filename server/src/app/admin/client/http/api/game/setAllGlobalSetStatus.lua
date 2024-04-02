---""（""）
--@module api.game.setAllGlobalSetStatus
--@author hyd
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/game/setAllGlobalSetStatus
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {    
--      adminAccount     [required] type=string help=""
--      data             [required] type=json help="", {"chainBridgeStatus":"close"}  ""，""
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
--  curl -v 'http://127.0.0.1:4241/api/game/setAllGlobalSetStatus' -d '{"adminAccount":"admin","data":"[{"ChainBridgeStatus":"close"}]","sign":"e10adc3949ba59abbe56e057f20f883e"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        data = {type="json"},
        sign = {type="string"},
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

    local globalSetArgs = constant.ADMIN_GLOBAL_SET_ARGS
    for k,v in pairs(request.data) do
        if not globalSetArgs[k] or globalSetArgs[k][v] ~= v then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = string.format("%s|%s",response.message,k)
            httpc.send_json(linkobj,200,response)
            return
        end
    end

    local recArgs = {}
    for k,v in pairs(globalSetArgs) do
        if request.data[k] and request.data[k] == v[request.data[k]] then
            recArgs[k] = request.data[k]
        end
    end
    local data = {}
    if recArgs[constant.REDIS_CHAIN_BRIDGE_STATUS] then
        local status = gg.shareProxy:call("setChainBridgeStatus", string.trim(recArgs.ChainBridgeStatus))
        table.insert(data, { [constant.REDIS_CHAIN_BRIDGE_STATUS] = status })
    end

    if recArgs[constant.REDIS_CHAIN_BRIDGE_NEED_SHIP] then
        local status = gg.shareProxy:call("setChainBridgeNeedShip", string.trim(recArgs.ChainBridgeNeedShip))
        table.insert(data, { [constant.REDIS_CHAIN_BRIDGE_NEED_SHIP] = status })
    end
    if recArgs[constant.REDIS_DEL_TIMEOUT_BATTLE_DATA] then
        local status
        local now = gg.time.time()
        local diff = now - constant.BATTLE_DATA_HOLE_TIME
        local query = {startBattleTime = {["$lt"] = diff}}
        status = gg.mongoProxy:call("delMultipleBattleInfo", query)
        table.insert(data, { [constant.REDIS_DEL_TIMEOUT_BATTLE_DATA] = status })
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