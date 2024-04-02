---""
--@module api.game.businessSetAccount
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/game/businessSetAccount
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {    
--      adminAccount     [required] type=string help=""
--      account          [required] type=string help=""
--      value            [required] type=string help="",0"",1""
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
--  curl -v 'http://127.0.0.1:4241/api/game/businessSetAccount' -d '{"adminAccount":"admin","account":"test01@gmail.com","value":"1","sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        account = {type="string"},
        value = {type="string"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end

    local value = request.value
    local account = request.account

    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE2) then
        return
    end
    
    if not string.checkEmail(string.trim(account)) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_FMT_ERR))
        return
    end

    local accountobj = businessaccountmgr.getbusinessaccount(account)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end

    local inviteobj = businessaccountmgr.getinviteaccount(account)
    if not inviteobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end

    if value == "1" then
        businessaccountmgr.updateinviteaccount(account, {business=math.floor(tonumber(value))})
    else
        businessaccountmgr.updateinviteaccount(account, {business=0})
    end

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = "success"
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