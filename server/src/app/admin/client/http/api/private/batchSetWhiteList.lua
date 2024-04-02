---""("")
--@module api.private.batchSetWhiteList
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/private/batchSetWhiteList
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
--  curl -v 'http://127.0.0.1:4241/private/batchSetWhiteList' -d '{"mail":"test1@qq.com"}'

-- http://10.168.1.95:4241/api/private/batchSetWhiteList?action=createRole&param1=20230227

-- http://10.168.1.95:4241/api/private/batchSetWhiteList?action=fatherAccount&param1=test114@gmail.com

-- http://10.168.1.95:4241/api/private/batchSetWhiteList?action=readFile&param1=etc.cfg.whiteList

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

    local ret = gg.redisProxy:call("hget", constant.REDIS_PRIVATE_API_INFO, "batchSetWhiteList")
    if not ret or ret ~= "1" then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "batchSetWhiteList close"
        httpc.send_json(linkobj,200,response)
        return
    end

    if action == "createRole" then
        --""
        local createDate = tonumber(param1)
        local docs = gg.mongoProxy.player_create_log:find({ createDate = createDate}, { _id = false, pid = true, account = true })
        for k,v in pairs(docs) do
            gg.shareProxy:call("setWhiteListAccount", string.trim(v.account), "1")
        end
    elseif action == "fatherAccount" then
        --""
        local fatherAccount = param1
        local docs = gg.mongoProxy.inviteAccount:find({ fatherAccount = fatherAccount}, { _id = false, account = true, fatherAccount = true })
        for k,v in pairs(docs) do
            gg.shareProxy:call("setWhiteListAccount", string.trim(v.account), "1")
        end
    elseif action == "readFile" then
        local cfgs = require(param1)
        for k,v in pairs(cfgs) do
            gg.shareProxy:call("setWhiteListAccount", string.trim(v.account), "1")
        end
    else
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "ActionError"
        httpc.send_json(linkobj,200,response)
        return
    end

    gg.redisProxy:call("hset", constant.REDIS_PRIVATE_API_INFO, "batchSetWhiteList", "0")

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = "success"
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