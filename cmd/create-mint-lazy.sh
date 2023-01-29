#!/bin/sh -e

account="$(create-account)"

private_key="$(echo $account | cut -d, -f1)"
public_key="$(echo $account | cut -d, -f2)"

export \
	MADL_RECIPIENT="$public_key" \
	MADL_MINT_NONCE=1

create-mint


