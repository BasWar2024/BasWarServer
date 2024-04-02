local OpCfgMgr = class("OpCfgMgr")

function OpCfgMgr:ctor(param)
    self.cache = {}
end

function OpCfgMgr:shutdown()
end

function OpCfgMgr:load_from_db()
end

function OpCfgMgr:save_to_db()

end
-----------------------------------------------
function OpCfgMgr:updateGameOpCfg(key, value)
    gg.centerProxy:send("broadCast2Game", "broadcastOpCfg", key, value)
end

function OpCfgMgr:getOpCfg(key)
    if not self.cache[key] then
        local value = gg.shareProxy:call("getOpCfg", key)
        if value then
            self.cache[key] = value
        end
    end
    if not self.cache[key] then
        return false, "no cfg"
    end
    return true,self.cache[key]
end

function OpCfgMgr:updateOpCfg(key, value)
    self.cache[key] = value
    self:updateGameOpCfg(key, value)
    return true
end
-----------------------------------------------
--""
function OpCfgMgr:onSecond()
end

function OpCfgMgr:onDayUpdate()
end

function OpCfgMgr:playerLogin(pid)
    
end

function OpCfgMgr:playerLogout(pid)
    
end

return OpCfgMgr