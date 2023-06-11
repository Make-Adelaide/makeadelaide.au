
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

uint8 constant VERSION = 1;

contract Website is OwnableUpgradeable {
    event SubmittedNewPeople(bytes indexed hash);
    event SubmittedNewArticles(bytes indexed hash);

    event NewSubmitter(address _oldSubmitter, address _newSubmitter);

    /* ~~~~~~~~~~ UPGRADEABLE FEATURES ~~~~~~~~~~ */

    uint8 private version_;

    /* ~~~~~~~~~~ IPFS STORAGE ~~~~~~~~~~ */

    bytes public hashPeople_;

    bytes public hashArticles_;

    /* ~~~~~~~~~~ ACCESS CONTROL ~~~~~~~~~~ */

    address public submitter_;

    function initialise(address _operator, address _submitter) external {
        require(version_ < VERSION, "already initialised");
        version_ = VERSION;
        _transferOwnership(_operator);
        submitter_ = _submitter;
    }

    modifier onlySubmitter() {
        require(msg.sender == submitter_, "only submitter");
        _;
    }

    function submitNewPeopleHash(bytes calldata _hash) external onlySubmitter {
        emit SubmittedNewPeople(_hash);
        hashPeople_ = _hash;
    }

    function submitNewArticlesHash(bytes calldata _hash) external onlySubmitter {
        emit SubmittedNewArticles(_hash);
        hashArticles_ = _hash;
    }

    function upgradeSubmitter(address _submitter) external onlyOwner {
        emit NewSubmitter(submitter_, _submitter);
        submitter_ = _submitter;
    }
}
