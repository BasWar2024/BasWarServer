--- "",""id""
--@script gg.base.sync
--@author sundream
--@release 2018/12/25 10:30:00
local queue = require "skynet.queue"
local csync = class("csync")

function csync:ctor()
    self.tasks = {}
    self.lockers = {}
    self.lockerPool = {}
end

function csync:getLocker(id)
    local locker = self.lockers[id]
    if not locker then
        locker = table.remove(self.lockerPool, 1)
        if locker == nil then
            locker = {ref = 0,  lock = queue()}
        end
        self.lockers[id] = locker
    end
    locker.ref = locker.ref + 1
    return locker
end

function csync:releaseLocker(id)
    local locker = self.lockers[id]
    if not locker then
        return
    end
    locker.ref = locker.ref - 1
    if locker.ref > 0 then
        return
    end
    self.lockers[id] = nil
    table.insert(self.lockerPool, locker)
end

function csync:_once_do(onerror, id, func, ...)
    local locker = self:getLocker(id)
    local rettbl = table.pack(locker.lock(function(func, ...)
        return xpcall(func, onerror or debug.traceback, ...)
    end, func, ...))
    self:releaseLocker(id)
    return table.unpack(rettbl, 1, rettbl.n)
end

--- ""id""
--@param[type=int|string] id ""ID
--@param[type=func] func ""
--@param[opt] ... func""
--@return[type=bool] ""
--@return func""
--@usage
--  local sync = ggclass.csync.new()
--  local id = string.format("player.%s",pid)
--  local ok,player = sync.once_do(id,gg.playermgr._loadplayer,gg.playermgr,id)
function csync:once_do(id,func,...)
    return self:_once_do(gg.onerror, id, func, ...)
end

-- function csync:_once_do(onerror,id,func,...)
--     local tasks = self.tasks
--     local task = tasks[id]
--     if not task then
--         task = {
--             co = coroutine.running(),
--             waiting = {},
--             result = nil,
--         }
--         tasks[id] = task
--         local rettbl = table.pack(xpcall(func,onerror or debug.traceback,...))
--         task.result = rettbl
--         local waiting = task.waiting
--         tasks[id] = nil
--         if next(waiting) then
--             for i,co in ipairs(waiting) do
--                 skynet.wakeup(co)
--             end
--         end
--         return table.unpack(task.result,1,task.result.n)
--     else
--         local co = coroutine.running()
--         table.insert(task.waiting,co)
--         skynet.wait(co)
--         return table.unpack(task.result,1,task.result.n)
--     end
-- end

return csync
