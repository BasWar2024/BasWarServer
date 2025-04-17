setlocal enabledelayedexpansion
@echo off
set GGROOT=../../..

set all_proto_filenames=common.proto
for /f %%i in ('dir /b *.proto') do (
	if not %%i==common.proto (
		set all_proto_filenames=!all_proto_filenames! %%i
	)
)
REM echo %all_proto_filenames%

protoc.exe %all_proto_filenames% -o all.pb
python.exe genProtoId.py --output=message_define.lua %all_proto_filenames%

copy /y all.pb "%GGROOT%/server/src/etc/proto/protobuf/"
copy /y message_define.lua "%GGROOT%/server/src/etc/proto/protobuf/"
copy /y all.pb "%GGROOT%/client/proto/protobuf/"
copy /y message_define.lua "%GGROOT%/client/proto/protobuf/"
copy /y all.pb "%GGROOT%/robot/proto/protobuf/"
copy /y message_define.lua "%GGROOT%/robot/proto/protobuf/"

if "%CLIENT_ETC_PATH%" neq "" (
    copy /y all.pb "%CLIENT_ETC_PATH%/proto/protobuf/all.pb.bytes"
    copy /y message_define.lua "%CLIENT_ETC_PATH%/proto/protobuf/message_define.lua.txt"
)

pause