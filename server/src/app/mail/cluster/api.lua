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
    gg.mailMgr:playerLogin(pid)
end

--""
function api.playerLogout(pid)
    gg.mailMgr:playerLogout(pid)
end

function api.gmSendMail(sendId, sendName, toPidList, mailData)
    -- return gg.mailMgr:gmSendMail(sendId, sendName, toPidList, mailData)
    local ok, ret1, ret2 = gg.sync:once_do("gmSendMail", gg.mailMgr.gmSendMail, gg.mailMgr, sendId, sendName, toPidList, mailData)
    if not ok then
        return false
    end
    return ret1, ret2
end

function api.gmGetMails(sendId, sendName, isDetail)
    return gg.mailMgr:gmGetMails(sendId, sendName, isDetail)
end

function api.gmGetMailsByPage(sendId, sendName, isDetail, pageNo, pageSize, beginDate, endDate)
    return gg.mailMgr:gmGetMailsByPage(sendId, sendName, isDetail, pageNo, pageSize, beginDate, endDate)
end

function api.gmDelMail(id)
    return gg.mailMgr:gmDelMail(id)
end

--""
function api.getPlayerMails(pid, lastSysMailId, lastPlyMailId)
    return gg.mailMgr:getPlayerMails(pid, lastSysMailId, lastPlyMailId)
end

function api.delPlayerMails(pid, delPlyMailIds)
    return gg.mailMgr:delPlayerMails(pid, delPlyMailIds)
end

function api.checkAndGetPlayerMails(pid, lastSysMailId, lastPlyMailId)
    return gg.mailMgr:checkAndGetPlayerMails(pid, lastSysMailId, lastPlyMailId)
end

return api