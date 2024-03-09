return {
    handshake = true,
    appid = "g3",
    appkey = "secret",
    loginserver = {
        ip = "127.0.0.1",
        port = 4000,
        appkey = "secret",
    },
    -- proto_type=protobuf/sproto/json
    proto_type = "protobuf",
    protobuf_config = {
        pbfile = "client/proto/protobuf/all.pb",
        idfile = "client/proto/protobuf/message_define.lua",
    },
    sproto_config = {
        c2s = "client/proto/sproto/all.spb",
        s2c = "client/proto/sproto/all.spb",
        binary = true,
    },
    json_config = {
    },
    bytestream_config = {
    },
    kcp_encrypt_key = 1314520,
    kcp_wndsize = 256,
    kcp_mtu = 496,
}
