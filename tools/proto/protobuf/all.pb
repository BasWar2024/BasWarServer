
“
common.proto"|
MessagePackage
cmd (Rcmd
args (Rargs
response (Rresponse
session (Rsession
ud (Rud"ª
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
ë
login.protocommon.proto"§

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
lang	 (	Rlang
ip
 (	Rip"ô
CheckTokenType
token (	Rtoken
account (	Raccount
version (	Rversion
forward (	Rforward#
device (2.DeviceTypeRdevice"Ø
C2S_CreateRole/

checktoken (2.CheckTokenTypeR
checktoken
account (	Raccount
name (	Rname
race (Rrace
head (	Rhead
roleid (Rroleid"X
C2S_EnterGame/

checktoken (2.CheckTokenTypeR
checktoken
roleid (Rroleid"
C2S_ExitGame"#
C2S_CheckName
name (	Rname"
C2S_Ping
str (	Rstr"Ï
RoleType
roleid (Rroleid
name (	Rname
race (Rrace
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
mapId (RmapId"Õ
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
¡
	msg.proto"

C2S_Msg_GM
cmd (	Rcmd"!
S2C_Msg_Error
err (	Rerr"&

S2C_Msg_GM
content (	Rcontent"A
S2C_Msg_Say
content (	Rcontent
errcode (Rerrcodebproto3
îû
player.protocommon.proto"3
PosType
x (Rx
y (Ry
z (Rz"O
ResType
resCfgId (RresCfgId
count (Rcount
bind (Rbind"[
ResExchangeType
resCfgId (RresCfgId
mit (Rmit
carboxyl (Rcarboxyl"£
PlayerResType
playerId (RplayerId
starCoin (RstarCoin
ice (Rice
gas (Rgas
carboxyl (Rcarboxyl
titanium (Rtitanium"â
PlayerBriefType
playerId (RplayerId 
playerScore (RplayerScore 
playerLevel (RplayerLevel

playerName (	R
playerName

playerHead (	R
playerHead
unionId (RunionId
	unionName (	R	unionName

donateTime (R
donateTime"∞
BuildBriefType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality
life (Rlife
curLife (RcurLife
pos (2.PosTypeRpos"´
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
lessTrainTick (RlessTrainTick
chain (Rchain
ref (Rref
refBy (RrefBy&
owner (2.PlayerBriefTypeRowner
	mintCount (R	mintCount
isNormal (RisNormal"É
BattleBuildType
id (Rid
cfgId (RcfgId
quality (Rquality
level (Rlevel
x (Rx
z (Rz"Z
SoliderLevelType
cfgId (RcfgId
level (Rlevel
lessTick (RlessTick"ó
SoliderBattleType
id (Rid
count (Rcount
dieCount (RdieCount
cfgId (RcfgId
level (Rlevel
index (Rindex"|
HeroBattleType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality
index (Rindex"i
WarShipBattleType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality"!
	ForgeData
level (Rlevel"ﬁ
HeroType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality
life (Rlife
curLife (RcurLife
skill1 (Rskill1
skill2 (Rskill2
skill3	 (Rskill3 
skillLevel1
 (RskillLevel1 
skillLevel2 (RskillLevel2 
skillLevel3 (RskillLevel3
lessTick (RlessTick
skillUp (RskillUp(
skillUpLessTick (RskillUpLessTick 
selectSkill (RselectSkill
chain (Rchain
ref (Rref
refBy (RrefBy&
owner (2.PlayerBriefTypeRowner
	mintCount (R	mintCount
battleCd (RbattleCd"ø
WarShipType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality
life (Rlife
curLife (RcurLife
skill1 (Rskill1
skill2 (Rskill2
skill3	 (Rskill3
skill4
 (Rskill4
skill5 (Rskill5 
skillLevel1 (RskillLevel1 
skillLevel2 (RskillLevel2 
skillLevel3 (RskillLevel3 
skillLevel4 (RskillLevel4 
skillLevel5 (RskillLevel5
lessTick (RlessTick
skillUp (RskillUp(
skillUpLessTick (RskillUpLessTick
chain (Rchain
ref (Rref
refBy (RrefBy&
owner (2.PlayerBriefTypeRowner&
launchLessTick (RlaunchLessTick
	mintCount (R	mintCount"Å
ArmyType&
warShip (2.WarShipTypeRwarShip
hero (2	.HeroTypeRhero.
soliders (2.SoliderBattleTypeRsoliders"ù
NFTType
id (Rid
cfgId (RcfgId
level (Rlevel
quality (Rquality
life (Rlife
curLife (RcurLife
skill1 (Rskill1
skill2 (Rskill2
skill3	 (Rskill3
skill4
 (Rskill4
skill5 (Rskill5 
skillLevel1 (RskillLevel1 
skillLevel2 (RskillLevel2 
skillLevel3 (RskillLevel3 
skillLevel4 (RskillLevel4 
skillLevel5 (RskillLevel5
chain (Rchain
ref (Rref
refBy (RrefBy

donateTime (R
donateTime
ownerPid (RownerPid
	ownerName (	R	ownerName
itemType (RitemType
	mintCount (R	mintCount
battleCd (RbattleCd">
Item
id (Rid
cfgId (RcfgId
num (Rnum"X
ComposeItem
item (2.ItemRitem
lessTick (RlessTick
hour (Rhour"1
TipItem
cfgId (RcfgId
num (Rnum"/
FreightType
id (Rid
num (Rnum"∞
FightReportType
fightId (RfightId&
resPlanetIndex (RresPlanetIndex
	fightTime (R	fightTime
	fightType (R	fightType
playerId (RplayerId
result (Rresult

isAttacker (R
isAttacker$
enemyPlayerId (RenemyPlayerId(
enemyPlayerName	 (	RenemyPlayerName*
enemyPlayerLevel
 (RenemyPlayerLevel*
enemyPlayerScore (RenemyPlayerScore(
enemyPlayerHead (	RenemyPlayerHead 
signinPosId (RsigninPosId
bVersion (	RbVersion%
heros (2.HeroBattleTypeRheros.
soliders (2.SoliderBattleTypeRsoliders(

currencies (2.ResTypeR
currencies
atkBadge (RatkBadge

defenBadge (R
defenBadge"ä
BattleTeamType
heroId (RheroId"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount
buildId (RbuildId"n
ArmyTeamType
heroId (RheroId"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount"Q

BattleArmy
	warShipId (R	warShipId%
teams (2.BattleTeamTypeRteams"î
StarmapBattleReport
battleId (RbattleId

battleTime (R
battleTime
playerId (RplayerId

playerName (	R
playerName
unionId (RunionId
	unionName (	R	unionName
result (Rresult
leftHp (RleftHp
	unionFlag	 (R	unionFlag$
presidentName
 (	RpresidentName,
warShip (2.WarShipBattleTypeRwarShip%
heros (2.HeroBattleTypeRheros.
soliders (2.SoliderBattleTypeRsoliders
	gridCfgId (R	gridCfgId

campaignId (R
campaignId
loseHp (RloseHp"œ
StarmapBattleDefender
playerId (RplayerId

playerName (	R
playerName
unionId (RunionId
	unionName (	R	unionName
	unionFlag (R	unionFlag$
presidentName (	RpresidentName"Ò
StarmapCampaignReport

campaignId (R
campaignId
	gridCfgId (R	gridCfgId
	startTime (R	startTime2
defender (2.StarmapBattleDefenderRdefender
	maxLoseHp (R	maxLoseHp
maxHp (RmaxHp
isEnd (RisEnd"à
StarmapCampaignPlyStatistics
playerId (RplayerId

playerName (	R
playerName
atkCnt (RatkCnt
atkHp (RatkHp"I
GridShareTime
	gridCfgId (R	gridCfgId
leftTime (RleftTime"?
GridExclusiveType
cfgId (RcfgId
chain (Rchain"=
ToGridBuildInfo
id (Rid
pos (2.PosTypeRpos"î
RankType
index (Rindex
name (	Rname
value (Rvalue
upDown (RupDown
award (Raward
headIcon (	RheadIcon"Ô
StarmapRankType
index (Rindex
unionId (RunionId
	unionName (	R	unionName
	unionFlag (R	unionFlag 
memberCount (RmemberCount
score (Rscore
ratio (Rratio
hyt (Rhyt
mit	 (Rmit"4

PledgeType
cfgId (RcfgId
mit (Rmit"u
BattleEndInfo
cfgId (RcfgId
	firstPass (R	firstPass
star (Rstar
	isNewStar (R	isNewStar"m
BattleOperate
	GameFrame (R	GameFrame
Order (ROrder
X (RX
Y (RY
Z (RZ"Í
PvpEnemyType
playerId (RplayerId 
playerScore (RplayerScore 
playerLevel (RplayerLevel

playerName (	R
playerName

playerHead (	R
playerHead
	unionName (	R	unionName
	canAttack (R	canAttack"≈

BattleInfo"
builds (2
.BuildInfoRbuilds
traps (2	.TrapInfoRtraps(
soliders (2.SoliderInfoRsoliders
heros (2	.HeroInfoRheros)
mainShip (2.MainShipInfoRmainShip"
skills (2
.SkillInfoRskills*

heroSkills (2
.SkillInfoR
heroSkills
buffs (2	.BuffInfoRbuffs#
enemy	 (2.PvpEnemyTypeRenemy 
attackCards
 (RattackCards"
defenseCards (RdefenseCards4
skillEffects (2.SkillEffectInfoRskillEffects4
summonSoliders (2.SoliderInfoRsummonSoliders4
battleMapInfo (2.BattleMapInfoRbattleMapInfo"µ
BattleMapInfo
sceneId (RsceneId*

signinPos1 (2
.SigninPosR
signinPos10
signinScale1 (2.SigninScaleRsigninScale1*

signinPos2 (2
.SigninPosR
signinPos20
signinScale2 (2.SigninScaleRsigninScale2*

signinPos3 (2
.SigninPosR
signinPos30
signinScale3 (2.SigninScaleRsigninScale3*

signinPos4 (2
.SigninPosR
signinPos40
signinScale4	 (2.SigninScaleRsigninScale4
length
 (Rlength
width (Rwidth.
skillAreaPos (2
.SigninPosRskillAreaPos4
skillAreaScale (2.SigninScaleRskillAreaScale"5
	SigninPos
x (Rx
y (Ry
z (Rz"Q
SigninScale
length (Rlength
width (Rwidth
hight (Rhight"õ
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

atkSkillId (R
atkSkillId
isMain (RisMain
type (Rtype
subType (RsubType
center (	Rcenter 
isConstruct (RisConstruct
	direction (R	direction"
atkReadyTime (RatkReadyTime
id (Rid.
atkSkillShowRadius (RatkSkillShowRadius

inAtkRange (R
inAtkRange
hp (Rhp
floor (	Rfloor 
deadSkillId (RdeadSkillId 
bornSkillId (RbornSkillId
race (Rrace 
atkSkill1Id (RatkSkill1Id
firstAtk (RfirstAtk
intArgs1 (RintArgs1
intArgs2  (RintArgs2
intArgs3! (RintArgs3
level" (Rlevel"Æ
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
 (RdelayExplosionTime
id (Rid"´
SoliderInfo
cfgId (RcfgId
model (	Rmodel
icon (	Ricon
amount (Ramount
	moveSpeed (R	moveSpeed
maxHp (RmaxHp
atk (Ratk
atkSpeed (RatkSpeed
atkRange	 (RatkRange
radius
 (Rradius

atkSkillId (R
atkSkillId
type (Rtype
center (	Rcenter

deadEffect (	R
deadEffect
	isDeminer (R	isDeminer"
atkReadyTime (RatkReadyTime
id (Rid.
atkSkillShowRadius (RatkSkillShowRadius
	isMedical (R	isMedical

inAtkRange (R
inAtkRange 
deadSkillId (RdeadSkillId 
bornSkillId (RbornSkillId
race (Rrace
index (Rindex
level (Rlevel"Ñ
HeroInfo
cfgId (RcfgId
model (	Rmodel
icon (	Ricon
	moveSpeed (R	moveSpeed
maxHp (RmaxHp
atk (Ratk
atkSpeed (RatkSpeed
atkRange (RatkRange
radius	 (Rradius

atkSkillId (R
atkSkillId
center (	Rcenter

deadEffect (	R
deadEffect
	isDeminer (R	isDeminer"
atkReadyTime (RatkReadyTime
id (Rid
level (Rlevel.
atkSkillShowRadius (RatkSkillShowRadius
	isMedical (R	isMedical

inAtkRange (R
inAtkRange 
deadSkillId (RdeadSkillId 
bornSkillId (RbornSkillId$
aroundSkillId (RaroundSkillId
race (Rrace
index (Rindex
skill1 (Rskill1
skill2 (Rskill2
skill3 (Rskill3
quality (Rquality"Ú
MainShipInfo
cfgId (RcfgId
model (	Rmodel

skillPoint (R
skillPoint
id (Rid
skill1 (Rskill1
skill2 (Rskill2
skill3 (Rskill3
skill4 (Rskill4
maxHp	 (RmaxHp
atk
 (Ratk"Ø	
	SkillInfo
id (Rid
cfgId (RcfgId
icon (	Ricon
type (Rtype
	skillType (R	skillType 
targetGroup (RtargetGroup*
skillEffectCfgId (RskillEffectCfgId

originCost (R
originCost
addCost	 (RaddCost
skillCd
 (RskillCd
useArea (RuseArea
intArg1 (RintArg1
intArg2 (RintArg2
intArg3 (RintArg3
intArg4 (RintArg4
intArg5 (RintArg5
intArg6 (RintArg6
intArg7 (RintArg7
intArg8 (RintArg8
intArg9 (RintArg9
intArg10 (RintArg10
intArg11 (RintArg11
intArg12 (RintArg12
intArg13 (RintArg13
intArg14 (RintArg14
intArg15 (RintArg15

stringArg1 (	R
stringArg1

stringArg2 (	R
stringArg2

stringArg3 (	R
stringArg3

stringArg4 (	R
stringArg4

stringArg5 (	R
stringArg5

stringArg6  (	R
stringArg6

stringArg7! (	R
stringArg7

stringArg8" (	R
stringArg8

stringArg9# (	R
stringArg9 
stringArg10$ (	RstringArg10
level% (Rlevel
quality& (Rquality(
releaseDistance' (RreleaseDistance$
skillAnimTime( (RskillAnimTime&
skillDelayTime) (RskillDelayTime"∞
BuffInfo
cfgId (RcfgId
name (	Rname
model (	Rmodel
lifeTime (RlifeTime
	frequency (R	frequency*
skillEffectCfgId (RskillEffectCfgId"è
SkillEffectInfo
cfgId (RcfgId
type (Rtype
args (	Rargs
	rangeType (R	rangeType
range (Rrange*
skillEffectCfgId (RskillEffectCfgId
	buffCfgId (R	buffCfgId 
entityCfgId (RentityCfgId

skillCfgId	 (R
skillCfgId"p
SystemNotice
imageUrl (	RimageUrl
url (	Rurl
text (	Rtext

createTime (R
createTime"Q
Achievement
index (Rindex
value (Rvalue
drawed (Rdrawed"6
Galaxy
cfgId (RcfgId
status (Rstatus"É
UnionMemberType
playerId (RplayerId

playerName (	R
playerName

playerHead (	R
playerHead 
playerScore (RplayerScore

matchScore (R
matchScore
unionJob (RunionJob

fightPower (R
fightPower
starCoin (RstarCoin
ice	 (Rice
titanium
 (Rtitanium
gas (Rgas
carboxyl (Rcarboxyl
online (Ronline"
contriDegree (RcontriDegree
grids (Rgrids
offline (Roffline
chain (Rchain
	combatVal (R	combatVal"¯
UnionSoliderType
cfgId (RcfgId
count (Rcount
genCount (RgenCount
genTick (RgenTick
level (Rlevel

hpAddRatio (R
hpAddRatio 
atkAddRatio (RatkAddRatio*
atkSpeedAddRatio (RatkSpeedAddRatio"ˆ
UnionBuildType
cfgId (RcfgId
count (Rcount
genCount (RgenCount
genTick (RgenTick
level (Rlevel

hpAddRatio (R
hpAddRatio 
atkAddRatio (RatkAddRatio*
atkSpeedAddRatio (RatkSpeedAddRatio"]
UnionTechType
cfgId (RcfgId
level (Rlevel 
levelUpTick (RlevelUpTick"´
UnionBaseType
unionId (RunionId
	unionName (	R	unionName
	unionFlag (R	unionFlag 
unionNotice (	RunionNotice"
unionSharing (RunionSharing
	enterType (R	enterType 
memberCount (RmemberCount
	memberMax	 (R	memberMax

fightPower
 (R
fightPower
starCoin (RstarCoin
ice (Rice
titanium (Rtitanium
gas (Rgas
carboxyl (Rcarboxyl$
nftDefenseNum (RnftDefenseNum

nftHeroNum (R
nftHeroNum

nftShipNum (R
nftShipNum$
presidentName (	RpresidentName 
beginGridId (RbeginGridId$
starCoinLimit (RstarCoinLimit
iceLimit (RiceLimit
gasLimit (RgasLimit$
titaniumLimit (RtitaniumLimit$
carboxylLimit (RcarboxylLimit

unionLevel (R
unionLevel
exp (Rexp
score (Rscore
rank (Rrank

gridOutput (R
gridOutput
plots (Rplots

unionChain  (R
unionChain"Ω
UnionJoinType
unionId (RunionId
	unionName (	R	unionName
	unionFlag (R	unionFlag"
unionSharing (RunionSharing
	enterType (R	enterType 
memberCount (RmemberCount
	memberMax	 (R	memberMax

fightPower
 (R
fightPower

unionChain (R
unionChain
score (Rscore"à
UnionBriefType
unionId (RunionId
	unionName (	R	unionName
	unionFlag (R	unionFlag 
unionNotice (	RunionNotice"
unionSharing (RunionSharing
	enterType (R	enterType

enterScore (R
enterScore 
memberCount (RmemberCount
	memberMax	 (R	memberMax

fightPower
 (R
fightPower
starCoin (RstarCoin
ice (Rice
titanium (Rtitanium
gas (Rgas
carboxyl (Rcarboxyl$
nftDefenseNum (RnftDefenseNum

nftHeroNum (R
nftHeroNum*
normalDefenseNum (RnormalDefenseNum$
normalHeroNum (RnormalHeroNum 
editArmyPid (ReditArmyPid"
editArmyTick (ReditArmyTick*
starCoinLimitAdd (RstarCoinLimitAdd 
gasLimitAdd (RgasLimitAdd 
iceLimitAdd (RiceLimitAdd*
titaniumLimitAdd (RtitaniumLimitAdd*
carboxylLimitAdd (RcarboxylLimitAdd

unionChain (R
unionChain"–
UnionApplyType
playerId (RplayerId 
playerScore (RplayerScore

fightPower (R
fightPower

playerName (	R
playerName

playerHead (	R
playerHead
	unionName (	R	unionName
unionId (RunionId
	applyTime (R	applyTime
answer	 (Ranswer
	baseLevel
 (R	baseLevel
chain (Rchain"Ö
UnionInviteType$
union (2.UnionBaseTypeRunion4
invitePlayer (2.UnionMemberTypeRinvitePlayer
answer (Ranswer"§
Mint
nftId1 (RnftId1
nftId2 (RnftId2
status (Rstatus
	startTime (R	startTime
	mintCfgId (R	mintCfgId
nftType (RnftType"·
ChatMsg
msgId (RmsgId
time (Rtime 
channelType (RchannelType
playerId (RplayerId

playerName (	R
playerName
headIcon (	RheadIcon
text (	Rtext
unionId (RunionId
unionJob	 (RunionJob
	unionName
 (	R	unionName
vip (Rvip"
hasHyperLink (RhasHyperLink
chain (Rchain":
CompleteTask
cfgId (RcfgId
stage (Rstage"@
TaskTargetCond
condId (RcondId
curVal (RcurVal"U

TaskTarget
tarId (RtarId1
targetConds (2.TaskTargetCondRtargetConds"O
	DailyTask
index (Rindex
value (Rvalue
drawed (Rdrawed"C
SoliderForgeLevelType
cfgId (RcfgId
level (Rlevel"≤
FoundationInfoType

playerName (	R
playerName
playerId (RplayerId 
playerLevel (RplayerLevel 
playerScore (RplayerScore

playerHead (	R
playerHead
isOnline (RisOnline"
builds (2
.BuildTypeRbuilds"
resInfo (2.ResTypeRresInfo
sceneId	 (RsceneId"Ø
	MailBrief
id (Rid
sendPid (RsendPid
sendName (	RsendName
title (	Rtitle
sendTime (RsendTime
read (Rread
canGet (RcanGet"j
MailAttachType
cfgId (RcfgId
quality (Rquality
count (Rcount
type (Rtype"è
MailType
id (Rid
duration (Rduration
sendPid (RsendPid
sendName (	RsendName
title (	Rtitle
content (	Rcontent
sendTime (RsendTime/

attachment (2.MailAttachTypeR
attachment
read	 (Rread
get
 (Rget"E
	GuideInfo
guideId (RguideId

skipOthers (R
skipOthers"â
	GridBrief
cfgId (RcfgId
status (Rstatus
belong (Rbelong

isFavorite (R
isFavorite&
owner (2.GridBrief.OwnerRowner
unionNum (RunionNum$
battleEndTick (RbattleEndTick 
protectTime (RprotectTimeâ
Owner
	unionName (	R	unionName

playerName (	R
playerName
	unionFlag (R	unionFlag$
presidentName (	RpresidentName" 

GridDetail
cfgId (RcfgId
status (Rstatus
belong (Rbelong
carboxyl (Rcarboxyl 
protectTime (RprotectTime"
builds (2
.BuildTypeRbuilds&
owner (2.PlayerBriefTypeRowner,
attacker (2.PlayerBriefTypeRattacker
sceneId	 (RsceneId$
battleEndTick
 (RbattleEndTick"É
StarmapMini
cfgId (RcfgId
belong (Rbelong
status (Rstatus
	unionName (	R	unionName
tag (	Rtag"P
PvpStageInfo
stage (Rstage
score (Rscore
ratio (Rratio"^
PvpRankMitRewardInfo
min_rank (RminRank
max_rank (RmaxRank
mit (Rmit"ñ
PvpMatchRewardRecord
rankTime (RrankTime
season (Rseason
score (Rscore
rank (Rrank 
reward (2.ResTypeRreward"6
PvpMatchRewardTips 
reward (2.ResTypeRreward"}
MyMatchReward
type (Rtype
weekno (Rweekno
rank (Rrank
carboxyl (Rcarboxyl
mit (Rmit"à
GridRewardPart
rtype (Rrtype
percent (Rpercent
total (Rtotal
myVal (RmyVal
carboxyl (Rcarboxyl"q
GridRewardRecord
cfgId (RcfgId)
rewards (2.GridRewardPartRrewards
	timestamp (R	timestamp"Ü

GridReward
unionMit (RunionMit$
unionCarboxyl (RunionCarboxyl$
otherUnionMit (RotherUnionMit.
otherUnionCarboxyl (RotherUnionCarboxyl*
personalUnionMit (RpersonalUnionMit4
personalUnionCarboxyl (RpersonalUnionCarboxyl"W
	ChainType
chainId (RchainId
	chainName (	R	chainName
open (Ropen"¥
LaunchBridgeRecord
time (Rtime
mit (Rmit
hyt (Rhyt
fee (Rfee
tokenIds (RtokenIds
itemIds (RitemIds

itemCfgIds (R
itemCfgIds"G
LaunchBridgeFee
min (Rmin
max (Rmax
fee (Rfee"\
EditorCreateBuilds
cfgId (RcfgId
pos (2.PosTypeRpos
level (Rlevel"3
PVEPass
cfgId (RcfgId
star (Rstar"9
PVEPassStar
cfgId (RcfgId
stars (Rstars"L
AutoPushType$
autoPushCfgId (RautoPushCfgId
status (Rstatus"õ
ReserveArmy
buildId (RbuildId

trainCfgId (R
trainCfgId

trainCount (R
trainCount
	trainTick (R	trainTick
count (Rcount"h
ArmyFormation
armyId (RarmyId
armyName (	RarmyName#
teams (2.ArmyTeamTypeRteams"V
DrawCardInfo
cfgId (RcfgId
count (Rcount
drawTime (RdrawTime"]
DrawCardRec
cfgId (RcfgId
	itemCfgId (R	itemCfgId
drawTime (RdrawTime"ä
ResExchangeTar
starCoin (	RstarCoin
ice (	Rice
titanium (	Rtitanium
gas (	Rgas
	tesseract (	R	tesseract"F
ResExchangeRate
from (Rfrom
to (2.ResExchangeTarRto"7
FavoriteGrids
cfgId (RcfgId
tag (	Rtag"
Heros
id (Rid"5
Funds
cfgId (RcfgId
status (Rstatus"$
Pros
	productId (	R	productId"9
Daily
status (Rstatus
isFirst (RisFirst"6
Gift
	productId (	R	productId
num (Rnum"E
Goods
cfgId (RcfgId
num (Rnum
index (Rindex"]
LoginReward
day (Rday

baseStatus (R
baseStatus
	advStatus (R	advStatus"6
StarPackInfo
cfgId (RcfgId
day (Rday"-
	SkillCard
id (Rid
num (Rnum",
ItemData
id (Rid
num (Rnum"E
C2S_Player_LookBriefs
pids (Rpids
session (Rsession"~
C2S_Player_BuildCreate
cfgId (RcfgId
pos (2.PosTypeRpos
opType (RopType
guideNow (RguideNow"B
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
C2S_Player_ExpandItemBag">
C2S_Player_ResolveItem
id (Rid
count (Rcount":
C2S_Player_UseItem
id (Rid
count (Rcount"K
C2S_Player_SoliderLevelUp
cfgId (RcfgId
speedUp (RspeedUp"H
C2S_Player_MineLevelUp
cfgId (RcfgId
speedUp (RspeedUp"'
C2S_Player_RemoveMess
id (Rid"ç
C2S_Player_SoliderTrain
id (Rid"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount
guideNow (RguideNow"s
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
speedUp (RspeedUp"l
C2S_Player_WarShipPutonSkill
id (Rid

skillIndex (R
skillIndex
	itemCfgId (R	itemCfgId"N
C2S_Player_WarShipResetSkill
id (Rid

skillIndex (R
skillIndex"O
C2S_Player_WarShipForgetSkill
id (Rid

skillIndex (R
skillIndex"\
C2S_Player_HeroSkillUp
id (Rid
skillUp (RskillUp
speedUp (RspeedUp"_
C2S_Player_WarShipSkillUp
id (Rid
skillUp (RskillUp
speedUp (RspeedUp"#
!C2S_Player_GetMyStarmapRewardList" 
C2S_Player_DrawMyStarmapReward"u
C2S_Player_ReserveArmyTrain
id (Rid"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount"+
C2S_Player_GetReserveArmy
id (Rid"w
C2S_Player_SpeedupReserveArmy
id (Rid"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount"5
C2S_Player_SearchPlayer
playerId (RplayerId"N
C2S_Player_HeroSelectSkill
id (Rid 
selectSkill (RselectSkill"1
C2S_Player_SpeedUp_BuildLevelUp
id (Rid"i
C2S_Player_HeroPutonSkill
id (Rid

skillIndex (R
skillIndex
	itemCfgId (R	itemCfgId"K
C2S_Player_HeroResetSkill
id (Rid

skillIndex (R
skillIndex"L
C2S_Player_HeroForgetSkill
id (Rid

skillIndex (R
skillIndex"3
!C2S_Player_SpeedUp_WarShipSkillUp
id (Rid"9
!C2S_Player_SpeedUp_SoliderLevelUp
cfgId (RcfgId"6
C2S_Player_SpeedUp_MineLevelUp
cfgId (RcfgId"1
C2S_Player_SpeedUp_SoliderTrain
id (Rid"ì
C2S_Player_StartBattle

battleType (R
battleType
enemyId (RenemyId
armyType (RarmyType
armyId (RarmyId!
armys (2.BattleArmyRarmys 
signinPosId (RsigninPosId
bVersion (	RbVersion*
operates (2.BattleOperateRoperates"å
C2S_Player_EndBattle
battleId (RbattleId
ret (Rret 
signinPosId (RsigninPosId
bVersion (	RbVersion*
operates (2.BattleOperateRoperates.
soliders (2.SoliderBattleTypeRsoliders
endStep (RendStep.
destoryDefendCount (RdestoryDefendCount0
destoryDevelopCount	 (RdestoryDevelopCount0
destoryEconomyCount
 (RdestoryEconomyCount"
C2S_Player_GetDrawCardRecord"J
C2S_Player_Draw_Card
cfgId (RcfgId
	drawCount (R	drawCount"4
C2S_Player_Exchange_Rate
tipType (RtipType"[
C2S_Player_Exchange_Res
from (Rfrom
	fromCount (R	fromCount
to (Rto"
C2S_Player_FirstGetGridRank"L
C2S_Player_Rank_Info
rankType (RrankType
version (Rversion"ü
C2S_Player_UploadBattle
battleId (RbattleId 
signinPosId (RsigninPosId
bVersion (	RbVersion*
operates (2.BattleOperateRoperates"z
$C2S_Player_QueryStarmapBattleReports

campaignId (R
campaignId
pageNo (RpageNo
pageSize (RpageSize"\
&C2S_Player_QueryStarmapCampaignReports
pageNo (RpageNo
pageSize (RpageSize">
C2S_Player_QueryFightReports

battleType (R
battleType"W
C2S_Player_LookBattlePlayBack
battleId (RbattleId
bVersion (	RbVersion"
C2S_Player_ChangePvpPlayers";
C2S_Player_PvpScoutFoundation
playerId (RplayerId"
C2S_Player_QueryPvpPlayers"
C2S_Player_AddPvpBattleNum"2
C2S_Player_DrawAchievement
index (Rindex"5
C2S_Player_FinishNewPlayerGuide
step (Rstep"
C2S_Player_GetMyGirdList""
 C2S_Player_GetMyFavoriteGridList"4
C2S_Player_DelMyFavoriteGrid
cfgId (RcfgId"/
C2S_Player_GiveUpMyGrid
cfgId (RcfgId"M
C2S_Player_GiftWithMyGrid
cfgId (RcfgId
playerId (RplayerId"F
C2S_Player_AddMyFavoriteGrid
cfgId (RcfgId
tag (	Rtag"ÿ
C2S_Player_CreateUnion
	unionName (	R	unionName 
unionNotice (	RunionNotice
	unionFlag (R	unionFlag
	enterType (R	enterType

enterScore (R
enterScore"
unionSharing (RunionSharing"0
C2S_Player_JoinUnion
unionId (RunionId"2
C2S_Player_SearchUnion
keyWord (	RkeyWord"9
C2S_Player_QueryUnionBaseInfo
unionId (RunionId"á
C2S_Player_EditUnionJob
unionId (RunionId
playerId (RplayerId
unionJob (RunionJob
editType (ReditType"O
C2S_Player_TickOutUnion
unionId (RunionId
playerId (RplayerId"0
C2S_Player_QuitUnion
unionId (RunionId"ˆ
C2S_Player_ModifyUnionInfo
unionId (RunionId
	unionFlag (R	unionFlag
	enterType (R	enterType

enterScore (R
enterScore"
unionSharing (RunionSharing 
unionNotice (	RunionNotice
	unionName (	R	unionName"j
C2S_Player_JoinUnionAnswer
answer (Ranswer
playerId (RplayerId
unionId (RunionId"
C2S_Player_QueryMyUnionInfo"R
C2S_Player_InviteJoinUnion
playerId (RplayerId
unionId (RunionId"P
C2S_Player_AnswerUnionInvite
unionId (RunionId
answer (Ranswer"
C2S_Player_GetUnionInviteList"8
C2S_Player_GetUnionApplyList
unionId (RunionId"
C2S_Player_UnionClearAllApply"™
C2S_Player_UnionDonate
unionId (RunionId
starCoin (RstarCoin
ice (Rice
titanium (Rtitanium
gas (Rgas
carboxyl (Rcarboxyl"d
C2S_Player_UnionTrainSolider
unionId (RunionId
cfgId (RcfgId
count (Rcount"M
C2S_Player_UnionTechLevelUp
unionId (RunionId
cfgId (RcfgId"r
C2S_Player_SendChatMsg 
channelType (RchannelType
text (	Rtext"
hasHyperLink (RhasHyperLink"T
C2S_Player_QueryChatMsgs 
channelType (RchannelType
cMsgId (RcMsgId"2
C2S_Player_OneKeyTrainSoldiers
ids (Rids"7
#C2S_Player_OneKeySpeedTrainSoldiers
ids (Rids"+
C2S_Player_DrawTask
index (Rindex">
*C2S_Player_OneKeySpeedAndFullTrainSoldiers
ids (Rids"
C2S_Player_QueryPlayerInfo"1
C2S_Player_ModifyPlayerName
name (	Rname"õ
C2S_Player_ModifyPlayerInfo
	canInvite (R	canInvite
canVisit (RcanVisit
text (	Rtext
headIcon (	RheadIcon
race (Rrace"<
C2S_Player_ChatVisitFoundation
playerId (RplayerId"R
 C2S_Player_SoliderQualityUpgrade
cfgId (RcfgId
speedUp (RspeedUp"=
%C2S_Player_SoliderQualityUpgradeSpeed
cfgId (RcfgId"K
C2S_Player_SoliderForge
cfgId (RcfgId
addRatio (RaddRatio"=
C2S_Player_UnionVisitFoundation
playerId (RplayerId"`
C2S_Player_UnionGenBuild
unionId (RunionId
cfgId (RcfgId
count (Rcount":
C2S_Player_StartEditUnionArmys
unionId (RunionId"
C2S_Player_GetStarmapScore"I
C2S_Player_AddUnionFavoriteGrid
cfgId (RcfgId
tag (	Rtag"7
C2S_Player_DelUnionFavoriteGrid
cfgId (RcfgId"$
C2S_Player_GetMail
id (Rid"$
C2S_Player_DelMail
id (Rid"
C2S_Player_OneKeyDelMails"
C2S_Player_OneKeyReadMails".
C2S_Player_ReceiveMailAttach
id (Rid"=
C2S_Player_finishGuides"
guides (2
.GuideInfoRguides"9
C2S_Player_enterStarmap

gridCfgIds (R
gridCfgIds"
C2S_Player_leaveStarmap"3
C2S_Player_scoutStarmapGrid
cfgId (RcfgId"g
C2S_Player_putBuildOnGrid
cfgId (RcfgId
buildId (RbuildId
pos (2.PosTypeRpos"h
C2S_Player_moveBuildOnGrid
cfgId (RcfgId
buildId (RbuildId
pos (2.PosTypeRpos"K
C2S_Player_delBuildOnGrid
cfgId (RcfgId
buildId (RbuildId"M
C2S_Player_storeBuildOnGrid
cfgId (RcfgId
buildId (RbuildId"3
C2S_Player_subscribeGrids
cfgIds (RcfgIds"5
C2S_Player_unsubscribeGrids
cfgIds (RcfgIds"[
C2S_Player_StarmapMatchRank
	matchType (R	matchType

unionChain (R
unionChain"#
!C2S_Player_StarmapMatchUnionGrids"
C2S_Player_ChainBridgeInfo"≥
C2S_Player_LaunchToBridge
chainId (RchainId
	warShipId (R	warShipId
mit (Rmit
hyt (Rhyt
tokenIds (RtokenIds

tokenKinds (R
tokenKinds"*
C2S_Player_SetUseWarShip
id (Rid"'
C2S_Player_SetUseHero
id (Rid"7
C2S_Player_BuyBattleNum
	battleNum (R	battleNum" 
C2S_Player_queryGmRobotPlayers"
C2S_Player_QueryWallet"#
!C2S_Player_GetLaunchBridgeRecrods"?
C2S_Player_ReapGuideRes
id (Rid
resId (RresId"M
C2S_Player_UnionDonateNft
unionId (RunionId
idList (RidList"O
C2S_Player_UnionTakeBackNft
unionId (RunionId
idList (RidList"Õ
C2S_Player_ResetGOLevel
goType (RgoType
id (Rid
cfgId (RcfgId
op (Rop
level (Rlevel
skillIdx (RskillIdx
skillLv (RskillLv
quality (Rquality"Ä
C2S_Player_GMBuildCreate
cfgId (RcfgId
pos (2.PosTypeRpos
opType (RopType
guideNow (RguideNow"L
C2S_Player_GMBuildBatchCreate+
builds (2.EditorCreateBuildsRbuilds"a
+C2S_Player_QueryUnionStarmapCampaignReports
pageNo (RpageNo
pageSize (RpageSize"&
$C2S_Player_StarmapMatchPersonalGrids";
#C2S_Player_StarmapTransferBeginGrid
cfgId (RcfgId"#
!C2S_Player_QueryJoinableUnionList"2
C2S_Player_ReceiveMintItem
index (Rindex"
C2S_Player_QueryUnionRes"
)C2S_Player_QueryUnionStarmapBattleReports

campaignId (R
campaignId
pageNo (RpageNo
pageSize (RpageSize"
C2S_Player_QueryUnionSoliders"N
,C2S_Player_QueryStarmapCampaignPlyStatistics

campaignId (R
campaignId"
C2S_Player_QueryUnionBuilds""
 C2S_Player_QueryStarmapHyJackpot"
C2S_Player_QueryUnionNfts"
C2S_Player_GetMints"
C2S_Player_QueryUnionMembers"^
C2S_Player_AddMint
nftId1 (RnftId1
nftId2 (RnftId2
nftType (RnftType"
C2S_Player_QueryUnionTechs"5
C2S_Player_PVEScoutFoundation
cfgId (RcfgId"6
C2S_Player_PVERecvDailyRewards
cfgId (RcfgId"x
C2S_Player_GOChangeSkill
goType (RgoType
id (Rid
skillIdx (RskillIdx
skillId (RskillId"v
C2S_Player_OPLandShipSoldier
id (Rid"
soliderCfgId (RsoliderCfgId"
soliderCount (RsoliderCount"=
C2S_Player_ModifyPlayerLanguage
language (	Rlanguage"D
C2S_Player_OPMoveBuild
id (Rid
pos (2.PosTypeRpos"y
C2S_Player_putBuildListOnGrid
cfgId (RcfgId.
	buildList (2.ToGridBuildInfoR	buildList
from (Rfrom"'
C2S_Player_HeroRepair
id (Rid"*
C2S_Player_WarShipRepair
id (Rid"(
C2S_Player_BuildRepair
id (Rid"l
C2S_Player_PutUnionBuildOnGrid
cfgId (RcfgId
buildId (RbuildId
pos (2.PosTypeRpos"v
C2S_Player_ArmyFormationAdd
armyId (RarmyId
armyName (	RarmyName#
teams (2.ArmyTeamTypeRteams"
C2S_Player_ArmyFormationQuery"8
C2S_Player_ArmyFormationDelete
armyId (RarmyId"è
C2S_Player_ArmyFormationUpdate
armyId (RarmyId
index (Rindex
armyName (	RarmyName#
teams (2.ArmyTeamTypeRteams"è
C2S_Player_EditedArmyFormation
armyId (RarmyId
index (Rindex
armyName (	RarmyName#
teams (2.ArmyTeamTypeRteams"<
C2S_Player_automaticForces

autoStatus (R
autoStatus"h
C2S_Player_UpdateSanctuaryHero
buildId (RbuildId
index (Rindex
heroId (RheroId"@
C2S_Player_IsUseGuidArmy$
isUseGuidArmy (RisUseGuidArmy"O
C2S_Player_AddGuildReserveCount,
guildReserveCount (RguildReserveCount"
C2S_Player_StarmapMinimap"%
#C2S_Player_GetUnionFavoriteGridList"5
C2S_Player_GetCumulativeFunds
cfgId (RcfgId"<
C2S_Player_GetRechargeReward
	giftCfgId (R	giftCfgId"7
C2S_Player_PayChannelInfo
platform (	Rplatform"1
C2S_Player_BuyMoreBuilder
cfgId (RcfgId"@
C2S_Player_DonateDaoItem
id (Rid
count (Rcount"5
C2S_Player_GetDailyReward
weekDay (RweekDay"+
C2S_Player_BuyGoods
index (Rindex"
C2S_Player_FreshShoppingMall",
C2S_Player_UseGiftCode
code (	Rcode"
C2S_Player_CleanAllArmy"E
C2S_Player_AutoPushStatus_Del$
autoPushCfgId (RautoPushCfgId"4
C2S_Player_DismantleHero
heroIds (RheroIds"R
C2S_Player_GetLoginActReward
day (Rday 
isAdvReward (RisAdvReward";
C2S_Player_OneKeyFillUpSoliders
armyIds (RarmyIds"1
C2S_Player_freshBuild
buildId (RbuildId"-
C2S_Player_UnlockLoginAdv
day (Rday"=
C2S_Player_DismantleWarShip

warShipIds (R
warShipIds"C
C2S_Player_SellEntity
idList (RidList
type (Rtype"Q
C2S_Player_DismantleSkillCard0
skillCardData (2
.SkillCardRskillCardData"<
C2S_Player_SellItem%
itemData (2	.ItemDataRitemData"U
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
.BuildTypeRbuild"æ
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
resData (2.ResTypeRresData"t
S2C_Player_ResChange
resCfgId (RresCfgId
count (Rcount
change (Rchange
bind (Rbind"o
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
getMit (RgetMit"R
S2C_Player_HeroData%
heroData (2	.HeroTypeRheroData
useId (RuseId"3
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
item (2.ItemRitem"y
S2C_Player_DrawCardData
op_type (RopType)
cardData (2.DrawCardInfoRcardData
discount (Rdiscount"Q
S2C_Player_DrawCardResult
cfgIds (RcfgIds
	newCfgIds (R	newCfgIds"^
S2C_Player_WarShipData.
warShipData (2.WarShipTypeRwarShipData
useId (RuseId"?
S2C_Player_WarShipAdd&
warShip (2.WarShipTypeRwarShip"'
S2C_Player_WarShipDel
id (Rid"B
S2C_Player_WarShipUpdate&
warShip (2.WarShipTypeRwarShip"=
S2C_Player_ItemComposeAdd 
item (2.ComposeItemRitem"D
S2C_Player_DrawCardRecords&
records (2.DrawCardRecRrecords"l
BoatResType
boatId (RboatId(

currencies (2.ResTypeR
currencies
items (2.ItemRitems";
#S2C_Player_StarmapTransferBeginGrid
cfgId (RcfgId"=
S2C_Player_StarmapMinimap 
list (2.StarmapMiniRlist"@
S2C_Player_UseItem
cfgId (RcfgId
count (Rcount"≈
!S2C_Player_GetMyStarmapRewardList+

gridReward (2.GridRewardR
gridReward?
gridRewardRecords (2.GridRewardRecordRgridRewardRecords2
matchRewards (2.MyMatchRewardRmatchRewards"M
S2C_Player_DrawMyStarmapReward+

gridReward (2.GridRewardR
gridReward"U
!S2C_Player_StarmapCampaignReports0
reports (2.StarmapCampaignReportRreports"q
&S2C_Player_StarmapCampaignReportUpdate
op_type (RopType.
report (2.StarmapCampaignReportRreport"Z
&S2C_Player_UnionStarmapCampaignReports0
reports (2.StarmapCampaignReportRreports"©
S2C_Player_SearchPlayer
playerId (RplayerId

playerName (	R
playerName

fightPower (R
fightPower
	baseLevel (R	baseLevel
chain (Rchain"v
+S2C_Player_UnionStarmapCampaignReportUpdate
op_type (RopType.
report (2.StarmapCampaignReportRreport"Q
S2C_Player_StarmapBattleReports.
reports (2.StarmapBattleReportRreports"[
S2C_Player_ReserveArmyUpdate
op_type (RopType"
armys (2.ReserveArmyRarmys"m
$S2C_Player_StarmapBattleReportUpdate
op_type (RopType,
report (2.StarmapBattleReportRreport"e
S2C_Player_FightReports*
reports (2.FightReportTypeRreports

battleType (R
battleType"E
S2C_Player_FightReportAdd(
report (2.FightReportTypeRreport"B
S2C_Player_PickBoatResNotify"
boats (2.BoatResTypeRboats"Å
S2C_Player_StartBattle
battleId (RbattleId+

battleInfo (2.BattleInfoR
battleInfo

battleType (R
battleType"“
S2C_Player_EndBattle
battleId (RbattleId
starCoin (RstarCoin
ice (Rice
carboxyl (Rcarboxyl
titanium (Rtitanium
gas (Rgas
badge (Rbadge
result (Rresult.
soliders	 (2.SoliderBattleTypeRsoliders

battleType
 (R
battleType(
endInfo (2.BattleEndInfoRendInfo"\
S2C_Player_Exchange_Rate&
rates (2.ResExchangeRateRrates
tipType (RtipType"T
"S2C_Player_EndBattle_NotCompletely
battleId (RbattleId
code (Rcode"V
$S2C_Player_UnionStarmapBattleReports.
reports (2.StarmapBattleReportRreports"r
)S2C_Player_UnionStarmapBattleReportUpdate
op_type (RopType,
report (2.StarmapBattleReportRreport"Ç
'S2C_Player_StarmapCampaignPlyStatistics

campaignId (R
campaignId7
reports (2.StarmapCampaignPlyStatisticsRreports"7
S2C_Player_StarmapHyJackpot
jackpot (Rjackpot"H
S2C_Player_FightReportUpdate(
report (2.FightReportTypeRreport"c
S2C_Player_FirstGetGridRank
list (2	.RankTypeRlist%
selfRank (2	.RankTypeRselfRank"í
S2C_Player_Rank_Info
rankType (RrankType
version (Rversion
rank (2	.RankTypeRrank%
selfRank (2	.RankTypeRselfRank"5
S2C_Player_UploadBattle
battleId (RbattleId"Ï
S2C_Player_LookBattlePlayBack
battleId (RbattleId+

battleInfo (2.BattleInfoR
battleInfo 
signinPosId (RsigninPosId
bVersion (	RbVersion*
operates (2.BattleOperateRoperates
endStep (RendStep"õ
S2C_Player_PvpData
	battleNum (R	battleNum 
battleTotal (RbattleTotal 
banLessTime (RbanLessTime"
banTotalTime (RbanTotalTime'
enemies (2.PvpEnemyTypeRenemies.
battleNumPurchased (RbattleNumPurchased
jackpot (Rjackpot
myreward (Rmyreward
myScore	 (RmyScore"
refreshCount
 (RrefreshCount
season (Rseason
lifeTime (RlifeTime"ˇ
S2C_Player_FoundationData

playerName (	R
playerName
playerId (RplayerId 
playerLevel (RplayerLevel 
playerScore (RplayerScore
isOnline (RisOnline"
builds (2
.BuildTypeRbuilds"
resInfo (2.ResTypeRresInfo"B
S2C_Player_SystemNotice'
notices (2.SystemNoticeRnotices"N
S2C_Player_AchievementData0
achievements (2.AchievementRachievements"N
S2C_Player_AchievementUpdate.
achievement (2.AchievementRachievement"O
S2C_Player_AchievementReplace.
achievement (2.AchievementRachievement"\
S2C_Player_VipData
mit (Rmit
vipLevel (RvipLevel
endTime (RendTime"<
S2C_Player_GetMyGirdList 
grids (2
.GridBriefRgrids"t
 S2C_Player_GetMyFavoriteGridList"
grids (2.StarmapMiniRgrids,

unionGrids (2.StarmapMiniR
unionGrids"4
S2C_Player_MyFavoriteGridDel
cfgId (RcfgId",
S2C_Player_MyGridDel
cfgId (RcfgId"6
S2C_Player_MyGridAdd
grid (2
.GridBriefRgrid";
S2C_Player_GetMyOwnNftTowers
items (2.ItemRitems"<
S2C_Player_MyOwnNftTowerLevelUp
item (2.ItemRitem">
S2C_Player_MyUnionInfo$
union (2.UnionBaseTypeRunion"F
S2C_Player_JoinableUnionList&
unions (2.UnionJoinTypeRunions"1
S2C_Player_UnionJob
unionJob (RunionJob"Q
S2C_Player_UnionMemberDel
unionId (RunionId
playerId (RplayerId"D
S2C_Player_UnionApplyList'
applys (2.UnionApplyTypeRapplys"F
S2C_Player_SearchUnionResult&
unions (2.UnionBaseTypeRunions"p
S2C_Player_DonateDaoItem
exp (Rexp

unionLevel (R
unionLevel"
contriDegree (RcontriDegree"H
S2C_Player_UnionInviteList*
invites (2.UnionInviteTypeRinvites"/
S2C_Player_UnionGridDel
cfgId (RcfgId"m
S2C_Player_ChatMsgs
msgs (2.ChatMsgRmsgs
sMsgId (RsMsgId 
channelType (RchannelType"
S2C_Player_MitNotEnoughTips"°
S2C_Player_TaskUpdate
op_type (RopType
	chapterId (R	chapterId*
completeChapters (RcompleteChapters3
completeTasks (2.CompleteTaskRcompleteTasks-
taskTargets (2.TaskTargetRtaskTargets

activation (R
activation$
activationBox (RactivationBox&
dailyResetTick (RdailyResetTick"
chapterState	 (RchapterState/
dailyTargets
 (2.TaskTargetRdailyTargets"8
S2C_Player_TaskReplace
task (2
.DailyTaskRtask"u
S2C_Player_TaskData 
tasks (2
.DailyTaskRtasks
lessTime (RlessTime 
playerLevel (RplayerLevel"’
S2C_Player_PlayerInfo
	canInvite (R	canInvite
canVisit (RcanVisit
pid (Rpid
badge (Rbadge
name (	Rname
headIcon (	RheadIcon
text (	Rtext
unionId (RunionId
	unionName	 (	R	unionName
	unionFlag
 (R	unionFlag$
modifyNameNum (RmodifyNameNum
vipLevel (RvipLevel
race (Rrace

inviteCode (	R
inviteCode.
modifyNameLessTick (RmodifyNameLessTick
language (	Rlanguage"|
"S2C_Player_SoliderForgeLevelUpdate>
forgeLevelInfo (2.SoliderForgeLevelTypeRforgeLevelInfo
result (Rresult"d
 S2C_Player_SoliderForgeLevelData@
forgeLevelInfos (2.SoliderForgeLevelTypeRforgeLevelInfos"E
S2C_Player_BuildQueueData(
buildQueueCount (RbuildQueueCount"f
S2C_Player_PvpScoutFoundation'
info (2.FoundationInfoTypeRinfo
	canAttack (R	canAttack"I
S2C_Player_ChatVisitFoundation'
info (2.FoundationInfoTypeRinfo"J
S2C_Player_UnionVisitFoundation'
info (2.FoundationInfoTypeRinfo"=
S2C_Player_UnionTechs$
techs (2.UnionTechTypeRtechs"∑
S2C_Player_ResAnimation
resCfgId (RresCfgId
count (Rcount
change (Rchange
buildId (RbuildId 
animationId (RanimationId
fromId (RfromId"X
S2C_Player_MailUpdate
op_type (RopType&
mailList (2
.MailBriefRmailList"6
S2C_Player_MailDetail
mail (2	.MailTypeRmail";
S2C_Player_NextGuides"
guides (2
.GuideInfoRguides"Ì
S2C_Player_EnterStarmap 
grids (2
.GridBriefRgrids 
beginGridId (RbeginGridId
season (Rseason
lifeTime (RlifeTime
score (Rscore$
unionFavGrids (RunionFavGrids

myFavGrids (R
myFavGrids">
S2C_Player_ScoutStarmapGrid
grid (2.GridDetailRgrid"S
S2C_Player_buildOnGridAdd
cfgId (RcfgId 
build (2
.BuildTypeRbuild"j
S2C_Player_buildOnGridUpdate
cfgId (RcfgId
buildId (RbuildId
pos (2.PosTypeRpos"K
S2C_Player_buildOnGridDel
cfgId (RcfgId
buildId (RbuildId"?
S2C_Player_starmapGridUpdate
grid (2.GridDetailRgrid"3
S2C_Player_UseWarShipUpdate
useId (RuseId"0
S2C_Player_UseHeroUpdate
useId (RuseId"Å
S2C_Player_PvpGmRobotPlayers'
enemies (2.PvpEnemyTypeRenemies
	pveWinIds (R	pveWinIds
pveScore (RpveScore"Q
S2C_Player_Wallet"
ownerAddress (	RownerAddress
chainId (RchainId"@
S2C_Player_ChainBridgeInfo"
chains (2
.ChainTypeRchains"u
S2C_Player_sendPvpBackGroundCfg#
stage (2.PvpStageInfoRstage-
reward (2.PvpRankMitRewardInfoRreward"R
!S2C_Player_GetLaunchBridgeRecrods-
records (2.LaunchBridgeRecordRrecords"{
S2C_Player_LaunchBridgeFees$
fees (2.LaunchBridgeFeeRfees
lastTick (RlastTick
needShip (RneedShip"S
 S2C_Player_pvpMatchRewardRecords/
records (2.PvpMatchRewardRecordRrecords"N
S2C_Player_pvpMatchRewardTips-
rewards (2.PvpMatchRewardTipsRrewards"
C2S_Player_DrawChapterTask"5
C2S_Player_DrawTaskActivation
cfgId (RcfgId"e
S2C_Player_UnionStartEditArmy 
editArmyPid (ReditArmyPid"
editArmyTick (ReditArmyTick"z
S2C_Player_StarmapBattleCancel

campaignId (R
campaignId
	gridCfgId (R	gridCfgId
armyType (RarmyType"É
S2C_Player_SubscribeGrids 
grids (2
.GridBriefRgrids$
unionFavGrids (RunionFavGrids

myFavGrids (R
myFavGrids"à
S2C_Player_StarmapRankList
rankType (RrankType
version (Rversion,
rankList (2.StarmapRankTypeRrankList,
selfRank (2.StarmapRankTypeRselfRank

matchCfgId (R
matchCfgId
chainId (RchainId

shareRatio (R
shareRatio"i
!S2C_Player_StarmapMatchUnionGrids"
list (2.GridShareTimeRlist 
personScore (RpersonScore"J
$S2C_Player_StarmapMatchPersonalGrids"
list (2.GridShareTimeRlist"L
S2C_Player_MintsUpdate
op_type (RopType
list (2.MintRlist"7
S2C_Player_StarmapScore
	starScore (R	starScore"ï
S2C_Player_StarmapGridCount

pGridCount (R
pGridCount

uGridCount (R
uGridCount
pGridMax (RpGridMax
uGridMax (RuGridMax"F
S2C_Player_MyFavoriteGridAdd
cfgId (RcfgId
tag (	Rtag"I
S2C_Player_UnionFavoriteGridAdd
cfgId (RcfgId
tag (	Rtag"7
S2C_Player_UnionFavoriteGridDel
cfgId (RcfgId"I
#S2C_Player_GetUnionFavoriteGridList"
grids (2.StarmapMiniRgrids"@
S2C_Player_UnionBaseInfo$
union (2.UnionBaseTypeRunion"±
S2C_Player_UnionRes
starCoin (RstarCoin
ice (Rice
titanium (Rtitanium
gas (Rgas
carboxyl (Rcarboxyl"
contriDegree (RcontriDegree"I
S2C_Player_UnionSoliders-
soliders (2.UnionSoliderTypeRsoliders"A
S2C_Player_UnionBuilds'
builds (2.UnionBuildTypeRbuilds"Z
S2C_Player_UnionNfts
items (2.NFTTypeRitems"
contriDegree (RcontriDegree"E
S2C_Player_UnionMembers*
members (2.UnionMemberTypeRmembers"¶
S2C_Player_PveInfo
pass (2.PVEPassRpass"
dailyRewards (RdailyRewards&
dailyResetTick (RdailyResetTick&
dayPass (2.PVEPassStarRdayPass"f
S2C_Player_PveScoutFoundation'
info (2.FoundationInfoTypeRinfo
	canAttack (R	canAttack">
S2C_Player_AutoPushStatus!
data (2.AutoPushTypeRdata"[
S2C_Player_ArmysQuery

autoStatus (R
autoStatus"
data (2.ArmyFormationRdata"™
 S2C_Player_UnionSelfBattleResult 
battleTotal (RbattleTotal"
reserveTotal (RreserveTotal"
battleResult (RbattleResult
	gridCfgId (R	gridCfgId"Q
S2C_Player_SanctuaryHeros
buildId (RbuildId
data (2.HerosRdata"s
S2C_Player_GuildReserveArmy&
isUseGuildArmy (RisUseGuildArmy,
guildReserveCount (RguildReserveCount"p
S2C_Player_CumulativeFunds
funds100 (Rfunds100
funds300 (Rfunds300
info (2.FundsRinfo"w
S2C_Player_Recharge
firstRec (RfirstRec 
rechargeVal (RrechargeVal"
rechargeStat (RrechargeStat"6
S2C_Player_DoubelRecharge
data (2.ProsRdata"'
S2C_Player_MoonCard
day (Rday"/
S2C_Player_PayChannelInfo
info (	Rinfo"*
S2C_Player_MoreBuilder
day (Rday"Q
S2C_Player_DailyCheck
data (2.DailyRdata
	flushTime (R	flushTime"1
S2C_Player_DailyGift
data (2.GiftRdata"o
S2C_Player_ShoppingMall
	overTimes (R	overTimes
data (2.GoodsRdata
freshNum (RfreshNum"r
S2C_Player_UseGiftCode
code (	Rcode
ret (Rret
cfgId (RcfgId
	itemCfgId (R	itemCfgId"Q
S2C_Player_DismantleReward
result (Rresult
items (2.ItemRitems"r
S2C_Player_TipNote
tipType (RtipType"
resInfo (2.ResTypeRresInfo
items (2.TipItemRitems"Z
S2C_Player_LoginActivityInfo
endTime (RendTime 
data (2.LoginRewardRdata"L
"S2C_Player_Starmap_Exclusive_Grids&
data (2.GridExclusiveTypeRdata"8
S2C_Player_StarPack!
data (2.StarPackInfoRdata"O
S2C_Player_Url_Config
baseUrl (	RbaseUrl
	marketUrl (	R	marketUrlbproto3