---""("")
--@module api.private.correct
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/private/correct
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      action              [required] type=string help=""
--      param1              [required] type=string help=""1
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
--  curl -v 'http://127.0.0.1:4241/private/correct' -d '{"action":"withdrawCorrect", "param1":"null"}'

-- http://10.168.1.95:4241/api/private/correct?action=withdrawCorrect&param1=null&param2=null
-- http://10.168.1.95:4241/api/private/correct?action=NFTCorrect&param1=0&param2=0

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        action = {type="string"},
        param1 = {type="string"},
        param2 = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local action = request.action
    local param1 = request.param1
    local param2 = request.param2

    local ret = gg.redisProxy:call("hget", constant.REDIS_PRIVATE_API_INFO, "correct")
    if not ret or ret ~= "1" then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "correct close"
        httpc.send_json(linkobj,200,response)
        return
    end

    local platformDict = {}

    if action == "withdrawCorrect" then
        local bson = require "bson"
        --"" withdrawToken
        local docs = gg.mongoProxy.withdrawToken:find({ }, { _id = false, order_num = true, create_time = true, pid = true })
        for k,v in pairs(docs) do
            if not platformDict[v.pid] then
                local role = gg.mongoProxy.role:findOne({ roleid = v.pid })
                if role then
                    platformDict[v.pid] = role.platform
                end
            end
            v.platform = platformDict[v.pid]
            v.dayno = gg.time.dayno(math.floor(v.create_time/1000))
            v.weekno = gg.time.weekno(math.floor(v.create_time/1000))
            v.monthno = gg.time.monthno(math.floor(v.create_time/1000))
            v.createTime = bson.date(math.floor(v.create_time/1000))
            v.createDate = tonumber(os.date("%Y%m%d", math.floor(v.create_time/1000)))
        end
        for k,v in pairs(docs) do
            local data = {}
            data.platform = v.platform
            data.dayno = v.dayno
            data.weekno = v.weekno
            data.monthno = v.monthno
            data.createTime = v.createTime
            data.createDate = v.createDate
            gg.mongoProxy.withdrawToken:update({ order_num = v.order_num },{["$set"] = data},false,false)
        end

        --"" withdrawNft
        local docs = gg.mongoProxy.withdrawNft:find({ }, { _id = false, order_num = true, create_time = true, pid = true })
        for k,v in pairs(docs) do
            if not platformDict[v.pid] then
                local role = gg.mongoProxy.role:findOne({ roleid = v.pid })
                if role then
                    platformDict[v.pid] = role.platform
                end
            end
            v.platform = platformDict[v.pid]
            v.dayno = gg.time.dayno(math.floor(v.create_time/1000))
            v.weekno = gg.time.weekno(math.floor(v.create_time/1000))
            v.monthno = gg.time.monthno(math.floor(v.create_time/1000))
            v.createTime = bson.date(math.floor(v.create_time/1000))
            v.createDate = tonumber(os.date("%Y%m%d", math.floor(v.create_time/1000)))
        end
        for k,v in pairs(docs) do
            local data = {}
            data.platform = v.platform
            data.dayno = v.dayno
            data.weekno = v.weekno
            data.monthno = v.monthno
            data.createTime = v.createTime
            data.createDate = v.createDate
            gg.mongoProxy.withdrawNft:update({ order_num = v.order_num },{["$set"] = data},false,false)
        end
    elseif action == "NFTCorrect" then
        local pid = nil             --0""
        if tonumber(param1) and tonumber(param1) > 0 then
            pid = math.floor(tonumber(param1))
        end
        local tokenId = nil         --0""nft
        if tonumber(param2) and tonumber(param2) > 0 then
            tokenId = math.floor(tonumber(param2))
        end
        
        local docs = gg.mongoProxy.role:find({ roleid = pid }, { _id = false, roleid = true, account = true })
        for k, v in pairs(docs) do
            local result = gg.playerProxy:call(v.roleid, "correctPlayerNFT", tokenId)
            if result then
                for _, dealId in pairs(result) do
                    logger.logf("info", "correct", "action=%s, pid=%s, dealId=%s,", action, v.roleid, dealId)
                end
            end
            skynet.sleep(1)
        end
    else
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "ActionError"
        httpc.send_json(linkobj,200,response)
        return
    end

    gg.redisProxy:call("hset", constant.REDIS_PRIVATE_API_INFO, "correct", "0")

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.message = "success"
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