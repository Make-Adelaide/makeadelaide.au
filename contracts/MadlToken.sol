
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MadlToken is ERC20, Ownable {
    address public distributor_;

    constructor(address _distributor) ERC20("Make Adelaide Ownership", "MADL") {
        _transferOwnership(_distributor);
        _mint(_distributor, type(uint256).max);
    }

    function transfer(
        address _to,
        uint256 _amount
    ) public onlyOwner override returns (bool) {
        return super.transfer(_to, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public onlyOwner override returns (bool) {
        return super.transferFrom(_from, _to, _amount);
    }
}
