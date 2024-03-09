--- 
--@script app.player.delay_exitgame
--@author sundream
--@release 2019/06/18 17:30:00
--@usage
--function cplayer:try_set_exitgame_time()
--    local now = os.time()
--    local ok,delayTime = self:canDelayExitGame()
--    if ok then
--        local exitgame_time = self:get_exitgame_time()
--        if not exitgame_time or exitgame_time <= now then
--            self:set_exitgame_time(now+delayTime)
--        end
--    end
--end
--
--function cplayer:entergame(replace)
--    self:del_delay_exitgame()
--    -- 
--    self:onlogin(replace)
--end
--
--function cplayer:exitgame(reason)
--    -- ,
--    if not self.force_exitgame then
--        self:try_set_exitgame_time()
--        local ok,delay_time = self:need_delay_exitgame()
--        if ok then
--            self:delay_exitgame(delay_time)
--            return
--        end
--    end
--    -- keep before onlogout!
--    self:del_delay_exitgame()
--    -- 
--    self.force_exitgame = nil
--    xpcall(self.onlogout,gg.onerror,self,reason)
--    -- will call save_to_db
--    gg.playermgr:delplayer(self.pid)
--end

local cplayer = reload_class("cplayer")

--- (/)
--@return[type=bool] 
--@return[type=int] ,
function cplayer:need_delay_exitgame()
    if not self.exitgame_time then
        return false
    else
        local now = os.time()
        local delay_time = self.exitgame_time - now
        return delay_time > 0,delay_time
    end
end

--- 
--@return[type=int] 
function cplayer:get_exitgame_time()
    return self.exitgame_time
end

--- (),,
--@param[type=int] time 
--@return[type=int] (nil)
function cplayer:set_exitgame_time(time)
    if not self.exitgame_time or self.exitgame_time < time then
        self.exitgame_time = time
    end
    local delay_time = self.exitgame_time - os.time()
    self:delay_exitgame(delay_time)
    return self.exitgame_time
end

function cplayer.__exitgame(pid)
    local player = gg.playermgr:getplayer(pid)
    if player then
        player:exitgame("delay_exitgame")
    end
end

--- 
--@param[type=int,opt=60] delay_time 
--@return[type=int] ID
function cplayer:delay_exitgame(delay_time)
    if self.delay_exitgame_timerid then
        gg.timer:deltimer(self.delay_exitgame_timerid)
    end
    self.delay_exitgame_timerid = gg.timer:timeout(delay_time,gg.functor(cplayer.__exitgame,self.pid))
    return self.delay_exitgame_timerid
end

--- 
function cplayer:del_delay_exitgame()
    self.exitgame_time = nil
    if self.delay_exitgame_timerid then
        local timerid = self.delay_exitgame_timerid
        self.delay_exitgame_timerid = nil
        gg.timer:deltimer(timerid)
        return timerid
    end
end

function cplayer:try_set_exitgame_time()
    if not self.canDelayExitGame then
        return
    end
    local now = os.time()
    local ok,delayTime = self:canDelayExitGame()
    if ok then
        local exitgame_time = self:get_exitgame_time()
        if not exitgame_time or exitgame_time <= now then
            self:set_exitgame_time(now+delayTime)
        end
    end
end

return cplayer
