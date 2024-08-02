------------ NOTES ------------

poolpi deployments - https://hackmd.io/qyPSHxCWT-G4jfMvAPzSqg
yHaaS Network Guide - https://hackmd.io/@mil0xeth/B1Ux3cLKR

Set up (arbitrum):
    - acceptManagement() from committee multisig
    - setEmergencyAdmin() to 0x6346282DB8323A54E840c6C772B4399C9c655C0d
    - setMaxProfitUnlockTime to 86400 (1 day)
    - setTradeFactory to whatever the trade factory address is...
    - addToken for ARB => USDC.e
    - setKeeper to 0xE0D19f6b240659da8E87ABbB73446E7B4346Baee (see yHaaS Network Guide)

Set up (mainnet):
    - acceptManagement() from committee multisig
    - setEmergencyAdmin() to XXX
    - setMaxProfitUnlockTime to 86400 (1 day)
    - setTradeFactory to whatever the trade factory address is...
    - addToken for SILO => USDC
    - setKeeper to 0x604e586F17cE106B64185A7a0d2c1Da5bAce711E (see yHaaS Network Guide)


------------ Mainnet ------------

Vaults:
    - crvUSD - 0xBF319dDC2Edc1Eb6FDf9910E39b37Be221C8805F

Factory Llama Edition:
    - 0xcfFeB2408ADfbab998f6929054f91d8DD9a9c8A1

Factory Silo Legacy:
    - 0xBa230f4Bf34E48D04e65dE9a0F6Fe5EcDAa0c17A

Factory Silo New:
    - 0xbAF4Cb2A7182e5bD4abb54C6F116d56c0E8b588C

Stratagies Silo New:
    - Silo Lender: USDC/PT-ezETH (26 Sep) - 0x8783C4aAf81B9312AdCCCcC09fa7B36b9d1f624f (need to set up)

------------ Arbitrum ------------

Vaults:
    - USDC.e - 0x2e48847FE29C3883c98125Cb2C44244d6602d549

Factory:
    - 0xDd737dADA46F3A111074dCE29B9430a7EA000092

Stratagies:
    - Silo Lender: USDC.e/wstETH - 0x127A7F610cc704Be6122dfa76eb61E84C9cb0Efd
    - Silo Lender: USDC.e/wBTC - 0x2d25Ce68AAd6Ffef1585ff05bC621db1F9F2E499