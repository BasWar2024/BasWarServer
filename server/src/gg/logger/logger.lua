--- 
--@script gg.logger.logger
--@author sundream
--@release 2018/12/25 10:30:00

local cjson = require "cjson"
local cluster = require "skynet.cluster"
local crc16 = require "skynet.db.redis.crc16"

logger = logger or {}

function logger._alloc_address(key)
    local index = crc16(key)
    return logger.addresses[index % #logger.addresses + 1]
end

function logger._send(address,...)
    if logger.node ~= logger.my_node then
        cluster.send(logger.node,address,...)
    else
        skynet.send(address,"lua",...)
    end
end

--- (msg,)
--@param[type=string] filename 
--@param[type=string] msg 
function logger.write(filename,msg)
    local address = logger._alloc_address(filename)
    logger._send(address,"write",filename,msg)
end

--- ,:debug
--@param[type=string] filename 
--@param[type=string] fmt 
--@param ... 
--@usage
--  logger.debug("test","name=%s,age=%s","lgl",28)
--  logger.debug("t1/t2/t3","hello,world")
function logger.debug(filename,fmt,...)
    logger.logf(logger.DEBUG,filename,fmt,...)
end

--- ,:trace,trace
--@param[type=string] filename 
--@param[type=string] fmt 
--@param ... 
--@usage
--  logger.debug("test","name=%s,age=%s","lgl",28)
--  logger.debug("t1/t2/t3","hello,world")
function logger.trace(filename,fmt,...)
    logger.logf(logger.TRACE,filename,fmt,...)
end

--- ,:info
--@param[type=string] filename 
--@param[type=string] fmt 
--@param ... 
--@usage
--  logger.info("test","name=%s,age=%s","lgl",28)
--  logger.info("t1/t2/t3","hello,world")
function logger.info(filename,fmt,...)
    logger.logf(logger.INFO,filename,fmt,...)
end

--- ,:warn
--@param[type=string] filename 
--@param[type=string] fmt 
--@param ... 
--@usage
--  logger.warn("test","name=%s,age=%s","lgl",28)
--  logger.warn("t1/t2/t3","hello,world")
function logger.warn(filename,fmt,...)
    logger.logf(logger.WARN,filename,fmt,...)
end

--- ,:error
--@param[type=string] filename 
--@param[type=string] fmt 
--@param ... 
--@usage
--  logger.error("test","name=%s,age=%s","lgl",28)
--  logger.error("t1/t2/t3","hello,world")
function logger.error(filename,fmt,...)
    logger.logf(logger.ERROR,filename,fmt,...)
end

--- ,:fatal
--@param[type=string] filename 
--@param[type=string] fmt 
--@param ... 
--@usage
--  logger.fatal("test","name=%s,age=%s","lgl",28)
--  logger.fatal("t1/t2/t3","hello,world")
function logger.fatal(filename,fmt,...)
    logger.logf(logger.FATAL,filename,fmt,...)
end

--- ,,
--@param[type=string] loglevel 
--@param[type=string] filename 
--@param ... (tablejson)
--@usage
--  logger.log("info","test","lgl",28)
--  logger.log("debug","t1/t2/t3","hello,world")
function logger.log(loglevel,filename,...)
    local loglevel_name
    loglevel,loglevel_name = logger.check_loglevel(loglevel)
    if logger.loglevel > loglevel then
        return
    end
    local args = table.pack(...)
    local len = math.max(#args,args.n or 0)
    for i = 1, len do
        local typ = type(args[i])
        if typ == "table" then
            local ok,str = pcall(cjson.encode,args[i])
            if ok then
                args[i] = str
            else
                args[i] = gg.tostring(args[i])
            end
        elseif typ ~= "number" then
            args[i] = tostring(args[i])
        end
    end
    local msg = table.concat(args,logger.seperator)
    logger.logf(loglevel,filename,msg)
end

function logger.format(fmt,...)
    local msg
    if select("#",...) == 0 then
        msg = fmt
    else
        local args = table.pack(...)
        local len = math.max(#args,args.n or 0)
        for i = 1, len do
            local typ = type(args[i])
            if typ == "table" then
                local ok,str = pcall(cjson.encode,args[i])
                if ok then
                    args[i] = str
                else
                    args[i] = gg.tostring(args[i])
                end
            elseif typ ~= "number" then
                args[i] = tostring(args[i])
            end
        end
        msg = string.format(fmt,table.unpack(args))
    end
    return msg
end

--- ,,
--@param[type=string] loglevel (debug<trace<info<warn<error<fatal)
--@param[type=string] filename 
--@param[type=string] fmt 
--@param ... (tablejson)
--@usage
--  logger.logf("info","test","name=%s,age=%s","lgl",28)
--  logger.logf("debug","t1/t2/t3","hello,world")  logger.debug("t1/t2/t3","hello,world")
function logger.logf(loglevel,filename,fmt,...)
    local loglevel_name
    loglevel,loglevel_name = logger.check_loglevel(loglevel)
    if logger.loglevel > loglevel then
        return
    end
    assert(fmt)
    if loglevel == logger.TRACE then
        local info = debug.getinfo(2,"Sl")
        fmt = info.short_src .. ":" .. info.currentline .. " " .. fmt
    end
    local msg = logger.format(fmt,...)
    msg = string.format("[%s] [%s] %s\n",loglevel_name,logger.my_node,msg)
    local address = logger._alloc_address(filename)
    logger._send(address,"log",filename,msg)
    if loglevel >= logger.WARN then
        local pos = string.find(msg,"\n")
        local tag = msg:sub(1,pos-1)
        local now = os.time()
        msg = string.format("[%s] %s",os.date("%Y-%m-%d %H:%M:%S",now),msg)
        logger.print(msg)
        local bugreport_mails = skynet.getenv("bugreport_mails")
        if bugreport_mails then
           if not logger.bugreport_mails then
                logger.bugreport_mails = {}
            end
            -- bug
            local last_sendtime = logger.bugreport_mails[tag]
            if not last_sendtime or (now - last_sendtime > 120) then
                local subject = string.format("ip=%s,name=%s,id=%s,loglevel_name=%s,index=%s,appid=%s,area=%s,zoneid=%s,address=%s,filename=%s",
                    skynet.getenv("ip"),skynet.getenv("name"),skynet.getenv("id"),loglevel_name,skynet.getenv("index"),skynet.getenv("appid"),skynet.getenv("area"),skynet.getenv("zoneid"),skynet.address(skynet.self()),filename)
                logger.sendmail(bugreport_mails,subject,msg)
            end
            logger.bugreport_mails[tag] = now
        end
    end
    return msg
end

--- (logrotate)
--@param[type=string] filename 
function logger.freopen(filename)
    local address = logger._alloc_address(filename)
    logger._send(address,"freopen",filename)
end


function logger.sendmail(to_list,subject,content,mail_smtp,mail_user,mail_password)
    mail_smtp = mail_smtp or skynet.getenv("mail_smtp")
    mail_user = mail_user or skynet.getenv("mail_user")
    mail_password = mail_password or skynet.getenv("mail_password")
    local address = logger.addresses[math.random(1,#logger.addresses)]
    logger._send(address,"sendmail",to_list,subject,content,mail_smtp,mail_user,mail_password)
end

--- ,debug,:,
--@param ... 
--@usage
--  logger.print("hello")
--  logger.print(string.format("key1=%s,key2=%s",1,2))
function logger.print(...)
    if logger.loglevel > logger.TRACE then
        return
    end
    local info = debug.getinfo(2,"Sl")
    local trace = info.short_src .. ":" .. info.currentline
    print(trace,...)
    skynet.error(trace,...)
end

--- ,debug,:,
--@param fmt 
--@param ... 
--@usage
--  logger.printf("key1=%s,key2=%s",1,2)
function logger.printf(fmt,...)
    if logger.loglevel > logger.TRACE then
        return
    end
    local info = debug.getinfo(2,"Sl")
    local trace = info.short_src .. ":" .. info.currentline
    local msg = logger.format(fmt,...)
    print(trace,msg)
    skynet.error(trace,msg)
end

--- logger.print,,/
function logger.output(...)
    local info = debug.getinfo(2,"Sl")
    local trace = info.short_src .. ":" .. info.currentline
    print(trace,...)
    skynet.error(trace,...)
end

--- 
--@param[type=string] loglevel 
--@usage
--  logger.setloglevel("info")  -- info,debug
function logger.setloglevel(loglevel)
    loglevel = logger.check_loglevel(loglevel)
    logger.loglevel = loglevel
end

function logger.check_loglevel(loglevel)
    if type(loglevel) == "string" then
        loglevel = logger.NAME_LEVEL[loglevel]
    end
    local name = logger.LEVEL_NAME[loglevel]
    return loglevel,name
end

logger.DEBUG = 1
logger.TRACE = 2
logger.INFO = 3
logger.WARN = 4
logger.ERROR = 5
logger.FATAL = 6
logger.NAME_LEVEL = {
    debug = logger.DEBUG,
    trace = logger.TRACE,
    info = logger.INFO,
    warn = logger.WARN,
    ["error"] = logger.ERROR,
    fatal = logger.FATAL,
}
logger.LEVEL_NAME = {
    [logger.DEBUG] = "debug",
    [logger.TRACE] = "trace",
    [logger.INFO] = "info",
    [logger.WARN] = "warn",
    [logger.ERROR] = "error",
    [logger.FATAL] = "fatal",
}


function logger.newservice()
    local loggerd_num = skynet.getenv("loggerd_num")
    local my_node = skynet.getenv("id")
    local my_address = skynet.self()
    local loggerserver = skynet.getenv("loggerserver")
    logger.addresses = {}
    if not loggerserver or loggerserver == my_node then
        for i=1,loggerd_num do
            local address = skynet.newservice("gg/service/loggerd")
            local name = string.format(".logger%s",i)
            skynet.name(name,address)
            table.insert(logger.addresses,address)
        end
    else
        for i=1,loggerd_num do
            local name = string.format(".logger%s",i)
            table.insert(logger.addresses,name)
        end
    end
end

--- 
--@usage
--  3
--  1. loglevel: (debug<trace<info<warn<error<fatal)
--  2. logpath: 
--  3. log_dailyrotate: 
function logger.init()
    local loggerd_num = skynet.getenv("loggerd_num")
    logger.seperator = skynet.getenv("log_seperator") or " "
    logger.setloglevel(skynet.getenv("loglevel"))
    logger.my_address = skynet.self()
    logger.my_node = skynet.getenv("id")
    logger.node = skynet.getenv("loggerserver") or logger.my_node
    if not logger.addresses then
        logger.addresses = {}
        for i=1,loggerd_num do
            local name = string.format(".logger%s",i)
            table.insert(logger.addresses,name)
        end
    end
end

--- 
function logger.exit()
    if logger.node ~= logger.my_node then
        return
    end
    for i,address in ipairs(logger.addresses) do
        skynet.call(address,"lua","exit")
    end
end

return logger