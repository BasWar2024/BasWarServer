---""
--@module api.mail.getMails
--@author sw
--@release 2022/7/4 17:38:00
--@usage
--api:      /api/mail/getMails
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign             [required] type=string help=""
--      pageNo           [required] type=number help=""
--      pageSize         [required] type=number help=""
--      sendId           [required] type=number help=""id
--      sendName         [optional] type=string help=""
--      isDetail         [required] type=boolean help=""
--      beginDate        [required] type=number help=""(""20220303)
--      endDate          [required] type=number help=""(""20220318)
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--                 {
--                      id =     [required] type=number help=""id
--                      mailType =     [required] type=number help=""(0"",1"")
--                      duration =     [required] type=number help=""("")
--                      sendPid =     [required] type=number help=""id
--                      sendName =     [required] type=number help=""
--                      title         [required] type=string help=""
--                      content       [required] type=string help=""
--                      sendTime      [required] type=number help=""
--                      attachment    [required] type=json help=""
--                      {
--                          {
--                              cfgId    [required] type=number help=""id
--                              quality  [required] type=number help=""
--                              count    [required] type=number help=""
--                              type     [required] type=number help=""
--                          }
--                      }
--                      receivePid      [required] type=number help=""pid
--                  }
--          }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/mail/gmGetMails' -d '{"sendId":0,"sendName":"DAPP","isDetail":false,"beginDate":20230303,"endDate":20230518,"pageSize":10,"pageNo":1}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        sendId = {type="number"},
        -- sendName = {type="string"},
        isDetail = {type="boolean"},
        beginDate = {type="number"},
        endDate = {type="number"},
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

    local sendId = request.sendId
    local sendName = request.sendName
    local isDetail = request.isDetail
    local r, err = mailUtil.check_sender(sendId, sendName)
    if not r then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local beginDate = request.beginDate
    local endDate = request.endDate
    if beginDate <= 0 or endDate <= 0 then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,"beginDate or endDate is error")
        httpc.send_json(linkobj,200,response)
        return
    end
    local pageNo = tonumber(request.pageNo) or 1
    pageNo = math.max(pageNo, 1)
    local pageSize = tonumber(request.pageSize) or 20
    
    pageSize = math.max(pageSize, 1)
    local mailList = gg.mailProxy:call("gmGetMailsByPage", sendId, sendName, isDetail, pageNo, pageSize, beginDate, endDate)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = mailList
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
