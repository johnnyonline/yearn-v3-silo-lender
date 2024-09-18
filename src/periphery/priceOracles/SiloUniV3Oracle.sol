// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/shared/interfaces/AggregatorV3Interface.sol";

import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {OracleLibrary} from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract SiloUniV3Oracle is AggregatorV3Interface {

    address public immutable token0;
    address public immutable token1;
    address public immutable pool;

    AggregatorV3Interface public wethUsdOracle;

    uint128 public constant UNIT = 1e8;

    constructor(address _wethUsdOracle, address _factory, address _token0, address _token1, uint24 _fee) {
        wethUsdOracle = AggregatorV3Interface(_wethUsdOracle);
        if (wethUsdOracle.decimals() != 8) revert ("!ORACLE");

        token0 = _token0;
        token1 = _token1;

        address _pool = IUniswapV3Factory(_factory).getPool(_token0, _token1, _fee);
        if (_pool == address(0)) revert ("!POOL");
        pool = _pool;
    }

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "SILO/USD Uniswap V3 Oracle";
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
        (int24 _tick, ) = OracleLibrary.consult(
            pool,
            300 // secondsAgo
        );
        (, int256 _wethUsdPrice,,,) = wethUsdOracle.latestRoundData();
        return int256(OracleLibrary.getQuoteAtTick(_tick, UNIT, token0, token1)) * _wethUsdPrice / int128(UNIT);
    }
}