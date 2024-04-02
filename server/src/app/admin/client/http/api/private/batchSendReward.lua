---""("")
--@module api.private.batchSendReward
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/private/batchSendReward
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
--  curl -v 'http://127.0.0.1:4241/private/batchSendReward' -d '{"action":"sendReturningReward", "param1":"etc.cfg.rewardList"}'

-- http://10.168.1.95:4241/api/private/batchSendReward?action=sendReturningReward&param1=etc.cfg.returningList
-- http://10.168.1.95:4241/api/private/batchSendReward?action=sendPreRegisteredReward&param1=etc.cfg.preRegisteredList


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        action = {type="string"},
        param1 = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local action = request.action
    local param1 = request.param1

    local ret = gg.redisProxy:call("hget", constant.REDIS_PRIVATE_API_INFO, "batchSendReward")
    if not ret or ret ~= "1" then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "batchSendReward close"
        httpc.send_json(linkobj,200,response)
        return
    end

    --[[
    if action == "updatePvpReward" then
        local keyList = gg.redisProxy:call("keys", "PlayerPvpMatchReward::*")
        for i, v in ipairs(keyList) do
            local carboxyl = gg.redisProxy:call("hget", v, 'carboxyl')
            if carboxyl then
                carboxyl = tonumber(carboxyl)
                if carboxyl > 0 then
                    local oldVal = carboxyl
                    carboxyl = math.floor(carboxyl / 0.6)
                    local newVal = carboxyl
                    gg.redisProxy:call("hset", v, 'carboxyl', carboxyl)
                    logger.logf("info", "batchSendReward", "action=%s, keyname=%s, oldVal=%s, newVal=%s, ", action, v, oldVal, newVal)
                end
            end
        end
        gg.redisProxy:call("hset", constant.REDIS_PRIVATE_API_INFO, "batchSendReward", "0")
        local response = httpc.answer.response(httpc.answer.code.OK)
        response.message = "success"
        httpc.send_json(linkobj,200,response)
        return
    end
    ]]

    local cfgs = require(param1)
    local sendList = {}
    local hasAccount = {}
    for k,v in pairs(cfgs) do
        if not hasAccount[v.account] then
            hasAccount[v.account] = true
            local tempAccount = v.account
            tempAccount = string.trim(tempAccount)
            tempAccount = string.lower(tempAccount)
            local doc = gg.mongoProxy.online_players:findOne({ account = tempAccount },{ _id = false, pid = true, account = true})
            if doc then
                table.insert(sendList, { cfgId = v.cfgId, account = tempAccount, pid = doc.pid})
            else
                table.insert(sendList, { cfgId = v.cfgId, account = tempAccount})
            end
        end
    end
    local batchList = {}
    local totalCnt = 0
    local batchCnt = 50
    local index = 0
    local temp = {}
    for k,v in ipairs(sendList) do
        if v.pid then
            if index == 0 then
                temp = {}
            end
            table.insert(temp, v.pid)
            index = index + 1
            totalCnt = totalCnt + 1
            if index == batchCnt then
                table.insert(batchList, temp)
                index = 0
            end
        end
    end
    if index ~= 0 then
        table.insert(batchList, temp)
    end

    if action == "sendReturningReward" then
        local sendId = 0
        local sendName = "Galaxy"
        local mailData = {
            title = "Gift for Returning Player", 
            content = "Dear commander,\n\nThank you for participating in the previous beta test, we have prepared special benefits and rewards for returning experienced players. Please click to receive the rewards. We look forward to exploring this mysterious interstellar world with you, in your mission to become the strongest commander in the universe!\n\nMethod: RECEIVE the reward-FIND it in MENU-storage-props",
            attachment = {{cfgId = 6920002, count = 1, type = 1}},
            logType = gamelog.MAIL_FROM_GMASTER,
            duration = 24 * 7,
        }
        for k,v in pairs(batchList) do
            local toPidList = v
            gg.mailProxy:call("gmSendMail", sendId, sendName, toPidList, mailData)
            logger.logf("info", "batchSendReward", "action=%s, batch=%s, batchList=%s,", action, k, table.dump(v))
        end
    elseif action == "sendPreRegisteredReward" then
        local sendId = 0
        local sendName = "Galaxy"
        local mailData = {
            title = "Gift for Pre-registered Player", 
            content = "Dear commander,\n\nThank you for participating in the Pre-registered, we have prepared special benefits and rewards for Pre-registered players. Please click to receive the rewards. We look forward to exploring this mysterious interstellar world with you, in your mission to become the strongest commander in the universe!\n\nMethod: RECEIVE the reward-FIND it in MENU-storage-props",
            attachment = {{cfgId = 6920001, count = 1, type = 1}},
            logType = gamelog.MAIL_FROM_GMASTER,
            duration = 24 * 7,
        }
        for k,v in pairs(batchList) do
            local toPidList = v
            gg.mailProxy:call("gmSendMail", sendId, sendName, toPidList, mailData)
            logger.logf("info", "batchSendReward", "action=%s, batch=%s, batchList=%s,", action, k, table.dump(v))
        end
    else
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "ActionError"
        httpc.send_json(linkobj,200,response)
        return
    end

    gg.redisProxy:call("hset", constant.REDIS_PRIVATE_API_INFO, "batchSendReward", "0")

    local file = io.open(string.format("./%s.csv", action), "w+")
    file:write("cfgId,account,pid\n")
    for i, v in ipairs(sendList) do
        local fields = {}
        table.insert(fields, v.cfgId or 0)
        table.insert(fields, v.account or "")
        table.insert(fields, v.pid or 0)
        file:write(table.concat(fields, ",") .. "\n")
    end
    file:close()

    local response = httpc.answer.response(httpc.answer.code.OK)
    local data = {}
    data.totalCnt = totalCnt
    data.batchList = batchList
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