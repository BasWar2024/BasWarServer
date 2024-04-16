constant.STARMAP_NORMAL_GRID = 1  --""
constant.STARMAP_NFT_GRID = 2   --NFT""
constant.STARMAP_BEGIN_GRID = 3 --""

constant.STARMAP_GRID_STATUS_IDLE = 0
constant.STARMAP_GRID_STATUS_BATTLE = 1
constant.STARMAP_GRID_STATUS_PROTECT = 2

constant.STARMAP_CAMPAIGN_REWARD_PERSON = 1 --""-""-""
constant.STARMAP_CAMPAIGN_REWARD_UNION = 2 --""-""-""
constant.STARMAP_GRID_REWARD_PERSON = 3 --""-""-""
constant.STARMAP_GRID_REWARD_UNION = 4 --""-""-""

constant.STARMAP_REWARD_RECORD_LIMIT = 50  --""

constant.STARMAP_BELONG_NONE = 0  --""
constant.STARMAP_BELONG_SELF = 1  --""
constant.STARMAP_BELONG_SELF_UNION = 2 --""
constant.STARMAP_BELONG_OTHER = 3  --""

constant.STARMAP_BELONG_TYPE_SELF = 0  --""
constant.STARMAP_BELONG_TYPE_UNION = 1  --""

constant.STARMAP_COLLECT_TAG_LEN = 12  --""

constant.STARMAP_PERSONAL_COLLECT = 1  --""
constant.STARMAP_UNION_COLLECT = 2  --""

constant.STARMAP_TO_GRID_BUILD_PERSON = 1  --""
constant.STARMAP_TO_GRID_BUILD_UNION = 2  --""

constant.STARMAP_JACKPOT_PLAYER_RATIO = 0.25     --""
constant.STARMAP_JACKPOT_SHARE_RATIO = 0.4        --""

constant.STARMAP_JACKPOT_SYSVAL = 1000000000    --""("")
constant.STARMAP_JACKPOT_INFO = {
    sysCarboxyl = constant.STARMAP_JACKPOT_SYSVAL,
    plyCarboxyl = 0,
}
constant.STARMAP_AUTO_ADD_JACKPOT = true    --""("")

constant.STARMAP_USE_RAND_TIME_SAVE = true  --""
constant.STARMAP_RAND_SAVE_TIME_MIN = -120  --""
constant.STARMAP_RAND_SAVE_TIME_MAX = 240  --""

constant.STARMAP_BATTLE_REPORT_QUERY_LIMIT = 999  --""

constant.STARMAP_EXCEL_CFG_NAME = "starmapConfig"  --excel""
constant.STARMAP_CFG_USE_EXCEL = true
constant.STARMAP_UNION_USE_BACKUP = 1

constant.STARMAP_CONTRI_USE_HOUR = false
constant.STARMAP_GRID_TEST_RES = false

--"" "" ""
constant.STARMAP_CHAIN_EXCLUSIVE = {
    ["0"] = "-1",
    ["-1"] = "-1"
}