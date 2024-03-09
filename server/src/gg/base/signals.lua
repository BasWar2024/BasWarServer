local csignals = class("csignals")

function csignals:ctor(id)
    self.id = id or tostring(self)
    self.timeout = {}       -- 
    self.signals = {}
end

--- ID
--@param ... 
--@usage
--local signal = self:signal("lucky number",8888)
function csignals:signal(...)
    local keys = {...}
    table.insert(keys,self.id)
    return table.concat(keys,".")
end

--- 
--@param[type=string] signal 
--@param[type=int,opt] timeuot ,nil/<=0--
--@return[type=bool] 
--@return wakeup
function csignals:wait(signal,timeout)
    local timer_id
    if timeout and timeout > 0 then
        timer_id = skynet.timeout(timeout,function ()
            local data = self.signals[signal]
            if not data or data.timer_id ~= timer_id then
                return
            end
            self:timeout_wakeup(signal)
        end)
    end
    assert(self.signals[signal] == nil)
    self.signals[signal] = {
        timer_id = timer_id,
    }
    skynet.wait(signal)
    local data = self.signals[signal]
    assert(data)
    self.signals[signal] = nil
    return data.timeout,table.unpack(data.result)
end

function csignals:_wakeup(signal,timeout,...)
    local data = self.signals[signal]
    if data then
        if timeout == self.timeout then
            data.timeout = true
            data.result = table.pack(...)
        else
            data.timeout = false
            data.result = table.pack(timeout,...)
        end
        skynet.wakeup(signal)
    end
end

--- 
--@param[type=string] signal 
--@param ... 
function csignals:wakeup(signal,...)
    self:_wakeup(signal,...)
end

--- ,wait
--@param[type=string] signal 
function csignals:timeout_wakeup(signal)
    self:_wakeup(signal,self.timeout)
end

return csignals
