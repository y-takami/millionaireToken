// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "base64-sol/base64.sol";

// soul bound token用
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";

import "./TokenBalanceCheck.sol";
import "./ChainlinkPriceOracle.sol";

contract MillionaireToken is ERC721URIStorage, Ownable, EIP712, ERC721Votes {
    using Strings for uint256;
    using Counters for Counters.Counter;
    // テスト時のみpublic変数に設定。テスト終了後はもとに戻す。
    Counters.Counter public _tokenIds;

    uint256 public MINT_PRICE = 0.01 ether; //0.01eth
    uint256 public MILLIONAIRE_VALUE = 1000000;

    mapping(address => bool) public mintedFlag;
    mapping(address => uint) public addressToId;

    event MintMillionaire(address indexed _to, uint256 _tokenId);

    address public _chainlinkPriceOracleAddress =
        0x72aDb9C024e9f0F8f48690A10A239A3A1d4c07a6;
    address public _tokenBalanceCheckAddress =
        0x2F75F18C12F5DDf19f8576808D915e8c1DbB8a0F;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) EIP712(_name, "1") {}

    modifier mintPermission(address _to) {
        // 手数料チェック
        require(msg.value == MINT_PRICE, "Fee to mint is incorrect");

        uint256 _totalValue = _checkAssetValue(_to);

        // //test assert
        // uint256 _totalValue = 1000001;

        // 一定以上のアセットを保有しているか、対象アセットはWBTC、ETH、USDT、USDC、BUSD、DAI
        require(
            _totalValue > MILLIONAIRE_VALUE,
            "Your asset is less than required"
        );
        // クレーム済みではないか
        require(mintedFlag[_to] == false, "You can only once mint NFT");
        // クレーム済みのウォレットとの取引履歴が無いか,このチェックは不要
        // require(msg.sender == msg.sender, "Your asset is less than required");
        _;
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        MINT_PRICE = _mintPrice;
    }

    function setMillionaireValue(uint256 _millionaireValue) external onlyOwner {
        MILLIONAIRE_VALUE = _millionaireValue;
    }

    function setChainlinkPriceOracleAddress(address _addr) external onlyOwner {
        _chainlinkPriceOracleAddress = _addr;
    }

    function setTokenBalanceCheckAddress(address _addr) external onlyOwner {
        _tokenBalanceCheckAddress = _addr;
    }

    function _checkPrice() private view returns (uint256[6] memory) {
        ChainlinkPriceOracle chainlinkPriceOracle = ChainlinkPriceOracle(
            _chainlinkPriceOracleAddress
        );
        uint256[6] memory priceArray;
        priceArray = chainlinkPriceOracle.getLatestPrice();
        return priceArray;
    }

    function _checkBalance(
        address _addr
    ) private view returns (uint256[6] memory) {
        TokenBalanceCheck tokenBalanceCheck = TokenBalanceCheck(
            _tokenBalanceCheckAddress
        );
        uint256[6] memory balanceArray;
        balanceArray = tokenBalanceCheck.checkAssetBalance(_addr);

        return balanceArray;
    }

    function _checkAssetValue(address _addr) private view returns (uint256) {
        uint256[6] memory priceArray = _checkPrice();
        uint256[6] memory balanceArray = _checkBalance(_addr);
        //桁数調整が必要なためdecimalsArrayを設定
        uint88[6] memory decimalsArray = [
            10 ** 8 * 10 ** 18,
            10 ** 8 * 10 ** 8,
            10 ** 8,
            10 ** 8,
            10 ** 8,
            10 ** 8
        ];

        uint256 assetValue = 0;
        for (uint i = 0; i < 6; i++) {
            assetValue =
                assetValue +
                (priceArray[i] * balanceArray[i]) /
                decimalsArray[i];
        }

        return assetValue;
    }

    function mint() public payable mintPermission(msg.sender) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI(newTokenId));

        mintedFlag[msg.sender] = true;
        addressToId[msg.sender] = newTokenId;

        emit MintMillionaire(msg.sender, newTokenId);
    }

    function generateTokenImage(
        uint256 tokenId
    ) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            name(),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "#",
            tokenId.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Millionaire Token #',
            tokenId.toString(),
            '",',
            '"description": "This is an NFT called Millionaire Token. It certificates that the owner is a millionaire. This Token has the properties of a so-called Soul Bound Token (SBT), which is tied to only one wallet and cannot be transferred to anyone.",',
            '"image": "',
            generateTokenImage(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    // SBT, Block token transfers.
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Votes) {
        super._afterTokenTransfer(from, to, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721) {
        require(from == address(0), "Err: token is SOUL BOUND");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
