// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/data-structures/TVector.sol";
import "../src/allocators/AllocatorFactory.sol";

contract MemoryVectorTest is Test {
    using TVector for TVector.Vector;

    function testInitialization() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Memory, 4);
        assertEq(vector.length(), 0);
        assertEq(vector.capacity, 4);
    }

    function testPushAndGet() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Memory, 4);

        vector.push(42);
        assertEq(vector.length(), 1);
        assertEq(vector.at(0), 42);

        vector.push(43);
        assertEq(vector.length(), 2);
        assertEq(vector.at(1), 43);
    }

    function testAutoResize() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Memory, 1);

        vector.push(1);
        vector.push(2);
        vector.push(3); // This should trigger resize

        assertEq(vector.length(), 3);
        assertEq(vector.capacity, 4);
        assertEq(vector.at(0), 1);
        assertEq(vector.at(1), 2);
        assertEq(vector.at(2), 3);
    }

    function testPop() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Memory, 2);

        vector.push(42);
        vector.push(43);
        assertEq(vector.length(), 2);

        vector.pop();
        assertEq(vector.length(), 1);
        assertEq(vector.at(0), 42);
    }

    function testPopEmptyReverts() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Memory, 2);

        vm.expectRevert(TVector.TVectorEmpty.selector);
        vector.pop();
    }

    function testOutOfBoundsReverts() public {
        TVector.Vector memory vector = TVector.newVector(AllocatorFactory.AllocatorType.Memory, 2);

        vector.push(42);
        vm.expectRevert(TVector.TVectorOutOfBounds.selector);
        vector.at(1);
    }

    function testMultipleVectorsIndependent() public {
        TVector.Vector memory vector1 = TVector.newVector(AllocatorFactory.AllocatorType.Memory, 2);
        TVector.Vector memory vector2 = TVector.newVector(AllocatorFactory.AllocatorType.Memory, 2);

        vector1.push(11);
        vector2.push(21);

        assertEq(vector1.at(0), 11);
        assertEq(vector2.at(0), 21);
        assertEq(vector1.length(), 1);
        assertEq(vector2.length(), 1);
    }

    function testLargeDataSet() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Memory,
            16 // Start with reasonable size
        );

        // Add 100 sequential numbers
        for (uint256 i = 0; i < 100; i++) {
            vector.push(i);
            // Verify last inserted value
            assertEq(vector.at(i), i);
            // Verify length
            assertEq(vector.length(), i + 1);
        }

        // Verify all values are still correct
        for (uint256 i = 0; i < 100; i++) {
            assertEq(vector.at(i), i);
        }

        // Verify final capacity is sufficient (should be 128 as it doubles: 16->32->64->128)
        assertEq(vector.capacity, 128);
    }

    function testLargeValuesAndResize() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Memory,
            2 // Start small to force multiple resizes
        );

        // Add large numbers to test full uint256 range
        uint256[] memory values = new uint256[](5);
        values[0] = type(uint256).max;
        values[1] = type(uint256).max - 1;
        values[2] = type(uint256).max / 2;
        values[3] = type(uint256).max / 3;
        values[4] = type(uint256).max / 4;

        for (uint256 i = 0; i < values.length; i++) {
            vector.push(values[i]);
            assertEq(vector.at(i), values[i]);
        }

        // Verify final state
        assertEq(vector.length(), 5);
        assertEq(vector.capacity, 8); // 2->4->8
        assertEq(vector.at(0), type(uint256).max);
    }
}
