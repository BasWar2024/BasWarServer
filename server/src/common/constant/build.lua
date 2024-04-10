--""
constant.BUILD_BASE = 6010001                                                   --""
constant.BUILD_BASE_PVE = 6013001                                               --PVE""
constant.BUILD_BLACKHOLE_REPOSITORIE = 6010010                                  --""
constant.BUILD_HEROHUT = 6020001                                                --""
constant.BUILD_HYPERSPACERESEARCH = 6020002                                     --""
constant.BUILD_LIBERATORSHIP = 0                                                --""
constant.BUILD_RESERVE_ARMY = 6020006                                           --""
constant.BUILD_SANCTUARY = 6020007                                              --""
constant.BUILD_BLACK_MARKET = 6020005                                           --""
--"", (x,z)
constant.BUILD_LIBERATORSHIPPOSLIST = {
    {9.00, -9.00}, {15.00, -9.00}, {19.54, -9.00}, {25.47, -9.00}, {29.60, -9.00}, {35.93, -9.00}, {40.36, -9.00}, {46.27, -9.00}
}


--""
constant.BUILD_TYPE_DEFAULT = 0            --""
constant.BUILD_TYPE_ECONOMY = 1            --""
constant.BUILD_TYPE_DEVELOP = 2            --""
constant.BUILD_TYPE_DEFEND = 3             --""
constant.BUILD_TYPE_MESS = 8               --""

constant.BUILD_TYPE_CAN_MOVE = {
    [constant.BUILD_TYPE_ECONOMY] = true,
    [constant.BUILD_TYPE_DEVELOP] = true,
    [constant.BUILD_TYPE_DEFEND] = true,
}

--""
constant.BUILD_SUBTYPE_DEFAULT = 0            --""
constant.BUILD_SUBTYPE_CANNON = 1             --""
constant.BUILD_SUBTYPE_MINE = 2               --""
constant.BUILD_SUBTYPE_LIBERATORSHIP = 4      --""

constant.BUILD_SUBTYPE_CAN_MOVE = {
    [constant.BUILD_SUBTYPE_CANNON] = true,
    [constant.BUILD_SUBTYPE_MINE] = true,
}

constant.BUILD_INIT_QUALITY = 0               --""
constant.BUILD_INIT_RACE = 0                  --""
constant.BUILD_INIT_STYLE = 0                 --""
constant.BUILD_INIT_LEVEL = 1

constant.BUILD_BELONG_UNION = 2               --""

constant.BUILD_USE_MESS_MIN_LV = false

constant.BUILD_CHAIN_TOWER = 63023        -- ""