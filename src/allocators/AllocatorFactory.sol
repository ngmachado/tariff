// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./TransientAllocator.sol";
import "./MemoryAllocator.sol";
import "./StorageAllocator.sol";

/**
 * @title AllocatorFactory
 * @notice A unified allocator system that supports dynamic storage allocation in `tstore`, `memory`, and `storage`.
 */
library AllocatorFactory {
    enum AllocatorType {
        Transient,
        Memory,
        Storage
    }

    struct Allocator {
        AllocatorType allocatorType;
        bytes32 pointer;
    }

    /**
     * @notice Allocates memory based on the selected allocator type
     * @param allocatorType The type of storage space (Transient, Memory, Storage)
     * @param slot The unique identifier for the storage space
     * @param size The required size for allocation
     */
    function allocate(AllocatorType allocatorType, bytes32 slot, uint256 size) internal pure returns (bytes32) {
        if (allocatorType == AllocatorType.Memory) {
            return MemoryAllocator.allocate(slot, size);
        } else if (allocatorType == AllocatorType.Storage) {
            return StorageAllocator.allocate(slot, size);
        } else {
            return TransientAllocator.allocate(slot, size);
        }
    }

    /**
     * @notice Stores a value in the allocated storage
     * @param allocatorType The type of storage space
     * @param pointer The allocated pointer
     * @param value The value to store
     */
    function store(AllocatorType allocatorType, bytes32 pointer, uint256 value) internal {
        if (allocatorType == AllocatorType.Transient) {
            TransientAllocator.store(pointer, value);
        } else if (allocatorType == AllocatorType.Memory) {
            MemoryAllocator.store(pointer, value);
        } else if (allocatorType == AllocatorType.Storage) {
            StorageAllocator.store(pointer, value);
        }
    }

    /**
     * @notice Loads a value from the allocated storage
     * @param allocatorType The type of storage space
     * @param pointer The allocated pointer
     */
    function load(AllocatorType allocatorType, bytes32 pointer) internal view returns (uint256) {
        if (allocatorType == AllocatorType.Transient) {
            return TransientAllocator.load(pointer);
        } else if (allocatorType == AllocatorType.Memory) {
            return MemoryAllocator.load(pointer);
        } else if (allocatorType == AllocatorType.Storage) {
            return StorageAllocator.load(pointer);
        }
        return 0;
    }

    /**
     * @notice Frees the allocated storage space
     * @param allocatorType The type of storage space
     * @param pointer The allocated pointer
     */
    function free(AllocatorType allocatorType, bytes32 pointer) internal {
        if (allocatorType == AllocatorType.Transient) {
            TransientAllocator.free(pointer);
        } else if (allocatorType == AllocatorType.Memory) {
            MemoryAllocator.free(pointer);
        } else if (allocatorType == AllocatorType.Storage) {
            StorageAllocator.free(pointer);
        }
    }
}
