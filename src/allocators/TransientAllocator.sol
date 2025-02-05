// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../interfaces/IAllocator.sol";

/**
 * @title TransientAllocator
 * @notice Implements allocation in transient storage using tstore/tload
 */
library TransientAllocator {
    /**
     * @notice Allocates transient storage space
     * @param slot Base slot for allocation, should be unique per allocation
     * @param size Size of the allocation
     */
    function allocate(
        bytes32 slot,
        uint256 size
    ) internal pure returns (bytes32 pointer) {
        require(slot != bytes32(0), "TransientAllocator: Invalid slot");
        require(size > 0, "TransientAllocator: Size must be positive");
        pointer = keccak256(abi.encode(slot, size));
    }

    function allocate(uint256 size) internal view returns (bytes32 pointer) {
        pointer = keccak256(abi.encodePacked("TransientAllocator", size));
        assembly {
            if iszero(iszero(tload(pointer))) {
                revert(0, 0)
            }
        }
    }

    /**
     * @notice Stores a value in transient storage
     * @param pointer The storage pointer
     * @param value The value to store
     */
    function store(bytes32 pointer, uint256 value) internal {
        assembly {
            tstore(pointer, value)
        }
    }

    /**
     * @notice Loads a value from transient storage
     * @param pointer The storage pointer
     */
    function load(bytes32 pointer) internal view returns (uint256 value) {
        assembly {
            value := tload(pointer)
        }
    }

    /**
     * @notice Frees transient storage
     * @param pointer The storage pointer
     */
    function free(bytes32 pointer) internal {
        assembly {
            tstore(pointer, 0)
        }
    }
}
