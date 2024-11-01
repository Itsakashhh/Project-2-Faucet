// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {EVT_Faucet} from "../src/Faucet.s.sol";
import {ElevenToken} from "../src/Token.s.sol";

contract FaucetTest is Test {
    EVT_Faucet public faucet;
    ElevenToken public token;
    address user = address(0x1);
    address owner = address(this);

    function setUp() public {
        token = new ElevenToken();
        faucet = new EVT_Faucet(token);
        token.approve(address(faucet), 1000 * (10 ** 18));
        faucet.fundFaucet(1000 * (10 ** 18));
    }

    function testOwnerIsCorrect() public view {
        assertEq(faucet.owner(), owner, "Owner should be the deployer.");
    }

    function testTokenAddressSetCorrectly() public view {
        assertEq(address(faucet.token()), address(token), "Token address not set correctly.");
    }

    function testFaucetBalance() public view {
        uint256 balance = faucet.getCurrentBalance();
        assertEq(balance, 1000 * (10 ** 18), "Faucet balance mismatch.");
    }

    function testUserCanRequestTokens() public {
        vm.prank(user);
        faucet.requestTokens();
        uint256 userBalance = token.balanceOf(user);
        assertEq(userBalance, 50 * (10 ** 18), "User should receive 50 EVT tokens.");
    }

    function testRequestCooldown() public {
        vm.prank(user);
        faucet.requestTokens(); 
        
       
        vm.expectRevert("Cooldown: Please wait before requesting again");
        vm.prank(user);
        faucet.requestTokens();
    }
    
    function testOnlyOwnerCanFundFaucet() public {
        vm.prank(user); 
        vm.expectRevert("Only the owner can fund the faucet");
        faucet.fundFaucet(50 * (10 ** 18));
    }

    
    function testOwnerCanFundFaucet() public {
        uint256 initialBalance = faucet.getCurrentBalance();

        token.approve(address(faucet), 500 * (10 ** 18));

        
        faucet.fundFaucet(500 * (10 ** 18));

        uint256 newBalance = faucet.getCurrentBalance();
        assertEq(newBalance, initialBalance + 500 * (10 ** 18), "Faucet balance should reflect the additional funding.");
    }

 
    function testGetCurrentBalance() public {
        uint256 initialBalance = faucet.getCurrentBalance();
        assertEq(initialBalance, 1000 * (10 ** 18), "Initial balance should be 1000 EVT");
        token.approve(address(faucet), 200 * (10 ** 18));
        faucet.fundFaucet(200 * (10 ** 18));
        uint256 updatedBalance = faucet.getCurrentBalance();

        assertEq(updatedBalance, initialBalance + 200 * (10 ** 18), "Balance should reflect the additional 200 EVT funding.");
    }

    function testDrainToOwner() public {
        faucet.drain();

        uint256 balanceAfterDrain = faucet.getCurrentBalance();
        assertEq(balanceAfterDrain, 0, "Faucet is Empty");
    }

    function testRequestFailsWhenFaucetBalanceLow() public {
        faucet.drain();

        vm.expectRevert("Insufficient tokens in faucet");
        faucet.requestTokens();
    }

    function testUserCanRequestTokensAfterCooldown() public {
        vm.prank(user);
        faucet.requestTokens();
        vm.warp(block.timestamp + faucet.requestCooldown());

        // User requests tokens again after cooldown
        vm.prank(user);
        faucet.requestTokens();
        uint256 userBalance = token.balanceOf(user);
        assertEq(userBalance, 100 * (10 ** 18), "User should receive 50 EVT tokens after cooldown.");
    }


}

