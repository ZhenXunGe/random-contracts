// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./Verifier.sol";

contract Random {
    // The Settle event helps off-chain applications understand
    // what happens within the contract.
    event Settle(uint256 seed, uint256 randomNumber);

    DelphinusVerifier private verifier;
    mapping(uint256 => address) public smap;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function ensure_admin() private view {
        require(owner == msg.sender, "Authority: Require Admin");
    }

    function setVerifier(address vaddr) public {
        ensure_admin();
        verifier = DelphinusVerifier(vaddr);
    }

    // Mapping a seed to a callback contract's address and
    // generate random number with the keccak256 hash algorithm
    function create_random(uint256 seed, address callback) public returns (uint256[2] memory){
        smap[seed] = callback;

        // Calculate random number with more random values, such as msg.sender and block.timestamp
        // Return block.timestamp for testing
        return [block.timestamp, uint256(keccak256(abi.encodePacked(seed, msg.sender, block.timestamp)))];
    }

    // Verify with seed, randomNumber and proof
    // If verify succeed, run callback
    function settle_random(
        uint256 seed,
        uint256 randomNumber,
        uint256[] calldata proof
    ) public {
        require(smap[seed] != address(0), "Seed not found");

        verifier.verify(seed, randomNumber, proof);
        smap[seed].call(abi.encodeWithSignature("handle_random()"));

        // Notify off-chain applications of the settle_random
        emit Settle(seed, randomNumber);
    }
}