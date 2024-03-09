all:linux

macosx:
	clang -undefined dynamic_lookup --shared -Wall -g -O2 -std=gnu99 -ldl\
		-o profile.so \
		imap.c profile.c

linux:
	gcc -shared -fPIC -Wall -g -O2 -std=gnu99 -lrt\
		-o profile.so \
		imap.c profile.c

clean:
	rm -rf profile.so

.PHONY : all clean macosx linux