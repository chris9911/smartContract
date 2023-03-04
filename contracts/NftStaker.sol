// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Generator.sol";


contract NftStaker is Ownable {
    IERC1155 public parentNFT;
    Generator public generator;
    address payable public ownerToPay;
    uint256 public temp;
    uint256 public result;
    
    struct Stake {
        uint256 tokenId;
        uint256 amount;
        uint256 timestamp;
    }

    modifier requiresFee(uint fee) {
        if (msg.value < fee) { revert(); }
        _;
    }
    constructor() payable{
        parentNFT = IERC1155(0xd9145CCE52D386f254917e481eB44e9943F39138);
        generator = Generator(0xd9145CCE52D386f254917e481eB44e9943F39138);
        ownerToPay = payable(msg.sender);
    }


    // map staker address to stake details
    mapping(address => Stake) public stakes;

    // map staker to total staking time 
    mapping(address => uint256) public stakingTime;    


    function stake(uint256 _tokenId, uint256 _amount) public {
        stakes[msg.sender] = Stake(_tokenId, _amount, block.timestamp); 
        parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "0x00");
    } 

    function unstake() public payable {
        parentNFT.safeTransferFrom(address(this), msg.sender, stakes[msg.sender].tokenId, stakes[msg.sender].amount, "0x00");
        stakingTime[msg.sender] += (block.timestamp - stakes[msg.sender].timestamp);
        delete stakes[msg.sender];
        temp=stakingTime[msg.sender]/10;
        result=random(0,100);
        if(result<=temp){
          generator.getLuckyReward(msg.sender);
        }

    }      

     function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

   function random(uint minNumber,uint maxNumber) private view returns (uint amount) {
     amount = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number))) % (maxNumber-minNumber);
     amount = amount + minNumber;
     return amount;
     } 

         // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable requiresFee(0.001 ether) {
    }

    // Call this function along with some Ether.
    // The function will throw an error since this function is not payable.
    function notPayable() public {}

    // Function to withdraw all Ether from this contract.
    function withdraw() public {
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = ownerToPay.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint _amount) public {
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
    

}
