// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {ISilo} from "@silo/interfaces/ISilo.sol";

import {SiloLlamaStrategy} from "../../strategies/crvUSD/SiloLlamaStrategy.sol";

contract Strategies {

    address private _crvUSDCRVSilo = 0x96eFdF95Cc47fe90e8f63D2f5Ef9FB8B180dAeB9;
    address private _crvUSD = 0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E;

    function _setUpStrategy() internal returns (address) {
        return _setUpSiloLlamaStrategy();
    }

    function _earnInterest() internal {
        _earnSiloLlamaInterest();
    }

    function _setUpSiloLlamaStrategy() private returns (address _strategy) {
        _strategy = address(new SiloLlamaStrategy(
            address(_crvUSDCRVSilo), // _silo
            address(0x361384A0d755f972E5Eea26e4F4efBAf976B6461), // _incentivesController
            _crvUSD, // _asset
            "crvUSD/CRV SiloLlamaStrategy"
        ));
    }

    function _earnSiloLlamaInterest() private {
        ISilo(_crvUSDCRVSilo).accrueInterest(_crvUSD);
    }
}