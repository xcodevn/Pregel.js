PATH := ./node_modules/.bin:${PATH}
V = @ 					# verbose 

.PHONY : init clean-docs clean build test dist publish

init:
		npm install

docs:
		docco src/*.coffee

clean-docs:
		rm -rf docs/

clean: clean-docs
		rm -rf lib/ test/*.js

build:
		$(V)coffee -o lib/ -c src/ && coffee -c test/pregel.coffee

shell:
		$(V)coffee 

test:
		$(V)nodeunit test/pregel.js

dist: clean init docs build test

publish: dist
		npm publish
