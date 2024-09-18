// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";
import {IPriceProvidersRepository} from "@silo/interfaces/IPriceProvidersRepository.sol";

contract SiloArbiOracle is AggregatorV3Interface {

    uint128 public constant UNIT = 1e18;

    address public constant SILO = 0x0341C0C0ec423328621788d4854119B97f44E391;

    AggregatorV3Interface public constant wethUsdOracle = AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612);
    IPriceProvidersRepository public constant priceProvidersRepository = IPriceProvidersRepository(0x5bf4E67127263D951FC515E23B323d0e3b4485fd);

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "SILO/USD Oracle";
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
        return (0, _calcPrice(), 0, block.timestamp, 0);
    }

    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (0, _calcPrice(), 0, block.timestamp, 0);
    }

    function _calcPrice() private view returns (int256) {
        (, int256 _wethUsdPrice,,,) = wethUsdOracle.latestRoundData();
        return int256(priceProvidersRepository.getPrice(SILO)) * _wethUsdPrice / int128(UNIT);
    }
}