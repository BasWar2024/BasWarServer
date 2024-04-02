---""
--@module api.analyzer.getPlayerResRankList
--@author wjc
--@release 2023/3/22 17:13:00
--@usage
--api:      /api/analyzer/getPlayerResRankList
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      refresh          [required] type=string help=0"",1""
--      resKey           [required] type=string help="", mit, starCoin, ice, hy, titanium, gas, tesseract, baseLevel("")
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getPlayerResRankList' -d '{"sign":"ea0f194840af008272bee8de05d0c0b5","adminAccount":"admin"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        refresh = {type="string"},
        resKey = {type="string"},
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
    local RES_KEY = {
        ["mit"] = "mit",
        ["starCoin"] = "starCoin",
        ["ice"] = "ice",
        ["carboxyl"] = "carboxyl",
        ["titanium"] = "titanium",
        ["gas"] = "gas",
        ["tesseract"] = "tesseract",
        ["baseLevel"] = "baseLevel",
    }
    local resKey = request.resKey
    if not RES_KEY[resKey] then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,"resKey is error")
        httpc.send_json(linkobj,200,response)
        return
    end
    
    local sortKey = RES_KEY[resKey]
    local redisKey = constant.REDIS_ADMIN_API_GETPLAYERRESRANKLIST.."_"..sortKey
    local refresh = request.refresh
    if refresh == "1" then
        --""
        gg.redisProxy:call("del", redisKey)
    end

    local text = gg.redisProxy:call("get", redisKey)
    if not text then
        local count = 100
        local result = analyzermgr.getPlayerResRankList(sortKey, count)
        text = cjson.encode(result)
        gg.redisProxy:call("set", redisKey, text)
    end
    local data = cjson.decode(text)
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