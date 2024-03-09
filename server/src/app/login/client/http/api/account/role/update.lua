---
--@author sundream
--@module api.account.role.update
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/role/update
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      roleid      [required] type=number help=ID
--      role        [required] type=table encode=json help=
--                  role = {
--                      name =      [required] type=string help=
--                      heroId =    [optional] type=number help=id
--                      level =     [optional] type=number default=0 help=
--                      gold =      [optional] type=number default=0 help=
--                      currentServerId = [required] type=string help=
--                      onlineState = [required] type=int help=(0=,1=,2=)
--                  }
--  }
--
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=number help=
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/role/update' -d '{"appid":"gg","roleid":1000000,"role":"{\"name\":\"name\"}","sign":"debug"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        roleid = {type="number"},
        role = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local roleid = request.roleid
    local role = request.role
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
    role.roleid = roleid
    local code = accountmgr.updaterole(appid,role)
    local response = httpc.answer.response(code)
    httpc.send_json(linkobj,200,response)
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
