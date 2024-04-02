---""
--@module api.analyzer.getIndexStatistic
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getIndexStatistic
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      refresh             [required] type=string help=0"",1""
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getIndexStatistic' -d '{"sign":"ea0f194840af008272bee8de05d0c0b5","adminAccount":"admin"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        refresh = {type="string"},
        sign = {type="string"},
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
    
    local refresh = request.refresh
    if refresh == "1" then
        --""
        gg.redisProxy:call("del", constant.REDIS_ADMIN_API_GETINDEXSTATISTIC)
    end

    local text = gg.redisProxy:call("get", constant.REDIS_ADMIN_API_GETINDEXSTATISTIC)
    if not text then
        local result = {}
        local resInfo = analyzermgr.getGameTotalRes()

        local statInfo = {}
        statInfo.useMit = analyzermgr.getYestdayUseMit() / 1000
        statInfo.useHyt = analyzermgr.getYestdayUseCarboxyl() / 1000
        statInfo.totalPlayerCount = analyzermgr.getTotalPlayerCount()
        statInfo.yestdayActiveNum = analyzermgr.getYestdayActivePlayerCount()
        statInfo.onlinePlayerCount = analyzermgr.getCurrentOnlineCount()
    
        local dayno = gg.time.dayno()
        statInfo.todayOrderPrice = analyzermgr.getTotalOrderPrice(dayno, nil, nil)
        statInfo.todayOrderTesseract = analyzermgr.getTotalOrderTesseract(dayno, nil, nil) / 1000
        statInfo.todayChainRechargeHYT = analyzermgr.getTotalChainRechargeToken(dayno, "HYT", nil, nil) / 1000
        statInfo.todayChainRechargeMIT = analyzermgr.getTotalChainRechargeToken(dayno, "MIT", nil, nil) / 1000
        statInfo.todayChainWithdrawHYT = analyzermgr.getTotalChainWithdrawToken(dayno, "HYT", nil, nil) / 1000
        statInfo.todayChainWithdrawMIT = analyzermgr.getTotalChainWithdrawToken(dayno, "MIT", nil, nil) / 1000
        statInfo.todayExchangeHydroxyl = analyzermgr.getTotalExchangeHydroxyl(dayno, nil, nil) / 1000
        statInfo.todayExchangeTesseract = analyzermgr.getTotalExchangeTesseract(dayno, nil, nil) / 1000
    
        local dayno = dayno - 1
        statInfo.yestdayOrderPrice = analyzermgr.getTotalOrderPrice(dayno, nil, nil)
        statInfo.yestdayOrderTesseract = analyzermgr.getTotalOrderTesseract(dayno, nil, nil) / 1000
        statInfo.yestdayChainRechargeHYT = analyzermgr.getTotalChainRechargeToken(dayno, "HYT", nil, nil) / 1000
        statInfo.yestdayChainRechargeMIT = analyzermgr.getTotalChainRechargeToken(dayno, "MIT", nil, nil) / 1000
        statInfo.yestdayChainWithdrawHYT = analyzermgr.getTotalChainWithdrawToken(dayno, "HYT", nil, nil) / 1000
        statInfo.yestdayChainWithdrawMIT = analyzermgr.getTotalChainWithdrawToken(dayno, "MIT", nil, nil) / 1000
        statInfo.yestdayExchangeHydroxyl = analyzermgr.getTotalExchangeHydroxyl(dayno, nil, nil) / 1000
        statInfo.yestdayExchangeTesseract = analyzermgr.getTotalExchangeTesseract(dayno, nil, nil) / 1000

        statInfo.totalOrderPrice = analyzermgr.getTotalOrderPrice(nil, nil, nil)
        statInfo.totalOrderTesseract = analyzermgr.getTotalOrderTesseract(nil, nil, nil) / 1000
        statInfo.totalChainRechargeHYT = analyzermgr.getTotalChainRechargeToken(nil, "HYT", nil, nil) / 1000
        statInfo.totalChainRechargeMIT = analyzermgr.getTotalChainRechargeToken(nil, "MIT", nil, nil) / 1000
        statInfo.totalChainWithdrawHYT = analyzermgr.getTotalChainWithdrawToken(nil, "HYT", nil, nil) / 1000
        statInfo.totalChainWithdrawMIT = analyzermgr.getTotalChainWithdrawToken(nil, "MIT", nil, nil) / 1000
        statInfo.totalExchangeHydroxyl = analyzermgr.getTotalExchangeHydroxyl(nil, nil, nil) / 1000
        statInfo.totalExchangeTesseract = analyzermgr.getTotalExchangeTesseract(nil, nil, nil) / 1000

        result.resInfo = resInfo
        result.statInfo = statInfo

        text = cjson.encode(result)
        gg.redisProxy:call("set", constant.REDIS_ADMIN_API_GETINDEXSTATISTIC, text)
    end

    local data = cjson.decode(text)

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