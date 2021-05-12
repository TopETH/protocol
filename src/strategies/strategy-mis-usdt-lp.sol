// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "./strategy-mith-farm-base.sol";

contract StrategyMisUsdtLp is StrategyMithFarmBase {
    // Token addresses
    address public mith_rewards = 0x717d21829188d3b1B16c428641691b5ecA1AEC15;
    address public uni_mis_usdt_lp = 0x097b21e4784c2B224FD8B880939f75B2E9f4dBa5;
    address public token_mis = 0x024B6e7DC26F4d5579bDD936F8d7BC31f2339999;

    constructor(address _strategist)
        public
        StrategyMithFarmBase(
            token_mis,
            mith_rewards,
            uni_mis_usdt_lp,
            _strategist
        )
    {
        // Redefined the performances fees - 1% goes to the initiator
        performanceInitiatorFee = 100;
        performanceStrategistFee = 200;
    }

    // **** Views ****

    function getName() external override pure returns (string memory) {
        return "StrategyMisUsdtLp";
    }
}
