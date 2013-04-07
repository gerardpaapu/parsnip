COFFEE=coffee --bare -p

ALL_JS=parsnip.json

COFFEE_FILES=$(addprefix src/, keyword.coffee Number.coffee\
				 String.coffee Collections.coffee Json.coffee)

JS_FILES=$(patsubst src/%.coffee, build/%.js, $(COFFEE_FILES))


build/%.js: src/%.coffee
	mkdir -p build
	echo '(function (exports) {' > $@
	$(COFFEE) $< >> $@
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
	vows --spec spec/*

clean:
	-rm build/*
	-rm -r build
