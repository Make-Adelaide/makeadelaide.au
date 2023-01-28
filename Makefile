
.PHONY: build clean

all: build

BUILD_FILES := $(shell find contracts)

TEST_FILES := $(shell find tests -type f ! -path '*/.pytest_cache/**')

build: build/done

build/done: ${BUILD_FILES}
	@brownie compile
	@touch build/done

test: ${BUILD_FILES} ${TEST_FILES}
	@brownie test
	@touch test

clean:
	@rm -rf build