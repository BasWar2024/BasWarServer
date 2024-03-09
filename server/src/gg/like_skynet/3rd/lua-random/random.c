// Marc B. Reynolds, 2013-2016
// Public Domain under http://unlicense.org, see link for details.
//
// Documentation: http://marc-b-reynolds.github.io/shf/2016/04/19/prns.html
//
// Modified by Cloud Wu

#include "random.h"

#ifndef PRNS_WEYL
#define PRNS_WEYL   0x61c8864680b583ebL
#define PRNS_WEYL_I 0x0e217c1e66c88cc3L
#endif

#ifndef PRNS_WEYL_D
#define PRNS_WEYL_D 0x4f1bbcdcbfa54001L
#endif

#ifndef PRNS_MIX_S0
#ifdef  PRNS_MIX_13
#define PRNS_MIX_S0 30
#define PRNS_MIX_S1 27
#define PRNS_MIX_S2 31
#define PRNS_MIX_M0 0xbf58476d1ce4e5b9L
#define PRNS_MIX_M1 0x94d049bb133111ebL
#else
#define PRNS_MIX_S0 31
#define PRNS_MIX_S1 27
#define PRNS_MIX_S2 33
#define PRNS_MIX_M0 0x7fb5d329728ea185L
#define PRNS_MIX_M1 0x81dadef4bc2dd44dL
#endif
#endif

#ifndef PRNS_MIX
#ifndef PRNS_SMALLCRUSH
#define PRNS_MIX(X) prns_mix(X)
#else
#define PRNS_MIX(X) prns_min_mix(X)
#endif
#endif

#ifndef PRNS_MIX_D
#ifndef PRNS_SMALLCRUSH
#define PRNS_MIX_D(X) prns_mix(X)
#else
#define PRNS_MIX_D(X) prns_min_mix(X)
#endif
#endif

static inline uint64_t
prns_mix(uint64_t x) {
	x ^= (x >> PRNS_MIX_S0);
	x *= PRNS_MIX_M0;
	x ^= (x >> PRNS_MIX_S1);
	x *= PRNS_MIX_M1;

#ifndef PRNS_NO_FINAL_XORSHIFT
	x ^= (x >> PRNS_MIX_S2);
#endif

	return x;
}

void
random_init(struct random_t *rd, uint64_t seed) {
	rd->x = PRNS_MIX(PRNS_WEYL*seed) + PRNS_WEYL_D;
}

uint64_t
random_get(struct random_t *rd) {
	uint64_t i = rd->x;
	uint64_t r = PRNS_MIX_D(i);
	rd->x = i + PRNS_WEYL_D;
	return r;
}

// random [0, range)
int
random_range(struct random_t *rd, int range) {
	uint64_t x = random_get(rd);
	return (int)(x % range);
}