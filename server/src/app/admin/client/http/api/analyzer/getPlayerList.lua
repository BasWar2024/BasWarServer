---""
--@module api.analyzer.getPlayerList
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getPlayerList
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      pageNo           [required] type=number help=""
--      pageSize         [required] type=number help=""
--      sign             [required] type=string help=""
--      onlineStatus             [required] type=string help=""
--      platform             [required] type=string help=""
--      server             [required] type=string help=""
--      account             [required] type=string help=""
--      pid             [required] type=string help=""ID
--      name             [required] type=string help=""
--      inviteCode             [required] type=string help=""
--      chainId             [required] type=string help=""id
--      walletAddress             [required] type=string help=""
--      minBaseLevel             [required] type=string help=""
--      maxBaseLevel             [required] type=string help=""
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getPlayerList' -d '{}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        onlineStatus = {type="string"},
        platform = {type="string"},
        server = {type="string"},
        account = {type="string"},
        pid = {type="string"},
        name = {type="string"},
        inviteCode = {type="string"},
        chainId = {type="string"},
        walletAddress = {type="string"},
        minBaseLevel = {type="string"},
        maxBaseLevel = {type="string"},
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

    condition.onlineStatus = nil
    if request.onlineStatus ~= NO then
        condition.onlineStatus = math.floor(tonumber(request.onlineStatus))
    end

    condition.platform = nil
    if request.platform ~= NO then
        condition.platform = request.platform
    end

    condition.server = nil
    if request.server ~= NO then
        condition.server = request.server
    end

    condition.account = nil
    if request.account ~= NO then
        condition.account = request.account
    end

    condition.pid = nil
    if request.pid ~= NO and tonumber(request.pid) then
        condition.pid = math.floor(tonumber(request.pid))
    end

    condition.name = nil
    if request.name ~= NO then
        condition.name = request.name
    end

    condition.inviteCode = nil
    if request.inviteCode ~= NO then
        condition.inviteCode = request.inviteCode
    end

    condition.chainId = nil
    if request.chainId ~= NO then
        condition.chainId = math.floor(tonumber(request.chainId))
    end

    condition.walletAddress = nil
    if request.walletAddress ~= NO then
        condition.walletAddress = request.walletAddress
    end

    condition.minBaseLevel = nil
    condition.maxBaseLevel = nil
    if request.minBaseLevel ~= NO and request.maxBaseLevel ~= NO then
        condition.baseLevel = { ["$gte"] = math.floor(tonumber(request.minBaseLevel)), ["$lte"] = math.floor(tonumber(request.maxBaseLevel)) }
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

        condition.createTime = { ["$gte"] = beginCreateTime, ["$lt"] = endCreateTime }
    end
    
    local pageNo = tonumber(request.pageNo) or 1
    local pageSize = tonumber(request.pageSize) or 20
    local result = analyzermgr.getPlayerList(pageNo, pageSize, condition)
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