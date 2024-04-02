---""
--@module api.pay.notifyxsolla
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/pay/notifyxsolla
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {

--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/pay/notifyxsolla' -d ''
local handler = {}

function handler.exec(linkobj,header,query,body)

    --""sign
    local authorization = header.authorization or ""
    local body = body or ""
    local content = body .. xsollamgr.web_key
    local sign = util.sha1(content)
    local myAuthorization = "Signature" .. " " .. sign
    logger.logf("info","xsollanotify",string.format("op=notifyxsollaexec,authorization=%s,myAuthorization=%s,ret=%s\n",authorization,myAuthorization,tostring(authorization==myAuthorization)))
    if authorization ~= myAuthorization then
        local result = {}
        result.error = {}
        result.error.code = "INVALID_SIGNATURE"
        result.error.message = "Invalid signature"
        httpc.send_json(linkobj,400,cjson.encode(result))
        return
    end

    local args = cjson.decode(body)

    local notification_type = args.notification_type
    local order = args.order
    local custom_parameters = args.custom_parameters

    if notification_type == "order_paid" then
        if next(order) and next(custom_parameters) then
            local payOrderNo = order.id
            local orderId = custom_parameters.orderId
            if payOrderNo and orderId then
                local order = accountmgr.get_order("order_ready",orderId)
                if order and order.state == constant.PAY_STATE_0 then
                    logger.logf("info","xsollanotify",string.format("op=notifyxsollacheck,payOrderNo=%s,orderId=%s\n",payOrderNo,orderId))
                    gg.mongoProxy.order_ready:update({ orderId = orderId, state = constant.PAY_STATE_0 },{["$set"] = { op = constant.PAY_OP_XSOLLACHECK, payOrderNo = tostring(payOrderNo) } },false,false)
                    accountmgr.settle_pay(orderId)
                end
            end
        end
    end

    httpc.send_json(linkobj,204,"success")
end

function handler.POST(linkobj,header,query,body)
    logger.logf("info","xsollanotify",string.format("op=notifyxsolla,header=%s,query=%s,body=%s\n",table.dump(header),table.dump(query),table.dump(body)))
    handler.exec(linkobj,header,query,body)
end

function __hotfix(module)
    gg.client:open()
end

return handler
