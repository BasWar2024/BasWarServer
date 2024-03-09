local skynet = require "skynet.manager"
local cluster = require "skynet.cluster"

local logger = logger or {}

local function fullname(name)
    -- : logger.path*.log
    local filename
    local extname = name:match(".+%.(%w+)$")
    if not extname then
        filename = string.format("%s/%s.log",logger.path,name)
    else
        filename = name
    end
    return filename
end

local isrelease = skynet.getenv("area") == "release"
-- logger.logfilename
function logger.log(filename,msg)
    --assert(string.match(filename,"^[a-z_]+[a-z_0-9/]*$"),"invalid log filename:" .. tostring(filename))
    local ms
    if isrelease then
        ms = math.tointeger(skynet.time() * 1000)
    else
        -- 
        local lutil = require "lutil"
        ms = lutil.getms()
    end
    local now = math.floor(ms/1000)
    ms = ms % 1000
    local yesterday = os.date("%Y-%m-%d",now-24*3600)
    local today = os.date("%Y-%m-%d",now)
    local time = os.date("%H:%M:%S",now)
    local date = string.format("%s %s",today,time)
    msg = string.format("[%s.%03d] %s",date,ms,msg)
    if logger.dailyrotate then
        local yesterday_filename
        local dirname,basename = string.match(filename,"(.*)/(.*)")
        if dirname and basename then
            filename = string.format("%s/%s/%s%s",dirname,basename,basename,today)
            yesterday_filename = string.format("%s/%s/%s%s",dirname,basename,basename,yesterday)
        else
            basename = filename
            filename = string.format("%s/%s%s",basename,basename,today)
            yesterday_filename = string.format("%s/%s%s",basename,basename,yesterday)
        end
        yesterday_filename = fullname(yesterday_filename)
        if logger.handles[yesterday_filename] then
            logger.close(yesterday_filename)
        end
    end
    logger.write(filename,msg)
    return msg
end


function logger.write(filename,msg)
    local fd,v = logger.gethandle(filename)
    v.lines = v.lines + 1
    if logger.rotate_lines ~= -1 and v.lines >= logger.rotate_lines then
        local new_filename = string.format("%s-%s",filename,os.date("%H-%M-%S",os.time()))
        logger.close(filename)
        local ok = os.rename(fullname(filename),fullname(new_filename))
        fd = logger.gethandle(filename)
    end
    fd:write(msg)
    fd:flush()
end

function logger.sendmail(to_list,subject,content,mail_smtp,mail_user,mail_password)
    local function escape(str)
        local str = string.gsub(str,"\"","\\\"")
        return str
    end
    local bugreport_url = skynet.getenv("bugreport_url")
    local bugreport_members = skynet.getenv("bugreport_members")
    content = string.format("%s\n%s",subject,content)
    local step = 2000
    for i=1,#content,step do
        local msg = string.sub(content,i,i+step-1)
        msg = escape(msg)
        assert(msg ~= "",content)
        local sh = string.format('curl -s -d "to=%s&content=%s" "%s"',bugreport_members,msg,bugreport_url)
        --print(sh)
        local fd = io.popen(sh,"r")
        --local output = fd:read("*a")
        --print(output)
    end
    --[[
    local sh = string.format("python sendmail.py %s \"%s\" \"%s\" %s %s %s",to_list,escape(subject),escape(content),mail_smtp,mail_user,mail_password)
    --local sh = string.format("sh sendmail.sh %s \"%s\" \"%s\" %s %s %s",to_list,escape(subject),escape(content),mail_smtp,mail_user,mail_password)
    --os.execute!
    --os.execute(sh)
    local fd = io.popen(sh,"r")
    local output = fd:read("*a")
    --print(output)
    ]]
end


function logger.gethandle(filename)
    filename = fullname(filename)
    local data = logger.handles[filename]
    if not data then
        local parent_path = string.match(filename,"(.*)/.*")
        if parent_path then
            os.execute("mkdir -p " .. parent_path)
        end
        local fd,err  = io.open(filename,"a+b")
        assert(fd,string.format("op=logfile open failed,filename=%s,err=%s",filename,err))
        fd:setvbuf("line")
        data = {
            fd = fd,
            lines = 0,
        }
        logger.handles[filename] = data
    end
    return data.fd,data
end

function logger.close(filename)
    filename = fullname(filename)
    local handle = logger.handles[filename]
    if not handle then
        return
    end
    local fd = handle.fd
    fd:close()
    logger.handles[filename] = nil
    return fd
end

function logger.freopen(filename)
    filename = fullname(filename)
    if logger.close(filename) then
        logger.gethandle(filename)
    end
end

function logger.init()
    if logger.binit then
        return
    end
    logger.binit = true
    logger.handles = {}
    logger.time = {
        sec = 0,
        usec = 0,
    }
    logger.path = skynet.getenv("logpath")
    logger.dailyrotate = skynet.getenv("log_dailyrotate") == "1"
    logger.rotate_lines = tonumber(skynet.getenv("log_rotate_lines")) or -1
    --print(string.format("logger.path: %s,dailyrotate: %s,rotate_lines: %s",logger.path,logger.dailyrotate,logger.rotate_lines))
    os.execute(string.format("mkdir -p %s",logger.path))
end

function logger.exit()
    for name in pairs(logger.handles) do
        logger.close(name)
    end
    logger.handles = {}
    skynet.retpack()
    skynet.exit()
end

skynet.init(function ()
    logger.init()
end)

skynet.start(function ()
    skynet.dispatch("lua",function (session,source,cmd,...)
        local func = logger[cmd]
        if not func then
            error("invalid cmd:" .. tostring(cmd))
        end
        func(...)
    end)
end)

return logger