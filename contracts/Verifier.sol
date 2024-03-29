// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface DelphinusVerifier {
    /**
     * @dev snark verification stub
     */
    function verify (
        uint256[] calldata proof,
        uint256 calldata seed,
        uint256 calldata randomNumber
    ) external view;
}
