---""
--@module api.account.adminChangeInfo
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/account/adminChangeInfo
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      changeAccount    [required] type=string help=""
--      newPassword      [required] type=string help="", no""
--      newAuthority     [required] type=string help="", no""
--      sign             [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/account/adminChangeInfo' -d '{"adminAccount":"admin","resetAccount":"admin","oldPassword":"e10adc3949ba59abbe56e057f20f883e","newPassword":"e10adc3949ba59abbe56e057f20f883e","sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        changeAccount = {type="string"},
        newPassword = {type="string"},
        newAuthority = {type="string"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local adminAccount = request.adminAccount
    local changeAccount = request.changeAccount
    local newPassword = request.newPassword
    local newAuthority = request.newAuthority
    
    local token = adminaccountmgr.gettoken(adminAccount)
    if not token then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.TOKEN_UNAUTH))
        return
    end
    if not util.admin_check_token_signature(args,token) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    
    if adminAccount ~= "admin" and adminAccount ~= "allen" then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.AUTHORITY_ERR))
        return
    end
    if changeAccount == "admin" then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.AUTHORITY_ERR))
        return
    end

    local accountobj = adminaccountmgr.getadminaccount(changeAccount)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end

    local NO = "no"

    if newPassword ~= NO then
        accountobj.adminPassword = newPassword
    end
    if newAuthority ~= NO then
        if not tonumber(newAuthority) then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = string.format("newAuthority error")
            httpc.send_json(linkobj,200,response)
            return
        end
        accountobj.authority = math.floor(tonumber(newAuthority))
    end

    adminaccountmgr.saveadminaccount(accountobj)
    adminaccountmgr.deltoken(changeAccount)
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
