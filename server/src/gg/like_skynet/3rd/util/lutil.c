#include <lua.h>
#include <lauxlib.h>

#include <time.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

#if defined(__APPLE__)
#include <sys/time.h>
#endif

static uint64_t
getms() {
#if !defined(__APPLE__) || defined(AVAILABLE_MAC_OS_X_VERSION_10_12_AND_LATER)
	struct timespec ti;
	clock_gettime(CLOCK_REALTIME, &ti);
	return (uint64_t)(1000 * ti.tv_sec + ti.tv_nsec/1000000);
#else
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return (uint64_t)(1000 * tv.tv_sec + tv.tv_usec/1000);
#endif
}

static int
lgetms(lua_State* L) {
	lua_pushinteger(L,getms());
	return 1;
}

static int
lgetpid(lua_State* L) {
	lua_pushinteger(L,getpid());
	return 1;
}

static int
lgetcwd(lua_State* L) {
	char path[PATH_MAX];
	getcwd(path,PATH_MAX);
	lua_pushstring(L,path);
	return 1;
}

static int
ltable_new(lua_State* L) {
	int narr = luaL_checkinteger(L,1);
	int nrec = luaL_checkinteger(L,2);
	lua_createtable(L,narr,nrec);
	return 1;
}

static int
ltable_copy(lua_State* L) {
	int to = 1;
	int from = 2;
	int keys = from;
	if (lua_gettop(L) >= 3) {
		keys = 3;
	}
	if (keys == from) {
		lua_pushnil(L);
		while(lua_next(L,keys) != 0) {
			lua_pushvalue(L,-2);
			lua_insert(L,-2);
			lua_settable(L,to);
		}
	} else {
		lua_pushnil(L);
		while(lua_next(L,keys) != 0) {
			lua_pop(L,1);
			lua_pushvalue(L,-1);
			lua_pushvalue(L,-1);
			lua_gettable(L,from);
			lua_settable(L,to);
		}
	}
	if (lua_getmetatable(L,from)) {
		lua_pushliteral(L,"__nocopy");
		if (lua_rawget(L,-2) == LUA_TBOOLEAN) {
			if (lua_toboolean(L,-1)) {
				lua_pop(L,1);
				lua_setmetatable(L,to);
			} else {
				lua_pop(L,1);
			}
		} else {
			lua_pop(L,1);
		}
	}
	lua_settop(L,to);
	return 1;
}

static void
_table_deepcopy(lua_State* L,int to,int from) {
	int key;
	int value;
	lua_pushnil(L);
	while(lua_next(L,from) != 0) {
		value = lua_gettop(L);
		key = value - 1;
		if (lua_type(L,value) == LUA_TTABLE) {
			lua_newtable(L);
			_table_deepcopy(L,value+1,value);
		} else {
			lua_pushvalue(L,value);
		}
		if (lua_type(L,key) == LUA_TTABLE) {
			lua_newtable(L);
			_table_deepcopy(L,value+2,key);
		} else {
			lua_pushvalue(L,key);
		}
		lua_insert(L,-2);
		lua_settable(L,to);
		lua_pop(L,1);
	}
	if (lua_getmetatable(L,from)) {
		lua_pushliteral(L,"__nocopy");
		if (lua_rawget(L,-2) == LUA_TBOOLEAN) {
			if (lua_toboolean(L,-1)) {
				lua_pop(L,1);
				lua_setmetatable(L,to);
			} else {
				lua_pop(L,1);
			}
		} else {
			lua_pop(L,1);
		}
	}
	lua_settop(L,to);
}

static int
ltable_deepcopy(lua_State* L) {
	int to = 1;
	int from = 2;
	_table_deepcopy(L,to,from);
	return 1;
}

LUAMOD_API int
luaopen_lutil(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{"getms",lgetms},
		{"getpid",lgetpid},
		{"getcwd",lgetcwd},
		{"table_new",ltable_new},
		{"table_copy",ltable_copy},
		{"table_deepcopy",ltable_deepcopy},
		{NULL,NULL},
	};
	luaL_newlib(L,l);
	return 1;
}