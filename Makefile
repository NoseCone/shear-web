all: shearWeb

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

comp-json/compFetch.o: comp-json/ffi/compFetch.c comp-json/ffi/compFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c comp-json/ffi/compFetch.c -o comp-json/compFetch.o

shearWeb: comp-json/compFetch.o
	urweb shearWeb -protocol http

run: shearWeb
	./shearWeb.exe

clean:
	rm -f shearWeb.exe
	rm -f comp-json/compJson.exe
	rm -f comp-json/compFetch.o
	rm -f site.css
	rm -f cssAsset.ur
