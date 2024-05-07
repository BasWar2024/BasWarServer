-- app.config.custom""*.config,""skynet.getenv"",""table,
return {
    -- ""
    loginserver = "127.0.0.1:4000",
    loginserver_appkey = "secretStarWar2021",

    -- db_type = "mongodb/mongodb_cluster/redis/redis_cluster"
    db_type = "mongodb",
    mongodb_config = {
        db = skynet.config.appid or "gg",
        rs = {
            {host = "127.0.0.1",port = 27017,username="root",password="StarWar**2021",authmod="scram_sha1",authdb="admin"},
        }
    },

    common_config = {
        db = "dappdb",
        rs = {
            {host = "127.0.0.1",port = 27018,username="root",password="StarWar**2021",authmod="scram_sha1",authdb="admin"},
        }
    },

    gamelog_config = {
        db = "gamelog",
        rs = {
            {host = "127.0.0.1",port = 27019,username="root",password="StarWar**2021",authmod="scram_sha1",authdb="admin"},
        }
    },

    redis_config = {
        host = "127.0.0.1",
        port = 6379,
        auth = "StarWar**2021",
    },

    -- proto_type=protobuf/sproto/json
    proto_type = "protobuf",
    protobuf_config = {
        pbfile = "src/etc/proto/protobuf/all.pb",
        idfile = "src/etc/proto/protobuf/message_define.lua",
    },
    sproto_config = {
        c2s = "src/etc/proto/sproto/all.spb",
        s2c = "src/etc/proto/sproto/all.spb",
        binary = true,
    },
    json_config = {
    },
    bytestream_config = {
    },
    battleServer_config = {
        { host  = "10.168.1.72:8888", url="/checkBattleVaild" },
    },
    checkBattleValid = true,
    -- cluster config
    nodes = require "config.nodes",
    -- ""
    collectVarNames = {
        "pos","mapId","sceneId","url","uri","reason","createTime","loginTime","logoutTime",
        "nodeId","x","y","z","pid","id","type","cfgId","quality","race","style","key","level",
        "source",
    },
}
