local ctimectrl = class("ctimectrl")

function ctimectrl:ctor()
end

function ctimectrl:tick()
    gg.timer:timeout(1,function ()
        self:tick()
    end)
    self:on_second()
    local now = gg.time.time()
    local second = gg.time.second(now)
    if second == 0 then
        self:minute_update(now)
    end
end

function ctimectrl:minute_update(now)
    self:on_minute_update()
    local min = gg.time.minute(now)
    if min % 5 == 0 then
        self:five_minute_update(now)
    end
end

function ctimectrl:five_minute_update(now)
    self:on_five_minute_update()
    local min = gg.time.minute(now)
    if min % 10 == 0 then
        self:ten_minute_update(now)
    end
end

function ctimectrl:ten_minute_update(now)
    self:on_ten_minute_update()
    local min = gg.time.minute(now)
    if min == 0 or min == 30 then
        self:half_hour_update(now)
    end
end

function ctimectrl:half_hour_update(now)
    self:on_half_hour_update()
    local min = gg.time.minute(now)
    if min == 0 then
        self:hour_update(now)
    end
end

function ctimectrl:hour_update(now)
    self:on_hour_update()
    local hour = gg.time.hour(now)
    if hour == 0  then
        self:day_update(now)
    end
end

function ctimectrl:day_update(now)
    self:on_day_update()
    local weekday = gg.time.weekday(now)
    if weekday == 0 then --""
        self:sunday_update(now)
    elseif weekday == 1 then --""
        self:monday_update(now)
    elseif weekday == 6 then --""
        self:saturday_update(now)
    end
    local day = gg.time.day(now)
    if day == 1 then
        self:month_update(now)
    end
end

function ctimectrl:monday_update(now)
    self:on_monday_update()
end

function ctimectrl:sunday_update(now)
    self:on_sunday_update()
end

--""
function ctimectrl:saturday_update(now)
    self:on_saturday_update()
end

function ctimectrl:month_update(now)
    self:on_month_update()
end

-- ""
function ctimectrl:on_second()
    --logger.logf("debug","time","on_second")
    if gg.onSecond then
        gg.onSecond()
    end
end

function ctimectrl:on_minute_update()
    --logger.logf("debug","time","on_minute_update")
    if gg.onMinuteUpdate then
        gg.onMinuteUpdate()
    end
end

function ctimectrl:on_five_minute_update()
    --logger.logf("debug","time","on_five_minute_update")
    if gg.onFiveMinuteUpdate then
        gg.onFiveMinuteUpdate()
    end
end

function ctimectrl:on_ten_minute_update()
    --logger.logf("debug","time","on_ten_minute_update")
    if gg.onTenMinuteUpdate then
        gg.onTenMinuteUpdate()
    end
end

function ctimectrl:on_half_hour_update()
    --logger.logf("debug","time","on_half_hour_update")
    if gg.onHalfHourUpdate then
        gg.onHalfHourUpdate()
    end
end


function ctimectrl:on_hour_update()
    --logger.logf("debug","time","on_hour_update")
    if gg.onHourUpdate then
        gg.onHourUpdate()
    end
end

function ctimectrl:on_day_update()
    --logger.logf("debug","time","on_day_update")
    if gg.onDayUpdate then
        gg.onDayUpdate()
    end
end

function ctimectrl:on_monday_update()
    --logger.logf("debug","time","on_monday_update")
    if gg.onMondayUpdate then
        gg.onMondayUpdate()
    end
end

function ctimectrl:on_sunday_update()
    --logger.logf("debug","time","on_sunday_update")
    if gg.onSundayUpdate then
        gg.onSundayUpdate()
    end
end

function ctimectrl:on_saturday_update()
    if gg.onSaturdayUpdate then
        gg.onSaturdayUpdate()
    end
end

function ctimectrl:on_month_update()
    --logger.logf("debug","time","on_month_update")
    if gg.onMonthUpdate then
        gg.onMonthUpdate()
    end
end

return ctimectrl
