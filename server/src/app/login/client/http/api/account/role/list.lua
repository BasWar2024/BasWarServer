---
--@module api.account.role.list
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/role/list
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      account     [required] type=string help=
--      serverid    [optional] type=string help=ID()
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=string help=
--      data = {
--          rolelsit =  [optional] type=list help=,api/role/get
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/role/list' -d '{"sign":"debug","appid":"gg","account":"lgl"}'
--  curl -v 'http://127.0.0.1:4000/api/account/role/list' -d '{"sign":"debug","appid":"gg","account":"lgl","serverid":"game1}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        account = {type="string"},
        serverid = {type="string",optional=true},
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
    if not accountmgr.getaccount(account) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    local rolelist = accountmgr.getrolelist(account,appid)
    if serverid then
        rolelist = table.filter(rolelist,function (v)
            return v.createServerId == serverid
        end)
    end
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = {rolelist=rolelist}
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
