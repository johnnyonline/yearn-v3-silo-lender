// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {BaseHealthCheck, ERC20} from "@periphery/Bases/HealthCheck/BaseHealthCheck.sol";
import {TradeFactorySwapper} from "@periphery/swappers/TradeFactorySwapper.sol";
import {Governance2Step} from "@periphery/utils/Governance2Step.sol";

import {IAaveIncentivesController} from "@silo/external/aave/interfaces/IAaveIncentivesController.sol";
import {IGuardedLaunch} from "@silo/interfaces/IGuardedLaunch.sol";
import {ISiloRepository} from "@silo/interfaces/ISiloRepository.sol";
import {ISilo} from "@silo/interfaces/ISilo.sol";
import {IShareToken} from "@silo/interfaces/IShareToken.sol";
import {EasyMathV2} from "@silo/lib/EasyMathV2.sol";

/**
 * The `TokenizedStrategy` variable can be used to retrieve the strategies
 * specific storage data your contract.
 *
 *       i.e. uint256 totalAssets = TokenizedStrategy.totalAssets()
 *
 * This can not be used for write functions. Any TokenizedStrategy
 * variables that need to be updated post deployment will need to
 * come from an external call from the strategies specific `management`.
 */

// NOTE: To implement permissioned functions you can use the onlyManagement, onlyEmergencyAuthorized and onlyKeepers modifiers

/**
 * @title SiloStrategy
 * @author johnnyonline
 * @notice A strategy that deposits funds into a Silo and harvests incentives.
 */
contract SiloStrategy is BaseHealthCheck, TradeFactorySwapper, Governance2Step {
    using SafeERC20 for ERC20;
    using EasyMathV2 for uint256;

    /**
     * @dev The incentives controller that pays the reward token.
     */
    IAaveIncentivesController public incentivesController;

    /**
     * @dev The Silo repository contract.
     */
    ISiloRepository public immutable repository;

    /**
     * @dev The Silo that the strategy is using.
     */
    ISilo public immutable silo;

    /**
     * @dev The share token that represents the strategy's share of the Silo.
     */
    IShareToken public immutable share;

    /**
     * @notice Used to initialize the strategy on deployment.
     * @param _governance Address of the governance contract.
     * @param _repository Address of the Silo repository.
     * @param _silo Address of the Silo that the strategy is using.
     * @param _share Address of the share token that represents the strategy's share of the Silo.
     * @param _asset Address of the underlying asset.
     * @param _incentivesController Address of the incentives controller that pays the reward token.
     * @param _name Name the strategy will use.
     */
    constructor(
        address _governance,
        address _repository,
        address _silo,
        address _share,
        address _asset,
        address _incentivesController,
        string memory _name
    ) BaseHealthCheck(_asset, _name) Governance2Step(_governance) {
        repository = ISiloRepository(_repository);
        silo = ISilo(_silo);
        share = IShareToken(_share);
        incentivesController = IAaveIncentivesController(_incentivesController);

        ERC20(_asset).forceApprove(_silo, type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////
                        GOVERNANCE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setIncentivesController(address _incentivesController) external onlyGovernance {
        require(_incentivesController != address(0), "!incentivesController");
        incentivesController = IAaveIncentivesController(_incentivesController);
    }

    /*//////////////////////////////////////////////////////////////
                        MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setTradeFactory(address _tradeFactory) external onlyManagement {
        _setTradeFactory(_tradeFactory, address(asset));
    }

    function addTokens(
        address _from,
        address _to
    ) external onlyManagement {
        require(_from != address(asset), "!asset");
        _addToken(_from, _to);
    }

    /*//////////////////////////////////////////////////////////////
                NEEDED TO BE OVERRIDDEN BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Can deploy up to '_amount' of 'asset' in the yield source.
     *
     * This function is called at the end of a {deposit} or {mint}
     * call. Meaning that unless a whitelist is implemented it will
     * be entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy can attempt
     * to deposit in the yield source.
     */
    function _deployFunds(uint256 _amount) internal override {
        silo.deposit(address(asset), _amount, false);
    }

    /**
     * @dev Should attempt to free the '_amount' of 'asset'.
     *
     * NOTE: The amount of 'asset' that is already loose has already
     * been accounted for.
     *
     * This function is called during {withdraw} and {redeem} calls.
     * Meaning that unless a whitelist is implemented it will be
     * entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * Should not rely on asset.balanceOf(address(this)) calls other than
     * for diff accounting purposes.
     *
     * Any difference between `_amount` and what is actually freed will be
     * counted as a loss and passed on to the withdrawer. This means
     * care should be taken in times of illiquidity. It may be better to revert
     * if withdraws are simply illiquid so not to realize incorrect losses.
     *
     * @param _amount, The amount of 'asset' to be freed.
     */
    function _freeFunds(uint256 _amount) internal override {
        silo.accrueInterest(address(asset));
        silo.withdraw(address(asset), _amount, false);
    }

    /**
     * @dev Internal function to harvest all rewards, redeploy any idle
     * funds and return an accurate accounting of all funds currently
     * held by the Strategy.
     *
     * This should do any needed harvesting, rewards selling, accrual,
     * redepositing etc. to get the most accurate view of current assets.
     *
     * NOTE: All applicable assets including loose assets should be
     * accounted for in this function.
     *
     * Care should be taken when relying on oracles or swap values rather
     * than actual amounts as all Strategy profit/loss accounting will
     * be done based on this returned value.
     *
     * This can still be called post a shutdown, a strategist can check
     * `TokenizedStrategy.isShutdown()` to decide if funds should be
     * redeployed or simply realize any profits/losses.
     *
     * @return _totalAssets A trusted and accurate account for the total
     * amount of 'asset' the strategy currently holds including idle funds.
     */
    function _harvestAndReport()
        internal
        override
        returns (uint256 _totalAssets)
    {
        silo.accrueInterest(address(asset));

        // Only harvest and redeploy if the strategy is not shutdown.
        if (!TokenizedStrategy.isShutdown()) {
            uint256 _toDeploy = asset.balanceOf(address(this));
            if (_toDeploy > 0) {
                uint256 _availableDepositLimit = availableDepositLimit(address(0));
                if (_toDeploy <= _availableDepositLimit) {
                    _deployFunds(_toDeploy);
                } else if (_availableDepositLimit > 0) {
                    _deployFunds(_availableDepositLimit);
                }
            }
        }

        // Return full balance no matter what.
        _totalAssets = _redeemableForShares() + asset.balanceOf(address(this));
    }

    function _claimRewards() internal override {
        IAaveIncentivesController _incentivesController = incentivesController;
        if (address(_incentivesController) != address(0)) {
            address[] memory assets = new address[](1);
            assets[0] = address(share);
            _incentivesController.claimRewards(
                assets,
                type(uint256).max,
                address(this)
            );
        }
    }

    /*//////////////////////////////////////////////////////////////
                    OPTIONAL TO OVERRIDE BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Optional function for strategist to override that can
     *  be called in between reports.
     *
     * If '_tend' is used tendTrigger() will also need to be overridden.
     *
     * This call can only be called by a permissioned role so may be
     * through protected relays.
     *
     * This can be used to harvest and compound rewards, deposit idle funds,
     * perform needed position maintenance or anything else that doesn't need
     * a full report for.
     *
     *   EX: A strategy that can not deposit funds without getting
     *       sandwiched can use the tend when a certain threshold
     *       of idle to totalAssets has been reached.
     *
     * This will have no effect on PPS of the strategy till report() is called.
     *
     * @param _totalIdle The current amount of idle funds that are available to deploy.
     *
    function _tend(uint256 _totalIdle) internal override {}
    */

    /**
     * @dev Optional trigger to override if tend() will be used by the strategy.
     * This must be implemented if the strategy hopes to invoke _tend().
     *
     * @return . Should return true if tend() should be called by keeper or false if not.
     *
    function _tendTrigger() internal view override returns (bool) {}
    */

    /**
     * @notice Gets the max amount of `asset` that an address can deposit.
     * @dev Defaults to an unlimited amount for any address. But can
     * be overridden by strategists.
     *
     * This function will be called before any deposit or mints to enforce
     * any limits desired by the strategist. This can be used for either a
     * traditional deposit limit or for implementing a whitelist etc.
     *
     *   EX:
     *      if(isAllowed[_owner]) return super.availableDepositLimit(_owner);
     *
     * This does not need to take into account any conversion rates
     * from shares to assets. But should know that any non max uint256
     * amounts may be converted to shares. So it is recommended to keep
     * custom amounts low enough as not to cause overflow when multiplied
     * by `totalSupply`.
     *
     * @param . The address that is depositing into the strategy.
     * @return . The available amount the `_owner` can deposit in terms of `asset`
     *
    */
    function availableDepositLimit(
        address // _owner
    ) public view override returns (uint256) {
        if (silo.depositPossible(address(asset), address(this))) {
            ISilo.AssetStorage memory _assetState = silo.assetStorage(address(asset));

            uint256 _decimals = 10 ** ERC20(address(asset)).decimals();
            uint256 _price = repository.priceProvidersRepository().getPrice(address(asset));
            uint256 _totalDepositsValue = _price * (_assetState.totalDeposits + _assetState.collateralOnlyDeposits) / _decimals;

            uint256 _maxDepositsValue = IGuardedLaunch(address(repository)).getMaxSiloDepositsValue(address(silo), address(asset));
            if (_maxDepositsValue == type(uint256).max) return type(uint256).max;

            if (_maxDepositsValue > _totalDepositsValue) {
                uint256 _availableDepositValue = _maxDepositsValue - _totalDepositsValue;
                if (_availableDepositValue == 0) return 0;
                return (_availableDepositValue * _decimals / _price) - 1;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    /**
     * @notice Gets the max amount of `asset` that can be withdrawn.
     * @dev Defaults to an unlimited amount for any address. But can
     * be overridden by strategists.
     *
     * This function will be called before any withdraw or redeem to enforce
     * any limits desired by the strategist. This can be used for illiquid
     * or sandwichable strategies.
     *
     *   EX:
     *       return asset.balanceOf(address(this));;
     *
     * This does not need to take into account the `_owner`'s share balance
     * or conversion rates from shares to assets.
     *
     * @param . The address that is withdrawing from the strategy.
     * @return . The available amount that can be withdrawn in terms of `asset`
     *
     */
    function availableWithdrawLimit(
        address // _owner
    ) public view override returns (uint256) {
        return asset.balanceOf(address(this)) + silo.liquidity(address(asset));
    }

    /**
     * @dev Optional function for a strategist to override that will
     * allow management to manually withdraw deployed funds from the
     * yield source if a strategy is shutdown.
     *
     * This should attempt to free `_amount`, noting that `_amount` may
     * be more than is currently deployed.
     *
     * NOTE: This will not realize any profits or losses. A separate
     * {report} will be needed in order to record any profit/loss. If
     * a report may need to be called after a shutdown it is important
     * to check if the strategy is shutdown during {_harvestAndReport}
     * so that it does not simply re-deploy all funds that had been freed.
     *
     * EX:
     *   if(freeAsset > 0 && !TokenizedStrategy.isShutdown()) {
     *       depositFunds...
     *    }
     *
     * @param _amount The amount of asset to attempt to free.
     *
     */
    function _emergencyWithdraw(uint256 _amount) internal override {
        silo.accrueInterest(address(asset));
        _freeFunds(
            Math.min(
                _amount,
                _redeemableForShares()
            )
        );
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL HELPERS
    //////////////////////////////////////////////////////////////*/

    function _redeemableForShares() internal view returns (uint256) {
        return share.balanceOf(address(this)).toAmount(silo.assetStorage(address(asset)).totalDeposits, share.totalSupply());
    }
}
