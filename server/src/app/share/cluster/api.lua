-- api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

function api.sendMailVerification(account)
    local code = string.randomnumber(6)
    local keyName = constant.REDIS_MAIL_VERIFICATION .. account
    gg.redismgr:getdb():set(keyName, code)
    gg.redismgr:getdb():expire(keyName, 60)
end

function api.getItemProductCfg()
    local str = gg.redismgr:getdb():get(constant.REDIS_ITEM_PRODUCT_CFG)
    if str == nil or #str == 0 then
        return
    end
    return cjson.decode(str)
end

function api.setItemProductCfg(itemProductCfg)
    local str = cjson.encode(itemProductCfg)
    gg.redismgr:getdb():set(constant.REDIS_ITEM_PRODUCT_CFG, str)
end

function api.getProductTotal(quality)
    local dayzerotime = gg.time.dayzerotime()
    local keyName = constant.REDIS_ITEM_PRODUCT_TOTAL..quality.."::"..dayzerotime
    return gg.redismgr:getdb():get(keyName)
end

function api.setProductTotal(quality, value)
    local dayzerotime = gg.time.dayzerotime()
    local keyName = constant.REDIS_ITEM_PRODUCT_TOTAL..quality.."::"..dayzerotime
    gg.redismgr:getdb():set(keyName, value)
    gg.redismgr:getdb():expire(keyName, dayzerotime+86400-os.time())
end

function api.decrProductTotal(quality, defaultValue)
    local dayzerotime = gg.time.dayzerotime()
    local keyName = constant.REDIS_ITEM_PRODUCT_TOTAL..quality.."::"..dayzerotime
    return gg.redismgr:getdb():decr(keyName)
end

function api.getMitExchangeRate()
    local text = gg.redismgr:getdb():get(constant.REDIS_EXCHANGE_RATE)
    if not text or text == "" then
        local default = {}
        default.mit = 1
        default.starCoin = 100
        default.ice = 100
        default.carboxyl = 100
        default.titanium = 100
        default.gas = 100

        text = cjson.encode(default)
        gg.redismgr:getdb():set(constant.REDIS_EXCHANGE_RATE, text)
        text = gg.redismgr:getdb():get(constant.REDIS_EXCHANGE_RATE)
    end
    return cjson.decode(text)
end

function api.getPlayerNodeByPid(pid)
    local db = gg.dbmgr:getdb()
    local doc = db.role:findOne({roleid=pid})
    if not doc then
        return nil
    end
    return doc.createServerId
end

function api.setPlayerBaseInfo(pid, infoDict)
    local keyName = constant.REDIS_PLAYER_BASE_INFO .. pid
    for k,v in pairs(infoDict) do
        gg.redismgr:getdb():hset(keyName, k, v)
    end
end

function api.getPlayerBaseInfo(pid, key, defaultValue)
    
end

return api