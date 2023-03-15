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
    uint256 public seeMsgValue;
    uint256 public seeRandom;

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public stakingTime;    
    mapping(address => uint256[]) private _values;  


    
    struct Stake {
        uint256 tokenId;
        uint256 amount;
        uint256 timestamp;
    }

    modifier requiresFee(uint fee) {
        if (msg.value < fee) { revert(); }
        _;
    }
    modifier notPresentFee(){
       for(uint i=0;i<_values[msg.sender].length;i++){
        if(_values[msg.sender][i]==msg.value){
            revert();
            }
        }
        _values[msg.sender].push(msg.value);
        if(_values[msg.sender].length==100){
            delete _values[msg.sender];
        }
        _;
    }    

    constructor() payable{
        parentNFT = IERC1155(0xd9145CCE52D386f254917e481eB44e9943F39138);
        generator = Generator(0xd9145CCE52D386f254917e481eB44e9943F39138);
        ownerToPay = payable(msg.sender);
    }


    function stake(uint256 _tokenId, uint256 _amount) public {
        stakes[msg.sender] = Stake(_tokenId, _amount, block.timestamp); 
        parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "0x00");
    } 

    function unstake() public payable requiresFee(0.001 ether){
        parentNFT.safeTransferFrom(address(this), msg.sender, stakes[msg.sender].tokenId, stakes[msg.sender].amount, "0x00");
        stakingTime[msg.sender] += (block.timestamp - stakes[msg.sender].timestamp);
        delete stakes[msg.sender];
        uint256 _temp=stakingTime[msg.sender]/10;
        uint256 _result=random(0,100);
        if(_result<=_temp){
          generator.getLuckyReward(msg.sender);
        }

    }  
    function testRandom()public payable{
        seeRandom=random(0,100);
    }    
    function testBlock()public payable notPresentFee{
        seeMsgValue=msg.value;
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

   function random(uint minNumber,uint maxNumber) private notPresentFee returns (uint amount) {
     amount = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number, msg.value))) % (maxNumber-minNumber);
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
