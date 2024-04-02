util = util or {}

function util.get_app(appid)
    local doc = gg.mongoProxy.app:findOne({appid=appid})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

function util.zonelist_by_version(appid,version)
    -- mongo3.4.6""key"""."
    version = string.gsub(version,"%.","_")
    local app = util.get_app(appid)
    return app.version_whitelist[version]
end

function util.zonelist_by_ip(appid,ip)
    local app = util.get_app(appid)
    return app.ip_whitelist[ip]
end

function util.zonelist_by_account(appid,account)
    local app = util.get_app(appid)
    return app.account_whitelist[account]
end

function util.zonelist_by_platform(appid,platform)
    local app = util.get_app(appid)
    return app.platform_whitelist[platform]
end

function util.serverlist_by_zonelist(all_serverlist,zonelist)
    local serverlist = {}
    for i,server in ipairs(all_serverlist) do
        for j,zoneid in ipairs(zonelist) do
            if string.match(server.zoneid,zoneid) then
                table.insert(serverlist,server)
            end
        end
    end
    return serverlist
end

function util.filter_serverlist(appid,version,ip,account,platform)
    local all_serverlist = servermgr.getserverlist(appid)
    local serverlist
    local zonelist = util.zonelist_by_version(appid,version)
    if zonelist then
        serverlist = util.serverlist_by_zonelist(all_serverlist,zonelist)
        return serverlist,zonelist
    end
    local zonelist = util.zonelist_by_ip(appid,ip)
    if zonelist then
        serverlist = util.serverlist_by_zonelist(all_serverlist,zonelist)
        return serverlist,zonelist
    end
    if account then
        zonelist = util.zonelist_by_account(appid,account)
        if zonelist then
            serverlist = util.serverlist_by_zonelist(all_serverlist,zonelist)
            return serverlist,zonelist
        end
    end
    local zonelist = util.zonelist_by_platform(appid,platform)
    if zonelist then
        serverlist = util.serverlist_by_zonelist(all_serverlist,zonelist)
        return serverlist,zonelist
    end
    return {},{}
end

function util.getProductCfg(productId)
    local product = cfg.get("etc.cfg.product")
    for k,v in pairs(product) do
        if v.productId == productId then
            return v
        end
    end
    return nil
end

function util.dapp_check_signature(params)
    if not params.sign then
        return false
    end
    local temp = {}
    for k, v in pairs(params) do
        if k ~= "sign" then
            temp[k] = v
        end
    end
    local content = gg.makeSignContent(temp, "STARWAR2021HAPPYLOGININTERFACE")
    local sign = md5.sumhexa(content)
    if params.sign ~= sign then
        return false
    end
    return true
end

function util.sha1(text)
	local c = crypt.sha1(text)
	return crypt.hexencode(c)
end

return util
