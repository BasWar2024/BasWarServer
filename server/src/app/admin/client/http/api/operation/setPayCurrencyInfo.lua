---""
--@module api.operation.setPayCurrencyInfo
--@author sw
--@release 2022/12/13 13:53:00
--@usage
--api:      /api/operation/setPayCurrencyInfo
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      currency          [required] type=string help=""ISO4217 code
--      en_name            [required] type=string help=""
--      rate          [required] type=string help="", "" "-9999" ""
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
--  curl -v http://10.168.1.95:4241/api/operation/setPayCurrencyInfo?adminAccount=admin&currency=EUR&en_name=Euro&rate=0.94&sign=4b08800d2a3cd0355b6e47e24ce98a6e

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        currency = {type="string"},
        en_name = {type="string"},
        rate = {type="string"},
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
    
    local currency = request.currency
    local en_name = request.en_name
    local rate = request.rate
    local info = gg.dynamicCfg:get(constant.REDIS_PAY_CURRENCY_INFO)
    if rate == "-9999" then
        info[currency] = nil
    else
        local old = info[currency] or {}
        old.en_name = en_name
        old.rate = rate
        info[currency] = old
    end

    gg.dynamicCfg:set(constant.REDIS_PAY_CURRENCY_INFO, info)
    
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = "success"
    httpc.send_json(linkobj,200,response)
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