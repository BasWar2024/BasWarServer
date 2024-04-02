---""
--@module api.analyzer.getRechargeWithdrawInfo
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getRechargeWithdrawInfo
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      unique           [required] type=string help=""id
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getRechargeWithdrawInfo' -d '{"sign":"ea0f194840af008272bee8de05d0c0b5","adminAccount":"admin"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        unique = {type="string"},
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
    
    local pid
    if string.checkEmail(request.unique) then
        local accountDoc = gg.mongoProxy.account:findOne({account = request.unique})
        if accountDoc then
            pid = accountDoc.roleid
        end
    else
        pid = tonumber(request.unique)
    end
    if not pid then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    
    local data = {}
    data.pid = pid
    data.totalOrderPrice = analyzermgr.getTotalOrderPrice(nil, nil, pid)
    data.totalOrderTesseract = analyzermgr.getTotalOrderTesseract(nil, nil, pid) / 1000
    data.totalChainRechargeHYT = analyzermgr.getTotalChainRechargeToken(nil, "HYT", nil, pid) / 1000
    data.totalChainRechargeMIT = analyzermgr.getTotalChainRechargeToken(nil, "MIT", nil, pid) / 1000
    data.totalChainWithdrawHYT = analyzermgr.getTotalChainWithdrawToken(nil, "HYT", nil, pid) / 1000
    data.totalChainWithdrawMIT = analyzermgr.getTotalChainWithdrawToken(nil, "MIT", nil, pid) / 1000
    data.totalExchangeHydroxyl = analyzermgr.getTotalExchangeHydroxyl(nil, nil, pid) / 1000
    data.totalExchangeTesseract = analyzermgr.getTotalExchangeTesseract(nil, nil, pid) / 1000

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