
# join.makeadelaide.au

Simple webapp that facilitates joining the DAO via a unique link given
out to users who visit Make Adelaide DAO events.

It:

1. Onboards with a custom URL that can be handed out in the form of a
QR code

2. The custom URL contains information embedded in it with the
signature to mint (and the private key)

3. Assumes the private key has been premade locally by the cmd
`create-account`

3. The client side with a JavaScript function and the private key
sends the transaction to the RPC, and thus redeems the user their
tokens for voting

## Example

Visiting the link https://join.makeadelaide.au/#/create#b09d305c22d7c570bdb7af625b9067f6355184fd5435bac953ef61514f3b6dfb,0x13f8ffc70000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000059e3498a3f5b6c059228e7336453cc8614a8362c0000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000041478f1851bcbf44a18322f86e15c1d19a32e8e5c2164e46114ec25ccbdc19968b246ab8df2ce132aa1b5fb52079f8bd5fbaaaff5e9a203b67ac7ae4c07c1281861b00000000000000000000000000000000000000000000000000000000000000

Will prompt the user to redeem 10 tokens to the wallet
0x59e3498a3f5b6c059228e7336453cc8614a8362c with instructions on how to
do so with Metamask. The user can then prove they own the amount by
submitting the calldata given with the private key given, redeeming
their voting tokens.
