constant.UNION_JOIN_TYPE_UNLIMIT = 0       --""
constant.UNION_JOIN_TYPE_APPLY = 1         --""
constant.UNION_JOIN_TYPE_NOT_ALLOW = 2     --""

constant.UNION_JOB_PRESIDENT = 9           --""
constant.UNION_JOB_VICEPRESIDENT = 8       --""
constant.UNION_JOB_COMMANDER = 7           --""
constant.UNION_JOB_MEMBER = 0              --""

constant.UNION_JOB_NAME = {
    [constant.UNION_JOB_PRESIDENT] = "president",
    [constant.UNION_JOB_VICEPRESIDENT] = "vicepresident",
    [constant.UNION_JOB_COMMANDER] = "commander",
    [constant.UNION_JOB_MEMBER] = "member",
}

constant.UNION_JOB_OP_TRANSFER = 1           --""
constant.UNION_JOB_OP_APPOINTED = 2          --""
constant.UNION_JOB_OP_REMOVE = 3             --""
constant.UNION_JOB_OP_OUTGOING = 4           --""

constant.UNION_DISTRIBUTION_DEMOCRATIC = 1   --""
constant.UNION_DISTRIBUTION_DICTATORSHIP = 2 --""
constant.UNION_DISTRIBUTION_OLIGARCH = 3     --""

constant.UNION_JOINABLE_LIST_MAX_COUNT = 30  --""30""

constant.UNION_JOIN_NOT_DECIDE = 0           --""
constant.UNION_JOIN_AGREE = 1                --""
constant.UNION_JOIN_REJECT = 2               --""

constant.UNION_CAMPAIGNREPORTS_LIMIT_COUNT = 100  --""

constant.UNION_CONTRI_USE_HOUR = false  --""
constant.UNION_DISTRIBUTE_RES_TEST = false  --""

constant.UNION_TECH_DEFENSE_LEVEL_UP = 301
constant.UNION_TECH_DEFENSE_ATTR_ADD = 302
constant.UNION_TECH_SOLIDER_LEVEL_UP = 401
constant.UNION_TECH_SOLIDER_ATTR_ADD = 402
constant.UNION_TECH_RES_LIMIT = 701
constant.UNION_TECH_SOLIDER_SPACE_ADD = 702     --""x

constant.UNION_TECH_KEYS = {
    [constant.UNION_TECH_DEFENSE_LEVEL_UP] = "DefenseLevelUpEffect",
    [constant.UNION_TECH_DEFENSE_ATTR_ADD] = "DefenseAttrAddEffect",
    [constant.UNION_TECH_SOLIDER_LEVEL_UP] = "SoliderLevelUpEffect",
    [constant.UNION_TECH_SOLIDER_ATTR_ADD] = "SoliderAttrAddEffect",
    [constant.UNION_TECH_RES_LIMIT] = "ResLimitEffect",
    [constant.UNION_TECH_SOLIDER_SPACE_ADD] = "SoliderSpaceAddEffect",
}

constant.UNION_TECH_ATTRS = {
    [1] = "level",
    [2] = "hpAddRatio",
    [3] = "atkAddRatio",
    [4] = "atkSpeedAddRatio",
}

constant.UNION_NFT_MINT_MIN_LEVEL = 1  --nft""

constant.UNION_DISABLE_FUNC = {
    ["donate"] = true,
    ["addMint"] = true,
    ["receiveMintItem"] = true,
    ["levelUpTech"] = true,
}

-------------------backup and restore starmap match union data-----------------
constant.UNION_STARMAP_BACKUP_KEYS = {
    ["unionId"] = {dtype = "number"},
    ["starCoin"] = {dtype = "number"},
    ["ice"] = {dtype = "number"},
    ["titanium"] = {dtype = "number"},
    ["gas"] = {dtype = "number"},
    ["carboxyl"] = {dtype = "number"},
    ["gridsScoreCount"] = {dtype = "table"},
    ["techs"] = {dtype = "table"},
    ["contriDegree"] = {dtype = "table"},
    ["combatDict"] = {dtype = "table"},
}

constant.UNION_STARMAP_CLEAR_KEYS = {
    ["starCoin"] = {dtype = "number"},
    ["ice"] = {dtype = "number"},
    ["titanium"] = {dtype = "number"},
    ["gas"] = {dtype = "number"},
    ["carboxyl"] = {dtype = "number", clear = true},
    ["gridsScoreCount"] = {dtype = "table", clear = true},
    -- ["techs"] = {dtype = "table"},
    ["contriDegree"] = {dtype = "table", clear = true},
    ["combatDict"] = {dtype = "table", clear = true},
}
-------------------------------------------------------------------------------