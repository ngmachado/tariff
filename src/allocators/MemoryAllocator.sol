// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../interfaces/IAllocator.sol";
import "forge-std/console.sol";

/**
 * @title MemoryAllocator
 * @notice Implements a flexible memory allocator using raw memory pointers.
 */
library MemoryAllocator {
    // Internal struct for array operations
    struct ArrayData {
        uint256 capacity;
        uint256 length;
    }

    /**
     * @notice Allocates memory space
     * @param slot Base slot for allocation (used for uniqueness)
     * @param size Number of slots to allocate
     */
    function allocate(
        bytes32 slot,
        uint256 size
    ) internal pure returns (bytes32 pointer) {
        require(size > 0, "MemoryAllocator: Size must be positive");
        require(size <= 0x1000, "MemoryAllocator: Size too large");
        assembly {
            // Use slot as base for pointer to ensure uniqueness
            pointer := add(mload(0x40), and(slot, 0xff))
            let newFreePtr := add(pointer, mul(size, 32))
            mstore(0x40, newFreePtr)
            mstore(pointer, 0)
        }
    }

    /**
     * @notice Store a single value
     * @param pointer The memory pointer
     * @param value The value to store
     */
    function store(bytes32 pointer, uint256 value) internal pure {
        assembly {
            mstore(pointer, value)
        }
    }

    /**
     * @notice Load a single value
     * @param pointer The memory pointer
     */
    function load(bytes32 pointer) internal pure returns (uint256 value) {
        assembly {
            value := mload(pointer)
        }
    }

    /**
     * @notice Frees memory allocation (Optional in Solidity)
     * @param pointer The memory pointer
     */
    function free(bytes32 pointer) internal pure {
        // Memory can't be freed in Solidity
    }

    // Additional array-like operations (internal use only)

    function storeAtIndex(
        bytes32 basePointer,
        uint256 index,
        uint256 value
    ) internal pure {
        console.log("storeAtIndex", value);
        assembly {
            mstore(add(basePointer, mul(index, 32)), value)
        }
    }

    function loadAtIndex(
        bytes32 basePointer,
        uint256 index
    ) internal pure returns (uint256 value) {
        assembly {
            value := mload(add(basePointer, mul(index, 32)))
        }
    }

    function initArray(bytes32 basePointer, uint256 capacity) internal pure {
        ArrayData memory data = ArrayData({capacity: capacity, length: 0});
        assembly {
            // Store array metadata before the data section
            mstore(basePointer, mload(data))
            mstore(add(basePointer, 0x20), mload(add(data, 0x20)))
        }
    }

    function getArrayLength(
        bytes32 basePointer
    ) internal pure returns (uint256) {
        uint256 length;
        assembly {
            length := mload(add(basePointer, 0x20))
        }
        return length;
    }

    function getArrayCapacity(
        bytes32 basePointer
    ) internal pure returns (uint256) {
        uint256 capacity;
        assembly {
            capacity := mload(basePointer)
        }
        return capacity;
    }
}
