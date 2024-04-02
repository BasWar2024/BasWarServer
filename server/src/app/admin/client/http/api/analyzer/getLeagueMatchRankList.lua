---""
--@module api.analyzer.getLeagueMatchRankList
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getLeagueMatchRankList
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      cfgId            [required] type=number help=""id
--      chainIndex       [required] type=number help=""
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getLeagueMatchRankList' -d '{"sign":"ea0f194840af008272bee8de05d0c0b5","adminAccount":"admin"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        cfgId = {type="number"},
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
    local cfgId = nil
    if request.cfgId > 0  then
        cfgId = request.cfgId
    end
    if not cfgId then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,"cfgId is error")
        httpc.send_json(linkobj,200,response)
        return
    end
    local chainIndex = nil
    if request.chainIndex then
        chainIndex = tonumber(request.chainIndex)
        if not chainIndex or chainIndex < 0 then
            chainIndex = nil
        end
    end
    local r, result = analyzermgr.getLeagueMatchRankList(cfgId, chainIndex or 0)
    if not r then
        local response = httpc.answer.response(httpc.answer.code.FAIL)
        response.message = string.format("%s|%s",response.message, result)
        httpc.send_json(linkobj,200,response)
        return
    end
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = result
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