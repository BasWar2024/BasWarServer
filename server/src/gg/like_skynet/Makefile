include platform.mk

SKYNET_PATH ?= ../skynet
LUALIB_PATH ?= lualib
LUACLIB_PATH ?= luaclib
SERVICE_PATH ?= service
CSERVICE_PATH ?= cservice

LUA_INC ?= $(SKYNET_PATH)/3rd/lua
LUA_LIB ?= $(SKYNET_PATH)/3rd/lua/liblua.a
CFLAGS = -g -O2 -Wall -I$(LUA_INC) $(LUA_LIB) $(MYFLAGS)
#CFLAGS = -g -O0 -Wall -I$(LUA_INC) $(LUA_LIB) $(MYFLAGS)
OPENSSL_LIBS	?= $(shell pkg-config openssl --static --libs)

$(LUALIB_PATH):
	mkdir -p $(LUALIB_PATH)

$(LUACLIB_PATH):
	mkdir -p $(LUACLIB_PATH)

$(SERVICE_PATH):
	mkdir -p $(SERVICE_PATH)

$(CSERVICE_PATH):
	mkdir -p $(CSERVICE_PATH)

# skynet_package
$(CSERVICE_PATH)/package.so : 3rd/skynet_package/service_package.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -I$(SKYNET_PATH)/skynet-src

$(LUALIB_PATH)/socket_proxy.lua: 3rd/skynet_package/lualib/socket_proxy.lua
	cp $^ $@

$(SERVICE_PATH)/socket_proxyd.lua: 3rd/skynet_package/service/socket_proxyd.lua
	cp $^ $@

# lua-websocket
$(LUALIB_PATH)/websocket:
	mkdir -p $(LUALIB_PATH)/websocket
	cp 3rd/lua-websocket/lib/websocket/* $(LUALIB_PATH)/websocket

# lua-cjson
$(LUACLIB_PATH)/cjson.so : 3rd/lua-cjson/strbuf.c 3rd/lua-cjson/fpconv.c 3rd/lua-cjson/lua_cjson.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

# crab
$(LUACLIB_PATH)/crab.so : 3rd/crab/lua-crab.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

$(LUACLIB_PATH)/utf8.so : 3rd/crab/lua-utf8.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

# pb
$(LUACLIB_PATH)/pb.so : 3rd/lua-protobuf/pb.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

# lkcp
$(LUACLIB_PATH)/lkcp.so : 3rd/kcp/lkcp.c 3rd/kcp/ikcp.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

# lfs
$(LUACLIB_PATH)/lfs.so : 3rd/lfs/src/lfs.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

# lutil
$(LUACLIB_PATH)/lutil.so : 3rd/util/lutil.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

# lua-webclient
$(LUACLIB_PATH)/webclient.so : 3rd/lua-webclient/webclient.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -lcurl

$(SERVICE_PATH)/webclient.lua : 3rd/lua-webclient/webclient.lua
	cp $^ $@

# aes128
$(LUACLIB_PATH)/aes128.so : 3rd/lua-aes/aes.c 3rd/lua-aes/laes.c
	$(CC) $(CFLAGS) $(SHARED) -DAES128=1 $^ -o $@

# aes192
$(LUACLIB_PATH)/aes192.so : 3rd/lua-aes/aes.c 3rd/lua-aes/laes.c
	$(CC) $(CFLAGS) $(SHARED) -DAES192=1 $^ -o $@

# aes256
$(LUACLIB_PATH)/aes256.so : 3rd/lua-aes/aes.c 3rd/lua-aes/laes.c
	$(CC) $(CFLAGS) $(SHARED) -DAES256=1 $^ -o $@

# lua-snowflake
$(LUACLIB_PATH)/snowflake.so : 3rd/lua-snowflake/snowflake.c 3rd/lua-snowflake/lsnowflake.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

$(LUALIB_PATH)/snowflake.lua: 3rd/lua-snowflake/snowflake.lua
	cp $^ $@

# codec
$(LUACLIB_PATH)/codec.so : 3rd/lua-codec/codec.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -I/usr/local/include -lcrypto

# zlib
$(LUACLIB_PATH)/zlib.so : 3rd/lua-zlib/lua_zlib.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -I/usr/local/include -lz -lm

# i18n
$(LUACLIB_PATH)/i18n.so : 3rd/lua-i18n/lua-i18n.c 3rd/lua-i18n/i18n.c
	$(CC) $(CFLAGS) $(SHARED) -std=c99 $^ -o $@ -I3rd/lua-i18n

$(LUALIB_PATH)/i18n.lua : 3rd/lua-i18n/i18n.lua
	cp $^ $@

# traceback
$(LUACLIB_PATH)/traceback.so : 3rd/lua-traceback/ltraceback.c
	$(CC) $(CFLAGS) $(SHARED) -std=c99 $^ -o $@ -I3rd/lua-traceback

# bytestream
$(LUACLIB_PATH)/bytestream.so : 3rd/lua-bytestream/lByteStream.cpp 3rd/lua-bytestream/ByteStream.cpp
	g++ -std=c++11 -lstdc++ $(CFLAGS) $(SHARED) $^ -o $@ -I3rd/lua-bytestream

# snapshot
$(LUACLIB_PATH)/snapshot.so : 3rd/lua-snapshot/lua-snapshot.c
	$(CC) $(CFLAGS) $(SHARED) -std=c99 $^ -o $@ -I3rd/lua-snapshot

$(LUALIB_PATH)/snapshot_utils.lua : 3rd/lua-snapshot/snapshot_utils.lua
	cp $^ $@

# profile
$(LUACLIB_PATH)/profile.so : 3rd/lua-profile/profile.c 3rd/lua-profile/imap.c
	$(CC) $(CFLAGS) $(SHARED) -std=c99 $^ -o $@ -I3rd/lua-profile

$(LUALIB_PATH)/profile.lua : 3rd/lua-profile/profile.lua
	cp $^ $@

# skiplist.so
$(LUACLIB_PATH)/skiplist.so : 3rd/lua-zset/skiplist.c 3rd/lua-zset/lua-skiplist.c
	$(CC) $(CFLAGS) $(SHARED) -std=c99 $^ -o $@ -I3rd/lua-zset

$(LUALIB_PATH)/zset.lua : 3rd/lua-zset/zset.lua
	cp $^ $@

# random.so
$(LUACLIB_PATH)/random.so : 3rd/lua-random/lua-random.c 3rd/lua-random/random.c
	$(CC) $(CFLAGS) $(SHARED) -std=c99 $^ -o $@ -I3rd/lua-random

# map
$(LUACLIB_PATH)/map.so : 3rd/Map/lua-bind/lMap.cpp 3rd/Map/src/Map.cpp 3rd/Map/src/AOI.cpp \
        3rd/Map/src/ByteStream.cpp 3rd/Map/src/Astar.cpp 3rd/Map/src/Collision.cpp \
        3rd/Map/src/Move.cpp 3rd/Map/src/snowflake.cpp \
        3rd/Map/src/math2d.cpp 3rd/Map/src/mathc.cpp 3rd/Map/src/imap.cpp 3rd/Map/src/random.cpp \
        3rd/Map/src/RandomMap.cpp
	g++ -std=c++11 -lstdc++ $(CFLAGS) $(SHARED) $^ -o $@ -I3rd/Map/src -DAXIS_Z_AS_Y -DFIND_PATH_MAX_LOOP_CNT=2000 -DMAX_PATH_LENGTH=32 -DDEBUG

LUALIB = socket_proxy.lua websocket snowflake.lua i18n.lua snapshot_utils.lua \
    profile.lua zset.lua
LUACLIB = cjson.so crab.so utf8.so pb.so lkcp.so lfs.so lutil.so webclient.so \
    snowflake.so codec.so zlib.so i18n.so traceback.so bytestream.so snapshot.so \
    profile.so skiplist.so map.so random.so
SERVICE = socket_proxyd.lua webclient.lua
CSERVICE = package.so

all : $(LUALIB_PATH) $(LUACLIB_PATH) $(SERVICE_PATH) $(CSERVICE_PATH) \
	$(foreach v, $(LUALIB),$(LUALIB_PATH)/$(v)) \
	$(foreach v, $(LUACLIB),$(LUACLIB_PATH)/$(v)) \
	$(foreach v, $(SERVICE),$(SERVICE_PATH)/$(v)) \
	$(foreach v, $(CSERVICE),$(CSERVICE_PATH)/$(v))

clean :
	rm -rf $(LUALIB_PATH)/*
	rm -rf $(LUACLIB_PATH)/*
	rm -rf $(SERVICE_PATH)/*
	rm -rf $(CSERVICE_PATH)/*

update3rd:
	rm -rf 3rd/crab
	rm -rf 3rd/lfs
	rm -rf 3rd/lua-cjson
	rm -rf 3rd/lua-protobuf
	rm -rf 3rd/skynet_package
	rm -rf 3rd/lua-websocket
	rm -rf 3rd/lua-webclient
	rm -rf 3rd/lua-zlib
	rm -rf 3rd/lua-i18n
	rm -rf 3rd/lua-traceback
	rm -rf 3rd/lua-bytestream
	rm -rf 3rd/lua-profile
	rm -rf 3rd/lua-zset
	-git submodule update --init

.PHONY: all clean update3rd
