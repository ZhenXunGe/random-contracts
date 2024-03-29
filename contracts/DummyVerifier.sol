// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./Verifier.sol";
contract DummyVerifier is DelphinusVerifier {
    function verify (
        uint256 seed,
        uint256 randomNumber,
        uint256[] calldata proof
    ) public view {
    }
}
