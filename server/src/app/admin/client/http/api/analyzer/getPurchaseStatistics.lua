---""
-- --@module api.analyzer.getPurchaseStatistics
--@author hyd
--@release 2023/1/18 10:30:00
--@usage
--api:      /api/analyzer/getPurchaseStatistics
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign          [required] type=string help=""
--      sort     [required] type=string help=""，""0""，1""
--      flush         [required] type=int help="",0""，1""
--  }
--return:
--  type=table encode=json
-- {
--     "message": "OK",
--     "data": {
--         "totalNum": 986,
--         "productInfo": [
--             {
--                 "num": 21,
--                 "ratio": 0.0212981744,
--                 "productId": "gb.moonCard.1999"
--             },
--             {
--                 "num": 20,
--                 "ratio": 0.0202839756,
--                 "productId": "gb.starcoin.2999"
--             },
--             {
--                 "num": 13,
--                 "ratio": 0.0131845841,
--                 "productId": "gb.resource.999"
--             },
--             {
--                 "num": 4,
--                 "ratio": 0.0040567951,
--                 "productId": "gb.resource.9999"
--             },
--             {
--                 "num": 1,
--                 "ratio": 0.0010141987,
--                 "productId": "gb.starcoin.9999"
--             },
--             {
--                 "num": 20,
--                 "ratio": 0.0202839756,
--                 "productId": "gb.skill.9999"
--             },
--             {
--                 "num": 27,
--                 "ratio": 0.0273833671,
--                 "productId": "gb.local.4"
--             },
--             {
--                 "num": 24,
--                 "ratio": 0.0243407707,
--                 "productId": "gb.tesseract.4999"
--             },
--             {
--                 "num": 41,
--                 "ratio": 0.0415821501,
--                 "productId": "gb.skill.4999"
--             },
--             {
--                 "num": 56,
--                 "ratio": 0.0567951318,
--                 "productId": "gb.cumulativeFunds.100"
--             },
--             {
--                 "num": 42,
--                 "ratio": 0.0425963488,
--                 "productId": "gb.tesseract.999"
--             },
--             {
--                 "num": 43,
--                 "ratio": 0.0436105476,
--                 "productId": "gb.tesseract.499"
--             },
--             {
--                 "num": 48,
--                 "ratio": 0.0486815415,
--                 "productId": "gb.tesseract.99"
--             },
--             {
--                 "num": 40,
--                 "ratio": 0.0405679513,
--                 "productId": "gb.cumulativeFunds.300"
--             },
--             {
--                 "num": 26,
--                 "ratio": 0.0263691683,
--                 "productId": "gb.tesseract.2999"
--             },
--             {
--                 "num": 49,
--                 "ratio": 0.0496957403,
--                 "productId": "gb.moonCard.199"
--             }
--         ]
--     },
--     "code": 0
-- }
--example:
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getPurchaseStatistics' -d '{"sign":"ea0f194840af008272bee8de05d0c0b5","adminAccount":"admin","res":"MIT","flush":0,"pid":1000503}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        sort = {type="number"},
        flush = {type="number"},
    })
    
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj, 200, response)
        return
    end

    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE2) then
        return
    end

    local flush = nil
    if request.flush == 1 or request.flush == 0 then
        flush = request.flush
    else
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PARAM_ERR))
        return
    end
    local sort = 0
    if request.sort == 1 then
        sort = 1
    end
    -- ""
    if flush == 0 then
        local data = gg.shareProxy:call("getPurchaseStatistics")
        if data and next(data) then
            data = cjson.decode(data[2])
            local response = httpc.answer.response(httpc.answer.code.OK)
            if sort == 0 then
                table.sort(data.productInfo, function (arg1, arg2)
                    return arg1.num > arg2.num
                end)
            elseif sort == 1 then
                table.sort(data.productInfo, function (arg1, arg2)
                    return arg1.num < arg2.num
                end)
            end
            response.data = data
            httpc.send(linkobj, 200, response)
            return
        end
    end
    gg.shareProxy:call("removePurchaseStatistics")
    local result = analyzermgr.getOrderStatistics()
    if not result or not next(result) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.FAIL))
        return
    end
    local data = gg.shareProxy:call("setPurchaseStatistics",  result)
    local response = httpc.answer.response(httpc.answer.code.OK)
    data = cjson.decode(data[2])
    if sort == 0 then
        table.sort(data.productInfo, function (arg1, arg2)
            return arg1.num > arg2.num
        end)
    elseif sort == 1 then
        table.sort(data.productInfo, function (arg1, arg2)
            return arg1.num < arg2.num
        end)
    end
    response.data = data
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