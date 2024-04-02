-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

-- ""#START
function api.lock(node,address,recoverPointId,lockId)
    return gg.clusterQueue:_lock(node,address,recoverPointId,lockId)
end

function api.unlock(lockId)
    gg.clusterQueue:_unlock(lockId)
end
-- ""#END

-- ""#START

---""
function api.getBrief(pid)
    return gg.briefMgr:getBrief(pid)
end

---""
function api.createBrief(packBrief)
    local pid = assert(packBrief.pid)
    local brief = ggclass.Brief.new(pid)
    brief:deserialize(packBrief)
    brief.dirty = true
    brief:save_to_db()
end

---""
function api.deleteBrief(pid)
    gg.briefMgr:delBrief(pid)
    ggclass.Brief.delete_from_db(pid)
end

--[gameserver -> centerserver]
---""
function api.setBriefAttrs(pid,attrs)
    local brief = gg.briefMgr.briefs[pid]
    if not brief then
        return
    end
    gg.briefMgr:setBriefAttrs(pid,attrs)
    -- sync to gameserver
    for node_address in pairs(brief.subscribers) do
        local nodeid = skynet.nodeid(node_address)
        local node = snowflake.node(nodeid)
        local address = skynet.localaddress(node_address)
        gg.cluster:send(node,address,"api","setBriefAttrs",pid,attrs)
    end
end

--[gameserver -> centerserver]
---""
function api.delBriefAttrs(pid,keys)
    local brief = gg.briefMgr.briefs[pid]
    if not brief then
        return
    end
    gg.briefMgr:delBriefAttrs(pid,keys)
    for node_address in pairs(brief.subscribers) do
        local nodeid = skynet.nodeid(node_address)
        local node = snowflake.node(nodeid)
        local address = skynet.localaddress(node_address)
        gg.cluster:send(node,address,"api","delBriefAttrs",pid,keys)
    end
end

---""(pid"")
function api.subscribeBrief(address,pid)
    local brief = gg.briefMgr:getBriefObj(pid)
    if brief then
        brief:subscribe(address)
    end
end

function api.subscribeBriefs(address,pids)
    for i,pid in ipairs(pids) do
        api.subscribeBrief(address,pid)
    end
end

---""
function api.unsubscribeBrief(address,pid)
    local brief = gg.briefMgr.briefs[pid]
    if not brief then
        return
    end
    brief:unsubscribe(address)
end

---""
function api.unsubscribeBriefs(address,pids)
    for _,pid in pairs(pids) do
        api.unsubscribeBrief(address,pid)
    end
end

-- ""#END

---""
---@param nodeType string
---@param service string
---@param cmd string
---@param ... any
function api.broadCast2Server(nodeType, service, cmd, ...)
    for nodeId, node in pairs(gg.nodeMgr.nodes) do
        if node.type == nodeType then
            skynet.fork(function(node, service, ...)
                gg.cluster:send(node, service, "api", ...)
            end, node.id, service, cmd, ...)
        end
    end
end

---""
---@param cmd string
---@param ... any
function api.broadCast2Game(cmd, ...)
    api.broadCast2Server("game", ".game", cmd, ...)
end

---""game""api
---@param pid integer
---@param cmd string
---@param ... any
function api.sendCmd2Player(pid, cmd, ...)
    local brief = gg.briefMgr.briefs[pid]
    if not brief then
        return
    end
    local node = brief.data.node
    gg.cluster:send(node, ".game", "playerexec", pid, cmd, ...)
end


--- ""
---@param chan any
function api.onMulticastPublish(chan, ...)
    gg.internal:send(".multicast", "api", "onPublish", chan, ...)
    for nodeId, node in pairs(gg.nodeMgr.nodes) do
        skynet.fork(function(node, ...)
            gg.cluster:send(node, ".multicast", "api", "onPublish", ...)
        end, node.id, chan, ...)
    end
end

return api