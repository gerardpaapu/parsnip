COFFEE=coffee

ALL_JS=parsnip

COFFEE_FILES=$(addprefix src/, Port.coffee From.coffee Result.coffee Core.coffee\
	Matchers.coffee Combinators.coffee Parser.coffee)

JS_FILES=$(patsubst src/%.coffee, build/%.js, $(COFFEE_FILES))


build/%.js: src/%.coffee
	mkdir -p build
	echo '(function (exports) {' > $@
	$(COFFEE) --bare -p $< >> $@
	echo "}.call(null, modules['./"$(basename $(notdir $@))"'] = {}));" >> $@

build/$(ALL_JS).js: $(JS_FILES) src/prefix.txt src/suffix.txt
	cat src/prefix.txt > $@
	cat $(JS_FILES) >> $@
	cat src/suffix.txt >> $@

build/%.min.js: build/%.js
	uglifyjs $< > $@

default: build/$(ALL_JS).js
	
minify: build/$(ALL_JS).min.js

test:
	vows --spec spec/* json/spec/*

clean:
	-rm build/*
	-rm -r build
