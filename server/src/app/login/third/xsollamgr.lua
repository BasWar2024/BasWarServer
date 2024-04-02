xsollamgr = xsollamgr or {}

xsollamgr.project_name = "GalaxyBlitzZksync"   --""GalaxyBlitz, ""GalaxyBlitzZksync

local merchant_id = 377934

local project_id_zksync = 220440
local api_key_zksync = "a2e15179a13739097d251b166e51b8218ca24e59"
local web_key_zksync = "mJfu-KhWIqrGpnJ4lvCpK"
local authorization_zksync= "Basic Mzc3OTM0OmEyZTE1MTc5YTEzNzM5MDk3ZDI1MWIxNjZlNTFiODIxOGNhMjRlNTk="

local project_id = 209831
local api_key = "8ff47d0b846dcc839aeb21c779f71908267b095b"
local web_key = "zHlYSSQ-7aju5dH81E0Qm"
local authorization= "Basic Mzc3OTM0OjhmZjQ3ZDBiODQ2ZGNjODM5YWViMjFjNzc5ZjcxOTA4MjY3YjA5NWI="

if xsollamgr.project_name == "GalaxyBlitzZksync" then
    project_id = project_id_zksync
    api_key = api_key_zksync
    web_key = web_key_zksync
    authorization = authorization_zksync
end

local auth_url = "https://api.xsolla.com/merchant/v2/merchants/%s/token"

local order_url = "https://store.xsolla.com/api/v2/project/%s/payment/item/%s"

local pay_center_sandbox_url = "https://sandbox-secure.xsolla.com/paystation2/?access_token=%s"
local pay_center_url = "https://secure.xsolla.com/paystation2/?access_token=%s"

function xsollamgr.getXsollaAuthToken(pid, name, language, account)
    pid = tostring(pid)
    name = tostring(name)
    local country = xsollamgr.getCountry(language)

    --""redis""
    local keyName = constant.REDIS_XSOLLA_TOKEN_AUTH .. pid
    local text = gg.redisProxy:call("get", keyName)
    if text then
        local myData = cjson.decode(text)
        if myData.country == country then
            return true, myData.token
        end
    end

    --""xsolla""
    local header = {
        ["content-type"] = "application/json;charset=utf-8",
        ["Authorization"] = authorization,
    }
    local params = {}
    params["purchase"] = {}
    params["purchase"]["description"] = {}
    params["purchase"]["description"]["value"] = "GalaxyBlitz Purchase"
    params["purchase"]["subscription"] = {}
    params["purchase"]["subscription"]["currency"] = "USD"

    params["settings"] = {}
    params["settings"]["currency"] = "USD"
    params["settings"]["language"] = xsollamgr.getLanguage(language)
    params["settings"]["project_id"] = project_id
    params["settings"]["ui"] = {}
    params["settings"]["ui"]["size"] = "medium"

    params["user"] = {}
    params["user"]["id"] = {}
    params["user"]["id"]["value"] = tostring(pid)
    params["user"]["name"] = {}
    params["user"]["name"]["value"] = tostring(name)
    params["user"]["email"] = {}
    params["user"]["email"]["value"] = tostring(account)
    params["user"]["email"]["allow_modify"] = false
    params["user"]["country"] = {}
    params["user"]["country"]["value"] = country
    params["user"]["country"]["allow_modify"] = false

    local req_url = string.format(auth_url, merchant_id)
    local ret, response = httpc.req(req_url,nil,cjson.encode(params),false,header)
    logger.logf("info","xsollamgr",string.format("op=getXsollaAuthToken,params=%s,ret=%s,response=%s \n",cjson.encode(params),ret,response))

    if ret == 200 then
        local data = cjson.decode(response)

        local myData = {}
        myData.token = data.token
        myData.country = country

        --""redis,""24""
        gg.redisProxy:call("set", keyName, cjson.encode(myData))
        gg.redisProxy:send("expire", keyName, 24*60*60)
    end

    local text = gg.redisProxy:call("get", keyName)
    if text then
        local myData = cjson.decode(text)
        if myData.country == country then
            return true, myData.token
        end
    end
    
    return false, ret
end

function xsollamgr.getXsollaOrderToken(authToken, productId, orderId, pid, sandbox, language, account)
    authToken = tostring(authToken)
    productId = tostring(productId)
    orderId = tostring(orderId)
    pid = tostring(pid)

    local header = {
        ["content-type"] = "application/json;charset=utf-8",
        ["Authorization"] = "Bearer " ..  authToken,
    }
    local params = {}
    params["custom_parameters"] = {}
    params["custom_parameters"]["pid"] = pid
    params["custom_parameters"]["productId"] = productId
    params["custom_parameters"]["orderId"] = orderId

    params["locale"] = xsollamgr.getLanguage(language)
    params["currency"] = "USD"
    params["quantity"] = 1
    if sandbox then
        params["sandbox"] = true
    end

    params["settings"] = {}
    params["settings"]["ui"] = {}
    params["settings"]["ui"]["size"] = "large"
    params["settings"]["ui"]["theme"] = "default"
    params["settings"]["ui"]["version"] = "desktop"

    params["settings"]["ui"]["desktop"] = {}
    params["settings"]["ui"]["desktop"]["header"] = {}
    params["settings"]["ui"]["desktop"]["header"]["close_button"] = false
    params["settings"]["ui"]["desktop"]["header"]["is_visible"] = true
    params["settings"]["ui"]["desktop"]["header"]["type"] = "normal"
    params["settings"]["ui"]["desktop"]["header"]["visible_logo"] = true
    params["settings"]["ui"]["desktop"]["header"]["visible_name"] = true
    params["settings"]["ui"]["desktop"]["header"]["visible_purchase"] = true

    params["settings"]["ui"]["mobile"] = {}
    params["settings"]["ui"]["mobile"]["footer"] = {}
    params["settings"]["ui"]["mobile"]["footer"]["is_visible"] = true
    params["settings"]["ui"]["mobile"]["header"] = {}
    params["settings"]["ui"]["mobile"]["header"]["close_button"] = false

    params["settings"]["ui"]["version"] = "mobile"

    local req_url = string.format(order_url, project_id, productId)
    local ret, response = httpc.req(req_url,nil,cjson.encode(params),false,header)
    logger.logf("info","xsollamgr",string.format("op=getXsollaOrderToken,params=%s,ret=%s,response=%s \n",cjson.encode(params),ret,response))

    if ret == 200 then
        local data = cjson.decode(response)
        local token = data.token

        return true, token
    end

    return false, ret
end

function xsollamgr.getXsollaPayUrl(orderToken, sandbox)
    local url = pay_center_url
    if sandbox then
        url = pay_center_sandbox_url
    end
    return string.format(url, orderToken)
end

function xsollamgr.getLanguage(language)
    local lang = "en"
    if language == "zh_TW" then
        lang = "tw"
    end
    return lang
end

function xsollamgr.getCountry(language)
    local country = "US"
    if language == "zh_TW" then
        country = "CN"
    end
    return country
end

xsollamgr.web_key = web_key