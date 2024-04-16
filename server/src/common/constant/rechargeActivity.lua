constant.CUMULATIVE_FUNDS = 1001    -- ""
constant.DRAW_CARD_DISCOUNT = 1002    -- ""
constant.FIREST_RECHARGE = 1003    -- ""
constant.RECHARGE = 1004    -- ""
constant.DOUBLE_RECHARGE = 1005    -- ""
constant.MOON_CARD = 1006              -- ""
constant.DOUBLE_RECHARGE_VALUE = 2 -- ""
constant.DAILYGIFT = 1008               -- ""
constant.SHOPING_MALL = 1009               -- ""
constant.LOGIN_ACT = 1010            -- ""
constant.LEVEL_PACK = 1015          -- ""


constant.PRO_CUMULATIVE_FUNDS_100 = "gb.cumulativeFunds.100"
constant.PRO_CUMULATIVE_FUNDS_300 = "gb.cumulativeFunds.300"
constant.PRO_MOON_CARD_199 = "gb.moonCard.1999"
constant.CUMULATIVE_FUNDS_100 = 100
constant.CUMULATIVE_FUNDS_300 = 300
constant.CUMULATIVE_FUNDS_100_300 = 400
constant.IS_CUMULATIVE_FUNDS = {
    [constant.PRO_CUMULATIVE_FUNDS_100] = constant.CUMULATIVE_FUNDS_100,
    [constant.PRO_CUMULATIVE_FUNDS_300] = constant.CUMULATIVE_FUNDS_300,
}

constant.PAY_BY_TESSERACT = 101
constant.PAY_BY_USD = 102
constant.SHOPPING_MALL_TYPES = {
    [constant.PAY_BY_TESSERACT] = constant.PAY_BY_TESSERACT,
    [constant.PAY_BY_USD] = constant.PAY_BY_USD
}

constant.IS_RECHARGE = {
["gb.tesseract.99"] = 1,
["gb.tesseract.499"] = 1,
["gb.tesseract.999"] = 1,
["gb.tesseract.2999"] = 1,
["gb.tesseract.4999"] = 1,
["gb.tesseract.9999"] = 1,
}

constant.IS_GIFT_BAG = {
    ["gb.resource.ice.999"] = 1,
    ["gb.starcoin.2999"] = 1,
    ["gb.skill.999"] = 1,
    ["gb.resource.gas.999"] = 1,
    ["gb.resource.titanium.999"] = 1,
    ["gb.skill.humanus.4999"] = 1,
    ["gb.skill.talus.4999"] = 1,
    ["gb.skill.endari.4999"] = 1,
    ["gb.skill.scourge.4999"] = 1,
    ["gb.skill.centra.4999"] = 1,
}

constant.IS_LOGIN_ACT = {
    ["gb.loginActivity.99"] = 1,
    ["gb.loginActivity.199"] = 1,
    ["gb.loginActivity.499"] = 1,
    ["gb.loginActivity.999"] = 1,
    ["gb.loginActivity.1999"] = 1,
    ["gb.loginActivity.2999"] = 1,
    ["gb.loginActivity.4999"] = 1,
}
-- constant.IS_GIFT_BAG = {
--     ["gb.Bresource.999"] = 1,
--     ["gb.starcoin.2999"] = 1,
--     ["gb.Qresource.999"] = 1,
--     ["gb.xrskill.4999"] = 1,
--     ["gb.xjskill.4999"] = 1,
--     ["gb.xyskill.4999"] = 1,
--     ["gb.xgskill.4999"] = 1,
--     ["gb.xgnskill.4999"] = 1,
-- }



constant.IS_PRO_MOON_CARD = {
--    [constant.PRO_MOON_CARD_199] = 1,
    ["gb.supplyPack.20"] = 1,
    ["gb.supplyPack.48"] = 1,
    ["gb.supplyPack.120"] = 1,
    ["gb.supplypack.20"] = 1,
    ["gb.supplypack.48"] = 1,
    ["gb.supplypack.120"] = 1,
}
constant.IS_PRO_STARPACK = {
    ["gb.starpack.2000"] = 1,
    ["gb.starpack.5000"] = 1,
}


constant.TIME_ONE_MONTH_TO_SECONE = 60 * 60 * 24 * 30       -- 30"" "" ""
constant.TIME_ONE_WEEK_TO_SECONE = 60 * 60 * 24 * 7           -- ""
constant.TIME_ONE_DAY_TO_SECONE = 60 * 60 * 24              -- ""
