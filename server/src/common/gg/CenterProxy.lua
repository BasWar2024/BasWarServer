local CenterProxy = class("CenterProxy")

function CenterProxy:ctor()
    self.proxy =  ggclass.Proxy.new("center", ".center")
end

---""
---@param cmd string
---@param ... any
function CenterProxy:broadCast2Game(cmd, ...)
    self.proxy:send("api", "broadCast2Game", cmd, ...)
end

---""
---@param cmd string
---@param ... any
function CenterProxy:sendCmd2Player(pid, cmd, ...)
    self.proxy:send("api", "sendCmd2Player", pid, cmd, ...)
end

--""
function CenterProxy:playerSay(pid, msg)
    self:sendCmd2Player(pid, ":say", msg)
end

--""
function CenterProxy:send2Client(pid, cmd, msg)
    self:sendCmd2Player(pid, ":send2Client", cmd, msg)
end

function CenterProxy:call(cmd, ...)
    return self.proxy:call("api", cmd, ...)
end

function CenterProxy:send(cmd, ...)
    self.proxy:send("api", cmd, ...)
end

return CenterProxy