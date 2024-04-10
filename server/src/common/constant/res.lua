--""
constant.RES_MIN = 101

constant.RES_MIT = 101           --MIT
constant.RES_STARCOIN = 102      --""
constant.RES_ICE = 103           --""
constant.RES_CARBOXYL = 104      --""
constant.RES_TITANIUM = 105      --""
constant.RES_GAS = 106           --""
constant.RES_TESSERACT = 107     --""

constant.RES_BADGE = 110         --""

constant.RES_MAX = 110

--[[
constant.TESSERACT_TO_RES = {
    starCoin = 10,
    ice = 10,
    titanium = 10,
    gas = 10,
}

constant.HYDROXYL_TO_TESSERACT = {
    tesseract = 1,
}
]]

constant.TESSERACT_TO_RES = {
    ["0"] = {starCoin = "10", ice = "10", titanium = "10", gas = "10"},    --""
    ["56"] = {starCoin = "10", ice = "10", titanium = "10", gas = "10"},   --BSC
    ["97"] = {starCoin = "10", ice = "10", titanium = "10", gas = "10"},   --TEST_BSC
    ["1030"] = {starCoin = "10", ice = "10", titanium = "10", gas = "10"}, --CFX
    ["71"] = {starCoin = "10", ice = "10", titanium = "10", gas = "10"},   --TEST_CFX
    ["324"] = {starCoin = "10", ice = "10", titanium = "10", gas = "10"}, --ZKSYNC
    ["280"] = {starCoin = "10", ice = "10", titanium = "10", gas = "10"},   --TEST_ZKSYNC
}

constant.HYDROXYL_TO_TESSERACT = {
    ["0"] = {tesseract = "1"},    --""
    ["56"] = {tesseract = "1"},   --BSC
    ["97"] = {tesseract = "1"},   --TEST_BSC
    ["1030"] = {tesseract = "1"}, --CFX
    ["71"] = {tesseract = "1"},   --TEST_CFX
    ["324"] = {tesseract = "1"}, --ZKSYNC
    ["280"] = {tesseract = "1"},   --TEST_ZKSYNC
}

constant.RES_JSON_KEYS = {
    [constant.RES_MIT] = "mit",
    [constant.RES_STARCOIN] = "starCoin",
    [constant.RES_ICE] = "ice",
    [constant.RES_CARBOXYL] = "carboxyl",
    [constant.RES_TITANIUM] = "titanium",
    [constant.RES_GAS] = "gas",
    [constant.RES_TESSERACT] = "tesseract",
}

constant.RES_KEYS = {
    [constant.RES_MIT] = 101,
    [constant.RES_STARCOIN] = 102,
    [constant.RES_ICE] = 103,
    [constant.RES_CARBOXYL] = 104,
    [constant.RES_TITANIUM] = 105,
    [constant.RES_GAS] = 106,
    [constant.RES_TESSERACT] = 107,
}

constant.RES_NAME = {
    [constant.RES_MIT] = "mit",
    [constant.RES_STARCOIN] = "StarCoin",
    [constant.RES_ICE] = "Ice",
    [constant.RES_CARBOXYL] = "Hydroxyl",
    [constant.RES_TITANIUM] = "Titanium",
    [constant.RES_GAS] = "Gas",
    [constant.RES_TESSERACT] = "Tesseract",
}

constant.ANIMATION_MAIL = 1          --""id
constant.ANIMATION_CHAP_TASK = 2     --""id
constant.ANIMATION_TASK = 3          --""id
constant.ANIMATION_TASK_ACTIVA = 4   --""id