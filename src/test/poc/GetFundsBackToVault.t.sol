// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.18;

// import {IStrategyInterface} from "../../interfaces/IStrategyInterface.sol";

// import {IVault} from "./IVault.sol";

// import "forge-std/Test.sol";
// import "forge-std/console.sol";

// contract GetFundsBackToVault is Test {

//     address public constant ROLE_MANAGER = 0x1dcAD21ccD74b7A8A7BC7D19894de8Af41D9ea03;
//     address public constant STRATEGY = 0x3FfA0C3fba4Adfe2b6e4D7E2f8E6e6324bE5305B;

//     IVault public constant VAULT = IVault(0x2e48847FE29C3883c98125Cb2C44244d6602d549);

//     function setUp() public {
//         // Setup the environment
//     }

//     function testSanity() public {
//         // Sanity check
//         assertTrue(true);

//         vm.startPrank(ROLE_MANAGER);

//         VAULT.add_role(ROLE_MANAGER, 64); // DEBT_MANAGER
//         // VAULT.update_debt(STRATEGY, 0);
//         IStrategyInterface(STRATEGY).report();

//         vm.stopPrank();

//         // IStrategyInterface(STRATEGY).balanceOf(VAULT);
//         console.log("VAULT.balanceOf(STRATEGY):", IStrategyInterface(STRATEGY).balanceOf(address(VAULT)));
//         console.log("supply:", IStrategyInterface(STRATEGY).totalSupply());
//         console.log("assets:", IStrategyInterface(STRATEGY).totalAssets());
//         console.log("fee:", IStrategyInterface(STRATEGY).performanceFeeRecipient());
//         // unlockedShares
//         console.log("unlockedShares:", IStrategyInterface(STRATEGY).unlockedShares());
//         revert("asd");
//     }
// }