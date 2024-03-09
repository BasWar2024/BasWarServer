local skynet = require "skynet.manager"
local config = require "app.config.custom"
local report_interval = config.report_interval * 100

local function on_report()
    skynet.timeout(report_interval,on_report)
    if config.ignore_report then
        return
    end
    skynet.error("on_report")
    local cmd = "cd ../../ && sh report.sh"
    os.execute(cmd)
    skynet.error(string.format("op=report,report_interval=%s",report_interval))
end


local usage = [[

Welcome,I'am a robot(version: 0.0.1)
usage:
    telnet 127.0.0.1 %s to control it
    #100,idrobot.config#startpid
    start app/service/newrobot 100
config:
    loginserver: %s:%s
    gameserver: %s:%s[%s]
]]


skynet.start(function ()
    local port = config.debug_port or 6666
    usage = string.format(usage,port,config.loginserver.ip,config.loginserver.port,config.ip,config.port,config.gate_type)
    print(usage)

    skynet.newservice("debug_console",port)
    skynet.timeout(report_interval,on_report)
end)
