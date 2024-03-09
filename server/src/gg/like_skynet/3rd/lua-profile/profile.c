#include <lua.h>
#include <lauxlib.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <assert.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "imap.h"
#if defined(__APPLE__)
#include <mach/task.h>
#include <mach/mach.h>
#endif


#define NANOSEC                     1000000000
#define MICROSEC                    1000000
#define MAX_SOURCE_LEN              128
#define MAX_NAME_LEN                32
#define MAX_CALL_SIZE               1024
#define DEFAULT_RECORD_COUNT        64

#define CLOCK_THREAD_CPUTIME_ID 3
#define CLOCK_REALTIME 0

static const char* KEY = "profile_key";


static inline uint64_t
gettime() {
#if !defined(__APPLE__)
    struct timespec ti;
    //clock_gettime(CLOCK_THREAD_CPUTIME_ID, &ti);
    clock_gettime(CLOCK_REALTIME, &ti);

    long sec = ti.tv_sec & 0xffff;
    long nsec = ti.tv_nsec;
    return sec * NANOSEC + nsec;
#else
    struct task_thread_times_info aTaskInfo;
    mach_msg_type_number_t aTaskInfoCount = TASK_THREAD_TIMES_INFO_COUNT;
    if (KERN_SUCCESS != task_info(mach_task_self(), TASK_THREAD_TIMES_INFO, (task_info_t )&aTaskInfo, &aTaskInfoCount)) {
        return 0;
    }

    int sec = aTaskInfo.user_time.seconds & 0xffff;
    int msec = aTaskInfo.user_time.microseconds;
    return sec * NANOSEC + msec * MICROSEC;
#endif
}

static inline double
realtime(uint64_t t) {
    return (double)t / MICROSEC;
}

typedef struct call_frame_t {
    uint64_t func_id;
    const char* source;
    const char* name;
    int line;
    char flag;
    bool is_tail_call;
    // sum_cost = real_cost + child_cost + yield_cost
    // cpu_cost = real_cost + child_cost
    uint64_t sum_cost;
    uint64_t cpu_cost;
    uint64_t real_cost;
    uint64_t child_cost;
    uint64_t yield_cost;
    uint64_t call_time;
} call_frame_t;

typedef struct call_stack_t {
    call_frame_t call_list[MAX_CALL_SIZE];
    int top;
    bool yielding;
    uint64_t yield_time;
    uint64_t yield_cost;
} call_stack_t;

typedef struct record_t {
    uint64_t func_id;
    char source[MAX_SOURCE_LEN];
    char name[MAX_NAME_LEN];
    int line;
    char flag;
    uint64_t call_count;
    uint64_t sum_cost;
    uint64_t cpu_cost;
    uint64_t real_cost;
    uint64_t avg_cost;
    uint64_t avg_cpu_cost;
    uint64_t avg_real_cost;
} record_t;

typedef struct record_list_t {
    record_t** temp_items;
    record_t* items;
    size_t length;
    size_t capacity;
} record_list_t;

typedef struct profile_context_t {
    struct imap_context* map_func_record;
    struct imap_context* map_co_callstack;
    record_list_t record_list;
    lua_State* current_co;
} profile_context_t;

static call_stack_t*
create_call_stack() {
    call_stack_t *callstack = (call_stack_t*)malloc(sizeof(call_stack_t));
    callstack->top = 0;
    callstack->yielding = false;
    callstack->yield_time = 0;
    callstack->yield_cost = 0;
    return callstack;
}

static void
free_call_stack(call_stack_t* callstack) {
    if (!callstack) {
        return;
    }
    free(callstack);
}

static profile_context_t*
profile_create() {
    profile_context_t* profile = (profile_context_t*)malloc(sizeof(profile_context_t));
    profile->map_func_record = imap_create();
    profile->map_co_callstack = imap_create();
    profile->record_list.capacity = DEFAULT_RECORD_COUNT;
    profile->record_list.length = 0;
    profile->record_list.items = (record_t*)malloc(profile->record_list.capacity*sizeof(record_t));
    profile->record_list.temp_items = (record_t**)malloc(profile->record_list.capacity*sizeof(record_t*));
    profile->current_co = NULL;
    return profile;
}

static void
profile_free(profile_context_t* profile) {
    free(profile->record_list.temp_items);
    free(profile->record_list.items);
    IMAP_FOREACH(profile->map_co_callstack,{
        free_call_stack(IMAP_ITEM_VALUE(item));
    })
    imap_free(profile->map_co_callstack);
    imap_free(profile->map_func_record);
    free(profile);
}

static inline call_stack_t*
get_call_stack(profile_context_t* profile, lua_State* co) {
    lua_State* current_co = profile->current_co;
    uint64_t key = (uint64_t)co;
    call_stack_t* callstack = (call_stack_t*)imap_get(profile->map_co_callstack,key);
    if (!callstack) {
        callstack = create_call_stack();
        imap_set(profile->map_co_callstack,key,callstack);
        #if DEBUG
            printf("op=create_call_stack,co=%p,current_co=%p\n",co,current_co);
        #endif
    }
    if (co != current_co) {
        call_stack_t* prev_callstack = get_call_stack(profile,current_co);
        if (!prev_callstack->yielding) {
            prev_callstack->yielding = true;
            prev_callstack->yield_time = gettime();
        }
        if (callstack->yielding) {
            callstack->yielding = false;
            callstack->yield_cost += gettime() - callstack->yield_time;
        }
        profile->current_co = co;
    }
    return callstack;
}

static inline call_frame_t*
push_call_frame(call_stack_t* callstack) {
    assert(callstack->top < MAX_CALL_SIZE);
    return &callstack->call_list[callstack->top++];
}

static inline call_frame_t*
pop_call_frame(call_stack_t* callstack) {
    assert(callstack->top > 0);
    return &callstack->call_list[--callstack->top];
}

static inline call_frame_t *
top_call_frame(call_stack_t* callstack) {
    if (callstack->top <= 0) {
        return NULL;
    }
    return &callstack->call_list[callstack->top-1];
}

static record_t*
create_record(profile_context_t* profile) {
    if (profile->record_list.length >= profile->record_list.capacity) {
        size_t new_capacity = profile->record_list.capacity * 2;
        profile->record_list.items = (record_t*)realloc(profile->record_list.items,new_capacity*sizeof(record_t));
        profile->record_list.capacity = new_capacity;
        profile->record_list.temp_items = (record_t**)realloc(profile->record_list.temp_items,new_capacity*sizeof(record_t*));
    }
    return &profile->record_list.items[profile->record_list.length++];
}

static void
add_record(profile_context_t* profile, call_frame_t* call_frame) {
    uint64_t key = call_frame->func_id;
    uint64_t record_pos = (uint64_t)imap_get(profile->map_func_record,key);
    record_t* record = NULL;
    if(record_pos == 0) {
        record = create_record(profile);
        record_pos = profile->record_list.length;
        record->func_id = call_frame->func_id;
        strncpy(record->source, call_frame->source, MAX_SOURCE_LEN);
        record->source[MAX_SOURCE_LEN-1] = '\0'; // padding zero terimal
        strncpy(record->name, call_frame->name, MAX_NAME_LEN);
        record->name[MAX_NAME_LEN-1] = '\0'; // padding zero terimal
        record->line = call_frame->line;
        record->flag = call_frame->flag;
        record->call_count = 0;
        record->sum_cost = 0;
        record->cpu_cost = 0;
        record->real_cost = 0;
        record->avg_cost = 0;
        record->avg_cpu_cost = 0;
        record->avg_real_cost = 0;
        imap_set(profile->map_func_record,key,(void*)record_pos);
    } else {
        record = &profile->record_list.items[record_pos-1];
    }
    record->call_count++;
    record->sum_cost += call_frame->sum_cost;
    record->cpu_cost += call_frame->cpu_cost;
    record->real_cost += call_frame->real_cost;
    #if DEBUG
        printf("op=add_record,func_id=%lu,call_count=%lu,source=%s:%d,name=%s,record_list_length=%lu\n",record->func_id,record->call_count,record->source,record->line,record->name,profile->record_list.length);
    #endif
}

static inline profile_context_t*
get_profile(lua_State* L) {
    lua_rawgetp(L, LUA_REGISTRYINDEX, (void *)&KEY);
    profile_context_t* addr = (profile_context_t*)lua_touserdata(L, -1);
    lua_pop(L, 1);
    return addr;
}

static void
resolve_hook(lua_State* co, lua_Debug* arv) {
    uint64_t cur_time = gettime();
    profile_context_t *profile = get_profile(co);
    if (!profile) {
        lua_sethook(co,NULL,0,0);
        return;
    }
    int event = arv->event;
    lua_Debug ar;
    int ret = lua_getstack(co, 0, &ar);
    const char* source = NULL;
    const char* name = NULL;
    char flag = 'L';
    int line = -1;
    if(!ret) {
        return;
    }
    #if DEBUG
        lua_getinfo(co, "nSlf", &ar);
        name = ar.name ? ar.name : "null";
        line = ar.linedefined;
        source = ar.source ? ar.source : "null";
        printf("op=resolve_hook,co=%p,name=%s,source=%s:%d,event=%d\n", co,name, source, line, event);
    #endif

    call_stack_t* callstack = get_call_stack(profile,co);
    if(event == LUA_HOOKCALL || event == LUA_HOOKTAILCALL) {
        lua_getinfo(co, "nSlf", &ar);
        name = ar.name;
        line = ar.linedefined;
        source = ar.source;
        if (ar.what[0] == 'C' && event == LUA_HOOKCALL) {
            lua_Debug ar2;
            int i=0;
            do {
                i++;
                ret = lua_getstack(co, i, &ar2);
                flag = 'C';
                if(ret) {
                    lua_getinfo(co, "Sl", &ar2);
                    if(ar2.what[0] != 'C') {
                        line = ar2.currentline;
                        source = ar2.source;
                        break;
                    }
                }
            } while(ret);
        }

        call_frame_t* frame = push_call_frame(callstack);
        frame->func_id = (uint64_t)lua_topointer(co,-1);
        frame->source = (source)?(source):("null");
        frame->name = (name)?(name):("null");
        frame->line = line;
        frame->flag = flag;
        frame->is_tail_call = event == LUA_HOOKTAILCALL;
        frame->sum_cost = 0;
        frame->real_cost = 0;
        frame->child_cost = 0;
        frame->yield_cost = 0;
        frame->call_time = cur_time;
    } else if(event == LUA_HOOKRET) {
        if (top_call_frame(callstack) == NULL) {
            return;
        }
        bool is_tail_call = false;
        call_frame_t* cur_frame = NULL;
        do {
            cur_frame = pop_call_frame(callstack);
            call_frame_t* prev_frame = top_call_frame(callstack);
            uint64_t sum_cost = cur_time - cur_frame->call_time;
            cur_frame->sum_cost = sum_cost;
            is_tail_call = cur_frame->is_tail_call;
            if(prev_frame) {
                prev_frame->child_cost += sum_cost;
            } else {
                is_tail_call = false;
            }
        } while(is_tail_call);
        if (cur_frame->call_time < callstack->yield_time) {
            cur_frame->yield_cost = callstack->yield_cost;
        }
        callstack->yield_cost = 0;
        cur_frame->real_cost = cur_frame->sum_cost - cur_frame->child_cost - cur_frame->yield_cost;
        cur_frame->cpu_cost = cur_frame->real_cost + cur_frame->child_cost;
        add_record(profile,cur_frame);
        if (top_call_frame(callstack) == NULL) {
            #if DEBUG
                printf("op=imap_remove,obj=map_co_call_stack,co=%p,co_status=%d,top_frame=%p\n",co,co_status,top_call_frame(callstack));
            #endif
            free_call_stack(imap_remove(profile->map_co_callstack,(uint64_t)co));
        }
    }
}

static int
lstart(lua_State *L) {
    profile_context_t* profile = get_profile(L);
    if (profile) {
        return 0;
    }
    profile = profile_create();
    profile->current_co = L;
    lua_pushlightuserdata(L, profile);
    lua_rawsetp(L, LUA_REGISTRYINDEX, (void*)&KEY);
    lua_sethook(L,resolve_hook, LUA_MASKCALL | LUA_MASKRET,0);
    return 0;
}

static int
lstop(lua_State* L) {
    profile_context_t* profile = get_profile(L);
    if (!profile) {
        return 0;
    }
    lua_sethook(L,NULL,0,0);
    lua_pushlightuserdata(L, (void *)&KEY);
    lua_pushnil(L);
    lua_settable(L, LUA_REGISTRYINDEX);
    profile_free(profile);
    return 0;
}

static int
compare0(const void* v1, const void* v2) {
    record_t* a = *(record_t**)v1;
    record_t* b = *(record_t**)v2;
    return (a->call_count > b->call_count) ? -1 : 1;
}

static int
compare1(const void* v1, const void* v2) {
    record_t* a = *(record_t**)v1;
    record_t* b = *(record_t**)v2;
    return (a->sum_cost > b->sum_cost) ? -1 : 1;
}

static int
compare2(const void* v1, const void* v2) {
    record_t* a = *(record_t**)v1;
    record_t* b = *(record_t**)v2;
    return (a->cpu_cost > b->cpu_cost) ? -1 : 1;
}

static int
compare3(const void* v1, const void* v2) {
    record_t* a = *(record_t**)v1;
    record_t* b = *(record_t**)v2;
    return (a->real_cost > b->real_cost) ? -1 : 1;
}

static int
compare4(const void* v1, const void* v2) {
    record_t* a = *(record_t**)v1;
    record_t* b = *(record_t**)v2;
    return (a->avg_cost > b->avg_cost) ? -1 : 1;
}

static int
compare5(const void* v1, const void* v2) {
    record_t* a = *(record_t**)v1;
    record_t* b = *(record_t**)v2;
    return (a->avg_cpu_cost > b->avg_cpu_cost) ? -1 : 1;
}

static int
compare6(const void* v1, const void* v2) {
    record_t* a = *(record_t**)v1;
    record_t* b = *(record_t**)v2;
    return (a->avg_real_cost > b->avg_real_cost) ? -1 : 1;
}

static void
item2table(lua_State* L, record_t* v, uint64_t total_cost,uint64_t total_cpu_cost,uint64_t total_real_cost) {
    char s[2] = {0};
    lua_createtable(L,0,14);

    lua_pushstring(L, v->name);
    lua_setfield(L, -2, "name");

    lua_pushstring(L, v->source);
    lua_setfield(L, -2, "source");

    lua_pushinteger(L, v->line);
    lua_setfield(L, -2, "line");

    s[0] = v->flag;
    lua_pushstring(L, s);
    lua_setfield(L, -2, "flag");

    lua_pushinteger(L, v->call_count);
    lua_setfield(L, -2, "call_count");

    lua_pushnumber(L, realtime(v->sum_cost));
    lua_setfield(L, -2, "sum_cost");

    lua_pushnumber(L, realtime(v->cpu_cost));
    lua_setfield(L, -2, "cpu_cost");

    lua_pushnumber(L, realtime(v->real_cost));
    lua_setfield(L, -2, "real_cost");

    lua_pushnumber(L, realtime(v->avg_cost));
    lua_setfield(L, -2, "avg_cost");

    lua_pushnumber(L, realtime(v->avg_cpu_cost));
    lua_setfield(L, -2, "avg_cpu_cost");

    lua_pushnumber(L,realtime(v->avg_real_cost));
    lua_setfield(L,-2,"avg_real_cost");

    double sum_cost_percent = realtime(v->sum_cost)/realtime(total_cost);
    lua_pushnumber(L,sum_cost_percent);
    lua_setfield(L,-2,"sum_cost_percent");

    double cpu_cost_percent = realtime(v->cpu_cost)/realtime(total_cpu_cost);
    lua_pushnumber(L,cpu_cost_percent);
    lua_setfield(L,-2,"cpu_cost_percent");

    double real_cost_percent = realtime(v->real_cost)/realtime(total_real_cost);
    lua_pushnumber(L,real_cost_percent);
    lua_setfield(L,-2,"real_cost_percent");
}


static int
lreport(lua_State* L) {
    profile_context_t* profile = get_profile(L);
    if (!profile) {
        return 0;
    }
    int count = 20;
    if (lua_gettop(L) >= 1) {
        count = luaL_checkinteger(L,1);
    }
    int sort_type = 1;
    if (lua_gettop(L) >= 2) {
        sort_type = luaL_checkinteger(L,2);
    }
    record_t* record = NULL;
    int length = profile->record_list.length;
    uint64_t total_cost = 0;
    uint64_t total_cpu_cost = 0;
    uint64_t total_real_cost = 0;
    for(int i = 0 ; i < length;i ++) {
        record = &profile->record_list.items[i];
        record->avg_cost = record->sum_cost / record->call_count;
        record->avg_cpu_cost = record->cpu_cost / record->call_count;
        record->avg_real_cost = record->real_cost / record->call_count;
        total_cost += record->sum_cost;
        total_cpu_cost += record->cpu_cost;
        total_real_cost += record->real_cost;
        profile->record_list.temp_items[i] = record;
    }
    if (sort_type == 0) {
        qsort((void*)profile->record_list.temp_items, length, sizeof(record_t*), compare0);
    } else if (sort_type == 1) {
        qsort((void*)profile->record_list.temp_items, length, sizeof(record_t*), compare1);
    } else if (sort_type == 2) {
        qsort((void*)profile->record_list.temp_items, length, sizeof(record_t*), compare2);
    } else if (sort_type == 3) {
        qsort((void*)profile->record_list.temp_items, length, sizeof(record_t*), compare3);
    } else if (sort_type == 4) {
        qsort((void*)profile->record_list.temp_items, length, sizeof(record_t*), compare4);
    } else if (sort_type == 5) {
        qsort((void*)profile->record_list.temp_items, length, sizeof(record_t*), compare5);
    } else if (sort_type == 6) {
        qsort((void*)profile->record_list.temp_items, length, sizeof(record_t*), compare6);
    }

    lua_newtable(L);
    if (count > length) {
        count = length;
    }
    for (int i = 0; i < count; i++) {
        item2table(L,profile->record_list.temp_items[i],total_cost,total_cpu_cost,total_real_cost);
        lua_seti(L, -2, i+1);
    }
    return 1;
}

static int
lmark(lua_State* L) {
    profile_context_t* profile = get_profile(L);
    if (!profile) {
        return 0 ;
    }
    lua_sethook(L, resolve_hook, LUA_MASKCALL | LUA_MASKRET, 0);
    return 0;
}

int
luaopen_profile_c(lua_State* L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        {"start", lstart},
        {"stop", lstop},
        {"report", lreport},
        {"mark",lmark},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}