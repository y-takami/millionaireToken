// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    function balanceOf(address) external view returns (uint);
}

contract TokenBalanceCheck {
    // IERC20 public uniSwap;
    IERC20 public wbtc;
    IERC20 public usdc;
    IERC20 public usdt;
    IERC20 public busd;
    IERC20 public dai;

    // IERC20[] public token;

    constructor() {
        // uniSwap = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
        wbtc = IERC20(0xC04B0d3107736C32e19F1c62b2aF67BE61d63a05); //decimals:8
        usdc = IERC20(0x2f3A40A3db8a7e3D09B0adfEfbCe4f6F81927557); //decimals:6
        usdt = IERC20(0x509Ee0d083DdF8AC028f2a56731412edD63223B9); //decimals:6
        busd = IERC20(0xb809b9B2dc5e93CB863176Ea2D565425B03c0540); //decimals:18
        dai = IERC20(0x73967c6a0904aA032C103b4104747E88c566B1A2); //decimals:18
    }

    function checkAssetBalance(
        address _addr
    ) public view returns (uint256[6] memory) {
        uint ethBalance = _addr.balance;
        // uint uniSwapBalance = uniSwap.balanceOf(_addr);
        uint wbtcBalance = wbtc.balanceOf(_addr);
        uint usdcBalance = usdc.balanceOf(_addr);
        uint usdtBalance = usdt.balanceOf(_addr);
        uint busdBalance = busd.balanceOf(_addr);
        uint daiBalance = dai.balanceOf(_addr);
        uint256[6] memory balanceArray = [
            ethBalance,
            wbtcBalance,
            usdcBalance,
            usdtBalance,
            busdBalance,
            daiBalance
        ];

        return balanceArray;
    }
}
