local ShareProxy = class("ShareProxy")

function ShareProxy:ctor()
    self.shareList = {}
    self.index = 1
end

function ShareProxy:getShare()
    if gg.shareMgr then
        return gg.shareMgr:getShare()
    end
    if self.shareList and next(self.shareList) then
        local share = self.shareList[self.index]
        self.index = self.index + 1
        if self.index > #self.shareList then
            self.index = 1
        end
        return share
    end
    local shareList = gg.internal:call(".main","exec","gg.shareMgr:getShareList")
    assert(shareList and #shareList > 0, "shareList is empty")
    self.shareList = shareList
    self.index = 2
    return self.shareList[1]
end

function ShareProxy:call(cmd, ...)
    return gg.internal:call(self:getShare(),"api",cmd,...)
end

function ShareProxy:send(cmd, ...)
    return gg.internal:send(self:getShare(),"api",cmd,...)
end

return ShareProxy