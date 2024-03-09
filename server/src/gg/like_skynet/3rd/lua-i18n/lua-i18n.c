#include <lua.h>
#include <lauxlib.h>

#include "i18n.h"

#define I18N_TEXT_TYPE 1

#define check_i18n(L, idx)\
    *(i18n_context_t**)luaL_checkudata(L, idx, "i18n")

#define check_i18n_text(L, idx)\
    *(i18n_text_t**)luaL_checkudata(L, idx, "i18n_text")

static int
li18n_new(lua_State* L) {
    size_t nlang = luaL_checkinteger(L,1);
    size_t translate_size = 0;
    if (lua_gettop(L) >= 2) {
        translate_size = luaL_checkinteger(L,2);
    }
    i18n_context_t* i18n = i18n_new(nlang,translate_size);
    i18n_context_t** li18n = (i18n_context_t**)lua_newuserdata(L,sizeof(i18n_context_t*));
    *li18n = i18n;
    luaL_getmetatable(L,"i18n");
    lua_setmetatable(L,-2);
    lua_pushvalue(L,-1);
    lua_setfield(L,LUA_REGISTRYINDEX,"i18n_singleton");
    return 1;
}

static int
li18n_free(lua_State* L) {
    i18n_context_t* i18n = check_i18n(L,1);
    i18n_free(i18n);
    return 0;
}

static void
push_i18n_text(lua_State* L,i18n_text_t* text,int uservalue) {
    i18n_text_t** ltext = (i18n_text_t**)lua_newuserdata(L,sizeof(i18n_text_t*));
    *ltext = text;
    if (uservalue != 0 && lua_istable(L,uservalue)) {
        // i18n_text's uservalue is a replace_dict
        lua_pushvalue(L,uservalue);
        lua_setuservalue(L,-2);
    }
    luaL_getmetatable(L,"i18n_text");
    lua_setmetatable(L,-2);
}

static int
li18n_format(lua_State* L) {
    i18n_context_t* i18n = check_i18n(L,1);
    int fmt = luaL_checkinteger(L,2);
    const char* str_arg;
    i18n_text_t* args[ARG_MAX_NUM];
    int top = lua_gettop(L);
    size_t narg = 0;
    int tidx = 3;
    int tt;
    if (top >= 3 && lua_istable(L,tidx)) {
        narg = lua_rawlen(L,tidx);
        if (narg > ARG_MAX_NUM) {
            narg = ARG_MAX_NUM;
        }
        for (int i=1; i<=narg; i++) {
            lua_rawgeti(L,tidx,i);
            tt = lua_type(L,-1);
            if (tt == LUA_TSTRING || tt == LUA_TNUMBER) {
                str_arg = luaL_checkstring(L,-1);
                args[i-1] = i18n_new_text(i18n,INVALID_TEXT_ID,str_arg,NULL,0);
            } else if(tt == LUA_TUSERDATA) {
                args[i-1] = check_i18n_text(L,-1);
            } else {
                luaL_error(L,"invalid type: %s",lua_typename(L,tt));
            }
            lua_pop(L,1);
        }
    }
    i18n_text_t* text = i18n_format(i18n,fmt,args,narg);
    int uservalue = 0;
    if (top == 4) {
        uservalue = top;
    }
    push_i18n_text(L,text,uservalue);
    return 1;
}

static void
unpack_i18n_text(lua_State* L,i18n_context_t* i18n,const char* str,int uservalue,int lang) {
    if (uservalue != 0 && lua_istable(L,uservalue)) {
        int tt = 0;
        int keylen = 0;
        const char* key = NULL;
        const char* value = NULL;
        i18n_text_t* temp = NULL;
        lua_pushnil(L);
        while(lua_next(L,uservalue) != 0) {
            tt = lua_type(L,-1);
            key = luaL_checkstring(L,-2);
            if (tt == LUA_TSTRING || tt == LUA_TNUMBER) {
                value = luaL_checkstring(L,-1);
            } else if(tt == LUA_TUSERDATA) {
                temp = check_i18n_text(L,-1);
                value = i18n_translateto(i18n,lang,temp);
            } else {
                luaL_error(L,"invalid type: %s",lua_typename(L,tt));
            }
            keylen = snprintf(i18n->result2,TEXT_MAX_LENGTH-1,"{%s}",key);
            i18n->result2[keylen] = '\0';
            str = luaL_gsub(L,str,i18n->result2,value);
            lua_pop(L,2);
        }
    }
    lua_pushstring(L,str);
}

static int
li18n_translateto(lua_State* L) {
    i18n_context_t* i18n = check_i18n(L,1);
    int lang = luaL_checkinteger(L,2);
    i18n_text_t* text = check_i18n_text(L,3);
    int uservalue = 0;
    if (lua_getuservalue(L,-1) != LUA_TNIL) {
        uservalue = lua_gettop(L);
    } else {
        lua_pop(L,1);
    }
    const char* str = i18n_translateto(i18n,lang,text);
    unpack_i18n_text(L,i18n,str,uservalue,lang);
    return 1;
}

static int
li18n_free_text(lua_State* L) {
    i18n_text_t* text = check_i18n_text(L,1);
    i18n_context_t* i18n = text->i18n;
    i18n_free_text(i18n,text);
    return 0;
}

static int
li18n_tostring(lua_State* L) {
    i18n_text_t* text = check_i18n_text(L,1);
    i18n_context_t* i18n = text->i18n;
    int uservalue = 0;
    if (lua_getuservalue(L,-1) != LUA_TNIL) {
        uservalue = lua_gettop(L);
    }
    const char* str = i18n_translateto(i18n,ORIGINAL_LANG_ID,text);
    unpack_i18n_text(L,i18n,str,uservalue,ORIGINAL_LANG_ID);
    return 1;
}

static int
li18n_equal(lua_State* L) {
    i18n_text_t* text1 = check_i18n_text(L,1);
    i18n_text_t* text2 = check_i18n_text(L,2);
    i18n_context_t* i18n = text1->i18n;
    char* str1 = i18n->result2;
    const char* temp = i18n_tostring(i18n,text1);
    memcpy(str1,temp,strlen(temp)+1);
    const char* str2 = i18n_tostring(i18n,text2);
    bool equal = strcmp(str1,str2) == 0;
    lua_pushboolean(L,equal);
    return 1;
}

static int
li18n_serialize_text(lua_State* L) {
    i18n_text_t* text = check_i18n_text(L,1);
    lua_getfield(L,LUA_REGISTRYINDEX,"i18n_singleton");
    i18n_context_t* i18n = check_i18n(L,-1);
    char* str = i18n->result;
    int len = i18n_serialize_text(i18n,text,str,TEXT_MAX_LENGTH);
    if (len <= 0) {
        lua_pushnil(L);
    } else {
        lua_pushlstring(L,str,len);
    }
    return 1;
}

static int
li18n_deserialize_text(lua_State* L) {
    size_t len = 0;
    const char* str = luaL_checklstring(L,1,&len);
    int uservalue = 0;
    if (!lua_isnoneornil(L,2)) {
        uservalue = 2;
    }
    lua_getfield(L,LUA_REGISTRYINDEX,"i18n_singleton");
    i18n_context_t* i18n = check_i18n(L,-1);
    int ilen = (int)len;
    i18n_text_t* text = i18n_deserialize_text(i18n,str,&ilen);
    if (text == NULL) {
        lua_pushnil(L);
    } else {
        push_i18n_text(L,text,uservalue);
    }
    return 1;
}

static int
li18n_add_text(lua_State* L) {
    i18n_context_t* i18n = check_i18n(L,1);
    const char* str = luaL_checkstring(L,2);
    int id = 0;
    if (lua_gettop(L) >= 3) {
        id = luaL_checkinteger(L,3);
    }
    id = i18n_add_text(i18n,str,id);
    lua_pushinteger(L,id);
    return 1;
}

static int
li18n_add_translate(lua_State* L) {
    i18n_context_t* i18n = check_i18n(L,1);
    int lang = luaL_checkinteger(L,2);
    int from = luaL_checkinteger(L,3);
    int to = luaL_checkinteger(L,4);
    i18n_add_translate(i18n,lang,from,to);
    return 0;
}

static luaL_Reg l[] = {
    {"new",li18n_new},
    {"serialize_text",li18n_serialize_text},
    {"deserialize_text",li18n_deserialize_text},
    {NULL,NULL},
};

static luaL_Reg methods[] = {
    {"format",li18n_format},
    {"translateto",li18n_translateto},
    {"add_text",li18n_add_text},
    {"add_translate",li18n_add_translate},
    {"free_text",li18n_free_text},
    {NULL,NULL},
};

int
luaopen_i18n_core(lua_State* L) {
    luaL_checkversion(L);
    luaL_newmetatable(L,"i18n");
    lua_newtable(L);
    luaL_setfuncs(L,methods,0);
    lua_setfield(L,-2,"__index");
    lua_pushcfunction(L,li18n_free);
    lua_setfield(L,-2,"__gc");
    lua_pop(L,1);
    luaL_newmetatable(L,"i18n_text");
    lua_pushcfunction(L,li18n_free_text);
    lua_setfield(L,-2,"__gc");
    lua_pushcfunction(L,li18n_tostring);
    lua_setfield(L,-2,"__tostring"),
    lua_pushcfunction(L,li18n_equal);
    lua_setfield(L,-2,"__eq");
    lua_pushinteger(L,I18N_TEXT_TYPE);
    lua_setfield(L,-2,"__type");
    lua_pop(L,1);
    luaL_newlib(L,l);
    lua_pushinteger(L,I18N_TEXT_TYPE);
    lua_setfield(L,-2,"I18N_TEXT_TYPE");
    return 1;
}