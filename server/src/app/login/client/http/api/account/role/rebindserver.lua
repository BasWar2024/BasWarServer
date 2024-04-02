---""
--@module api.account.role.rebindserver
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/role/rebindserver
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign            [required] type=string help=""
--      appid           [required] type=string help=appid
--      account         [required] type=string help=""
--      new_serverid    [required] type=string help=""ID
--      old_roleid      [required] type=number help=""ID
--      new_roleid      [required] type=number help=""ID(""ID""ID"")
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/role/rebindserver' -d '{"sign":"debug","appid":"gg","account":"lgl","old_roleid":1000000,"new_roleid":1000000,"new_serverid":"game2"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        account = {type="string"},
        new_serverid = {type="string"},
        old_roleid = {type="number"},
        new_roleid = {type="number"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account
    local new_serverid = request.new_serverid
    local old_roleid = request.old_roleid
    local new_roleid = request.new_roleid
    local app = util.get_app(appid)
    if not app then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.APPID_NOEXIST))
        return
    end
    local appkey = app.appkey
    if not httpc.check_signature(args.sign,args,appkey) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    local code = accountmgr.rebindserver(account,appid,new_serverid,old_roleid,new_roleid)
    httpc.send_json(linkobj,200,httpc.answer.response(code))
    return
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
