local NoticeBag = class("NoticeBag")

function NoticeBag:ctor(param)
    self.player = param.player
end

function NoticeBag:querySystemNotice()
    local noticeList = {}
    if gg.systemNoticeCfg and next(gg.systemNoticeCfg) then
        for k, v in pairs(gg.systemNoticeCfg) do
            if v.status and v.status == 1 and v.createTime then
                table.insert(noticeList, v)
            end
        end
    end
    local notices = {}
    if noticeList and next(noticeList) then
        table.sort(noticeList, function(a, b)
            return a.createTime > b.createTime
        end)
        for i=1, constant.NOTICE_SHOW_NUM do
            if noticeList[i] then
                table.insert(notices, noticeList[i])
            else
                break
            end
        end
    end
    gg.client:send(self.player.linkobj,"S2C_Player_SystemNotice", {notices=notices})
    return notices
end

function NoticeBag:onload()

end

function NoticeBag:onlogin()
    self:querySystemNotice()
end

function NoticeBag:onlogout()

end

return NoticeBag