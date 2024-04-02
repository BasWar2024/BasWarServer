-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

--""
function api.playerLogin(pid)
    
end

--""
function api.playerLogout(pid)
    
end

function api.addChatMsg(pid, chatMsg, unionId)
    return gg.chatMgr:addChatMsg(pid, chatMsg, unionId)
end

function api.addSysMsg(sysMsg)
    return gg.chatMgr:addSysMsg(sysMsg)
end

function api.queryWorldChatMsgs(pid, msgId)
    return gg.chatMgr:queryWorldChatMsgs(pid, msgId)
end

function api.queryUnionChatMsgs(pid, unionId, msgId)
    return gg.chatMgr:queryUnionChatMsgs(pid, unionId, msgId)
end

return api