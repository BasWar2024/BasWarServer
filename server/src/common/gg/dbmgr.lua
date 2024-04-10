local redis = require "skynet.db.redis"
local rediscluster = require "skynet.db.redis.cluster"
local mongo = require "skynet.db.mongo"

local cdbmgr = class("cdbmgr")

function cdbmgr:ctor(db_type)
    self.db_type = db_type or skynet.config.db_type
    if self.db_type:sub(-8,-1) == "_cluster" then
        self.db_is_cluster = true
        self.db_type = self.db_type:sub(1,-9)
    else
        self.db_is_cluster = false
    end
    -- db_type_nodes""db"","",
    -- ""db_type_nodes,""
    self.nodes = skynet.config[self.db_type .. "_nodes"] or {}
    local db_config = skynet.config[self.db_type .. "_config"]
    if db_config then
        if not self.nodes[skynet.config.id] then
            self.nodes[skynet.config.id] = db_config
        end
    end
    self.dbs = {}       -- db_id-> {conf="",db=db""}
    self.cursors = {}
    self.cursor_id = 0
end

function cdbmgr:new_db(db_config)
    local db_type = self.db_type
    local db_is_cluster = self.db_is_cluster
    if db_type == "redis" then
        if not db_is_cluster then
            return redis.connect(db_config)
        else
            return rediscluster.new(db_config.startup_nodes,db_config.opt)
        end
    else
        return mongo.client(db_config)
    end
end

function cdbmgr:getdb(db_id)
    db_id = db_id or skynet.config.id
    local ok,obj = gg.sync:once_do(self.db_type .. "_" .. db_id,function ()
        return self:_getdb(db_id)
    end)
    assert(ok,obj)
    local db = obj.db
    local conf = obj.conf
    -- ""?
    if conf.db then
        db = db[conf.db]
    end
    return db
end

function cdbmgr:_getdb(db_id)
    if not self.dbs[db_id] or not self.dbs[db_id].db then
        local conf = self:get_db_conf(db_id)
        local db = self:new_db(conf)
        self.dbs[db_id] = {
            conf = conf,
            db = db,
            wlocks = {},
        }
    end
    return self.dbs[db_id]
end

function cdbmgr:get_db_conf(db_id)
    db_id = db_id or skynet.config.id
    return self.nodes[db_id]
end

function cdbmgr:shutdown()
    for db_id,obj in pairs(self.dbs) do
        local db = obj.db
        obj.db = nil
        if self.db_type == "redis" then
            if self.db_is_cluster then
                db:close_all_connection()
            else
                db:disconnect()
            end
        else
            db:disconnect()
        end
    end
end

return cdbmgr