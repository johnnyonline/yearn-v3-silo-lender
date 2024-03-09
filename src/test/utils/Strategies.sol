// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {ISilo} from "@silo/interfaces/ISilo.sol";

import {SiloStrategy} from "../../strategies/silo/SiloStrategy.sol";

contract Strategies {

    address private constant _crvUSDCRVSilo = 0x96eFdF95Cc47fe90e8f63D2f5Ef9FB8B180dAeB9;
    address private constant _siloRepository = 0xBCd67f35c7A2F212db0AD7f68fC773b5aC15377c;
    address private constant _crvUSD = 0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E;
    address private constant _incentivesController = 0x361384A0d755f972E5Eea26e4F4efBAf976B6461;
    address private constant _crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;

    function _setUpStrategy() internal returns (address) {
        return _setUpSiloStrategy();
    }

    function _earnInterest() internal {
        _earnSiloInterest();
    }

    function _setUpSiloStrategy() private returns (address _strategy) {
        _strategy = address(new SiloStrategy(
            _siloRepository,
            _incentivesController,
            _crv,
            _crvUSD,
            "crvUSD/CRV SiloLlamaStrategy"
        ));
    }

    function _earnSiloInterest() private {
        ISilo(_crvUSDCRVSilo).accrueInterest(_crvUSD);
    }
}