// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./CallbackIface.sol";

contract Callback is CallbackIface {
    // The Settle event helps off-chain applications understand
    // what happens within the contract.
    event Settle(uint256 seed, uint256 randomNumber);

    mapping (uint256 => uint256) public smap;

    function handle_random(uint256 seed, uint256 randomNumber) public {
        smap[seed] = randomNumber;
        emit Settle(seed, randomNumber);
    }
}