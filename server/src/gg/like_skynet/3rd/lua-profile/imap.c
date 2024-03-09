#include "imap.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

#define pmalloc malloc
#define pfree free
#define pcalloc calloc

#define DEFAULT_IMAP_SLOT_SIZE  8

struct imap_context *
imap_create() {
    struct imap_context* imap = (struct imap_context*)pmalloc(sizeof(*imap));
    imap->slots = (struct imap_slot*)pcalloc(DEFAULT_IMAP_SLOT_SIZE, sizeof(struct imap_slot));
    imap->size = DEFAULT_IMAP_SLOT_SIZE;
    imap->count = 0;
    imap->lastfree = imap->slots + imap->size;
    return imap;
}

void
imap_free(struct imap_context* imap) {
    pfree(imap->slots);
    pfree(imap);
}

static inline uint64_t
_imap_hash(struct imap_context* imap, uint64_t key) {
    //uint64_t hash = key % (uint64_t)(imap->size);
    uint64_t hash = key & (uint64_t)(imap->size - 1);
    return hash;
}

static void
_imap_rehash(struct imap_context* imap) {
    size_t new_sz = DEFAULT_IMAP_SLOT_SIZE;
    struct imap_slot* old_slots = imap->slots;
    size_t old_count = imap->count;
    size_t old_size = imap->size;
    while(new_sz <= imap->count) {
        new_sz *= 2;
    }

    struct imap_slot* new_slots = (struct imap_slot*)pcalloc(new_sz, sizeof(struct imap_slot));
    imap->lastfree = new_slots + new_sz;
    imap->size = new_sz;
    imap->slots = new_slots;
    imap->count = 0;

    size_t i=0;
    for(i=0; i<old_size; i++) {
        struct imap_slot* p = &(old_slots[i]);
        if (p->status == IS_EXIST) {
            imap_set(imap, p->key, p->value);
        }
    }

    assert(old_count == imap->count);
    pfree(old_slots);
}

static struct imap_slot *
_imap_get(struct imap_context* imap, uint64_t key,struct imap_slot** prev) {
    uint64_t hash = _imap_hash(imap, key);
    struct imap_slot* p = &(imap->slots[hash]);
    struct imap_slot *temp = NULL;
    while(p) {
        if(p->key == key && p->status == IS_EXIST) {
            if (prev) {
                *prev = temp;
            }
            return p;
        }
        temp = p;
        p = p->next;
    }
    return NULL;
}

void *
imap_get(struct imap_context* imap, uint64_t key) {
    struct imap_slot* p = _imap_get(imap, key,NULL);
    if(p) {
        return p->value;
    }
    return NULL;
}

static struct imap_slot *
_imap_getfree(struct imap_context* imap) {
    while(imap->lastfree > imap->slots) {
        imap->lastfree--;
        if (imap->lastfree->status == IS_NONE) {
            return imap->lastfree;
        }
    }
    return NULL;
}

void
imap_set(struct imap_context* imap, uint64_t key, void* value) {
    assert(value);
    uint64_t hash = _imap_hash(imap, key);
    struct imap_slot* p = &(imap->slots[hash]);
    if (p->status == IS_EXIST) {
        struct imap_slot* np = p;
        while(np) {
            if(np->key == key) {
                assert(np->status == IS_EXIST);
                np->value = value;
                return;
            }
            np = np->next;
        }

        np = _imap_getfree(imap);
        if(np == NULL) {
            _imap_rehash(imap);
            imap_set(imap, key, value);
            return;
        }

        uint64_t main_hash = _imap_hash(imap, p->key);
        if(main_hash == hash) {
            np->next = p->next;
            p->next = np;
            p = np;
        } else {
            *np = *p;
            struct imap_slot *last = &(imap->slots[main_hash]);
            while (last->next != p) {
                last = last->next;
            }
            last->next = np;
            p->next = NULL;
        }
    }

    imap->count++;
    p->key = key;
    p->value = value;
    p->status = IS_EXIST;
}

void *
imap_remove(struct imap_context* imap, uint64_t key) {
    struct imap_slot* prev = NULL;
    struct imap_slot* p = _imap_get(imap, key,&prev);
    if(p) {
        if (prev) {
            prev->next = p->next;
            p->next = NULL;
        }
        imap->count--;
        void *result = p->value;
        p->value = NULL;
        p->status = IS_REMOVE;
        return result;
    }
    return NULL;
}
