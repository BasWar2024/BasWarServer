---""("")
--@module api.analyzer.getUserStatisticByDay
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getUserStatisticByDay
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
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getUserStatisticByDay' -d '{}'


local handler = {}

function handler.exec(linkobj,header,args)

    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        beginDate = {type="number"},
        endDate = {type="number"},
        platform = {type = "string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
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

    local beginDate = request.beginDate
    local endDate = request.endDate
    local platform = request.platform
    local pageNo = tonumber(request.pageNo) or 1
    local pageSize = tonumber(request.pageSize) or 10
    local list = analyzermgr.getUserStatisticByDay(beginDate, endDate,platform,pageNo,pageSize)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = list
    httpc.send(linkobj, 200, response)
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