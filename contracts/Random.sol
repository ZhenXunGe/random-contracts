// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./Verifier.sol";
import "./Callback.sol";

contract Random {
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
        require(smap[seed] == address(0), "Seed already exists");

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

        Callback(smap[seed]).handle_random(seed, randomNumber);

        // Delete seed after callback
        delete smap[seed];
    }
}