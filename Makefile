all: shearWeb

VENDOR_CSS_DIR := vendor/css
VENDORED_CSS := $(VENDOR_CSS_DIR)/bulma-0.9.3.min.css $(VENDOR_CSS_DIR)/layout.svelte-a0a62b13.css

vendor-css: $(VENDORED_CSS)

$(VENDOR_CSS_DIR):
	mkdir -p $(VENDOR_CSS_DIR)

$(VENDOR_CSS_DIR)/bulma-0.9.3.min.css: | $(VENDOR_CSS_DIR)
	curl -fsSL https://cdn.jsdelivr.net/npm/bulma@0.9.3/css/bulma.min.css -o $@

$(VENDOR_CSS_DIR)/layout.svelte-a0a62b13.css: | $(VENDOR_CSS_DIR)
	curl -fsSL http://svelte.flaretiming.com/_app/assets/pages/__layout.svelte-a0a62b13.css -o $@

site.css: vendor-css
	cat $(VENDORED_CSS) > $@.tmp
	perl -0pi \
	  -e 's/\.container\b/.ShearWeb_container/g' \
	  -e 's/\.spacer\b/.ShearWeb_spacer/g' \
	  -e 's/\.content\b/.ShearWeb_content/g' \
	  -e 's/\.tile\b/.ShearWeb_tile/g' \
	  -e 's/\.is-ancestor\b/.ShearWeb_is_ancestor/g' \
	  -e 's/\.is-parent\b/.ShearWeb_is_parent/g' \
	  -e 's/\.notification\b/.ShearWeb_notification/g' \
	  -e 's/\.is-light\b/.ShearWeb_is_light/g' \
	  -e 's/\.subtitle\b/.ShearWeb_subtitle/g' \
	  -e 's/\.is-vertical\b/.ShearWeb_is_vertical/g' \
	  -e 's/\.is-5\b/.ShearWeb_is_5/g' \
	  -e 's/\.is-child\b/.ShearWeb_is_child/g' \
	  -e 's/\.box\b/.ShearWeb_box/g' \
	  -e 's/\.is-7\b/.ShearWeb_is_7/g' \
	  -e 's/\.footer\b/.ShearWeb_footer_cls/g' \
	  -e 's/\.is-size-7\b/.ShearWeb_is_size_7/g' \
	  $@.tmp
	mv $@.tmp $@

siteCssAsset.ur: site.css
	python3 -c "import json,pathlib; css=pathlib.Path('site.css').read_text(); pathlib.Path('siteCssAsset.ur').write_text('val content = ' + json.dumps(css) + '\\n')"

URWEB_CINCLUDE := $(shell urweb -print-cinclude)

# SEE: https://github.com/kgabis/parson
parson.o: parson.c parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c parson.c -o parson.o

compFetch.o: compFetch.c compFetch.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compFetch.c -o compFetch.o

compParse.o: compParse.c compParse.h parson.h
	cc -fPIC -O2 -I $(URWEB_CINCLUDE) -c compParse.c -o compParse.o

shearWeb: parson.o compFetch.o compParse.o siteCssAsset.ur site.css
	urweb shearWeb -protocol http

run: shearWeb
	./shearWeb.exe

clean:
	rm -f shearWeb.exe
	rm -f parson.o
	rm -f compFetch.o
	rm -f compParse.o
	rm -f site.css
	rm -f siteCssAsset.ur
