---""
--@module api.analyzer.getGameResLog
--@author sw
--@release 2022/8/10 14:32:00
--@usage
--api:      /api/analyzer/getGameResLog
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      pageNo           [required] type=number help=""
--      pageSize         [required] type=number help=""
--      pid              [required] type=number help=""id
--      res              [required] type=string help=MIT HYT STARCOIN ICE TITANIUM GAS
--      reason           [required] type=string help=""
--      sign             [required] type=string help=""
--      change           [required] type=string help=""    1|-1 ""  get or use  ""1（get）
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getGameResLog' -d '{"adminAccount":"admin","pageNo":"1","pageSize":"5","pid":"1000010","reason":"all","res":"HYT","sign":"e10adc3949ba59abbe56e057f20f883e,"change":1}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        pid = {type="number"},
        res = {type="string"},
        reason = {type="string"},
        change = {type="number"}
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

    local reason = nil
    if #request.reason > 0 and request.reason ~= "all" then
        reason = request.reason
    end
    local pid = nil
    if request.pid ~= 0 then
        pid = request.pid
    end
    
    local change = nil
    if request.change == 1 or request.change == -1 or request.change == 0 then
        change = request.change
    end

    local pageNo = tonumber(request.pageNo) or 1
    pageNo = math.max(pageNo, 1)
    local pageSize = tonumber(request.pageSize) or 20
    pageSize = math.max(pageSize, 1)
    local result = analyzermgr.getGameResLog(pageNo, pageSize, pid, request.res, reason, change)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = result
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
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler