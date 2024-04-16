
---"": "","",""/"",""centerserver""
---@script common.brief.briefMgr
---@author sundream
---@release 2019/11/07 19:50:00
---@usage:
---"":
---gg.briefMgr:getBrief(pid)  <=> ""("")
---gg.proxy.center:call("api","getBrief",pid)  <=> ""("")
---gg.proxy.center:send("api","setBriefAttrs",pid,attrs)  <=> ""
---gg.proxy.center:send("api","delBriefAttrs",pid,{"key1","key2"})  <=> ""

local BriefMgr = class("BriefMgr")

function BriefMgr:ctor()
    self.node = skynet.config.id
    local centerserver = skynet.config.centerserver or self.node
    self.centerProxy = ggclass.CenterProxy.new()
    self.isHost = self.node == centerserver
    self.address = skynet.globaladdress()
    self.briefs = {}
    self.event  = ggclass.Event.new(self)
end

-- ""brief""
function BriefMgr:start()
    function gg.api.setBriefAttrs(...)
        self:setBriefAttrs(...)
    end

    function gg.api.delBriefAttrs(...)
        self:delBriefAttrs(...)
    end
end

function BriefMgr:exit()
    self:unsubscribeAllBrief()
end

-- "","",""getBriefObj""!
function BriefMgr:getBrief(pid)
    local brief = self:getBriefObj(pid)
    if not brief then
        return
    end
    return brief:pack()
end

function BriefMgr:loadBrief(pid)
    local brief = ggclass.Brief.new(pid)
    if self.isHost then
        brief:load_from_db()
    else
        local data = self.centerProxy:call("getBrief",pid)
        assert(data,"unknow brief:" .. pid)
        brief:deserialize(data)
    end
    return brief
end

function BriefMgr:getBriefObj(pid)
    local brief = self.briefs[pid]
    if not brief then
        local id = string.format("brief.%s",pid)
        local ok
        ok,brief = gg.sync:_once_do(nil,id,self.loadBrief,self,pid)
        if not ok then
            return
        end
        -- double check
        if not self.briefs[pid] then
            self:addBrief(brief)
        end
    end
    return brief
end

function BriefMgr:setBriefAttrs(pid,attrs)
    local brief = self.briefs[pid]
    if not brief then
        return
    end
    brief:_set(attrs)
    self.event:dispatchEvent("onSetBriefAttrs",brief,attrs)
end

function BriefMgr:delBriefAttrs(pid,keys)
    local brief = gg.briefMgr.briefs[pid]
    if not brief then
        return
    end
    brief:_del(keys)
    self.event:dispatchEvent("onDelBriefAttrs",brief,keys)
end

function BriefMgr:addBrief(brief)
    local pid = assert(brief.pid)
    --logger.print("addBrief",pid)
    self.briefs[pid] = brief
    if self.isHost then
        brief.savename = string.format("brief.%s",pid)
        gg.savemgr:autosave(brief)
    else
        self.centerProxy:send("subscribeBrief",self.address,pid)
    end
    self.event:dispatchEvent("onAddBrief",brief)
end

function BriefMgr:delBrief(pid)
    local brief = self.briefs[pid]
    if not brief then
        return
    end
    --logger.print("delBrief",pid)
    self.briefs[pid] = nil
    if self.isHost then
        gg.savemgr:nowsave(brief)
        gg.savemgr:closesave(brief)
    else
        self.centerProxy:send("unsubscribeBrief",self.address,pid)
    end
    self.event:dispatchEvent("onDelBrief",pid)
end

function BriefMgr:unsubscribeAllBrief()
    if self.isHost then
        return
    end
    self.centerProxy:send("unsubscribeBriefs",self.address,table.keys(self.briefs))
end

function BriefMgr:resubscribeAllBrief()
    if self.isHost then
        return
    end
    local pids = table.keys(gg.briefMgr.briefs)
    self.centerProxy:send("subscribeBriefs",self.address,pids)
end

return BriefMgr