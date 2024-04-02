---""
--@module api.analyzer.getActiveUserStatistic
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getActiveUserStatistic
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign             [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=string help=""
--      data = {
--          month =  [required] type=number help=""
--          activeRatio = [required] type=number help=""
--          monthActiveNum = [required] type=number help=""("")
--          weekActiveNum = [required] type=number help=""("")
--          dayActiveNum = [required] type=number help=""("")
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getActiveUserStatistic' -d '{}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        platform = {type= "string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        year = {type="number"},
        month = {type="number"},
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

    local response = httpc.answer.response(httpc.answer.code.OK)
    local platform =  request.platform
    local pageNo = tonumber(request.pageNo) or 1
    local pageSize = tonumber(request.pageSize) or 20
    local year = tonumber(request.year) or 2010
    local month = tonumber(request.month) or 1
    local data = analyzermgr.getActiveUserStatisticByMonth(platform,year,month,pageNo,pageSize)
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