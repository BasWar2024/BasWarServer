---""
--@module api.pay.ready
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/pay/ready
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      appid       [required] type=string help=appid
--      platform       [required] type=string help=platform
--      sdk       [required] type=string help=sdk
--      payChannel     [required] type=string help=""
--      payCurrency     [required] type=string help="","" USD
--      payType     [required] type=string help=""
--      account     [required] type=string help=""
--      pid      [required] type=int help=""id
--      productId  [required] type=string help=""id
--      ext         [optional] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--          order =  [required] type=table help=""
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/pay/ready' -d '{"sign":"debug","appid":"gg","platform":"local","sdk":"local","payChannel":"local","payCurrency":"USD","payType":"default","account":"xxx","pid":"1000000","product_id":"product1","ext":"ext"}'

--/*
--"":
--C""
--LS""("","")
--GS""("")
--PS""(""appstore)
--AS""
--CS""
--C2LS:""->""
--LS2C:"" ->""
--C2PS: ""->""
--C2S: ""->""

--"": ""/""
--""(appstore,googlePlay,local),""：
--1. C2LS: "",""orderId""(/api/account/pay/ready)
--2. C2PS: ""(""orderId,"")
--3. C2LS: "",""LS(/api/account/pay/settle),LS"",""
--4. CS:"","",""


--""(""),
--1. C2LS: "",""orderId""(/api/account/pay/ready),""url""
--2. C2PS: ""(""orderId)
--3. PS2LS: ""(/api/account/pay/back/$payChannel),LS""
--4. CS:"","",""
--*/

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        platform = {type="string"},
        sdk = {type="string"},
        payChannel = {type="string"},
        payCurrency = {type="string"},
        payType = {type="string"},
        account = {type="string"},
        pid = {type="number"},
        productId = {type="string"},
        ext = {type = "string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local platform = request.platform
    local sdk = request.sdk
    local payChannel = request.payChannel
    local payCurrency = request.payCurrency
    local payType = request.payType
    local account = request.account
    local pid = request.pid
    local productId = request.productId
    local ext = request.ext
    local language = request.language or "en_US"

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
    local accountobj = accountmgr.getaccount(account)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    if accountobj.roleid ~= pid then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ROLE_NOEXIST))
        return
    end

    --"" price, ""price""
    local productCfg = util.getProductCfg(productId)
    if not productCfg then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "productId error"
        httpc.send_json(linkobj,200,response)
        return
    end

    --"",""1""
    -- local dailyCnt = gg.shareProxy:call("getOrderDailyCount")
    -- if dailyCnt > 0 then
    --     local dayno = gg.time.dayno()
    --     local ok, curCnt = gg.sync:once_do("OrderReadyCnt"..pid, accountmgr.getOrderReadyCnt, pid, dayno)
    --     if not ok then
    --         httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SERVER_ERR))
    --         return
    --     end
    --     if curCnt >= dailyCnt then
    --         httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.DAILY_ORDER_MAX))
    --         return
    --     end
    -- end

    --""
    local channelInfo = gg.shareProxy:call("getDynamicCfg", constant.REDIS_PAY_CHANNEL_INFO)
    if not channelInfo or not channelInfo[payChannel] or channelInfo[payChannel].status ~= "open" then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "channel error"
        httpc.send_json(linkobj,200,response)
        return
    end
    if channelInfo[payChannel].currency and next(channelInfo[payChannel].currency) and (not channelInfo[payChannel].currency[payCurrency]) then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = "payCurrency error"
        httpc.send_json(linkobj,200,response)
        return
    end
    local payTypeDict = channelInfo[payChannel].payType
    if next(payTypeDict) then
        local choosePayType = payTypeDict[payType]
        if not choosePayType or choosePayType.status ~= "open" then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = "payType error"
            httpc.send_json(linkobj,200,response)
            return
        end
        local support = choosePayType.support or {}
        if next(support) then
            local tipText = ""
            local pass = false
            for k,v in pairs(support) do
                if tipText == "" then
                    tipText = tipText .. v
                else
                    tipText = tipText .. "," .. v
                end
                if v == payCurrency then
                    pass = true
                end
            end
            if not pass then
                local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
                response.message = payType .. " only support " .. tipText
                httpc.send_json(linkobj,200,response)
                return
            end
        end
    end

    local price = tonumber(productCfg.price)
    local value = tonumber(productCfg.value)

    local payPrice = price

    --"",""
    if payCurrency ~= "USD" then
        local currencyInfo = gg.shareProxy:call("getDynamicCfg", constant.REDIS_PAY_CURRENCY_INFO)
        if not currencyInfo or not currencyInfo[payCurrency] or not currencyInfo[payCurrency].rate then
            local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
            response.message = "currency error"
            httpc.send_json(linkobj,200,response)
            return
        end
        local rate = tonumber(currencyInfo[payCurrency].rate)
        payPrice = price * rate
        payPrice = tonumber(string.format("%.3f",payPrice))
    end

    local xsollaAuthToken = nil
    if payChannel == constant.PAYCHANNEL_XSOLLA then
        --""xsolla""
        local result, authToken = xsollamgr.getXsollaAuthToken(pid, pid, language, account)
        if not result then
            local response = httpc.answer.response(httpc.answer.code.FAIL)
            response.message = string.format("xsolla busy %s,please wait", authToken)
            httpc.send_json(linkobj,200,response)
            return
        end
        xsollaAuthToken = authToken
    end
             
    local param = {}
    param.appid = appid
    param.platform = accountobj.platform
    param.sdk = accountobj.sdk
    param.payChannel = payChannel
    param.payCurrency = payCurrency
    param.payType = payType
    param.account = account
    param.pid = pid
    param.productId = productId
    param.ext = ext
    param.price = price
    param.value = value
    param.payPrice = payPrice

    local order = accountmgr.ready_pay(param)

    local payUrl = nil
    if payChannel == constant.PAYCHANNEL_XSOLLA then
        local sandbox = false
        if payType == "sandbox" then
            sandbox = true
        end
        local result, orderToken = xsollamgr.getXsollaOrderToken(xsollaAuthToken, productId, order.orderId, pid, sandbox, language, account)
        if not result then
            local response = httpc.answer.response(httpc.answer.code.FAIL)
            response.message = string.format("Xsolla busy %s,please wait", orderToken)
            httpc.send_json(linkobj,200,response)
            return
        end
        payUrl = xsollamgr.getXsollaPayUrl(orderToken, sandbox)
    elseif payChannel == constant.PAYCHANNEL_INTERNATION then
        local orderAmount = math.ceil(payPrice * 100)
        local productDetail = productCfg.des
        payUrl = internationmgr.getInternationPayUrl(payType, payCurrency, order.orderId, orderAmount, productDetail)
        if not payUrl then
            local response = httpc.answer.response(httpc.answer.code.FAIL)
            response.message = "Internation busy,please wait"
            httpc.send_json(linkobj,200,response)
            return
        end
    end
    
    local data = {
        order = order,
        payUrl = payUrl,
    }
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = data
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
