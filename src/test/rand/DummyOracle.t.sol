// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";

import {DummyOracle} from "../../periphery/priceOracles/DummyOracle.sol";
import {SiloUniV3Oracle} from "../../periphery/priceOracles/SiloUniV3Oracle.sol";
import {SiloLenderAprOracle} from "../../periphery/SiloLenderAprOracle.sol";

import "forge-std/Test.sol";

contract TestDummyOracle is Test {

    address public management = 0x6A16CFA0dF474f3cB1BF5bBa595248EEfb404e2b;
    address public rewardToken = 0x6f80310CA7F2C654691D1383149Fa1A57d8AB1f8; // silo
    address public asset = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // weth
    address public wethOracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    // address public strategy = address(0x262683DaFa4218f6B62Dd5Ee23d233Af6E7a0F33); // Silo Lender: USDC/weETH
    address public strategy = address(0x9ED112B9cED514894D253B3Fdc20d13876B50514); // Silo Lender: WETH/pzETH

    address public univ3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    SiloLenderAprOracle public aprOracle;
    DummyOracle public oracle;
    SiloUniV3Oracle public uniV3Oracle;

    function setUp() public {
        vm.selectFork(vm.createFork(vm.envString("ETH_RPC_URL")));

        oracle = new DummyOracle();
        aprOracle = new SiloLenderAprOracle(management);
        uniV3Oracle = new SiloUniV3Oracle(wethOracle, univ3Factory, rewardToken, asset, 500);
    }

    function testOracle() public {

        vm.startPrank(management);
        aprOracle.setRewardAssetPriceOracle(AggregatorV3Interface(address(uniV3Oracle)), rewardToken);
        aprOracle.setRewardAssetPriceOracle(AggregatorV3Interface(address(wethOracle)), asset);
        vm.stopPrank();

        int256 _delta = 0;
        uint256 _apr = aprOracle.aprAfterDebtChange(strategy, _delta);
        console.log("APR: %s", _apr);

        // (, int256 answer,,,) = uniV3Oracle.latestRoundData();
        // console.log("Answer: %s", uint256(answer));
    }
}
