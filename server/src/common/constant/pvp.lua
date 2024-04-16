constant.ARMY_COUNT_PER_INDEX = 1                          --pvp""
constant.PVP_FILTER_ATTACKED_COUNT = 4                     --""
constant.PVP_PLUNDER_DEFAULT_RATIO = 0.2                   --""pvp""
constant.NEW_HAND_PVP_PROTECT_RATIO =                      --""
{
    { minBaseLevel = 0, maxBaseLevel = 5, ratio = 0.9 },
    { minBaseLevel = 6, maxBaseLevel = -1, ratio = 0.0 },
}

constant.PVP_PLAYER_BATTLE_TOTAL = 5                       --""
constant.PVP_PLAYER_BATTLE_MAX = 15
constant.PVP_PLAYER_REFRESH_TOTAL = 10                     --""
constant.PVP_PLUNDER_AFTER_PROTECT_RATIOS = { 0.4, 0.3 }   --""

constant.BAN_OFFLINE_BATTLE_TIME = {900, 1800, 3600, 7200, 14400}

constant.PVP_PLAYER_BATTLE_ADD_BASE = {{level = 10, add = 1}, {level = 20, add = 2}}

constant.PVP_SYS_CARBOXYL = 200     -- pvp""
constant.PVP_STAGE_RATIO = {
    {["stage"] = 1, ["score"] = {0,79}, ["ratio"] = 0, ["name"] = "Private"},
    {["stage"] = 2, ["score"] = {80,119}, ["ratio"] = 0.08, ["name"] = "Lieutenant"},
    {["stage"] = 3, ["score"] = {120,149}, ["ratio"] = 0.1, ["name"] = "Captain"},
    {["stage"] = 4, ["score"] = {150,179}, ["ratio"] = 0.12, ["name"] = "Major"},
    {["stage"] = 5, ["score"] = {180,269}, ["ratio"] = 0.2, ["name"] = "Colonel"},
    {["stage"] = 6, ["score"] = {270,999999}, ["ratio"] = 0.5, ["name"] = "General"},
}

constant.PVP_JACKPOT_PLAYER_RATIO = 0.25     --pvp""
constant.PVP_JACKPOT_SHARE_RATIO = 1      --pvp""

constant.PVP_JACKPOT_SYSVAL = 200000000    --PVP""("")
constant.PVP_JACKPOT_INFO = {
    sysCarboxyl = constant.PVP_JACKPOT_SYSVAL,
    plyCarboxyl = 0,
}

constant.PVP_AUTO_ADD_JACKPOT = true    --""PVP""("")

constant.PVP_RANK_MIT_REWARD = {
    {["min_rank"] = 1, ["max_rank"] = 1, ["mit"] = 1000000},
    {["min_rank"] = 2, ["max_rank"] = 2, ["mit"] = 800000},
    {["min_rank"] = 3, ["max_rank"] = 3, ["mit"] = 500000},
    {["min_rank"] = 4, ["max_rank"] = 10, ["mit"] = 200000},
    {["min_rank"] = 11, ["max_rank"] = 20, ["mit"] = 100000},
    {["min_rank"] = 21, ["max_rank"] = 50, ["mit"] = 50000},
    --{["min_rank"] = 51, ["max_rank"] = 100, ["mit"] = 50000},
}

constant.PVP_MATCH_CFGID = 4     -- pvp""id
constant.PVP_BE_ATTACK_LV = 0    -- pvp""
constant.PVP_BE_ATTACK_SEC = 0   -- pvp""
constant.PVP_JOIN_BASE_LV = 3    -- pvp""

constant.PVP_MATCH_WIN_SCORE = 3     -- pvp""
constant.PVP_MATCH_LOSE_SCORE = 1    -- pvp""

constant.PVP_MATCH_TEST_SCORE = nil   -- pvp""