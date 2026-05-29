all: build/index.html

build/index.html: site
	mkdir -p build && ./site.exe /Site/main > build/site.html
	sed -e '1,/^\r\{0,1\}$$/d' build/site.html > $@

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

compsFetch.o: compsFetch.c compsFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compsFetch.c -o compsFetch.o

site: compsFetch.o
	urweb site -protocol static

clean:
	rm -f build/index.html
	rm -f site.exe
	rm -f compsFetch.o

www: build/index.html
	cd build && python3 -m http.server
