// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Verifier.sol";
contract DummyVerifier is DelphinusVerifier {
    function verify (
        uint256[] calldata proof,
        uint256 calldata seed,
        uint256 calldata randomNumber
    ) public view {
    }
}
