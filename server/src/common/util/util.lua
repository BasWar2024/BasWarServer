util = util or {}

function util.packSceneId(nodeIndex,address)
    return skynet.globaladdress(nodeIndex,address)
end

function util.unpackSceneId(sceneId)
    local nodeIndex = skynet.nodeid(sceneId)
    local nodeId = snowflake.node(nodeIndex)
    local address = skynet.localaddress(sceneId)
    return nodeId,address
end

function util.getSceneProxy(sceneId)
    local sceneNode,sceneAddress = util.unpackSceneId(sceneId)
    local proxy = gg.getProxy(sceneNode,sceneAddress)
    proxy.sceneId = sceneId
    return proxy
end

function util.configScene(mapId,joinPlayers)
    if joinPlayers then
        for i,joinPlayer in ipairs(joinPlayers) do
            local brief = gg.briefMgr:getBrief(joinPlayer.pid)
            table.update(joinPlayer,{
                uuid = brief.uuid,
                name = brief.name,
                loadProgress = 0,
            })
        end
    end
    return {
        mapId = mapId,
        joinPlayers = joinPlayers,
    }
end

util.bornLocation = {
    mapId = 1,
    pos = {x=0,y=0,z=0},
    lookAt = {x=0,y=0,z=1},
}

if not util.vec360 then
    util.vec360 = {}
    for i=1,360 do
        local angle = i*math.deg2Rad
        local pos = util.vec360[i]
        if pos then
            pos.x,pos.y,pos.z = math.sin(angle),0,math.cos(angle)
        else
            util.vec360[i] = Vector3.New(math.sin(angle),0,math.cos(angle))
        end
    end
end

function util.randomPointInCircle(origin,minRadius,maxRadius)
    local distance = math.random(minRadius,maxRadius)
    local angle =  math.random(360)
    return origin +  util.vec360[angle]*distance
end

function util.syncBuildBagToBuildMgr(pid, data)
    local syncDate = {}
    syncDate.pid = pid
    syncDate.builds = {}
    for _, buildData in ipairs(data.builds) do
        if buildData.cfgId == constant.BUILD_BASE then
            syncDate.base_level = buildData.level
        end
        local temp = {}
        temp.id = buildData.id
        temp.cfgId = buildData.cfgId
        temp.quality = buildData.quality
        temp.level = buildData.level
        temp.x = buildData.x
        temp.z = buildData.z
        table.insert(syncDate.builds, temp)
    end
    return syncDate
end

function __hotfix(module)

end

return util