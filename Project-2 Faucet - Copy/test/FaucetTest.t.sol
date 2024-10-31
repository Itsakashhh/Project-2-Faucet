// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {EVT_Faucet} from "../src/Faucet.s.sol";
import {ElevenToken } from "../src/Token.s.sol";

contract FaucetTest is Test {
    EVT_Faucet public faucet;
    ElevenToken public token;
    address user = address(0x1);
    address owner = address(this);

    function setUp() public {
        // Deploy the token contract
        token = new ElevenToken();

        // Transfer initial EVT tokens to faucet for testing
        faucet = new EVT_Faucet(token);
        token.transfer(address(faucet), 1000 * (10 ** 18)); // 1000 EVT
    }

    // Test if faucet owner is set correctly
    function testOwnerIsCorrect() public view {
        assertEq(faucet.owner(), owner, "Owner should be the deployer.");
    }

    // Test if faucet balance is correct after funding
    function testFaucetBalance() public view{
        uint256 balance = faucet.getCurrentBalance();
        assertEq(balance, 1000 * (10 ** 18), "Faucet balance mismatch.");
    }

    // Test successful token request by a user
    function testUserCanRequestTokens() public {
        vm.prank(user);
        faucet.requestTokens();
        uint256 userBalance = token.balanceOf(user);
        assertEq(userBalance, 50 * (10 ** 18), "User should receive 50 EVT tokens.");
    }

   function testRequestCooldown() public {
    // Initial request to set lastRequestTime
    faucet.requestTokens();
    
    // Attempt to request tokens again immediately, which should fail due to cooldown
    vm.expectRevert("Cooldown: Please wait before requesting again");
    faucet.requestTokens();
}

    // Test only owner can fund faucet
    function testOnlyOwnerCanFundFaucet() public {
        vm.prank(user); // Non-owner tries to fund faucet
        vm.expectRevert("Only the owner can fund the faucet");
        faucet.fundFaucet(50 * (10 ** 18));
    }
}