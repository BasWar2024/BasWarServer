#!/bin/sh
GGROOT=../../..

protoc -oall.pb *.proto
python genProtoId.py --output=message_define.lua common.proto *.proto

cp all.pb message_define.lua $GGROOT/server/src/etc/proto/protobuf/
cp all.pb message_define.lua $GGROOT/client/proto/protobuf/
cp all.pb message_define.lua $GGROOT/robot/proto/protobuf/
