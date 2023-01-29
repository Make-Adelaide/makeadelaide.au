
# Create Mint

Create a mint for the recipient and amount given. Generate the
calldata to send the contract to create a mint.

## Variables

|         Name       |                      Description                       |
|--------------------|--------------------------------------------------------|
| `MADL_PRIVATE_KEY` | Private key in hex without 0x to sign the minting with |

## Usage

create-mint has the ABI definition for `mint` in `mint.json`.

	MADL_PRIVATE_KEY=d8dddfa00a17ef7802643fabadd9df34685693ccb73bfffc43395bc7e656a1f5 \
		./create-mint
