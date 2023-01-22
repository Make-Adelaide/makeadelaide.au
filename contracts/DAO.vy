# @version ^0.3.7

"""
@title DAO for MakeAdelaide
@author bayge

The DAO sits in front of MakeAdelaide, acting as the operator.
"""

VERSION: constant(uint8) = 1

version: uint8

executive_council: address

@external
def initialise(_executive_council: address):
	assert self.version != VERSION, "already initialised"
	self.version = VERSION
	self.executive_council = _executive_council
