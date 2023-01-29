package main

import (
	"math/big"
	"testing"
	"encoding/hex"

	"github.com/stretchr/testify/assert"

	ethCrypto "github.com/ethereum/go-ethereum/crypto"
	ethCommon "github.com/ethereum/go-ethereum/common"
)

var testCalldata, _ = hex.DecodeString(`13f8ffc7000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000000000000000000000006221a9c005f6e47eb398fd867784cacfdcfff4e70000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000041b2784d8dd43b582c5330745b74cba80ec1a2d657315caf4af563a871b69ea6b153dd3442511589e1de5567523d2dd2dcd64b8d8cc1db5b1f403164abc27a8d591b00000000000000000000000000000000000000000000000000000000000000`)

var (
	privateKey, _ = ethCrypto.HexToECDSA("253bb914d7ce5226ddc1004b694d705b5944171e9ad05bc26f99886c50d1debf")
	recipient = ethCommon.HexToAddress("0x6221A9c005F6e47EB398fD867784CacfDcFFF4E7")
	amount, _     = new(big.Int).SetString("10000000000000000000", 10)
	nonce         = new(big.Int).SetInt64(1)
	chainId       = new(big.Int).SetInt64(1)
)

func TestFullCalldata(t *testing.T) {
	calldata, err := constructMintCalldata(
		privateKey,
		nonce,
		chainId,
		recipient,
		amount,
	)

	assert.Nil(t, err)

	assert.Equal(
		t,
		calldata,
		testCalldata,
		"calldata in hex not equal",
	)
}
