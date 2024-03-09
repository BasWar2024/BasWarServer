#include <lua.h>
#include <lauxlib.h>
#include <string.h>

// most code copy from ldblib.c#db_traceback/lauxlib.c#luaL_traceback

#define LEVELS1	10	/* size of the first part of the stack */
#define LEVELS2	11	/* size of the second part of the stack */

static lua_State* getthread (lua_State *L, int *arg) {
  if (lua_isthread(L, 1)) {
    *arg = 1;
    return lua_tothread(L, 1);
  }
  else {
    *arg = 0;
    return L;  /* function will operate over current thread */
  }
}

/*
** search for 'objidx' in table at index -1.
** return 1 + string at top if find a good name.
*/
static int findfield (lua_State *L, int objidx, int level) {
  if (level == 0 || !lua_istable(L, -1))
    return 0;  /* not found */
  lua_pushnil(L);  /* start 'next' loop */
  while (lua_next(L, -2)) {  /* for each pair in table */
    if (lua_type(L, -2) == LUA_TSTRING) {  /* ignore non-string keys */
      if (lua_rawequal(L, objidx, -1)) {  /* found object? */
        lua_pop(L, 1);  /* remove value (but keep name) */
        return 1;
      }
      else if (findfield(L, objidx, level - 1)) {  /* try recursively */
        lua_remove(L, -2);  /* remove table (but keep name) */
        lua_pushliteral(L, ".");
        lua_insert(L, -2);  /* place '.' between the two names */
        lua_concat(L, 3);
        return 1;
      }
    }
    lua_pop(L, 1);  /* remove value */
  }
  return 0;  /* not found */
}

/*
** Search for a name for a function in all loaded modules
*/
static int pushglobalfuncname (lua_State *L, lua_Debug *ar) {
  int top = lua_gettop(L);
  lua_getinfo(L, "f", ar);  /* push function */
  lua_getfield(L, LUA_REGISTRYINDEX, LUA_LOADED_TABLE);
  if (findfield(L, top + 1, 2)) {
    const char *name = lua_tostring(L, -1);
    if (strncmp(name, "_G.", 3) == 0) {  /* name start with '_G.'? */
      lua_pushstring(L, name + 3);  /* push name without prefix */
      lua_remove(L, -2);  /* remove original name */
    }
    lua_copy(L, -1, top + 1);  /* move name to proper place */
    lua_pop(L, 2);  /* remove pushed values */
    return 1;
  }
  else {
    lua_settop(L, top);  /* remove function and global table */
    return 0;
  }
}


static void pushfuncname (lua_State *L, lua_Debug *ar) {
  if (pushglobalfuncname(L, ar)) {  /* try first a global name */
    lua_pushfstring(L, "function '%s'", lua_tostring(L, -1));
    lua_remove(L, -2);  /* remove name */
  }
  else if (*ar->namewhat != '\0')  /* is there a name from code? */
    lua_pushfstring(L, "%s '%s'", ar->namewhat, ar->name);  /* use it */
  else if (*ar->what == 'm')  /* main? */
      lua_pushliteral(L, "main chunk");
  else if (*ar->what != 'C')  /* for Lua functions, use <file:line> */
    lua_pushfstring(L, "function <%s:%d>", ar->short_src, ar->linedefined);
  else  /* nothing left... */
    lua_pushliteral(L, "?");
}

static void pushvars(lua_State* L,lua_State* L1,lua_Debug* ar,int level,int collectlocalvars) {
  int n = 1;
  const char* varname = NULL;
  while (n <= ar->nparams) {
    varname = lua_getlocal(L1,ar,n++);
    if (varname == NULL) {
      break;
    }
    lua_xmove(L1,L,1);
    lua_pushstring(L,varname);
    lua_pushboolean(L,1);
    lua_pushvalue(L,collectlocalvars);
    lua_rotate(L,-4,1);
    int r = lua_pcall(L,3,1,0);
    if (r == LUA_OK) {
      if (lua_isnil(L,-1)) {
        lua_pop(L,1);
      } else {
        lua_pushfstring(L,"\n\t\t%s=%s",varname,lua_tostring(L,-1));
        lua_remove(L,-2);
      }
    }
  }
  if (varname == NULL) {
    return;
  }
  while (1) {
    varname = lua_getlocal(L1,ar,n++);
    if (varname == NULL) {
      break;
    }
    lua_checkstack(L,4);
    lua_xmove(L1,L,1);
    lua_pushstring(L,varname);
    lua_pushboolean(L,0);
    lua_pushvalue(L,collectlocalvars);
    lua_rotate(L,-4,1);
    int r = lua_pcall(L,3,1,0);
    if (r == LUA_OK) {
      if (lua_isnil(L,-1)) {
        lua_pop(L,1);
      } else {
        lua_pushfstring(L,"\n\t\t%s=%s",varname,lua_tostring(L,-1));
        lua_remove(L,-2);
      }
    }
  }
}

static int lastlevel (lua_State *L) {
  lua_Debug ar;
  int li = 1, le = 1;
  /* find an upper bound */
  while (lua_getstack(L, le, &ar)) { li = le; le *= 2; }
  /* do a binary search */
  while (li < le) {
    int m = (li + le)/2;
    if (lua_getstack(L, m, &ar)) li = m + 1;
    else le = m;
  }
  return le - 1;
}

void my_traceback (lua_State *L, lua_State *L1,const char *msg, int level,int collectlocalvars) {
  lua_Debug ar;
  int top = lua_gettop(L);
  int last = lastlevel(L1);
  int n1 = (last - level > LEVELS1 + LEVELS2) ? LEVELS1 : -1;
  if (msg)
    lua_pushfstring(L, "%s\n", msg);
  luaL_checkstack(L, 32, NULL);
  lua_pushliteral(L, "stack traceback:");
  while (lua_getstack(L1, level, &ar)) {
    if (n1-- == 0) {  /* too many levels? */
      lua_pushliteral(L, "\n\t...");  /* add a '...' */
      level = last - LEVELS2 + 1;  /* and skip to last ones */
    }
    else {
      lua_getinfo(L1, "Slntu", &ar);
      lua_pushfstring(L, "\n\t%d @%s:", level,ar.short_src);
      if (ar.currentline > 0)
        lua_pushfstring(L, "%d:", ar.currentline);
      lua_pushliteral(L, " in ");
      pushfuncname(L, &ar);
      if (ar.istailcall)
        lua_pushliteral(L, "\n\t(...tail calls...)");
      if (collectlocalvars != 0) {
        pushvars(L,L1,&ar,level,collectlocalvars);
      }
      lua_concat(L, lua_gettop(L) - top);
      level++;
    }
  }
  lua_concat(L, lua_gettop(L) - top);
}


static int ltraceback (lua_State* L) {
  int arg;
  lua_State *L1 = getthread(L, &arg);
  const char *msg = lua_tostring(L, arg + 1);
  if (msg == NULL && !lua_isnoneornil(L, arg + 1))  /* non-string 'msg'? */
    lua_pushvalue(L, arg + 1);  /* return it untouched */
  else {
    int level = (int)luaL_optinteger(L, arg + 2, (L == L1) ? 1 : 0);
    int collectlocalvars = 0;
    lua_getfield(L,LUA_REGISTRYINDEX,"__collectlocalvars");
    if (!lua_isnil(L,-1)) {
        collectlocalvars = lua_gettop(L);
    }
    my_traceback(L, L1, msg, level,collectlocalvars);
  }
  return 1;
}

static int lregister_collecter(lua_State* L) {
  if (!(lua_isfunction(L,1) || lua_isnil(L,1))) {
    return 0;
  }
  lua_setfield(L,LUA_REGISTRYINDEX,"__collectlocalvars");
  return 0;
}


static luaL_Reg funcs[] = {
  {"traceback",ltraceback},
  {"register_collecter",lregister_collecter},
  {NULL,NULL},
};

LUAMOD_API int luaopen_traceback(lua_State* L) {
  luaL_newlib(L,funcs);
  return 1;
}