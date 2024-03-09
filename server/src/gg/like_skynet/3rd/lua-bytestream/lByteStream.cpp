#include <lua.hpp>
#include <string.h>
#include <ByteStream.h>
using namespace MapLib;

#if __cplusplus
extern "C" {
#endif

#define checkByteStream(L, idx)\
    *(ByteStream**)luaL_checkudata(L, idx, "ByteStream")

typedef struct ByteStreamPool{
    ByteStream* free_head;
}ByteStreamPool;

static int
lwriteByte(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint8_t value = luaL_checkinteger(L,2);
    //printf("op=writeByte,stream=%p,value=%u\n",stream,value);
    stream->writeByte(value);
    return 0;
}

static int
lwriteUInt8(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint8_t value = luaL_checkinteger(L,2);
    //printf("stream=%p,writeUInt8 value=%u\n",stream,value);
    stream->writeUInt8(value);
    return 0;
}

static int
lwriteUInt16(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint16_t value = luaL_checkinteger(L,2);
    //printf("op=writeUInt16,stream=%p,value=%u\n",stream,value);
    stream->writeUInt16(value);
    return 0;
}

static int
lwriteUInt32(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint32_t value = luaL_checkinteger(L,2);
    //printf("op=writeUInt32,stream=%p,value=%u\n",stream,value);
    stream->writeUInt32(value);
    return 0;
}

static int
lwriteUInt64(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint64_t value = luaL_checkinteger(L,2);
    //printf("op=writeUInt64,stream=%p,value=%lu\n",stream,value);
    stream->writeUInt64(value);
    return 0;
}


static int
lwriteInt8(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int8_t value = luaL_checkinteger(L,2);
    //printf("stream=%p,writeInt8 value=%d\n",stream,value);
    stream->writeInt8(value);
    return 0;
}

static int
lwriteInt16(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int16_t value = luaL_checkinteger(L,2);
    //printf("op=writeInt16,stream=%p,value=%d\n",stream,value);
    stream->writeInt16(value);
    return 0;
}

static int
lwriteInt32(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int32_t value = luaL_checkinteger(L,2);
    //printf("op=writeInt32,stream=%p,value=%d\n",stream,value);
    stream->writeInt32(value);
    return 0;
}

static int
lwriteInt64(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int64_t value = luaL_checkinteger(L,2);
    //printf("op=writeInt64,stream=%p,value=%ld\n",stream,value);
    stream->writeInt64(value);
    return 0;
}

static int
lwriteFloat(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int base = 0;
    mfloat_t value = luaL_checknumber(L,2);
    if(lua_gettop(L)>=3){
        base = luaL_checkinteger(L,3);
        stream->writeFloat(value,base);
    } else {
        stream->writeFloat(value);
    }
    //printf("op=writeFloat,stream=%p,base=%d,value=%f\n",stream,base,value);
    return 0;
}

static int
lwriteString(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    size_t length = 0;
    const char * ptr;
    if (lua_isuserdata(L,2)) {
		ptr = (const char *)lua_touserdata(L,2);
		length = (size_t)luaL_checkinteger(L, 3);
	} else {
		ptr = luaL_checklstring(L, 2, &length);
	}
    stream->writeString(ptr,(uint16_t)length);
    //printf("op=writeString,stream=%p,ptr=%s,length=%lu\n",stream,ptr,length);
    return 0;
}

static int
lwrite(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    const char * ptr = NULL;
    size_t length = 0;
    uint32_t offset = luaL_checkinteger(L,3);
	if(lua_isuserdata(L,2)) {
		ptr = (const char *)lua_touserdata(L,2);
		length = (size_t)luaL_checkinteger(L, 4);
	} else if(lua_gettop(L)>=4) {
        ptr = luaL_checkstring(L, 2);
        length = (size_t)luaL_checkinteger(L, 4);
    } else {
        ptr = luaL_checklstring(L, 2, &length);
    }
	stream->write((uint8_t*)ptr,offset,length);
    //printf("op=write,stream=%p,ptr=%p,offset=%d,length=%lu\n",stream,ptr,offset,length);
    return 0;
}

static int
lreadByte(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint8_t value = stream->readByte();
    lua_pushinteger(L,value);
    //printf("op=readByte,stream=%p,value=%u\n",stream,value);
    return 1;
}

static int
lreadUInt8(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint8_t value = stream->readUInt8();
    lua_pushinteger(L,value);
    //printf("op=readUInt8,stream=%p,value=%u\n",stream,value);
    return 1;
}

static int
lreadUInt16(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint16_t value = stream->readUInt16();
    lua_pushinteger(L,value);
    //printf("op=readUInt16,stream=%p,value=%u\n",stream,value);
    return 1;
}

static int
lreadUInt32(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint32_t value = stream->readUInt32();
    lua_pushinteger(L,value);
    //printf("op=readUInt32,stream=%p,value=%u\n",stream,value);
    return 1;
}

static int
lreadUInt64(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint64_t value = stream->readUInt64();
    lua_pushinteger(L,value);
    //printf("op=readUInt64,stream=%p,value=%lu\n",stream,value);
    return 1;
}

static int
lreadInt8(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int8_t value = stream->readInt8();
    lua_pushinteger(L,value);
    //printf("op=readInt8,stream=%p,value=%d\n",stream,value);
    return 1;
}

static int
lreadInt16(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int16_t value = stream->readInt16();
    lua_pushinteger(L,value);
    //printf("op=readInt16,stream=%p,value=%d\n",stream,value);
    return 1;
}

static int
lreadInt32(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int32_t value = stream->readInt32();
    lua_pushinteger(L,value);
    //printf("op=readInt32,stream=%p,value=%d\n",stream,value);
    return 1;
}

static int
lreadInt64(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int64_t value = stream->readInt64();
    lua_pushinteger(L,value);
    //printf("op=readInt64,stream=%p,value=%ld\n",stream,value);
    return 1;
}

static int
lreadFloat(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    int base = 0;
    mfloat_t value;
    if(lua_gettop(L)>=2){
        base = luaL_checkinteger(L,2);
        value = stream->readFloat(base);
    } else {
        value = stream->readFloat();
    }
    lua_pushnumber(L,value);
    //printf("op=readFloat,stream=%p,base=%u,value=%f\n",stream,base,value);
    return 1;
}

static int
lreadString(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint16_t length = 0;
    const char * ptr = stream->readString(&length);
    if(length > 0){
        lua_pushlstring(L,ptr,length);
        return 1;
    }
    return 0;
}

static int
lread(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    const char * ptr;
    uint32_t result = 0;
	if (lua_isuserdata(L,2)) {
		ptr = (const char *)lua_touserdata(L,2);
        uint32_t offset = luaL_checkinteger(L,3);
	    uint32_t length = luaL_checkinteger(L,4);
        result = stream->read((uint8_t*)ptr,offset,length);
        lua_pushinteger(L,result);
        //printf("op=read,stream=%p,ptr=%p,offset=%d,length=%d\n",stream,ptr,offset,length);
        return 1;
	} else {
        uint32_t offset = 0;
        uint32_t length = luaL_checkinteger(L,2);
        char * data = (char*)malloc(length);
        result = stream->read((uint8_t*)data,offset,length);
		lua_pushinteger(L,result);
        lua_pushlstring(L,data,length);
        free(data);
        //printf("op=read,stream=%p,ptr=nil,offset=%d,length=%d\n",stream,offset,length);
        return 2;
	}
}

static int
lgetBuffer(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint8_t* result = stream->getBuffer();
    lua_pushlightuserdata(L,result);
    //printf("op=getBuffer,stream=%p,result=%p\n",stream,result);
    return 1;
}

static int
lgetCapcity(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint32_t result = stream->getCapcity();
    lua_pushinteger(L,result);
    //printf("op=getCapcity,stream=%p,result=%d\n",stream,result);
    return 1;
}

static int
lgetPos(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint32_t result = stream->getPos();
    lua_pushinteger(L,result);
    //printf("op=getPos,stream=%p,result=%d\n",stream,result);
    return 1;
}

static int
lseek(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint32_t offset = luaL_checkinteger(L,2);
	uint32_t whence = luaL_checkinteger(L,3);
    uint32_t result = stream->seek(offset,whence);
    lua_pushinteger(L,result);
    //printf("op=seek,stream=%p,offset=%d,whence=%d,result=%d\n",stream,offset,whence,result);
    return 1;
}

static int
lreadFile(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    const char* filename = luaL_checkstring(L,2);
    stream->readFile(filename);
    //printf("op=readFile,stream=%p,filename=%s\n",stream,filename);
    return 0;
}

static int
lwriteFile(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    const char* filename = luaL_checkstring(L,2);
    stream->writeFile(filename);
    //printf("op=writeFile,stream=%p,filename=%s\n",stream,filename);
    return 0;
}

static int
linit(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    uint32_t size = luaL_checkinteger(L,2);
    stream->init(size);
    //printf("op=init,stream=%p,size=%d\n",stream,size);
    return 0;
}

static int
ltostring(lua_State* L) {
    ByteStream* stream = checkByteStream(L,1);
    if(!stream){
        return luaL_error(L, "Invalid ByteStream");
    }
    const char* buff = (const char*)stream->getBuffer();
    uint32_t length = stream->getPos();
    lua_pushlstring(L,buff,length);
    return 1;
}

static ByteStream *
newByteStream(ByteStreamPool**ppool,uint32_t size){
    ByteStreamPool* pool = *ppool;
    ByteStream* stream = pool->free_head;
    if(stream){
        pool->free_head = stream->next;
        stream->init(size);
        //printf("op=newByteStream,stream=%p,pool=%p,size=%d,reuse=true\n",stream,pool,size);
    } else {
        stream = new ByteStream(size);
        //printf("op=newByteStream,stream=%p,pool=%p,size=%d,new=true\n",stream,pool,size);
    }
    stream->next = NULL;
    stream->ppool = ppool;
    return stream;
}

static void
freeByteStream(ByteStream* stream){
    ByteStreamPool**ppool = (ByteStreamPool**)stream->ppool;
    ByteStreamPool* pool = *ppool;
    if(pool){
        //printf("op=freeByteStream,stream=%p,pool=%p,put in pool\n",pool,stream);
        stream->next = pool->free_head;
        pool->free_head = stream;
    } else {
        //printf("op=freeByteStream,stream=%p,pool=%p,delete\n",pool,stream);
        delete stream;
    }
}

static int
lnewByteStream(lua_State* L) {
    ByteStreamPool** ppool = (ByteStreamPool**) lua_touserdata(L, lua_upvalueindex(1));
    size_t sz = 8;
    if (lua_gettop(L) >= 1) {
        sz = luaL_checkinteger(L,1);
    }
    ByteStream *stream = newByteStream(ppool,sz);
    ByteStream** pstream = (ByteStream**)lua_newuserdata(L,sizeof(ByteStream*));
    *pstream = stream;
    //printf("op=lnewByteStream,stream=%p,pstream=%p,pool=%p\n",stream,pstream,*ppool);
    luaL_getmetatable(L,"ByteStream");
    lua_setmetatable(L,-2);
    return 1;
}

static int
lfreeByteStream(lua_State* L) {
    ByteStream** pstream = (ByteStream**)luaL_checkudata(L, -1, "ByteStream");
    ByteStream* stream = *pstream;
    //printf("op=lfreeByteStream,stream=%p,pstream=%p\n",stream,pstream);
    *pstream = NULL;
    if(stream){
        freeByteStream(stream);
    }
    return 0;
}

static int
lgcByteStream(lua_State* L) {
    ByteStream** pstream = (ByteStream**)luaL_checkudata(L, 1, "ByteStream");
    ByteStream* stream = *pstream;
    //printf("op=lgcByteStream,stream=%p,pstream=%p\n",stream,pstream);
    *pstream = NULL;
    if(stream){
        freeByteStream(stream);
    }
    return 0;
}

static int
lgcPool(lua_State* L) {
    ByteStreamPool** ppool = (ByteStreamPool**) lua_touserdata(L, lua_upvalueindex(1));
    ByteStreamPool* pool = *ppool;
    *ppool = NULL;
    //printf("op=lgcPool,pool=%p,ppool=%p\n",pool,ppool);
    if(pool){
        ByteStream*free_head = pool->free_head;
        ByteStream*tmp;
        while(free_head){
            tmp = free_head->next;
            //printf("op=lgcPool,delete free:%p\n",free_head);
            delete free_head;
            free_head = tmp;
        }
        delete pool;
    }
    return 0;
}

static luaL_Reg l[] = {
    {"new",lnewByteStream},
    {"free",lfreeByteStream},
    {NULL,NULL},
};

static luaL_Reg methods[] = {
    {"writeByte",lwriteByte},
    {"writeUInt8",lwriteUInt8},
    {"writeUInt16",lwriteUInt16},
    {"writeUInt32",lwriteUInt32},
    {"writeUInt64",lwriteUInt64},
    {"writeInt8",lwriteInt8},
    {"writeInt16",lwriteInt16},
    {"writeInt32",lwriteInt32},
    {"writeInt64",lwriteInt64},
    {"writeFloat",lwriteFloat},
    {"writeString",lwriteString},
    {"write",lwrite},
    {"readByte",lreadByte},
    {"readUInt8",lreadUInt8},
    {"readUInt16",lreadUInt16},
    {"readUInt32",lreadUInt32},
    {"readUInt64",lreadUInt64},
    {"readInt8",lreadInt8},
    {"readInt16",lreadInt16},
    {"readInt32",lreadInt32},
    {"readInt64",lreadInt64},
    {"readFloat",lreadFloat},
    {"readString",lreadString},
    {"read",lread},
    {"getBuffer",lgetBuffer},
    {"getCapcity",lgetCapcity},
    {"getPos",lgetPos},
    {"seek",lseek},
    {"readFile",lreadFile},
    {"writeFile",lwriteFile},
    {"init",linit},
    {"tostring",ltostring},
    {NULL,NULL},
};

static void
initMetatable(lua_State* L) {
    luaL_newmetatable(L,"ByteStream");
    lua_newtable(L);
    luaL_setfuncs(L,methods,0);
    lua_pushinteger(L,ByteStreamSeek::Begin);
    lua_setfield(L,-2,"Begin");
    lua_pushinteger(L,ByteStreamSeek::Cur);
    lua_setfield(L,-2,"Cur");
    lua_pushinteger(L,ByteStreamSeek::End);
    lua_setfield(L,-2,"End");
    lua_setfield(L,-2,"__index");
    lua_pushcfunction(L,lgcByteStream);
    lua_setfield(L,-2,"__gc");
    lua_pop(L,1);
}

LUAMOD_API int
luaopen_bytestream_core(lua_State* L) {
    luaL_checkversion(L);
    initMetatable(L);
    lua_newtable(L);
    ByteStreamPool* pool = new ByteStreamPool();
    ByteStreamPool** ppool = (ByteStreamPool**)lua_newuserdata(L,sizeof(ByteStreamPool*));
    pool->free_head = NULL;
    *ppool = pool;
    luaL_setfuncs(L,l,1);
    lua_newtable(L);
    lua_pushlightuserdata(L,ppool);
    lua_pushcclosure(L,lgcPool,1);
    lua_setfield(L,-2,"__gc");
    lua_setmetatable(L,-2);
    return 1;
}

#if __cplusplus
} // extern "C"
#endif
