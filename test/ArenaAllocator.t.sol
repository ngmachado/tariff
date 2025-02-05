// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/allocators/ArenaAllocator.sol";

contract ArenaAllocatorTest is Test {
    using ArenaAllocator for ArenaAllocator.Arena;

    function testInitialize() public {
        ArenaAllocator.Arena memory arena;
        bytes32 slot = keccak256("test");
        uint256 size = 100;

        arena.initialize(slot, size);

        assertEq(arena.arenaKey, slot);
        assertEq(arena.capacity, size);
        assertEq(arena.offset, 0);
    }

    function testInitializeZeroSizeFails() public {
        ArenaAllocator.Arena memory arena;
        bytes32 slot = keccak256("test");

        vm.expectRevert("ArenaAllocator: Size must be positive");
        arena.initialize(slot, 0);
    }

    function testAllocateInArena() public {
        ArenaAllocator.Arena memory arena;
        bytes32 slot = keccak256("test");
        arena.initialize(slot, 100);

        bytes32 pointer1 = arena.allocate(10);
        bytes32 pointer2 = arena.allocate(20);

        assertTrue(pointer1 != pointer2);
        assertEq(arena.offset, 30);
    }

    function testAllocateInArenaOutOfSpace() public {
        ArenaAllocator.Arena memory arena;
        bytes32 slot = keccak256("test");
        arena.initialize(slot, 10);

        arena.allocate(6);
        vm.expectRevert("ArenaAllocator: Out of space");
        arena.allocate(5);
    }

    function testStoreAndLoad() public {
        ArenaAllocator.Arena memory arena;
        bytes32 slot = keccak256("test");
        arena.initialize(slot, 100);

        bytes32 pointer = arena.allocate(1);
        uint256 value = 12345;

        ArenaAllocator.store(pointer, value);
        assertEq(ArenaAllocator.load(pointer), value);
    }

    function testFreeAndReset() public {
        ArenaAllocator.Arena memory arena;
        bytes32 slot = keccak256("test");
        arena.initialize(slot, 100);

        bytes32 pointer = arena.allocate(1);
        ArenaAllocator.store(pointer, 12345);

        ArenaAllocator.free(pointer);
        assertEq(ArenaAllocator.load(pointer), 0);

        arena.reset();
        assertEq(arena.offset, 0);
    }

    function testAllocateWithSlot() public {
        bytes32 slot = keccak256("test");
        bytes32 pointer = ArenaAllocator.allocate(slot, 10);

        uint256 value = 12345;
        ArenaAllocator.store(pointer, value);
        assertEq(ArenaAllocator.load(pointer), value);
    }

    function testAllocateAutoSlot() public {
        bytes32 pointer = ArenaAllocator.allocate(10);

        uint256 value = 12345;
        ArenaAllocator.store(pointer, value);
        assertEq(ArenaAllocator.load(pointer), value);
    }

    function testAllocateAutoSlotCollision() public view {
        bytes32 pointer1 = ArenaAllocator.allocate(10);
        bytes32 pointer2 = ArenaAllocator.allocate(10);

        // Same size should result in same pointer
        assertEq(pointer1, pointer2);
    }

    function testMultipleArenasIndependent() public {
        ArenaAllocator.Arena memory arena1;
        ArenaAllocator.Arena memory arena2;

        arena1.initialize(keccak256("arena1"), 100);
        arena2.initialize(keccak256("arena2"), 100);

        bytes32 pointer1 = arena1.allocate(10);
        bytes32 pointer2 = arena2.allocate(10);

        ArenaAllocator.store(pointer1, 111);
        ArenaAllocator.store(pointer2, 222);

        assertEq(ArenaAllocator.load(pointer1), 111);
        assertEq(ArenaAllocator.load(pointer2), 222);
    }

    function testArenaPersistenceBetweenCalls() public {
        ArenaAllocator.Arena memory arena;
        bytes32 slot = keccak256("test");
        arena.initialize(slot, 100);

        // First function call
        bytes32 pointer1 = arena.allocate(10);
        ArenaAllocator.store(pointer1, 123);
        uint256 offset1 = arena.offset;

        // Simulate another function call by creating new arena instance
        ArenaAllocator.Arena memory arena2;
        arena2.arenaKey = slot; // Same key
        arena2.capacity = 100; // Same capacity
        arena2.offset = offset1; // Restore offset

        // Second allocation should continue from previous offset
        bytes32 pointer2 = arena2.allocate(20);
        ArenaAllocator.store(pointer2, 456);

        // Values should persist
        assertEq(ArenaAllocator.load(pointer1), 123);
        assertEq(ArenaAllocator.load(pointer2), 456);
        assertEq(arena2.offset, offset1 + 20);
    }

    function testLargeDataSet() public {
        ArenaAllocator.Arena memory arena;
        bytes32 slot = keccak256("test");
        arena.initialize(slot, 128); // Start with sufficient size

        bytes32[] memory pointers = new bytes32[](100);

        // Store 100 sequential numbers
        for (uint256 i = 0; i < 100; i++) {
            pointers[i] = arena.allocate(1);
            ArenaAllocator.store(pointers[i], i);
            // Verify stored value
            assertEq(ArenaAllocator.load(pointers[i]), i);
        }

        // Verify all values are still correct
        for (uint256 i = 0; i < 100; i++) {
            assertEq(ArenaAllocator.load(pointers[i]), i);
        }

        // Verify final offset
        assertEq(arena.offset, 100);
    }
}
