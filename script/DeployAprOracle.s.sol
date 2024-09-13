// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";

import {SiloLenderAprOracle} from "../src/periphery/SiloLenderAprOracle.sol";
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

    address public constant REWARD = 0x6f80310CA7F2C654691D1383149Fa1A57d8AB1f8; // SILO
    address public constant ASSET = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    address public constant WETH_ORACLE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // mainnet

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address _yearnDeployer = 0x318d0059efE546b5687FA6744aF4339391153981;

        SiloLenderAprOracle _oracle = new SiloLenderAprOracle(_yearnDeployer);
        DummyOracle _dummyOracle = new DummyOracle();

        _oracle.setRewardAssetPriceOracle(AggregatorV3Interface(address(_dummyOracle)), REWARD);
        _oracle.setRewardAssetPriceOracle(AggregatorV3Interface(address(WETH_ORACLE)), ASSET);

        _oracle.transferGovernance(MANAGEMENT);

        console.log("-----------------------------");
        console.log("oracle deployed at: ", address(_oracle));
        console.log("-----------------------------");

        vm.stopBroadcast();
    }
}