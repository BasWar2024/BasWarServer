

common.proto"|
MessagePackage
cmd (Rcmd
args (Rargs
response (Rresponse
session (Rsession
ud (Rud

login.proto"

DeviceType,
registerLoginType (RregisterLoginType

deviceCode (	R
deviceCode
network (	Rnetwork
wifiName (	RwifiName

deviceType (R
deviceType 
deviceModel (	RdeviceModel
os (	Ros
	channelId (R	channelId
lang	 (	Rlang"
CheckTokenType
token (	Rtoken
account (	Raccount
version (	Rversion
forward (	Rforward#
device (2.DeviceTypeRdevice"
C2S_CreateRole/

checktoken (2.CheckTokenTypeR
checktoken
roleid (Rroleid
account (	Raccount
name (	Rname
heroId (RheroId"X
C2S_EnterGame/

checktoken (2.CheckTokenTypeR
checktoken
roleid (Rroleid"
C2S_ExitGame"#
C2S_CheckName
name (	Rname"
C2S_Ping
str (	Rstr"
RoleType
roleid (Rroleid
name (	Rname
heroId (RheroId
level (Rlevel&
createServerId (	RcreateServerId(
currentServerId (	RcurrentServerId

createTime (R
createTime
account (	Raccount"Z
S2C_CreateRoleFail
status (Rstatus
code (Rcode
message (	Rmessage"6
S2C_CreateRoleSuccess
role (2	.RoleTypeRrole"Y
S2C_EnterGameFail
status (Rstatus
code (Rcode
message (	Rmessage"H
S2C_EnterGameSuccess
account (	Raccount
linkid (Rlinkid"
S2C_ReEnterGame
token (	Rtoken
roleid (Rroleid
go_serverid (	R
goServerid
ip (	Rip
tcp_port (RtcpPort
kcp_port (RkcpPort%
websocket_port (RwebsocketPort""
S2C_Kick
reason (	Rreason"F
S2C_Pong
str (	Rstr
time (Rtime
token (	Rtoken"'
	S2C_Hello
randseed (Rrandseed"M
S2C_NameIsValid
name (	Rname
ok (Rok
errmsg (	Rerrmsg"
S2C_BeReplace
ip (	Rip