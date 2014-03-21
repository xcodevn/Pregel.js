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
		coffee -o lib/ -c src/ && coffee -o test -c test/

shell:
		$(V)coffee 

test:
		nodeunit test/pregel.js

run_worker: build
	$(V)coffee test/worker.coffee

run_master: build
	$(V)coffee test/master.coffee

dist: clean init docs build test

publish: dist
		npm publish
