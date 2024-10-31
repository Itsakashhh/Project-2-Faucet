// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ElevenToken is ERC20 {
     uint256 private constant TOTAL_SUPPLY = 100000 * (10 ** 18); // 100,000 tokens

    constructor() ERC20("ElevenToken", "EVT") {
        _mint(msg.sender, TOTAL_SUPPLY); // Mint all tokens to contract deployer
    }
}

//0xF11c7BB03e99D9100e2eEb5DBC87256d18556B48
//0xF11c7BB03e99D9100e2eEb5DBC87256d18556B48