// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/allocators/HeapAllocator.sol";
import "../src/allocators/TransientAllocator.sol";

contract HeapAllocatorTest is Test {
    using HeapAllocator for HeapAllocator.Heap;

    function testInitialization() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);
        assertEq(heap.totalSize, 1024);
        assertEq(heap.freeList, 0);
    }

    function testBasicAllocation() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);

        bytes32 ptr1 = heap.allocate(64);
        bytes32 ptr2 = heap.allocate(128);

        assertTrue(uint256(ptr1) != uint256(ptr2));
        assertTrue(uint256(ptr1) > uint256(heap.basePointer));
        assertTrue(uint256(ptr2) > uint256(heap.basePointer));
    }

    function testAllocationAndFree() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);

        bytes32 ptr = heap.allocate(64);
        uint256 originalFreeList = heap.freeList;

        heap.free(ptr);
        // After freeing, the block should be available again
        assertEq(heap.freeList, originalFreeList);
    }

    function testMultipleAllocationsAndFrees() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);

        bytes32[] memory ptrs = new bytes32[](3);
        ptrs[0] = heap.allocate(64);
        ptrs[1] = heap.allocate(128);
        ptrs[2] = heap.allocate(256);

        // Free in random order to test coalescing
        heap.free(ptrs[1]);
        heap.free(ptrs[0]);
        heap.free(ptrs[2]);
    }

    function testBlockSplitting() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);

        // Allocate a small block from a large free block
        bytes32 ptr = heap.allocate(32);
        assertTrue(uint256(ptr) > uint256(heap.basePointer));

        // Should be able to allocate more from the remaining space
        bytes32 ptr2 = heap.allocate(32);
        assertTrue(uint256(ptr2) > uint256(ptr));
    }

    function testOutOfMemory() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(256);

        // Should revert when trying to allocate more than available
        vm.expectRevert(HeapAllocator.OutOfMemory.selector);
        heap.allocate(512);
    }

    function testDoubleFree() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);

        bytes32 ptr = heap.allocate(64);
        heap.free(ptr);

        vm.expectRevert("HeapAllocator: Double free");
        heap.free(ptr);
    }

    function testCoalescing() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);

        bytes32 ptr1 = heap.allocate(64);
        bytes32 ptr2 = heap.allocate(64);
        bytes32 ptr3 = heap.allocate(64);

        // Free in order that should trigger coalescing
        heap.free(ptr2); // Middle block
        heap.free(ptr1); // Should coalesce with middle
        heap.free(ptr3); // Should coalesce with the combined block

        // Should now have one large free block at the start
        assertEq(heap.freeList, 0);
    }

    function testLargeAllocation() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(2048);

        // Test allocating and using larger blocks
        for (uint256 i = 0; i < 10; i++) {
            bytes32 ptr = heap.allocate(100);
            assertTrue(uint256(ptr) > uint256(heap.basePointer));
            heap.free(ptr);
        }
    }

    function testFragmentation() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);

        bytes32[] memory ptrs = new bytes32[](5);

        // Create fragmented memory pattern
        for (uint256 i = 0; i < 5; i++) {
            ptrs[i] = heap.allocate(32);
        }

        // Free alternate blocks
        for (uint256 i = 0; i < 5; i += 2) {
            heap.free(ptrs[i]);
        }

        // Should still be able to allocate in the gaps
        bytes32 newPtr = heap.allocate(32);
        assertTrue(uint256(newPtr) > uint256(heap.basePointer));
    }

    function testLargeDataSet() public {
        HeapAllocator.Heap memory heap = HeapAllocator.initialize(16384);

        bytes32[] memory ptrs = new bytes32[](100);
        uint256[] memory values = new uint256[](100);
        bool[] memory freed = new bool[](100); // Track which pointers were freed

        // Allocate and store 100 sequential numbers
        for (uint256 i = 0; i < 100; i++) {
            ptrs[i] = heap.allocate(32);
            values[i] = i;
            TransientAllocator.store(ptrs[i], values[i]);
            console.log("Allocation %d: ptr=%x", i, uint256(ptrs[i]));
        }

        // Verify all values are stored correctly
        for (uint256 i = 0; i < 100; i++) {
            assertEq(TransientAllocator.load(ptrs[i]), values[i]);
        }

        // Free half the allocations (no duplicates)
        uint256 freedCount = 0;
        for (uint256 i = 0; i < 100 && freedCount < 50; i++) {
            uint256 index = uint256(keccak256(abi.encode(i))) % 100;
            if (!freed[index]) {
                heap.free(ptrs[index]);
                ptrs[index] = bytes32(0);
                freed[index] = true;
                freedCount++;
            }
        }

        // Allocate new values in the freed spaces
        for (uint256 i = 0; i < 25; i++) {
            bytes32 ptr = heap.allocate(32);
            TransientAllocator.store(ptr, i + 1000);
        }

        // Verify remaining original values are still correct
        for (uint256 i = 0; i < 100; i++) {
            if (!freed[i]) {
                assertEq(TransientAllocator.load(ptrs[i]), values[i]);
            }
        }
    }
}
