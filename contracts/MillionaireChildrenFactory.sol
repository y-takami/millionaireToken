// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./MillionaireToken.sol";
import "./MillionaireChildrenToken.sol";

contract MillionaireChildrenFactory is Ownable {
    address payable[] public deployedMillionaireChildrenTokens;

    // そのアドレスで子NFTが作成されたかどうかを判断するためのマッピングを作成する
    mapping(address => bool) public createdMillionaireChildrenToken;

    // ユーザーのアドレスをキーとして、そのユーザーが作成した子NFTのコントラクトアドレスを格納するマッピングを作成する
    mapping(address => address) public addressToChildrenTokenContractAddress;

    address public parentAddress = 0x436453BcDf840Ba90145660bdD94ebcBcc8C0a20;

    // ユーザーが所有する親NFTのトークンIDを取得する関数を作成する
    function getParentTokenId() public view returns (uint256) {
        MillionaireToken millionaireToken = MillionaireToken(parentAddress);
        // msg.senderが所有する親NFTのトークンIDを返す
        return millionaireToken.addressToId(msg.sender);
    }

    // オーナーのみが親NFTコントラクトのアドレスを変更できる関数を作成する
    function setParentAddress(address _addr) public onlyOwner {
        parentAddress = _addr;
    }

    // ユーザーが子NFTを作成する関数を作成する
    function createMillionaireChildrenToken() public payable {
        // ユーザーが親NFTを所有しているかどうかを確認する
        require(getParentTokenId() != 0, "You don't have millionaire token");
        // ユーザーが既に子NFTを作成しているかどうかを確認する
        require(
            createdMillionaireChildrenToken[msg.sender] == false,
            "You can only once create NFT"
        );

        // 新しい子NFTを作成する
        MillionaireChildrenToken newMillionaireChildrenToken = new MillionaireChildrenToken(
                createChildrenTokenName(),
                createChildrenTokenSymbol(),
                getParentTokenId()
            );

        deployedMillionaireChildrenTokens.push(
            payable(address(newMillionaireChildrenToken))
        );

        createdMillionaireChildrenToken[msg.sender] = true;
        addressToChildrenTokenContractAddress[msg.sender] = address(
            newMillionaireChildrenToken
        );
        MillionaireToken millionaireToken = MillionaireToken(parentAddress);
        newMillionaireChildrenToken.transferOwnership(millionaireToken.owner());
    }

    function createChildrenTokenName() private view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "Millionaire",
                    "#",
                    Strings.toString(getParentTokenId()),
                    " Children Token"
                )
            );
    }

    function createChildrenTokenSymbol() private view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "M",
                    "#",
                    Strings.toString(getParentTokenId()),
                    "CHILD"
                )
            );
    }
}
