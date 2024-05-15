// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

interface IStakingRewards {
    function stakeFor(address recipient, uint256 amount) external;
    function withdrawFor(address recipient, uint256 amount, bool exit) external;
    function stakingToken() external view returns (address);
    function owner() external view returns (address);
    function cloneStakingPool(address _owner, address _stakingToken, address _zapContract) external returns (address newStakingPool);
}