-- app.config.custom*.config,skynet.getenv,table,
return {
    -- 
    loginserver = "127.0.0.1:4000",
    loginserver_appkey = "secret",

    -- db_type = "mongodb/mongodb_cluster/redis/redis_cluster"
    db_type = "mongodb",
    mongodb_config = {
        db = skynet.config.appid or "gg",
        rs = {
            {host = "127.0.0.1",port = 27017,username=nil,password=nil,authmod="scram_sha1",authdb="admin"},
        }
    },

    redis_config = {
        host = "127.0.0.1",
        port = 6379,
        auth = "startwar@@2021",
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
    -- cluster config
    nodes = require "config.nodes",
    -- 
    collectVarNames = {
        "pos","mapId","sceneId","url","uri","reason","createTime","loginTime","logoutTime",
        "nodeId","x","y","z","seatId","groupId","type","x","y","z","effectId","key","camp",
    },
}
