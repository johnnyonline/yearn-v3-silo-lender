// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {ExtendedTest} from "./ExtendedTest.sol";

import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {ISiloRepository} from "@silo/interfaces/ISiloRepository.sol";
import {ISilo} from "@silo/interfaces/ISilo.sol";
import {GuardedLaunch} from "@silo/utils/GuardedLaunch.sol";

import {IStrategyInterface} from "../../interfaces/IStrategyInterface.sol";

import {SiloStrategyFactory, SiloStrategy} from "../../strategies/silo/SiloStrategyFactory.sol";

import "forge-std/console.sol";

contract Strategies is ExtendedTest {

    // LlamaEdition
    address private constant _crvUSDYFISilo = 0xb0823c25cDF531a58e581eE14f160c290fef5722;
    address private constant _siloRepositoryLlama = 0xBCd67f35c7A2F212db0AD7f68fC773b5aC15377c;
    address private constant _crvUSD = 0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E;
    address private constant _incentivesControllerLlama = 0x361384A0d755f972E5Eea26e4F4efBAf976B6461;
    address private constant _crvEth = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address private constant _yfi = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;

    // Arbitrum
    address private constant _usdcweETHSilo = 0x7bec832FF8060cD396645Ccd51E9E9B0E5d8c6e4;
    address private constant _siloRepositoryARB = 0x8658047e48CC09161f4152c79155Dac1d710Ff0a;
    address private constant _usdc = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8; // 6 decimals
    address private constant _incentivesControllerARB = 0x4999873bF8741bfFFB0ec242AAaA7EF1FE74FCE8; // SILO rewards
    address private constant _weETH = 0x35751007a407ca6FEFfE80b3cB397736D2cf4dbe;
    address private constant _crvArb = 0x11cDb42B0EB46D95f990BeDD4695A6e3fA034978;

    // ----

    address private _borrower = address(420);

    address private constant silo = _crvUSDYFISilo;
    address private constant borrowedAsset = _crvUSD;
    address private constant collateralAsset = _yfi;
    address private constant incentivesController = _incentivesControllerLlama;
    address private constant siloRepository = _siloRepositoryLlama;
    address private constant _crv = _crvEth;

    // address private constant silo = _usdcweETHSilo;
    // address private constant borrowedAsset = _usdc;
    // address private constant collateralAsset = _weETH;
    // address private constant incentivesController = _incentivesControllerARB;
    // address private constant siloRepository = _siloRepositoryARB;
    // address private constant _crv = _crvArb;

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
        assertEq(
            address(_strategy.incentivesController()),
            incentivesController,
            "!incentivesController"
        );
        assertEq(address(_strategy.silo()), silo, "!silo");
        assertEq(
            address(_strategy.share()),
            address(_strategy.silo().assetStorage(borrowedAsset).collateralToken),
            "!share"
        );
        assertEq(
            IStrategyInterface(address(_strategy)).performanceFeeRecipient(),
            performanceFeeRecipient,
            "!performanceFeeRecipient"
        );
        assertEq(
            IStrategyInterface(address(_strategy)).performanceFee(),
            1_000,
            "!performanceFee"
        );
    }

    function _customStrategyTest(address strategy_) internal {
        _testWithdrawLimit(strategy_);
        _testDepositLimit(strategy_);
    }

    /*//////////////////////////////////////////////////////////////
                    STRATEGY SPECIFIC HELPERS - SILO
    //////////////////////////////////////////////////////////////*/

    function _setUpSiloStrategy() private returns (address _strategy) {
        vm.expectRevert("invalid silo repository");
        new SiloStrategyFactory(
            ISiloRepository(address(0)),
            management,
            performanceFeeRecipient
        );

        SiloStrategyFactory factory = new SiloStrategyFactory(
            ISiloRepository(siloRepository),
            management,
            performanceFeeRecipient
        );

        vm.expectRevert("!management");
        factory.deploySiloStrategy(
            management,
            _crv,
            collateralAsset,
            incentivesController,
            "crvUSD/YFI SiloLlamaStrategy"
        );

        vm.startPrank(management);

        vm.expectRevert("wrong silo");
        factory.deploySiloStrategy(
            management,
            _crv,
            collateralAsset,
            incentivesController,
            "crvUSD/YFI SiloLlamaStrategy"
        );

        vm.expectRevert("wrong silo");
        factory.deploySiloStrategy(
            management,
            collateralAsset,
            _crv,
            incentivesController,
            "crvUSD/YFI SiloLlamaStrategy"
        );

        _strategy = address(factory.deploySiloStrategy(
            management,
            collateralAsset,
            borrowedAsset,
            incentivesController,
            "crvUSD/YFI SiloLlamaStrategy"
        ));

        vm.expectRevert("already deployed");
        factory.deploySiloStrategy(
            management,
            collateralAsset,
            borrowedAsset,
            incentivesController,
            "crvUSD/YFI SiloLlamaStrategy"
        );

        vm.stopPrank();
    }

    function _earnSiloInterest() private {
        uint256 _accruedInterest = ISilo(silo).accrueInterest(borrowedAsset);
        // require(_accruedInterest > 0, "no interest accrued"); // dev: could not earn interest for some reason
    }

    function _testDepositLimit(address strategy_) private {
        GuardedLaunch _repo = GuardedLaunch(siloRepository);
        assertEq(_repo.getMaxSiloDepositsValue(silo, borrowedAsset), type(uint256).max, "_testDepositLimit: E0");

        vm.startPrank(_repo.manager());
        _repo.setLimitedMaxLiquidity(true);

        ISilo.AssetStorage memory _assetState = ISilo(silo).assetStorage(borrowedAsset);
        uint256 _totalDeposit = _assetState.totalDeposits + _assetState.collateralOnlyDeposits;

        uint256 _price = ISiloRepository(siloRepository).priceProvidersRepository().getPrice(borrowedAsset);
        uint256 _totalDepositsValue = _price * _totalDeposit / (10 ** IERC20Metadata(borrowedAsset).decimals());

        _repo.setSiloMaxDepositsLimit(silo, borrowedAsset, _totalDepositsValue);
        assertEq(_repo.getMaxSiloDepositsValue(silo, borrowedAsset), _totalDepositsValue, "_testDepositLimit: E1");
        assertEq(IStrategyInterface(strategy_).availableDepositLimit(address(0)), 0, "_testDepositLimit: E2");

        _repo.setSiloMaxDepositsLimit(silo, borrowedAsset, _totalDepositsValue * 2);
        assertEq(_repo.getMaxSiloDepositsValue(silo, borrowedAsset), _totalDepositsValue * 2, "_testDepositLimit: E3");
        assertApproxEqAbs(IStrategyInterface(strategy_).availableDepositLimit(address(0)), _totalDeposit, 1e4, "_testDepositLimit: E4");
        assertGe(_totalDeposit, IStrategyInterface(strategy_).availableDepositLimit(address(0)), "_testDepositLimit: E5");

        vm.stopPrank();
    }

    function _testWithdrawLimit(address strategy_) private {
        SiloStrategy _strategy = SiloStrategy(strategy_);
        ISilo _silo = _strategy.silo();

        uint256 _amount = 1_000_000_000 * 1e18;
        deal(collateralAsset, _borrower, _amount);

        vm.startPrank(_borrower);

        ERC20(collateralAsset).approve(address(_silo), _amount);

        _silo.deposit(
            collateralAsset,
            _amount,
            true // _collateralOnly
        );

        _silo.borrow(
            borrowedAsset,
            ISilo(silo).liquidity(borrowedAsset) // borrow all
        );

        vm.stopPrank();

        assertEq(_strategy.availableWithdrawLimit(address(0)), 0, "!availableWithdrawLimit");
    }
}
