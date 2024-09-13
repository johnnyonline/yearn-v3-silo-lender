// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {IVault} from "@periphery-lib/yearn-vaults-v3/contracts/interfaces/IVault.sol";
import {IVaultFactory} from "@periphery-lib/yearn-vaults-v3/contracts/interfaces/IVaultFactory.sol";
import "forge-std/Script.sol";

// ---- Usage ----
// forge script script/DeployVault.s.sol:DeployVault --legacy --slow --rpc-url $RPC_URL --broadcast

contract DeployVault is Script {

    address yearnDeployer = 0x318d0059efE546b5687FA6744aF4339391153981; // yearn deployer (me)
    IVaultFactory factory = IVaultFactory(0x444045c5C13C246e117eD36437303cac8E250aB0); // mainnet

    address strategy1 = 0x91C14409E03570AEDDb2fCe5709032a71a46c9EE; // WETH/Re7LRT
    address strategy2 = 0xe6f11cb8335e4AE364C3A7F941Bbcb6E7ABB2A51; // WETH/amphrETH //
    address strategy3 = 0x9ED112B9cED514894D253B3Fdc20d13876B50514; // WETH/pzETH

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        IVault _vault = IVault(factory.deploy_new_vault(
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // WETH
            "Silo-LRT WETH yVault",
            "yvSilo-LRT-WETH",
            yearnDeployer,
            604800
        ));

        // IVault _vault = IVault(0x3f540647b08e3E9bcD297e065e42E6CDAF37eBa0); // set vault

        // set role
        _vault.set_role(yearnDeployer, 16383);

        // set deposit limit
        _vault.set_deposit_limit(100000000000000);
        // 6 decimals -  100000000 000000
        // 18 decimals - 100000000 000000000000000000
        // 40000000000000000000000

        // add strategy and update max debt for strategy
        _vault.add_strategy(strategy1);
        _vault.update_max_debt_for_strategy(strategy1, 10000000000000);
        // 6 deciamls -  10000000000000
        // 18 decimals - 10000000000000000000000000
        // 4000000000000000000000

        _vault.add_strategy(strategy2);
        _vault.update_max_debt_for_strategy(strategy2, 10000000000000);

        _vault.add_strategy(strategy3);
        _vault.update_max_debt_for_strategy(strategy3, 10000000000000);

        _vault.transfer_role_manager(0xb3bd6B2E61753C311EFbCF0111f75D29706D9a41); //

        console.log("-----------------------------");
        console.log("vault deployed at: ", address(_vault));
        console.log("-----------------------------");

        vm.stopBroadcast();
    }
}