
JS = build/acorn.player.js

CSS = build/acorn.player.css

JS_SRC = $(shell find coffee | grep .coffee | sed 's/coffee\//build\/js-compiled\//g' | sed 's/\.coffee/\.js/g' )


all: build

.PHONY: clean test watch

test:
	# probably broken?
	@npm test

clean:
	rm -rf -- build


# css
build/acorn.player.css: less/acorn-player.less
	@mkdir -p `dirname $@`
	@rm -f $@
	node_modules/.bin/lessc $< $@

build/acorn.player.min.css: build/acorn.player.css
	@mkdir -p `dirname $@`
	@rm -f $@
	cat $< | node_modules/.bin/cssmin > $@


# coffee
build/js-compiled/%.js: coffee/%.coffee
	@mkdir -p `dirname $@`
	@rm -f $@
	node_modules/.bin/coffee -b -p -c $< > $@


# js
build/acorn.player.js: $(JS_SRC) package.json
	#: $(shell node_modules/.bin/smash --list build/js-compiled/src/)
	# use JS_SRC here because the index.js (for smash --list) is an intermediate
	# file, which gets constructed.
	@mkdir -p `dirname $@`
	@rm -f $@
	node_modules/.bin/smash build/js-compiled/src/ | node_modules/.bin/uglifyjs - -b indent-level=2 -o $@


# minification
build/%.min.js: build/%.js
	@mkdir -p `dirname $@`
	@rm -f $@
	node_modules/.bin/uglifyjs $< > $@


# build
build: build/acorn.player.min.js build/acorn.player.min.css


# dist
dist: build
	cp -r $< $@


# serve
serve:
	@echo "Serving static files..."
	@node_modules/.bin/http-server -p 8000

# watching
watch:
	@echo "Serving static files..."
	@node_modules/.bin/http-server -p 8000 &
	@echo "Watching files for changes..."
	@watchr -e "watch('(less|coffee|lib)\/.*\.(less|coffee|css)') { system 'make' }"

