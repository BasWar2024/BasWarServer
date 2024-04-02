---""
--@module api.account.adminAccountAdd
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/account/adminAccountAdd
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      addAccount       [required] type=string help=""
--      addPassword      [required] type=string help=""
--      addAuthority     [required] type=number help=""(0"")
--      sign             [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--          addAccount = [required] type=string help=""
--          authority =  [required] type=number help="",0""
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/account/adminAccountAdd' -d '{"adminAccount":"admin","addAccount":"test","addPassword":"0483f597de3b17d265e96ee7cdefb363","sign":"e10adc3949ba59abbe56e057f20f883e"}'

--"": "": "", "", "", "", "", "", ""(""), ""(""), "", "" ""
--""0:"", "", "", "", "", "", "", ""(""), ""(""), "", ""
--""1:"", "", "", "", "", "", ""(""), ""("")
--""2:"", "", "", "", "", "", ""("")

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        addAccount = {type="string"},
        addPassword = {type="string"},
        addAuthority = {type="number"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local adminAccount = request.adminAccount
    local adminAccountobj = adminaccountmgr.getadminaccount(adminAccount)
    if not adminAccountobj then
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
    if adminAccountobj.authority ~= constant.ADMIN_AUTHORITY_ROOT then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.AUTHORITY_ERR))
        return
    end
    local addAccount = request.addAccount
    local addPassword = request.addPassword
    local addAuthority = math.floor(request.addAuthority)
    local accountobj = {}
    accountobj.adminAccount = addAccount
    accountobj.adminPassword = addPassword
    accountobj.authority = addAuthority
    local ret = adminaccountmgr.addadminaccount(accountobj)
    httpc.send_json(linkobj,200,httpc.answer.response(ret))
end

function handler.GET(linkobj,header,query,body)
    local args = urllib.parse_query(query)
    handler.exec(linkobj,header,args)
end

function handler.POST(linkobj,header,query,body)
    local args = {}
    if body and body ~= "" then
        args = cjson.decode(body)
    end
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
