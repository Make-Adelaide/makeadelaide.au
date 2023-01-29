
OUT := ${CMD}.out

GO_BUILD := go build

.PHONY: build clean install

build: ${OUT}

${OUT}: $(shell find . -type f -name '*.go')
	@${GO_BUILD} -o ${OUT}

install: ${OUT}
	@if [ -z "${INSTALL_DIR}" ]; then >& 'INSTALL_DIR not set!'; fi
	@cp ${OUT} $${INSTALL_DIR}/${CMD}
