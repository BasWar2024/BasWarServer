internationmgr = internationmgr or {}

local callbackUrl = "http://login.alphastar.me:4000/api/pay/notifyinternation"
if gg.isAlphaServer() then
    callbackUrl = "http://login.alphastar.me:4000/api/pay/notifyinternation"
elseif gg.isBetaServer() then
    callbackUrl = "http://beta.galaxyblitz.space:4000/api/pay/notifyinternation"
elseif gg.isReleaseServer() then
    callbackUrl = "http://www.galaxyblitz.space:4000/api/pay/notifyinternation"
elseif gg.isZksyncServer() then
    callbackUrl = "http://zksync.galaxyblitz.space:4000/api/pay/notifyinternation"
end 

local noticeUrl = "https://www.galaxyblitz.world"

local payGateUrl = "http://3.1.123.115:5005/cardPay/outerCardCashier?merchantOrderNo=%s&currency=%s&orderAmount=%s&productDetail=%s&callbackUrl=%s&noticeUrl=%s"

local queryUrl = "http://3.1.123.115:5005/cardPay/query"

function internationmgr.getInternationPayUrl(payType, currency, orderId, orderAmount, productDetail)
    local payUrl = nil
    if payType == "INTERNATIONAL_CARD" then
        payUrl = string.format(payGateUrl, orderId, currency, orderAmount, productDetail, callbackUrl, noticeUrl)
    end
    logger.logf("info","internationmgr",string.format("op=getInternationPayUrl,url=%s \n",tostring(payUrl)))
    return payUrl
end

function internationmgr.getInternationOrder(orderId)
    local ret, response = httpc.req(queryUrl,{ merchantOrderNo = orderId },nil,false,nil)
    logger.logf("info","internationmgr",string.format("op=getInternationOrder,orderId=%s,ret=%s,response=%s \n",orderId,ret,response))
    if ret == 200 then
        local data = cjson.decode(response)
        if data.meta and data.meta.code and data.meta.code == "0000" then
            return true, data.data
        end
    end
    return false, nil
end