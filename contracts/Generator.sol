// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Generator is ERC1155Supply, Ownable {
    uint256 public constant nftTest=1;
    uint256 public constant quantium=2;
    uint256 public constant baseValue = 3000;
    address private _contractAllowed;
    uint256 public testA;

    modifier onlyAllowed(address _address) {
        require(_address == _contractAllowed);
        _;
    }
    constructor(string memory uri_) ERC1155("https://bafybeigatl3xp73qctwji6ioqjdzkzzc6edr2gn5zuasr55qeffo7tvjny.ipfs.nftstorage.link/{id}.json"){
        _mint(msg.sender, nftTest, 1, "");
        _mint(msg.sender, quantium, 10000, "");
        _setURI(uri_);
    }
    function getLuckyReward(address _user) external onlyAllowed(msg.sender) {
        _mint(_user, quantium, _calculateValue(), "");
    }
    function setContractAllowed(address _address) external onlyOwner{
        _contractAllowed=_address;
    }
    function _calculateValue() private view returns (uint256 value){
        uint256 _exponent = totalSupply(2)/100000;
        //instead of writing (3/2)^exp not supported in solidity i wrote (3^exp)/(2^exp)
        uint256 _denominator = ((3)**_exponent)/((2)**_exponent);
        //100 is the minimum value that can be earned
        return (baseValue/_denominator)+100;
    }
    function uri(uint256 _tokenid) override public pure returns (string memory){
        return string(
            abi.encodePacked(
                "https://bafybeigatl3xp73qctwji6ioqjdzkzzc6edr2gn5zuasr55qeffo7tvjny.ipfs.nftstorage.link/",
                Strings.toString(_tokenid),".json"
            )
        );
        }
}