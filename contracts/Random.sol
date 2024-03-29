// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "Verifier.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Random {
    mapping(uint256 => function) private _smap;

    // Mapping a seed to a callback function and
    // generate random number with the keccak256 hash algorithm
    function create_random(uint256 seed, function external returns (bool) callback) public returns (uint256){
        _smap[seed] = callback;
        return uint256(keccak256(seed)));
    }

    // Verify proof
    // If verify succeed, run callback
    function settle_random(
        uint256 calldata seed,
        uint256 calldata randomNumber,
        uint256[] calldata proof
    ) public returns (bool){
        verifier.verify(proof, seed, randomNumber);
        callback = _smap[seed];
        callback();
    }
}
