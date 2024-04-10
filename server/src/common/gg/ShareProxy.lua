local ShareProxy = class("ShareProxy")

function ShareProxy:ctor(cnt)
    self.shareList = {}
    self.index = 1

    if gg.standalone then
        cnt = cnt or 10
        self:createShare(cnt)
    end
end

function ShareProxy:createShare(cnt)
    for i = 1, cnt do
        local name = ".share" .. i
        local address = skynet.newservice("app/share/main", name)
        table.insert(self.shareList, address)
    end
end

function ShareProxy:getShare()
    if next(self.shareList) then
        local share = self.shareList[self.index]
        self.index = self.index + 1
        if self.index > #self.shareList then
            self.index = 1
        end
        return share
    end
    local shareList = gg.internal:call(".main","exec","gg.shareProxy:getShareList")
    assert(shareList and #shareList > 0, "shareList is empty")
    self.shareList = shareList
    self.index = 2
    return self.shareList[1]
end

function ShareProxy:call(cmd, ...)
    local share = self:getShare()
    return gg.internal:call(share,"api",cmd,...)
end

function ShareProxy:send(cmd, ...)
    local share = self:getShare()
    return gg.internal:send(share,"api",cmd,...)
end

function ShareProxy:getShareList()
    return self.shareList
end

return ShareProxy