// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        uint256 answer
        );
}

contract ChainlinkPriceOracle {
    AggregatorV3Interface internal priceFeedETH;
    AggregatorV3Interface internal priceFeedBTC;
    AggregatorV3Interface internal priceFeedUSDC;
    AggregatorV3Interface internal priceFeedUSDT;
    AggregatorV3Interface internal priceFeedBUSD;
    AggregatorV3Interface internal priceFeedDAI;

    constructor() {
        // ETH / USD
        priceFeedETH = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
        priceFeedBTC = AggregatorV3Interface(
            0xA39434A63A52E749F02807ae27335515BA4b07F7
        );
        priceFeedUSDC = AggregatorV3Interface(
            0xAb5c49580294Aff77670F839ea425f5b78ab3Ae7
        );
        //JPY
        priceFeedUSDT = AggregatorV3Interface(
            0x295b398c95cEB896aFA18F25d0c6431Fd17b1431
        );
        //LINK
        priceFeedBUSD = AggregatorV3Interface(
            0xb4c4a493AB6356497713A78FFA6c60FB53517c63
        );
        priceFeedDAI = AggregatorV3Interface(
            0x0d79df66BE487753B02D015Fb622DED7f0E9798d
        );
    }

    function getLatestPrice() public view returns (uint256[6] memory) {

        (uint80 roundIDETH, uint256 priceETH)  = priceFeedETH.latestRoundData();
        (uint80 roundIDBTC, uint256 priceBTC)  = priceFeedBTC.latestRoundData();
        (uint80 roundIDUSDC, uint256 priceUSDC) = priceFeedUSDC.latestRoundData();
        (uint80 roundIDUSDT, uint256 priceUSDT) = priceFeedUSDT.latestRoundData();
        (uint80 roundIDBUSD, uint256 priceBUSD) = priceFeedBUSD.latestRoundData();
        (uint80 roundIDDAI, uint256 priceDAI) = priceFeedDAI.latestRoundData();
        uint256 [6] memory priceArray = [priceETH, priceBTC, priceUSDC, priceUSDT, priceBUSD, priceDAI];

        return priceArray;
    }

}

