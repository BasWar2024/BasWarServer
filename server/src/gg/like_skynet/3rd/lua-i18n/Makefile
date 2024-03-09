.PHONY : all linux test benchmark clean

all : linux

linux : i18n.so

i18n.so: i18n.c lua-i18n.c
	gcc -std=c99 -O2 -g -Wall -fPIC --shared -o i18n.so i18n.c lua-i18n.c

test: i18n.so
	lua test.lua

benchmark: i18n.so
	lua benchmark.lua

clean:
	rm -rf i18n.so

