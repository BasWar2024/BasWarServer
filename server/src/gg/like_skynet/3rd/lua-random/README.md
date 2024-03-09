
==============

 http://marc-b-reynolds.github.io/shf/2016/04/19/prns.html


====

 `gcc --shared -o random.dll random.c`  lua 

 random.c  host  `luaL_requiref(L, "random", luaopen_random, 0);`

API
===

 g = random(seed)  g g  math.random seed 

 [0,1)  [1, n]  [m,n] 

 C  C  Lua API 

`void random_init(struct random_t *rd, uint64_t seed)`  seed 

`uint64_t random_get(struct random_t *rd)`  64 

`int random_range(struct random_t *rd, int range)`  [0, range) 
