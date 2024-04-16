--""
constant.ADMIN_AUTHORITY_ROOT = 0             --""
constant.ADMIN_AUTHORITY_OPERATE1 = 1         --"",""
constant.ADMIN_AUTHORITY_OPERATE2 = 2         --"","",""

constant.ADMIN_GLOBAL_SET_ARGS = {             --""
    [constant.REDIS_CHAIN_BRIDGE_STATUS] = {   --1""
            ["open"] = "open",
            ["close"] = "close",
    },
    [constant.REDIS_CHAIN_BRIDGE_NEED_SHIP] = {   --2""
            ["open"] = "open",
            ["close"] = "close",
    },
    [constant.REDIS_DEL_TIMEOUT_BATTLE_DATA] = {   --3""
            ["delete"] = "delete",
    },
}

constant.ADMIN_BUSINESS_BASE_INFO_DICT = {}
constant.ADMIN_BUSINESS_BASE_INFO_DICT["PHONE"] = true
constant.ADMIN_BUSINESS_BASE_INFO_DICT["DISCORD"] = true
constant.ADMIN_BUSINESS_BASE_INFO_DICT["TELEGRAM"] = true
constant.ADMIN_BUSINESS_BASE_INFO_DICT["PAYPAL"] = true
constant.ADMIN_BUSINESS_BASE_INFO_DICT["ERC20"] = true
constant.ADMIN_BUSINESS_BASE_INFO_DICT["TRC20"] = true
constant.ADMIN_BUSINESS_BASE_INFO_DICT["BEP20"] = true

constant.ADMIN_ITEM_CONFIG = "item"
