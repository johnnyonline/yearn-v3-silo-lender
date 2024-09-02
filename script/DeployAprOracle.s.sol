// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {SiloUsdcLenderAprOracle} from "../src/periphery/SiloUsdcLenderAprOracle.sol";
import {DummyOracle} from "../src/periphery/DummyOracle.sol";

import "forge-std/Script.sol";

// ---- Usage ----
// forge script script/DeployAprOracle.s.sol:DeployAprOracle --verify --legacy --etherscan-api-key $KEY --rpc-url $RPC_URL --broadcast

// verify:
// --constructor-args $(cast abi-encode "constructor(address,address,address)" 0xbACBBefda6fD1FbF5a2d6A79916F4B6124eD2D49 0x6A16CFA0dF474f3cB1BF5bBa595248EEfb404e2b 0x318d0059efE546b5687FA6744aF4339391153981)
// forge verify-contract --etherscan-api-key $KEY --watch --chain-id 42161 --compiler-version v0.8.18+commit.87f61d96 --verifier-url https://api.arbiscan.io/api 0x9a5eca1b228e47a15BD9fab07716a9FcE9Eebfb5 src/ERC404/BaseERC404.sol:BaseERC404

contract DeployAprOracle is Script {

    // address private constant MANAGEMENT = 0x1dcAD21ccD74b7A8A7BC7D19894de8Af41D9ea03; // arbitrum
    address private constant MANAGEMENT = 0x6A16CFA0dF474f3cB1BF5bBa595248EEfb404e2b; // mainnet

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        SiloUsdcLenderAprOracle _oracle = new SiloUsdcLenderAprOracle(MANAGEMENT);
        DummyOracle _dummyOracle = new DummyOracle();

        console.log("-----------------------------");
        console.log("oracle deployed at: ", address(_oracle));
        console.log("dummy oracle deployed at: ", address(_dummyOracle));
        console.log("-----------------------------");

        vm.stopBroadcast();
    }
}