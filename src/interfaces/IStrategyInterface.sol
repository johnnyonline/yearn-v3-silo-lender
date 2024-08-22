// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {IStrategy} from "@tokenized-strategy/interfaces/IStrategy.sol";

interface IStrategyInterface is IStrategy {
    function incentivesController() external view returns (address);
    function repository() external view returns (address);
    function share() external view returns (address);
    function silo() external view returns (address);
    function claimRewards() external;
}
