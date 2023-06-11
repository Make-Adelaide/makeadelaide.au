
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {
    IERC20MetadataUpgradeable as IERC20
    } from "@openzeppelin/contracts-upgradeable/interfaces/IERC20MetadataUpgradeable.sol";

import "hardhat/console.sol";

uint8 constant VERSION = 1;

/// @dev GRACE_PERIOD time since before an event cannot be redeemed
uint256 constant GRACE_PERIOD = 7 days;

/**
 * Distributor distributes ownership of the MadlToken, with an
 * inflationary schedule. The inflationary schedule is used to
 * punish early participants who fail to regularly attend events or
 * deliver value in the form of being an executive.

 * The current distributor is able to increment the event given and
 * reward multiple users with the token distribution for that event
 * period. They do this by calling the `createEvent` function, which
 * increments the event that's tracked and stores it in the array. Users
 * can then generate transactions that redeem the ownership.

 * Token distribution happens according to this schedule
 * https:docs.google.com/spreadsheets/d/1tVA7d6uJ1p-Vkhvzrt1Ai0zXOUw2l073qXawe7PTEQc
 */

struct Distributor {
    // valid is whether the distributor is enabled
    bool valid;

    // nonces that can be spent by the distributor
    mapping (uint256 => bool) nonces;
}

struct Redemption {
    address recipient;
    uint256 eventNumber;
    uint256 nonce;
}

contract Distribution is OwnableUpgradeable {
    event Minted(address _recipient, uint256 _amount);

    event DistributorChange(address _address, bool _status);

    /* ~~~~~~~~~~ UPGRADING ~~~~~~~~~~ */

    uint8 private version_;

    /* ~~~~~~~~~~ ACCESS CONTROL ~~~~~~~~~~ */

    mapping (address => Distributor) public distributors_;

    /* ~~~~~~~~~~ TOKEN DISTRIBUTION/REDEMPTION ~~~~~~~~~~ */

    uint256 private chainId_;

    bytes32 private domainSeparator_;

    IERC20 token_;

    uint256 tokenDecimalsPow_;

    /* ~~~~~~~~~~ EVENTS ~~~~~~~~~~ */

    uint256[] public eventMaxRedemptionTimestamps_;

    mapping (uint256 => mapping(address => bool)) eventParticipants_;

    /* ~~~~~~~~~~ EVENTS ~~~~~~~~~~ */

    modifier onlyValidDistributor() {
        require(distributors_[msg.sender].valid, "only valid distributor");
        _;
    }

    /* ~~~~~~~~~~ INITIALISATION ~~~~~~~~~~ */

    function initialise(address _owner, IERC20 _token) public {
        require(version_ < VERSION, "already initialised");
        _transferOwnership(_owner);
        chainId_ = block.chainid;
        domainSeparator_ = _computeDomainSeparator();
        token_ = _token;
        tokenDecimalsPow_ = 10 ** _token.decimals();
    }

    /* ~~~~~~~~~~ HOUSEKEEPING ~~~~~~~~~~ */

    function _computeDomainSeparator() internal view returns (bytes32) {
        return keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes("Distribution")),
            keccak256(bytes("1")),
            chainId_,
            address(this)
        ));
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == chainId_ ? domainSeparator_ : _computeDomainSeparator();
    }

    function setDistributor(address _newDistributor, bool _state) external onlyOwner {
        emit DistributorChange(_newDistributor, _state);
        distributors_[_newDistributor].valid = _state;
    }

    /* ~~~~~~~~~~ EVENT CREATION ~~~~~~~~~~ */

    function calculateTokenEmission(uint256 _no) public view returns (uint256) {
        uint256 x = (tokenDecimalsPow_ * _no) / 2;
        return x;
    }

    function createEvent(uint256 _eventTimestamp) external onlyValidDistributor returns (uint256 eventNumber) {
        //require(block.timestamp < _eventTimestamp, "event isn't in the future");
        eventNumber = eventMaxRedemptionTimestamps_.length;
        eventMaxRedemptionTimestamps_.push(_eventTimestamp + GRACE_PERIOD);
    }

    /* ~~~~~~~~~~ REDEMPITON ~~~~~~~~~~ */

    function _transfer(address _recipient, uint256 _amount) internal {
        bool rc = token_.transfer(_recipient, _amount);
        require(rc, "failed to transfer");
    }

    function _hashRedemption(
        address _recipient,
        uint256 _eventNumber,
        uint256 _nonce
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            keccak256("Redemption(address recipient,uint256 eventNumber,uint256 nonce)"),
            _recipient,
            _eventNumber,
            _nonce
        ));
    }

    function hashRedemption(Redemption memory _v) public pure returns (bytes32) {
        return _hashRedemption(_v.recipient, _v.eventNumber, _v.nonce);
    }

    function redemptionNonceNotUsed(address _signer, uint256 _pos) public view returns (bool) {
        return !distributors_[_signer].nonces[_pos];
    }

    function redeemParticipation(
        address _recipient,
        uint256 _eventNumber,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (uint256 receivingAmount) {
        address signer = ecrecover(
            keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR(),
                _hashRedemption(_recipient, _eventNumber, _nonce)
            )),
            _v,
            _r,
            _s
        );

        require(distributors_[signer].valid, "distributor not active");

        require(redemptionNonceNotUsed(signer, _nonce), "distributor nonce already used");

        // it's not possible to get the event number currently with zksync so this is just disabled
        // require(events_[_eventNumber].maxRedemptionDate > block.timestamp, "event well over");
        require(eventMaxRedemptionTimestamps_.length > _eventNumber, "event doesn't exist");

        distributors_[signer].nonces[_nonce] = false;

        receivingAmount = calculateTokenEmission(_eventNumber);

        _transfer(_recipient, receivingAmount);

        return receivingAmount;
    }

    /* ~~~~~~~~~~ DAO SUPPORT ~~~~~~~~~~ */

    function transfer(address _recipient, uint256 _amount) external onlyOwner {
        _transfer(_recipient, _amount);
    }
}
