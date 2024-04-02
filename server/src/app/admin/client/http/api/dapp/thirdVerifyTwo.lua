--""
--@module api.dapp.thirdVerifyTwo
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/dapp/thirdVerifyTwo
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      verifyId              [required] type=string help=id
--      verifyAddress              [required] type=string help=address
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
--  curl -v 'http://127.0.0.1:4241/api/dapp/thirdVerifyTwo' -d '{"address":"xxxxxxxxxxxxxx", "verifyId":"xxx"}'

--  http://10.168.1.95:4241/api/dapp/thirdVerifyTwo?verifyId=&verifyAddress=70782944435303916278720f2fdc7b3270e89ce7

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        verifyAddress = {type="string"},
    })
    local result = {}
    result.code = 200
    result.msg = "success!"
    result.data = {}
    result.data.result = false
    result.data.msg = "fail, address is error"
    if not err and #request.verifyAddress > 1 then
        local address = request.verifyAddress
        address = string.lower(address)

        local keyName = constant.REDIS_THIRD_VERIFY_TWO .. "::" .. "total" .. "::" .. address
        gg.redisProxy:send("incrby", keyName, 1)

        if analyzermgr.isThirdAddress(address) then
            --"",""true
            result.data.result = true
            result.data.msg = "success"
            httpc.send_json(linkobj,200,cjson.encode(result))

            local keyName = constant.REDIS_THIRD_VERIFY_TWO .. "::" .. "right" .. "::" .. address
            gg.redisProxy:send("incrby", keyName, 1)
            return
        end

        local addressDoc = gg.mongoProxy.account:findOne({owner_address = address})
        if addressDoc and addressDoc.roleid then
            local ret = analyzermgr.getPlayerDataList({ pid = addressDoc.roleid }, false)
            local playerInfo = ret[1]
            if playerInfo then
                local baseLevel = playerInfo.baseLevel
                if baseLevel >= 15 then
                    --"",""true
                    result.data.result = true
                    result.data.msg = "success"
                    httpc.send_json(linkobj,200,cjson.encode(result))

                    local keyName = constant.REDIS_THIRD_VERIFY_TWO .. "::" .. "right" .. "::" .. address
                    gg.redisProxy:send("incrby", keyName, 1)
                    return
                end
            end
        end
    end

    result.data.result = false
    httpc.send_json(linkobj,200,cjson.encode(result))
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