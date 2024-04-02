---""
--@module api.account.businessAccountLogin
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/account/businessAccountLogin
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      businessAccount     [required] type=string help=""
--      businessPassword    [required] type=string help=""
--      sign                [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--          businessAccount =       [required] type=string help=""
--          token =     [required] type=string help=TOKEN
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/account/businessAccountLogin' -d '{"businessAccount":"test@qq.com","businessPassword":"e10adc3949ba59abbe56e057f20f883e","sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        businessAccount = {type="string"},
        businessPassword = {type="string"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    if not util.business_check_signature(args) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    local businessAccount = request.businessAccount
    local businessPassword = request.businessPassword
    local accountobj = businessaccountmgr.getbusinessaccount(businessAccount)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    if businessPassword ~= accountobj.passwd then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PASSWD_ERROR))
        return
    end
    local inviteobj = businessaccountmgr.getinviteaccount(businessAccount)
    if not inviteobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    if inviteobj.business ~= 1 then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOT_BUSINESS))
        return
    end

    local token = businessaccountmgr.gentoken(businessAccount)
    
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = { businessAccount = businessAccount, token = token }
    httpc.send_json(linkobj,200,response)
end

function handler.GET(linkobj,header,query,body)
    local args = urllib.parse_query(query)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
