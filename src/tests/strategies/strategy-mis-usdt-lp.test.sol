pragma solidity ^0.6.7;

import "../lib/test-strategy-mith-mis-farm-base.sol";

import "../../interfaces/strategy.sol";
import "../../interfaces/uniswapv2.sol";

import "../../mith-mis-jar.sol";
import "../../strategies/strategy-mis-usdt-lp.sol";

contract StrategyMisUsdtLpTest is StrategyMithMisFarmTestBase {
    function setUp() public {
        want = 0x097b21e4784c2B224FD8B880939f75B2E9f4dBa5; // Sushiswap MIS-USDT
        token1 = 0x024B6e7DC26F4d5579bDD936F8d7BC31f2339999; // MIS

        strategist = address(this);

        strategy = IStrategy(
            address(
                new StrategyMisUsdtLp(strategist)
            )
        );

        misJar = new MithMisJar(strategy);

        strategy.setJar(address(misJar));

        // Set time
        hevm.warp(startTime);
    }

    // **** Tests ****

    function test_mic_usdt_withdraw_release() public {
        // strategy.addToWhiteList(strategist);
        // strategy.removeFromWhiteList(strategist);
        _test_withdraw_release();
    }

    function test_mic_usdt_get_earn_harvest_rewards() public {
        _test_get_earn_harvest_rewards();
    }
}
