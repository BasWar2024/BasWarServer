--""
constant.RANK_TYPE_BADGE = 1             --1""
constant.RANK_TYPE_COST_MIT = 2          --2mit""
constant.RANK_TYPE_PLANET = 3            --3""
constant.RANK_TYPE_MATCH_BADGE = 4       --4pvp""
constant.RANK_TYPE_GET_HYDROXYL = 5      --5""
constant.RANK_TYPE_UNION_GET_HYDROXYL = 6      --6""

--""
constant.RANK_TYPE_REFRESH_CFG = {
    [constant.REDIS_RANK_BADGE] = {--1""
        ["curKey"] = constant.REDIS_RANK_BADGE_CUR,
        ["dataKey"] = "score",
        ["rankTemp"] = "badgeRankTemp",
        ["rankVersion"] = "badgeRankVersion",
        ["rankType"] = constant.RANK_TYPE_BADGE,
    },
    [constant.REDIS_RANK_COST_MIT] = {--2mit""
        ["curKey"] = constant.REDIS_RANK_COST_MIT_CUR,
        ["dataKey"] = "score",
        ["rankTemp"] = "costMitRankTemp",
        ["rankVersion"] = "costMitRankVersion",
        ["rankType"] = constant.RANK_TYPE_COST_MIT,
    },
    [constant.REDIS_RANK_PLANET] = {--3""
        ["curKey"] = constant.REDIS_RANK_PLANET_CUR,
        ["dataKey"] = "score",
        ["rankTemp"] = "planetRankTemp",
        ["rankVersion"] = "planetRankVersion",
        ["rankType"] = constant.RANK_TYPE_PLANET,
    },
    [constant.REDIS_MATCH_RANK_BADGE] = {--4pvp""
        ["curKey"] = constant.REDIS_MATCH_RANK_BADGE_CUR,
        ["dataKey"] = "score",
        ["rankTemp"] = "matchBadgeRankTemp",
        ["rankVersion"] = "matchBadgeRankVersion",
        ["rankType"] = constant.RANK_TYPE_MATCH_BADGE,
    },
    [constant.REDIS_RANK_GET_HYDROXYL] = {--5""
        ["curKey"] = constant.REDIS_RANK_GET_HYDROXYL_CUR,
        ["dataKey"] = "score",
        ["rankTemp"] = "getHydroxylRankTemp",
        ["rankVersion"] = "getHydroxylRankVersion",
        ["rankType"] = constant.RANK_TYPE_GET_HYDROXYL,
    },
}

--""
constant.RANK_TYPE_UNION_REFRESH = {
    [constant.REDIS_RANK_UNION_GET_HYDROXYL] = {--6""
        ["curKey"] = constant.REDIS_RANK_UNION_GET_HYDROXYL_CUR,
        ["dataKey"] = "score",
        ["rankTemp"] = "unionGetHydroxylRankTemp",
        ["rankVersion"] = "unionGetHydroxylRankVersion",
        ["rankType"] = constant.RANK_TYPE_UNION_GET_HYDROXYL,
    },
}

constant.RANK_TYPE_TO_RANK_KEY = {
    [constant.RANK_TYPE_BADGE] = constant.REDIS_RANK_BADGE,
    [constant.RANK_TYPE_COST_MIT] = constant.REDIS_RANK_COST_MIT,
    [constant.RANK_TYPE_PLANET] = constant.REDIS_RANK_PLANET,
    [constant.RANK_TYPE_MATCH_BADGE] = constant.REDIS_MATCH_RANK_BADGE,
    [constant.RANK_TYPE_GET_HYDROXYL] = constant.REDIS_RANK_GET_HYDROXYL,
    [constant.RANK_TYPE_UNION_GET_HYDROXYL] = constant.REDIS_RANK_UNION_GET_HYDROXYL,
}

constant.RANK_REFRESH_RANK_KEY = {
    [constant.REDIS_RANK_BADGE] = constant.RANK_TYPE_BADGE,
    [constant.REDIS_RANK_COST_MIT] = constant.RANK_TYPE_COST_MIT,
    [constant.REDIS_RANK_PLANET] = constant.RANK_TYPE_PLANET,
    [constant.REDIS_MATCH_RANK_BADGE] = constant.RANK_TYPE_MATCH_BADGE,
    [constant.REDIS_RANK_GET_HYDROXYL] = constant.RANK_TYPE_GET_HYDROXYL,
}

constant.RANK_REFRESH_UNION_RANK_KEY = {
    [constant.REDIS_RANK_UNION_GET_HYDROXYL] = constant.RANK_TYPE_UNION_GET_HYDROXYL,
}