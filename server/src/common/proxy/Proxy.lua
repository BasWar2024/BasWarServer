local Proxy = class("Proxy")

function Proxy:ctor(node,address)
    self.myNode = skynet.config.id
    self.node = node or self.myNode
    self.address = assert(address)
end

function Proxy:isLocal()
    return self.myNode == self.node
end

function Proxy:call(cmd,...)
    if self.myNode ~= self.node then
        return gg.cluster:call(self.node,self.address,cmd,...)
    else
        return gg.internal:call(self.address,cmd,...)
    end
end

function Proxy:callx(cmd,...)
    if self.myNode ~= self.node then
        return gg.cluster:callx(self.node,self.address,cmd,...)
    else
        return gg.internal:callx(self.address,cmd,...)
    end
end

function Proxy:pcall(cmd,...)
    return pcall(self.call,self,cmd,...)
end

function Proxy:xpcall(cmd,...)
    return xpcall(self.call,self,gg.onerror,cmd,...)
end

function Proxy:send(cmd,...)
    if self.myNode ~= self.node then
        return gg.cluster:send(self.node,self.address,cmd,...)
    else
        return gg.internal:send(self.address,cmd,...)
    end
end

function Proxy:sendx(callback,cmd,...)
    if self.myNode ~= self.node then
        return gg.cluster:sendx(callback,self.node,self.address,cmd,...)
    else
        return gg.internal:sendx(callback,self.address,cmd,...)
    end
end

-- send
function Proxy:rawSend(cmd,...)
    if self.myNode ~= self.node then
        return cluster.send(self.node,self.address,"cluster",self.node,self.address,cmd,...)
    else
        return skynet.send(self.address,"lua","internal",cmd,...)
    end
end

function Proxy:timeout_call(ti,cmd,...)
    if self.myNode ~= self.node then
        return gg.cluster:timeout_call(ti,self.node,self.address,cmd,...)
    else
        return gg.internal:timeout_call(ti,self.address,cmd,...)
    end
end

return Proxy