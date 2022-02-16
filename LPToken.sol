// SPDX-License-Identifier: MIT
// Only for test
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract LPToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10**uint(decimals()));
    }
}
