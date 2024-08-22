// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AprOracleBase} from "@periphery/AprOracle/AprOracleBase.sol";
import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";
import {ISilo} from "@silo/interfaces/ISilo.sol";
import {ISiloRepository} from "@silo/interfaces/ISiloRepository.sol";
import {IInterestRateModel} from "@silo/interfaces/IInterestRateModel.sol";
import {IAaveIncentivesController} from "@silo/external/aave/interfaces/IAaveIncentivesController.sol";
import {EasyMathV2} from "@silo/lib/EasyMathV2.sol";

import {IStrategyInterface} from "../interfaces/IStrategyInterface.sol";

interface ISiloRepositoryExtended is ISiloRepository {
    function fees() external view returns (Fees memory);
}

contract SiloUsdcLenderAprOracle is AprOracleBase {

    uint256 private constant _PRECISION = 1e18; // dev: same precision as Silo uses for its fee calculations
    uint256 private constant _SECONDS_IN_YEAR = 60 * 60 * 24 * 365;

    mapping(address rewardAsset => AggregatorV3Interface oracle) public oracles;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _governance) AprOracleBase("Silo USDC Lender APR Oracle", _governance) {}

    /*//////////////////////////////////////////////////////////////
                                SETTERS
    //////////////////////////////////////////////////////////////*/

    function setRewardAssetPriceOracle(AggregatorV3Interface _oracle, address _asset) external onlyGovernance {
        (, int256 _rewardPrice, , uint256 _updatedAt,) = _oracle.latestRoundData();
        if (_rewardPrice <= 0 || (block.timestamp - _updatedAt) > 1 days) revert("!oracle");
        oracles[_asset] = _oracle;
        emit RewardAssetPriceOracleSet(_oracle, _asset);
    }

    /*//////////////////////////////////////////////////////////////
                                VIEWS
    //////////////////////////////////////////////////////////////*/

    function aprAfterDebtChange(address _strategy, int256 _delta) external view override returns (uint256) {

        IStrategyInterface strategy_ = IStrategyInterface(_strategy);

        address _silo = strategy_.silo();
        address _asset = strategy_.asset();
        ISilo.UtilizationData memory _utilizationData = ISilo(_silo).utilizationData(_asset);
        if (_delta < 0) require(uint256(_delta * -1) <= _utilizationData.totalDeposits, "delta exceeds deposits");

        uint256 _totalAssetsAfterDelta = uint256(int256(_utilizationData.totalDeposits) + _delta);
        require(_utilizationData.totalBorrowAmount <= _totalAssetsAfterDelta, "debt exceeds deposits");

        return
            _lendAPR(strategy_, _silo, _asset, _totalAssetsAfterDelta, _utilizationData) +
            _rewardAPR(strategy_, _totalAssetsAfterDelta, _utilizationData.totalDeposits);
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNALS
    //////////////////////////////////////////////////////////////*/

    /// @dev Assumes lent asset is a stablecoin and is worth $1
    function _lendAPR(
        IStrategyInterface _strategy,
        address _silo,
        address _asset,
        uint256 _totalAssetsAfterDelta,
        ISilo.UtilizationData memory _utilizationData
    ) internal view returns (uint256) {

        ISiloRepositoryExtended _repo = ISiloRepositoryExtended(_strategy.repository());
        IInterestRateModel _interestRateModel = _repo.getInterestRateModel(_silo, _asset);

        uint256 _rate;
        if (_totalAssetsAfterDelta == _utilizationData.totalDeposits) { // delta == 0
            _rate = _interestRateModel.getCurrentInterestRate(_silo, _asset, block.timestamp);
        } else {
            _rate = _interestRateModel.calculateCurrentInterestRate(
                _interestRateModel.getConfig(_silo, _asset),
                _totalAssetsAfterDelta,
                _utilizationData.totalBorrowAmount,
                _utilizationData.interestRateTimestamp,
                block.timestamp
            );
        }

        uint256 _dp = _interestRateModel.DP();
        uint256 _utilizationRate = EasyMathV2.calculateUtilization(_dp, _totalAssetsAfterDelta, _utilizationData.totalBorrowAmount);
        if (_utilizationRate == 0) return 0;

        return (_rate * _utilizationRate / _dp) * (_PRECISION - _repo.fees().protocolShareFee) / _PRECISION;
    }

    function _rewardAPR(
        IStrategyInterface _strategy,
        uint256 _totalAssetsAfterDelta,
        uint256 _totalAssets
    ) internal view returns (uint256) {

        IAaveIncentivesController _incentivesController = IAaveIncentivesController(_strategy.incentivesController());
        (, uint256 _ratePerSecond, ) = _incentivesController.getAssetData(_strategy.share());
        if (_ratePerSecond == 0) return 0;

        AggregatorV3Interface _rewardPriceOracle = oracles[_incentivesController.REWARD_TOKEN()];
        (, int256 _rewardPrice, , uint256 _updatedAt,) = _rewardPriceOracle.latestRoundData();
        if (_rewardPrice <= 0 || (block.timestamp - _updatedAt) > 1 days) revert("!oracle");

        IERC20Metadata _share = IERC20Metadata(_strategy.share());

        uint256 _shareDecimals = 10 ** _share.decimals();
        uint256 _totalSupplyAfterDelta =
            EasyMathV2.toShare(_shareDecimals, _totalAssets, _share.totalSupply()) *
            _totalAssetsAfterDelta /
            _shareDecimals;

        return
            _ratePerSecond * _SECONDS_IN_YEAR * _shareDecimals / _totalSupplyAfterDelta *
            uint256(_rewardPrice) / (10 ** _rewardPriceOracle.decimals());
    }

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event RewardAssetPriceOracleSet(AggregatorV3Interface _oracle, address _asset);
}