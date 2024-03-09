// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {AprOracleBase} from "@periphery/AprOracle/AprOracleBase.sol";

import {ISilo} from "@silo/interfaces/ISilo.sol";

import {SiloLlamaStrategy} from "../../strategies/crvUSD/SiloLlamaStrategy.sol";
import {SiloLlamaAprOracle} from "../../strategies/crvUSD/SiloLlamaAprOracle.sol";

contract Strategies {

    address private _crvUSDCRVSilo = 0x96eFdF95Cc47fe90e8f63D2f5Ef9FB8B180dAeB9;
    address private _crvUSD = 0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E;

    function _setUpStrategy() internal returns (address) {
        return _setUpSiloLlamaStrategy();
    }

    function _earnInterest() internal {
        _earnSiloLlamaInterest();
    }

    function _deployAprOracle() internal returns (AprOracleBase) {
        return AprOracleBase(address(new SiloLlamaAprOracle(
            address(0xBCd67f35c7A2F212db0AD7f68fC773b5aC15377c), // _siloRepository
            _crvUSDCRVSilo, // _silo
            _crvUSD, // _asset
            "crvUSD/CRV SiloLlamaAprOracle"
        )));
    }

    function _setUpSiloLlamaStrategy() private returns (address _strategy) {
        // address[] memory _rewardTokens,
        address[] memory _rewardTokens = new address[](2);
        _rewardTokens[0] = address(0xD533a949740bb3306d119CC777fa900bA034cd52); // CRV
        _rewardTokens[1] = address(0x5B5CFE992AdAC0C9D48E05854B2d91C73a003858); // SILO
        _strategy = address(new SiloLlamaStrategy(
            address(0x361384A0d755f972E5Eea26e4F4efBAf976B6461), // _incentivesController
            address(_crvUSDCRVSilo), // _silo
            address(0xb27D1729489d04473631f0AFAca3c3A7389ac9F8), // _share
            _crvUSD, // _asset
            _rewardTokens,
            "crvUSD/CRV SiloLlamaStrategy"
        ));
    }

    function _earnSiloLlamaInterest() private {
        ISilo(_crvUSDCRVSilo).accrueInterest(_crvUSD);
    }
}