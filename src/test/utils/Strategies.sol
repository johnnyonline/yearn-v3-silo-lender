// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {ExtendedTest} from "./ExtendedTest.sol";

import {ISiloRepository} from "@silo/interfaces/ISiloRepository.sol";
import {ISilo} from "@silo/interfaces/ISilo.sol";

import {SiloStrategyFactory, SiloStrategy} from "../../strategies/silo/SiloStrategyFactory.sol";

import {Test} from "forge-std/Test.sol";

contract Strategies is ExtendedTest{

    address private constant _crvUSDCRVSilo = 0x96eFdF95Cc47fe90e8f63D2f5Ef9FB8B180dAeB9;
    address private constant _siloRepository = 0xBCd67f35c7A2F212db0AD7f68fC773b5aC15377c;
    address private constant _crvUSD = 0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E;
    address private constant _incentivesController = 0x361384A0d755f972E5Eea26e4F4efBAf976B6461;
    address private constant _crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address private constant _yfi = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;

    /*//////////////////////////////////////////////////////////////
                        GENERAL STRATEGY HELPERS
    //////////////////////////////////////////////////////////////*/

    function _setUpStrategy() internal returns (address) {
        return _setUpSiloStrategy();
    }

    function _earnInterest() internal {
        _earnSiloInterest();
    }

    function _testSetupStrategyOK(address strategy_) internal {
        SiloStrategy _strategy = SiloStrategy(strategy_);
        assertEq(address(_strategy.rewardToken()), _strategy.incentivesController().REWARD_TOKEN(), "!rewardToken");
        assertEq(address(_strategy.incentivesController()), _incentivesController, "!incentivesController");
        assertEq(address(_strategy.silo()), _crvUSDCRVSilo, "!silo");
        assertEq(address(_strategy.share()), address(_strategy.silo().assetStorage(_crvUSD).collateralToken), "!share");
    }

    /*//////////////////////////////////////////////////////////////
                    STRATEGY SPECIFIC HELPERS - SILO
    //////////////////////////////////////////////////////////////*/

    function _setUpSiloStrategy() private returns (address _strategy) {

        vm.expectRevert("invalid silo repository");
        new SiloStrategyFactory(ISiloRepository(address(0)));

        SiloStrategyFactory factory = new SiloStrategyFactory(ISiloRepository(_siloRepository));

        vm.expectRevert("wrong silo");
        factory.deploySiloStrategy(management, _crv, _yfi, _incentivesController, "crvUSD/CRV SiloLlamaStrategy");

        vm.expectRevert("wrong silo");
        factory.deploySiloStrategy(management, _yfi, _crv, _incentivesController, "crvUSD/CRV SiloLlamaStrategy");

        address _faultyIncentivesController = 0x6c1603aB6CecF89DD60C24530DdE23F97DA3C229;
        vm.expectRevert("no incentives");
        factory.deploySiloStrategy(management, _crv, _crvUSD, _faultyIncentivesController, "crvUSD/CRV SiloLlamaStrategy");

        _strategy = factory.deploySiloStrategy(
            management,
            _crv,
            _crvUSD,
            _incentivesController,
            "crvUSD/CRV SiloLlamaStrategy"
        );
    }

    function _earnSiloInterest() private {
        ISilo(_crvUSDCRVSilo).accrueInterest(_crvUSD);
    }
}