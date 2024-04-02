---""app
--@module api.app.add
--@author sundream
--@release 2019/6/18 10:30:00
--@usage
--api:      /api/app/add
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      app = [required] type=json help=app
--  }
--  app""
--  {
--      appid           [required] type=string help="",""_G""
--      appkey          [required] type=string help=""
--      platform_whitelist  [required] type=table help=""
--      ip_whitelist    [optional] type=table help=ip""
--      account_whitelist [optional] type=table help=""
--      max_role_num_per_account [requird] type=int help=""
--      max_role_num_per_server [required] type=int help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        app = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local app = request.app
    local appid = assert(app.appid)
    local sign = request.sign
    local appkey = skynet.getenv("appkey")
    if not httpc.check_signature(args.sign,args,appkey) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    gg.mongoProxy.app:update({appid=appid},app,true,false)
    local response = httpc.answer.response(httpc.answer.code.OK)
    httpc.send_json(linkobj,200,response)
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
