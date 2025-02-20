// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../../src/data-structures/TBytesVector.sol";
import "../../src/allocators/AllocatorFactory.sol";
import "../helpers/VectorRevertHelper.sol";

abstract contract TBytesVectorTestSuite is Test {
    using TBytesVector for TBytesVector.Vector;

    AllocatorFactory.AllocatorType internal allocatorType;
    VectorRevertHelper internal helper;

    function setUp() public virtual {
        helper = new VectorRevertHelper();
    }

    function testBasicOperations() public virtual {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            allocatorType,
            4
        );

        bytes memory hello = hex"48656c6c6f";
        bytes memory world = hex"576f726c64";

        vector.push(hello);
        vector.push(world);

        assertEq(vector.length(), 2);
        assertEq(keccak256(vector.at(0)), keccak256(hello));
        assertEq(keccak256(vector.at(1)), keccak256(world));
    }

    function testEmptyBytes() public virtual {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            allocatorType,
            4
        );

        bytes memory emptyData = new bytes(0);
        vm.expectRevert(TBytesVector.TBytesVectorInvalidData.selector);
        helper.tryBytesPush(vector, emptyData);
    }

    function testOutOfBounds() public {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            allocatorType,
            4
        );

        vm.expectRevert(TBytesVector.TBytesVectorOutOfBounds.selector);
        helper.tryBytesAt(vector, 0);

        bytes memory testData = "Test";
        vector.push(testData);

        vm.expectRevert(TBytesVector.TBytesVectorOutOfBounds.selector);
        helper.tryBytesAt(vector, 1);
    }

    function testLargeBytes() public virtual {
        TBytesVector.Vector memory vector = TBytesVector.newVector(
            allocatorType,
            4
        );

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

    function testMultipleVectors() public virtual {
        TBytesVector.Vector memory vector1 = TBytesVector.newVector(
            allocatorType,
            4
        );
        TBytesVector.Vector memory vector2 = TBytesVector.newVector(
            allocatorType,
            4
        );

        bytes memory data1 = hex"566563746f7231";
        bytes memory data2 = hex"566563746f7232";

        vector1.push(data1);
        vector2.push(data2);

        assertEq(keccak256(vector1.at(0)), keccak256(data1));
        assertEq(keccak256(vector2.at(0)), keccak256(data2));
    }
}
