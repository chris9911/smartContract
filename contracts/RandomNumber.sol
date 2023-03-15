// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

contract RandomnessProvider {
    /// Stores the block a request is committed to.
    mapping(bytes32 => uint256) public revealBlock;

    /// User requests randomness for a future block along with a request id.
    function commitRandomness(bytes32 _requestId, uint256 _revealBlock) external {
        require(_revealBlock > block.number, "Must commit to a future block");
        require(revealBlock[_requestId] == 0, "Request already submitted");
        revealBlock[_requestId] = _revealBlock;
    }

    /// Returns the blockhash of the block after checking that the request's target
    /// block has been reached.
    function fetchRandomness(bytes32 _requestId) public view returns (uint256) {
        bytes32 randomnessBlock = revealBlock[_requestId];
        require(block.number > randomnessBlock, "Request not ready");
        require(block.number <= randomnessBlock + 256, "Request expired");
        return blockhash(randomnessBlock);
    }
}