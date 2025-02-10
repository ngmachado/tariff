// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/data-structures/TBytesVector.sol";
import "../src/allocators/AllocatorFactory.sol";

contract TBytesVectorTest is Test {
    using TBytesVector for TBytesVector.Vector;

    function testNewVector() public {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );
        assertEq(vector.length(), 0);
        assertEq(vector.capacity, 4);
    }

    function testPushAndAt() public {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        bytes memory data1 = "Hello";
        bytes memory data2 = "World";

        vector.push(data1);
        vector.push(data2);

        assertEq(vector.length(), 2);
        assertEq(string(vector.at(0)), string(data1));
        assertEq(string(vector.at(1)), string(data2));
    }

    function testSetAndAt() public {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        bytes memory data1 = "Hello";
        vector.push(data1);

        bytes memory data2 = "Updated";
        vector.set(0, data2);

        assertEq(string(vector.at(0)), string(data2));
    }

    function testAutoResize() public {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            2
        );

        bytes memory data1 = "One";
        bytes memory data2 = "Two";
        bytes memory data3 = "Three";

        vector.push(data1);
        vector.push(data2);
        // This should trigger resize
        vector.push(data3);

        assertEq(vector.capacity, 4);
        assertEq(vector.length(), 3);
        assertEq(string(vector.at(2)), string(data3));
        // Verify previous data is intact
        assertEq(string(vector.at(0)), string(data1));
        assertEq(string(vector.at(1)), string(data2));
    }

    function testEmptyBytes() public {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        bytes memory emptyData = "";
        vector.push(emptyData);

        assertEq(vector.length(), 1);
        assertEq(vector.at(0).length, 0);
        assertEq(string(vector.at(0)), string(emptyData));
    }

    function testLargeBytes() public {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        // Create large bytes data (>32 bytes)
        bytes memory largeData = new bytes(100);
        for (uint i = 0; i < 100; i++) {
            largeData[i] = bytes1(uint8(i % 256));
        }

        vector.push(largeData);
        bytes memory retrieved = vector.at(0);

        assertEq(retrieved.length, largeData.length);
        assertEq(keccak256(retrieved), keccak256(largeData));
    }

    function testOutOfBounds() public {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        vm.expectRevert(TBytesVector.TBytesVectorOutOfBounds.selector);
        vector.at(0);

        vector.push("Test");

        vm.expectRevert(TBytesVector.TBytesVectorOutOfBounds.selector);
        vector.at(1);

        vm.expectRevert(TBytesVector.TBytesVectorOutOfBounds.selector);
        vector.set(1, "Test");
    }

    function testInvalidCapacity() public {
        vm.expectRevert(TBytesVector.TBytesVectorCapacityTooLarge.selector);
        TBytesVector.newVector(AllocatorFactory.AllocatorType.Transient, 0);

        vm.expectRevert(TBytesVector.TBytesVectorCapacityTooLarge.selector);
        TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            type(uint256).max
        );
    }

    function testFuzzPushAndAt(bytes[] memory values) public {
        vm.assume(values.length > 0 && values.length <= 100);
        for (uint i = 0; i < values.length; i++) {
            vm.assume(values[i].length <= 1000); // Reasonable size limit
        }

        TBytesVector.Vector memory vector = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        for (uint i = 0; i < values.length; i++) {
            vector.push(values[i]);
            assertEq(
                keccak256(vector.at(i)),
                keccak256(values[i]),
                "Data mismatch at index"
            );
        }

        assertEq(vector.length(), values.length);
    }

    function testMultipleVectors() public {
        TBytesVector.Vector memory vector1 = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );
        TBytesVector.Vector memory vector2 = TBytesVector.newVector(
            AllocatorFactory.AllocatorType.Transient,
            4
        );

        vector1.push("Vector1");
        vector2.push("Vector2");

        assertEq(string(vector1.at(0)), "Vector1");
        assertEq(string(vector2.at(0)), "Vector2");
    }
}
