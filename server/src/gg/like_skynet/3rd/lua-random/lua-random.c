/// lua binding
#include "random.h"

#include <lua.h>
#include <lauxlib.h>

static int
lrandom_get(lua_State *L) {
	struct random_t r;
	r.x = lua_tointeger(L, lua_upvalueindex(1));
	uint64_t x = random_get(&r);
	lua_pushinteger(L, r.x);
	lua_replace(L, lua_upvalueindex(1));
	uint64_t low, up;
	const uint64_t mask = (((uint64_t)1 << 50) - 1);	// 50bit
	switch (lua_gettop(L)) {
	case 0:
		// return [0,1)
		x &= mask;
		double r = (double)x / (double)(mask+1);
		lua_pushnumber(L, r);
		return 1;
	case 1:
		// return [1, up]
		low = 1;
		up = luaL_checkinteger(L, 1);
		break;
	case 2:
		// return [low, up]
		low = luaL_checkinteger(L, 1);
		up = luaL_checkinteger(L, 2);
		break;
	default:
		return luaL_error(L, "Only support 0/1/2 parms");
	}
	luaL_argcheck(L, low <= up, 1, "interval is empty");
	luaL_argcheck(L, low >= 0 || up <= LUA_MAXINTEGER + low, 1, "interval too large");

	x %= (up - low) + 1;
	lua_pushinteger(L, x + low);

	return 1;
}

static int
lrandom_init(lua_State *L) {
	lua_Integer seed = luaL_checkinteger(L, 1);
	struct random_t r;
	random_init(&r, seed);
	lua_pushinteger(L, r.x);
	lua_pushcclosure(L, lrandom_get, 1);
	return 1;
}

LUAMOD_API int
luaopen_random(lua_State *L) {
	lua_pushcfunction(L, lrandom_init);
	return 1;
}
