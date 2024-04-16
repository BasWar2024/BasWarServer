constant.PAYCHANNEL_LOCAL = "pay_local"                        --""
constant.PAYCHANNEL_APPSTORE = "pay_appstore"                  --""
constant.PAYCHANNEL_GOOGLEPLAY = "pay_googleplay"              --google""
constant.PAYCHANNEL_XSOLLA = "pay_xsolla"                      --xsolla""
constant.PAYCHANNEL_INTERNATION = "pay_internation"            --""


constant.PAY_OP_GMAPPROVE = "GmApprove"                        --gm""
constant.PAY_OP_XSOLLACHECK = "XsollaCheck"                    --xsolla""
constant.PAY_OP_INTERNATIONCHECK = "InternationCheck"          --internation""
constant.PAY_OP_APPSTORECHECK = "AppstoreCheck"                --appstore""
constant.PAY_OP_GOOGLEPLAYCHECK = "GoogleplayCheck"            --googleplay""

constant.PAY_STATE_0 = 0                  --""
constant.PAY_STATE_1 = 1                  --""
constant.PAY_STATE_2 = 2                  --""

constant.PAY_CURRENCY_INFO = {
    ["USD"] = {["en_name"]="United States dollar", ["rate"]="1"},
    ["EUR"] = {["en_name"]="Euro", ["rate"]="0.94"},
    ["CNY"] = {["en_name"]="Renminbi", ["rate"]="6.88"},
    ["HKD"] = {["en_name"]="Hong Kong Dollar", ["rate"]="7.85"},
    ["JPY"] = {["en_name"]="Japanese yen", ["rate"]="136.36"},
    ["THB"] = {["en_name"]="Thai baht", ["rate"]="35.05"},
    ["GBP"] = {["en_name"]="Pound sterling", ["rate"]="0.83"},
    ["PHP"] = {["en_name"]="Philippine peso", ["rate"]="55.01"},
    ["AUD"] = {["en_name"]="Australian Dollar", ["rate"]="1.48"},
    ["KRW"] = {["en_name"]="South Korean won", ["rate"]="1315.58"},
    ["IPA"] = {["en_name"]="Ruble", ["rate"]="75.05"},
    ["CAD"] = {["en_name"]="Canadian dollar", ["rate"]="1.36"},
    ["TRY"] = {["en_name"]="Turkish Lire", ["rate"]="18.89"},
    ["SAR"] = {["en_name"]="Saudi riyal", ["rate"]="3.75"},
    ["VND"] = {["en_name"]="Vietnamese đồng", ["rate"]="23730"},
    ["MYR"] = {["en_name"]="Malaysian ringgit", ["rate"]="4.49"},
    ["IDR"] = {["en_name"]="Indonesian rupiah", ["rate"]="15250.55"},
    ["BRL"] = {["en_name"]="Brazilian real", ["rate"]="5.24"},
    ["ARS"] = {["en_name"]="Argentine peso", ["rate"]="197.17"}
}


constant.PAY_CHANNEL_INFO = {
    [constant.PAYCHANNEL_LOCAL] = {
        ["name"] = "local",
        ["status"] = "open",
        ["currency"] = {
            ["USD"] = "United States dollar"
        },
        ["payType"] = {
            ["local"] = { ["status"] = "open" }
        }
    },
    [constant.PAYCHANNEL_XSOLLA] = {
        ["name"] = "xsolla",
        ["status"] = "open",
        ["currency"] = {
            ["USD"] = "United States dollar"
        },
        ["payType"] = {
            ["xsolla"] = { ["status"] = "open" },
            ["sandbox"] = { ["status"] = "open" }
        }
    },
    [constant.PAYCHANNEL_APPSTORE] = {
        ["name"] = "appstore",
        ["status"] = "open",
        ["currency"] = {
            ["USD"] = "United States dollar"
        },
        ["payType"] = {
            ["appstore"] = { ["status"] = "open" },
        }
    },
    [constant.PAYCHANNEL_GOOGLEPLAY] = {
        ["name"] = "googleplay",
        ["status"] = "open",
        ["currency"] = {
            ["USD"] = "United States dollar"
        },
        ["payType"] = {
            ["googleplay"] = { ["status"] = "open" },
        }
    },
    [constant.PAYCHANNEL_INTERNATION] = {
        ["name"] = "internation",
        ["status"] = "close",
        ["currency"] = {
            ["USD"] = "United States dollar",
            ["CNY"] = "Renminbi",
            ["EUR"] = "Euro",
            ["HKD"] = "Hong Kong dollar",
        },
        ["payType"] = {
            ["INTERNATIONAL_CARD"] = { ["status"] = "close" },
            ["INTERNATIONAL_TEST1"] = { ["status"] = "close" },
            ["INTERNATIONAL_TEST2"] = { ["status"] = "close", ["support"] = { "USD", "CNY" } }
        }
    }
}