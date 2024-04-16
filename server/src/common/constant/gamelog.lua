gamelog = gamelog or {} 

local function add(logType)
    assert(gamelog[logType.id] == nil, "repeat log type id="..logType.id)
    gamelog[logType.id] = logType.msg
    return logType.id
end

gamelog.DRAW_ACHIEVEMENT = add{ id=1, msg = "draw achievement" }                                  --""
gamelog.GET_BUILD_RES = add{ id=2, msg = "get build res" }                                        --""
gamelog.REMOVE_MESS = add{ id=3, msg = "remove mess" }                                            --""，""，""，""
gamelog.PLEDGE_MIT = add{ id=4, msg = "pledge mit" }                                              --""mit
gamelog.CANCEL_PLEDGE_MIT = add{ id=5, msg = "cancel pledge mit" }                                --""
gamelog.CREATE_PLAYER_GIFT = add{ id=6, msg = "create player gift" }                              --""
gamelog.EXCHANGE_RES = add{ id=7, msg = "exchange res" }                                          --""
gamelog.DRAW_TASK = add{ id=8, msg = "draw task" }                                                --""    --""
gamelog.DRAW_UNION_TAX = add{ id=9, msg = "draw union tax" }                                      --""  --""
gamelog.GM = add{ id=10, msg = "gm operate" }                                                     --GM""
gamelog.EDITOR = add{ id=11, msg = "Editor operate" }                                             --""
gamelog.CREATE_UNION = add{ id=12, msg = "create union" }                                         --""
gamelog.MODIFY_UNION_NAME = add{ id=13, msg = "modify union name" }                               --""

gamelog.SOLIDER_QUALITY_LEVEL_UP = add{ id=17, msg = "level up solider quality" }                 --""    --""
gamelog.SPEED_SOLIDER_QUALITY_LEVEL_UP = add{ id=18, msg = "speed level up solider qualtiy" }     --""   --""
gamelog.FORGE_LEVEL_UP = add{ id=19, msg = "forge level up" }                                     --""    --""
gamelog.MINE_LEVEL_UP = add{ id=20, msg = "mine level up" }                                       --""    --""
gamelog.SPEED_MINE_LEVEL_UP = add{ id=21, msg = "speed mine level up" }                           --""  --""
gamelog.TRAIN_SOLIDER = add{ id=22, msg = "train solider" }                                       --""
gamelog.ONE_KEY_TRAIN_SOLIDER = add{ id=23, msg = "on key train solider" }                        --""
gamelog.ONE_KEY_SPEED_FULL_TRAIN_SOLIDER = add{ id=24, msg = "one key speed train solider full" } --""
gamelog.SPEED_TRAIN_SOLIDER = add{ id=25, msg = "speed train solider" }                           --""
gamelog.REPLACE_SOLIDER = add{ id=26, msg = "replace solider" }                                   --""
gamelog.WORLD_CHAT = add{ id=27, msg = "world chat" }                                             --""
gamelog.PVP_PLUNDER = add{ id=28, msg = "pvp plunder" }                                           --pvp""
gamelog.PVP_START_BATTLE = add{ id=29, msg = "pvp start battle" }                                 --""pvp""
gamelog.PVP_DEFEN_SUCC = add{ id=30, msg = "pvp defensive success" }                              --pvp""

gamelog.MODIFY_PLAYER_NAME = add{ id=35, msg = "modify player name" }                             --""
gamelog.ADD_BATTLE_NUM = add{ id=36, msg = "add battle num" }                                     --""
gamelog.FIND_PVP_PLAYERS = add{ id=37, msg = "find pvp players" }                                 --""pvp"" 
gamelog.SCOUT_PVP_PLAYER = add{ id=38, msg = "scout pvp player" }                                 --""pvp""
gamelog.ACT_PVP_RANK = add{ id=39, msg = "pvp rank open activity" }                          --pvp""
gamelog.ACT_STARMAP_UNION = add{ id=40, msg = "starmap union rank open activity" }           --""
gamelog.ACT_STARMAP_FIRST_GET = add{ id=41, msg = "starmap grid first get open activity" }   --""
gamelog.DONATE_DAO_ITEM = add{ id=42, msg = "donate dao item" }                             --""dao""
gamelog.UNION_MATCH_RANK = add{ id=43, msg = "union match rank reward" }                    --""
gamelog.STARMAP_MATCH_UNION_REWARD = add{ id=44, msg = "starmap match union reward" }        --""

gamelog.VIP_PLEDGE = add{ id=50, msg = "vip pledge" }                                             --VIP""
gamelog.BRIDGE_RECHARGE_TOKEN = add{ id=51, msg = "bridge recharge token" }                       --""token
gamelog.BRIDGE_WITHDRAW_TOKEN = add{ id=52, msg = "bridge withdraw token" }                       --""token
gamelog.BRIDGE_WITHDRAW_REJECT = add{ id=53, msg = "bridge withdraw reject" }                     --""
gamelog.BATTLE_REWARD_ON_GRID = add{ id=54, msg = "battle reward on grid"}                        --""
gamelog.LOST_GRID_COST_ITEM_LIFE = add{ id=55, msg="lost grid cost item life"}                    --""
gamelog.PVP_SYS_CARBOXYL = add{ id=56, msg = "pvp system carboxyl reward" }                       --pvp""
gamelog.STARMAP_DRAW_REWARD = add{ id = 57, msg = "star map draw reward" }
gamelog.PVP_MATCH_SETTLEMENT = add{ id=58, msg = "pvp match settlement reward" }                  --pvp""
gamelog.MAIL_ATTACHMENT = add{ id=59, msg = "mail attachment" }                                   --""
gamelog.DAPP_RECHARGE = add{ id=60, msg = "migrate from chain" }                                  --DAPP""
gamelog.TASK_REWARD = add{ id=61, msg = "task reward" }                                           --""
gamelog.UNION_DONATE = add{ id=62, msg = "donate to union" }                                      --""
gamelog.PVE_PASS_REWARD = add{ id=63, msg = "pve pass reward" }                                   --pve""
gamelog.PVE_DAILY_REWARD = add{ id=64, msg = "pve daily reward" }                                 --pve""
gamelog.UNION_NFT_MINT = add{ id=65, msg = "union nft mint" }                                     --nft""
gamelog.MINT_RECEIVE_ITEM = add{ id=66, msg = "receive mint item" }                               --""
gamelog.MAIL_FROM_GMASTER = add{ id=67, msg = "mail from game master" }                           --""
gamelog.SEND_EMAIL_TO_INVITER = add{ id=68, msg = "send email to inviter" }                       --""
gamelog.UNION_SHARE_GRID_HY = add{ id=69, msg = "union share grid Hydroxyl" }                     --""
gamelog.BUILD_CREATE = add{ id=70, msg = "build create" }                                         --""
gamelog.GRID_BUILD_CREATE = add{ id=71, msg = "grid build create" }                               --""
gamelog.BUILD_GM_CREATE = add{ id=72, msg = "build gm create" }                                   --GM""
gamelog.BUILD_LEVEL_UP = add{ id=74, msg = "build level up" }                                     --""
gamelog.SPEED_BUILD_LEVEL_UP = add{ id=77, msg = "speed build level up" }                         --""
gamelog.SOON_BUILD_LEVEL_UP = add{ id=78, msg = "soon build level up" }                           --""

gamelog.HERO_LEVEL_UP = add{ id=80, msg = "hero level up" }                                       --""
gamelog.HERO_PUTON_SKILL = add{ id=81, msg = "hero put on skill" }                                --""
gamelog.SPEED_HERO_LEVEL_UP = add{ id=82, msg = "speed hero level up" }                           --""
gamelog.SOON_HERO_LEVEL_UP = add{ id=83, msg = "soon hero level up" }                             --""
gamelog.HERO_SKILL_LEVEL_UP = add{ id=84, msg = "hero skill level up" }                           --""
gamelog.HERO_RESET_SKILL = add{ id=85, msg = "hero reset skill" }                                 --""
gamelog.SPEED_HERO_SKILL_LEVEL_UP = add{ id=86, msg = "speed hero skill level up" }               --""
gamelog.HERO_FORGET_SKILL = add{ id=87, msg = "hero forget skill" }                               --""
gamelog.SOON_HERO_SKILL_LEVEL_UP = add{ id=88, msg = "soon hero skill level up" }                 --""

gamelog.WARSHIP_LEVEL_UP = add{ id=90, msg = "warship level up" }                                 --""
gamelog.WARSHIP_PUTON_SKILL = add{ id=91, msg = "warship put on skill" }                          --""
gamelog.SPEED_WARSHIP_LEVEL_UP = add{ id=92, msg = "speed warship level up" }                     --""
gamelog.SOON_WARSHIP_LEVEL_UP = add{ id=93, msg = "soon warship level up" }                       --""
gamelog.WARSHIP_SKILL_LEVEL_UP = add{ id=94, msg = "warship skill level up" }                     --""
gamelog.WARSHIP_RESET_SKILL = add{ id=95, msg = "warship reset skill" }                           --""
gamelog.SPEED_WARSHIP_SKILL_LEVEL_UP = add{ id=96, msg = "speed warship skill level up" }         --""
gamelog.WARSHIP_FORGET_SKILL = add{ id=97, msg = "warship forget skill" }                         --""
gamelog.SOON_WARSHIP_SKILL_LEVEL_UP = add{ id=98, msg = "soon warship skill level up" }           --""

gamelog.REPAIR_BUILD_LIFE = add{ id=100, msg = "repair build life" }                              --""
gamelog.REPAIR_HERO_LIFE = add{ id=102, msg = "repair hero life" }                                --""
gamelog.REPAIR_WARSHIP_LIFE = add{ id=104, msg = "repair warship life" }                          --""

gamelog.SOLIDER_LEVEL_UP = add{ id=110, msg = "solider level up" }                                 --""
gamelog.SPEED_SOLIDER_LEVEL_UP = add{ id=112, msg = "speed solider level up" }                     --""
gamelog.SOON_SOLDIER_LEVEL_UP = add{ id=115, msg = "soon soldier level up" }                       --""

gamelog.ITEM_USE = add{ id=120, msg = "item use" }                                                 --""
gamelog.ITEM_RESOLVE = add{ id=122, msg = "item resolve" }                                         --""

gamelog.BRIDGE_RECHARGE_NFT = add{ id=130, msg = "bridge recharge nft" }                 --""nft
gamelog.BRIDGE_WITHDRAW_NFT = add{ id=132, msg = "bridge withdraw nft" }                 --""nft

gamelog.DRAW_CARD = add{ id=140, msg = "draw card" }                                 --""

gamelog.ORDER_PAY_LOCAL = add{ id=150, msg = "order pay local" }                     --"" local
gamelog.ORDER_PAY_XSOLLA = add{ id=152, msg = "order pay xsolla" }                   --"" xsolla
gamelog.ORDER_PAY_INTERNATION = add{ id=153, msg = "order pay internation" }         --"" internation
gamelog.ORDER_PAY_APPSTORE = add{ id=155, msg = "order pay appstore" }               --"" appstore
gamelog.ORDER_PAY_GOOGLEPLAY = add{ id=160, msg = "order pay googleplay" }           --"" googleplay

gamelog.INVITEE_PURCHASE_RATE = add{ id=166, msg = "invitee purchase rate" }         --""

gamelog.TRAIN_GUILD_RESERVE_ARMY = add{ id=167, msg = "train guild reserve army" }         --""

gamelog.FIREST_RECHARGE_REWARD = add{ id=168, msg = "first recharge reward" }                                 --""

gamelog.CUMULATIVE_FUNDS = add{ id=169, msg = "cumulative funds reward" }                                 --""
gamelog.BUY_BUILD_QUEUE = add{ id=170, msg = "buy build queue" }                             -- ""
gamelog.MOON_CARD_REWARD = add{ id=171, msg = "moon card reward" }                          -- ""
gamelog.BUY_GIFT_BAG_REWARD = add{ id=172, msg = "buy gift bag " }                          -- ""
gamelog.REPEAT_RECHARGE_CPS = add{ id=173, msg = "repeated recharge compensation" }         -- ""
gamelog.RECHARGE = add{ id=174, msg = "recharge" }                                          -- ""
gamelog.DAILY_CHECK = add{ id=175, msg = "daily check" }                                          -- ""

gamelog.GIFT_CODE_EXCHANGE = add{ id=176, msg = "gift code exchange" }                 --""

gamelog.RECHARGE_REWARD = add{ id=177, msg = "recharge reward" }                                 --""
gamelog.FRESH_SHOPPINGMALL = add{ id=178, msg = "fresh shoppingMall" }                           --""
gamelog.DISMANTLING_HERO = add{ id=179, msg = "dismantling hero" }                           --""
gamelog.LOGIN_ACT = add{ id=180, msg = "login activity" }                           --""

gamelog.STAR_PACK_REWARD = add{ id=181, msg = "star pack reward" }                           --""
gamelog.LEVEL_PACK_REWARD = add{ id=182, msg = "level pack reward" }                           --""
gamelog.UNLOCK_LOGIN_ACT_ADV = add{ id=183, msg = "unlock login activity advanced reward" }                           --""

gamelog.SELL_HERO = add{ id=184, msg = "sell hero" }                                               --""
gamelog.SELL_BUILD = add{ id=185, msg = "sell build" }                                               --""
gamelog.SELL_WARSHIP = add{ id=186, msg = "sell warShip" }                                               --""
gamelog.DISMANTLING_WARSHIP = add{ id=187, msg = "dismantling warShip" }                           --""
gamelog.SELL_ITEM = add{ id=188, msg = "sell item" }                                               --""