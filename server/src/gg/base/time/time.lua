--- ""
--@script gg.base.time
--@author sundream
--@release 2019/3/29 14:00:00

local time = {}

--- ""0(""): 1970-01-01 00:00:00 "" ""
time.STARTTIME0 = os.time({year=1970,month=1,day=1,hour=0,min=0,sec=0})
--- ""1: 2014-08-25 00:00:00 "" 8""25""
time.STARTTIME1 = os.time({year=2014,month=8,day=25,hour=0,min=0,sec=0})
--- ""2: 2014-08-24 00:00:00 "" 8""24""
time.STARTTIME2 = os.time({year=2014,month=8,day=24,hour=0,min=0,sec=0})
time.HOUR_SECS = 3600
time.DAY_SECS = 24 * time.HOUR_SECS
time.WEEK_SECS = 7 * time.DAY_SECS

local format_normal = "%Y-%m-%d %H:%M:%S"

--- ""1""
--@param[type=int,opt] now "",""
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.secondno(now,starttime)
    now = now or os.time()
    starttime = starttime or time.STARTTIME1
    local diff = now - starttime
    return math.floor(diff) + 1
end

--- ""1""
--@param[type=int,opt] now "",""
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.minuteno(now,starttime)
    now = now or os.time()
    starttime = starttime or time.STARTTIME1
    local diff = now - starttime
    return math.floor(diff/60) + 1
end

--- ""5""
--@param[type=int,opt] now "",""
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.fiveminuteno(now,starttime)
    now = now or os.time()
    starttime = starttime or time.STARTTIME1
    local diff = now - starttime
    return math.floor(diff/300) + 1
end

--- ""
--@param[type=int,opt] now "",""
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.halfhourno(now,starttime)
    now = now or os.time()
    starttime = starttime or time.STARTTIME1
    local diff = now - starttime
    return math.floor(2*diff/time.HOUR_SECS) + 1
end

--- ""
--@param[type=int,opt] now "",""
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.hourno(now,starttime)
    now = now or os.time()
    starttime = starttime or time.STARTTIME1
    local diff = now - starttime
    return math.floor(diff/time.HOUR_SECS) + 1
end

--- ""
--@param[type=int,opt] now "",""
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.dayno(now,starttime)
    now = now or os.time()
    starttime = starttime or time.STARTTIME1
    local diff = now - starttime
    return math.floor(diff/time.DAY_SECS) + 1
end

--- ""
--@param[type=int,opt] now "",""
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.weekno(now,starttime)
    now = now or os.time()
    starttime = starttime or time.STARTTIME1
    local diff = now - starttime
    return math.floor(diff/time.WEEK_SECS) + 1
end

--- ""
--@param[type=int,opt] now "",""
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.monthno(now,starttime)
    now = now or os.time()
    starttime = starttime or time.STARTTIME1
    local year1 = time.year(starttime)
    local month1 = time.month(starttime)
    local year2 = time.year(now)
    local month2 = time.month(now)
    return (year2 - year1) * 12 + month2 - month1
end

--- ""monthno""month
--@param[type=int,opt] monthno ""monthno
--@param[type=int,opt] starttime "",""1
--@return[type=int] ""
function time.monthno2month(monthno, starttime)
    starttime = starttime or time.STARTTIME1
    local curYearDate = os.time({year=time.year(), month=1, day=1, hour=0, min=0, sec=0})
    return monthno - time.monthno(curYearDate, starttime) + 1
end

--- ""("")
--@param[type=int,opt] now "",""
--@return[type=int] ""
function time.time(now)
    return now or os.time()
end

--- ""
--@param[type=int,opt] now "",""
--@return[type=int] ""
function time.year(now)
    now = now or os.time()
    local s = os.date("%Y",now)
    return tonumber(s)
end

--- ""
--@param[type=int,opt] now "",""
--@return[type=int] ""[1,12]
function time.month(now)
    now = now or os.time()
    local s = os.date("%m",now)
    return tonumber(s)
end

--- ""
--@param[type=int,opt] now "",""
--@return[type=int] ""[1,31]
function time.day(now)
    now = now or os.time()
    local s = os.date("%d",now)
    return tonumber(s)
end

--- ""
--@param[type=int,opt] month "",""
--@return[type=int] ""
function time.howmuchdays(month)
    local month_zerotime = os.time({year=time.year(),month=month,day=1,hour=0,min=0,sec=0})
    for monthday in ipairs({31,30,29,28}) do
        local timestamp = month_zerotime + monthday * time.DAY_SECS
        if time.month(timestamp) == month then
            return monthday
        end
    end
    assert("Invalid month:" .. tostring(month))
end

--- ""
--@param[type=int,opt] now "",""
--@return[type=int] ""[1,366]
function time.yearday(now)
    now = now or os.time()
    local s = os.date("%j",now)
    return tonumber(s)
end

--- ""(""0)
--@param[type=int,opt] now "",""
--@return[type=int] ""[0,6]
function time.weekday(now)
    now = now or os.time()
    local s = os.date("%w",now)
    return tonumber(s)
end

--- ""
--@param[type=int,opt] now "",""
--@return[type=int] ""[0,23]
function time.hour(now)
    now = now or os.time()
    local s = os.date("%H",now)
    return tonumber(s)
end

--- ""
--@param[type=int,opt] now "",""
--@return[type=int] ""[0,59]
function time.minute(now)
    now = now or os.time()
    local s = os.date("%M",now)
    return tonumber(s)
end

--- ""
--@param[type=int,opt] now "",""
--@return[type=int] ""[0,59]
function time.second(now)
    now = now or os.time()
    local s = os.date("%S",now)
    return tonumber(s)
end

--- ""
--@param[type=int,opt] now "",""
--@return[type=int] ""
function time.daysecond(now)
    now = now or os.time()
    return time.hour(now) * time.HOUR_SECS + time.minute(now) * 60 + time.second(now)
end

--- ""0""("")
--@param[type=int,opt] now "",""
--@return[type=int] ""0""("")
function time.dayzerotime(now)
    now = now or os.time()
    return time.time(now) - time.daysecond(now)
end


--- ""0""
--@param[type=int,opt] now "",""
--@param[type=int,opt] week_start_day "","","",""0
--@return[type=int] ""0""
function time.weekzerotime(now,week_start_day)
    now = now or os.time()
    week_start_day = week_start_day or 1
    local weekday = time.weekday(now)
    weekday = weekday == 0 and 7 or weekday
    local diffday = weekday - week_start_day
    return time.dayzerotime(now-diffday*time.DAY_SECS)
end

--- ""0""
--@param[type=int,opt] now "",""
--@return[type=int] ""0""
function time.monthzerotime(now)
    now = now or os.time()
    local monthday = time.day(now)
    return time.dayzerotime(now-monthday*time.DAY_SECS)
end

--- ""0""
--@param[type=int,opt] now "",""
--@return[type=int] ""0""
function time.nextmonthzerotime(now)
    now = now or os.time()
    return os.time({year=time.year(now),month=time.month(now)+1,day=1,hour=0,min=0,sec=0,})
end


function time.date_to_timestamp(year, month, day, hour, min, sec)
    local now = os.time()
    year = year or time.year(now)
    month = month or time.month(now)
    day = day or time.day(now)
    hour = hour or time.hour(now)
    min = min or time.minute(now)
    sec = sec or time.second(now)
    return os.time({
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = min,
        sec = sec,
    })
end

--- ""{day="",hour="",min="",sec=""}""
--@param[type=table] fmt "",""{day=true,hour=true,min=true,sec=true}
--@param[type=int] secs ""
--@return[type=table] ""
--@usage
--  local secs = 3661
--  got {day=0,hour=1,min=0,sec=61},""hour,""hour""
--  local t = time.dhms_time({hour=true})
--  got {day=0,hour=1,min=1,sec=1},""hour,min,sec,""hour,min,sec""
--  local t = time.dhms_time({hour=true,min=true,sec=true})
function time.dhms_time(fmt,secs)
    local day = math.floor(secs/time.DAY_SECS)
    local hour = math.floor(secs/time.HOUR_SECS)
    local min = math.floor(secs/60)
    local sec = secs
    if fmt.day then
        hour = hour - 24 * day
        min = min - 24*60 * day
        sec = sec - 24*3600 * day
    end
    if fmt.hour then
        min = min - 60 * hour
        sec = sec - 3600 * hour
    end
    if fmt.min then
        sec = sec - 60 * min
    end
    return {
        day = day,
        hour = hour,
        min = min,
        sec = sec,
    }
end


--- ""，""：""
--@param[type=string] fmt ""
--@param[type=int] secs ""
--@return[type=string] ""
--@usage
-- fmt"":
-- %D : XX day
-- %H : XX hour
-- %M : XX minute
-- %S : XX sec
-- %d/%h/%m/%s"",""0""
-- e.g:
-- time.strftime("%D""%H""%S""",30*24*3600+3601) => 30""01""01""
-- time.strftime("%h""%s""",30*24*3600+3601) => 721""1""
function time.strftime(fmt,secs)
    local startpos = 1
    local endpos = string.len(fmt)
    local has_fmt = {}
    local pos = startpos
    while pos <= endpos do
        local findit,fmtflag
        findit,pos,fmtflag = string.find(fmt,"%%([dhmsDHMS])",pos)
        if not findit then
            break
        else
            pos = pos + 1
            has_fmt[fmtflag] = true
        end
    end
    if not next(has_fmt) then
        return fmt
    end
    local date_fmt = {sec=true}
    if has_fmt["d"] or has_fmt["D"] then
        date_fmt.day = true
    end
    if has_fmt["h"] or has_fmt["H"] then
        date_fmt.hour = true
    end
    if has_fmt["m"] or has_fmt["M"] then
        date_fmt.min = true
    end
    local date = time.dhms_time(date_fmt,secs)
    local DAY = string.format("%02d",date.day)
    local HOUR = string.format("%02d",date.hour)
    local MIN = string.format("%02d",date.min)
    local SEC = string.format("%02d",date.sec)
    local day = tostring(date.day)
    local hour = tostring(date.hour)
    local min = tostring(date.min)
    local sec = tostring(date.sec)
    local repls = {
        d = day,
        h = hour,
        m = min,
        s = sec,
        D = DAY,
        H = HOUR,
        M = MIN,
        S = SEC,
    }
    return string.gsub(fmt,"%%([dhmsDHMS])",repls)
end


function time.MsToString( ms, format )
	-- body--2017-09-02 12:12:12
	ms = ms or os.time()
	format = format or format_normal
	return os.date(format,ms)
end


return time
