# @version ^0.3.7

"""
@title DAO for MakeAdelaide
@author bayge

The DAO sits in front of MakeAdelaide, acting as the operator.
"""

VERSION: constant(uint8) = 1

VOTE_CALLDATA_SIZE: constant(uint8) = 300 - 72

version: uint8

nonce: uint256

executive_council: address

struct Vote:
	ipfs_hash: bytes20
	calldata_hashed: bytes32
	contract_target: address

@external
def initialise(_executive_council: address):
	assert self.version <= VERSION, "already initialised"
	self.version = VERSION
	self.executive_council = _executive_council

@internal
@pure
def vote_verify_calldata(_hashed: bytes32, _calldata: Bytes[VOTE_CALLDATA_SIZE]) -> bool:
	return True

@internal
@pure
def vote_passed(_vote: Vote) -> bool:
	return True

@external
@nonreentrant("lock")
def execute(_vote: Vote, _calldata: Bytes[VOTE_CALLDATA_SIZE]) -> Bytes[32]:
	"""
	@notice execute the vote on the contract given
	@param _vote to execute
	@param _calldata to use when executing on the contract given, verified by the hash in the vote block

	@dev calldata = 300 - Vote

	"""

	assert self.vote_passed(_vote)

	assert self.vote_verify_calldata(_vote.calldata_hashed, _calldata)

	resp: Bytes[32] = raw_call(
		_vote.contract_target,
		_calldata,
		max_outsize = 32,
		value = 0,
		gas = 0,
		is_delegate_call = False,
		is_static_call = False,
		revert_on_failure = True
	)

	return resp
