util = util or {}

function util.admin_check_signature(params)
    if not params.sign then
        return false
    end
    local temp = {}
    for k, v in pairs(params) do
        if k ~= "sign" then
            temp[k] = v
        end
    end
    local content = gg.makeSignContent(temp, "STARWAR2021HAPPYFISHADMININTERFACE")
    local sign = md5.sumhexa(content)
    if params.sign ~= sign then
        return false
    end
    return true
end

function util.admin_check_token_signature(params, token)
    if not params.sign then
        return false
    end
    local temp = {}
    for k, v in pairs(params) do
        if k ~= "sign" then
            temp[k] = v
        end
    end
    local content = gg.makeSignContent(temp, "STARWAR2021HAPPYFISHADMININTERFACE")
    content = content .. "&" .. token
    local sign = md5.sumhexa(content)
    if params.sign ~= sign then
        return false
    end
    return true
end

function util.business_check_signature(params)
    if not params.sign then
        return false
    end
    local temp = {}
    for k, v in pairs(params) do
        if k ~= "sign" then
            temp[k] = v
        end
    end
    local content = gg.makeSignContent(temp, "STARWAR2021HAPPYFISHBUSINESSINTERFACE")
    local sign = md5.sumhexa(content)
    if params.sign ~= sign then
        return false
    end
    return true
end

function util.business_check_token_signature(params, token)
    if not params.sign then
        return false
    end
    local temp = {}
    for k, v in pairs(params) do
        if k ~= "sign" and k ~= "pageNo" and k ~= "pageSize" then
            temp[k] = v
        end
    end
    local content = gg.makeSignContent(temp, "STARWAR2021HAPPYFISHBUSINESSINTERFACE")
    content = content .. "&" .. token
    local sign = md5.sumhexa(content)
    if params.sign ~= sign then
        return false
    end
    return true
end

return util
