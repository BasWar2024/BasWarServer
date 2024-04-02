---""token
--@module api.account.adminRefreshToken
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/account/adminRefreshToken
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      sign             [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--          adminAccount = [required] type=string help=""
--          authority =     [required] type=number help="",0""
--          token =     [required] type=string help=""TOKEN
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/account/adminRefreshToken' -d '{"adminAccount":"admin","sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local adminAccount = request.adminAccount
    local accountobj = adminaccountmgr.getadminaccount(adminAccount)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    local token = adminaccountmgr.gettoken(adminAccount)
    if not token then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.TOKEN_UNAUTH))
        return
    end
    if not util.admin_check_token_signature(args,token) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    local token = adminaccountmgr.gentoken()
    local data = {
        token = token,
        adminAccount = adminAccount,
        authority = accountobj.authority,
    }
    adminaccountmgr.settoken(adminAccount, token)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = data
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
