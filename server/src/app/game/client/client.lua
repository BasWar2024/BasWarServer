local cclient = reload_class("cclient")

--- "",""nil,""player/linkobj
function cclient:filter(linkobj,cmd,args,response,session,ud)
    local player
    if linkobj.pid then
        player = assert(gg.playermgr:getonlineplayer(linkobj.pid))
    else
        if not self.unauth_cmd[cmd] then
            return
        end
        player = linkobj
    end
    return player
end

function cclient:onConnect(linkobj)
    self:send(linkobj,"S2C_Hello",{
        randseed = skynet.now(),
    })
end

function cclient:onClose(linkobj)
    local pid = linkobj.pid
    local player = gg.playermgr:getplayer(pid)
    if player then
        player:disconnect(ggclass.cplayer.LOGOUT_TYPE_NORMAL)
    end
end

function cclient:open()
    self:register_http("/api/rpc",require "app.game.client.http.api.rpc")

    local login = require("app.game.client.login")
    self:register_module(login)
    self:register_unauth_module(login)

    self:register_module(require("app.game.client.msg"))
    self:register_module(require("app.game.client.player"))
    self:register_module(require("app.game.client.battle"))
end

function __hotfix(module)
    gg.client:open()
end

return cclient
