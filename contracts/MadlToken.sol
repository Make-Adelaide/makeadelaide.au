
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

string constant TOKEN_NAME = "Make Adelaide Token";

uint256 constant TOKEN_SUPPLY = 1e60;

contract MadlToken is ERC20, ERC20Permit, Ownable, ERC20Votes {
    address public distributor_;

    constructor(address _distributor) ERC20(TOKEN_NAME, "MADL") ERC20Permit(TOKEN_NAME) {
        _transferOwnership(_distributor);
        _mint(_distributor, TOKEN_SUPPLY);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
