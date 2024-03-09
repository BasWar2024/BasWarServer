return {
    ignore_report = true,    -- 
    handshake = true,       -- false:
    appid = "sw",
    appkey = "secret",
    loginserver = {
        ip = "127.0.0.1",
        port = 4000,
        appkey = "secret",
    },
    gate_type = "tcp",           -- tcp
    port = 6001,                 -- 
    ip = "127.0.0.1",            -- ip
    report_ip = "127.0.0.1",     -- ip
    report_script_ip = "127.0.0.1",    -- ip
    debug_port = 6666,           -- debug_console
    startpid = 1000000,          -- id
    report_interval = 600,       -- ()
    robot_num_per_batch = 100,   -- 
    batch_interval = 5,          -- robot_num_per_batch,batch_interval

    -- proto_type=protobuf/sproto/json
    proto_type = "protobuf",
    protobuf_config = {
        pbfile = "../../proto/protobuf/all.pb",
        idfile = "../../proto/protobuf/message_define.lua",
    },
    sproto_config = {
        c2s = "../../proto/sproto/all.spb",
        s2c = "../../proto/sproto/all.spb",
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
