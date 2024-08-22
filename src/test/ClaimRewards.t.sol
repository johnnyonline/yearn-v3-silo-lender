// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/console.sol";
import {Setup} from "./utils/Setup.sol";

contract ClaimRewardsTest is Setup {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_claimRewards(uint256 _amount) external {
        vm.assume(_amount > minFuzzAmount && _amount < maxFuzzAmount);

        // Deposit into strategy
        mintAndDepositIntoStrategy(strategy, user, _amount);

        vm.expectRevert("!keeper");
        strategy.claimRewards();

        vm.prank(keeper);
        strategy.claimRewards();

        vm.prank(keeper);
        strategy.claimRewards();

        vm.prank(management);
        strategy.claimRewards();
    }
}