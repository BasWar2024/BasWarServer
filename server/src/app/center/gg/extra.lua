--mongo""
function gg.createMongoIndex()
    --common
    gg.mongoProxy.account:createIndex({"account", unique = true})
    gg.mongoProxy.account:createIndex({"owner_address", unique = false})

    gg.mongoProxy.rechargeToken:createIndex({"order_num", unique = true})
    gg.mongoProxy.rechargeNft:createIndex({"order_num", unique = true})
    gg.mongoProxy.withdrawToken:createIndex({"order_num", unique = true})
    gg.mongoProxy.withdrawNft:createIndex({"order_num", unique = true})
    gg.mongoProxy.nftInfo:createIndex({"token_id", unique = true})
    gg.mongoProxy.withdrawRecord:createIndex({"pid", unique = false})

    --gg.mongoProxy.pledge:createIndex({"owner_address", unique = false})
    --gg.mongoProxy.pledge:createIndex({"chain_id", unique = false})
    gg.mongoProxy.pledge:createIndex({"chain_id", "owner_address", unique = true})

    --game""
    gg.mongoProxy.account_roles:createIndex({"account","appid",unique = false})
    gg.mongoProxy.player:createIndex({"pid", unique = true})
    gg.mongoProxy.battle:createIndex({"battleId", unique = true})
    gg.mongoProxy.brief:createIndex({"pid", unique = true})
    gg.mongoProxy.role:createIndex({"roleid", unique = true})
    gg.mongoProxy.genid:createIndex({"idkey", unique = true})
    gg.mongoProxy.starmap:ensureIndex({cfgId=1}, {unique = true, name="IDX_CFGID"})
    gg.mongoProxy.campaign:ensureIndex({campaignId=1}, {unique = true, name="IDX_CAMPAIGNID"})
    gg.mongoProxy.union:ensureIndex({unionId=1}, {unique = true, name="IDX_UNIONID"})
    gg.mongoProxy.sysmail:ensureIndex({id=1}, {unique = true, name="IDX_ID"})
    gg.mongoProxy.plymail:ensureIndex({id=1}, {unique = true, name="IDX_ID"})

    gg.mongoProxy.order_ready:createIndex({"orderId", unique = true})
    gg.mongoProxy.order_ready:createIndex({"pid", unique = false})
    gg.mongoProxy.order_ready:createIndex({"platform", unique = false})
    gg.mongoProxy.order_ready:createIndex({"payChannel", unique = false})
    gg.mongoProxy.order_ready:createIndex({"createDate", unique = false})
    gg.mongoProxy.order_ready:createIndex({"monthno", unique = false})
    gg.mongoProxy.order_ready:createIndex({"dayno", unique = false})
    gg.mongoProxy.order_ready:createIndex({"weekno", unique = false})
    gg.mongoProxy.order_ready:createIndex({"settledayno", unique = false})
    gg.mongoProxy.order_ready:createIndex({"settleweekno", unique = false})
    gg.mongoProxy.order_ready:createIndex({"settlemonthno", unique = false})
    gg.mongoProxy.order_ready:createIndex({"settleDate", unique = false})
    gg.mongoProxy.order_ready:createIndex({"transaction", unique = false})

    gg.mongoProxy.order_settle:createIndex({"orderId", unique = true})
    gg.mongoProxy.order_settle:createIndex({"pid", unique = false})
    gg.mongoProxy.order_settle:createIndex({"platform", unique = false})
    gg.mongoProxy.order_settle:createIndex({"payChannel", unique = false})
    gg.mongoProxy.order_settle:createIndex({"createDate", unique = false})
    gg.mongoProxy.order_settle:createIndex({"monthno", unique = false})
    gg.mongoProxy.order_settle:createIndex({"dayno", unique = false})
    gg.mongoProxy.order_settle:createIndex({"weekno", unique = false})
    gg.mongoProxy.order_settle:createIndex({"settledayno", unique = false})
    gg.mongoProxy.order_settle:createIndex({"settleweekno", unique = false})
    gg.mongoProxy.order_settle:createIndex({"settlemonthno", unique = false})
    gg.mongoProxy.order_settle:createIndex({"settleDate", unique = false})
    gg.mongoProxy.order_settle:createIndex({"transaction", unique = false})

    gg.mongoProxy.gift_code:createIndex({"cfgId", unique = false})
    gg.mongoProxy.gift_code:createIndex({"code", unique = false})
    gg.mongoProxy.gift_code:createIndex({"pid", unique = false})
    gg.mongoProxy.gift_code:createIndex({"rewardTime", unique = false})

    --gamelog""
    gg.mongoProxy.player_pve_log:createIndex({"pid", unique = false})
    gg.mongoProxy.player_pve_log:createIndex({"platform", unique = false})
    gg.mongoProxy.player_pve_log:createIndex({"timestamp", unique = false})
    gg.mongoProxy.player_pve_log:createIndex({"pveScore", unique = false})

    gg.mongoProxy.mit_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.mit_log:ensureIndex({resCfgId=1}, {unique = false, name="IDX_RESCFGID"})
    gg.mongoProxy.mit_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.mit_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.mit_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.mit_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.carboxyl_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.carboxyl_log:ensureIndex({resCfgId=1}, {unique = false, name="IDX_RESCFGID"})
    gg.mongoProxy.carboxyl_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.carboxyl_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.carboxyl_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.carboxyl_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.gas_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.gas_log:ensureIndex({resCfgId=1}, {unique = false, name="IDX_RESCFGID"})
    gg.mongoProxy.gas_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.gas_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.gas_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.gas_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.ice_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.ice_log:ensureIndex({resCfgId=1}, {unique = false, name="IDX_RESCFGID"})
    gg.mongoProxy.ice_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.ice_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.ice_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.ice_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.starcoin_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.starcoin_log:ensureIndex({resCfgId=1}, {unique = false, name="IDX_RESCFGID"})
    gg.mongoProxy.starcoin_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.starcoin_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.starcoin_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.starcoin_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.titanium_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.titanium_log:ensureIndex({resCfgId=1}, {unique = false, name="IDX_RESCFGID"})
    gg.mongoProxy.titanium_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.titanium_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.titanium_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.titanium_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.tesseract_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.tesseract_log:ensureIndex({resCfgId=1}, {unique = false, name="IDX_RESCFGID"})
    gg.mongoProxy.tesseract_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.tesseract_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.tesseract_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.tesseract_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.item_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.item_log:ensureIndex({cfgId=1}, {unique = false, name="IDX_CFGID"})
    gg.mongoProxy.item_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.item_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.item_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.item_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.warship_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.warship_log:ensureIndex({cfgId=1}, {unique = false, name="IDX_CFGID"})
    gg.mongoProxy.warship_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.warship_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.warship_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.warship_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.hero_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.hero_log:ensureIndex({cfgId=1}, {unique = false, name="IDX_CFGID"})
    gg.mongoProxy.hero_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.hero_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.hero_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.hero_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.build_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.build_log:ensureIndex({cfgId=1}, {unique = false, name="IDX_CFGID"})
    gg.mongoProxy.build_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.build_log:ensureIndex({logType=1}, {unique = false, name="IDX_LOG_TYPE"})
    gg.mongoProxy.build_log:ensureIndex({reason=1}, {unique = false, name="IDX_REASON"})
    gg.mongoProxy.build_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})

    gg.mongoProxy.invite_day_pay_check:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})

    gg.mongoProxy.invite_day_pay_detail:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.invite_day_pay_detail:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})
    gg.mongoProxy.invite_day_pay_detail:ensureIndex({weekno=1}, {unique = false, name="IDX_WEEKNO"})
    gg.mongoProxy.invite_day_pay_detail:ensureIndex({monthno=1}, {unique = false, name="IDX_MONTHNO"})
    gg.mongoProxy.invite_day_pay_detail:ensureIndex({fatherAccount = 1}, {unique = false, name = "IDX_FATHER_ACCOUNT"})

    --""
    gg.mongoProxy.online_players:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.online_players:ensureIndex({account=1}, {unique = false, name="IDX_ACCOUNT"})
    gg.mongoProxy.online_players:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.online_players:ensureIndex({onlineStatus=1}, {unique = false, name="IDX_ONLINE_STATUS"})
    gg.mongoProxy.online_players:ensureIndex({tuoguanStatus=1}, {unique = false, name="IDX_TUOGUAN_STATUS"})

    --""("", "")
    gg.mongoProxy.active_account_log:ensureIndex({account=1}, {unique = true, name="IDX_ACCOUNT"})
    gg.mongoProxy.active_account_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.active_account_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})
    gg.mongoProxy.active_account_log:ensureIndex({monthno=1}, {unique = false, name="IDX_MONTHNO"})
    gg.mongoProxy.active_account_log:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})
    gg.mongoProxy.active_account_log:ensureIndex({weekno=1}, {unique = false, name="IDX_WEEKNO"})

    --""("", "")
    gg.mongoProxy.register_account_log:ensureIndex({account=1}, {unique = true, name="IDX_ACCOUNT"})
    gg.mongoProxy.register_account_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.register_account_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})
    gg.mongoProxy.register_account_log:ensureIndex({monthno=1}, {unique = false, name="IDX_MONTHNO"})
    gg.mongoProxy.register_account_log:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})
    gg.mongoProxy.register_account_log:ensureIndex({weekno=1}, {unique = false, name="IDX_WEEKNO"})

    --""("", "")
    gg.mongoProxy.player_create_log:ensureIndex({pid=1}, {unique = true, name="IDX_PID"})
    gg.mongoProxy.player_create_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.player_create_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})
    gg.mongoProxy.player_create_log:ensureIndex({monthno=1}, {unique = false, name="IDX_MONTHNO"})
    gg.mongoProxy.player_create_log:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})
    gg.mongoProxy.player_create_log:ensureIndex({weekno=1}, {unique = false, name="IDX_WEEKNO"})

    gg.mongoProxy.player_login_log:ensureIndex({lid=1}, {unique = true, name="IDX_LID"})
    gg.mongoProxy.player_login_log:ensureIndex({pid=1}, {unique = false, name="IDX_PID"})
    gg.mongoProxy.player_login_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.player_login_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})
    gg.mongoProxy.player_login_log:ensureIndex({monthno=1}, {unique = false, name="IDX_MONTHNO"})
    gg.mongoProxy.player_login_log:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})
    gg.mongoProxy.player_login_log:ensureIndex({weekno=1}, {unique = false, name="IDX_WEEKNO"})

    gg.mongoProxy.game_statistic_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})
    gg.mongoProxy.game_statistic_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.game_statistic_log:ensureIndex({monthno=1}, {unique = false, name="IDX_MONTHNO"})
    gg.mongoProxy.game_statistic_log:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})
    gg.mongoProxy.game_statistic_log:ensureIndex({weekno=1}, {unique = false, name="IDX_WEEKNO"})

    gg.mongoProxy.game_statistic_minute_log:ensureIndex({hourMin=1}, {unique = false, name="IDX_HOURMIN"})
    gg.mongoProxy.game_statistic_minute_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.game_statistic_minute_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})
    gg.mongoProxy.game_statistic_minute_log:ensureIndex({monthno=1}, {unique = false, name="IDX_MONTHNO"})
    gg.mongoProxy.game_statistic_minute_log:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})
    gg.mongoProxy.game_statistic_minute_log:ensureIndex({weekno=1}, {unique = false, name="IDX_WEEKNO"})

    gg.mongoProxy.server_status_statistic_log:ensureIndex({hourMin=1}, {unique = false, name="IDX_HOURMIN"})
    gg.mongoProxy.server_status_statistic_log:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.server_status_statistic_log:ensureIndex({server=1}, {unique = false, name="IDX_SERVER"})
    gg.mongoProxy.server_status_statistic_log:ensureIndex({createDate=1}, {unique = false, name="IDX_CREATE_DATE"})
    gg.mongoProxy.server_status_statistic_log:ensureIndex({monthno=1}, {unique = false, name="IDX_MONTHNO"})
    gg.mongoProxy.server_status_statistic_log:ensureIndex({dayno=1}, {unique = false, name="IDX_DAYNO"})
    gg.mongoProxy.server_status_statistic_log:ensureIndex({weekno=1}, {unique = false, name="IDX_WEEKNO"})

    --""
    gg.mongoProxy.inviteAccount:ensureIndex({account = 1}, {unique = true, name = "IDX_ACCOUNT"})
    gg.mongoProxy.inviteAccount:ensureIndex({platform=1}, {unique = false, name="IDX_PLATFORM"})
    gg.mongoProxy.inviteAccount:ensureIndex({inviteCode = 1}, {unique = false, name = "IDX_INVITE_CODE"})
    gg.mongoProxy.inviteAccount:ensureIndex({pid = 1}, {unique = false, name = "IDX_PID"})
    gg.mongoProxy.inviteAccount:ensureIndex({fatherInviteCode = 1}, {unique = false, name = "IDX_FATHER_INVITE_CODE"})
    gg.mongoProxy.inviteAccount:ensureIndex({fatherPid = 1}, {unique = false, name = "IDX_FATHER_PID"})
    gg.mongoProxy.inviteAccount:ensureIndex({fatherAccount = 1}, {unique = false, name = "IDX_FATHER_ACCOUNT"})

    --""
    gg.mongoProxy.starmap_hy_log:ensureIndex({unionId=1}, {unique = false, name="IDX_UNIONID"})
    gg.mongoProxy.starmap_hy_log:ensureIndex({gridCfgId=1}, {unique = false, name="IDX_GRIDCFGID"})

end