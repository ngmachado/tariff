// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../allocators/AllocatorFactory.sol";

/**
 * @title TMap
 * @notice A transient storage-based key-value mapping.
 */
library TMap {
    using AllocatorFactory for AllocatorFactory.AllocatorType;

    struct Map {
        AllocatorFactory.AllocatorType allocator; // Determines storage type
        bytes32 basePointer; // Base address for storing key-value pairs
    }

    struct MapEntry {
        bool exists;
        uint256 value;
    }

    /**
     * @notice Creates a new transient mapping
     * @param allocatorType The storage type (Transient, Memory, Storage)
     */
    function newTMap(
        AllocatorFactory.AllocatorType allocatorType
    ) internal view returns (Map memory map) {
        map.allocator = allocatorType;
        bytes32 slot = keccak256(
            abi.encodePacked("TMap", msg.sender, address(this))
        );
        map.basePointer = allocatorType.allocate(slot, 1); // Base slot with size 1
    }

    /**
     * @notice Stores a value for a given key
     * @param map The mapping instance
     * @param key The key
     * @param value The value to store
     */
    function set(Map memory map, bytes32 key, uint256 value) internal {
        bytes32 slot = keccak256(abi.encodePacked(map.basePointer, key));
        map.allocator.store(slot, value);
    }

    /**
     * @notice Retrieves a value by key
     * @param map The mapping instance
     * @param key The key to lookup
     */
    function get(Map memory map, bytes32 key) internal view returns (uint256) {
        bytes32 slot = keccak256(abi.encodePacked(map.basePointer, key));
        return map.allocator.load(slot);
    }

    /**
     * @notice Checks if a key exists
     * @param map The mapping instance
     * @param key The key to check
     */
    function contains(
        Map memory map,
        bytes32 key
    ) internal view returns (bool) {
        bytes32 slot = keccak256(abi.encodePacked(map.basePointer, key));
        uint256 value = map.allocator.load(slot);
        return value != 0;
    }

    /**
     * @notice Deletes a key-value pair
     * @param map The mapping instance
     * @param key The key to delete
     */
    function remove(Map memory map, bytes32 key) internal {
        bytes32 slot = keccak256(abi.encodePacked(map.basePointer, key));
        map.allocator.free(slot);
    }
}
