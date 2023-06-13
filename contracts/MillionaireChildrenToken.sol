// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./MillionaireToken.sol";

contract MillionaireChildrenToken is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint256 public MINT_PRICE = 0.1 ether;
    uint8 public NUMBER_OF_CHILDREN = 5;

    address payable[] public deployedMillionaireTokens;
    MillionaireToken[] private _millionaireTokens;

    address public parentAddress = 0x436453BcDf840Ba90145660bdD94ebcBcc8C0a20;
    uint public parentId;

    event MintMillionaireChildren(address indexed _to, uint256 _tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        uint _parentId
    ) ERC721(_name, _symbol) {
        parentId = _parentId;
    }

    modifier millionaireTokenOwner() {
        require(
            getParentTokenId() == parentId,
            "You don't have millionaire token"
        );
        _;
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        MINT_PRICE = _mintPrice;
    }

    function setNumberOfChildren(uint8 _numberOfChildren) external onlyOwner {
        NUMBER_OF_CHILDREN = _numberOfChildren;
    }

    function setParentAddress(address _addr) external onlyOwner {
        parentAddress = _addr;
    }

    function getParentTokenId() public view returns (uint256) {
        MillionaireToken millionaireToken = MillionaireToken(parentAddress);
        return millionaireToken.addressToId(msg.sender);
    }

    function mint() public payable millionaireTokenOwner {
        require(msg.value == MINT_PRICE, "Fee to mint is incorrect");
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI(newTokenId));

        emit MintMillionaireChildren(msg.sender, newTokenId);
    }

    function repeatMint() external payable millionaireTokenOwner {
        for (uint i = 0; i < NUMBER_OF_CHILDREN; i++) {
            mint();
        }
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
            "No.",
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
    ) public view override returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Millionaire Children Token #',
            tokenId.toString(),
            '",',
            '"description": "This is an NFT called Millionaire Children Token. This token was created by Millionaire Token #',
            parentId.toString(),
            '",',
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

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
