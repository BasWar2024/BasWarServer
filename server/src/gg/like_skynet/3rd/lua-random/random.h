#ifndef RANDOM_H
#define RANDOM_H

#include <stdint.h>

struct random_t {
	uint64_t x;
};



void random_init(struct random_t *rd, uint64_t seed);
uint64_t random_get(struct random_t *rd);
int random_range(struct random_t *rd, int range);

#endif