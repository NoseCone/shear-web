all: shearWeb

VENDOR_CSS_DIR := vendor/css
VENDORED_CSS := $(VENDOR_CSS_DIR)/bulma-0.9.3.css $(VENDOR_CSS_DIR)/layout.svelte-a0a62b13.css

vendor-css: $(VENDORED_CSS)

$(VENDOR_CSS_DIR):
	mkdir -p $(VENDOR_CSS_DIR)

$(VENDOR_CSS_DIR)/bulma-0.9.3.css: | $(VENDOR_CSS_DIR)
	curl -fsSL https://cdn.jsdelivr.net/npm/bulma@0.9.3/css/bulma.css -o $@

$(VENDOR_CSS_DIR)/layout.svelte-a0a62b13.css: | $(VENDOR_CSS_DIR)
	curl -fsSL http://svelte.flaretiming.com/_app/assets/pages/__layout.svelte-a0a62b13.css -o $@

site.css: vendor-css shearWeb-bridge.css
	cat $(VENDORED_CSS) > $@.tmp
	python3 scripts/transform_css.py $@.tmp $@.tmp
	cat shearWeb-bridge.css >> $@.tmp
	mv $@.tmp $@

cssAsset.ur: site.css
	python3 -c "import json,pathlib; css=pathlib.Path('site.css').read_text(); pathlib.Path('cssAsset.ur').write_text('val content = ' + json.dumps(css) + '\\n')"

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

# SEE: https://github.com/kgabis/parson
parson.o: parson.c parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c parson.c -o parson.o

compFetch.o: compFetch.c compFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compFetch.c -o compFetch.o

compParse.o: compParse.c compParse.h parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compParse.c -o compParse.o

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
