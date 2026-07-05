all: shearWeb

VENDOR_CSS_DIR := vendor/css
VENDORED_CSS := $(VENDOR_CSS_DIR)/ft-styles.css

vendor-css: $(VENDORED_CSS)

$(VENDOR_CSS_DIR):
	mkdir -p $(VENDOR_CSS_DIR)

$(VENDOR_CSS_DIR)/ft-styles.css: | $(VENDOR_CSS_DIR)
	curl -fsSL http://2017-dalby.flaretiming.com/styles.css -o $@

site.css: vendor-css
	cat $(VENDORED_CSS) > $@

cssAsset.ur: site.css
	printf 'val content = %s\n' "$$(jq -Rs '.' site.css)" > $@

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

# SEE: https://github.com/kgabis/parson
parson.o: ffi/parson.c ffi/parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c ffi/parson.c -o parson.o

compFetch.o: ffi/compFetch.c ffi/compFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c ffi/compFetch.c -o compFetch.o

compParse.o: ffi/compParse.c ffi/compParse.h ffi/parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c ffi/compParse.c -o compParse.o

shearWeb: parson.o compFetch.o compParse.o cssAsset.ur site.css
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
