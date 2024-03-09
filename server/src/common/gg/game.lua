local lutil = require "lutil"

game = game or {}

function game.init()
    logger.newservice()
    skynet.name(".main",skynet.self())
    if gg.init then
        gg.init()
    end
end

function game.start()
    gg.starting = true
    gg.pid = lutil.getpid()
    gg.cwd = lutil.getcwd()
    gg.runId = string.format("%s.%s",gg.pid,skynet.timestamp())
    local msg = string.format("op=starting,runId=%s",gg.runId)
    logger.output(msg)
    logger.logf("info","game",msg)
    local debug_port = skynet.getenv("debug_port")
    if debug_port then
        -- remember address + port for shell/gm.sh
        local file = io.open("debug_console.txt","wb")
        file:write(string.format("address=%s\nport=%s\nserverid=%s",skynet.self(),debug_port,skynet.config.id))
        file:close()
        local debug_ip = skynet.getenv("debug_ip") or "127.0.0.1"
        game.debug_console = skynet.uniqueservice("debug_console",debug_ip,debug_port)
    end
    if not skynet.getenv "daemon" then
        local file = io.open("skynet.pid","wb")
        file:write(gg.pid)
        file:close()
        console.init()
    end
    if gg.start then
        gg.start()
    end
    gg.starting = nil
    local msg = string.format("op=started,runId=%s",gg.runId)
    logger.output(msg)
    logger.logf("info","game",msg)
end

function game.exit()
    gg.stoping = true
    local msg = string.format("op=stoping,runId=%s",gg.runId)
    logger.output(msg)
    logger.logf("info","game",msg)
    if gg.exit then
        gg.exit()
    end
    msg = string.format("op=stoped,runId=%s",gg.runId)
    logger.output(msg)
    logger.logf("info","game",msg)
    logger.exit()
    local filename = "skynet.pid"
    os.execute(string.format("rm %s",filename))
    logger.output("rm skynet.pid")
    gg.stoping = nil
    skynet.abort()
end

return game