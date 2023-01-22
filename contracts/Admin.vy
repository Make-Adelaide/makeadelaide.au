# @version ^0.3.7

"""
@title Admin for administrating the contract code
@author bayge

Admin deploys a TransparentProxy pointing to MakeAdelaide and DAO.

The deployed DAO can use the Admin contract to upgrade any TransparentProxy(ies).
"""

import TransparentProxy as TransparentProxy

# @notice address_DAO that is also used as the admin for this
address_DAO: public(TransparentProxy)

address_MakeAdelaide: public(TransparentProxy)

@external
def __init__(_dao: TransparentProxy, _make_adelaide: TransparentProxy):
	self.address_DAO = _dao
	self.address_MakeAdelaide = _make_adelaide

@internal
@view
def isSenderAdmin()-> bool: return msg.sender == self.address_DAO.address

@external
def upgrade_dao(_logic: address):
	assert self.isSenderAdmin(), "not admin"
	self.address_DAO.upgrade(_logic)

@external
def upgrade_make_adelaide(_logic: address):
	assert self.isSenderAdmin(), "not admin"
	self.address_MakeAdelaide.upgrade(_logic)

@external
@view
def dao() -> address: return self.address_DAO.address

@external
@view
def make_adelaide() -> address: return self.address_MakeAdelaide.address

@external
@view
def configured() -> bool:
	dao: address = self.address_DAO.address
	make_adelaide: address = self.address_MakeAdelaide.address
	return dao != empty(address) and make_adelaide != empty(address)
