package main

import (
	"crypto/ecdsa"
	"fmt"
	"log"

	ethCrypto "github.com/ethereum/go-ethereum/crypto"
)

func main() {
	privateKey, err := ethCrypto.GenerateKey()

	if err != nil {
		log.Fatalf(
			"Failed to generate a private key! %v",
			err,
		)
	}

	var (
		privateKeyDump = ethCrypto.FromECDSA(privateKey)
		publicKey      = privateKey.Public().(*ecdsa.PublicKey)
	)

	publicKeyDump := ethCrypto.PubkeyToAddress(*publicKey)

	fmt.Printf("%x,0x%x\n", privateKeyDump, publicKeyDump)
}
