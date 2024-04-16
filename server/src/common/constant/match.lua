

constant.MATCH_TYPE_WEEK = 1        --""
constant.MATCH_TYPE_MONTH = 2       --""
constant.MATCH_TYPE_SEASON = 3      --""

constant.MATCH_STARMAP_RANK_SIZE = 100       --""
constant.MATCH_STARMAP_TEST_START = false      --""

constant.MATCH_BELONG_UNION = 1     --""
constant.MATCH_BELONG_PVP = 2       --PVP""
constant.MATCH_BELONG_CLASS = {
    [constant.MATCH_BELONG_UNION] = "StarmapMatch",
    [constant.MATCH_BELONG_PVP] = "PvpMatch",
}

constant.MATCH_REWARD_TYPE_DATE_TIME = 0  --""
constant.MATCH_REWARD_TYPE_DELAY_SEC = 1  --""

constant.MATCH_STATE = {
    NONE = 0,
    NOTICE = 1,
    BEGIN = 2,
    END = 3,
    REWARD = 4,
    SUSPEND = 5,
}
