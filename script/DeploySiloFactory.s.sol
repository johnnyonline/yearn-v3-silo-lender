// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {ISiloRepository} from "@silo/interfaces/ISiloRepository.sol";

import {SiloStrategyFactory} from "../src/strategies/silo/SiloStrategyFactory.sol";

import "forge-std/Script.sol";

// ---- Usage ----
// forge script script/DeploySiloFactory.s.sol:DeploySiloFactory --verify --legacy --etherscan-api-key $KEY --rpc-url $RPC_URL --broadcast

// verify:
// --constructor-args $(cast abi-encode "constructor(address,address,address)" 0x8658047e48CC09161f4152c79155Dac1d710Ff0a 0x1dcAD21ccD74b7A8A7BC7D19894de8Af41D9ea03 0x5C1E6bA712e9FC3399Ee7d5824B6Ec68A0363C02)
// forge verify-contract --etherscan-api-key $KEY --watch --chain-id 42161 --compiler-version v0.8.18+commit.87f61d96 --verifier-url https://api.arbiscan.io/api 0x9a5eca1b228e47a15BD9fab07716a9FcE9Eebfb5 src/ERC404/BaseERC404.sol:BaseERC404

contract DeploySiloFactory is Script {

    // address private constant MANAGEMENT = 0x16388463d60FFE0661Cf7F1f31a7D658aC790ff7; // mainnet
    address private constant MANAGEMENT = 0x1dcAD21ccD74b7A8A7BC7D19894de8Af41D9ea03; // arbitrum
    address private constant PERFORMANCE_FEE_RECIPIENT = 0x318d0059efE546b5687FA6744aF4339391153981; // yearn deployer

    // ISiloRepository private constant REPO = ISiloRepository(0xBCd67f35c7A2F212db0AD7f68fC773b5aC15377c); // https://devdocs.silo.finance/security/smart-contracts#silo-llama-ethereum
    // ISiloRepository private constant REPO = ISiloRepository(0xd998C35B7900b344bbBe6555cc11576942Cf309d); // https://devdocs.silo.finance/security/smart-contracts#silo-legacy-ethereum
    ISiloRepository private constant REPO = ISiloRepository(0x8658047e48CC09161f4152c79155Dac1d710Ff0a); // https://devdocs.silo.finance/security/smart-contracts#silo-arbitrum

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        SiloStrategyFactory _factory = new SiloStrategyFactory(REPO, MANAGEMENT, PERFORMANCE_FEE_RECIPIENT);

        console.log("-----------------------------");
        console.log("factory deployed at: ", address(_factory));
        console.log("-----------------------------");

        vm.stopBroadcast();
    }
}
forge verify-contract --etherscan-api-key $KEY --watch --chain-id 42161 --compiler-version v0.8.18+commit.87f61d96 --verifier-url https://api.arbiscan.io/api 0x127A7F610cc704Be6122dfa76eb61E84C9cb0Efd src/ERC404/BaseERC404.sol:BaseERC404

// address _repository, - 0x8658047e48CC09161f4152c79155Dac1d710Ff0a
// address _silo, - 0xA8897b4552c075e884BDB8e7b704eB10DB29BF0D
// address _share, - 0x713fc13CaAB628F116Bc34961f22a6B44aD27668
// address _asset, - 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8
// address _incentivesController, - 0xCC4933B0405Ae9DDFE05a54d20f56A0447c9EBcF
// string memory _name
--constructor-args $(cast abi-encode "constructor(address,address,address,address,address,string)" 0x8658047e48CC09161f4152c79155Dac1d710Ff0a 0xA8897b4552c075e884BDB8e7b704eB10DB29BF0D 0x713fc13CaAB628F116Bc34961f22a6B44aD27668 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8 0xCC4933B0405Ae9DDFE05a54d20f56A0447c9EBcF "Silo Lender wstETH/USDC.e")