---""(TOKEN)""
--@module api.analyzer.getChainWithdrawTokenList
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getChainWithdrawTokenList
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
--      account          [required] type=string help=""
--      pid              [required] type=string help=""ID
--      order_num          [required] type=string help=""
--      chain_id          [required] type=string help=""ID
--      token          [required] type=string help=MIT HYT
--      to_address          [required] type=string help=""
--      state              [required] type=string help="" --0"",1"",2"",3"",-1""
--      transaction_hash          [required] type=string help=""hash
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getChainWithdrawTokenList' -d '{}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        platform = {type="string"},
        account = {type="string"},
        pid = {type="string"},
        order_num = {type="string"},
        chain_id = {type="string"},
        token = {type="string"},
        to_address = {type="string"},
        state = {type="string"},
        transaction_hash = {type="string"},
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

    condition.owner_mail = nil
    if request.account ~= NO then
        condition.owner_mail = request.account
    end

    condition.pid = nil
    if request.pid ~= NO and tonumber(request.pid) then
        condition.pid = math.floor(tonumber(request.pid))
    end

    condition.order_num = nil
    if request.order_num ~= NO and tonumber(request.order_num) then
        condition.order_num = math.floor(tonumber(request.order_num))
    end

    condition.chain_id = nil
    if request.chain_id ~= NO and tonumber(request.chain_id) then
        condition.chain_id = math.floor(tonumber(request.chain_id))
    end

    condition.token = nil
    if request.token ~= NO then
        condition.token = request.token
    end

    condition.to_address = nil
    if request.to_address ~= NO then
        condition.to_address = request.to_address
    end

    condition.state = nil
    if request.state ~= NO and tonumber(request.state) then
        condition.state = math.floor(tonumber(request.state))
    end

    condition.transaction_hash = nil
    if request.transaction_hash ~= NO then
        condition.transaction_hash = request.transaction_hash
    end

    condition.beginCreateDate = nil
    condition.endCreateDate = nil
    if request.beginCreateDate ~= NO and request.endCreateDate ~= NO then
        local beginYear = tonumber(string.sub(request.beginCreateDate, 1, 4))
        local beginMonth = tonumber(string.sub(request.beginCreateDate, 5, 6))
        local beginDay = tonumber(string.sub(request.beginCreateDate, 7, 8))
        local beginCreateTime = gg.time.date_to_timestamp(beginYear, beginMonth, beginDay, 0, 0, 0)
        beginCreateTime = beginCreateTime * 1000

        local endYear = tonumber(string.sub(request.endCreateDate, 1, 4))
        local endMonth = tonumber(string.sub(request.endCreateDate, 5, 6))
        local endDay = tonumber(string.sub(request.endCreateDate, 7, 8))
        local endCreateTime = gg.time.date_to_timestamp(endYear, endMonth, endDay, 23, 59, 59)
        endCreateTime = endCreateTime * 1000 + 999

        condition.create_time = { ["$gte"] = beginCreateTime, ["$lt"] = endCreateTime }
    end
    
    local pageNo = tonumber(request.pageNo) or 1
    local pageSize = tonumber(request.pageSize) or 20
    local result = analyzermgr.getChainWithdrawTokenList(pageNo, pageSize, condition)
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