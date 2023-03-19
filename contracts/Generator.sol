// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Generator is ERC1155Supply, Ownable {
    uint8 public constant nftTest1=1;
    uint8 public constant nftTest2=2;
    uint8 public constant nftTest3=3;
    uint8 public constant nftTest4=4;
    uint8 public constant nftTest5=5;
    uint8 public constant nftTest6=6;
    uint8 public constant nftTest7=7;
    uint8 public constant nftTest8=8;
    uint8 public constant nftTest9=9;
    uint8 public constant nftTest10=10;
    uint8 public constant quantium=11;
    address private _contractAllowed;
    uint256 public testA;

    modifier onlyAllowed(address _address) {
        require(_address == _contractAllowed);
        _;
    }
    constructor(string memory uri_) ERC1155("https://bafybeibxsoumzovbxmkmpgoj2sccxa27eavq66q2pe2fsgkeunekk67nee.ipfs.nftstorage.link/{id}.json"){
        _mint(msg.sender, nftTest1, 1, "");
        _mint(msg.sender, nftTest2, 1, "");
        _mint(msg.sender, nftTest3, 1, "");
        _mint(msg.sender, nftTest4, 1, "");
        _mint(msg.sender, nftTest5, 1, "");
        _mint(msg.sender, nftTest6, 1, "");
        _mint(msg.sender, nftTest7, 1, "");
        _mint(msg.sender, nftTest8, 1, "");
        _mint(msg.sender, nftTest9, 1, "");
        _mint(msg.sender, nftTest10, 1, "");
        
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
                "https://bafybeibxsoumzovbxmkmpgoj2sccxa27eavq66q2pe2fsgkeunekk67nee.ipfs.nftstorage.link/",
                Strings.toString(_tokenid),".json"
            )
        );
        }
}