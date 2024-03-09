--- ,id
--@script gg.base.sync
--@author sundream
--@release 2018/12/25 10:30:00
local queue = require "skynet.queue"
local csync = class("csync")

function csync:ctor()
    self.tasks = {}
end

--- id
--@param[type=int|string] id ID
--@param[type=func] func 
--@param[opt] ... func
--@return[type=bool] 
--@return func
--@usage
--  local sync = ggclass.csync.new()
--  local id = string.format("player.%s",pid)
--  local ok,player = sync.once_do(id,gg.playermgr._loadplayer,gg.playermgr,id)
function csync:once_do(id,func,...)
    return self:_once_do(gg.onerror,id,func,...)
end

function csync:_once_do(onerror,id,func,...)
    local tasks = self.tasks
    local task = tasks[id]
    if not task then
        task = {
            co = coroutine.running(),
            waiting = {},
            result = nil,
        }
        tasks[id] = task
        --print("[sync.once_do] call",id)
        local rettbl = table.pack(xpcall(func,onerror or debug.traceback,...))
        task.result = rettbl
        local waiting = task.waiting
        tasks[id] = nil
        --print("[sync.once_do] call return",id,table.dump(task))
        if next(waiting) then
            for i,co in ipairs(waiting) do
                skynet.wakeup(co)
            end
        end
        return table.unpack(task.result,1,task.result.n)
    else
        local co = coroutine.running()
        table.insert(task.waiting,co)
        --print("[sync.once_do] wait",id)
        skynet.wait(co)
        --print("[sync.once_do] wait return",id,table.dump(task))
        return table.unpack(task.result,1,task.result.n)
    end
end

return csync
