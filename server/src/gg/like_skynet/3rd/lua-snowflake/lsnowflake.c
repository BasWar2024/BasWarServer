#include <lua.h>
#include <lauxlib.h>
#include <stdlib.h>
#include <stdint.h>
#include "snowflake.h"

/**
 * UUID
 * @function snowflake.getTimestampByUUID
 * @param uuid int64 ID
 * @return timestamp int ID
 */
static int
lgetTimestampByUUID(lua_State *L) {
    uint64_t i = luaL_checkinteger(L,1);
    uint64_t timestamp = getTimestampByUUID(i);
    lua_pushinteger(L,timestamp);
    return 1;
}

/**
 * UUIDID
 * @function snowflake.getNodeIdByUUID
 * @param uuid int64 ID
 * @return nodeId int ID
 */
static int
lgetNodeIdByUUID(lua_State *L) {
    uint64_t i = luaL_checkinteger(L,1);
    int nodeId = getNodeIdByUUID(i);
    lua_pushinteger(L,nodeId);
    return 1;
}

/**
 * UUIDID
 * @function snowflake.getSequenceByUUID
 * @param uuid int64 ID
 * @return sequence int ID
 */
static int
lgetSequenceByUUID(lua_State *L) {
    uint64_t i = luaL_checkinteger(L,1);
    int sequence = getSequenceByUUID(i);
    lua_pushinteger(L,sequence);
    return 1;
}

/**
 * ,ID,uuid
 * @function snowflake.composeUUID
 * @param timestamp int (:[0,2^41))
 * @param nodeid int ID(:[0,2^10))
 * @param sequence int (:[0,2^12))
 * @return uuid uint64 ID
 */
static int
lcomposeUUID(lua_State *L) {
    uint64_t timestamp = luaL_checkinteger(L,1);
    int nodeid = luaL_checkinteger(L,2);
    int sequence = luaL_checkinteger(L,3);
    uint64_t id = composeUUID(timestamp,nodeid,sequence);
	lua_pushinteger(L, id);
    return 1;
}


/**
 * ID,ID
 * @function snowflake.uuid
 * @param nodeId int ID
 * @return uuid uint64 ID
 */
static int
luuid(lua_State *L) {
    int nodeId = luaL_checkinteger(L,1);
    int* sequence = (int*)lua_touserdata(L,lua_upvalueindex(1));
    uint64_t id = uuid(nodeId,sequence);
	lua_pushinteger(L, id);
    return 1;
}


LUAMOD_API int
luaopen_snowflake_core(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        {"getTimestampByUUID",lgetTimestampByUUID},
        {"getNodeIdByUUID",lgetNodeIdByUUID},
        {"getSequenceByUUID",lgetSequenceByUUID},
        {"composeUUID",lcomposeUUID},
        {NULL,NULL},
    };

    luaL_newlibtable(L,l);
    luaL_setfuncs(L,l,0);
    int* sequence = (int*)lua_newuserdata(L,sizeof(int));
    *sequence = 0;
    lua_pushcclosure(L,luuid,1);
    lua_setfield(L,-2,"uuid");
    return 1;
}
