// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./Verifier.sol";
import "./Callback.sol";

contract Random {
    mapping(uint256 => address[2]) public smap;

    // Mapping a seed to a callback contract's address and
    // generate random number with the keccak256 hash algorithm
    // mapping seed to verify contract's address
    function create_random(uint256 seed, address callback, address verify) public returns (uint256[2] memory){
        require(smap[seed][0] == address(0) && smap[seed][1] == address(0), "Seed already exists");

        smap[seed] = [callback, verify];

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
        require(smap[seed][0] != address(0) && smap[seed][1] != address(0), "Seed not found");

        DelphinusVerifier(smap[seed][1]).verify(seed, randomNumber, proof);

        Callback(smap[seed][0]).handle_random(seed, randomNumber);

        // Delete seed after callback
        delete smap[seed];
    }
}