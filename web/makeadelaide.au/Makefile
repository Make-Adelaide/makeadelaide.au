
.PHONY: build watch

build/index.html: index.html
	@cp index.html build/index.html

build/index.css: index.sass
	@sass index.sass >build/index.css

build: build/index.html build/index.css

watch:
	@ls -1 index.html index.sass | entr -sr 'clear && ${MAKE} -j2 build'
