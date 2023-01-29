package main

import (
	"crypto/ecdsa"
	"fmt"
	"encoding/hex"
	"log"
	"math/big"
	"os"

	ethAbi "github.com/ethereum/go-ethereum/accounts/abi"
	ethCommon "github.com/ethereum/go-ethereum/common"
	ethCrypto "github.com/ethereum/go-ethereum/crypto"
)

// SignaturePreamble added by most tooling to prevent signing arbitrary
// messages
const SignaturePreamble = "\x19Ethereum Signed Message:\n"

const (
	// EnvPrivateKey to use as the private key for signing
	EnvPrivateKey = `MADL_MINT_PRIVATE_KEY`

	// EnvRecipientAddress to receive tokens to
	EnvRecipientAddress = `MADL_MINT_RECIPIENT`

	// EnvNonce to track this reward for for the recipient
	EnvNonce = `MADL_MINT_NONCE`

	// EnvChainId to create the mint for
	EnvChainId = `MADL_MINT_CHAIN_ID`

	// EnvAmount to pay out to the recipient of the mint
	EnvAmount = `MADL_MINT_AMOUNT`
)

// MintFunctionSelector to use instead of packing with the ABI
// (keccak(mint function))
var MintFunctionSelector []byte

var (
	EthTypeUint256, _ = ethAbi.NewType("uint256", "", nil)
	EthTypeAddress, _ = ethAbi.NewType("address", "", nil)
	EthTypeBytes, _ = ethAbi.NewType("bytes", "", nil)

	MintArgsPartial = ethAbi.Arguments{
		{Type: EthTypeUint256, Name: "_nonce"},
		{Type: EthTypeUint256, Name: "_chain_id"},
		{Type: EthTypeAddress, Name: "_recipient"},
		{Type: EthTypeUint256, Name: "_amount"},
	}

	MintArgsFull = append(
		MintArgsPartial,
		ethAbi.Argument{Type: EthTypeBytes, Name: "_sig"},
	)
)

func hashPartialArgs(nonce, chainId *big.Int, recipient ethCommon.Address, amount *big.Int) (hash []byte, err error) {
	calldata, err := MintArgsPartial.Pack(
		nonce,
		chainId,
		recipient,
		amount,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to pack args: %v", err)
	}

	return ethCrypto.Keccak256(calldata), nil
}

func calldataMintFunction(nonce, chainId *big.Int, recipient ethCommon.Address, amount *big.Int, v uint8, r, s []byte) (calldata []byte, err error) {
	rsv := append(append(r, s...), byte(v))

	calldata, err = MintArgsFull.Pack(
		nonce,
		chainId,
		recipient,
		amount,
		rsv,
	)

	if err != nil {
		return nil, fmt.Errorf(
			"failed to generate calldata for the full args: %v",
			err,
		)
	}

	calldata = append(MintFunctionSelector, calldata...)

	return calldata, nil
}

func signHash(key *ecdsa.PrivateKey, hash []byte) (v uint8, r []byte, s []byte, err error) {
	sig, err := ethCrypto.Sign(hash, key)

	if err != nil {
		return 0, nil, nil, fmt.Errorf(
			"failed to sign hash given: %v",
			err,
		)
	}

	r = sig[:32]
	s = sig[32:64]

	v = 27

	return v, r, s, nil
}

// constructMintCalldata by signing the hashed calldata of the inputs,
// computing the v, r and s then generating calldata again with the
// inputs and returning it in hex
func constructMintCalldata(privateKey *ecdsa.PrivateKey, nonce, chainId *big.Int, recipient ethCommon.Address, amount *big.Int) ([]byte, error) {
	partialHash, err := hashPartialArgs(nonce, chainId, recipient, amount)

	if err != nil {
		return nil, fmt.Errorf("failed to hash partial args: %v", err)
	}

	v, r, s, err := signHash(privateKey, partialHash)

	if err != nil {
		return nil, fmt.Errorf("failed to sign partial hash: %v", err)
	}

	calldata, err := calldataMintFunction(
		nonce,
		chainId,
		recipient,
		amount,
		v,
		r,
		s,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to create calldata for mint: %v", err)
	}

	return calldata, nil
}

func main() {
	var (
		privateKey             *ecdsa.PrivateKey
		recipientAddress       ethCommon.Address
		nonce, chainId, amount *big.Int
		rc                     bool
		err                    error
	)

	var (
		privateKey_       = os.Getenv(EnvPrivateKey)
		recipientAddress_ = os.Getenv(EnvRecipientAddress)
		nonce_            = os.Getenv(EnvNonce)
		chainId_          = os.Getenv(EnvChainId)
		amount_           = os.Getenv(EnvAmount)
	)

	switch true {
	case privateKey_ == "":
		log.Fatalf("%s not set!", EnvPrivateKey)

	case recipientAddress_ == "":
		log.Fatalf("%s not set!", EnvRecipientAddress)

	case nonce_ == "":
		log.Fatalf("%s not set!", EnvNonce)

	case chainId_ == "":
		log.Fatalf("%s not set!", EnvChainId)

	case amount_ == "":
		log.Fatalf("%s not set!", EnvAmount)
	}

	privateKey, err = ethCrypto.HexToECDSA(privateKey_)

	if err != nil {
		log.Fatalf(
			"Private key (%s) can't be decoded: %v",
			EnvPrivateKey,
			err,
		)
	}

	recipientAddress = ethCommon.HexToAddress(recipientAddress_)

	if nonce, rc = new(big.Int).SetString(nonce_, 10); !rc {
		log.Fatalf("Failed to decode nonce %#v!", nonce_)
	}

	if chainId, rc = new(big.Int).SetString(chainId_, 10); !rc {
		log.Fatalf("Failed to decode chain id %#v!", chainId_)
	}

	if amount, rc = new(big.Int).SetString(amount_, 10); !rc {
		log.Fatalf("Failed to decode amount %#v!", amount_)
	}

	calldata, err := constructMintCalldata(
		privateKey,
		nonce,
		chainId,
		recipientAddress,
		amount,
	)

	if err != nil {
		log.Fatalf("Failed to generate calldata: %v", err)
	}

	fmt.Printf("0x%x\n", calldata)
}

func init() {
	var err error

	MintFunctionSelector, err = hex.DecodeString("13f8ffc7")

	if err != nil {
		panic(err)
	}
}
