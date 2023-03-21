// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Generator.sol";

contract NftStaker is Ownable {
    IERC1155 public parentNFT;
    Generator public generator;
    uint256 public seeMsgValue;
    uint256 public seeRandom;
    uint16 private constant _baseValue = 3000;
    bool private _isStopped = false;

    mapping(address => mapping(uint8 => Stake)) private _stakes;

    struct Stake {
        uint64 amount;
        uint256 timestamp;
    }

    modifier requiresFee(uint64 fee) {
        require(msg.value > fee, "the amount of fees payed is too low");
        _;
    }
    modifier stoppedInEmergency() {
        require(!_isStopped);
        _;
    }

    modifier onlyWhenStopped() {
        require(_isStopped);
        _;
    }

    function stopContract() public onlyOwner {
        _isStopped = true;
    }

    function resumeContract() public onlyOwner {
        _isStopped = false;
    }

    constructor() payable {
        parentNFT = IERC1155(0xe9829598C68d570512f9D0c4d1586880Da9Ce569);
        generator = Generator(0xe9829598C68d570512f9D0c4d1586880Da9Ce569);
    }

    function stakeNft(uint8 _tokenId, uint64 _amount)
        public
        stoppedInEmergency
    {
        require(
            generator.exists(_tokenId),
            "the nft you are trying to stake does not exists"
        );
        require(
            _stakes[msg.sender][_tokenId].amount == 0 && _amount == 1,
            "You can only stake one NFT at a time and cannot stake the same NFT twice."
        );
        require(
            parentNFT.balanceOf(msg.sender, _tokenId) == _amount,
            "You do not have the NFT to stake."
        );

        _stakes[msg.sender][_tokenId] = Stake(_amount, block.timestamp);

        parentNFT.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            "0x00"
        );
    }

    function stakeToken(uint8 _tokenId, uint64 _amount)
        public
        stoppedInEmergency
    {
        require(generator.exists(_tokenId), 
        "the token id is not correct"
        );
        require(
            _amount >= 0,
            "you have to insert an amount different from zero"
        );
        require(
            parentNFT.balanceOf(msg.sender, _tokenId) >= _amount,
            "You do not have enough quantum to stake."
        );
        uint64 _tempAmount = _stakes[msg.sender][_tokenId].amount + _amount;
        uint256 _tempTimestamp = _stakes[msg.sender][_tokenId].timestamp;
        _stakes[msg.sender][_tokenId] = Stake(_tempAmount, _tempTimestamp);

        parentNFT.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            "0x00"
        );
    }

    function unstakeNft(uint8 _tokenId)
        public
        payable
        requiresFee(0.002 ether)
        stoppedInEmergency
    {
        require(generator.exists(_tokenId), "the token id is not correct");
        require(_stakes[msg.sender][_tokenId].amount > 0, "No stake found");

        uint256 _stakingPeriod = block.timestamp -
            _stakes[msg.sender][_tokenId].timestamp;
        uint256 _reward = 0;
        uint256 _rewardChance = _stakingPeriod / 10;
        uint256 _randomNumber = _random(0, 100);
        if (_randomNumber <= _rewardChance) {
            _reward = _calculateValue();
        }

        parentNFT.safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId,
            _stakes[msg.sender][_tokenId].amount,
            "0x00"
        );

        delete _stakes[msg.sender][_tokenId];

        if (_reward > 0) {
            generator.getLuckyReward(msg.sender, _reward);
        }
    }

    function unstakeToken(uint8 _tokenId)
        public
        payable
        requiresFee(0.002 ether)
        stoppedInEmergency
    {
        require(generator.exists(_tokenId), "the token id is not correct");
        require(_stakes[msg.sender][_tokenId].amount > 0, "No stake found");

        uint256 _stakingPeriod = block.timestamp -
            _stakes[msg.sender][_tokenId].timestamp;
        uint256 _reward = 0;
        uint256 _rewardChance = _stakingPeriod / 10;
        uint256 _randomNumber = _random(0, 100);
        if (_randomNumber <= _rewardChance) {
            _reward = _calculateValue();

            parentNFT.safeTransferFrom(
                address(this),
                msg.sender,
                _tokenId,
                _stakes[msg.sender][_tokenId].amount,
                "0x00"
            );
        }

        delete _stakes[msg.sender][_tokenId];

        if (_reward > 0) {
            generator.getLuckyReward(msg.sender, _reward);
        }
    }

    function testRandom() public payable {
        seeRandom = _random(0, 100);
    }

    function testBlock() public payable {
        seeMsgValue = msg.value;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function _random(uint8 minNumber, uint64 maxNumber)
        private
        returns (uint256 amount)
    {
        amount =
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        block.number,
                        msg.value
                    )
                )
            ) %
            (maxNumber - minNumber);
        amount = amount + minNumber;
        return amount;
    }

    // Function to deposit Ether into this contract.
    function deposit()
        public
        payable
        requiresFee(0.001 ether)
        onlyOwner
        stoppedInEmergency
    {}

    // Function to withdraw all Ether from this contract.
    function withdraw() public onlyOwner stoppedInEmergency {
        require(address(this).balance > 0, "No balance to withdraw");
        require(msg.sender == generator.owner(), "Only owner can withdraw");

        uint256 amount = address(this).balance;
        address payable owner = payable(generator.owner());
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Withdrawal failed");
    }
    
    function balanceStakedOf(address _account, uint8 _tokenId) external view returns (uint256 value){
        return _stakes[_account][_tokenId].amount;
    }

    function _calculateValue() private view returns (uint256 value) {
        uint256 _exponent = generator.totalSupply(2) / 100000;
        //instead of writing (3/2)^exp not supported in solidity i wrote (3^exp)/(2^exp)
        uint256 _denominator = ((3)**_exponent) / ((2)**_exponent);
        //100 is the minimum value that can be earned
        return (_baseValue / _denominator) + 100;
    }
}
