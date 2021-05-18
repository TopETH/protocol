// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "./strategy-staking-rewards-base-curve.sol";

import "../interfaces/curvefi.sol";

interface MisStaking {
    function notifyReward(uint256) external;
}

abstract contract StrategyMithFarmBaseCurve is StrategyStakingRewardsBaseCurve {
    // Token addresses
    address public mis = 0x024B6e7DC26F4d5579bDD936F8d7BC31f2339999;
    address public usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    // USDT/<token1> pair
    address public token1;

    // How much MIS tokens to keep?
    uint256 public keepMIS = 1200;
    uint256 public constant keepMISMax = 10000;

    // Uniswap swap paths
    address[] public mis_usdt_path;
    address[] public usdt_token1_path;

    constructor(
        address _token1,
        address _rewards,
        address _lp,
        address _strategist
    )
        public
        StrategyStakingRewardsBaseCurve(
            _rewards,
            _lp,
            _strategist
        )
    {
        token1 = _token1;

        mis_usdt_path = new address[](2);
        mis_usdt_path[0] = mis;
        mis_usdt_path[1] = usdt;
    }

    // **** State Mutations ****

    function harvest() public override onlyBenevolent {
        // Anyone can harvest it at any given time.
        // I understand the possibility of being frontrun
        // But ETH is a dark forest, and I wanna see how this plays out
        // i.e. will be be heavily frontrunned?
        //      if so, a new strategy will be deployed.

        // Collects MIS 
        require(isWhitelisted(msg.sender), "Not whitelisted");
        
        IStakingRewards(rewards).getReward();
        uint256 _mis = IERC20(mis).balanceOf(address(this));
        if (_mis > 0) {
            // 12% is streamed to staking contract
            uint256 _keepMIS = _mis.mul(keepMIS).div(keepMISMax);
            if (stakingContract != address(0)) {
                IERC20(mis).safeTransfer(
                    stakingContract,
                    _keepMIS
                );
                MisStaking(stakingContract).notifyReward(_keepMIS);
            } else {
                // If stakingContract is not set, send to treasury
                IERC20(mis).safeTransfer(
                    treasury,
                    _keepMIS
                );
            }

            _swapSushiswapWithPath(mis_usdt_path, _mis.sub(_keepMIS));
        }

        // Adds in liquidity for USDT/Token
        uint256 _usdt = IERC20(usdt).balanceOf(address(this));
        if (_usdt > 0) {
            IERC20(usdt).safeApprove(curveRouter, 0);
            IERC20(usdt).safeApprove(curveRouter, _usdt);

            uint256[4] memory curve_swap_amounts;
            curve_swap_amounts[0] = 0;
            curve_swap_amounts[1] = 0;
            curve_swap_amounts[2] = 0;
            curve_swap_amounts[3] = _usdt;
            ICurveFi_SwapY(curveRouter).add_liquidity(
                curvePool,
                curve_swap_amounts,
                0
            );

            // Donates DUST
            IERC20(usdt).safeTransfer(
                strategist,
                IERC20(usdt).balanceOf(address(this))
            );
        }

        // We want to get back MIS LP tokens
        _distributePerformanceFeesAndDeposit();
    }
}
