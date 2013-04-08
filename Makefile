COFFEE=coffee

ALL_JS=parsnip

COFFEE_FILES=$(addprefix src/, Port.coffee From.coffee Result.coffee Core.coffee\
	Matchers.coffee Combinators.coffee Parser.coffee)

JS_FILES=$(patsubst src/%.coffee, build/%.js, $(COFFEE_FILES))

all: browser minify
	cd json; make

build/%.js: src/%.coffee
	mkdir -p build
	echo '(function (exports) {' > $@
	$(COFFEE) --bare -p $< >> $@
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
	vows --spec spec/* json/spec/*

clean:
	-rm build/*
	-rm -r build
	-rm dist/*
	-rm -r dist
