------------ NOTES ------------

poolpi deployments - https://hackmd.io/qyPSHxCWT-G4jfMvAPzSqg
yHaaS Network Guide - https://hackmd.io/@mil0xeth/B1Ux3cLKR
V3 Roles - https://github.com/yearn/strategist-ms/blob/master/yearn/v3_constants.py#L12

Set up (arbitrum):
    - acceptManagement() from committee multisig
    - setEmergencyAdmin() to 0x6346282DB8323A54E840c6C772B4399C9c655C0d
    - setMaxProfitUnlockTime to 86400 (1 day)
    - setKeeper to 0xE0D19f6b240659da8E87ABbB73446E7B4346Baee (see yHaaS Network Guide)
    - setTradeFactory to 0xE8228A2E7102ce51Bb73115e2964A233248398B9
    - addToken for ARB (0x912CE59144191C1204E64559FE8253a0e49E6548) => USDC.e (0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8)
    - setOracle in 0x27aD2fFc74F74Ed27e1C0A19F1858dD0963277aE

Set up (mainnet):
    - acceptManagement() from committee multisig
    - setEmergencyAdmin() to 0x16388463d60FFE0661Cf7F1f31a7D658aC790ff7
    - setMaxProfitUnlockTime to 604800 (7 days)
    - setKeeper to 0x604e586F17cE106B64185A7a0d2c1Da5bAce711E (see yHaaS Network Guide)
    - setTradeFactory to 0xb634316E06cC0B358437CbadD4dC94F1D3a92B3b
    - addToken for SILO (0x6f80310CA7F2C654691D1383149Fa1A57d8AB1f8) => USDC (0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) / WETH (0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)
    - setOracle in 0x27aD2fFc74F74Ed27e1C0A19F1858dD0963277aE

When deprecating a strategy:
    - let Milo know about it in advance, so he can remove the strategy from yHaaS and i can do the final report through SMS in the same tx as i deprecate it
    - setKeeper() back to msig from yHAAS

Set up a Vault:
    - use Factory (with my address as `role_manager`)
    - set_role(yearnDeployer, 16383);
    - _vault.set_deposit_limit(100000000000000);
    - _vault.add_strategy(strategy1);
    - _vault.update_max_debt_for_strategy(strategy1, 10000000000000);
    - add to yHAAS
    - add to yDAEMON (after it was picked up) (e.g. https://github.com/yearn/ydaemon/pull/399)
    - endorse (e.g. https://github.com/yearn/chief-multisig-officer/pull/1419)

------------ Mainnet ------------

Vaults:
    - crvUSD - 0xBF319dDC2Edc1Eb6FDf9910E39b37Be221C8805F
    - USDC (Silo LRT) - 0x4Dd0FE8549641A04d7ab4f37dbb541aE7dBb2838
    - WETH (Silo LRT) - 0x3f540647b08e3E9bcD297e065e42E6CDAF37eBa0

Factory Llama Edition:
    - 0xcfFeB2408ADfbab998f6929054f91d8DD9a9c8A1

Factory Silo Legacy:
    - 0xBa230f4Bf34E48D04e65dE9a0F6Fe5EcDAa0c17A

Factory Silo New:
    - 0xbAF4Cb2A7182e5bD4abb54C6F116d56c0E8b588C
    - 0x3e1435Cd3e13423de06C0CE4F9B8deb19A74f7B9 (new Factory, with manual rewards claiming)

Stratagies Silo New
    - Silo Lender: USDC/PT-ezETH (26 Sep) - 0x8783C4aAf81B9312AdCCCcC09fa7B36b9d1f624f
    - Silo Lender: USDC/PT-eETH (26 Sep) - 0x2e3daa02411dC9A2cdb7e3409eB2fF0f90154C9A
    - Silo Lender: USDC/PT-pufETH (26 Sep) - 0x333f4f2a8bc9eDbDeB1f913b147bB47f76919956
    - Silo Lender: USDC/PT-sUSDE (26 Sep) - 0x6d197c7a600788BC2A996460e70B91995Bf70Ce2
    - Silo Lender: USDC/ezETH - 0x6D6092C129601e59938beAf695858E03850E51C0
    - Silo Lender: USDC/weETH - 0xF232C4b675c9e8541712b7Ea32dCb4cfbB93AB80

Stratagies Silo New (new Factory, with manual rewards claiming):
    - Silo Lender: USDC/PT-ezETH (26 Sep) - 0x970befebDF0C5aac775D2391Fbb7A15b5C284b9c
    - Silo Lender: USDC/PT-eETH (26 Sep) - 0x4A0Fce1af23BB0d6C63A67A9658728d34e37ec00
    - Silo Lender: USDC/PT-pufETH (26 Sep) - 0xD0269e26cDF21537B52Ef506D6C241109b9a3F65
    - Silo Lender: USDC/ezETH - 0x03F60C781a22DB4C8a2bAA118f39f0e8AC52326B
    - Silo Lender: USDC/weETH - 0x262683DaFa4218f6B62Dd5Ee23d233Af6E7a0F33
    - Silo Lender: USDC/rstETH - 0x0666E28441F7F0B461e6A075edE46153aA5C6124
    - Silo Lender: USDC/amphrETH - 0x8582279459BC320909D034a8f972a2dC6d0f0929
    - Silo Lender: USDC/pzETH - 0xA9c16bBA9078C4d8c341847307D7F1f86950411c
    - Silo Lender: USDC/Re7LRT - 0x8B8ccc510d3fC4CC9B5E0f9c0611e26f4eF8Cd77
    - Silo Lender: WETH/Re7LRT - 0x91C14409E03570AEDDb2fCe5709032a71a46c9EE
    - Silo Lender: WETH/amphrETH - 0xe6f11cb8335e4AE364C3A7F941Bbcb6E7ABB2A51
    - Silo Lender: WETH/pzETH - 0x9ED112B9cED514894D253B3Fdc20d13876B50514

APR Oracle:
    - 0x365F901dfD546D7b9a4a8C3Cca4a826a3eE000B2 (faulty manager)
    - usdc - 0x8fD057567D9fF56A42315F8BC1e31FDe5c01F89d
    - dummy oracle - 0xeA7dE917660a7F42742E371E4C33f39433d92C5D
    - new - 0xD38B163EB243c90f4a089e9818ceEfde29B0C5C8

------------ Arbitrum ------------

Vaults:
    - USDC.e - 0x2e48847FE29C3883c98125Cb2C44244d6602d549
    - USDC.e-2 - 0x9FA306b1F4a6a83FEC98d8eBbaBEDfF78C407f6B

Factory:
    - 0xDd737dADA46F3A111074dCE29B9430a7EA000092
    - 0xb628B1fdbE8C01777aEa2bF3bd386df4Af84e8d3 (new Factory, with manual rewards claiming)

Stratagies:
    - Silo Lender: USDC.e/wstETH - 0x127A7F610cc704Be6122dfa76eb61E84C9cb0Efd
    - Silo Lender: USDC.e/wBTC - 0x2d25Ce68AAd6Ffef1585ff05bC621db1F9F2E499

Stratagies (new Factory, with manual rewards claiming):
    - Silo Lender wstETH/USDC.e - 0xA4B8873B4629c20f2167c0A2bC33B6AF8699dDc1
    - Silo Lender: USDC.e/wBTC - 0xE82D060687C014B280b65df24AcD94A77251C784
    - Silo Lender ARB/USDC.e - 0xb739AE19620f7ECB4fb84727f205453aa5bc1AD2

TradeFactory:
    - 0xE8228A2E7102ce51Bb73115e2964A233248398B9

APR Oracle:
    - 0xEB3d79b238Ea547a4A37a448ba37fEc247e2F69e
