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
    address private constant _usdcwstETHSilo = 0xA8897b4552c075e884BDB8e7b704eB10DB29BF0D;
    address private constant _siloRepositoryARB = 0x8658047e48CC09161f4152c79155Dac1d710Ff0a;
    address private constant _usdc = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8; // 6 decimals
    address private constant _incentivesControllerARB = 0x7e5BFBb25b33f335e34fa0d78b878092931F8D20; // SILO rewards
    // 0xCC4933B0405Ae9DDFE05a54d20f56A0447c9EBcF // ARB rewards
    address private constant _wstETH = 0x5979D7b546E38E414F7E9822514be443A4800529;
    address private constant _crvArb = 0x11cDb42B0EB46D95f990BeDD4695A6e3fA034978;

    SiloStrategyFactory private constant _actualFactory = SiloStrategyFactory(0xDd737dADA46F3A111074dCE29B9430a7EA000092);

    // Optimism
    address private constant _usdcwBTCSilo = 0x03d0b417b7Bcd0C399f1db3321985353a515B2b8;
    address private constant _siloRepositoryOP = 0xD2767dAdED5910bbc205811FdbD2eEFd460AcBe9;
    address private constant _usdcOP = 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85;
    address private constant _incentivesControllerOP = 0x847D9420643e117798e803d9C5F0e406277CB622;
    address private constant _wBTC = 0x68f180fcCe6836688e9084f035309E29Bf0A2095;
    address private constant _snxOP = 0x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4;

    // ----

    address private _borrower = address(420);

    // Ethereum
    address private constant silo = _crvUSDYFISilo;
    address private constant borrowedAsset = _crvUSD;
    address private constant collateralAsset = _yfi;
    address private constant incentivesController = _incentivesControllerLlama;
    address private constant siloRepository = _siloRepositoryLlama;
    address private constant _crv = _crvEth;

    // Arbitrum
    // address private constant silo = _usdcwstETHSilo;
    // address private constant borrowedAsset = _usdc;
    // address private constant collateralAsset = _wstETH;
    // address private constant incentivesController = _incentivesControllerARB;
    // address private constant siloRepository = _siloRepositoryARB;
    // address private constant _crv = _crvArb;

    // Optimism
    // address private constant silo = _usdcwBTCSilo;
    // address private constant borrowedAsset = _usdcOP;
    // address private constant collateralAsset = _wBTC;
    // address private constant incentivesController = _incentivesControllerOP;
    // address private constant siloRepository = _siloRepositoryOP;
    // address private constant _crv = _snxOP;

    /*//////////////////////////////////////////////////////////////
                        GENERAL STRATEGY HELPERS
    //////////////////////////////////////////////////////////////*/

    function _setUpStrategy() internal returns (address) {
        // return _setUpSiloStrategy();
        vm.prank(management);
        return address(_actualFactory.deploySiloStrategy(management, collateralAsset, borrowedAsset, incentivesController, "crvUSD/YFI SiloLlamaStrategy"));
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
