// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract iassafe42 is ERC20 {

    constructor() ERC20("iassafe42", "IAS42") {
        _mint(msg.sender, 42_000_000 * (10 ** 18));
    }
}
