--- 
--@script app.game.player.playermgr
--@release 2021 1 27 20:40:00

local cplayermgr = class("cplayermgr")

--/*
-- 
--*/
function cplayermgr:ctor()
    self.onlinenum = 0
    self.onlinelimit = tonumber(skynet.config.onlinelimit) or 10240
    self.players = ggclass.ccontainer.new()
    self.id_player = ggclass.ccontainer.new()
    -- token
    self.tokens = ggclass.cthistemp.new()
    --,900s
    self.last_tick = {}
end

---
--@param[type=int] pid id
--@return[type=table] |nil
function cplayermgr:getplayer(pid)
    return self.players:get(pid)
end

function cplayermgr:getplayerbyid(id)
    return self.id_player:get(id)
end

function cplayermgr:setplayerlasttick(pid)
    local player = self:getplayer(pid)
    if not player then
        self.last_tick[pid] = nil
        return
    end
    if player.linkobj then
        self.last_tick[pid] = nil
        return
    end
    self.last_tick[pid] = skynet.timestamp()
end

function cplayermgr:onMinute()
    local overTick = 900 * 1000          -- 900
    local nowTick = skynet.timestamp()
    local overPidList = {}
    for pid, lastTick in pairs(self.last_tick) do
        if (nowTick - lastTick) > overTick then
            table.insert(overPidList, pid)
        end
    end
    for _, pid in ipairs(overPidList) do
        local player = self:getonlineplayer(pid)
        if player then
            --
            self.last_tick[pid] = nil
        else
            self:delplayer(pid)
        end
    end
end

function cplayermgr:addplayer(player)
    local pid = assert(player.pid)
    self.players:add(player,pid)
    local id = player.id
    if id then
        self.id_player:add(player,id)
    end
    if player.linkobj then
        self.onlinenum = self.onlinenum + 1
    else
        -- 
        player.is_offline_player = true
        player.no_save_to_db = true
    end
    player.savename = string.format("player.%s",pid)
    gg.savemgr:autosave(player)
end

-- ,self.kick
function cplayermgr:delplayer(pid)
    local player = self:getplayer(pid)
    if player then
        if not player.is_offline_player then
            self.onlinenum = self.onlinenum - 1
        end
        gg.savemgr:nowsave(player)
        gg.savemgr:closesave(player)
        self.players:del(pid)
        local id = player.id
        if id then
            self.id_player:del(id)
        end
    end
    self.last_tick[pid] = nil
    return player
end

---
--@param[type=int] pid id
--@return[type=table] |nil
function cplayermgr:getonlineplayer(pid)
    local player = self:getplayer(pid)
    if player then
        if player.linkobj then
            return player
        end
    end
end

function cplayermgr:bind_linkobj(player,linkobj)
    if player.linkobj then
        self:unbind_linkobj(player)
    end
    --logger.logf("info","playermgr","op=bind_linkobj,pid=%s,linkid=%s,linktype=%s,ip=%s,port=%s",
    --  player.pid,linkobj.linkid,linkobj.linktype,linkobj.ip,linkobj.port)
    linkobj.pid = player.pid
    linkobj.id = player.id

    player.linkobj = linkobj
    player.is_offline_player = nil
    player.no_save_to_db = nil
    self:transfer_mark(player,linkobj)
end

function cplayermgr:unbind_linkobj(player)
    local linkobj = assert(player.linkobj)
    --logger.logf("info","playermgr","op=unbind_linkobj,pid=%s,linkid=%s,linktype=%s,ip=%s,port=%s",
    --  player.pid,linkobj.linkid,linkobj.linktype,linkobj.ip,linkobj.port)
    player.linkobj.pid = nil
    player.linkobj.id = nil

    player.linkobj = nil
end

function cplayermgr:allplayer()
    return table.keys(self.players.objs)
end

---
--@param[type=int] pid id
--@param[type=string] reason 
function cplayermgr:kick(pid,reason)
    reason = reason or "force logout"
    local player = self:getplayer(pid)
    if not player then
        return
    end
    if player.linkobj then
        if i18n then
            reason = i18n.translateto(player.lang,reason)
        end
        gg.client:send(player.linkobj,"S2C_Kick",{reason=reason})
    end
    player.force_exitgame = true
    if player:isdisconnect() then
        -- 
        -- 
        player:exitgame(ggclass.cplayer.LOGOUT_TYPE_KICK)
    else
        player:disconnect(ggclass.cplayer.LOGOUT_TYPE_KICK)
    end
end

---
--@param[type=string] reason 
function cplayermgr:kickall(reason)
    --loginqueue.clear()
    local allplayer = self:allplayer()
    local count = #allplayer
    if count == 0 then
        return
    end
    local co = coroutine.running()
    for _,pid in ipairs(allplayer) do
        skynet.fork(function()
            xpcall(self.kick,gg.onerror,self,pid,reason)
            count = count - 1
            if count == 0 then
                skynet.wakeup(co)
            end
        end)
    end
    skynet.wait()
end

function cplayermgr:createplayer(pid,conf)
    --logger.logf("info","playermgr","op=createplayer,pid=%d,player=%s",pid,conf)
    local player = ggclass.cplayer.new(pid)
    player:create(conf)
    player.savename = string.format("player.%s",pid)
    gg.savemgr:oncesave(player)
    gg.savemgr:nowsave(player)
    gg.savemgr:closesave(player)
    return player
end

function cplayermgr:_loadplayer(pid)
    local player = ggclass.cplayer.new(pid)
    player:load_from_db()
    return player
end

-- nil
function cplayermgr:recoverplayer(pid)
    assert(tonumber(pid),"invalid pid:" .. tostring(pid))
    assert(self:getplayer(pid) == nil,"try recover a loaded player:" .. tostring(pid))
    local id = string.format("player.%s",pid)
    local ok,player = gg.sync:once_do(id,self._loadplayer,self,pid)
    assert(ok,player)
    if player:isloaded() then
        return player
    else
        return nil
    end
end

-- ,
function cplayermgr:loadplayer2(packPlayer,pack_callback)
    local pid = packPlayer.pid
    local player = self:getplayer(pid)
    if not player then
        player = ggclass.cplayer.new(pid)
    end
    player.linkobj = packPlayer.linkobj
    player.fromServerId = packPlayer.fromServerId
    player:deserialize(packPlayer)
    if not self:getplayer(pid) then
        self:addplayer(player)
    end
    if pack_callback then
        local callback = gg.unpack_function(pack_callback)
        xpcall(callback,gg.onerror)
    end
end

function cplayermgr:isloading(pid)
    local id = string.format("player.%s",pid)
    if gg.sync.tasks[id] then
        return true
    end
    return false
end

---()
--@param[type=int] pid id
--@param[type=table] |nil=
--@usage
--unloadplayer,gg.playermgr:loadplayer_callback
function cplayermgr:loadplayer(pid)
    local player = self:getplayer(pid)
    if player then
        return player
    end
    player = self:recoverplayer(pid)
    if not player then
        return
    end
    if not self:getplayer(pid) then
        self:addplayer(player)
    end
    return player
end

---(loadplayer)
--@param[type=int] pid id
function cplayermgr:unloadplayer(pid)
    local player = self:getplayer(pid)
    if not player then
        return
    end
    if not player.is_offline_player then
        return
    end
    self:delplayer(pid)
end

---,,
--@param[type=int] pid id
--@param[type=func] callback 
--@return 
function cplayermgr:loadplayer_callback(pid,callback)
    local player = self:loadplayer(pid)
    if not player then
        return
    end
    local result = {xpcall(callback,gg.onerror,player)}
    self:unloadplayer(pid)
    return table.unpack(result)
end

--/*
-- 
--*/
function cplayermgr:transfer_mark(player,linkobj)
    player.linktype = linkobj.linktype
    player.linkid = linkobj.linkid
    player.ip = linkobj.ip
    player.port = linkobj.port
    player.version = linkobj.version
    player.debuglogin = linkobj.debuglogin

    local device = linkobj.device
    linkobj.device = nil
    if device then
        player.device = device
        if player.device.lang then
            player.lang = player.device.lang
        end
    end
    -- 
    local kuafu_forward = linkobj.kuafu_forward
    linkobj.kuafu_forward = nil
    player.kuafu_forward = kuafu_forward
    player.fromServerId = player.kuafu_forward and player.kuafu_forward.fromServerId
end

function cplayermgr:broadcast(func)
    for i,pid in ipairs(self:allplayer()) do
        local player = self:getplayer(pid)
        if player then
            xpcall(func,gg.onerror,player)
        end
    end
end

-- 
function cplayermgr:tuoguannum(channelId)
    channelId = channelId or 0
    local tuoguannum = 0
    for pid,player in pairs(self.players.objs) do
        if not player.linkobj then
            if channelId == 0 or player.device.channelId then
                tuoguannum = tuoguannum + 1
            end
        end
    end
    return tuoguannum
end

return cplayermgr