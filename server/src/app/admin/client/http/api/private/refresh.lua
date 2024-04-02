---""("")
--@module api.private.refresh
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/private/refresh
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      action              [required] type=string help=""
--      param1              [required] type=string help=""1
--      param2              [required] type=string help=""2
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

-- http://10.168.1.95:4241/api/private/refresh?action=RefreshChainExclusive&param1=null&param2=null
-- http://10.168.1.95:4241/api/private/refresh?action=RefreshUrlConfig&param1=null&param2=null

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        action = {type="string"},
        param1 = {type="string"},
        param2 = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local action = request.action
    local param1 = request.param1
    local param2 = request.param2
    local ret = gg.redisProxy:call("hget", constant.REDIS_PRIVATE_API_INFO, "refresh")
    if not ret or ret ~= "1" then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "refresh close"
        httpc.send_json(linkobj,200,response)
        return
    end

    local platformDict = {}

    if action == "RefreshChainExclusive" then
        local data = gg.shareProxy:call("getDynamicCfg", constant.REDIS_STARMAP_CHAIN_EXCLUSIVE)
        gg.dynamicCfg:set(constant.REDIS_STARMAP_CHAIN_EXCLUSIVE, data)
    elseif action == "RefreshUrlConfig" then
        local data = gg.shareProxy:call("getDynamicCfg", constant.REDIS_URL_CONFIG_BASE)
        gg.dynamicCfg:set(constant.REDIS_URL_CONFIG_BASE, data)

        local data = gg.shareProxy:call("getDynamicCfg", constant.REDIS_URL_CONFIG_MARKET)
        gg.dynamicCfg:set(constant.REDIS_URL_CONFIG_MARKET, data)
    elseif action == "exportAllNftData" then
        local data = analyzermgr.exportAllNftData()
        local response = httpc.answer.response(httpc.answer.code.OK)
        response.message = "export all nft data success"
        httpc.send_json(linkobj,200,response)
        return
    elseif action == "correct" then
        if param1 == "1" then -- ""nft""
            gg.playerProxy:send(tonumber(param2), "correctBuilds")
            local response = httpc.answer.response(httpc.answer.code.OK)
            response.message = "correct nft build data success"
            httpc.send_json(linkobj,200,response)
            return
        end
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "param error"
        httpc.send_json(linkobj,200,response)
        return
    else
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "ActionError"
        httpc.send_json(linkobj,200,response)
        return
    end

    gg.redisProxy:call("hset", constant.REDIS_PRIVATE_API_INFO, "refresh", "0")

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.message = "success"
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