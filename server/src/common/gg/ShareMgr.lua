local ShareMgr = class("ShareMgr")

--share,
function ShareMgr:ctor(cnt)
    self.cnt = cnt or 10
    self.shareList = {}
    self.index = 1
    self:init()
end

function ShareMgr:init()
    for i = 1, self.cnt do
        local name = ".share" .. i
        local address = skynet.newservice("app/share/main", name)
        table.insert(self.shareList, address)
    end
end

function ShareMgr:getShare()
    local address = self.shareList[self.index]
    self.index = self.index + 1
    if self.index > self.cnt then
        self.index = 1
    end
    return address
end

function ShareMgr:getShareList()
    return self.shareList
end

function ShareMgr:call(cmd,...)
    return gg.internal:call(self:getShare(),"api",cmd,...)
end

function ShareMgr:send(cmd,...)
    return gg.internal:send(self:getShare(),"api",cmd,...)
end

return ShareMgr