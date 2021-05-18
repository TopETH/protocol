pragma solidity ^0.6.7;

import "../lib/test-strategy-mith-farm-base.sol";

import "../../interfaces/strategy.sol";
import "../../interfaces/uniswapv2.sol";

import "../../mith-mis-jar.sol";
import "../../strategies/strategy-mic-usdt-lp.sol";

contract StrategyMicUsdtLpTest is StrategyMithFarmTestBase {
    function setUp() public {
        want = 0x2B26239f52420d11420bC0982571BFE091417A7d; // Sushiswap MIC-USDT
        token1 = 0xEEd0c8d2DA6d243329a6F4A8C2aC61A59ecBFa02; // MIC

        strategist = address(this);

        strategy = IStrategy(
            address(
                new StrategyMicUsdtLp(strategist)
            )
        );

        mithJar = new MithJar(strategy);

        strategy.setJar(address(mithJar));
        strategy.addToWhiteList(strategist);

        // Set time
        hevm.warp(startTime);
    }

    // **** Tests ****

    function test_mic_usdt_withdraw_release() public {
        _test_withdraw_release();
    }

    function test_mic_usdt_get_earn_harvest_rewards() public {
        _test_get_earn_harvest_rewards();
    }
}
