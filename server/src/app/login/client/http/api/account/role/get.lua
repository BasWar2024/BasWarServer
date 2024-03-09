---
--@module api.account.role.get
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/role/get
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      roleid      [required] type=number help=ID
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=string help=
--      data = {
--          role =  [optional] type=table help=
--                  role/api/account/role/add
--                  
--                  roleid = ID
--                  createTime = 
--                  createServerId = 
--                  currentServerId = 
--                  onlineState = [required] type=int help=(0=,1=,2=)
--                  level = 
--                  gold = 
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/role/get' -d '{"sign":"debug","appid":"gg","roleid":1000000}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        roleid = {type="number"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local roleid = request.roleid
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
    local role = accountmgr.getrole(appid,roleid)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = {role=role}
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
