---""
--@module api.analyzer.getGameItemLog
--@author sw
--@release 2022/8/10 14:32:00
--@usage
--api:      /api/analyzer/getGameItemLog
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      pageNo           [required] type=number help=""
--      pageSize         [required] type=number help=""
--      pid              [required] type=number help=""id,""0
--      id               [required] type=string help=""id,"0"
--      cfgId            [required] type=number help=""id,""0
--      reason           [required] type=string help="","" "all"
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getGameItemLog' -d '{"adminAccount":"admin","pageNo":"1","pageSize":"5","pid":"1000010","id":"0","cfgId":"0","reason":"all","sign":"e10adc3949ba59abbe56e057f20f883e"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        pid = {type="number"},
        id = {type="string"},
        cfgId = {type="number"},
        reason = {type="string"},
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

    local pid = nil
    if request.pid > 0  then
        pid = request.pid
    end
    local id = nil
    if #request.id > 0 and request.id ~= "0" then
        id = tonumber(request.id)
    end
    local cfgId = nil
    if request.cfgId > 0  then
        cfgId = request.cfgId
    end
    local reason = nil
    if #request.reason > 0 and request.reason ~= "all" then
        reason = request.reason
    end

    local pageNo = tonumber(request.pageNo) or 1
    pageNo = math.max(pageNo, 1)
    local pageSize = tonumber(request.pageSize) or 20
    pageSize = math.max(pageSize, 1)
 
    local result = analyzermgr.getGameItemLog(pageNo, pageSize, pid, id, cfgId, reason)
    for k,v in pairs(result.rows) do
        local itemCfg = operationmgr.getItemCfg(v.cfgId)
        if itemCfg then
            v.name = itemCfg.name
        end
    end
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