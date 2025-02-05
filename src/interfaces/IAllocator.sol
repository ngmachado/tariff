// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Allocator Interface for Storage Spaces
 */
interface IAllocator {
    function allocate(
        bytes32 slot,
        uint256 size
    ) external pure returns (bytes32);
    function allocate(uint256 size) external view returns (bytes32);
    function free(bytes32 pointer) external pure;
}
