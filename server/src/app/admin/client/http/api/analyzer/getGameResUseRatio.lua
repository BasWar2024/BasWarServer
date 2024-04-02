---""
--@module api.analyzer.getGameResUseRatio
--@author hyd
--@release 2023/1/18 10:30:00
--@usage
--api:      /api/analyzer/getGameResUseRatio
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign          [required] type=string help=""
--      res           [required] type=string help="",MIT，HYT, STARCOIN, ICE, TITANIUM, GAS, TESSERACT
--      flush         [required] type=int help="",0""，1""
--      pid           [required] type=int help="",0""，-1""，
--  }
--return:
--  type=table encode=json
--  {
--     "message": "OK",
--     "data": {
--         "totalNum": [
--             {
--                 "value": 186347500,
--                 "type": "useData"
--             },
--             {
--                 "value": 190133000,
--                 "type": "getData"
--             }
--         ],
--         "getData": [
--             {
--                 "value": 150,
--                 "ratio": 0.0007889214,
--                 "reason": "create player gift"
--             },
--             {
--                 "value": 189981,
--                 "ratio": 0.9992005596,
--                 "reason": "order pay local"
--             }
--         ],
--         "useData": [
--             {
--                 "value": 60,
--                 "ratio": 0.000321979,
--                 "reason": "train solider"
--             },
--             {
--                 "value": 151501,
--                 "ratio": 0.8130025892,
--                 "reason": "soon build level up"
--             }
--         ]
--     },
--     "code": 0
-- }
--example:
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getGameResUseRatio' -d '{"sign":"ea0f194840af008272bee8de05d0c0b5","adminAccount":"admin","res":"MIT","flush":0,"pid":1000503}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        res = {type="string"},
        flush = {type="number"},
        pid = {type="number"},
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

    local res = nil
    local temp = {
        ["MIT"] = "MIT",
        ["HYT"] = "HYT",
        ["STARCOIN"] = "STARCOIN",
        ["ICE"] = "ICE",
        ["TITANIUM"] = "TITANIUM",
        ["GAS"] = "GAS",
        ["TESSERACT"] = "TESSERACT",
    }
    if temp[request.res] then
        res = request.res
    else
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PARAM_ERR))
        return
    end
    local pid = request.pid
    if not pid then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PARAM_ERR))
        return
    end
    -- ""
    local function formatData(data)
        local temp = {}
        for k,v in pairs(data) do
            if type(v) == "table" then
                table.insert(temp, {
                    reason = k,
                    value =v[1],
                    ratio = v[2]
                })
            end
        end
        return temp
    end
    if flush == 0 then
        local data = gg.shareProxy:call("getResUseRatio", res, pid)
        if data and next(data) then
            local response = httpc.answer.response(httpc.answer.code.OK)
            data = cjson.decode(data[2])
            local totalNum = {}
            local sendData = {}
            for k,v in pairs(data) do
                local temp = formatData(v)
                sendData[k] = temp
                table.insert(totalNum,{type=k,value=v.totalNum})
            end
            sendData.totalNum = totalNum
            response.data = sendData
            httpc.send(linkobj, 200, response)
            return
        end
    end
    gg.shareProxy:call("removeResUseRatio", res, pid)
    local useInfo = analyzermgr.getGameResByReason(res, -1, pid)
    local getInfo = analyzermgr.getGameResByReason(res, 1, pid)
    if not useInfo or not getInfo then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.FAIL))
        return
    end
    local function dealInfo(info)
        local totalNum = 0
        for k,v in pairs(info) do
            if v.totalValue < 0 then
                v.totalValue =  - v.totalValue
            end
            totalNum = totalNum + v.totalValue
        end
        local data = {}
        for k,v in pairs(info) do
            local ratio = v.totalValue / totalNum
            ratio = ratio - ratio % 0.0000000001
            data[v._id] =  {v.totalValue / 1000 , ratio ,}
        end
        data["totalNum"] = totalNum / 1000
        return data
    end

    local useData = dealInfo(useInfo)
    local getData = dealInfo(getInfo)
    local data = {}
    data.useData = useData
    data.getData = getData

    local data = gg.shareProxy:call("setResUseRatio", res, data, pid)
    local response = httpc.answer.response(httpc.answer.code.OK)
    data = cjson.decode(data[2])
    local totalNum = {}
    local sendData = {}
    for k,v in pairs(data) do
        local temp = formatData(v)
        sendData[k] = temp
        table.insert(totalNum,{type=k,value=v.totalNum})
    end
    sendData.totalNum = totalNum
    response.data = sendData
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