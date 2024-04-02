---""
--@module api.account.adminChangeInfo
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/account/adminResetPassword
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      resetAccount     [required] type=string help=""
--      oldPassword      [required] type=string help=""
--      newPassword      [required] type=string help=""
--      sign             [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/account/adminResetPassword' -d '{"adminAccount":"admin","resetAccount":"admin","oldPassword":"e10adc3949ba59abbe56e057f20f883e","newPassword":"e10adc3949ba59abbe56e057f20f883e","sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        resetAccount = {type="string"},
        oldPassword = {type="string"},
        newPassword = {type="string"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local adminAccount = request.adminAccount
    local resetAccount = request.resetAccount
    local oldPassword = request.oldPassword
    local newPassword = request.newPassword
    local token = adminaccountmgr.gettoken(adminAccount)
    if not token then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.TOKEN_UNAUTH))
        return
    end
    if not util.admin_check_token_signature(args,token) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    if adminAccount ~= resetAccount then
        local adminAccountobj = adminaccountmgr.getadminaccount(adminAccount)
        if not adminAccountobj then
            httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
            return
        end
        if adminAccountobj.authority ~= constant.ADMIN_AUTHORITY_ROOT then
            httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.AUTHORITY_ERR))
            return
        end
    end
    
    local accountobj = adminaccountmgr.getadminaccount(resetAccount)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    if adminAccount == resetAccount and oldPassword ~= accountobj.adminPassword then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PASSWD_ERROR))
        return
    end
    accountobj.adminPassword = newPassword
    adminaccountmgr.saveadminaccount(accountobj)
    adminaccountmgr.deltoken(resetAccount)
    local response = httpc.answer.response(httpc.answer.code.OK)
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
