COFFEE=coffee --bare -p

ALL_JS=parsnip.json

COFFEE_FILES=$(addprefix src/, keyword.coffee Number.coffee\
				 String.coffee Collections.coffee Json.coffee)

JS_FILES=$(patsubst src/%.coffee, build/%.js, $(COFFEE_FILES))

all: browser minify

build/%.js: src/%.coffee
	mkdir -p build
	echo '(function (exports) {' > $@
	$(COFFEE) $< >> $@
	echo "}.call(null, modules['./"$(basename $(notdir $@))"'] = {}));" >> $@

dist/$(ALL_JS).js: $(JS_FILES) src/prefix.txt src/suffix.txt
	mkdir -p dist
	cat src/prefix.txt > $@
	cat $(JS_FILES) >> $@
	cat src/suffix.txt >> $@

%.min.js: %.js
	uglifyjs $< > $@

browser: dist/$(ALL_JS).js
	
minify: dist/$(ALL_JS).min.js

test:
	vows --spec spec/*

clean:
	-rm build/*
	-rm -r build
	-rm dist/*
	-rm -r dist
