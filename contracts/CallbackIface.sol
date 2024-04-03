// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface CallbackIface {
    function handle_random(uint256 seed, uint256 randomNumber) external;
}