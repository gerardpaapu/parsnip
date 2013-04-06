COFFEE=coffee

COFFEE_FILES=src/Port.coffee src/From.coffee src/Result.coffee src/Core.coffee\
	src/Matchers.coffee src/Combinators.coffee src/Parser.coffee

JS_FILES=$(patsubst src/%.coffee, build/%.js, $(COFFEE_FILES))


build/%.js: src/%.coffee
	mkdir -p build
	echo '(function (exports) {' > $@
	$(COFFEE) --bare -p $< >> $@
	echo "}.call(null, modules['./"$(basename $(notdir $@))"']));" >> $@

build/all.js: $(JS_FILES) src/prefix.txt src/suffix.txt
	cat src/prefix.txt > $@
	cat $(JS_FILES) >> $@
	cat src/suffix.txt >> $@

all:
	build/all.js

test:
	vows --spec spec/*

clean:
	-rm $(JS_FILES) build/all.js
	-rm -r build
