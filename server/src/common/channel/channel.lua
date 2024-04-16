local cchannel = class("cchannel")

function cchannel:ctor(param)
    self.id = param.id
    self.dispatch = param.dispatch
    self.kind = param.kind
    self.subscribers = {}
end

function cchannel:subscribe(who)
    self.subscribers[who] = true
end

function cchannel:unsubscribe(who)
    self.subscribers[who] = nil
end

function cchannel:destroy()
    self:publish_queue()
    self.queue = nil
    local timer = self.timer
    self.timer = nil
    if timer then
        gg.timer:deltimer(timer)
    end
end

function cchannel:publish(...)
    if self.queue then
        if self.queue_max_length == -1 or #self.queue < self.queue_max_length then
            table.insert(self.queue,table.pack(...))
        else
            self:publish_queue()
        end
        return
    end
    self:_publish(false,...)
end

function cchannel:_publish(is_queue,...)
    if not self.dispatch then
        return
    end
    for who in pairs(self.subscribers) do
        self.dispatch(self,who,is_queue,...)
    end
end

function cchannel:publish_queue()
    if not self.queue or not next(self.queue) then
        return
    end
    local queue = self.queue
    self.queue = {}
    self:_publish(true,queue)
end

--- ""
--@param[type=int] time ""("")
--@param[type=int] max_length ""("")
function cchannel:mark_delay(time,max_length)
    self:destroy()
    if time <= 0 then
        return
    end
    self.queue = {}
    self.queue_max_length = max_length
    self:start_timer_delay_publish(time)
end

function cchannel:start_timer_delay_publish(time)
    self.timer = gg.timer:timeout2(time,function ()
        self:start_timer_delay_publish(time)
    end)
    self:publish_queue()
end

return cchannel