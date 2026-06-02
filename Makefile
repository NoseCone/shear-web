all: shear-web

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

# SEE: https://github.com/kgabis/parson
parson.o: parson.c parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c parson.c -o parson.o

compFetch.o: compFetch.c compFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compFetch.c -o compFetch.o

compParse.o: compParse.c compParse.h parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compParse.c -o compParse.o

shear-web: parson.o compFetch.o compParse.o
	urweb shear-web -protocol http

run: shear-web
	./shear-web.exe

clean:
	rm -f shear-web.exe
	rm -f parson.o
	rm -f compFetch.o
	rm -f compParse.o
