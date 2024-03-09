#include "i18n.h"

inline static i18n_text_t*
remove_from_textpool(i18n_context_t* i18n) {
    i18n_text_t* text = NULL;
    if (i18n->textpool) {
        text = i18n->textpool;
        i18n->textpool = text->next;
        text->next = NULL;
        text->inpool = false;
    }
    return text;
}

inline static void
add_to_textpool(i18n_context_t* i18n,i18n_text_t* text) {
    assert(text->i18n != NULL);
    assert(text->next == NULL);
    text->inpool = true;
    if (i18n->textpool) {
        text->next = i18n->textpool;
    } else {
        text->next = NULL;
    }
    i18n->textpool = text;
    for (int i=0; i<text->narg; i++) {
        add_to_textpool(i18n,text->args[i]);
        text->args[i] = NULL;
    }
    text->narg = 0;
}

inline static i18n_text_t*
_i18n_new_text(i18n_context_t* i18n) {
    i18n_text_t* text = (i18n_text_t*)malloc(sizeof(i18n_text_t));
    text->id = INVALID_TEXT_ID;
    text->fmt = NULL;
    text->fmt_size = 0;
    text->narg = 0;
    text->next = NULL;
    text->i18n = i18n;
    text->inpool = false;
    for (int i=0; i<ARG_MAX_NUM; i++) {
        text->args[i] = NULL;
    }
    return text;
}

i18n_text_t*
i18n_new_text(i18n_context_t* i18n,int fmt_id,const char* fmt,i18n_text_t** args,size_t narg) {
    i18n_text_t* text = remove_from_textpool(i18n);
    if (text == NULL) {
        text = _i18n_new_text(i18n);
    }
    text->id = fmt_id;
    if (fmt != NULL) {
        size_t len = strlen(fmt)+1;
        if (len > TEXT_MAX_LENGTH) {
            len = TEXT_MAX_LENGTH;
        }
        if (text->fmt_size < len) {
            if (text->fmt != NULL) {
                free(text->fmt);
            }
            text->fmt_size = len;
            text->fmt = (char*)malloc(text->fmt_size*sizeof(char));
        }
        memcpy(text->fmt,fmt,len);
        text->fmt[len-1] = '\0';
    }
    assert(narg <= ARG_MAX_NUM);
    text->narg = narg;
    for (int i=0; i<narg; i++) {
        text->args[i] = args[i];
    }
    return text;
}

void
_i18n_free_text(i18n_context_t* i18n,i18n_text_t* text) {
    (void)i18n;
    i18n_text_t* arg = NULL;
    for (int i=0; i<ARG_MAX_NUM; i++) {
        arg = text->args[i];
        if (arg) {
            _i18n_free_text(i18n,arg);
        }
    }
    if (text->fmt != NULL) {
        free(text->fmt);
    }
    free(text);
}

void
i18n_free_text(i18n_context_t* i18n,i18n_text_t* text) {
    if (text->inpool) {
        return;
    }
    add_to_textpool(i18n,text);
}

i18n_context_t*
i18n_new(size_t nlang,size_t translate_size) {
    if (translate_size == 0) {
        translate_size = DEFAULT_INIT_SIZE;
    }
    i18n_context_t *i18n = (i18n_context_t*)malloc(sizeof(i18n_context_t));
    i18n->maxid = 0;
    i18n->nlang = nlang;
    i18n->translate_size = translate_size;
    i18n->translates = (int*)calloc(nlang*translate_size,sizeof(int));
    i18n->text_size = nlang * translate_size;
    i18n->texts = (char**)calloc(i18n->text_size,sizeof(char*));
    i18n->textpool = NULL;
    i18n_text_t* text = NULL;
    int size = DEFAULT_INIT_SIZE;
    for (int i=0; i<size; i++) {
        text = _i18n_new_text(i18n);
        add_to_textpool(i18n,text);
    }
    return i18n;
}

void
i18n_free(i18n_context_t *i18n) {
    i18n_text_t *text;
    while((text=remove_from_textpool(i18n)) != NULL) {
        _i18n_free_text(i18n,text);
    }
    free(i18n->translates);
    for (int id=0; id <= i18n->maxid; id++) {
        if (i18n->texts[id]) {
            free(i18n->texts[id]);
        }
    }
    free(i18n->texts);
    free(i18n);
}

int
i18n_add_text(i18n_context_t* i18n,const char* str,int id) {
    if (id != 0) {
        if (id > i18n->maxid) {
            i18n->maxid = id;
        }
    } else {
        i18n->maxid++;
        id = i18n->maxid;
    }
    if (id >= i18n->text_size) {
        int old_text_size = i18n->text_size;
        while (id >= i18n->text_size) {
            i18n->text_size *= 2;
        }
        i18n->texts = (char**)realloc(i18n->texts,i18n->text_size*sizeof(char*));
        for (int i=old_text_size; i<i18n->text_size; i++) {
            i18n->texts[i] = NULL;
        }
    }
    assert(i18n->texts[id] == NULL);
    size_t len = strlen(str) + 1;
    if (len > TEXT_MAX_LENGTH) {
        len = TEXT_MAX_LENGTH;
    }
    i18n->texts[id] = (char*)malloc(len*sizeof(char));
    memcpy(i18n->texts[id],str,len);
    i18n->texts[id][len-1] = '\0';
    return id;
}

inline static int*
index_translate(i18n_context_t* i18n,int id) {
    return &i18n->translates[id*i18n->nlang];
}

void
i18n_add_translate(i18n_context_t* i18n,int lang,int from,int to) {
    assert(lang < i18n->nlang);
    if (i18n->texts[from] == NULL) {
        return;
    }
    if (i18n->texts[to] == NULL) {
        return;
    }
    if (from >= i18n->translate_size) {
        int old_translate_size = i18n->translate_size;
        while(from >= i18n->translate_size) {
            i18n->translate_size = i18n->translate_size * 2;
        }
        i18n->translates = (int*)realloc(i18n->translates,i18n->nlang*i18n->translate_size*sizeof(int));
        for (int i = old_translate_size*i18n->nlang; i < i18n->translate_size*i18n->nlang; i++) {
            i18n->translates[i] = 0;
        }
    }
    int *it = index_translate(i18n,from);
    it[lang] = to;
}

inline static const char*
unpack_text(i18n_context_t* i18n,int text_id,int lang) {
    const char* text = NULL;
    if (text_id >= i18n->translate_size) {
        text = i18n->texts[text_id];
    } else {
        int *it = index_translate(i18n,text_id);
        int to_id = it[lang];
        if (to_id != 0) {
            text = i18n->texts[to_id];
        } else {
            text = i18n->texts[text_id];
        }
    }
    return text;
}

i18n_text_t*
i18n_format(i18n_context_t* i18n, int fmt, i18n_text_t** args, size_t narg) {
    assert(fmt <= i18n->text_size);
    i18n_text_t* text = i18n_new_text(i18n,fmt,NULL,args,narg);
    return text;
}

static const char*
_i18n_translateto(i18n_context_t* i18n, int lang, i18n_text_t* text,char* result,size_t result_size) {
    assert(lang < i18n->nlang);
    const char* fmt = text->fmt;
    if (text->id != INVALID_TEXT_ID) {
        fmt = unpack_text(i18n,text->id,lang);
        if (fmt == NULL) {
            // if A node's texts diffrence B node's texts,maybe fmt will be NULL,compat it
            fmt = text->fmt;
        }
    }
    if (text->narg > 0) {
        for (int i=0; i < text->narg; i++) {
            _i18n_translateto(i18n,lang,text->args[i],i18n->args[i],result_size);
        }
    }
    // replace
    int arg_index = 0;
    size_t len = 0;
    bool open = false;
    const char* open_fmt = NULL;
    const char* last_fmt = fmt;
    const char* arg_str = NULL;
    int arg_len = 0;
    char ch = 0;
    while((ch=*fmt++) != 0) {
        arg_len = 0;
        switch(ch) {
            case '{':
                open = true;
                open_fmt = fmt - 1;
                arg_index = 0;

                arg_str = last_fmt;
                arg_len = open_fmt - last_fmt;
                last_fmt = open_fmt;
                break;
            case '0': case '1': case '2': case '3': case '4':
            case '5': case '6': case '7': case '8': case '9':
                if (open) {
                    arg_index = arg_index*10 + (ch - '0');
                }
                break;
            case '}':
                if (!open) {
                    arg_str = last_fmt;
                    arg_len = fmt - last_fmt;
                } else {
                    open = false;
                    if (arg_index < text->narg) {
                        arg_str = i18n->args[arg_index];
                        arg_len = strlen(arg_str);
                    } else {
                        arg_str = open_fmt;
                        arg_len = fmt - open_fmt;
                    }
                }
                last_fmt = fmt;
                break;
            default:
                open = false;
                break;
        }
        if (arg_len > 0) {
            if (len + arg_len >= result_size) {
                result[len] = '\0';
                return result;
            } else {
                memcpy(result+len,arg_str,arg_len);
                len = len + arg_len;
            }
        }
    }
    arg_len = fmt - last_fmt;
    if (arg_len > 0) {
        if (len + arg_len >= result_size) {
        } else {
            memcpy(result+len,last_fmt,arg_len);
            len = len + arg_len;
        }
    }
    result[len] = '\0';
    return result;
}

const char*
i18n_translateto(i18n_context_t* i18n,int lang,i18n_text_t* text) {
    _i18n_translateto(i18n,lang,text,i18n->result,TEXT_MAX_LENGTH);
    // ,luagc
    //i18n_free_text(i18n,text);
    return (const char*)i18n->result;
}

inline static int
write_buffer(char** buffer,int* buffer_len,void* source,int len) {
    if (*buffer_len < len) {
        return 0;
    }
    char* buf = *buffer;
    memcpy(buf,source,len);
    *buffer += len;
    *buffer_len -= len;
    return len;
}

inline static int
read_buffer(const char** buffer,int* buffer_len, void* dest,int len) {
    if (*buffer_len < len) {
        return 0;
    }
    memcpy(dest,*buffer,len);
    *buffer += len;
    *buffer_len -= len;
    return len;
}

int
i18n_serialize_text(i18n_context_t* i18n,i18n_text_t* text, char* buffer,int buffer_len) {
    int len = 0;
    char* fmt = text->fmt;
    if (text->id != INVALID_TEXT_ID) {
        fmt = i18n->texts[text->id];
    }
    int fmt_id = text->id;
    if (fmt_id >= i18n->translate_size) {
        fmt_id = INVALID_TEXT_ID;
    }
    int write_len = write_buffer(&buffer,&buffer_len,&fmt_id,sizeof(fmt_id));
    if (write_len <= 0) {
        return 0;
    }
    len += write_len;
    size_t fmt_len = strlen(fmt);
    write_len = write_buffer(&buffer,&buffer_len,&fmt_len,sizeof(fmt_len));
    if (write_len <= 0) {
        return 0;
    }
    len += write_len;
    write_len = write_buffer(&buffer,&buffer_len,fmt,fmt_len);
    if (write_len <= 0) {
        return 0;
    }
    len += write_len;
    write_len = write_buffer(&buffer,&buffer_len,&text->narg,sizeof(text->narg));
    if (write_len <= 0) {
        return 0;
    }
    len += write_len;
    for (int i=0; i<text->narg; i++) {
        write_len = i18n_serialize_text(i18n,text->args[i],buffer,buffer_len);
        if (write_len <= 0) {
            return 0;
        }
        len += write_len;
        buffer += write_len;
        buffer_len -= write_len;
    }
    return len;
}

i18n_text_t*
i18n_deserialize_text(i18n_context_t* i18n,const char* buffer, int* buffer_len) {
    int fmt_id = 0;
    if (read_buffer(&buffer,buffer_len,&fmt_id,sizeof(fmt_id)) <= 0) {
        return NULL;
    }
    size_t fmt_len = 0;
    if (read_buffer(&buffer,buffer_len,&fmt_len,sizeof(fmt_len)) <= 0) {
        return NULL;
    }
    char* fmt = i18n->result;
    if (read_buffer(&buffer,buffer_len,fmt,fmt_len) <= 0) {
        return NULL;
    }
    fmt[fmt_len] = '\0';
    size_t narg = 0;
    if (read_buffer(&buffer,buffer_len,&narg,sizeof(narg)) <= 0) {
        return NULL;
    }
    i18n_text_t* text = i18n_new_text(i18n,fmt_id,fmt,NULL,0);
    for (int i = 0; i < narg; i++) {
        int old_buffer_len = *buffer_len;
        text->args[i] = i18n_deserialize_text(i18n,buffer,buffer_len);
        if (text->args[i] == NULL) {
            i18n_free_text(i18n,text);
            return NULL;
        }
        buffer += (old_buffer_len - *buffer_len);
    }
    text->narg = narg;
    return text;
}

const char*
i18n_tostring(i18n_context_t* i18n,i18n_text_t* text) {
    return i18n_translateto(i18n,ORIGINAL_LANG_ID,text);
}