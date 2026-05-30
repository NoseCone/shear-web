all: site

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

compFetch.o: compFetch.c compFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compFetch.c -o compFetch.o

site: compFetch.o
	urweb site -protocol http

run: site
	./site.exe

clean:
	rm -f site.exe
	rm -f compFetch.o
