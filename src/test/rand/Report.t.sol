// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.18;

// import {ITokenizedStrategy} from "@tokenized-strategy/interfaces/ITokenizedStrategy.sol";
// import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";

// import {SiloArbiOracle} from "../../periphery/priceOracles/SiloArbiOracle.sol";
// import {SiloUsdcLenderAprOracle} from "../../periphery/SiloUsdcLenderAprOracle.sol";
// import {SiloStrategy} from "../../strategies/silo/SiloStrategy.sol";

// import "forge-std/Test.sol";

// contract TestReport is Test {

//     SiloArbiOracle public siloOracle;

//     SiloUsdcLenderAprOracle public aprOracle = SiloUsdcLenderAprOracle(0xEB3d79b238Ea547a4A37a448ba37fEc247e2F69e);
//     ITokenizedStrategy public strategy = ITokenizedStrategy(0xE82D060687C014B280b65df24AcD94A77251C784);
//     SiloStrategy public siloStrategy = SiloStrategy(0xE82D060687C014B280b65df24AcD94A77251C784);

//     address public constant SILO = 0x0341C0C0ec423328621788d4854119B97f44E391; // arbi
//     address public constant USDCE = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8; // arbi
//     address public constant MANAGMENT = 0x1dcAD21ccD74b7A8A7BC7D19894de8Af41D9ea03; // arbi

//     function setUp() public {
//         vm.selectFork(vm.createFork(vm.envString("ARBI_RPC_URL")));

//         siloOracle = new SiloArbiOracle();
//     }

//     function testReport() public {
//         vm.startPrank(MANAGMENT);
//         siloStrategy.setIncentivesController(0xbDBBf747402653A5aD6F6B8c49F2e8dCeC37fAcF);
//         siloStrategy.addToken(SILO, USDCE);
//         vm.stopPrank();

//         vm.prank(0xE0D19f6b240659da8E87ABbB73446E7B4346Baee);
//         strategy.report();

//         vm.startPrank(MANAGMENT);
//         aprOracle.setRewardAssetPriceOracle(
//             AggregatorV3Interface(address(siloOracle)),
//             SILO
//         );
//         vm.stopPrank();

//         int256 _delta = 0;
//         uint256 _apr = aprOracle.aprAfterDebtChange(address(strategy), _delta);
//         console.log("APR: %s", _apr);

//         (, int256 answer,,,) = siloOracle.latestRoundData();
//         console.log("Answer: %s", uint256(answer));
//     }
// }