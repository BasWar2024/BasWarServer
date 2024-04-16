errors = errors or {}
errmsg = errmsg or {}

local function add(err)
    assert(errors[err.id] == nil, "repeat error id="..err.id)
    errmsg[err.id] = err.msg
    return err
end
--------------------------------------------------------------------
--common 00
errors.ARG_ERR =                       add{id = 1, msg = "Argument error"}                                               --""
errors.LEVELINGUP =                    add{id = 2, msg = "Upgrading"}                                                    --""
errors.LEVEL_MAX =                     add{id = 3, msg = "Highest level has reached"}                                    --""
errors.CUR_LEVEL_CONFIG_NIL =          add{id = 4, msg = "Current level is not configured"}                              --""
errors.SPEEDUP_ERR =                   add{id = 5, msg = "Not upgrading. Instant complete is unavailable."}              --""
errors.CFG_NOT_EXIST =                 add{id = 6, msg = "Data is not configured"}                                       --""
errors.SERVER_INTERNAL_ERR =           add{id = 7, msg = "server internal execute err: {0}"}
errors.NFT_NOT_EXIST =                 add{id = 8, msg = "NFT is not exist"}
errors.NFT_GET_NOT_CD =                add{id = 9, msg = "NFT is not cd now"}
errors.INVALID_UTF8 =                  add{id = 10, msg = "Invalid UTF8 text"}
errors.NOT_GM =                        add{id = 11, msg = "not GM"}
errors.NFT_NOT_AVAILABLE =             add{id = 12, msg = "nft not available"}
errors.SYSTEM_BUSY =                   add{id = 17, msg = "system busy"}                                                  -- ""
errors.HQ_NO_SPACE =                   add{id = 18, msg = "HQ has no extra space"}                                        -- ""
--------------------------------------------------------------------
--nft 01
errors.NFT_LEVEL_NOT_ENOUGH =                   add{id = 101, msg = "NFT level is not enough."}              --nft""
errors.NFT_CANNOT_DISMANTLING = add{id=102, msg="nft cannot be dismantling"}                                             --nft""
errors.NFT_CANNOT_SELL = add{id=102, msg="nft cannot be sell"}                                                           --nft""
--------------------------------------------------------------------
--achievement 02
errors.ACHIEVEMENT_DRAWED =            add{id=201, msg = "Reward has been claimed"}                                            --""
errors.ACHIEVEMENT_NOT_FINISH =        add{id=202, msg = "Achievement is not completed"}                                       --""
errors.ACHIEVEMENT_NOT_FOUND =         add{id=203, msg = "This achievement is not found"}                                      --""

--------------------------------------------------------------------
--build 03
errors.BASE_BUILD_LV_LOW =              add{id=301, msg="Main Base Level is not enough. Upgrade to send!"}                    --""

errors.BASE_BUILD_REPEAT =              add{id=303, msg="Main Base already exists"}                                           --""
errors.BUILD_COUNT_LIMIT =              add{id=304, msg="Number built has reached to its limit"}                              --""
errors.BUILD_CREATE_ERR =               add{id=305, msg="Fail to build this facility"}                                        --""
errors.BUILD_NOT_EXIST =                add{id=306, msg="This facility does not exist" }                                      --""
errors.BUILD_TYPE_ERR =                 add{id=307, msg="This is not Stone"}                                                  --""("")

errors.BUILD_TRAINNING_SOLIDERS =       add{id=309, msg="Training in progress"}                                               --""

errors.POS_ERR =                        add{id=311, msg="Cannot be placed here"}                                              --""
errors.WORK_QUE_FULL =                  add{id=312, msg="All builders are busy"}                                              --""
errors.RESEARCH_WORK_QUEUE_FULL =       add{id=313, msg="Researching queue is full"}                                          --""
errors.BUILD_LEVEL_NOT_ENOUGH =         add{id=314, msg="You need to upgrade {0} to Level {1}"}                               --""
errors.BUILD_POS_EXCHANGE_ERR =         add{id=315, msg="Position of the Liberator Warship cannot be changed"}                --""

errors.POS_OUT_OF_BOUNDS =              add{id=317, msg="pos is out of bunds"}                                                --""
errors.BUILD_CANT_MOVE =                add{id=318, msg="build can't move"}                                                   --""

errors.BUILD_REQUIRE_LEVEL_AND_COUNT =  add{id=320, msg="You need {0} level {1}"}                                             --""xxx""xx""
errors.BUILD_REF_BUSY =                 add{id=321, msg="build is reference by other place. "}                                --""，""
errors.BUILD_IS_NOT_NFT =               add{id=322, msg="build is not nft"}                                                   --""nft
errors.BUILD_CANNOT_DELETE =            add{id=323, msg="build cannot delete"}                                                --""
errors.BUILD_DEGREE_NOT_ENOUGH =        add{id=324, msg="build degree not enough"}                                            --""
errors.BUILD_BASE_CANNOT_DELETE =       add{id=325, msg="build base cannot delete"}                                           --""
errors.BUILD_LEVEL_OR_SKILL_UP =        add{id=326, msg="build level or skill upgrade in progress"}                           --""
errors.BUILD_FRESH_SUCCESS =        add{id=327, msg="fresh success"}                           --""nft build""
errors.BUILD_FREQUENT_REFRESH =        add{id=328, msg="frequent refresh, please try again later"}                           --""，""
errors.BUILD_SOLIDERS_UPGRADING =       add{id=329, msg="soldier upgrading"}                                               --""
errors.BUILD_BUILD_UPGRADING =          add{id=330, msg="build upgrading"}                                               --""
--------------------------------------------------------------------
--solider 04


errors.SOLIDER_NOT_EXIST =             add{id=403, msg="This type of troops does not exist"}                                  --""
errors.SOLIDER_NOT_UNLOCK =            add{id=404, msg="Research to unlock"}                                                  --""

errors.TRAIN_SPACE_NOT_ENOUGH =        add{id=406, msg="Not enough training spaces"}                                          --""


errors.SOLIDER_LEVEL_NOT_ENOUGH =      add{id=409, msg="Level of this troop is too low"}                                      --""
errors.SOLIDER_COUNT_NOT_LEGAL =       add{id=410, msg="Illegal number of soldiers"}                                          --""

--------------------------------------------------------------------
--battle 05
errors.BATTLE_DATA_ERR =              add{id=501, msg="Battle data error"}                                                    --""
errors.BATTLE_BAN =                   add{id=502, msg="You are temporarily banned from battling"}                             --""
errors.BATTLE_TYPE_ERR =              add{id=503, msg="Battle type error"}                                                    --""(""PVP"")


errors.BATTLE_NOT_FINISH =            add{id=506, msg="Battle is incomplete"}                                                 --""
errors.BATTLE_DATA_TIMEOUT =          add{id=507, msg="Battle log has expired"}                                               --""


errors.BATTLE_NUM_NOT_ENOUGH =        add{id=510, msg="No remaining attack left"}                                             --""
errors.BATTLE_NUM_FULL =              add{id=511, msg="Maximum number of remaining attacks"}                                  --""

errors.EMEMY_ERR =                    add{id=513, msg="Opponent data error"}                                                  --""
errors.EMEMY_BUILDS_EMPTY =           add{id=514, msg="This Enemy Builds does not exist"}                                     --""
errors.EMEMY_NO_PLAYER =              add{id=515, msg="This Enemy does not exist"}                                            --""
errors.EMEMY_NOT_PVP =                add{id=516, msg="This opponent is not in the PVP list"}                                 --""pvp""
errors.ARMY_NO_WARSHIP =              add{id=517, msg="You do not have a Warship"}                                            --""
errors.ARMY_NO_SOLIDER =              add{id=518, msg="No troops in your army. Please train your troops before attacking."}   --""
errors.BATTLE_IN_FIGHTING =           add{id=519, msg="Currently in a battle"}                                                --""
errors.BATTLE_NUM_BOUGHT_WRONG =      add{id=520, msg="The battleNum you bought is wrong"}                                    --"" 
errors.BATTLE_NOT_EXIST =             add{id=521, msg="This Battle not exist"}                                                --""
errors.BATTLE_PVP_COST_NOT_FOUND =    add{id=522, msg="This level of pvp cost cfg not exist"}                                 --""PVP""
errors.BATTLE_ENEMY_BASE_BUSY =       add{id=523, msg="This Enemy base is attacked or in protect"}                            --""
errors.BATTLE_NUM_BOUGHT_LIMIT =      add{id=524, msg="You can only buy {0} attacks per day,please come back tomorrow"}       --""


errors.CAMPAIGN_BATTLE_CANCEL =       add{id=527, msg="Campaign battle is cancel"}                                            --""
errors.CAMPAIGN_ARMY_EMPTY =          add{id=528, msg="ArmyInfos is empty"}                                                   --""
errors.CAMPAIGN_ARMY_REPEAT =         add{id=529, msg="The warShip or hero is repeat"}                                        --""
errors.BATTLE_SOLIDER_NOT_ENOUGH =    add{id=530, msg="The solider not enough"}                                               --""
errors.BATTLE_BASE_LEVEL_NOT_ENOUGH = add{id=531, msg="You need to upgrade base to Level {1}"}                               --""
errors.ARMY_NO_HERO =                 add{id=532, msg="You do not have a hero"}


errors.CAMPAIGN_LANDSHIP_REPEAT =     add{id=535, msg="Soldier s of landing ships can only use it once"}                    --""
errors.CAMPAIGN_TIMEOUT =             add{id=536, msg="starmap campaign is timeout"}                                        --""
errors.HERO_IN_BATTLE_CD =            add{id=537, msg="Hero in battle CD"}                                                  --""cd""

--------------------------------------------------------------------
--chat 06
errors.CHAT_CHAN_TYPE_ERR =          add{id=601, msg="Invalid channel type"}                                                 --""
errors.CHAT_TEXT_NULL =              add{id=602, msg="Your content is empty"}                                                --""
errors.POLITE_LANGUAGE =             add{id=603, msg="Please use words politely!"}                                           --""
errors.CHAT_BAN_TALK =               add{id=604, msg="You are ban talk"}
errors.CHAT_CD =                     add{id=605, msg="chat cd"}                                                              --""

--------------------------------------------------------------------
--union 07
errors.UNION_BUILD_BELONG_ERR =        add{id=701, msg="The building cannot be built on the starmap plot"}
errors.UNION_FORBID =                  add{id=707, msg="Join by invitation only"}                                                              --""
errors.UNION_MEMBER_LIMIT =            add{id=708, msg="Number of Dao members has reached to its maximum"}                                     --""
errors.UNION_NOT_EXIST =               add{id=709, msg="This DAO does not exist"}                                                              --""
errors.UNION_NAME_ERR =                add{id=710, msg="Invalid DAO Name"}                                                                     --""
errors.UNION_NAME_REPEAT =             add{id=711, msg="This DAO name is unavailable"}                                                         --""
errors.UNION_SCORE_NOT_ENOUGH =        add{id=712, msg="Minimum number of badges required cannot be negative"}                                 --""

errors.UNION_JOINED =                  add{id=714, msg="Player joined a DAO"}                                                                  --""

errors.UNION_REPEAT_JOIN =             add{id=720, msg="You've already joined a DAO"}                                                          --""
errors.UNION_NOT_JOIN =                add{id=721, msg="You haven't joined any DAOs"}                                                          --""

errors.UNION_TRANSFER_FIRST =          add{id=723, msg="Before you quit, you should transfer your title"}                                 --""
errors.UNION_KICK_SELF =               add{id=724, msg="You cannot remove yourself out"}                                                       --""

errors.UNION_EDIT_SELF_JOB =           add{id=726, msg="You cannot transfer or assign title to yourself"}                                      --""
errors.UNION_ENTER_SCORE_ERR =         add{id=727, msg="Invalid enter score"}                                                                  --""
errors.UNION_NO_AUTHORITY =            add{id=728, msg="No authority for this action"}                                                         --""
errors.UNION_INVALID_NOTICE =          add{id=729, msg="Invalid Dao notice"}                                                                   --""
errors.UNION_SOLIDER_COST_ERR =        add{id=730, msg="Error in deducting the number of reservists"}                                                             --""
errors.UNION_NOT_MEMBER =              add{id=731, msg="You are not this union Member"}                                                        --""
errors.UNION_JOIN_APPLY_INVALID =      add{id=732, msg="Dao join apply invalid"}                                                               --""
errors.UNION_INVITE_INVALID =          add{id=733, msg="Dao invite invalid"}                                                                   --""
errors.UNION_NO_THIS_MEMBER =          add{id=734, msg="Dao have not this member"}                                                             --""
errors.UNION_INVALID_FLAG =            add{id=735, msg="Invalid dao flag setting"}                                                             --""
errors.UNION_INVALID_SHARING =         add{id=736, msg="Invalid dao res sharing setting"}                                                      --""
errors.UNION_SOLIDER_NOT_UNLOCK =      add{id=737, msg="Union solider not unlock"}                                                             --""
errors.UNION_SOLIDER_NUM_LIMIT  =      add{id=738, msg="Union solider train limit"}                                                            --""
errors.UNION_TECH_NOT_UNLOCK =         add{id=739, msg="Union tech not unlock"}                                                                --""
errors.UNION_PRESET_TECH_LEVEL_LIMIT = add{id=740, msg="Union preset techs level limit"}                                                       --""
errors.UNION_TECH_LEVEL_LIMIT =        add{id=741, msg="Union tech level limit"}                                                               --""
errors.UNION_DEFENSE_NOT_UNLOCK =      add{id=742, msg="Union defense build not unlock"}                                                       --""
errors.UNION_DEFENSE_NUM_LIMIT  =      add{id=743, msg="Union defense build limit"}                                                            --""
errors.UNION_SOLIDER_NOT_ENOUGH =      add{id=744, msg="Union solider not enough"}                                                             --""
errors.UNION_NFT_HERO_REPEAT =         add{id=745, msg="Union nft hero repeat"}                                                                --""NFT""
errors.UNION_NFT_NOT_AVALIABLE =       add{id=746, msg="Union nft not exist or not avaliable"}                                                 --""NFT""
errors.UNION_OTHER_PLAYER_EDIT_ARMY =  add{id=747, msg="Union other player is edit army team"}                                                 --""
errors.UNION_YOU_NOT_LOCK_EDIT_ARMY =  add{id=748, msg="Union you have not locker for edit arym"}                                              --""
errors.UNION_EDIT_ARMY_IS_LOCKED =     add{id=749, msg="Union edit army is locked"}                                                            --""
errors.UNION_OTHER_LOCK_EDIT_ARMY =    add{id=750, msg="Union other lock edit army"}                                                           --""
errors.UNION_INVALID_ENTERTYPE =       add{id=751, msg="Invalid enterType setting"}                                                            --""
errors.UNION_TRANSFER_INVALID =        add{id=752, msg="You should transfer your title to Vice President only"}                                --""
errors.UNION_HAS_APPLY =               add{id=753, msg="Apply Success,Please Wait"}
errors.UNION_HAS_INVITE =              add{id=754, msg="INVITE Success,Please Wait"}                                                           --"",""
errors.UNION_SOLIDER_BATTLE_NUM  =     add{id=755, msg="Union battle soldier count more than limit"}                                           --""
errors.UNION_BATTLE_NUM_LESS  =        add{id=756, msg="Union army count is too less"}
errors.UNION_MAX_TITLE  =              add{id=757, msg="Union max title"}
errors.UNION_TECH_MAX_COUNT =          add{id=758, msg="Union tech max count"}
errors.UNION_REJOIN_CD =               add{id=759, msg="Union Rejoin cd"}                                                                      --""
errors.UNION_NORMAL_NOT_AVALIABLE =    add{id=760, msg="Union normal defanse build not exist or not avaliable"}
errors.UNION_MINT_NOT_EXIST =          add{id=761, msg="Mint  not exist "}
errors.UNION_MINT_REPEAT =             add{id=762, msg="NFT already used for mint cannot be reused "}
errors.UNION_MINT_SCORE_NOT_ENOUGH =   add{id=763, msg="DAO plots do not have enough scores for mint"}
errors.UNION_MINT_COUNT_LIMIT =        add{id=764, msg="Mint count is limit"}
errors.UNION_MINT_NOT_DONE =           add{id=765, msg="Mint is not finish"}
errors.UNION_LEVEL_MAX =               add{id=766, msg="Union level is max"}
errors.UNION_TECH_MOD_MAX =            add{id=767, msg="Similar technologies are already being upgraded"}                                      -- ""
--------------------------------------------------------------------
--hero 08
errors.HERO_NOT_EXIST =           add{id=801, msg="This hero does not exist"}                                                             --""

errors.SKILL_NOT_EXIST =          add{id=805, msg="You do not have this skill"}                                                           --""
errors.SKILL_SAME =               add{id=806, msg="Same skill selected"}                                                                  --""
errors.SKILL_LEVEL_MAX =          add{id=807, msg="skill level is max"}                                                                   --""
errors.SKILL_CONFIG_NOT_EXIST =   add{id=808, msg="skill data not config"}                                                                --""
errors.SKILL_LEVEL_HERO_LIMIT =   add{id=809, msg="skill level should limit by hero level"}                                               --""

errors.HERO_USING =               add{id=811, msg="Hero is using!"}                                                                       --""
errors.HERO_REF_BUSY =            add{id=812, msg="Hero is reference by other place. "}                                                   --""
errors.HERO_NOT_LIFE =            add{id=813, msg="Hero durability not enough"}                                                           --""
errors.HERO_NOT_FORGET_SKILL =    add{id=814, msg="need to forget all skills"}            --""
errors.HERO_LEVEL_OR_SKILL_UP =   add{id=815, msg="hero level or skill upgrade in progress"}                                                  --""
errors.NFT__CANNOT_DISMANTLING =   add{id=816, msg="nft hero cannot be dismantling"}                                                  --nft""
errors.HERO_NFT_CANNOT_SELL = add{id=926, msg="nft warship cannot be sell"}                                                           --nft""
--------------------------------------------------------------------
--warship 09 
errors.WARSHIP_NOT_EXIST =        add{id=911, msg="This Warship does not exist"}                                                         --""

errors.WARSHIP_REF_BUSY =         add{id=921, msg="Warship is reference by other place. "}                                               --""，""
errors.WARSHIP_BIG_SKILLLV =      add{id=922, msg="Warship skill level bigger than level. "}                                             --""
errors.WARSHIP_NOT_LIFE =         add{id=923, msg="Warship durability not enough"}                                                       --""
errors.WARSHIP_LEVEL_OR_SKILL_UP= add{id=924, msg="Warship level or skill upgrade in progress"}                                          --""
errors.WARSHIP_IN_USE = add{id=925, msg="Warship in use"}                                                                                --""
errors.WARSHIP_NOT_FORGET_SKILL =    add{id=926, msg="need to forget all skills"}                                                        --""
errors.WARSHIP_LEVEL_OR_SKILL_UP =   add{id=927, msg="warship level or skill upgrade in progress"}                                                  --""
--------------------------------------------------------------------
--itembag 10
errors.ITEM_DAO_EFFECT_ERR =      add{id=1001, msg="DAO artifact prop effect out of error"}                                                          --dao""
errors.ITEM_NOT_EXIST =           add{id=1003, msg="This item does not exist"}                                                           --""

errors.ITEM_CANNOT_USE =          add{id=1010, msg="cannot use"}                                                                         --""
errors.ITEM_COUNT_LESS =          add{id=1011, msg="Quantity is not enough"}                                                             --""
errors.ITEM_CANNOT_RESOLVE =      add{id=1012, msg="Props cannot be resolve"}                                                            --""                         
errors.ITEM_CFG_NOT_EXIST =       add{id=1013, msg="Item cfg not exist"}                                                                 --""                         
errors.ITEM_NOT_ENOUGH =          add{id=1014, msg="Item count not enough"}                                                              --""
errors.ITEM_NOT_DAO =             add{id=1015, msg="Item is not DAO artifact"}                                                          --""
errors.ITEM_NOT_BASE_LEVEL =      add{id=1016, msg="Insufficient base level"}                                                          --""
errors.ITEM_ONLY_USE_ONCE =       add{id=1017, msg="Unique item, not reusable"}                                                   --""，""
--------------------------------------------------------------------
--xxxx 11


--------------------------------------------------------------------
--repair 12

errors.REPAIR_NOT_NEED =          add{id=1205, msg="This entity not need repair"}                                                        --""


--------------------------------------------------------------------
--playerinfo 13
errors.NAME_MODIFY_ERR =          add{id=1301, msg="Fail to edit Name"}                                                            --""
errors.NOT_ALLOW_INVITE =         add{id=1302, msg="Player sets restriction: Not allow to invite"}                                        --""
errors.NOT_ALLOW_VISIT =          add{id=1303, msg="Player sets restriction: Not allow to visit"}                                         --""
errors.PLAYER_NOT_EXIST =         add{id=1304, msg="This player does not exist"}                                                          --""
errors.NAME_MODIFY_LOCK =         add{id=1305, msg="Wait {0} to modify name"}                                                   --""                              

--------------------------------------------------------------------
--res 14
errors.STARCOIN_NOT_ENOUGH =      add{id=1402, msg="Not enough Star Coins"}                                                               --""
errors.RES_EXCHANGE_ERR =         add{id=1404, msg="resource can not exchange"}                                                           --""
errors.RES_NOT_ENOUGH =           add{id=1405, msg="{0} is not enough"}                                                                   --""
errors.EXCHANGE_SUCCESS =         add{id=1406, msg="Exchange successful !"}                                                               --""
errors.NOT_ADD_RES_NUM =          add{id=1407, msg="No resource quantity added!"}                                                         --""

--------------------------------------------------------------------
--task 15
errors.TASK_NO_DRAWED =           add{id=1501, msg="This reward has been claimed"}      --""
errors.TASK_NOT_FINISH =          add{id=1502, msg="Task is not completed"}             --""
errors.TASK_NOT_EXIST =           add{id=1503, msg="Task is not exist"}                 --""
errors.TASK_CHAPTER_NOT_DONE =    add{id=1504, msg="Chapter main task is not completed or receive"}   --""
errors.TASK_ACTIVATION_NOT_EXIST =add{id=1505, msg="Task activation is not exist"}                 --""
errors.TASK_ACTIVATION_NOT_ENOUGH =add{id=1506, msg="Task activation is not enough"}             --""

--------------------------------------------------------------------
--mail 16
errors.MAIL_NOT_EXIST =           add{id=1601, msg="Mail not exist" }  
errors.MAIL_ATTACH_REPEAT_GET =   add{id=1602, msg="Mail attachment repeat get" }  
errors.MAIL_ATTACH_NOT_EXIST =    add{id=1603, msg="Mail attachment not exist" }  
errors.MAIL_ATTACH_NOT_RECEIVED =    add{id=1604, msg="Mail attachment not received" }  
--------------------------------------------------------------------
--xxx 17

--------------------------------------------------------------------
--guide 18
errors.GUIDE_NOT_EXIST =                add{id=1801, msg="GuideIds not exist" }
errors.GUIDE_ID_NOT_EXIST =             add{id=1802, msg="GuideId not exist" }

--------------------------------------------------------------------
--bridge 19
errors.BRIDGE_CHAIN_ID_NOT_EXIST =     add{id=1906, msg="chain id not exist"}
errors.BRIDGE_TOKEN_NOT_EXIST =        add{id=1907, msg="token not exist"}
errors.BRIDGE_NO_BIND_WALLET =         add{id=1908, msg="no bind wallet"}
errors.BRIDGE_WARSHIP_LAUNCH_BUSY =    add{id=1909, msg="warship launch busy"}
errors.BRIDGE_ITEM_NOT_EXIST =         add{id=1910, msg="item not exist"}
errors.BRIDGE_LAUNCH_HYT_LESS_FEE =    add{id=1911, msg="launch bridge need hyt more than fee"}
errors.BRIDGE_ADDNFT_SUCCESS =         add{id=1912, msg="add success, token_id {0}"}
errors.BRIDGE_ENTITY_BUSY =            add{id=1913, msg="entity busy"}
errors.BRIDGE_NOT_NFT =                add{id=1914, msg="not nft"}
errors.BRIDGE_NEED_MAX_LIFE =          add{id=1915, msg="Need full durability"}
errors.BRIDGE_CHAIN_PAUSE_USE =        add{id=1916, msg="Chain bridge pause use"}
errors.BRIDGE_CHAIN_BAN_TRANSPORT =    add{id=1918, msg="Ban Transport"}
errors.BRIDGE_CHAIN_COOLING =          add{id=1919, msg="In Cooling,Left {0}"}
errors.BRIDGE_OWN_NFT_WARSHIP =        add{id=1920, msg="must own nft ship"}
errors.BRIDGE_MUST_IN_SAME_CHAIN =     add{id=1921, msg="must in same chain"}
errors.BRIDGE_LEVEL_OR_SKILL_UP =      add{id=1922, msg="entity level or skill upgrade in progress"}                           --nft""
errors.BRIDGE_HYT_MIN =                add{id=1925, msg="hydroxyl min {0}"}
errors.BRIDGE_MIT_MIN =                add{id=1926, msg="mit min {0}"}
--------------------------------------------------------------------
--starmap 20
errors.GRID_NFT_BUILD_CAN_USE =        add{id=2001, msg="only nft build can put on starmap"}
errors.GRID_OWNER_NOT_YOU =            add{id=2002, msg="this grid owner not you"}
errors.GRID_STATUS_BATTLE =            add{id=2003, msg="grid is battle status"}
errors.GRID_NOT_JOIN_UNION =           add{id=2004, msg="you must join a union to do this operate"}
errors.GRID_PLY_BUILD_LIMIT =          add{id=2005, msg="player build count is max"}
errors.GRID_BATTLE_REQUIRE_UNION =     add{id=2006, msg="you need join a union to attack starmap"}
errors.GRID_STATUS_PROTECT =           add{id=2007, msg="grid is protect status"}
errors.GRID_BATTLE_SELF =              add{id=2008, msg="you can not battle with youself"}
errors.GRID_PROTECTED =                add{id=2009, msg="starmap grid is be protected"}
errors.GRID_BATTLE_BEGIN_GRID =        add{id=2010, msg="you can not battle in begin grid"}
errors.GRID_NEAR_NOT_BELONG =          add{id=2011, msg="The near grid is not belong to your union"}
errors.GRID_MATCH_RANK_ERROR =         add{id=2012, msg="The match type is error"}
errors.GRID_MATCH_RANK_EMPTY =         add{id=2013, msg="The match rank list is empty"}
errors.GRID_MATCH_NOT_START =          add{id=2014, msg="The match hasn't started yet"}
errors.GRID_NOT_HAS_BEGIN_GRID =       add{id=2015, msg="your union has not begin grid"}
errors.GRID_INIT_ERROR =               add{id=2016, msg="starmap grid init error"}
errors.GRID_NUM_LIMIT =                add{id=2017, msg="starmap the number of plots reaches the limit"}
errors.GRID_BELONG_TYPE_SELF =         add{id=2018, msg="The grid only can battle with youself soldier"}
errors.GRID_COLLECT_TAG_OVER =         add{id=2019, msg="The grid collect tag is too long"}
errors.GRID_COLLECT_OVER_LIMIT =       add{id=2020, msg="The grid collect quantity is reach limit"}
errors.GRID_NOT_EXIST =                add{id=2021, msg="grid cfg is not exist"}
errors.GRID_NOT_BEGIN_GRID =           add{id=2022, msg="The grid is not begin grid"}
errors.GRID_TRANSFER_BEGIN_CD =        add{id=2023, msg="You have already moved the initial plot and you need to wait {0} h {1} min before you can move it again."}
errors.GRID_BATTLE_SUB_GRID =          add{id=2024, msg="you can not battle in children grid"}
errors.GRID_IN_NUCLEAR_FUSION =        add{id=2025, msg="Star In Nuclear Fusion"}                          --""
errors.GRID_BATTLE_REQUIRE_CHAINID =   add{id=2026, msg="You need a chain id to attack starmap"}           --""
errors.GRID_MY_CHAINID_DIFF_UNION =    add{id=2027, msg="Your chain id is different with union"}           --""
errors.GRID_UNION_CHAINID_DIFF =       add{id=2028, msg="Your union chain id is different with grid"}      --""
errors.GRID_CAN_NOT_GIVE_UP =          add{id=2029, msg="{0} seconds to give up"}      --""xx""
errors.GRID_IS_EXCLUSIVE_STAR =        add{id=2031, msg="is exclusive star"}           --""
errors.GRID_MUST_PUT_EXCLUSIVE_DEFENSE =        add{id=2033, msg="must put exclusive defense"}           --""
errors.GRID_TO_GRID_BUILD_TYPE_ERR =            add{id=2034, msg="the build must from personal bag or union bag"} --""
--------------------------------------------------------------------
--xxx 21


--------------------------------------------------------------------
--pve 22
errors.PVE_CANT_ATTACK =               add{id=2204, msg="This level can not challenge now"}

--------------------------------------------------------------------
--xxxx 23

--------------------------------------------------------------------
--skill 24
errors.SKILL_CANT_PUTON =        add{id=2401, msg="Skills cannot be put on repeatedly"}
errors.SKILL_EQUIP_TYPE_ERR =    add{id=2402, msg="skill equip type error"}
errors.SKILL_UNIT_ERR =          add{id=2403, msg="skill use unit error"}
errors.SKILL_CANT_RESET =        add{id=2404, msg="skill can not reset"}
errors.SKILL_CANT_FORGET =       add{id=2405, msg="skill can not forget"}

--------------------------------------------------------------------
--draw card 25
errors.DRAW_NOT_EXIST =          add{id=2501, msg="card pool not exist"}

--------------------------------------------------------------------
--Aarmy formation 26
errors.ARMY_FORMATION_TEAM_NOT_SPACE =      add{id=2601, msg="army formation team not space"}
errors.ARMY_FORMATION_NOT_EXIST =        	add{id=2602, msg="army formation not exit"}
errors.RESERVE_ARMY_NOT_ENOUGH =    		add{id=2603, msg="army fofrmation not enough"}
errors.ARMY_FORMATION_NAME_IS_ILLEGAL =     add{id=2604, msg="army formation name is illegal"}
errors.ARMY_FORMATION_MUST_HAVA_HERO =      add{id=2605, msg="The formation must have a hero"}
errors.ARMY_GUILD_SOLDIER_NOT_ENOUGH =      add{id=2606, msg="Not enough reservists for DAO battles"}

--------------------------------------------------------------------
--sanctuary formation 27
errors.SANCTUARY_NO_SPACE =                 add{id=2701, msg="There is no space in the sanctuary"}
errors.SANCTUARY_HERO_USING =               add{id=2702, msg="Hero is using!"}
errors.SANCTUARY_HERO_NOT_EXIST =           add{id=2703, msg="Hero is not exist!"}

--------------------------------------------------------------------
--rechargeActivity 28
errors.RECHARGEACTIVITY_NOT_EXIT =             add{id=2704, msg="The activity does not exist or expired!"}
errors.FUNDS_AWARD_IS_GET =                    add{id=2705, msg="The fund award has been obtained!"}
errors.RECHARGE_NOT_ENOUGH =                   add{id=2706, msg="Recharge amount is not up to standard!"}
errors.NUM_FRESH_LIMIT =                       add{id=2707, msg="Refresh limit reached!"}       -- ""
errors.NOT_GOODS =                             add{id=2708, msg="not goods"}       -- ""
errors.REPEAT_UNLOCK =                         add{id=2709, msg="Repeat unlocking"}       -- ""
errors.REWARD_AlREADY_ISSUED =               add{id=2710, msg="Rewards have been issued"}       -- ""

--gift code 29
errors.GIFT_CODE_ERROR =                       add{id=2902, msg="gift code error"}        --""
errors.GIFT_CODE_NOT_IN_TIME =                 add{id=2903, msg="Redeem code is not valid for the time"}  --""
errors.GIFT_CODE_NOT_EXIST =                   add{id=2904, msg="gift code not exist"}    --""
errors.GIFT_CODE_ALREADY_USE =                 add{id=2905, msg="gift code already use"}  --""
errors.GIFT_CODE_MAX_COUNT =                   add{id=2906, msg="Redeem code reached the maximum"}    --""