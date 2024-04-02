---""
--@module api.game.whiteListSetAccount
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/game/whiteListSetAccount
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {    
--      adminAccount     [required] type=string help=""
--      account          [required] type=string help=""
--      value            [required] type=string help="", 0"", 1""
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
--  curl -v 'http://127.0.0.1:4241/api/game/whiteListSetAccount' -d '{"adminAccount":"admin","account":"test01@gmail.com","value":"1","sign":"e10adc3949ba59abbe56e057f20f883e"}'


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

    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE2) then
        return
    end

    if request.value == "2" and request.adminAccount ~= "allen" then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.AUTHORITY_ERR))
        return
    end
 
    if not string.checkEmail(string.trim(request.account)) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_FMT_ERR))
        return
    end

    gg.shareProxy:call("setWhiteListAccount", string.trim(request.account), string.trim(request.value))

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