---""
--@module api.business.getBusinessBaseInfo
--@author sw
--@release 2023/1/11 10:30:00
--@usage
--api:      /api/business/getBusinessBaseInfo
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {    
--      businessAccount     [required] type=string help=""
--      sign             [required] type=string help=""
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
--  curl -v 'http://127.0.0.1:4241/api/business/getBusinessBaseInfo' -d '{"businessAccount":"test01@gmail.com", "sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        businessAccount = {type="string"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    
    if not operationmgr.checkBusinessAccount(linkobj, request, args) then
        return
    end
    
    local businessAccount = request.businessAccount

    local inviteobj = businessaccountmgr.getinviteaccount(businessAccount)
    if not inviteobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end

    local data = {}
    data.account = businessAccount
    data.PHONE = inviteobj.PHONE or ""
    data.DISCORD = inviteobj.DISCORD or ""
    data.TELEGRAM = inviteobj.TELEGRAM or ""
    data.PAYPAL = inviteobj.PAYPAL or ""
    data.ERC20 = inviteobj.ERC20 or ""
    data.TRC20 = inviteobj.TRC20 or ""
    data.BEP20 = inviteobj.BEP20 or ""
    
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = data
    httpc.send_json(linkobj, 200, response)
end

function handler.POST(linkobj,header,query,body)
    local args = {}
    if body and body ~= "" then
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