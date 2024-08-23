// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {ISiloRepository} from "@silo/interfaces/ISiloRepository.sol";

import {SiloStrategyFactory} from "../src/strategies/silo/SiloStrategyFactory.sol";

import "forge-std/Script.sol";

// ---- Usage ----
// forge script script/DeploySiloFactory.s.sol:DeploySiloFactory --verify --legacy --etherscan-api-key $KEY --rpc-url $RPC_URL --broadcast

// verify:
// --constructor-args $(cast abi-encode "constructor(address,address,address)" 0xbACBBefda6fD1FbF5a2d6A79916F4B6124eD2D49 0x6A16CFA0dF474f3cB1BF5bBa595248EEfb404e2b 0x318d0059efE546b5687FA6744aF4339391153981)
// forge verify-contract --etherscan-api-key $KEY --watch --chain-id 42161 --compiler-version v0.8.18+commit.87f61d96 --verifier-url https://api.arbiscan.io/api 0x9a5eca1b228e47a15BD9fab07716a9FcE9Eebfb5 src/ERC404/BaseERC404.sol:BaseERC404

// - acceptManagement()
//     - setEmergencyAdmin() to 0x6346282DB8323A54E840c6C772B4399C9c655C0d
//     - setMaxProfitUnlockTime to 86400
//     - setKeeper to 0xE0D19f6b240659da8E87ABbB73446E7B4346Baee
//     - addToken for ARB => USDC.e

contract DeploySiloFactory is Script {

    address private constant MANAGEMENT = 0x6A16CFA0dF474f3cB1BF5bBa595248EEfb404e2b; // mainnet
    // address private constant MANAGEMENT = 0x1dcAD21ccD74b7A8A7BC7D19894de8Af41D9ea03; // arbitrum
    address private constant PERFORMANCE_FEE_RECIPIENT = 0x318d0059efE546b5687FA6744aF4339391153981; // yearn deployer

    // ISiloRepository private constant REPO = ISiloRepository(0xBCd67f35c7A2F212db0AD7f68fC773b5aC15377c); // https://devdocs.silo.finance/security/smart-contracts#silo-llama-ethereum
    // ISiloRepository private constant REPO = ISiloRepository(0xd998C35B7900b344bbBe6555cc11576942Cf309d); // https://devdocs.silo.finance/security/smart-contracts#silo-legacy-ethereum
    ISiloRepository private constant REPO = ISiloRepository(0xbACBBefda6fD1FbF5a2d6A79916F4B6124eD2D49); // https://devdocs.silo.finance/security/smart-contracts#silo-legacy-ethereum
    // ISiloRepository private constant REPO = ISiloRepository(0x8658047e48CC09161f4152c79155Dac1d710Ff0a); // https://devdocs.silo.finance/security/smart-contracts#silo-arbitrum

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        SiloStrategyFactory _factory = new SiloStrategyFactory(REPO, MANAGEMENT, PERFORMANCE_FEE_RECIPIENT);

        console.log("-----------------------------");
        console.log("factory deployed at: ", address(_factory));
        console.log("-----------------------------");

        vm.stopBroadcast();
    }
}

//         address _repository, // 0xbACBBefda6fD1FbF5a2d6A79916F4B6124eD2D49
//         address _silo, // 0x26a334F76A1aC40Bb6094131f7D30BBA0c08D4c6
//         address _share, // 0x4482E26ee5fEB318c2EBe0e00891f834739949C6
//         address _asset, // 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
//         address _incentivesController, // 0xB14F20982F2d1E5933362f5A796736D9ffa220E4
//         string memory _name // Silo Lender: USDC/weETH
--constructor-args $(cast abi-encode "constructor(address,address,address,address,address,string)" 0xbACBBefda6fD1FbF5a2d6A79916F4B6124eD2D49 0x26a334F76A1aC40Bb6094131f7D30BBA0c08D4c6 0x4482E26ee5fEB318c2EBe0e00891f834739949C6 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 0xB14F20982F2d1E5933362f5A796736D9ffa220E4 "Silo Lender: USDC/weETH")
forge verify-contract --etherscan-api-key BX1TIHEAARY5TKZD4N6BH931APXEJRDR3V --watch --compiler-version v0.8.18+commit.87f61d96 0x262683DaFa4218f6B62Dd5Ee23d233Af6E7a0F33 src/ERC404/BaseERC404.sol:BaseERC404