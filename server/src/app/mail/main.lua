require "app.mail.init"
local serviceName = ...

skynet.init(function ()
    local init
    if serviceName == nil then
        serviceName = string.match(SERVICE_NAME,"^.+/(.+)/.+$")
        serviceName = "." .. serviceName
        gg.standalone = true
        init = game.init
    else
        init = gg.init
    end
    gg.serviceName = serviceName
    gg.actor = ggclass.cactor.new()
    local ok,err = xpcall(init,debug.traceback)
    if not ok then
        local msg = string.format("op=init,service=%s,err=%s",SERVICE_NAME,err)
        print(msg)
        skynet.error(msg)
        os.exit()
    end
end)

skynet.start(function ()
    local start = gg.standalone and game.start or gg.start
    local ok,err = xpcall(start,gg.onerror)
    if not ok then
        local msg = string.format("op=start,service=%s,err=%s",SERVICE_NAME,err)
        print(msg)
        skynet.error(msg)
        os.exit()
    end
end)

skynet.info_func(function ()
    return table.dump(gg.profile.cost)
end)