// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/data-structures/TVector.sol";
import "../src/allocators/AllocatorFactory.sol";

contract TVectorTest is Test {
    using TVector for TVector.Vector;

    function testNewVector() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );
        assertEq(vector.length(), 0);
        assertEq(vector.capacity, 4);
    }

    function testPushAndAt() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        vector.push(1);
        vector.push(2);
        vector.push(3);

        assertEq(vector.length(), 3);
        assertEq(vector.at(0), 1);
        assertEq(vector.at(1), 2);
        assertEq(vector.at(2), 3);
    }

    function testPop() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        vector.push(1);
        vector.push(2);
        assertEq(vector.length(), 2);

        vector.pop();
        assertEq(vector.length(), 1);
        assertEq(vector.at(0), 1);
    }

    function testPopEmpty() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        vm.expectRevert(TVector.TVectorEmpty.selector);
        vector.pop();
    }

    function testAtOutOfBounds() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        vm.expectRevert(TVector.TVectorOutOfBounds.selector);
        vector.at(0);
    }

    function testAutoResize() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            2
        );

        vector.push(1);
        vector.push(2);
        // This should trigger resize
        vector.push(3);

        assertEq(vector.capacity, 4);
        assertEq(vector.length(), 3);
        assertEq(vector.at(2), 3);
    }

    function testMemoryAllocator() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Memory,
            4
        );

        vector.push(1);
        vector.push(2);
        vector.push(3);

        assertEq(vector.length(), 3);
        assertEq(vector.at(0), 1);
        assertEq(vector.at(1), 2);
        assertEq(vector.at(2), 3);
    }

    function testMemoryAllocatorResize() public {
        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Memory,
            2
        );

        vector.push(1);
        vector.push(2);
        // This should trigger resize
        vector.push(3);

        assertEq(vector.capacity, 4);
        assertEq(vector.length(), 3);
        assertEq(vector.at(2), 3);
    }

    function testInvalidCapacity() public {
        vm.expectRevert(TVector.TVectorInvalidCapacity.selector);
        TVector.newVector(AllocatorFactory.AllocatorType.Transient, 0);
    }

    function testCapacityTooLarge() public {
        vm.expectRevert(TVector.TVectorCapacityTooLarge.selector);
        TVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            type(uint256).max
        );
    }

    function testFuzzPushAndAt(uint256[] memory values) public {
        vm.assume(values.length > 0 && values.length <= 100);

        TVector.Vector memory vector = TVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        for (uint i = 0; i < values.length; i++) {
            vector.push(values[i]);
            assertEq(vector.at(i), values[i]);
        }

        assertEq(vector.length(), values.length);
    }
}
