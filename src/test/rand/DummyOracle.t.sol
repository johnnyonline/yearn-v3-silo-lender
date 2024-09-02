// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";

import {DummyOracle} from "../../periphery/DummyOracle.sol";
import {SiloUsdcLenderAprOracle} from "../../periphery/SiloUsdcLenderAprOracle.sol";

import "forge-std/Test.sol";

contract TestDummyOracle is Test {

    address public management = 0x6A16CFA0dF474f3cB1BF5bBa595248EEfb404e2b;
    address public rewardToken = 0x6f80310CA7F2C654691D1383149Fa1A57d8AB1f8;
    address public strategy = address(0x262683DaFa4218f6B62Dd5Ee23d233Af6E7a0F33); // Silo Lender: USDC/weETH
    SiloUsdcLenderAprOracle public aprOracle;
    DummyOracle public oracle;

    function setUp() public {
        vm.selectFork(vm.createFork(vm.envString("ETH_RPC_URL")));

        oracle = new DummyOracle();
        aprOracle = new SiloUsdcLenderAprOracle(management);
    }

    function testOracle() public {

        vm.prank(management);
        aprOracle.setRewardAssetPriceOracle(AggregatorV3Interface(address(oracle)), rewardToken);
        int256 _delta = 0;
        uint256 _apr = aprOracle.aprAfterDebtChange(strategy, _delta);
        console.log("APR: %s", _apr);
    }
}
