---""("","")
--@module api.pay.repair
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/pay/repair
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      orderid     [required] type=string help=orderid
--  }
--
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/pay/repair' -d '{"appid":"gg","orderid":"1111111","sign":"debug"}'
--  curl -v 'http://127.0.0.1:4000/api/pay/repair' -d '{"appid":"gg","orderid":"2222222","sign":"debug"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        orderid = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local orderId = request.orderid
    local app = util.get_app(appid)
    if not app then
        local response = httpc.answer.response(httpc.answer.code.APPID_NOEXIST)
        response.message = "app not exist"
        response.orderId = orderId
        httpc.send_json(linkobj,200,response)
        return
    end
    local appkey = app.appkey
    if not httpc.check_signature(args.sign,args,appkey) then
        local response = httpc.answer.response(httpc.answer.code.SIGN_ERR)
        response.message = "sign error"
        response.orderId = orderId
        httpc.send_json(linkobj,200,response)
        return
    end

    local ret, message = accountmgr.settle_pay(orderId)

    local response = httpc.answer.response(ret)
    response.message = message
    response.orderId = orderId
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
