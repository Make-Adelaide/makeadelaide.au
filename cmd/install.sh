#!/bin/sh

export INSTALL_DIR=${INSTALL_DIR:-$1}

if [ -z "$INSTALL_DIR" ]; then
	>&2 echo "INSTALL_DIR not set!"
	exit 1
fi

make install
