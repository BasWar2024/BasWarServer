---""
--@module api.analyzer.getGameResStatisticHistory
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getGameResStatisticHistory
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      beginDate     [required] type=number help=""(""20220303)
--      endDate       [required] type=number help=""(""20220318)
--      sign          [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getGameResStatisticHistory' -d '{}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        beginDate = {type="number"},
        endDate = {type="number"},
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
    local token = request.token
    local resInfo = analyzermgr.getGameResStatisticHistory(beginDate, endDate)
    if not resInfo then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = resInfo
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