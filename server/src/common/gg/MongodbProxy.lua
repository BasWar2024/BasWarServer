local MongodbProxy = class("MongodbProxy")

MongodbProxy.cache = {}
function MongodbProxy.newDB(node, dbName, tableName)
    node = node or skynet.config.id
    return setmetatable({}, {
        __index = function(t, k)
            local key = dbName.."."..tableName.."."..k
            local func = MongodbProxy.cache[key]
            if func then
                return func
            end
            func = function(obj, ...)
                local proxy = gg.getProxy(node, ".mongodb")
                return proxy:call("api", "runCommand", dbName, tableName, k, ...)
            end
            MongodbProxy.cache[key] = func
            return func
        end
    })
end

function MongodbProxy:ctor()
    self.gamedb = MongodbProxy.newDB(nil, "game", "nil")
    self.gamelogdb = MongodbProxy.newDB(nil, "gamelog", "nil")
    self.commondb = MongodbProxy.newDB(nil, "common", "nil")
    
    self.app = MongodbProxy.newDB(nil, "game", "app")
    --self.account = MongodbProxy.newDB(nil, "game", "account")
    --self.accountalias = MongodbProxy.newDB(nil, "game", "accountalias")
    self.account_roles = MongodbProxy.newDB(nil, "game", "account_roles")
    self.role = MongodbProxy.newDB(nil, "game", "role")
    self.genid = MongodbProxy.newDB(nil, "game", "genid")
    self.roleid = MongodbProxy.newDB(nil, "game", "roleid")
    self.orderid = MongodbProxy.newDB(nil, "game", "orderid")
    self.server = MongodbProxy.newDB(nil, "game", "server")
    self.adminaccount = MongodbProxy.newDB(nil, "game", "adminaccount")
    self.player = MongodbProxy.newDB(nil, "game", "player")
    self.robot = MongodbProxy.newDB(nil, "game", "robot")
    self.match = MongodbProxy.newDB(nil, "game", "match")
    self.starmap = MongodbProxy.newDB(nil, "game", "starmap")
    self.campaign = MongodbProxy.newDB(nil, "game", "campaign")
    self.brief = MongodbProxy.newDB(nil, "game", "brief")
    self.chat_channel = MongodbProxy.newDB(nil, "game", "chat_channel")
    self.mail_mgr = MongodbProxy.newDB(nil, "game", "mail_mgr")
    self.sysmail = MongodbProxy.newDB(nil, "game", "sysmail")
    self.plymail = MongodbProxy.newDB(nil, "game", "plymail")
    self.battle = MongodbProxy.newDB(nil, "game", "battle")
    self.union = MongodbProxy.newDB(nil, "game", "union")
    self.order_ready = MongodbProxy.newDB(nil, "game", "order_ready")
    self.order_settle = MongodbProxy.newDB(nil, "game", "order_settle")
    self.activity = MongodbProxy.newDB(nil, "game", "activity")
    self.gift_code = MongodbProxy.newDB(nil, "game", "gift_code")

    self.account = MongodbProxy.newDB(nil, "common", "account")
    self.accountalias = MongodbProxy.newDB(nil, "common", "accountalias")
    self.nftInfo = MongodbProxy.newDB(nil, "common", "nftInfo")
    self.rechargeToken = MongodbProxy.newDB(nil, "common", "rechargeToken")
    self.rechargeNft = MongodbProxy.newDB(nil, "common", "rechargeNft")
    self.withdrawToken = MongodbProxy.newDB(nil, "common", "withdrawToken")
    self.withdrawNft = MongodbProxy.newDB(nil, "common", "withdrawNft")
    self.withdrawRecord = MongodbProxy.newDB(nil, "common", "withdrawRecord")
    self.pledge = MongodbProxy.newDB(nil, "common", "pledge")
    self.inviteAccount = MongodbProxy.newDB(nil, "common", "inviteAccount")


    self.player_chat_log = MongodbProxy.newDB(nil, "gamelog", "player_chat_log")
    self.active_account_log = MongodbProxy.newDB(nil, "gamelog", "active_account_log")
    self.analyzer_day_check = MongodbProxy.newDB(nil, "gamelog", "analyzer_day_check")
    self.carboxyl_log = MongodbProxy.newDB(nil, "gamelog", "carboxyl_log")
    self.game_statistic_log = MongodbProxy.newDB(nil, "gamelog", "game_statistic_log")
    self.game_statistic_minute_log = MongodbProxy.newDB(nil, "gamelog", "game_statistic_minute_log")
    self.gas_log = MongodbProxy.newDB(nil, "gamelog", "gas_log")
    self.ice_log = MongodbProxy.newDB(nil, "gamelog", "ice_log")
    self.tesseract_log = MongodbProxy.newDB(nil, "gamelog", "tesseract_log")
    self.item_log = MongodbProxy.newDB(nil, "gamelog", "item_log")
    self.mit_log = MongodbProxy.newDB(nil, "gamelog", "mit_log")
    self.warship_log = MongodbProxy.newDB(nil, "gamelog", "warship_log")
    self.hero_log = MongodbProxy.newDB(nil, "gamelog", "hero_log")
    self.build_log = MongodbProxy.newDB(nil, "gamelog", "build_log")
    self.online_players = MongodbProxy.newDB(nil, "gamelog", "online_players")
    self.player_create_log = MongodbProxy.newDB(nil, "gamelog", "player_create_log")
    self.player_login_log = MongodbProxy.newDB(nil, "gamelog", "player_login_log")
    self.player_pve_log = MongodbProxy.newDB(nil, "gamelog", "player_pve_log")
    self.register_account_log = MongodbProxy.newDB(nil, "gamelog", "register_account_log")
    self.server_status_log = MongodbProxy.newDB(nil, "gamelog", "server_status_log")
    self.server_status_statistic_log = MongodbProxy.newDB(nil, "gamelog", "server_status_statistic_log")
    self.starcoin_log = MongodbProxy.newDB(nil, "gamelog", "starcoin_log")
    self.titanium_log = MongodbProxy.newDB(nil, "gamelog", "titanium_log")
    self.gm_players = MongodbProxy.newDB(nil, "gamelog", "gm_players")
    self.starmap_hy_log = MongodbProxy.newDB(nil, "gamelog", "starmap_hy_log")
    self.gm_send_mail_log = MongodbProxy.newDB(nil, "gamelog", "gm_send_mail_log")

    self.invite_day_pay_check = MongodbProxy.newDB(nil, "gamelog", "invite_day_pay_check")
    self.invite_day_pay_detail = MongodbProxy.newDB(nil, "gamelog", "invite_day_pay_detail")
end

function MongodbProxy:call(cmd, ...)
    local proxy = gg.getProxy(skynet.config.id, ".mongodb")
    return proxy:call("api", cmd, ...)
end

function MongodbProxy:send(cmd, ...)
    local proxy = gg.getProxy(skynet.config.id, ".mongodb")
    proxy:send("api", cmd, ...)
end


return MongodbProxy

