all: site

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

compsFetch.o: compsFetch.c compsFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compsFetch.c -o compsFetch.o

site: compsFetch.o
	urweb site -protocol http

run: site
	./site.exe

clean:
	rm -f site.exe
	rm -f compsFetch.o
