openui = openui or {}

--[[
function onBuySomething(window,response)
    local pid = response.pid
    local player = gg.playermgr:getplayer(pid)
    local answer = response.answer
    elseif answer == 1 then             -- button 1
    elseif answer == 2 then             -- button 2
    end
end

openui.messageBox(player,{
                type = constant.UI_MB_LACK_CONDITION,
                title = i18n.format(""""),
                content = i18n.format("""100"":"),
                buttons = {
                    openui.button(i18n.format("""")),
                    openui.button(i18n.format(""""),10),
                },
                timeout_button = 2,  -- ""2
                close_button = 2,    -- ""2
                auto_close = true,   -- ""
                ,onBuySomething)
--]]
function openui.messageBox(player,window,onResponse)
    window.lifetime = window.lifetime or 300
    window.forward = {
        node = skynet.config.id,
        address = skynet.self(),
    }
    window.answers = {{pid=player.pid,answer=0}}
    if window.auto_close == nil then
        window.auto_close = true
    end
    local onClose = window.on_close or openui.onClose
    window.on_close = nil
    local id = gg.reqresp:req(window,onResponse,onClose)
    openui.showMessageBox(player,window)
    return id
end

function openui.showMessageBox(player,window)
    local lang = player.lang
    local packWindow = {}
    packWindow.type = assert(window.type)
    if window.title then
        packWindow.title = assert(i18n.translateto(lang,window.title))
    end
    if window.content then
        packWindow.content = assert(i18n.translateto(lang,window.content))
    end
    if window.attach then
        packWindow.attach = cjson.encode(window.attach)
    end
    packWindow.buttons = {}
    for i,button in ipairs(window.buttons or {}) do
        local content = button.content
        if type(content) == "table" or type(content) == "userdata" then
            content = i18n.translateto(lang,button.content)
        end
        packWindow.buttons[i] = {
            content = content,
            timeout = button.timeout,
        }
    end
    packWindow.timeout_button = window.timeout_button
    packWindow.close_button = window.close_button
    if window.forward then
        packWindow.forward = cjson.encode(window.forward)
    end
    if window.tips then
        packWindow.tips = assert(i18n.translateto(lang,window.tips))
    end
    packWindow.id = window.id
    packWindow.lifetime = window.lifetime
    packWindow.answers = window.answers
    gg.client:send(player.linkobj,"S2C_MessageBox",packWindow)
end

function openui.button(content,timeout)
    return {
        content = content,
        timeout = timeout,
    }
end

function openui.getMessageBox(boxId)
    return gg.reqresp:get_session(boxId)
end

-- ""onPlayerResponse
-- ""onAllResponse
-- callback""：1： window
-- callback""：2： answers -- {{pid=xxx,answer=xxx},...}
function openui.messageBoxToPlayers(players,window,onPlayerResponse,onAllResponse)
    local answers = {}
    for _,player in pairs(players) do
        answers[#answers+1] = {
            pid = player.pid,
            answer = 0,
        }
    end
    window.answers = answers
    window.lifetime = window.lifetime or 300
    window.forward = {
        node = skynet.config.id,
        address = skynet.self(),
    }
    window.auto_close = false
    local function _callback(window,response)
        --[[
        for _,player in pairs(players) do
            gg.client:send(player.linkobj,"S2C_MessageBoxAnswer",{
                id = window.id,
                answers = window.answers,
            })
        end
        ]]
        if onPlayerResponse then
            onPlayerResponse(window,response)
        end
        local isAllResponse = true
        for i,resp in ipairs(window.answers) do
            if resp.answer == 0 then
                isAllResponse = false
            end
        end
        if not isAllResponse then
            return
        end
        openui.closeMessageBox(window.id)
        if onAllResponse then
            onAllResponse(window,window.answers)
        end
    end
    local onClose = window.on_close or openui.onClose
    window.on_close = nil
    local id = gg.reqresp:req(window,_callback,onClose)
    for _,player in pairs(players) do
        openui.showMessageBox(player,window)
    end
    return id
end

function openui.closeMessageBox(id)
    gg.reqresp:close(id)
end

function openui.onClose(window)
    for i,resp in ipairs(window.answers) do
        local pid = resp.pid
        local player
        if ggmap then
            player = ggmap:getMaster(pid)
        elseif gg.playermgr then
            player = gg.playermgr:getplayer(pid)
        else
            player = gg.briefMgr:getBrief(pid)
        end
        if player then
            gg.client:send(player.linkobj,"S2C_CloseMessageBox",{id=window.id})
        end
    end
end

return openui
