local skynet = require "skynet"
local datacenter = require "skynet.datacenter"
local config = require "app.config.custom"

local playernum = 0
local num,testmode,pid = ...
num = assert(tonumber(num))
assert(testmode)
pid = tonumber(pid)

local function batch_add_robot(robot_num,testmode,startpid)
    local num
    local robot_num_per_batch = config.robot_num_per_batch
    local batch_interval = config.batch_interval * 100
    if robot_num >= robot_num_per_batch then
        num = robot_num_per_batch
        skynet.timeout(batch_interval,function ()
            batch_add_robot((robot_num - num), testmode,(startpid + num))
        end)
    else
        num = robot_num
        skynet.timeout(1000,function ()
            skynet.exit()
        end)
    end
    skynet.error(startpid,tostring(startpid))
    local ip = config.ip
    local port = config.port
    local gate_type = config.gate_type
    for i=0,num-1 do
        local curTestMode
        local pid = startpid + i
        if testmode == 'normal' then
            if i < math.floor(num * 0.8) then
                curTestMode = 'match'
            elseif i < math.floor(num * 0.9) then
                curTestMode = 'chat'
            elseif i < num then
                curTestMode = 'team'
            end
        else
            curTestMode = testmode
        end
        skynet.error(string.format("op=add_robot,pid=%s,testmode=%s",pid,curTestMode))
        local robot = skynet.newservice("app/service/robot",pid,curTestMode)
        skynet.send(robot,"lua","connect",{
            ip = ip,
            port = port,
            gate_type = gate_type,
        })
    end
end

skynet.start(function ()
    local initpid = config.startpid or 1000000
    if pid == 0 then
        pid = initpid
    end
    local startpid = datacenter.get("startpid")
    if not startpid then
        startpid = initpid
        datacenter.set("startpid",startpid)
    end
    if pid and pid > 0 then
        startpid = pid
    end

    datacenter.set("startpid",startpid+num)

    playernum = playernum + num
    local report = string.format("report_script_ip=%s\nhost=%s\nmode=%s\nplayernum=%d",config.report_script_ip,config.report_ip,testmode,playernum)
    local cmd = string.format("echo '%s' > ../../report.txt",report)
    os.execute(cmd)

    batch_add_robot(num, testmode,startpid)
end)
