local UnionProxy = class("UnionProxy")
function UnionProxy:ctor()
    self.unionProxy = ggclass.Proxy.new("center",".union")
    self.unions = {}                  --""unionInfo, unionId, unionName, unionFlag, presidentName
end

function UnionProxy:doPlayerCmd(pid, cmd, ...)
    local player = gg.playermgr:getplayer(pid)
    if not player then
        return nil
    end
    if player.unionBag[cmd] then
        player.unionBag[cmd](player.unionBag, ...)
    end
end

function UnionProxy:onUnionAdd(unionInfo, createPid)
    self.unions[unionInfo.unionId] = unionInfo
end

function UnionProxy:onUnionDel(unionId, lastPid)
    self.unions[unionId] = nil
end

function UnionProxy:onUnionUpdate(subCmd, unionId, param)
    if subCmd == "onModifyUnionInfo" then
        local unionInfo = param
        self.unions[unionInfo.unionId] = unionInfo
    end
end

function UnionProxy:getUnionInfo(unionId)
    if not unionId then
        return nil
    end
    return self.unions[unionId]
end

function UnionProxy:searchUnionNameOrUnionIdLike(keyWord)
    return gg.unionProxy:call("searchUnionNameOrUnionIdLike", keyWord)
end

function UnionProxy:playerLogin(pid, data)
    self.unionProxy:send("api", "playerLogin", pid, data)
end

function UnionProxy:playerLogout(pid, data)
    self.unionProxy:send("api", "playerLogout", pid, data)
end

function UnionProxy:call(cmd, ...)
    return self.unionProxy:call("api", cmd, ...)
end

function UnionProxy:send(cmd, ...)
    return self.unionProxy:send("api", cmd, ...)
end

function UnionProxy:start()
    local unionInfos = self:call("getAllUnionInfo")
    for k, v in pairs(unionInfos) do
        self.unions[v.unionId] = v
    end
end

return UnionProxy