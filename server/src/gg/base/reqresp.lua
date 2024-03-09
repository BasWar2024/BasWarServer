-- 

local creqresp = class("creqresp")
creqresp.ANSWER_TIMEOUT = 98            -- 
creqresp.ANSWER_CLOSE = 99              -- 


function creqresp:ctor()
    self.sessions = {}
    self.id = 0
end

function creqresp:genid()
    self.id = self.id + 1
    return self.id
end

function creqresp:get_session(id)
    return self.sessions[id]
end

function creqresp:req(request,on_response,on_close)
    local id
    if on_response then
        id = self:genid()
    else
        id = 0
    end
    if id ~= 0 then
        request.id = id
        request.lifetime = request.lifetime or -1
        request.buttons = request.buttons or {}
        self.sessions[id] = {
            id = id,
            request = request,
            on_response = on_response,
            on_close = on_close,
            createTime = os.time(),
        }
        self:start_timer(self.sessions[id])
    end
    return id
end

function creqresp:start_timer(session)
    local id = session.id
    local lifetime = session.request.lifetime or -1
    if lifetime < 0 then
        lifetime = 60*5
    end
    gg.timer:timeout2(lifetime*1000,function ()
        if self.sessions[id] then
            self:close(id,creqresp.ANSWER_TIMEOUT)
        end
    end)

    local buttons = session.request.buttons
    for buttonid,button in ipairs(buttons) do
        local timeout = button.timeout
        local answer = buttonid
        if timeout and timeout ~= -1 then
            gg.timer:timeout2(timeout*1000,function ()
                if self.sessions[id] then
                    for i,resp in ipairs(session.request.answers) do
                        if resp.answer == 0 then
                            self:_resp(session,{pid=resp.pid,answer=answer})
                        end
                    end
                end
            end)
        end
    end
end

function creqresp:resp(id,response)
    local session = self.sessions[id]
    if session then
        self:_resp(session,response)
    end
    return session
end

function creqresp:_resp(session,response)
    local id = session.id
    response.answer = self:ajust_answer(session,response.answer)
    local request = session.request
    local valid = false
    for i,resp in ipairs(request.answers) do
        if resp.pid == response.pid then
            resp.answer = response.answer
            valid = true
            break
        end
    end
    if not valid then
        return
    end
    local on_response = session.on_response
    if on_response then
        on_response(session.request,response)
    end
    if request.auto_close then
        self:close(id)
    end
end

function creqresp:ajust_answer(session,answer)
    if answer == creqresp.ANSWER_TIMEOUT then
        answer = session.timeout_button or answer
    elseif answer == creqresp.ANSWER_CLOSE then
        answer = session.close_botton or answer
    end
    return answer
end

function creqresp:close(id,answer)
    local session = self.sessions[id]
    if not session then
        return
    end
    self.sessions[id] = nil
    answer = answer or creqresp.ANSWER_CLOSE
    answer = self:ajust_answer(session,answer)

    local request = session.request
    for i,resp in ipairs(request.answers) do
        if resp.answer == 0 then
            self:_resp(session,{pid = resp.pid,answer = answer})
        end
    end
    if session.on_close then
        session.on_close(request)
    end
end

return creqresp