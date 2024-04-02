---""
--@module api.mail.delMail
--@author sw
--@release 2022/7/4 17:38:00
--@usage
--api:      /api/mail/delMail
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign             [required] type=string help=""
--      id               [required] type=number help=""id
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/mail/gmDelMail' -d '{"id":0}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        id = {type="number"},
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

    local id = request.id
    local ret = gg.mailProxy:call("gmDelMail", id)
    local response = httpc.answer.response(httpc.answer.code.OK)
    if not ret then
        response = httpc.answer.response(httpc.answer.code.FAIL)
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
