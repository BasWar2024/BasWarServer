---
--@module api.account.role.add
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/role/add
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      account     [required] type=string help=
--      serverid    [required] type=string help=ID
--      roleid      [optional] type=number help=ID,genrolekey,minroleid,maxroleid
--      genrolekey  [optional] type=string help=genroleidkey
--      minroleid   [optional] type=number help=ID
--      maxroleid   [optional] type=number help=ID(),[minroleid,maxroleid)
--      role        [required] type=table encode=json help=
--                  role = {
--                      name =      [required] type=string help=
--                      heroId =    [optional] type=number help=id
--                      level =     [optional] type=number default=0 help=
--                      gold =      [optional] type=number default=0 help=
--                      rmb =       [optional] type=number default=0 help=rmb
--                  }
--  }
--
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=number help=
--      data = {
--          role =  [required] type=table help=
--                              role/api/account/role/get
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/role/add' -d '{"appid":"gg","account":"lgl","serverid":"game1","roleid":1000000,"role":"{\"name\":\"name\"}","sign":"debug"}'
--  curl -v 'http://127.0.0.1:4000/api/account/role/add' -d '{"appid":"gg","account":"lgl","serverid":"game1","genrolekey":"gg","minroleid":1000000,"maxroleid":2000000000,"role":"{\"name\":\"name\"}","sign":"debug"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        account = {type="string"},
        serverid = {type="string"},
        role = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account
    local serverid = request.serverid
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
    local roleid
    if request.roleid then
        roleid = request.roleid
    else
        if not (request.genrolekey and
            request.minroleid and
            request.maxroleid) then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = string.format("%s|%s",response.message,"'genrolekey,minroleid,maxroleid' must appear at same time")
            httpc.send_json(linkobj,200,response)
            return
        end
        roleid = accountmgr.genroleid(appid,request.genrolekey,request.minroleid,request.maxroleid)
        if not roleid then
            httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ROLE_OVERLIMIT))
            return
        end
    end
    role.roleid = roleid
    role.rmb = role.rmb or 0
    if role.name == "roleName" then
        role.name = "user" .. roleid
    end
    local code,err = accountmgr.addrole(account,appid,serverid,role)
    local response = httpc.answer.response(code)
    if code == httpc.answer.code.OK then
        response.data = {role=role}
    end
    if err then
        response.message = string.format("%s|%s",response.message,err)
    end
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
