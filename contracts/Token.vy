# @version ^0.3.7

"""
@title Make Adelaide DAO unit of voting power
@author bayge
@notice ERC20 token representing a unit of voting power redeemed at an
        event

minter is used to sign requests to distribute ownership to users who
visit Make Adelaide events.

For each attendance, a user receives 10 Token(s), for which they call
the function "mint" on-chain to verify and receive.

TODO: instead of a mulcall, use circom for a proof
"""

VERSION: constant(uint8) = 1

from vyper.interfaces import ERC20
from vyper.interfaces import ERC20Detailed

implements: ERC20
implements: ERC20Detailed

event Transfer:
	sender: indexed(address)
	receiver: indexed(address)
	value: uint256

event Approval:
	owner: indexed(address)
	spender: indexed(address)
	value: uint256

event Minted:
	recipient: indexed(address)
	value: uint256

struct Mint:
	nonce: uint256
	chain_id: uint256
	recipient: address
	value: uint256
	sig: Bytes[65]

version: uint8

chain_id: uint256

operator: public(address)

name: public(String[10])

decimals: public(uint8)

totalSupply: public(uint256)

symbol: public(String[5])

balanceOf: public(HashMap[address, uint256])

allowance: public(HashMap[address, HashMap[address, uint256]])

nonce: public(HashMap[address, uint256])

minter: public(address)

@external
def initialise(
	_operator: address,
	_minter: address,
	_name: String[10],
	_decimals: uint8,
	_total_supply: uint256,
	_symbol: String[5]
):
	assert self.version < VERSION, "already initialised"

	self.chain_id = chain.id

	self.minter = _minter
	self.operator = _operator
	self.name = _name
	self.decimals = _decimals
	self.totalSupply = _total_supply
	self.symbol = _symbol

	self.version = VERSION

@external
@view
def chainId_() -> uint256: return self.chain_id

@external
def transfer(_recipient: address, _value: uint256) -> bool:
	"""
	@notice transfer an amount to the recipient given
	@param _recipient to receive the funds
	@param _value to send

	Vyper has an underflow check so we can reduce the sender
	instead of having a check for their balances
	"""

	self.balanceOf[msg.sender] -= _value
	self.balanceOf[_recipient] += _value
	log Transfer(msg.sender, _recipient, _value)
	return True

@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
	self.allowance[_from][msg.sender] -= _value
	self.balanceOf[_from] -= _value
	self.balanceOf[_to] += _value

	log Transfer(_from, _to, _value)

	return True

@external
def approve(_spender: address, _value: uint256) -> bool:
	self.allowance[msg.sender][_spender] = _value
	log Approval(msg.sender, _spender, _value)
	return True

@internal
def __mint(_recipient: address, _value: uint256):
	self.balanceOf[_recipient] += _value

@external
def operator_mint(_recipient: address, _value: uint256):
	"""
	@notice operator_mint some tokens
	@param _recipient to send the amount to
	@param _value to send to the recipient
	"""

	assert msg.sender == self.operator, "not operator"
	self.__mint(_recipient, _value)

@external
def change_operator(_operator: address):
	assert msg.sender == _operator
	self.operator = _operator

@internal
@pure
def extract_mint_hash_with_preamble(
	_nonce: uint256,
	_chain_id: uint256,
	_recipient: address,
	_value: uint256
) -> bytes32:
	"""
	@notice extract_mint_hash_with_preamble by reconstructing
	        argument calldata then prepending eth_sign preamble
	"""

	hash: bytes32 = keccak256(_abi_encode(
		_nonce,
		_chain_id,
		_recipient,
		_value
	))

	return keccak256(concat(
		#\x19Ethereum Signed Message:\n32
		0x19457468657265756d205369676e6564204d6573736167653a0a3332,

		hash
	))

@internal
@view
def signed_is_minter(_hash: bytes32, _sig: Bytes[65]) -> bool:
	"""
	@notice signed_is_minter check by comparing the signature
	against the minter
	"""

	r: uint256 = extract32(_sig, 0, output_type=uint256)
	s: uint256 = extract32(_sig, 32, output_type=uint256)
	v: int128 = convert(slice(_sig, 64, 1), int128)

	if v != 27:
		return False

	return self.minter == ecrecover(_hash, convert(v, uint256), r, s)

@internal
def _mint(
	_nonce: uint256,
	_chain_id: uint256,
	_recipient: address,
	_value: uint256,
	_sig: Bytes[65]
):
	assert self.chain_id == _chain_id, "wrong chain"

	hash: bytes32 = self.extract_mint_hash_with_preamble(
		_nonce,
		_chain_id,
		_recipient,
		_value
	)

	assert self.signed_is_minter(hash, _sig), "minter didn't sign!"

	assert self.nonce[_recipient] < _nonce, "nonce lower than!"

	self.__mint(_recipient, _value)

	self.nonce[_recipient] += 1

	log Minted(_recipient, _value)

@external
def mint(
	_nonce: uint256,
	_chain_id: uint256,
	_recipient: address,
	_value: uint256,
	_sig: Bytes[65]
):
	"""
	@notice mint some tokens for the sender
	@param _nonce that this mint payout should be for
	@param _recipient to send the tokens to
	@param _value to send the recipient
	@param _sig bytes to grab (r, s, v) from

	Mint some tokens for the user, taking a signed blob and
	verifying the signer was the "minter". Check if the nonce
	given is above the nonce for the recipient.
	"""

	self._mint(_nonce, _chain_id, _recipient, _value, _sig)

@external
def multicall_mint(_mints: Mint[20]):
	"""
	@notice multicall_mint using the Mint array given (max 20 items)
	@pararm _mints array containing each mint
	"""

	for mint in _mints:
		self._mint(
			mint.nonce,
			mint.chain_id,
			mint.recipient,
			mint.value,
			mint.sig
		)
