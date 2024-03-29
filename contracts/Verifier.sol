// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface DelphinusVerifier {
    /**
     * @dev snark verification stub
     */
    function verify (
        uint256 seed,
        uint256 randomNumber,
        uint256[] calldata proof
    ) external view;
}
