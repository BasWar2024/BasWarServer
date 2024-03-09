#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdbool.h>

#define ARG_MAX_NUM (10)
#define TEXT_MAX_LENGTH (10*1024)
#define DEFAULT_INIT_SIZE (32)
#define INVALID_TEXT_ID (-1)
#define ORIGINAL_LANG_ID (0)

struct i18n_context_t;

typedef struct i18n_text_t {
    int id;
    size_t fmt_size;
    char* fmt;
    size_t narg;
    struct i18n_text_t* args[ARG_MAX_NUM];
    struct i18n_text_t *next;
    struct i18n_context_t* i18n;
    bool inpool;
} i18n_text_t;

typedef struct i18n_context_t {
    int maxid;
    size_t nlang;
    size_t text_size;
    char** texts;
    size_t translate_size;
    int* translates;
    i18n_text_t* textpool;
    char args[ARG_MAX_NUM][TEXT_MAX_LENGTH];
    char result[TEXT_MAX_LENGTH];
    char result2[TEXT_MAX_LENGTH];
} i18n_context_t;

i18n_context_t*
i18n_new(size_t nlang,size_t translate_size);

void
i18n_free(i18n_context_t* i18n);

i18n_text_t*
i18n_new_text(i18n_context_t* i18n,int fmt_id,const char* fmt,i18n_text_t** args,size_t narg);

void
i18n_free_text(i18n_context_t* i18n,i18n_text_t* text);

int
i18n_add_text(i18n_context_t* i18n,const char* str,int id);

void
i18n_add_translate(i18n_context_t* i18n,int lang,int from,int to);

i18n_text_t*
i18n_format(i18n_context_t* i18n, int fmt, i18n_text_t** args, size_t narg);

const char*
i18n_translateto(i18n_context_t* i18n,int lang,i18n_text_t* text);

int
i18n_serialize_text(i18n_context_t* i18n,i18n_text_t* text, char* buffer,int buffer_len);

i18n_text_t*
i18n_deserialize_text(i18n_context_t* i18n,const char* buffer, int* buffer_len);

const char*
i18n_tostring(i18n_context_t* i18n,i18n_text_t* text);