// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {AprOracleBase} from "@periphery/AprOracle/AprOracleBase.sol";

import {IInterestRateModel} from "@silo/interfaces/IInterestRateModel.sol";
import {ISiloRepository} from "@silo/interfaces/ISiloRepository.sol";
import {Solvency} from "@silo/lib/Solvency.sol";

contract SiloLlamaAprOracle is AprOracleBase {

    address private immutable silo;
    address private immutable asset;

    ISiloRepository private immutable siloRepository;

    constructor(address _siloRepository, address _silo, address _asset, string memory _name) AprOracleBase(_name, msg.sender) {
        siloRepository = ISiloRepository(_siloRepository);

        silo = _silo;
        asset = _asset;
    }

    /**
     * @notice Will return the expected Apr of a strategy post a debt change.
     * @dev _delta is a signed integer so that it can also represent a debt
     * decrease.
     *
     * This should return the annual expected return at the current timestamp
     * represented as 1e18.
     *
     *      ie. 10% == 1e17
     *
     * _delta will be == 0 to get the current apr.
     *
     * This will potentially be called during non-view functions so gas
     * efficiency should be taken into account.
     *
     * @param _strategy The token to get the apr for.
     * @param _delta The difference in debt.
     * @return . The expected apr for the strategy represented as 1e18.
     */
    function aprAfterDebtChange(
        address _strategy,
        int256 _delta
    ) external view override returns (uint256) {
        // TODO -- + CRV/SILO rewards
        // uint256 rateBeforeFee = IInterestRateModel(siloRepository.getInterestRateModel(silo, asset)).getCurrentInterestRate(
        //     silo,
        //     asset, 
        //     block.timestamp
        // );
        // uint256 rateAfterFee = rateBeforeFee - (rateBeforeFee * siloRepository.protocolShareFee() / Solvency._PRECISION_DECIMALS);
        return 1e17;
    }
}
