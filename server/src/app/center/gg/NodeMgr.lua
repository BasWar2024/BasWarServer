local NodeMgr = class("NodeMgr")

function NodeMgr:ctor()
    self.nodes = {}
    self.event = ggclass.Event.new(self)
end

--- ""
--@param[type=table] node {id=""id,type="",busyness=""}
function NodeMgr:login(node)
    local nodeId = node.id
    self.nodes[nodeId] = node
    node.heartbeatCount = gg.actor.heartbeatCount
    self.event:dispatchEvent("login",nodeId)
end

function NodeMgr:logout(nodeId)
    local node = self.nodes[nodeId]
    if not node then
        return
    end
    self.nodes[nodeId] = nil
    self.event:dispatchEvent("logout",nodeId)
end

function NodeMgr:heartbeat(attrs)
    local nodeId = attrs.id
    local node = self.nodes[nodeId]
    if not node then
        return false
    end
    table.update(node,attrs)
    node.heartbeatCount = gg.actor.heartbeatCount
    return true
end

function NodeMgr:getNodesOfType(nodeType)
    local list = {}
    for nodeId,node in pairs(self.nodes) do
        if node.type == nodeType then
            list[#list+1] = node
        end
    end
    return list
end

--- ""
--@param[type=string] nodeType ""
--@param[type=string] strategy ""(random="",busyness="")
--@return[type=string] ""id
function NodeMgr:alloc(nodeType,strategy)
    local nodes = self:getNodesOfType(nodeType)
    if not next(nodes) then
        return nil
    end
    strategy = strategy or "busyness"
    local node
    if strategy == "random" then
        node = table.choose(nodes)
    elseif strategy == "busyness" then
        table.sort(nodes,function (a,b)
            if a.busyness == b.busyness then
                return false
            end
            return a.busyness < b.busyness
        end)
        node = nodes[1]
    else
        error("invalid strategy: " .. strategy)
    end
    return node.id
end

function NodeMgr:broadcastToClient(cmd,args)
    for nodeId,node in pairs(self.nodes) do
        if node.type == "game" then
            gg.cluster:send(node.id,".game","api","broadcastToClient",cmd,args)
        end
    end
end

function NodeMgr:isDown(node)
    if gg.actor.heartbeatInterval * (gg.actor.heartbeatCount - node.heartbeatCount) > 20000 then
        -- 20s""
        return true
    end
    return false
end

function NodeMgr:onHeartbeat()
    for nodeId,node in pairs(self.nodes) do
        if self:isDown(node) then
            self:logout(nodeId)
        end
    end
end


return NodeMgr