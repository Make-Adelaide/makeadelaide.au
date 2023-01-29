
.PHONY: install

FIND := find . -mindepth 1 -maxdepth 1

install:
	@${FIND} -type d | xargs -I {} sh -c 'cd {} && ${MAKE} install'
	@${FIND} -type f -executable | xargs -I {} sh -c 'cp {} ${INSTALL_DIR}'
