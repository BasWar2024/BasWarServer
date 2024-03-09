servermgr = servermgr or {}

function servermgr.saveserver(appid,server)
    local db = gg.dbmgr:getdb()
    local app = assert(util.get_app(appid))
    local db_name = app.current_serverlist or "server"
    local id = assert(server.id)
    server.appid = appid
    db[db_name]:update({appid=appid,id=id},server,true,false)
end

function servermgr.loadserver(appid,serverid)
    local db = gg.dbmgr:getdb()
    local app = assert(util.get_app(appid))
    local db_name = app.current_serverlist or "server"
    local doc = db[db_name]:findOne({appid=appid,id=serverid})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end


function servermgr.checkserver(server)
    local server,err = table.check(server,{
        ip = {type="string"},                                   -- ip
        cluster_ip = {type="string",optional=true},             -- ip
        cluster_port = {type="number",optional=true},           -- 
        tcp_port = {type="number",optional=true},               -- tcp
        kcp_port = {type="number",optional=true},               -- kcp
        websocket_port = {type="number",optional=true},         -- websocket
        debug_port = {type="number",optional=true},             -- debug
        http_port = {type="number",optional=true},              -- http
        id = {type="string"},                                   -- ID
        name = {type="string"},                                 -- 
        index = {type="number"},                                -- 
        type = {type="string"},                                 -- 
        zoneid = {type="string"},                               -- ID
        zonename = {type="string"},                             -- 
        clusterid = {type="string"},                            -- id
        clustername = {type="string"},                          -- 
        opentime = {type="number"},                             -- 
        is_open = {type="number",optional=true,default=1},       -- 
        busyness = {type="number",optional=true,default=0.0},   -- 
        updatetime = {type="number",optional=true,default=os.time()}, -- 
    })
    return server,err
end

function servermgr.addserver(appid,server)
    local server,err = servermgr.checkserver(server)
    if err then
        return httpc.answer.code.SERVER_FMT_ERR,err
    end
    if not (server.tcp_port or server.kcp_port or server.websocket_port) then
        return httpc.answer.code.SERVER_FMT_ERR,"no tcp/kcp/websocket port"
    end
    server.createTime = os.time()
    servermgr.saveserver(appid,server)
    return httpc.answer.code.OK
end

function servermgr.delserver(appid,serverid)
    local db = gg.dbmgr:getdb()
    local app = assert(util.get_app(appid))
    local db_name = app.current_serverlist or "server"
    local ok = db[db_name]:safe_delete({appid=appid,id=serverid},true)
    if not ok then
        return httpc.answer.code.SERVER_NOEXIST
    else
        return httpc.answer.code.OK
    end
end

function servermgr.updateserver(appid,sync_server)
    local serverid = assert(sync_server.id)
    if not util.get_app(appid) then
        return httpc.answer.code.APPID_NOEXIST
    end
    local server = servermgr.getserver(appid,serverid)
    if not server then
        return httpc.answer.code.SERVER_NOEXIST
    end
    table.update(server,sync_server)
    servermgr.saveserver(appid,server)
    return httpc.answer.code.OK
end

function servermgr.getserver(appid,serverid)
    local server = servermgr.loadserver(appid,serverid)
    if server then
        local now = os.time()
        if server.is_down == nil then
            if (now - (server.updatetime or 0)) < 40 then
                server.is_down = 0
            else
                server.is_down = 1
            end
        end
        if server.is_new == nil then
            if (now - server.opentime) > 14 * 24 * 3600 then
                server.is_new = 0
            else
                server.is_new = 1
            end
        end
    end
    return server
end
--random
function servermgr.getonlineserver(appid)
    local all_serverlist = servermgr.getserverlist(appid)
    local online_serverlist = table.filter(all_serverlist,function (srv)
        return srv.is_down == 0
    end)
    if #online_serverlist == 0 then
        return nil
    end
    return online_serverlist[math.random(1, #online_serverlist)]
end

function servermgr.getserverlist(appid)
    local db = gg.dbmgr:getdb()
    local app = assert(util.get_app(appid))
    local db_name = app.current_serverlist or "server"
    local serverlist = {}
    local cursor = db[db_name]:find({appid=appid})
    local now = os.time()
    while cursor:hasNext() do
        local doc = cursor:next()
        doc._id = nil
        local server = doc
        if server.is_down == nil then
            if (now - (server.updatetime or 0)) < 40 then
                server.is_down = 0
            else
                server.is_down = 1
            end
        end
        if server.is_new == nil then
            if (now - server.opentime) > 14 * 24 * 3600 then
                server.is_new = 0
            else
                server.is_new = 1
            end
        end
        table.insert(serverlist,server)
    end
    return serverlist
end

function servermgr.switchserverlist(appid,serverlist_name)
    local app = assert(util.get_app(appid))
    app.current_serverlist = serverlist_name
    local db = gg.dbmgr:getdb()
    db.app:update({appid=appid},app,true,false)
    return httpc.answer.code.OK
end

return servermgr
