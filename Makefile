all: shearWeb

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

# SEE: https://github.com/kgabis/parson
comp-json/parson.o: vendor/parson/parson.c vendor/parson/parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c vendor/parson/parson.c -o comp-json/parson.o

comp-json/compFetch.o: comp-json/ffi/compFetch.c comp-json/ffi/compFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c comp-json/ffi/compFetch.c -o comp-json/compFetch.o

comp-json/compParse.o: comp-json/ffi/compParse.c comp-json/ffi/compParse.h vendor/parson/parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -I vendor/parson -c comp-json/ffi/compParse.c -o comp-json/compParse.o

shearWeb: comp-json/parson.o comp-json/compFetch.o comp-json/compParse.o
	urweb shearWeb -protocol http

run: shearWeb
	./shearWeb.exe

clean:
	rm -f shearWeb.exe
	rm -f comp-json/parson.o
	rm -f comp-json/compFetch.o
	rm -f comp-json/compParse.o
	rm -f site.css
	rm -f cssAsset.ur
