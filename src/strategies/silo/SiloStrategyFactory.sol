// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {ISiloRepository} from "@silo/interfaces/ISiloRepository.sol";
import {Ping} from "@silo/lib/Ping.sol";

import {IStrategyInterface} from "../../interfaces/IStrategyInterface.sol";

import {SiloStrategy, ISilo} from "./SiloStrategy.sol";

/**
 * @title SiloStrategyFactory
 * @author johnnyonline
 * @notice Factory for creating Silo strategies
 */
contract SiloStrategyFactory {
    /**
     * @notice Emitted when a new Silo strategy is deployed.
     */
    event StrategyDeployed(
        address _management,
        address strategy,
        address silo,
        address share,
        address indexed strategyAsset,
        address incentivesController,
        string name
    );

    /**
     * @dev The management address.
     */
    address public management;

    /**
     * @dev The performance fee recipient.
     */
    address public performanceFeeRecipient;

    /**
     * @dev The Silo repository contract.
     */
    ISiloRepository public immutable repository;

    /**
     * @notice Used to initialize the strategy factory on deployment.
     * @param _repository Address of the Silo repository.
     * @param _management Address of the management account.
     * @param _performanceFeeRecipient Address of the performance fee recipient.
     */
    constructor(ISiloRepository _repository, address _management, address _performanceFeeRecipient) {
        require(Ping.pong(_repository.siloRepositoryPing), "invalid silo repository");
        require(_management != address(0), "invalid management");

        repository = _repository;
        management = _management;
        performanceFeeRecipient = _performanceFeeRecipient;
    }

    modifier onlyManagement() {
        require(msg.sender == management, "!management");
        _;
    }

    /**
     * @notice Used to deploy a new Silo strategy.
     * @param _management Address of the management account.
     * @param _siloAsset Address of the Silo asset. Used to get the Silo address.
     * @param _strategyAsset Address of the underlying strategy asset.
     * @param _incentivesController Address of the incentives controller that pays the reward token.
     * @param _name Name the strategy will use.
     */
    function deploySiloStrategy(
        address _management,
        address _siloAsset,
        address _strategyAsset,
        address _incentivesController,
        string memory _name
    ) external returns (IStrategyInterface _strategy) {

        address _silo = repository.getSilo(_siloAsset);
        address _share = address(
            ISilo(_silo).assetStorage(_strategyAsset).collateralToken
        );
        require(_share != address(0), "wrong silo");

        _strategy = IStrategyInterface(address(
            new SiloStrategy(
                _silo,
                _share,
                _strategyAsset,
                _incentivesController,
                _name
            )
        ));

        _strategy.setPerformanceFeeRecipient(performanceFeeRecipient);
        _strategy.setPendingManagement(_management);

        emit StrategyDeployed(
            _management,
            address(_strategy),
            _silo,
            _share,
            _strategyAsset,
            _incentivesController,
            _name
        );
    }

    /**
     * @notice Set the management address.
     * @dev This is the address that can call the management functions.
     * @param _management The address to set as the management address.
     */
    function setManagement(address _management) external onlyManagement {
        require(_management != address(0), "ZERO_ADDRESS");
        management = _management;
    }

    /**
     * @notice Set the performance fee recipient address.
     * @dev This is the address that will receive the performance fee.
     * @param _performanceFeeRecipient The address to set as the performance fee recipient address.
     */
    function setPerformanceFeeRecipient(
        address _performanceFeeRecipient
    ) external onlyManagement {
        require(_performanceFeeRecipient != address(0), "ZERO_ADDRESS");
        performanceFeeRecipient = _performanceFeeRecipient;
    }
}
