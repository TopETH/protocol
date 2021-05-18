// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "./strategy-mith-farm-base-curve.sol";

contract StrategyMicUsdtLp is StrategyMithFarmBaseCurve {
    // Token addresses
    address public mith_rewards = 0xe9e8f52169b7dD0Ff6Ea072168bccA42aCBc7689;
    address public uni_mic_usdt_lp = 0x2B26239f52420d11420bC0982571BFE091417A7d;
    address public mic = 0xEEd0c8d2DA6d243329a6F4A8C2aC61A59ecBFa02;

    constructor(address _strategist)
        public
        StrategyMithFarmBaseCurve(
            mic,
            mith_rewards,
            uni_mic_usdt_lp,
            _strategist
        )
    {}

    // **** Views ****

    function getName() external override pure returns (string memory) {
        return "StrategyMicUsdtLp";
    }
}
