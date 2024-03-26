function unittest.test_C2S_Scene_Enter()
    local player = gg.gm.master
    if not player then
        return
    end
    local cmd = "C2S_Scene_Enter"
    local args = {
        mapId = 1,
        pos = nil,
        lookAt = nil,
        mapLine = 0,
    }
    gg.client:_onmessage(player,cmd,args)
end

function unittest.test_C2S_Scene_Leave()
    local player = gg.gm.master
    if not player then
        return
    end
    local cmd = "C2S_Scene_Leave"
    local args = {
    }
    gg.client:_onmessage(player,cmd,args)
end

function unittest.test_C2S_Scene_LoadProgress()
    local player = gg.gm.master
    if not player then
        return
    end
    local cmd = "C2S_Scene_LoadProgress"
    local args = {
        loadProgress = 100,
    }
    gg.client:_onmessage(player,cmd,args)
end


function unittest.test_C2S_Scene_Connect()
    local player = gg.gm.master
    if not player then
        return
    end
    local linkid = 0
    local cmd = "C2S_Scene_Connect"
    local args = {
        password = 0,
        sceneId = player.scene.sceneId,
        pid = player.pid,
    }
    gg.cluster:send("scenemgr1",".scenemgr","exec","gg.client:onmessage",linkid,cmd,args)
end

function unittest.testScene(cmd)
    local func = unittest["test_" .. cmd]
    if not func then
        return
    end
    func()
end