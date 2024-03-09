local SceneMgrProxy = class("SceneMgrProxy")

function SceneMgrProxy:ctor()
end

function SceneMgrProxy:createScene(mapId,joinPlayers,strategy)
    if gg.isLocalServer() then
        strategy = skynet.config.id
    end
    return gg.proxy.center:call("api","createScene",mapId,joinPlayers,strategy)
end

function SceneMgrProxy:destroyScene(sceneId)
    gg.proxy.center:send("api","destroyScene",sceneId)
end

function SceneMgrProxy:allocScene(mapId,strategy)
    if gg.isLocalServer() then
        strategy = skynet.config.id
    end
    return gg.proxy.center:call("api","allocScene",mapId,strategy)
end

function SceneMgrProxy:getScene(sceneId)
    return gg.proxy.center:call("api","getScene",sceneId)
end

function SceneMgrProxy:getSceneByLine(mapId,mapLine)
    return gg.proxy.center:call("api","getSceneByLine",mapId,mapLine)
end

return SceneMgrProxy