// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";

import "forge-std/console.sol";
import {Setup} from "./utils/Setup.sol";

import {StrategyAprOracle} from "../periphery/StrategyAprOracle.sol";

contract OracleTest is Setup {

    // Optimism
    address public op = 0x4200000000000000000000000000000000000042;
    AggregatorV3Interface public opOracle = AggregatorV3Interface(0x0D276FC14719f9292D5C1eA2198673d1f4269246);

    StrategyAprOracle public oracle;

    function setUp() public override {
        super.setUp();
        oracle = new StrategyAprOracle(management);
    }

    function checkOracle(address _strategy, uint256 _delta) public {

        if (block.chainid == 10) {
            // Check set up
            vm.expectRevert("!governance");
            vm.prank(user);
            oracle.setRewardAssefPriceOracle(opOracle, op);

            vm.prank(management);
            oracle.setRewardAssefPriceOracle(opOracle, op);

            address _rewardTokenPriceOracle = address(oracle.oracles(op));
            assertEq(_rewardTokenPriceOracle, address(opOracle), "oracle");
        }

        uint256 currentApr = oracle.aprAfterDebtChange(_strategy, 0);
        console.log("Current APR: ", currentApr);

        // Should be greater than 0 but likely less than 100%
        assertGt(currentApr, 0, "ZERO");
        assertLt(currentApr, 1e18, "+100%");

        uint256 negativeDebtChangeApr = oracle.aprAfterDebtChange(_strategy, -int256(_delta));
        console.log("Negative Debt Change APR: ", negativeDebtChangeApr);

        // The apr should go up if deposits go down
        assertLt(currentApr, negativeDebtChangeApr, "negative change");

        uint256 positiveDebtChangeApr = oracle.aprAfterDebtChange(_strategy, int256(_delta));
        console.log("Positive Debt Change APR: ", positiveDebtChangeApr);

        assertGt(currentApr, positiveDebtChangeApr, "positive change");
    }

    function test_oracle(uint256 _amount, uint16 _percentChange) public {
        uint256 _decimals = 10 ** decimals;
        vm.assume(_amount > minFuzzAmount * _decimals && _amount < maxFuzzAmount);
        _percentChange = uint16(bound(uint256(_percentChange), 100, MAX_BPS));

        mintAndDepositIntoStrategy(strategy, user, _amount);

        uint256 _delta = (_amount * _percentChange) / MAX_BPS;

        checkOracle(address(strategy), _delta);
    }

    // function test_displayAPR() public {
    //     uint256 apr = oracle.aprAfterDebtChange(address(strategy), 0);
    //     console.log("------- TOTAL APR: ", apr);
    // }

    // TODO: Deploy multiple strategies with different tokens as `asset` to test against the oracle.
}