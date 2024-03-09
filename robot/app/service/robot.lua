require "app.util"
local skynet = require "skynet"
local agent = require "app.agent"
local login = require "app.login"
local config = require "app.config.custom"

local robot = {}
local param1,param2,param3 = ...
robot.roleid = tonumber(param1)
robot.testmode = param2
assert(robot.roleid)

function robot.heartbeat()
    if robot.linkobj.closed then
        return
    end
    local interval = 500   -- 5s
    skynet.timeout(interval,robot.heartbeat)
    robot.linkobj:send_request("C2S_Ping",{
        str = "heartbeat",
    })
    robot.linkobj:wait("S2C_Pong",function (linkobj,args)
        local time = args.time  -- 
        local delay
        if not robot.linkobj.time then
            delay = 0
        else
            delay = time - robot.linkobj.time - interval * 10
        end
        robot.linkobj.time = time
        --[[if delay > 50 then
            skynet.error(string.format("op=heartbeat,linktype=%s,linkid=%s,roleid=%s,delay=%sms",linkobj.linktype,linkobj.linkid,robot.roleid,delay))
        end]]
    end)
end

function robot.onconnect(linkobj)
    skynet.error(string.format("op=onconnect,linktype=%s,linkid=%s,roleid=%s",linkobj.linktype,linkobj.linkid,robot.roleid))
    robot.linkobj = linkobj
end

function robot.onhandshake(linkobj,result)
    skynet.error(string.format("op=onhandshake,linktype=%s,linkid=%s,roleid=%s,result=%s",linkobj.linktype,linkobj.linkid,robot.roleid,result))
    if result ~= "OK" then
        return
    end
    local account = string.format("#%d",robot.roleid)
    robot.account = account
    login.quicklogin(linkobj,account,robot.roleid,robot)
end

function robot.onclose(linkobj)
    skynet.error(string.format("op=onclose,linktype=%s,linkid=%s,roleid=%s",linkobj.linktype,linkobj.linkid,robot.roleid))
    robot.linkobj.closed = true
end

function robot.onlogin(linkobj)
    local linkobj = robot.linkobj
    skynet.error(string.format("op=onlogin,linktype=%s,linkid=%s,roleid=%s",linkobj.linktype,linkobj.linkid,robot.roleid))
    robot.heartbeat()
    -- todo something
    --[[
    local level = math.random(20,60)
    robot.do_gm(string.format("setLevel %s",level))
    robot.do_gm(string.format("addHeroLevel %s",level))
    local country = math.random(1,2)
    robot.do_gm(string.format("joinCountry %s",country))
    ]]

    if robot.testmode == "team" then
        robot.test_team()
    elseif robot.testmode == "chat" then
        robot.timer_speak(60)
    elseif robot.testmode == "match" then
        robot.test_match()
    elseif robot.testmode == "watch" then
        robot.test_watch()
    elseif robot.testmode == "battle" then
        robot.test_battle()
    end
end

--- dump(,)
--@param[type=table] t 
--@return[type=string] dump
local function dump(t,space,name)
    if type(t) ~= "table" then
        return tostring(t)
    end
    space = space or ""
    name = name or ""
    local cache = { [t] = "."}
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key),new_key))
            else
                table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return table.concat(temp,"\n"..space)
    end
    return _dump(t,space,name)
end

function robot.addListener(protoname,callback)
    robot.linkobj:wait(protoname,function (linkobj,args)
        robot.addListener(protoname,callback)
        callback(linkobj,args)
    end)
end

function robot.sendRequest(protoname,request,callback)
    robot.linkobj:send_request(protoname,request)
end

-- 
function robot.test_battle()
end

--   ->->
function robot.test_team()
end

--   ->ai->->
function robot.test_match()
end


-- 
function robot.test_watch()
end

function robot.do_gm(cmd)
    local linkobj = robot.linkobj
    if linkobj.closed then
        return
    end
    --skynet.error(string.format("op=do_gm,linktype=%s,linkid=%s,roleid=%s,cmd=%s",linkobj.linktype,linkobj.linkid,robot.roleid,cmd))
    robot.sendRequest("C2S_DoGM",{
        cmd = cmd,
    })
end

function robot.timer_speak(interval)
    skynet.timeout(interval*100,function ()
        robot.timer_speak(interval)
    end)
    local msgs = {
        "hello,world",
        "i am robot",
        "keep it simple and stupid",
        "are you ok",
        "i am fine",
        "oh,no!",
        "double kill!",
        ",",
        ",",
        ",",
        "?",
        "",
        "",
        "? ? ?",
        "",
        ",,",
        "",
        ": 1+1=?",
    }
    local channelId = 1
    local index = math.random(1,#msgs)
    local content = msgs[index]
    robot.speak(channelId,content)
end

function robot.speak(channelId,content)
    local linkobj = robot.linkobj
    if linkobj.closed then
        return
    end
    -- todo: chat in world channel
end

function robot.pack_create_role(create_role)
    local heroIds = {1001,1002,1003,1004,1005,1006,1007,1008}
    local heroId = heroIds[math.random(1,#heroIds)]
    create_role.heroId = heroId         -- id
    return create_role
end

agent.start(robot)

return robot
