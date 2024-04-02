---""
--@module api.mail.sendMail
--@author sw
--@release 2022/4/12 10:30:00
--@usage
--api:      /api/mail/sendMail
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign             [required] type=string help=""
--      sendId           [required] type=number help=""id
--      sendName         [required] type=string help=""
--      toPidList        [required] type=json help=""id，""
--      mailData
--      {
--          title         [required] type=string help=""
--          content       [required] type=string help=""
--          sendTime      [required] type=number help=""
--          attachment    [required] type=json help=""
--          {
--              {
--                  cfgId    [required] type=number help=""id
--                  quality  [required] type=number help=""
--                  count    [required] type=number help=""
--                  type     [required] type=number help=""
--              }    
--          }
--          duration      [required] type=number help=""("")
--          filter        [required] type=number help=0"",1"",2""
--      }
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/mail/gmSendMail' -d '{"sendId":0,"sendName":"DAPP","toPidList":"[]","mailData":"{\"title\":\"test\",\"content\":\"content\"}"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sendId = {type="number"},
        sendName = {type="string"},
        toPidList = {type="json"},
        mailData = {type="json"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    
    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE1) then
        return
    end
    
    local sendId = request.sendId
    local sendName = request.sendName
    local toPidList = request.toPidList
    local mailData = request.mailData
    local r, err = mailUtil.check_params(sendId, sendName, toPidList, mailData)
    if not r then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local ret = gg.mailProxy:call("gmSendMail", sendId, sendName, toPidList, mailData)
    local response = httpc.answer.response(httpc.answer.code.OK)
    if not ret then
        response = httpc.answer.response(httpc.answer.code.FAIL)
    else
        response.data = "success"
    end
    httpc.send_json(linkobj,200,response)
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
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
