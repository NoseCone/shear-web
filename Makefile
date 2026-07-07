all: shearWeb

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

# SEE: https://github.com/kgabis/parson
parson.o: ffi/parson.c ffi/parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c ffi/parson.c -o parson.o

compFetch.o: ffi/compFetch.c ffi/compFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c ffi/compFetch.c -o compFetch.o

compParse.o: ffi/compParse.c ffi/compParse.h ffi/parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c ffi/compParse.c -o compParse.o

shearWeb: parson.o compFetch.o compParse.o
	urweb shearWeb -protocol http

run: shearWeb
	./shearWeb.exe

clean:
	rm -f shearWeb.exe
	rm -f parson.o
	rm -f compFetch.o
	rm -f compParse.o
	rm -f site.css
	rm -f cssAsset.ur
