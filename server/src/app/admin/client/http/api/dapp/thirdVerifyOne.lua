--""
--@module api.dapp.thirdVerifyOne
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/dapp/thirdVerifyOne
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      address              [required] type=string help=address
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
--  curl -v 'http://127.0.0.1:4241/api/dapp/thirdVerifyOne' -d '{"address":"xxxxxxxxxxxxxx"}'

--  http://10.168.1.95:4241/api/dapp/thirdVerifyOne?address=70782944435303916278720f2fdc7b3270e89ce7

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        address = {type="string"},
    })
    local result = {}
    result.error = {}
    result.error.code = 0
    result.error.message = "error message"
    result.data = {}
    result.data.result = false
    if not err and #request.address > 1 then
        local address = request.address
        address = string.lower(address)

        local keyName = constant.REDIS_THIRD_VERIFY_ONE .. "::" .. "total" .. "::" .. address
        gg.redisProxy:send("incrby", keyName, 1)

        if analyzermgr.isThirdAddress(address) then
            result.data.result = true
            httpc.send_json(linkobj,200,cjson.encode(result))

            local keyName = constant.REDIS_THIRD_VERIFY_ONE .. "::" .. "right" .. "::" .. address
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
                    httpc.send_json(linkobj,200,cjson.encode(result))

                    local keyName = constant.REDIS_THIRD_VERIFY_ONE .. "::" .. "right" .. "::" .. address
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
    if query and query ~= "" then
        local param = urllib.parse_query(query)
        table.update(args, param)
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