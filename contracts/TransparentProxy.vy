# @version ^0.3.7

"""
@title Transparent proxy utilising an admin and target slot for supporting upgrades
@author bayge

The transparent proxy stores the admin address (presemably the DAO) in
`bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)`.

The logic contract is stored in
`bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`.
"""

proxy_admin: public(address)

proxy_implementation: public(address)

@external
def upgrade(_logic: address):
	assert msg.sender == self.proxy_admin
	self.proxy_implementation = _logic

@external
def new_admin(_new_admin: address):
	assert msg.sender == self.proxy_admin
	self.proxy_admin = _new_admin

@external
def __init__(_implementation: address):
	self.proxy_admin = msg.sender
	self.proxy_implementation = _implementation

@external
def __default__() -> Bytes[32]:
	return raw_call(
		self.proxy_implementation,
		msg.data,
		max_outsize = 32,
		is_delegate_call = True,
		revert_on_failure = True,
	)
