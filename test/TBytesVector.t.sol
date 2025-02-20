// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./data-structures/TBytesVectorTestSuite.sol";

contract TBytesVectorTest is TBytesVectorTestSuite {
    using TBytesVector for TBytesVector.Vector;

    function setUp() public override {
        super.setUp();
        allocatorType = AllocatorFactory.AllocatorType.Transient;
    }

    function testBasicOperations() public override {
        TBytesVector.Vector memory vector = TBytesVector.newVector(allocatorType, 4);

        bytes memory hello = hex"48656c6c6f"; // "Hello" in hex
        bytes memory world = hex"576f726c64"; // "World" in hex

        vector.push(hello);
        vector.push(world);

        assertEq(vector.length(), 2);
        assertEq(keccak256(vector.at(0)), keccak256(hello), "Hello");
        assertEq(keccak256(vector.at(1)), keccak256(world), "World");
    }

    function testEmptyBytes() public override {
        TBytesVector.Vector memory vector = TBytesVector.newVector(allocatorType, 4);

        bytes memory emptyData = new bytes(0);
        vm.expectRevert(TBytesVector.TBytesVectorInvalidData.selector);
        helper.tryBytesPush(vector, emptyData);
    }

    function testLargeBytes() public override {
        TBytesVector.Vector memory vector = TBytesVector.newVector(allocatorType, 4);

        bytes memory largeData = new bytes(100);
        for (uint256 i = 0; i < 100; i++) {
            largeData[i] = bytes1(uint8(i % 256));
        }

        vector.push(largeData);
        bytes memory retrieved = vector.at(0);

        assertEq(retrieved.length, largeData.length);
        for (uint256 i = 0; i < largeData.length; i++) {
            assertEq(uint8(retrieved[i]), uint8(largeData[i]));
        }
    }

    function testMultipleVectors() public override {
        TBytesVector.Vector memory vector1 = TBytesVector.newVector(allocatorType, 4);
        TBytesVector.Vector memory vector2 = TBytesVector.newVector(allocatorType, 4);

        bytes memory data1 = hex"566563746f7231"; // "Vector1" in hex
        bytes memory data2 = hex"566563746f7232"; // "Vector2" in hex

        vector1.push(data1);
        vector2.push(data2);

        assertEq(keccak256(vector1.at(0)), keccak256(data1));
        assertEq(keccak256(vector2.at(0)), keccak256(data2));
    }

    function testInvalidCapacity() public {
        vm.expectRevert(TBytesVector.TBytesVectorCapacityTooLarge.selector);
        helper.tryNewBytesVector(allocatorType, 0);
    }

    function testCapacityTooLarge() public {
        vm.expectRevert(TBytesVector.TBytesVectorCapacityTooLarge.selector);
        helper.tryNewBytesVector(allocatorType, type(uint256).max);
    }
}
