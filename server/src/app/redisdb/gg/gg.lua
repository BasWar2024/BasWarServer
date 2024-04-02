function gg.init()
    gg.client.queue = true
    gg.cluster.queue = false
    gg.internal.queue = false
    gg.ignoreCfg = false
    gg._init()
    gg.redismgr = ggclass.cdbmgr.new("redis")
end

function gg.start()
    gg.actor:start()
    if gg.standalone then
        gg.cluster:open()
        logger.print("cluster:open")
    end
    gg.internal:open()
    logger.print("internal:open")
    gg.gm:open()
    logger.print("gm:open")
end

function gg.exit()
    logger.logf("info","service","redisdb.exit, mqlen=%s, message=%s",skynet.mqlen(),skynet.stat("message"))
    local exitTick = skynet.timestamp()
    while skynet.mqlen() > 0 do
        skynet.sleep(100)
        local curTick = skynet.timestamp()
        logger.logf("info","service","redisdb.exit, exitTick=%s, curTick=%s",exitTick,curTick)
        if curTick - exitTick > 20 * 1000 then
            break
        end
    end
    gg._exit()
end

--- ""("")
---@param[type=table] linkobj ""
---@param[type=string] err ""
function gg.sayError(linkobj,err)
end

function __hotfix(module)
end