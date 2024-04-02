---""
--@module api.business.setBusinessBaseInfo
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/business/setBusinessBaseInfo
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {    
--      businessAccount     [required] type=string help=""
--      data             [required] type=json help="", {"PHONE":"85259893846"}  ""，""
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
--  curl -v 'http://127.0.0.1:4241/api/business/setBusinessBaseInfo' -d '{"businessAccount":"admin","data":"[{"PHONE":"85259893846"}]","sign":"e10adc3949ba59abbe56e057f20f883e"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        businessAccount = {type="string"},
        data = {type="json"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    
    if not operationmgr.checkBusinessAccount(linkobj, request, args) then
        return
    end
    
    local businessAccount = request.businessAccount

    for k,v in pairs(request.data) do
        if not constant.ADMIN_BUSINESS_BASE_INFO_DICT[k] then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = string.format("%s|%s",response.message,k)
            httpc.send_json(linkobj,200,response)
            return
        end
    end

    local newData = {}
    for k,v in pairs(request.data) do
        newData[k] = tostring(v)
    end

    businessaccountmgr.updateinviteaccount(businessAccount, newData)

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = "success"
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