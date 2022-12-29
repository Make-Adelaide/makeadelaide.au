
pragma solidity ^0.8.15;

interface IWebpage {
	/// @notice initialises the webpage, taking the
	function initialise(address operator, address submitter, address emergency) external;

	/// @notice operator returns the current operator (account able
	/// to change settings, etc)
	function operator() external view returns (address);

	/// @notice emergency returns the emergency council of the contract
	function emergency() external view returns (address);

	/// @notice submitter returns the submitter that can send hashes to the contract
	function submitter() external view returns (address);

	/// @notice operational status of the contract (true = no emergency)
	function operational() external view returns (bool);

	/// @notice return the hash of the articles currently stored on IPFS
	function articlesHash() external view returns (bytes20);

	/// @notice return the hash of the directory containing people stored on IPFS
	function peopleHash() external view returns (bytes20);

	function registerArticles(bytes20 hash) external;

	function registerPeople(bytes20 hash) external;
}
