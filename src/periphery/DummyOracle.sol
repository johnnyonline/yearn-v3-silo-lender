// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";

contract DummyOracle is AggregatorV3Interface {

    int256 public constant PRICE = 1e8;

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "Dummy Oracle";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80) external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (0, PRICE, 0, block.timestamp, 0);
    }

    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (0, PRICE, 0, block.timestamp, 0);
    }
}