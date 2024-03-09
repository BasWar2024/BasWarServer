

common.proto"|
MessagePackage
cmd (Rcmd
args (Rargs
response (Rresponse
session (Rsession
ud (Rud"
	BriefType
uuid (Ruuid
pid (Rpid
account (	Raccount
name (	Rname
level (Rlevel
vip (Rvip
sceneId (RsceneId
mapId (RmapId
mapLine	 (RmapLine 
onlineState
 (RonlineState&
disconnectTime (RdisconnectTime

logoutTime (R
logoutTimebproto3

login.protocommon.proto"

DeviceType,
registerLoginType (RregisterLoginType

deviceCode (	R
deviceCode
network (	Rnetwork
wifiName (	RwifiName

deviceType (R
deviceType 
deviceModel (	RdeviceModel
os (	Ros
	channelId (R	channelId
lang	 (	Rlang"
CheckTokenType
token (	Rtoken
account (	Raccount
version (	Rversion
forward (	Rforward#
device (2.DeviceTypeRdevice"
C2S_CreateRole/

checktoken (2.CheckTokenTypeR
checktoken
account (	Raccount
name (	Rname
heroId (RheroId"X
C2S_EnterGame/

checktoken (2.CheckTokenTypeR
checktoken
roleid (Rroleid"
C2S_ExitGame"#
C2S_CheckName
name (	Rname"
C2S_Ping
str (	Rstr"
RoleType
roleid (Rroleid
name (	Rname
heroId (RheroId
level (Rlevel&
createServerId (	RcreateServerId(
currentServerId (	RcurrentServerId

createTime (R
createTime
account (	Raccount"Z
S2C_CreateRoleFail
status (Rstatus
code (Rcode
message (	Rmessage"6
S2C_CreateRoleSuccess
role (2	.RoleTypeRrole"Y
S2C_EnterGameFail
status (Rstatus
code (Rcode
message (	Rmessage"^
S2C_EnterGameSuccess
account (	Raccount
linkid (Rlinkid
mapId (RmapId"
S2C_ReEnterGame
token (	Rtoken
roleid (Rroleid
go_serverid (	R
goServerid
ip (	Rip
tcp_port (RtcpPort
kcp_port (RkcpPort%
websocket_port (RwebsocketPort""
S2C_Kick
reason (	Rreason"F
S2C_Pong
str (	Rstr
time (Rtime
token (	Rtoken"'
	S2C_Hello
randseed (Rrandseed"M
S2C_NameIsValid
name (	Rname
ok (Rok
errmsg (	Rerrmsg"
S2C_BeReplace
ip (	Rip"7
S2C_EnterGameFinish 
brief (2
.BriefTypeRbriefbproto3

	msg.proto"

C2S_Msg_GM
cmd (	Rcmd"!
S2C_Msg_Error
err (	Rerr"&

S2C_Msg_GM
content (	Rcontent"'
S2C_Msg_Say
content (	Rcontentbproto3
y
player.protocommon.proto"3
PosType
x (Rx
y (Ry
z (Rz";
ResType
resCfgId (RresCfgId
count (Rcount"
	BuildType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality
life (Rlife
curLife (RcurLife
pos (2.PosTypeRpos
lessTick (RlessTick 
curStarCoin	 (RcurStarCoin
curIce
 (RcurIce 
curCarboxyl (RcurCarboxyl 
curTitanium (RcurTitanium
curGas (RcurGas"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount

trainCfgId (R
trainCfgId

trainCount (R
trainCount$
lessTrainTick (RlessTrainTick"Z
SoliderLevelType
cfgId (RcfgId
level (Rlevel
lessTick (RlessTick"W
MineLevelType
cfgId (RcfgId
level (Rlevel
lessTick (RlessTick"3
SoliderType
id (Rid
count (Rcount"
HeroType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality
life (Rlife
curLife (RcurLife 
skillLevel1 (RskillLevel1 
skillLevel2 (RskillLevel2 
skillLevel3	 (RskillLevel3
lessTick
 (RlessTick
skillUp (RskillUp(
skillUpLessTick (RskillUpLessTick 
selectSkill (RselectSkill"
WarShipType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality
life (Rlife
curLife (RcurLife 
skillLevel1 (RskillLevel1 
skillLevel2 (RskillLevel2 
skillLevel3	 (RskillLevel3 
skillLevel4
 (RskillLevel4 
skillLevel5 (RskillLevel5
lessTick (RlessTick
skillUp (RskillUp(
skillUpLessTick (RskillUpLessTick"{
ArmyType&
warShip (2.WarShipTypeRwarShip
hero (2	.HeroTypeRhero(
soliders (2.SoliderTypeRsoliders"
Item
id (Rid
cfgId (RcfgId
num (Rnum 
targetCfgId (RtargetCfgId 
targetLevel (RtargetLevel$
targetQuality (RtargetQuality 
skillLevel1 (RskillLevel1 
skillLevel2 (RskillLevel2 
skillLevel3	 (RskillLevel3
life
 (Rlife
curLife (RcurLife 
skillLevel4 (RskillLevel4 
skillLevel5 (RskillLevel5
ref (Rref"X
ComposeItem
item (2.ItemRitem
lessTick (RlessTick
hour (Rhour"|

RepairItem
id (Rid
life (Rlife
curLife (RcurLife
cfgId (RcfgId
lessTick (RlessTick"e
FreightType
itemId (RitemId
itemNum (RitemNum$
currency (2.ResTypeRcurrency"
ResPlanetBrief
index (Rindex"
holdPlayerId (RholdPlayerId&
holdPlayerName (	RholdPlayerName(

currencies (2.ResTypeR
currencies"
	ResPlanet
index (Rindex
pos (2.PosTypeRpos
quality (Rquality
isOnline (RisOnline 
isAttacking (RisAttacking&
holdPlayerName (	RholdPlayerName"
holdPlayerId (RholdPlayerId(
holdPlayerLevel (RholdPlayerLevel(
holdPlayerScore	 (RholdPlayerScore(

currencies
 (2.ResTypeR
currencies"
builds (2
.BuildTypeRbuilds
ver (Rver"
FightReportType
fightId (RfightId&
resPlanetIndex (RresPlanetIndex
	fightTime (R	fightTime
	fightType (R	fightType
playerId (RplayerId
isWin (RisWin

isAttacker (R
isAttacker$
enemyPlayerId (RenemyPlayerId(
enemyPlayerName	 (	RenemyPlayerName*
enemyPlayerLevel
 (	RenemyPlayerLevel*
enemyPlayerScore (	RenemyPlayerScore-
loseArmyInfo (2	.ArmyTypeRloseArmyInfo(

currencies (2.ResTypeR
currencies"z
RankType
index (Rindex
name (	Rname
value (Rvalue
change (Rchange
reward (Rreward"

AirwayType
cfgId (RcfgId
name (	Rname
	warShipId (R	warShipId
flyTime (RflyTime
lessTime (RlessTime(

currencies (2.ResTypeR
currencies
items (2.ItemRitems
status (Rstatus"4

PledgeType
cfgId (RcfgId
mit (Rmit"m
BattleOperate
	GameFrame (R	GameFrame
Order (ROrder
X (RX
Y (RY
Z (RZ"E
C2S_Player_LookBriefs
pids (Rpids
session (Rsession"J
C2S_Player_BuildCreate
cfgId (RcfgId
pos (2.PosTypeRpos"B
C2S_Player_BuildMove
id (Rid
pos (2.PosTypeRpos"C
C2S_Player_BuildLevelUp
id (Rid
speedUp (RspeedUp"F
C2S_Player_BuildExchange
fromId (RfromId
toId (RtoId"(
C2S_Player_BuildGetRes
id (Rid"
C2S_Player_ExpandItemBag"(
C2S_Player_DestoryItem
id (Rid"E
C2S_Player_Move2ItemBag
id (Rid
itemType (RitemType"G
C2S_Player_MoveOutItemBag
id (Rid
pos (2.PosTypeRpos"K
C2S_Player_SoliderLevelUp
cfgId (RcfgId
speedUp (RspeedUp"H
C2S_Player_MineLevelUp
cfgId (RcfgId
speedUp (RspeedUp"'
C2S_Player_RemoveMess
id (Rid"q
C2S_Player_SoliderTrain
id (Rid"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount"s
C2S_Player_SoliderReplace
id (Rid"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount"<
C2S_Player_ItemCompose
id (Rid
hour (Rhour".
C2S_Player_ItemComposeCancel
id (Rid"-
C2S_Player_ItemComposeSpeed
id (Rid"B
C2S_Player_HeroLevelUp
id (Rid
speedUp (RspeedUp"E
C2S_Player_WarShipLevelUp
id (Rid
speedUp (RspeedUp"%
C2S_Player_Repair
ids (Rids"(
C2S_Player_RepairSpeed
id (Rid"\
C2S_Player_HeroSkillUp
id (Rid
skillUp (RskillUp
speedUp (RspeedUp"_
C2S_Player_WarShipSkillUp
id (Rid
skillUp (RskillUp
speedUp (RspeedUp"2
C2S_Player_PickBoatRes
boatIds (RboatIds"I
!C2S_Player_ResPlanetBuild2ItemBag
index (Rindex
id (Rid"e
!C2S_Player_ItemBagBuild2ResPlanet
index (Rindex
id (Rid
pos (2.PosTypeRpos"0
C2S_Player_LookResPlanet
index (Rindex"7
C2S_Player_BeginAttackResPlanet
index (Rindex"K
C2S_Player_EndAttackResPlanet
index (Rindex
isWin (RisWin"#
!C2S_Player_QueryAllResPlanetBrief"N
C2S_Player_HeroSelectSkill
id (Rid 
selectSkill (RselectSkill"1
C2S_Player_SpeedUp_BuildLevelUp
id (Rid"0
C2S_Player_SpeedUp_HeroLevelUp
id (Rid"0
C2S_Player_SpeedUp_HeroSkillUp
id (Rid"3
!C2S_Player_SpeedUp_WarShipLevelUp
id (Rid"3
!C2S_Player_SpeedUp_WarShipSkillUp
id (Rid"9
!C2S_Player_SpeedUp_SoliderLevelUp
cfgId (RcfgId"6
C2S_Player_SpeedUp_MineLevelUp
cfgId (RcfgId"1
C2S_Player_SpeedUp_SoliderTrain
id (Rid"R
C2S_Player_StartBattle

battleType (R
battleType
enemyId (RenemyId"
C2S_Player_EndBattle
battleId (RbattleId
ret (Rret 
signinPosId (RsigninPosId
bVersion (	RbVersion*
operates (2.BattleOperateRoperates(
soliders (2.SoliderTypeRsoliders"
C2S_Player_Exchange_Rate"A
C2S_Player_Exchange_Res
mit (Rmit
cfgId (RcfgId";
C2S_Player_Pledge
cfgId (RcfgId
mit (Rmit"/
C2S_Player_PledgeCancel
cfgId (RcfgId"Q
C2S_Player_AirwaySetWarShip
cfgId (RcfgId
	warShipId (R	warShipId"[
C2S_Player_AirwayAddFreight
cfgId (RcfgId&
freight (2.FreightTypeRfreight"/
C2S_Player_AirwaySetOut
cfgId (RcfgId"4
C2S_Player_AirwayClickFinish
cfgId (RcfgId"N
C2S_Player_Rank_Info
rankType (RrankType
cVersion (RcVersion"k
C2S_Player_ResPlanetMoveBuild
index (Rindex
buildId (RbuildId
pos (2.PosTypeRpos"U
S2C_Player_LookBriefs"
briefs (2
.BriefTypeRbriefs
session (Rsession":
S2C_Player_UpdateBrief 
brief (2
.BriefTypeRbrief"@
S2C_Player_BuildData(
	buildData (2
.BuildTypeR	buildData"7
S2C_Player_BuildAdd 
build (2
.BuildTypeRbuild"J
S2C_Player_BuildMove
ret (Rret 
build (2
.BuildTypeRbuild";
S2C_Player_BuildLevelUp 
build (2
.BuildTypeRbuild":
S2C_Player_BuildUpdate 
build (2
.BuildTypeRbuild"
S2C_Player_BuildGetRes
id (Rid 
getStarCoin (RgetStarCoin
getIce (RgetIce 
getCarboxyl (RgetCarboxyl 
getTitanium (RgetTitanium
getGas (RgetGas"%
S2C_Player_BuildDel
id (Rid"8
S2C_Player_ResData"
resData (2.ResTypeRresData"`
S2C_Player_ResChange
resCfgId (RresCfgId
count (Rcount
change (Rchange"o
S2C_Player_ItemBag
maxSpace (RmaxSpace 
expandSpace (RexpandSpace
items (2.ItemRitems"\
S2C_Player_SoliderLevelData=
soliderLevelData (2.SoliderLevelTypeRsoliderLevelData"V
S2C_Player_SoliderLevelUpdate5
soliderLevel (2.SoliderLevelTypeRsoliderLevel"<
S2C_Player_ExpandItemBag 
expandSpace (RexpandSpace"2
S2C_Player_ItemUpdate
item (2.ItemRitem"/
S2C_Player_ItemAdd
item (2.ItemRitem"$
S2C_Player_ItemDel
id (Rid"?
S2C_Player_RemoveMess
id (Rid
getMit (RgetMit"<
S2C_Player_HeroData%
heroData (2	.HeroTypeRheroData"3
S2C_Player_HeroAdd
hero (2	.HeroTypeRhero"$
S2C_Player_HeroDel
id (Rid"6
S2C_Player_HeroUpdate
hero (2	.HeroTypeRhero"@
S2C_Player_ComposeItemData"
items (2.ComposeItemRitems"C
S2C_Player_ItemCompose
id (Rid
item (2.ItemRitem"9
S2C_Player_ItemComposeCancel
item (2.ItemRitem"H
S2C_Player_WarShipData.
warShipData (2.WarShipTypeRwarShipData"?
S2C_Player_WarShipAdd&
warShip (2.WarShipTypeRwarShip"'
S2C_Player_WarShipDel
id (Rid"B
S2C_Player_WarShipUpdate&
warShip (2.WarShipTypeRwarShip"=
S2C_Player_ItemComposeAdd 
item (2.ComposeItemRitem"h
S2C_Player_RepairReturn/
successItems (2.RepairItemRsuccessItems
	totalCost (R	totalCost";
S2C_Player_RepairItems!
items (2.RepairItemRitems";
S2C_Player_RepairItemAdd
item (2.RepairItemRitem">
S2C_Player_RepairItemUpdate
item (2.RepairItemRitem"l
BoatResType
boatId (RboatId(

currencies (2.ResTypeR
currencies
items (2.ItemRitems"*
S2C_Player_RepairItemDel
id (Rid">
S2C_Player_ResPlanetData"
planet (2
.ResPlanetRplanet"<
S2C_Player_PickBoatRes"
boats (2.BoatResTypeRboats"W
S2C_Player_ResPlanet_BuildAdd
index (Rindex 
build (2
.BuildTypeRbuild"O
S2C_Player_ResPlanet_BuildDel
index (Rindex
buildId (RbuildId"Z
 S2C_Player_ResPlanet_BuildUpdate
index (Rindex 
build (2
.BuildTypeRbuild"I
S2C_Player_AllResPlanetBrief)
planets (2.ResPlanetBriefRplanets"P
S2C_Player_MineLevelData4
mineLevelData (2.MineLevelTypeRmineLevelData"J
S2C_Player_MineLevelUpdate,
	mineLevel (2.MineLevelTypeR	mineLevel"
S2C_Player_ResPlanetFightBegin
index (Rindex
pos (2.PosTypeRpos
quality (Rquality
isOnline (RisOnline 
isAttacking (RisAttacking&
holdPlayerName (	RholdPlayerName"
holdPlayerId (RholdPlayerId(
holdPlayerLevel (RholdPlayerLevel(
holdPlayerScore	 (RholdPlayerScore(

currencies
 (2.ResTypeR
currencies"
builds (2
.BuildTypeRbuilds
fightId (RfightId*
attackPlayerName (	RattackPlayerName&
attackPlayerId (RattackPlayerId,
attackPlayerLevel (RattackPlayerLevel,
attackPlayerScore (RattackPlayerScore%
armyInfo (2	.ArmyTypeRarmyInfo"
S2C_Player_ResPlanetFightEnd
index (Rindex
fightId (RfightId
isWin (RisWin(

currencies (2.ResTypeR
currencies-
loseArmyInfo (2	.ArmyTypeRloseArmyInfo"O
S2C_Player_FightReports4
fightReports (2.FightReportTypeRfightReports"Q
S2C_Player_FightReportAdd4
fightReports (2.FightReportTypeRfightReports"B
S2C_Player_PickBoatResNotify"
boats (2.BoatResTypeRboats"a
S2C_Player_StartBattle
battleId (RbattleId+

battleInfo (2.BattleInfoR
battleInfo"

BattleInfo"
builds (2
.BuildInfoRbuilds
traps (2	.TrapInfoRtraps(
soliders (2.SoliderInfoRsoliders
hero (2	.HeroInfoRhero)
mainShip (2.MainShipInfoRmainShip"
skills (2
.SkillInfoRskills(
	heroSkill (2
.SkillInfoR	heroSkill%
bullets (2.BulletInfoRbullets
buffs	 (2	.BuffInfoRbuffs"
	BuildInfo
cfgId (RcfgId
model (	Rmodel(
explosionEffect (	RexplosionEffect$
wreckageModel (	RwreckageModel
x (Rx
z (Rz
maxHp (RmaxHp
atk (Ratk
atkSpeed	 (RatkSpeed
atkRange
 (RatkRange
radius (Rradius
atkAir (RatkAir 
bulletCfgId (RbulletCfgId
isMain (RisMain
type (Rtype"
TrapInfo
cfgId (RcfgId
model (	Rmodel(
explosionEffect (	RexplosionEffect
x (Rx
z (Rz
	buffCfgId (R	buffCfgId

alertRange (R
alertRange
atkRange (RatkRange
radius	 (Rradius.
delayExplosionTime
 (RdelayExplosionTime"
SoliderInfo
cfgId (RcfgId
uuid (Ruuid
model (	Rmodel
icon (	Ricon
amount (Ramount
	moveSpeed (R	moveSpeed
maxHp (RmaxHp
atk (Ratk
atkSpeed	 (RatkSpeed
atkRange
 (RatkRange
radius (Rradius

originCost (R
originCost
addCost (RaddCost 
bulletCfgId (RbulletCfgId.
flashMoveDelayTime (RflashMoveDelayTime
type (Rtype"
HeroInfo
cfgId (RcfgId
model (	Rmodel
icon (	Ricon
	moveSpeed (R	moveSpeed
maxHp (RmaxHp
atk (Ratk
atkSpeed (RatkSpeed
atkRange (RatkRange
radius	 (Rradius.
flashMoveDelayTime
 (RflashMoveDelayTime 
bulletCfgId (RbulletCfgId"Z
MainShipInfo
cfgId (RcfgId
model (	Rmodel

skillPoint (R
skillPoint"
	SkillInfo
cfgId (RcfgId
model (	Rmodel
icon (	Ricon 
effectModel (	ReffectModel
	buffCfgId (R	buffCfgId
	moveSpeed (R	moveSpeed
lifeTime (RlifeTime
	frequency (R	frequency
range	 (Rrange

originCost
 (R
originCost
addCost (RaddCost

followSelf (R
followSelf
type (Rtype"

BulletInfo
cfgId (RcfgId
model (	Rmodel(
explosionEffect (	RexplosionEffect
type (Rtype
	moveSpeed (R	moveSpeed
atkRange (RatkRange"
BuffInfo
cfgId (RcfgId
model (	Rmodel
atk (Ratk
cure (Rcure
addAtk (RaddAtk 
addAtkSpeed (RaddAtkSpeed"
addMoveSpeed (RaddMoveSpeed

stopAction (R
stopAction
lifeTime	 (RlifeTime
	frequency
 (R	frequency
lifeType (RlifeType"
S2C_Player_EndBattle
battleId (RbattleId
starCoin (RstarCoin
ice (Rice
carboxyl (Rcarboxyl
titanium (Rtitanium
gas (Rgas"
S2C_Player_Exchange_Rate
mit (Rmit
starCoin (RstarCoin
ice (Rice
carboxyl (Rcarboxyl
titanium (Rtitanium
gas (Rgas">
S2C_Player_PledgeData%
pledges (2.PledgeTypeRpledges";
S2C_Player_PledgeAdd#
pledge (2.PledgeTypeRpledge",
S2C_Player_PledgeDel
cfgId (RcfgId">
S2C_Player_AirwayData%
airways (2.AirwayTypeRairways">
S2C_Player_AirwayUpdate#
airway (2.AirwayTypeRairway"m
S2C_Player_Rank_Info
rankType (RrankType
sVersion (RsVersion
rank (2	.RankTypeRrankbproto3