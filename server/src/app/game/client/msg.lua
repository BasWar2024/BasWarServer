local net = {}

function net.C2S_Msg_GM(player,args)
    local cmd = assert(args.cmd)
    if typename(player) ~= "cplayer" then
        logger.print(",GM",cmd)
        return
    end
    if not player:isGm() then
        player:say(i18n.format("not GM"))
        return
    end
    cmd = string.format("%s %s",player.pid,cmd)
    gg.gm:docmd(cmd)
end

function __hotfix(module)
    gg.client:open()
end

return net