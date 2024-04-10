local ServiceMgr = class("ServiceMgr")

function ServiceMgr:ctor()
    self.list = {}
    self.addressToName = {}
end

--- ""
--@param[type=int] address ""
function ServiceMgr:register(address,serviceName)
    self.list[#self.list + 1] = address
    if serviceName then
        self.addressToName[address] = serviceName
    end
end

--- ""
--@param[type=int] address ""
function ServiceMgr:unregister(address)
    for i,v in ipairs(self.list) do
        if v == address then
            table.remove(self.list,i)
            self.addressToName[address] = nil
            break
        end
    end
    logger.logf("info","service","ServiceMgr:unregister, address=%s",address)
end

--- ""
--@param[type=string] filename ""
--@return[type=bool] true=""
--@return[type=string] ""
function ServiceMgr:hotfix(filename)
    local ok,errmsg = gg.internal:call(self.list[1],"exec","gg.hotfix",filename)
    if ok then
        for i=2,#self.list do
            local address = self.list[i]
            gg.internal:send(address,"exec","gg.hotfix",filename)
        end
    end
    return ok,errmsg
end

--- ""
function ServiceMgr:exit()
    local list = self.list
    local mongodbList = {}
    local redisList = {}
    self.list = {}
    for i=#list,1,-1 do
        local address = list[i]
        local serviceName = self.addressToName[address]
        if serviceName == ".mongodb" then
            table.insert(mongodbList, address)
        elseif serviceName == ".redisdb" then
            table.insert(redisList, address)
        else
            logger.logf("info","service","ServiceMgr:exit, address=%s,serviceName=%s",address,tostring(serviceName))
            gg.internal:call(address,"exec","gg.exit")
        end
    end
    for i=#redisList,1,-1 do
        local address = redisList[i]
        local serviceName = self.addressToName[address]
        logger.logf("info","service","ServiceMgr:exit, address=%s,serviceName=%s",address,tostring(serviceName))
        gg.internal:call(address,"exec","gg.exit")
    end
    for i=#mongodbList,1,-1 do
        local address = mongodbList[i]
        local serviceName = self.addressToName[address]
        logger.logf("info","service","ServiceMgr:exit, address=%s,serviceName=%s",address,tostring(serviceName))
        gg.internal:call(address,"exec","gg.exit")
    end
end

function ServiceMgr:hotfixAll()
    if not gg.isInnerServer() then
        return
    end
    gg.internal:call(self.list[1],"exec","ggclass.ServiceMgr._hotfixAll")
    for i=2,#self.list do
        local address = self.list[i]
        gg.internal:send(address,"exec","ggclass.ServiceMgr._hotfixAll")
    end
end

-- ""
function ServiceMgr._hotfixAll()
    logger.logf("info","hotfix","op=hotfixAll,address=%s",skynet.address(skynet.self()))
    skynet.cache.clear()
    -- ""
    if not gg.ignoreCfg then
        if cfg.isHost then
            cfg.loadAll()
        end
        cfg.hotfixAll()
    end
    -- ""
    gg.hotfixProto()
    -- ""
    gg.hotfixI18n()
    -- ""
    for k,v in pairs(package.loaded) do
        if string.startswith(k,"app.") or string.startswith(k,"common") or string.startswith(k,"etc") then
            gg._hotfix(k)
        end
    end
    if gg.standalone then
        logger.print("reload ok")
    end
end

return ServiceMgr