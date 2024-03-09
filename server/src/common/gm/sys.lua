local cgm = reload_class("cgm")

---: 
---@usage
---: stop
function cgm:stop(args)
    game.exit()
end

---: 
---@usage
---: restart
function cgm:restart(args)
    local now = os.time()
    -- man at see usage
    local start_time = os.date("%Y%m%d%H%M.%S",now+6)
    local cmd = string.format("at -f $PWD/restart.sh -t %s",start_time)
    logger.print(cmd)
    os.execute(cmd)
    game.exit()
end

function cgm:saveall(args)
    gg.savemgr:saveall()
end

---: 
---@usage
---: disconnect [id]
function cgm:disconnect(args)
    local pid = tonumber(args[1]) or self.master.pid
    local player = gg.playermgr:getplayer(pid)
    if player then
        player:disconnect("gm")
    end
end

---: 
---@usage
---: kick [ID [ID]...]
function cgm:kick(args)
    if #args == 0 then
        args[1] = self.master.pid
    end
    for i,v in ipairs(args) do
        local pid = tonumber(v)
        gg.playermgr:kick(pid,"gm")
    end
end

---: 
---@usage
---: kickall
function cgm:kickall(args)
    gg.playermgr:kickall("gm")
end

---: lua
---@usage
---: exec lua
function cgm:exec(args)
    local cmdline = table.concat(args," ")
    local chunk = load(cmdline,"=(load)","bt")
    return chunk()
end

---: 
---@usage
---: dofile lua ...
---: dofile tmp.lua
function cgm:dofile(args)
    local ok,args = gg.checkargs(args,"string","*")
    if not ok then
        return self:say(": dofile lua")
    end
    local filename = args[1]
    -- loadfile need execute skynet.cache.clear to reload
    --local chunk = loadfile(filename,"bt")
    local fd = io.open(filename,"rb")
    local script = fd:read("*all")
    fd:close()
    return gg.eval(script,nil,table.unpack(args,2))
end

---: 
---@usage
---: hotfix  ...
function cgm:hotfix(args)
    local fails = {}
    for i,path in ipairs(args) do
        local ok,errmsg = gg.serviceMgr:hotfix(path)
        if not ok then
            table.insert(fails,{path=path,errmsg=errmsg})
        end
    end
    if next(fails) then
        return self:say(":\n" .. table.dump(fails))
    end
end

cgm.reload = cgm.hotfix

---: 
---@usage
---: hotfixAll
function cgm:hotfixAll(args)
    gg.serviceMgr:hotfixAll()
end

---: /
---@usage
---: loglevel []
---:
---loglevel     <=> 
---loglevel debug/trace/info/warn/error/fatal  <=> 
function cgm:loglevel(args)
    local loglevel = args[1]
    if not loglevel then
        local loglevel,name = logger.check_loglevel(logger.loglevel)
        return self:say(name)
    else
        local ok,loglevel,name = pcall(logger.check_loglevel,loglevel)
        if not ok then
            local errmsg = loglevel
            return self:say(errmsg)
        end
        logger.setloglevel(loglevel)
        return name
    end
end

---: /
---@usage
---: date []
---: date        <=> 
---: date 2019/11/28 10:10:10        <=> 2019/11/28 10:10:10
function cgm:date(args)
    local date
    if #args > 0 then
        if not skynet.getenv("allow_modify_date") then
            return self:say("")
        end
        date = table.concat(args," ")
        if not pcall(string.totime,date) then
            return self:say(string.format(":%s",date))
        end
        local cmd = string.format("date -s '%s'",date)
        local ok,errmsg,errno = os.execute(cmd)
        if not ok then
            return self:say(string.format(",errmsg=%s,errno=%s",errmsg,errno))
        else
            date = os.date("%Y/%m/%d %H:%M:%S")
        end
    else
        date = os.date("%Y/%m/%d %H:%M:%S")
    end
    self:say(string.format(":%s",date))
    self:say(" help ntpdate")
    return date
end

---: 
---@usage
---: ntpdate
---: ntpdate <=> 
function cgm:ntpdate(args)
    if not skynet.getenv("allow_modify_date") then
        return self:say("")
    end
    local ntp_domain = skynet.getenv("ntp_domain") or "cn.ntp.org.cn"
    local cmd = string.format("/usr/sbin/ntpdate -u %s",ntp_domain)
    self:say("...")
    local ok,errmsg,errno = os.execute(cmd)
    if ok then
        local date = os.date("%Y/%m/%d %H:%M:%S")
        return self:say(string.format(":%s",date))
    else
        return self:say(string.format(",errmsg=%s,errno=%s",errmsg,errno))
    end
end

---: 
---@usage
---: info []
function cgm:info(args)
    local address = args[1] or skynet.self()
    if tonumber(address) then
        address = skynet.address(tonumber(address))
    end
    local data = skynet.call(address,"debug","INFO")
    return self:say(table.dump(data))
end

---: 
---@usage
---: bugreport ()  
function cgm:bugreport(args)
    local ok,args = gg.checkargs(args,"string","string","string")
    if not ok then
        return self:say(": bugreport ()  ")
    end
    local to_list = args[1]
    local subject = args[2]
    local content = args[3]
    logger.sendmail(to_list,subject,content)
end

--- : 
---@usage
---: check_cluster
function cgm:check_cluster(args)
    local result = {}
    if gg.loginserver then
        local status,response = gg.loginserver:rpc(nil,"print","ping")
        if status ~= 200 then
            table.insert(result,{
                node = "login",
                ok = false,
                status = status,
            })
        else
            table.insert(result,{
                node = "login",
                ok = response.code == httpc.answer.code.OK,
                code = response.code,
            })
        end
    end
    local nodes = skynet.config.nodes
    for node in pairs(nodes) do
        local no_timeout,ok,err = pcall(gg.cluster.timeout_call,gg.cluster,5000,node,".main","ping")
        local info = {node = node, ok = ok}
        if not no_timeout then
            info.timeout = true
        end
        table.insert(result,info)
    end
    return self:say(result)
end

--- : id
---@usage
---: close_link id
---: close_link 0       <=> 
---: close_link 1802    <=> 1802
function cgm:close_link(args)
    local ok,args = gg.checkargs(args,"int")
    if not ok then
        return self:say(": close_link id")
    end
    local linkid = args[1]
    if linkid ~= 0 then
        gg.client:dellinkobj(linkid,true)
    else
        for linkid,linkobj in pairs(gg.client.linkobjs.objs) do
            gg.client:dellinkobj(linkid,true)
        end
    end
end

---@usage
---: close_login 1(+)|0(+)
---: close_login 1        <=> +
---: close_login 0        <=> +
function cgm:close_login(args)
    local ok,args = gg.checkargs(args,"int")
    if not ok then
        return self:say(": close_login 1(+)|0(+)")
    end
    local close = args[1]
    if close == 0 then
        gg.closeEnterGame = false
        gg.closeCreateRole = false
    else
        gg.closeEnterGame = true
        gg.closeCreateRole = true
    end
    if gg.stopTimerOpenLogin then
        gg.stopTimerOpenLogin()
    end
    return self:say(string.format("closeEnterGame=%s,closeCreateRole=%s",gg.closeEnterGame,gg.closeCreateRole))
end

--- : 
---@usage
---: recvclient cmd args(lua table)
---: recvclient C2S_Ping {str="hello"}
---: sh gm.sh 1000001 recvclient C2S_Ping '{str=\"hello\"}'
function cgm:recvclient(args)
    local ok,args = gg.checkargs(args,"string","string")
    if not ok then
        return self:say(": recvclient cmd args(lua table)")
    end
    local cmd = args[1]
    local argStr = args[2]
    if not gg.client.cmd[cmd] then
        return self:say(": "..cmd)
    end
    local f,err = load("return "..argStr,"gm","t")
    if not f then
        return self:say(string.format("lua: %s,=%s",argStr,err))
    end
    local args = f()
    gg.client:_onmessage(self.master,cmd,args)
    return self:say(string.format("op=recvclient,cmd=%s,args=%s",cmd,table.dump(args)))
end

--- : 
---@usage
---: sendclient cmd args(lua table)
---: sendclient S2C_Pong {str="hello",time=1604913284000,token="test"}
---: sh gm.sh 1000001 sendclient S2C_Pong '{str=\"hello\",time=1604913284000,token=\"test\"}'
function cgm:sendclient(args)
    local ok,args = gg.checkargs(args,"string","string")
    if not ok then
        return self:say(": sendclient cmd args(lua table)")
    end
    local cmd = args[1]
    local argStr = args[2]
    local f,err = load("return "..argStr,"gm","t")
    if not f then
        return self:say(string.format("lua: %s,=%s",argStr,err))
    end
    local args = f()
    gg.client:send(self.master.linkobj,cmd,args)
    return self:say(string.format("op=sendclient,cmd=%s,args=%s",cmd,table.dump(args)))
end

--- : rpc#call
---@usage
---: call    [1(lua) 2...]
---: call center .main ping
---: call center :00000008 ping
---: call center .main exec#logger.print "one" 1 {"table"}
---: sh gm.sh 0 call center .main exec#SERVICE_NAME
---: sh gm.sh 0 call center .main exec#gg.serviceName
---: sh gm.sh 0 call center .main exec#logger.print '\"one\" 1 {\"table\"}'
function cgm:call(args)
    local ok,args = gg.checkargs(args,"string","string","string","*")
    if not ok then
        return self:say(": call    [1(lua) 2...]")
    end
    local pid = self.master_pid
    local node = args[1]
    local address = args[2]
    local method = args[3]
    local argStr = table.concat(args,",",4)
    if address:sub(1,1) == ":" then
        address = tonumber(address:sub(2),16)
    end
    if tonumber(address) then
        address = tonumber(address)
    end
    if not skynet.config.nodes[node] then
        node = node .. "server"
    end
    if not skynet.config.nodes[node] then
        return self:say(string.format(": %s",node))
    end
    local f,err = load("return "..argStr,"gm","t")
    if not f then
        return self:say(string.format("lua: %s,=%s",argStr,err))
    end
    local args = table.pack(f())
    if string.find(method,"#") then
        local a,b = string.match(method,"^(.+)#(.+)$")
        method = a
        table.insert(args,1,b)
        if method == "gm" then
            table.insert(args,1,pid)
        end
    end
    if node == skynet.config.id and method == "gm" then
        return self:say("callgm,gm.lock")
    end
    local result = table.pack(gg.cluster:call(node,address,method,table.unpack(args)))
    return self:say(table.dump(result))
end

--- : rpc#send
---@usage
---: send    [1(lua) 2...]
---: send center .main ping
---: send center :00000008 ping
---: send game1 :00000008 gm#kick 1000001 1000002
---: send center .main exec#logger.print "one" 1 {"table"}
---: sh gm.sh 0 send center .main exec#logger.print '\"one\" 1 {\"table\"}'
function cgm:send(args)
    local ok,args = gg.checkargs(args,"string","string","string","*")
    if not ok then
        return self:say(": send    [1(lua) 2...]")
    end
    local pid = self.master_pid
    local node = args[1]
    local address = args[2]
    local method = args[3]
    local argStr = table.concat(args,",",4)
    if address:sub(1,1) == ":" then
        address = tonumber(address:sub(2),16)
    end
    if tonumber(address) then
        address = tonumber(address)
    end
    if not skynet.config.nodes[node] then
        node = node .. "server"
    end
    if not skynet.config.nodes[node] then
        return self:say(string.format(": %s",node))
    end
    local f,err = load("return "..argStr,"gm","t")
    if not f then
        return self:say(string.format("lua: %s,=%s",argStr,err))
    end
    local args = table.pack(f())
    if string.find(method,"#") then
        local a,b = string.match(method,"(.+)#(.+)")
        method = a
        table.insert(args,1,b)
        if method == "gm" then
            table.insert(args,1,pid)
        end
    end
    gg.cluster:send(node,address,method,table.unpack(args))
end


--- : proxy.call/send
---@usage
---: proxy call/send   [1(lua) 2...]
---: proxy call center ping
---: proxy send center ping
---: proxy call center exec#SERVICE_NAME
---: proxy send center exec#logger.print "one" 1 {"table"}
---: proxy send :00000008 gm#help "help"
---: proxy send :00000008 gm#kick 1000001 1000002
---: sh gm.sh 0 proxy call center exec#gg.serviceName
---: sh gm.sh 0 proxy send center exec#logger.print '\"one\" 1 {\"table\"}'
function cgm:proxy(args)
    local ok,args = gg.checkargs(args,"string","string","string","*")
    if not ok then
        return self:say(": proxy call/send   [1(lua) 2...]")
    end
    local pid = self.master_pid
    local op = args[1]
    local proxyName = args[2]
    local method = args[3]
    local argStr = table.concat(args,",",4)
    local proxy
    if proxyName:sub(1,1) == ":" then
        proxyName = tonumber(proxyName:sub(2),16)
    end
    if tonumber(proxyName) then
        proxy = ggclass.Proxy.new(nil,tonumber(proxyName))
    else
        proxy = gg.proxy[proxyName]
    end
    if not proxy then
        return self:say(string.format(": %s",proxyName))
    end
    local f,err = load("return "..argStr,"gm","t")
    if not f then
        return self:say(string.format("lua: %s,=%s",argStr,err))
    end
    if not (op == "call" or op == "send") then
        return self:say(string.format(": %s",op))
    end
    local args = table.pack(f())
    if string.find(method,"#") then
        local a,b = string.match(method,"^(.+)#(.+)$")
        method = a
        table.insert(args,1,b)
        if method == "gm" then
            table.insert(args,1,pid)
        end
    end
    if op == "call" then
        local result = table.pack(proxy:call(method,table.unpack(args)))
        return self:say(table.dump(result))
    else
        proxy:send(method,table.unpack(args))
    end
end

--- : profile
---@usage
---: 0=,1=,2=cpu(),3=(+),4=,5=cpu,6=
--- startProfile topN  ()
--- startProfile 20 2 20000  <=> 20s20cpu
--- proxy send :0000002b gm#startProfile 20 2 20000  <=> :0000002b20s20cpu
function cgm:startProfile(args)
    local ok,args = gg.checkargs(args,"int","int","int")
    if not ok then
        return self:say(" startProfile topN  ()")
    end
    local topN = args[1]
    local sortType = args[2]
    local interval = args[3]
    gg.actor:startProfile(topN,sortType,interval)
end

--- : profile
---@usage
---stopProfile
---: stopProfile  <=> profile
---: proxy send :0000002b gm#stopProfile  <=> :0000002bprofile
function cgm:stopProfile(args)
    gg.actor:stopProfile()
end

--- : 
---@usage
---snapshot (diff/refcount/tablecount/find) [value]
---: snapshot diff    <=> ,diff
---: snapshot refcount 100    <=> 100
---: snapshot tablecount 100  <=> 100table
---: snapshot find 0x7fa830f63580  <=> 
---: snapshot clear           <=> 
--- proxy send :0000002b gm#snapshot diff  <=> :0000002b,diff
function cgm:snapshot(args)
    local ok,args = gg.checkargs(args,"string","*")
    if not ok then
        return self:say("snapshot (diff/refcount/tablecount/find) [value]")
    end
    local mode = args[1]
    local value = args[2]
    return self:say(gg.actor:snapshot(mode,value))
end

--- : ldoc,../doc/server
function cgm:ldoc(args)
    local path = string.format("../doc/server")
    os.execute(string.format("mkdir -p %s",path))
    --os.execute(string.format("svn update --accept=theirs-full %s",path))
    if skynet.config.repo_type == "svn" then
        os.execute(string.format("svn update --accept=theirs-full %s",path))
    else
        os.execute(string.format("git checkout HEAD -- %s",path))
    end
    local cmd = string.format("ldoc . -d %s",path)
    local fd = io.popen(cmd,"r")
    local result = fd:read("*a")
    fd:close()
    if skynet.config.repo_type == "svn" then
        os.execute(string.format("svn add --force %s",path))
        os.execute(string.format("svn commit %s -m ''",path))
    else
        os.execute(string.format("git add %s",path))
        os.execute(string.format("git commit -m 'GM'"))
        os.execute(string.format("git push"))
    end
    logger.print(result)
end

--- : ip
---@usage:
---: set_net_delay 0/(0) [ip]
---: set_net_delay 100 192.168.30.150  <=> 192.168.30.150ip100ms
---: set_net_delay 0 192.168.30.150  <=> 192.168.30.150ip
---: set_net_delay 100  <=> 100ms
---: set_net_delay 0  <=> 
function cgm:set_net_delay(args)
    local ok,args = gg.checkargs(args,"int","*")
    if not ok then
        return self:say("set_net_delay 0/(0) [ip]")
    end
    local delay = args[1]
    local ip = args[2]
    local player = self.master
    if not ip then
        ip = player.ip
    end
    delay = math.max(0,delay)
    local cmd
    if delay == 0 then
        cmd = string.format("sh del_net_delay.sh %s",ip)
    else
        cmd = string.format("sh set_net_delay.sh %s %s",ip,delay)
    end
    local fd = io.popen(cmd)
    local result = fd:read("*all")
    fd:close()
    return self:say(result)
end

--- : 
---@usage:
---: show_net_delay [ip]
---: show_net_delay 100 192.168.30.150  <=> ,IP
---: show_net_delay <=> ,
function cgm:show_net_delay(args)
    local ok,args = gg.checkargs(args,"*")
    if not ok then
        return self:say("show_net_delay [ip]")
    end
    local ip = args[1]
    local player = self.master
    if not ip then
        ip = player.ip
    end
    local cmd = string.format("sh show_net_delay.sh %s",ip)
    local fd = io.popen(cmd)
    local result = fd:read("*all")
    fd:close()
    return self:say(result)
end

--- : pingpong
function cgm:ping(args)
    return "pong2"
end

function __hotfix(module)
end

return cgm
