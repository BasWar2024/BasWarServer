---
--@module api.account.pay.settle
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/pay/settle
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      order_id    [required] type=string help=id
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=number help=
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/pay/settle' -d '{"sign":"debug","order_id":"158505582400000000010"}'
local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        order_id = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local order_id = request.order_id
    local order = accountmgr.get_order("end_order",order_id)
    if order then
        local response = httpc.answer.response(httpc.answer.code.PAY_ORDER_AREADY_SETTLE)
        httpc.send_json(linkobj,200,response)
        return
    end
    order = accountmgr.get_order("finish_order",order_id)
    if not order then
        local response = httpc.answer.response(httpc.answer.code.PAY_ORDER_NO_EXIST)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = order.appid
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
    accountmgr.settle_pay(order)
    httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.OK))
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
