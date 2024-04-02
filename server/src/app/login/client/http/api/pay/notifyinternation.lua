---""
--@module api.pay.notifyinternation
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/pay/notifyinternation
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
--  curl -v 'http://127.0.0.1:4000/api/pay/notifyinternation' -d ''
local handler = {}

function handler.exec(linkobj,header,query,body)
    --""sign
    local text = string.urldecode(body)
    logger.logf("info","internationnotify",string.format("op=notifyinternationurldecode,body=%s\n",text))

    local param = urllib.parse_query(text)
    local dataText = param.data
    if dataText then
        local data = cjson.decode(dataText)
        local merchantOrderNo = data.merchantOrderNo
        if merchantOrderNo then
            local result, merchantOrder = internationmgr.getInternationOrder(merchantOrderNo)
            if result and merchantOrder and next(merchantOrder) then
                local payOrderNo = merchantOrder.orderNo
                local orderId = merchantOrder.merchantOrderNo
                local orderStatus = merchantOrder.orderStatus
                if orderStatus == "SUCCESS" and payOrderNo and orderId then
                    local order = accountmgr.get_order("order_ready",orderId)
                    if order and order.state == constant.PAY_STATE_0 then
                        logger.logf("info","internationnotify",string.format("op=notifyinternationcheck,payOrderNo=%s,orderId=%s\n",payOrderNo,orderId))
                        gg.mongoProxy.order_ready:update({ orderId = orderId, state = constant.PAY_STATE_0 },{["$set"] = { op = constant.PAY_OP_INTERNATIONCHECK, payOrderNo = tostring(payOrderNo) } },false,false)
                        accountmgr.settle_pay(orderId)
                    end
                end
            else
                httpc.send_json(linkobj,200,"fail")
                return
            end
        end
    end
    
    httpc.send_json(linkobj,200,"success")
end

function handler.POST(linkobj,header,query,body)
    logger.logf("info","internationnotify",string.format("op=notifyinternation,header=%s,query=%s,body=%s\n",table.dump(header),table.dump(query),table.dump(body)))
    handler.exec(linkobj,header,query,body)
end

function __hotfix(module)
    gg.client:open()
end

return handler
