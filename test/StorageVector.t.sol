// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/data-structures/TVector.sol";
import "../src/allocators/AllocatorFactory.sol";

contract StorageVectorTest is Test {
    using TVector for TVector.Vector;

    function testInitialization() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 10);

        assertEq(TVector.length(vector), 0);
        assertEq(vector.capacity, 10);
    }

    function testPushAndGet() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 2);

        vector.push(42);
        vector.push(43);

        assertEq(vector.at(0), 42);
        assertEq(vector.at(1), 43);
        assertEq(TVector.length(vector), 2);
    }

    function testAutoResize() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 1);

        vector.push(1);
        vector.push(2); // Should trigger resize to capacity 2
        vector.push(3);

        assertEq(TVector.length(vector), 3);
        assertEq(vector.capacity, 4); // After resize: 1 -> 2 -> 4
        assertEq(vector.at(0), 1);
        assertEq(vector.at(1), 2);
        assertEq(vector.at(2), 3);
    }

    function testPop() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 2);

        vector.push(42);
        vector.push(43);
        assertEq(TVector.length(vector), 2);

        vector.pop();
        assertEq(TVector.length(vector), 1);
        assertEq(vector.at(0), 42);

        vector.pop();
        assertEq(TVector.length(vector), 0);
    }

    function testPopEmptyReverts() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 1);

        vm.expectRevert(TVector.TVectorEmpty.selector);
        vector.pop();
    }

    function testOutOfBoundsReverts() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 1);

        vector.push(42);

        vm.expectRevert(TVector.TVectorOutOfBounds.selector);
        vector.at(1);
    }

    function testMultipleVectorsIndependent() public {
        TVector.Vector memory vector1 = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 2);
        TVector.Vector memory vector2 = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 2);

        vector1.push(11);
        vector1.push(12);
        vector2.push(21);
        vector2.push(22);

        assertEq(vector1.at(0), 11);
        assertEq(vector1.at(1), 12);
        assertEq(vector2.at(0), 21);
        assertEq(vector2.at(1), 22);
    }

    function testVectorPersistenceBetweenCalls() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Storage, 2);

        vector.push(42);
        uint256 length = TVector.length(vector);
        bytes32 basePointer = vector.basePointer;

        // Simulate another call by creating new vector instance with same state
        TVector.Vector memory vector2;
        vector2.allocator = vector.allocator;
        vector2.basePointer = basePointer;
        vector2.capacity = vector.capacity;
        vector2._length = length;

        // Should be able to access previous data and continue operations
        assertEq(vector2.at(0), 42);
        vector2.push(43);
        assertEq(vector2.at(1), 43);
    }

    function testLargeDataSet() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Storage,
            16 // Start with reasonable size
        );

        // Add 100 sequential numbers
        for (uint256 i = 0; i < 100; i++) {
            vector.push(i);
            // Verify last inserted value
            assertEq(vector.at(i), i);
            // Verify length
            assertEq(TVector.length(vector), i + 1);
        }

        // Verify all values are still correct
        for (uint256 i = 0; i < 100; i++) {
            assertEq(vector.at(i), i);
        }

        // Verify final capacity is sufficient (should be 128 as it doubles: 16->32->64->128)
        assertEq(vector.capacity, 128);
    }
}
