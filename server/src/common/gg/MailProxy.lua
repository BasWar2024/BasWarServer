local MailProxy = class("MailProxy")

function MailProxy:ctor()
    self.node = skynet.config.id
    local centerserver = skynet.config.centerserver or self.node
    self.mailProxy = ggclass.Proxy.new(centerserver,".mail")
    self.isLocal = self.mailProxy:isLocal()
    self.address = skynet.localname(".rescenter")
    self.pidMailInit = {}
    self.pidMailIds = {}            -- key:pid, value={id1,id2...}
end

function MailProxy:isPlayerMailInit(pid)
    return self.pidMailInit[pid]
end

function MailProxy:getPlayerMails(pid, lastSysMailId, lastPlyMailId)
    -- if not self.pidMailInit[pid] then
        self:send("getPlayerMails", pid, lastSysMailId, lastPlyMailId)
    -- end
end

function MailProxy:setPlayerMailInit(pid)
    self.pidMailInit[pid] = true
end

function MailProxy:delPlayerMails(pid, delPlyMailIds)
    if table.count(delPlyMailIds) == 0 then
        return
    end
    self:send("delPlayerMails", pid, delPlyMailIds)
end

function MailProxy:doPlayerCmd(pid, cmd, ...)
    local player = gg.playermgr:getplayer(pid)
    if not player then
        return nil
    end
    if player.mailBag[cmd] then
        player.mailBag[cmd](player.mailBag, ...)
    end
end

function MailProxy:broadcastSysMail()
    local pidList = gg.playermgr:allplayer()
    if #pidList == 0 then
        return
    end
    skynet.fork(function()
        self:_onlinePlayerCmd(pidList, "newMailsNotice")
    end)
end

function MailProxy:_onlinePlayerCmd(pidList, cmd, ...)
    for _, pid in ipairs(pidList) do
        local player = gg.playermgr:getplayer(pid)
        if player and player.linkobj then
            if player.mailBag[cmd] then
                player.mailBag[cmd](player.mailBag, ...)
            end
        end
    end
end

function MailProxy:playerLogin(pid)
    self.mailProxy:send("api", "playerLogin", pid)
end

function MailProxy:playerLogout(pid)
    self.mailProxy:send("api", "playerLogout", pid)
end

function MailProxy:call(cmd, ...)
    return self.mailProxy:call("api", cmd, ...)
end

function MailProxy:send(cmd, ...)
    return self.mailProxy:send("api", cmd, ...)
end

return MailProxy
