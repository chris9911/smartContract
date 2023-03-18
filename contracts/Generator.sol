// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Generator is ERC1155Supply, Ownable {
    uint256 public constant nftTest=1;
    uint256 public constant quantium=2;
    address private _contractAllowed;
    uint256 public testA;

    modifier onlyAllowed(address _address) {
        require(_address == _contractAllowed);
        _;
    }
    constructor(string memory uri_) ERC1155("https://bafybeighfrbbxpdtk4cnsievpjmpoqd5bklr4fjibawyaan5fljoixvwse.ipfs.nftstorage.link/{id}.json"){
        _mint(msg.sender, nftTest, 1, "");
        _mint(msg.sender, quantium, 10000, "");
        _setURI(uri_);
    }
    function getLuckyReward(address _user, uint256 _reward) external onlyAllowed(msg.sender) {
        _mint(_user, quantium, _reward, "");
    }
    function setContractAllowed(address _address) external onlyOwner{
        _contractAllowed=_address;
    }
    function uri(uint256 _tokenid) override public pure returns (string memory){
        return string(
            abi.encodePacked(
                "https://bafybeighfrbbxpdtk4cnsievpjmpoqd5bklr4fjibawyaan5fljoixvwse.ipfs.nftstorage.link/",
                Strings.toString(_tokenid),".json"
            )
        );
        }
}