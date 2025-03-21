/**
 *
 * Copyright (C) 2015 by David Lin
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALING IN
 * THE SOFTWARE.
 *
 */

#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>

#include "ikcp.h"

#if LUA_VERSION_NUM < 502
    #define LUA_RIDX_MAINTHREAD 1
#endif

#ifndef RECV_BUFFER_LEN
#define RECV_BUFFER_LEN 4*1024*1024
#endif

#define check_kcp(L, idx)\
    *(ikcpcb**)luaL_checkudata(L, idx, "kcp_meta")

#define check_buf(L, idx)\
    (char*)luaL_checkudata(L, idx, "recv_buffer")

struct Callback {
    int log_handle;
    int handle;
    lua_State* L;
};

static void kcp_writelog_callback(const char *log,ikcpcb *kcp,void *user) {
    if (user == NULL)
        return;
    struct Callback* c = (struct Callback*)user;
    lua_State* L = c -> L;
    int log_handle = c -> log_handle;
    if (log_handle == LUA_NOREF)
        return;
    lua_rawgeti(L, LUA_REGISTRYINDEX, log_handle);
    lua_pushstring(L,log);
    lua_pcall(L, 1, 0,0);
}

static int kcp_output_callback(const char *buf, int len, ikcpcb *kcp, void *arg) {
    struct Callback* c = (struct Callback*)arg;
    lua_State* L = c -> L;
    int handle = c -> handle;
    lua_rawgeti(L, LUA_REGISTRYINDEX, handle);
    lua_pushlstring(L, buf, len);
    lua_pcall(L, 1, 0,0);
    return 0;
}

static int kcp_gc(lua_State* L) {
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        return 0;
    }
    if (kcp->user != NULL) {
        struct Callback* c = (struct Callback*)kcp -> user;
        int handle = c -> handle;
        int log_handle = c -> log_handle;
        if (handle != LUA_NOREF) {
            luaL_unref(L, LUA_REGISTRYINDEX, handle);
        }
        if (log_handle != LUA_NOREF) {
            luaL_unref(L, LUA_REGISTRYINDEX, log_handle);
        }
        free(c);
        kcp->user = NULL;
    }
    ikcp_release(kcp);
    kcp = NULL;
    return 0;
}

static int lkcp_create(lua_State* L){
    int log_handle = LUA_NOREF;
    int n = lua_gettop(L);
    assert(n <= 3);
    if (n == 3) {
        if (lua_isnil(L,3)) {
            lua_pop(L,1);
        } else {
            log_handle = luaL_ref(L,LUA_REGISTRYINDEX);
        }
    }
    int handle = luaL_ref(L, LUA_REGISTRYINDEX);
    int32_t conv = luaL_checkinteger(L, 1);

    lua_rawgeti(L,LUA_REGISTRYINDEX,LUA_RIDX_MAINTHREAD);
    lua_State *mL = lua_tothread(L,-1);
    lua_pop(L,1);

    struct Callback* c = malloc(sizeof(struct Callback));
    memset(c, 0, sizeof(struct Callback));
    c -> log_handle = log_handle;
    c -> handle = handle;
    c -> L = mL;

    ikcpcb* kcp = ikcp_create(conv, (void*)c);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: fail to create kcp");
        return 2;
    }
    kcp->output = kcp_output_callback;
    kcp->writelog = kcp_writelog_callback;

    *(ikcpcb**)lua_newuserdata(L, sizeof(void*)) = kcp;
    luaL_getmetatable(L, "kcp_meta");
    lua_setmetatable(L, -2);
    return 1;
}

static int lkcp_recv(lua_State* L){
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    lua_getfield(L, LUA_REGISTRYINDEX, "kcp_lua_recv_buffer");
    char* buf = check_buf(L, -1);
    lua_pop(L, 1);

    int32_t hr = ikcp_recv(kcp, buf, RECV_BUFFER_LEN);
    if (hr <= 0) {
        lua_pushinteger(L, hr);
        return 1;
    }

    lua_pushinteger(L, hr);
    lua_pushlstring(L, (const char *)buf, hr);

    return 2;
}

static int lkcp_send(lua_State* L){
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    size_t size;
    const char *data = luaL_checklstring(L, 2, &size);
    int32_t hr = ikcp_send(kcp, data, size);
    
    lua_pushinteger(L, hr);
    return 1;
}

static int lkcp_update(lua_State* L){
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    int32_t current = luaL_checkinteger(L, 2);
    ikcp_update(kcp, current);
    return 0;
}

static int lkcp_check(lua_State* L){
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    int32_t current = luaL_checkinteger(L, 2);
    int32_t hr = ikcp_check(kcp, current);
    lua_pushinteger(L, hr);
    return 1;
}

static int lkcp_input(lua_State* L){
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    size_t size;
    const char *data = luaL_checklstring(L, 2, &size);
    int32_t hr = ikcp_input(kcp, data, size);
    
    lua_pushinteger(L, hr);
    return 1;
}

static int lkcp_flush(lua_State* L){
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    ikcp_flush(kcp);
    return 0;
}

static int lkcp_wndsize(lua_State* L){
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    int32_t sndwnd = luaL_checkinteger(L, 2);
    int32_t rcvwnd = luaL_checkinteger(L, 3);
    ikcp_wndsize(kcp, sndwnd, rcvwnd);
    return 0;
}

static int lkcp_nodelay(lua_State* L){
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    int32_t nodelay = luaL_checkinteger(L, 2);
    int32_t interval = luaL_checkinteger(L, 3);
    int32_t resend = luaL_checkinteger(L, 4);
    int32_t nc = luaL_checkinteger(L, 5);
    int32_t hr = ikcp_nodelay(kcp, nodelay, interval, resend, nc);
    lua_pushinteger(L, hr);
    return 1;
}

static int lkcp_peeksize(lua_State* L) {
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    lua_pushinteger(L,ikcp_peeksize(kcp));
    return 1;
}

static int lkcp_setmtu(lua_State* L) {
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    int32_t mtu = luaL_checkinteger(L,2);
    int32_t ret = ikcp_setmtu(kcp,mtu);
    lua_pushinteger(L,ret);
    return 1;
}

static int lkcp_waitsnd(lua_State* L) {
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    lua_pushinteger(L,ikcp_waitsnd(kcp));
    return 1;
}

static int lkcp_logmask(lua_State* L) {
    ikcpcb* kcp = check_kcp(L, 1);
    if (kcp == NULL) {
        lua_pushnil(L);
        lua_pushstring(L, "error: kcp not args");
        return 2;
    }
    int32_t logmask = luaL_checkinteger(L,2);
    kcp->logmask = logmask;
    return 0;
}

static int lkcp_getconv(lua_State* L) {
    if (lua_isnoneornil(L,1)) {
        return 0;
    }
    size_t size;
    const char *buffer = luaL_checklstring(L, 1, &size);
    lua_pushinteger(L,ikcp_getconv(buffer));
    return 1;
}


static const struct luaL_Reg lkcp_methods [] = {
    { "lkcp_recv" , lkcp_recv },
    { "lkcp_send" , lkcp_send },
    { "lkcp_update" , lkcp_update },
    { "lkcp_check" , lkcp_check },
    { "lkcp_input" , lkcp_input },
    { "lkcp_flush" , lkcp_flush },
    { "lkcp_wndsize" , lkcp_wndsize },
    { "lkcp_nodelay" , lkcp_nodelay },
    { "lkcp_peeksize",lkcp_peeksize },
    { "lkcp_setmtu",lkcp_setmtu },
    { "lkcp_waitsnd",lkcp_waitsnd },
    { "lkcp_logmask",lkcp_logmask },
    {NULL, NULL},
};

static const struct luaL_Reg l_methods[] = {
    { "lkcp_create" , lkcp_create },
    { "lkcp_getconv",lkcp_getconv },
    {NULL, NULL},
};

int luaopen_lkcp(lua_State* L) {
#ifdef luaL_checkversion
    luaL_checkversion(L);
#endif

    luaL_newmetatable(L, "kcp_meta");

    lua_newtable(L);
    luaL_setfuncs(L, lkcp_methods, 0);
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, kcp_gc);
    lua_setfield(L, -2, "__gc");

    luaL_newmetatable(L, "recv_buffer");

    char* global_recv_buffer = lua_newuserdata(L, sizeof(char)*RECV_BUFFER_LEN);
    memset(global_recv_buffer, 0, sizeof(char)*RECV_BUFFER_LEN);
    luaL_getmetatable(L, "recv_buffer");
    lua_setmetatable(L, -2);
    lua_setfield(L, LUA_REGISTRYINDEX, "kcp_lua_recv_buffer");

    luaL_newlib(L, l_methods);

    return 1;
}
