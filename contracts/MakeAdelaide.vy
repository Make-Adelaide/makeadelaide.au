# @version ^0.3.7

"""
@title Server
@author bayge
@license UNLICENSED

Server implements support for caching bytes20 IPFS hashes pointing to
directories of articles/people's identities provided by a "submitter".

A submitter is a trusted party that runs off-chain.
"""

# @notice version of the contract below
VERSION: constant(uint8) = 1

event SubmittedNewPeople:
	_hashPeople: indexed(bytes20)

event SubmittedNewArticles:
	_hashArticles: indexed(bytes20)

event Enabled:
	_status: bool

# @notice enabled denominates whether the contract is enabled
enabled: public(bool)

# @notice version of the contract in use
version: uint8

# @notice operator that's allowed to disable the contract and change submitters
operator: public(address)

# @notice emergencyCouncil that's allowed to shut the contract down
emergencyCouncil: public(address)

# @notice submitter that can upload hashes to the contract for people/articles
submitter: public(address)

# @notice hash of the directory containing people
hashPeople: public(bytes20)

# @notice hash of the directory containing articles to display on the frontend
hashArticles: public(bytes20)

@external
def initialise(_operator: address, _emergencyCouncil: address, _submitter: address):
	"""
	@notice contract constructor (upgradeable pattern)
	@param _operator priviledged account
	@param _emergencyCouncil account that can shut everything down
	@param _submitter account that can submit articles and people
	"""

	assert self.version != VERSION, "already initialised"

	self.operator = _operator
	self.emergencyCouncil = _emergencyCouncil
	self.submitter = _submitter

	self.version = VERSION

@internal
def isSubmitter() -> bool: return msg.sender == self.submitter

@internal
def isOperator() -> bool: return msg.sender == self.operator

@internal
def isEmergencyCouncil() -> bool:
	return msg.sender == self.emergencyCouncil

@external
def submitNewPeopleHash(_hashPeople: bytes20):
	"""
	@notice set the hash containing the people in the database
	@param _hashPeople to set as the current IPFS hash of people
	"""

	assert self.isSubmitter(), "not submitter"

	self.hashPeople = _hashPeople

	log SubmittedNewPeople(_hashPeople)

@external
def submitNewArticles(_hashArticles: bytes20):
	"""
	@notice set the hash containing the articles in the database
	@param _hashArticles to set as the current IPFS hash of people
	"""

	assert self.isSubmitter(), "not submitter"

	self.hashArticles = _hashArticles

	log SubmittedNewArticles(_hashArticles)

@external
def setEnabled(_enabled: bool):
	"""
	@notice set whether the contract should be enabled right now
	@param _enabled status to set
	"""

	# if the user is not the operator or emergency council, reject

	assert self.isOperator() or self.isEmergencyCouncil(), "not allowed"

	self.enabled = _enabled

	log Enabled(_enabled)

@external
def setNewSubmitter(_submitter: address):
	"""
	@notice set a new submitter if the user is either the
	        operator, emergency council or submitter
	@param _submitter to replace with
	"""

	# if the user is not the submitter, or the operator, reject

	assert self.isSubmitter() or self.isOperator(), "not allowed"

	self.submitter = _submitter
