--- ,skynet.queue,
--@author sundream
--@script common.gg.ClusterQueue
--@release 2021/1/25 16:15:00
local skynet = require "skynet"
local ClusterQueue = class("ClusterQueue")

function ClusterQueue:ctor(localNode,remoteNode,remoteAddress)
    self.localNode = localNode
    self.localAddress = skynet.self()
    self.remoteNode = remoteNode or localNode
    self.remoteAddress = remoteAddress
    self.locks = {}
    self.recoverPointId = 0
end

function ClusterQueue:newLock(lockId)
    return {
        lockId = lockId,
        createTime = skynet.timestamp(),
        waiting = {},
    }
end

function ClusterQueue:_lock(node,address,recoverPointId,lockId)
    local lock = self.locks[lockId]
    if not lock then
        lock = self:newLock(lockId)
        self.locks[lockId] = lock
        return true
    else
        table.insert(lock.waiting,{
            node = node,
            address = address,
            recoverPointId = recoverPointId,
        })
        return false
    end
end

function ClusterQueue:_unlock(lockId)
    local lock = self.locks[lockId]
    if not lock then
        return
    end
    if not next(lock.waiting) then
        self.locks[lockId] = nil
        return
    end
    local wait = table.remove(lock.waiting,1)
    if wait.node == self.localNode and wait.address == self.localAddress then
        skynet.wakeup(wait.recoverPointId)
    else
        gg.cluster:send(wait.node,wait.address,"api","wakeup",wait.recoverPointId)
    end
end

function ClusterQueue:genRecoverPointId()
    self.recoverPointId = self.recoverPointId + 1
    return self.recoverPointId
end

function ClusterQueue:lock(lockId)
    local recoverPointId = self:genRecoverPointId()
    if self.localNode == self.remoteNode and self.localAddress == self.remoteAddress then
        local ok = self:_lock(self.localNode,self.localAddress,recoverPointId,lockId)
        if not ok then
            skynet.wait(recoverPointId)
        end
    else
        local ok = gg.cluster:call(self.remoteNode,self.remoteAddress,"api","lock",self.localNode,self.localAddress,recoverPointId,lockId)
        if not ok then
            skynet.wait(recoverPointId)
        end
    end
end

function ClusterQueue:unlock(lockId)
    if self.localNode == self.remoteNode and self.localAddress == self.remoteAddress then
        self:_unlock(lockId)
    else
        gg.cluster:send(self.remoteNode,self.remoteAddress,"api","unlock",lockId)
    end
end

function ClusterQueue:xpcallReturn(lockId,ok, ...)
    self:unlock(lockId)
    assert(ok,(...))
    return ...
end

--- skynet.queue,
--@param[type=string|int] lockId id,id
--@param[type=func] func 
--@param ... 
--@return 
function ClusterQueue:queue(lockId,func,...)
    self:lock(lockId)
    return self:xpcallReturn(lockId,xpcall(func,debug.traceback,...))
end

return ClusterQueue
