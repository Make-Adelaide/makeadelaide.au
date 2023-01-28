# @version ^0.3.7

"""
@title Server
@author bayge
@license UNLICENSED

MakeAdelaide implements the contract storing the information rendered
to makeadelaide.au

It implements support for caching bytes20 IPFS hashes pointing to
directories of articles/people's identities provided by a "submitter".

A submitter is a trusted party that runs off-chain.
"""

# @notice version of the contract below
VERSION: constant(uint8) = 1

event SubmittedNewPeople:
	_hash_people: indexed(bytes20)

event SubmittedNewArticles:
	_hash_articles: indexed(bytes20)

event Enabled:
	_status: bool

# @notice enabled denominates whether the contract is enabled
enabled: public(bool)

# @notice version of the contract in use
version: uint8

# @notice operator that's allowed to disable the contract and change submitters
operator: public(address)

# @notice emergency_council that's allowed to shut the contract down
emergency_council: public(address)

# @notice submitter that can upload hashes to the contract for people/articles
submitter: public(address)

# @notice hash of the directory containing people
hash_people: public(bytes20)

# @notice hash of the directory containing articles to display on the frontend
hash_articles: public(bytes20)

@external
def initialise(_operator: address, _emergencyCouncil: address, _submitter: address):
	"""
	@notice contract constructor (upgradeable pattern)
	@param _operator priviledged account
	@param _emergencyCouncil account that can shut everything down
	@param _submitter account that can submit articles and people
	"""

	assert self.version <= VERSION, "already initialised"

	self.operator = _operator
	self.emergency_council = _emergencyCouncil
	self.submitter = _submitter

	self.version = VERSION

@internal
def is_submitter() -> bool: return msg.sender == self.submitter

@internal
def is_operator() -> bool: return msg.sender == self.operator

@internal
def is_emergency_council() -> bool:
	return msg.sender == self.emergency_council

@external
def submit_new_people_hash(_hash_people: bytes20):
	"""
	@notice set the hash containing the people in the database
	@param _hash_people to set as the current IPFS hash of people
	"""

	assert self.is_submitter(), "not submitter"

	self.hash_people = _hash_people

	log SubmittedNewPeople(_hash_people)

@external
def submit_new_articles(_hash_articles: bytes20):
	"""
	@notice set the hash containing the articles in the database
	@param _hash_articles to set as the current IPFS hash of people
	"""

	assert self.is_submitter(), "not submitter"

	self.hash_articles = _hash_articles

	log SubmittedNewArticles(_hash_articles)

@external
def setEnabled(_enabled: bool):
	"""
	@notice set whether the contract should be enabled right now
	@param _enabled status to set
	"""

	# if the user is not the operator or emergency council, reject

	assert self.is_operator() or self.is_emergency_council(), "not allowed"

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

	assert self.is_submitter() or self.is_operator(), "not allowed"

	self.submitter = _submitter
