// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./TransientAllocator.sol";
import "../interfaces/IAllocator.sol";

/**
 * @title ArenaAllocator
 * @notice Arena-based allocation strategy built on top of TransientAllocator
 */
library ArenaAllocator {
    struct Arena {
        bytes32 arenaKey; // Unique identifier for the arena
        uint256 offset; // Current allocation offset
        uint256 capacity; // Total arena capacity
    }

    /**
     * @notice Initializes a new arena
     * @param arena The Arena struct
     * @param slot Unique identifier for the arena
     * @param size Maximum capacity of the arena
     */
    function initialize(Arena memory arena, bytes32 slot, uint256 size) internal pure {
        require(size > 0, "ArenaAllocator: Size must be positive");
        arena.arenaKey = slot;
        arena.capacity = size;
        arena.offset = 0;
    }

    /**
     * @notice Allocates a block within the arena
     * @param slot Base slot for allocation
     * @param size Number of slots to allocate
     */
    function allocate(bytes32 slot, uint256 size) internal pure returns (bytes32 pointer) {
        return TransientAllocator.allocate(slot, size);
    }

    /**
     * @notice Allocates a block with auto-generated slot, multi call to this allocates will result in the same pointer aka collision
     * @param size Number of slots to allocate
     */
    function allocate(uint256 size) internal view returns (bytes32 pointer) {
        return TransientAllocator.allocate(size);
    }

    /**
     * @notice Allocates a block within a specific arena
     * @param arena The Arena struct
     * @param size Number of slots to allocate
     */
    function allocate(Arena memory arena, uint256 size) internal pure returns (bytes32 pointer) {
        require(arena.offset + size <= arena.capacity, "ArenaAllocator: Out of space");
        pointer = TransientAllocator.allocate(keccak256(abi.encode(arena.arenaKey, arena.offset)), size);
        arena.offset += size;
    }

    /**
     * @notice Stores a value at a pointer
     * @param pointer The allocated pointer
     * @param value The value to store
     */
    function store(bytes32 pointer, uint256 value) internal {
        TransientAllocator.store(pointer, value);
    }

    /**
     * @notice Reads a value from a pointer
     * @param pointer The allocated pointer
     */
    function load(bytes32 pointer) internal view returns (uint256 value) {
        return TransientAllocator.load(pointer);
    }

    /**
     * @notice Frees an allocation
     * @param pointer The pointer to free
     */
    function free(bytes32 pointer) internal {
        TransientAllocator.free(pointer);
    }

    /**
     * @notice Resets an arena, freeing all allocations
     * @param arena The Arena to reset
     */
    function reset(Arena memory arena) internal pure {
        arena.offset = 0;
    }
}
