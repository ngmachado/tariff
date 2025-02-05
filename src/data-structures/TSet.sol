// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../allocators/AllocatorFactory.sol";

/**
 * @title TSet
 * @notice A transient storage-based unique value set.
 */
library TSet {
    using AllocatorFactory for AllocatorFactory.AllocatorType;

    struct Set {
        AllocatorFactory.AllocatorType allocator; // Determines storage type
        bytes32 basePointer; // Base address for storing elements
    }

    /**
     * @notice Creates a new transient set
     * @param allocatorType The storage type (Transient, Memory, Storage)
     */
    function newTSet(
        AllocatorFactory.AllocatorType allocatorType
    ) internal view returns (Set memory set) {
        set.allocator = allocatorType;
        bytes32 slot = keccak256(
            abi.encodePacked("TSet", msg.sender, address(this))
        );
        set.basePointer = allocatorType.allocate(slot, 1); // Base slot with size 1
    }

    /**
     * @notice Adds a value to the set
     * @param set The set instance
     * @param value The value to add
     */
    function add(Set memory set, bytes32 value) internal {
        bytes32 slot = keccak256(abi.encodePacked(set.basePointer, value));
        set.allocator.store(slot, 1); // 1 = exists
    }

    /**
     * @notice Checks if a value exists in the set
     * @param set The set instance
     * @param value The value to check
     */
    function contains(
        Set memory set,
        bytes32 value
    ) internal view returns (bool) {
        bytes32 slot = keccak256(abi.encodePacked(set.basePointer, value));
        return set.allocator.load(slot) != 0;
    }

    /**
     * @notice Removes a value from the set
     * @param set The set instance
     * @param value The value to remove
     */
    function remove(Set memory set, bytes32 value) internal {
        bytes32 slot = keccak256(abi.encodePacked(set.basePointer, value));
        set.allocator.free(slot);
    }
}
