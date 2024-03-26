local cplayer = reload_class("cplayer")

function cplayer:subscribeBrief()
    -- "",""+""
    local brief = gg.briefMgr:getBriefObj(self.pid)
    brief:subscribe(self.pid)
end

function cplayer:unsubscribeBrief()
    local brief = gg.briefMgr:getBriefObj(self.pid)
    brief:unsubscribe(self.pid)
end

return cplayer