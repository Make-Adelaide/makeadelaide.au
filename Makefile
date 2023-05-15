
.PHONY: build clean test

all: build

BUILD_FILES := $(shell find contracts -type f)

ADMIN_ARTIFACT := artifacts/contracts/Admin.vy/Admin.json

test:
	@npx hardhat test
