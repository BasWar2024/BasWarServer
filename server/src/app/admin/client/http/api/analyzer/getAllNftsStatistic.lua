--@module api.analyzer.getAllNftsStatistic
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getAllNftsStatistic
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign             [required] type=string help=""
--      adminAccount     [required] type=string help=""
--      chainId          [required] type=number help=""id
--      flush            [required] type=int help="",0""，1""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=string help=""
--     {
--     "data": [
--         {
--             "chainId": 97,
--             "nfts": {
--                 "nftWarShips": {
--                     "total": 109,
--                     "level": {
--                         "count": {
--                             "1": 109
--                         },
--                         "ratio": {
--                             "1": 1
--                         }
--                     },
--                     "quality": {
--                         "count": {
--                             "5": 109
--                         },
--                         "ratio": {
--                             "5": 1
--                         }
--                     }
--                 },
--                 "nftBuilds": {
--                     "total": 119,
--                     "level": {
--                         "count": {
--                             "1": 98,
--                             "40": 16,
--                             "2": 2,
--                             "11": 1,
--                             "3": 2
--                         },
--                         "ratio": {
--                             "1": 0.82352941176471,
--                             "40": 0.13445378151261,
--                             "2": 0.016806722689076,
--                             "11": 0.0084033613445378,
--                             "3": 0.016806722689076
--                         }
--                     },
--                     "quality": {
--                         "count": {
--                             "1": 20,
--                             "5": 87,
--                             "2": 12
--                         },
--                         "ratio": {
--                             "1": 0.16806722689076,
--                             "5": 0.73109243697479,
--                             "2": 0.10084033613445
--                         }
--                     }
--                 },
--                 "nftHeros": {
--                     "total": 88,
--                     "level": {
--                         "count": {
--                             "1": 77,
--                             "3": 4,
--                             "2": 7
--                         },
--                         "ratio": {
--                             "1": 0.875,
--                             "3": 0.045454545454545,
--                             "2": 0.079545454545455
--                         }
--                     },
--                     "quality": {
--                         "count": {
--                             "5": 88
--                         },
--                         "ratio": {
--                             "5": 1
--                         }
--                     }
--                 }
--             }
--         },
--         {
--             "chainId": 71,
--             "nfts": {
--                 "nftWarShips": {
--                     "total": 30,
--                     "level": {
--                         "count": {
--                             "1": 30
--                         },
--                         "ratio": {
--                             "1": 1
--                         }
--                     },
--                     "quality": {
--                         "count": {
--                             "5": 10,
--                             "4": 10,
--                             "3": 10
--                         },
--                         "ratio": {
--                             "5": 0.33333333333333,
--                             "4": 0.33333333333333,
--                             "3": 0.33333333333333
--                         }
--                     }
--                 },
--                 "nftBuilds": {
--                     "total": 24,
--                     "level": {
--                         "count": {
--                             "1": 24
--                         },
--                         "ratio": {
--                             "1": 1
--                         }
--                     },
--                     "quality": {
--                         "count": {
--                             "5": 8,
--                             "4": 8,
--                             "3": 8
--                         },
--                         "ratio": {
--                             "5": 0.33333333333333,
--                             "4": 0.33333333333333,
--                             "3": 0.33333333333333
--                         }
--                     }
--                 },
--                 "nftHeros": {
--                     "total": 24,
--                     "level": {
--                         "count": {
--                             "1": 24
--                         },
--                         "ratio": {
--                             "1": 1
--                         }
--                     },
--                     "quality": {
--                         "count": {
--                             "5": 8,
--                             "4": 8,
--                             "3": 8
--                         },
--                         "ratio": {
--                             "5": 0.33333333333333,
--                             "4": 0.33333333333333,
--                             "3": 0.33333333333333
--                         }
--                     }
--                 }
--             }
--         }
--     ],
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getAllNftsStatistic' -d '{"adminAccount":"admin","sign":"4b08800d2a3cd0355b6e47e24ce98a6e","flush":"1","chainId":"0"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        chainId = {type="number"},
        flush = {type="number"},
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
    local flush = nil
    if request.flush == 1 or request.flush == 0 then
        flush = request.flush
    else
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PARAM_ERR))
        return
    end

    local chainId = nil
    if request.chainId >= 0 then
        chainId = tonumber(request.chainId)
    else
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PARAM_ERR))
        return
    end

    -- ""
    if flush == 0 then
        local data = gg.shareProxy:call("getAllNftsStatistic", chainId)
        local resData = {}
        if #data > 0 then
            if chainId > 0 then
                table.insert(resData, {chainId = chainId, nfts = cjson.decode(data)})
            else
                for k,v in pairs(data) do
                    if k % 2 ~= 0 then
                        table.insert(resData, {chainId = cjson.decode(v), nfts = cjson.decode(data[k+1])})
                    end
                end
            end
        end
        local response = httpc.answer.response(httpc.answer.code.OK)
        response.data = resData
        httpc.send(linkobj, 200, response)
        return
    end
    gg.shareProxy:call("removeAllNftsStatistic")
    local result = analyzermgr.getAllNfts() -- ""redis""
    if not result or not next(result) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.FAIL))
        return
    end
    for k,v in pairs(result) do
        for kk,vv in pairs(v) do
            for kkk,vvv in pairs(vv) do
                if kkk == "quality" or kkk == "level" then
                    for kkkk,vvvv in pairs(vvv.ratio) do
                        vvv.ratio[kkkk] = vvv.count[kkkk] / vv.total
                    end
                end
            end
        end
    end
    local data = gg.shareProxy:call("setAllNftsStatistic",  result, chainId)
    local resData = {}
    if #data > 0 then
        if chainId > 0 then
            table.insert(resData, {chainId = chainId, nfts = cjson.decode(data)})
        else
            for k,v in pairs(data) do
                if k % 2 ~= 0 then
                    table.insert(resData, {chainId = cjson.decode(v), nfts = cjson.decode(data[k+1])})
                end
            end
        end
    end
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = resData
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