#ifndef _IMAP_H_
#define _IMAP_H_

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

enum imap_status {
    IS_NONE,
    IS_EXIST,
    IS_REMOVE,
};

struct imap_slot {
    uint64_t key;
    void* value;
    struct imap_slot* next;
    enum imap_status status;
};

struct imap_context {
    struct imap_slot* slots;
    size_t size;
    size_t count;
    struct imap_slot* lastfree;
};

struct imap_context* imap_create();
void imap_free(struct imap_context* imap);

// the value is no-null point
void imap_set(struct imap_context* imap, uint64_t key, void* value);

void* imap_remove(struct imap_context* imap, uint64_t key);
void* imap_get(struct imap_context* imap, uint64_t key);

#define IMAP_FOREACH(imap,code) { \
    for(size_t i=0; i<imap->size; i++) { \
        struct imap_slot* item = &imap->slots[i]; \
        if (item->value) { \
            code; \
        } \
    } \
}

#define IMAP_ITEM_VALUE(item) item->value

#endif
