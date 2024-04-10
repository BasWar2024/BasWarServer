local queue = require "skynet.queue"

local cgm = class("cgm")

function cgm:ctor()
    self.cmd = {}
    self.master = nil
    self.lock = queue()
end

function cgm:hotfix_gm()
    local filename = string.format("app.%s.gm.gm",gg.moduleName)
    if not package.searchpath(filename,package.path) then
        return
    end
    gg.hotfix(filename)
end

function cgm:register(cmd,handler,tag,desc)
    assert(tag,cmd)
    self.cmd[cmd:lower()] = {
        cmd = cmd,
        handler = handler,
        tag = tag,
        desc = desc,
    }
end

-- ""
function cgm:register_np(cmd,handler,tag,desc)
    self:register(cmd,handler,tag | self.TAG_NOT_PLAYER_METHOD,desc)
end

function cgm:dispatch(session,source,cmdline)
    if session ~= 0 then
        skynet.retpack(self:docmd(cmdline))
    else
        self:docmd(cmdline)
    end
end

function cgm:unlock(serverid)
    -- skynet.call("unknow_address",...)""
    logger.logf("info","gm","op=unlock,serverid=%s",serverid)
    if serverid == skynet.config.id then
        self.lock = queue()
    else
        gg.cluster:send(serverid,".main","exec","gg.gm:unlock",serverid)
    end
end

function cgm:docmd(cmdline)
    local serverid
    if cmdline == "0 unlock" then
        serverid = skynet.config.id
    else
        serverid = string.match(cmdline,"^0 unlock (.+)$")
    end
    if serverid then
        self:unlock(serverid)
        return true
    end
    local split = string.split(cmdline,"%s")
    return self:lock_docmd(split)
end

function cgm:lock_docmd(split)
    local cmdline = table.concat(split," ")
    local retlist = table.pack(self.lock(self._docmd,self,split))
    logger.logf("info","gm","op=docmd,cmdline='%s',return=%s",cmdline,table.dump(retlist))
    return table.unpack(retlist)
end

function cgm:_docmd(split)
    local cmdline = table.concat(split," ")
    local pid = table.remove(split,1)
    local cmd = table.remove(split,1)
    local args = split
    pid = tonumber(pid)
    if not pid then
        return self:say("no pid: " .. cmdline)
    end
    if not cmd then
        return self:say("no cmd: " .. cmdline,pid)
    end
    local tag
    local handler
    for k,v in pairs(self.cmd) do
        if k == cmd:lower() then
            tag = v.tag
            handler = v.handler
        end
    end
    if not handler then
        return self:say(string.format("not found cmd: %q",cmd),pid)
    end
    self.master_pid = pid
    if pid ~= 0 and (tag & self.TAG_NOT_PLAYER_METHOD) == 0 then
        self.master = self:getplayer(pid)
        if not self.master then
            return pid .. " not online"
        end
    end
    self:say(string.format("%s %s",cmd,table.concat(args," ")))
    local ret = table.pack(xpcall(handler,gg.onerror,self,args))
    if ret[1] then
        self:say("execute no error")
    else
        self:say("execute error")
    end
    self.master_pid = nil
    self.master = nil
    return table.unpack(ret,1,ret.n)
end

function cgm:say(msg,pid)
    if not msg then
        return
    end
    if self.master then
        pid = pid or self.master.pid
    end
    if pid and pid ~= 0 then
        local player = self:getplayer(pid)
        if player then
            msg = i18n.translateto(player.lang,msg)
            local length = #msg
            local step = 4096
            for i=1,length,step do
                local content = msg:sub(i,i+step-1)
                player:sayToGmChannel(content)
            end
        end
    end
    return msg
end

if not cgm.getplayer then
    function cgm:getplayer(pid)
        return nil
    end
end

return cgm