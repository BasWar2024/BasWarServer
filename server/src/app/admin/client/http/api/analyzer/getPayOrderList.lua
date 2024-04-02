---""
--@module api.analyzer.getPayOrderList
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getPayOrderList
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      pageNo           [required] type=number help=""
--      pageSize         [required] type=number help=""
--      sign             [required] type=string help=""
--      platform         [required] type=string help=""
--      payChannel       [required] type=string help=""
--      account          [required] type=string help=""
--      pid              [required] type=string help=""ID
--      orderId             [required] type=string help="" orderId
--      state              [required] type=string help="" --0"",1"",2""
--      op             [required] type=string help=""op
--      productId             [required] type=string help=""
--      beginCreateDate             [required] type=string help=""
--      endCreateDate             [required] type=string help=""
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getPayOrderList' -d '{}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        platform = {type="string"},
        payChannel = {type="string"},
        account = {type="string"},
        pid = {type="string"},
        orderId = {type="string"},
        state = {type="string"},
        op = {type="string"},
        productId = {type="string"},
        beginCreateDate = {type="string"},
        endCreateDate = {type="string"},
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

    local NO = "no"

    local condition = {}

    condition.platform = nil
    if request.platform ~= NO then
        condition.platform = request.platform
    end

    condition.payChannel = nil
    if request.payChannel ~= NO then
        condition.payChannel = request.payChannel
    end

    condition.account = nil
    if request.account ~= NO then
        condition.account = request.account
    end

    condition.pid = nil
    if request.pid ~= NO and tonumber(request.pid) then
        condition.pid = math.floor(tonumber(request.pid))
    end

    condition.orderId = nil
    if request.orderId ~= NO then
        condition.orderId = request.orderId
    end

    condition.state = nil
    if request.state ~= NO and tonumber(request.state) then
        condition.state = math.floor(tonumber(request.state))
    end

    condition.op = nil
    if request.op ~= NO then
        condition.op = request.op
    end

    condition.productId = nil
    if request.productId ~= NO then
        condition.productId = request.productId
    end

    condition.beginCreateDate = nil
    condition.endCreateDate = nil
    if request.beginCreateDate ~= NO and request.endCreateDate ~= NO then
        local beginYear = tonumber(string.sub(request.beginCreateDate, 1, 4))
        local beginMonth = tonumber(string.sub(request.beginCreateDate, 5, 6))
        local beginDay = tonumber(string.sub(request.beginCreateDate, 7, 8))
        local beginCreateTime = gg.time.date_to_timestamp(beginYear, beginMonth, beginDay, 0, 0, 0)

        local endYear = tonumber(string.sub(request.endCreateDate, 1, 4))
        local endMonth = tonumber(string.sub(request.endCreateDate, 5, 6))
        local endDay = tonumber(string.sub(request.endCreateDate, 7, 8))
        local endCreateTime = gg.time.date_to_timestamp(endYear, endMonth, endDay, 23, 59, 59)

        condition.createOrderTime = { ["$gte"] = beginCreateTime, ["$lt"] = endCreateTime }
    end
    
    local pageNo = tonumber(request.pageNo) or 1
    local pageSize = tonumber(request.pageSize) or 20
    local result = analyzermgr.getPayOrderList(pageNo, pageSize, condition)
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
    handler.exec(linkobj,header, args)
end

function __hotfix(module)
    gg.client:open()
end

return handler