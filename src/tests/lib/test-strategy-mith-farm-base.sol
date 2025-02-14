pragma solidity ^0.6.7;

import "../lib/hevm.sol";
import "../lib/user.sol";
import "../lib/test-approx.sol";
import "../lib/test-sushi-base-curve.sol";

import "../../interfaces/strategy.sol";
import "../../interfaces/uniswapv2.sol";
import "../../interfaces/curvefi.sol";

import "../../mith-jar.sol";

contract StrategyMithFarmTestBase is DSTestSushiBaseCurve {
    address want;
    address token1;

    address strategist;

    address mis = 0x024B6e7DC26F4d5579bDD936F8d7BC31f2339999;

    uint256 performanceInitiatorFee = 75;
    uint256 performanceStrategistFee = 225;
    uint256 stakingContractFee = 1200;

    MithJar mithJar;
    IStrategy strategy;

    function _getWant(uint256 usdtAmount) internal {

        _getERC20(usdt, 5000000);

        uint256 _usdt = IERC20(usdt).balanceOf(address(this));

        IERC20(usdt).safeApprove(address(curveRouter), 0);
        IERC20(usdt).safeApprove(address(curveRouter), _usdt);

        uint256[4] memory curve_swap_amounts;
        curve_swap_amounts[0] = 0;
        curve_swap_amounts[1] = 0;
        curve_swap_amounts[2] = 0;
        curve_swap_amounts[3] = _usdt;
        curveRouter.add_liquidity(
            curvePool,
            curve_swap_amounts,
            0
        );
    }

    // **** Tests ****

    function _test_withdraw_release() internal {
        _getWant(10000 * 10 ** 6); // USDT decimals is 6
        uint256 _want = IERC20(want).balanceOf(address(this));
        IERC20(want).safeApprove(address(mithJar), 0);
        IERC20(want).safeApprove(address(mithJar), _want);
        mithJar.deposit(_want);
        mithJar.earn();
        hevm.warp(block.timestamp + 1 weeks);
        strategy.harvest();

        uint256 _before = IERC20(want).balanceOf(address(this));
        mithJar.withdrawAll();
        uint256 _after = IERC20(want).balanceOf(address(this));
        assertTrue(_after > _before);

        // Check if we gained interest
        assertTrue(_after > _want);
    }

    function _test_get_earn_harvest_rewards() internal {
        _getWant(10000 * 10 ** 6); // USDT decimals is 6
        uint256 _want = IERC20(want).balanceOf(address(this));
        IERC20(want).safeApprove(address(mithJar), 0);
        IERC20(want).safeApprove(address(mithJar), _want);
        mithJar.deposit(_want);
        mithJar.earn();
        hevm.warp(block.timestamp + 1 weeks);

        // Call the harvest function
        uint256 _before = mithJar.balance();
        uint256 _strategistBefore = IERC20(want).balanceOf(strategist);
        uint256 _initiatorBefore = IERC20(want).balanceOf(strategy.initiator());

        uint256 _stakingContractBefore;
        if (strategy.stakingContract() != address(0)) {
            _stakingContractBefore = IERC20(mis).balanceOf(strategy.stakingContract());
        } else {
            _stakingContractBefore = IERC20(mis).balanceOf(strategy.treasury());
        }

        uint256 misRewards = strategy.getHarvestable();

        emit log_named_uint("    before", misRewards);
        emit log_named_uint("    before", _stakingContractBefore);

        strategy.harvest();

        uint256 _after = mithJar.balance();
        uint256 _strategistAfter = IERC20(want).balanceOf(strategist);
        uint256 _initiatorAfter = IERC20(want).balanceOf(strategy.initiator());
        
        uint256 _stakingContractAfter;
        if (strategy.stakingContract() != address(0)) {
            _stakingContractAfter = IERC20(mis).balanceOf(strategy.stakingContract());
        } else {
            _stakingContractAfter = IERC20(mis).balanceOf(strategy.treasury());
        }

        emit log_named_uint("    after", _stakingContractAfter);

        uint256 earned = _after.sub(_before).mul(1000).div(850);
        uint256 strategistRewards = earned.mul(performanceStrategistFee).div(10000); // 2.25%
        uint256 initiatorRewards = earned.mul(performanceInitiatorFee).div(10000); // 0.75%
        uint256 stakingContractRewards = misRewards.mul(stakingContractFee).div(10000); // 12%

        uint256 strategistRewardsEarned = _strategistAfter.sub(_strategistBefore);
        uint256 initiatorRewardsEarned = _initiatorAfter.sub(_initiatorBefore);
        uint256 stakingContractRewardsEarned = _stakingContractAfter.sub(_stakingContractBefore);

        // 2.25% strategist fee is given
        assertEqApprox(strategistRewards, strategistRewardsEarned);

        // 0.75% initiator fee is given
        assertEqApprox(initiatorRewards, initiatorRewardsEarned);

        // 12% goes to staking contract
        assertEqApprox(stakingContractRewards, stakingContractRewardsEarned);
    }
}
