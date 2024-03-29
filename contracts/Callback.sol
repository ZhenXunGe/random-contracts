// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./CallbackIface.sol";

// If verify in settle_random passed, run handle_random 
contract Callback is CallbackIface {
    function handle_random() public {
    }
}