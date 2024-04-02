---""
--@module api.pay.settle
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/pay/settle
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      orderId    [required] type=string help=""id

--      account     [required] type=string help=""
--      productId  [required] type=string help=""id

--      receiptData    [required] type=string help=receiptData, pay_appstore""

--      signtureData    [required] type=string help=signtureData, pay_googleplay""
--      signture    [required] type=string help=signture, pay_googleplay""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/pay/settle' -d '{"sign":"debug","appid":"gg","orderId":"1","account":"1000000","productId":"product1","receiptData":"XXXXXXXXXXXXXXXXX","signtureData":"XXXXXXXXXXXXXXXXX","signture":"XXXXXXXXXXXXXXXXX"}'
local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        orderId = {type="string"},
        account = {type="string"},
        productId = {type="string"},
        receiptData = {type="string"},
        signtureData = {type="string"},
        signture = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
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

    local orderId = request.orderId
    local order = accountmgr.get_order("order_ready",orderId)
    if not order then
        local response = httpc.answer.response(httpc.answer.code.PAY_ORDER_NO_EXIST)
        response.message = "order error"
        response.orderId = orderId
        httpc.send_json(linkobj,200,response)
        return
    end
    local account = request.account
    if order.account ~= account then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "account error"
        response.orderId = orderId
        httpc.send_json(linkobj,200,response)
        return
    end
    local productId = request.productId
    if order.productId ~= productId then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "productId error"
        response.orderId = orderId
        httpc.send_json(linkobj,200,response)
        return
    end
    if order.state > constant.PAY_STATE_0 then
        local response = httpc.answer.response(httpc.answer.code.PAY_ORDER_AREADY_SETTLE)
        response.message = "aready settle"
        response.orderId = orderId
        httpc.send_json(linkobj,200,response)
        return
    end
    if order.receiptData or order.signtureData or order.signture then
        local response = httpc.answer.response(httpc.answer.code.PAY_ORDER_AREADY_SETTLE)
        response.message = "aready settled"
        response.orderId = orderId
        httpc.send_json(linkobj,200,response)
        return
    end

    local receiptData = request.receiptData
    --"",""
    --[[
    if receiptData == "" then
        receiptData = appstoremgr.tempReceipt
    end
    --]]
    local signtureData = request.signtureData
    --"",""
    --[[
    if signtureData == "" then
        signtureData = googleplaymgr.signtureData
    end
    --]]
    local signture = request.signture
    --"",""
    --[[
    if signture == "" then
        signture = googleplaymgr.signture
    end
    --]]

    if order.payChannel == constant.PAYCHANNEL_LOCAL then
        gg.mongoProxy.order_ready:update({ orderId = orderId },{["$set"] = { op = constant.PAY_OP_GMAPPROVE } },false,false)
    elseif order.payChannel == constant.PAYCHANNEL_APPSTORE then
        if not receiptData or receiptData == "" or receiptData == " " then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = "receiptData error"
            response.orderId = orderId
            httpc.send_json(linkobj,200,response)
            return
        end
        --""
        local transaction = md5.sumhexa(receiptData)
        local doc = gg.mongoProxy.order_ready:findOne({ transaction = transaction})
        if doc then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = "receiptData repeat"
            response.orderId = orderId
            httpc.send_json(linkobj,200,response)
            return
        end
        gg.mongoProxy.order_ready:update({ orderId = orderId },{["$set"] = { receiptData = receiptData, transaction = transaction } },false,false)
    elseif order.payChannel == constant.PAYCHANNEL_GOOGLEPLAY then
        if not signtureData or signtureData == "" or signtureData == " " then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = "signtureData error"
            response.orderId = orderId
            httpc.send_json(linkobj,200,response)
            return
        end
        if not signture or signture == "" or signture == " " then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = "signture error"
            response.orderId = orderId
            httpc.send_json(linkobj,200,response)
            return
        end
        --""
        local transaction = md5.sumhexa(signtureData)
        local doc = gg.mongoProxy.order_ready:findOne({ transaction = transaction })
        if doc then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = "signtureData repeat"
            response.orderId = orderId
            httpc.send_json(linkobj,200,response)
            return
        end
        gg.mongoProxy.order_ready:update({ orderId = orderId },{["$set"] = { signtureData = signtureData, signture = signture, transaction = transaction } },false,false)
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
