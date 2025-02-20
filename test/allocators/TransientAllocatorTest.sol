// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./AllocatorTestSuite.sol";
import "../helpers/VectorRevertHelper.sol";

contract TransientAllocatorTest is AllocatorTestSuite {
    using TransientAllocator for bytes32;

    VectorRevertHelper internal helper;

    function setUp() public {
        helper = new VectorRevertHelper();
    }

    function testAllocate() public override {
        bytes32 pointer = TransientAllocator.allocate(10);
        assertTrue(pointer != bytes32(0));
    }

    function testStoreAndLoad() public override {
        bytes32 pointer = TransientAllocator.allocate(1);
        uint256 value = 12345;

        TransientAllocator.store(pointer, value);
        assertEq(TransientAllocator.load(pointer), value);
    }

    function testFree() public override {
        bytes32 pointer = TransientAllocator.allocate(1);
        TransientAllocator.store(pointer, 12345);

        TransientAllocator.free(pointer);
        assertEq(TransientAllocator.load(pointer), 0);
    }

    function testMultipleAllocations() public override {
        // Use a unique slot for each allocation to avoid collisions
        bytes32[] memory pointers = new bytes32[](5);

        for (uint256 i = 0; i < pointers.length; i++) {
            bytes32 slot = keccak256(abi.encodePacked("test", i));
            pointers[i] = TransientAllocator.allocate(slot, 1);
            TransientAllocator.store(pointers[i], i);
        }

        for (uint256 i = 0; i < pointers.length; i++) {
            assertEq(TransientAllocator.load(pointers[i]), i);
        }
    }

    function testLargeValues() public override {
        bytes32 pointer = TransientAllocator.allocate(1);
        uint256 value = type(uint256).max;

        TransientAllocator.store(pointer, value);
        assertEq(TransientAllocator.load(pointer), value);
    }

    function testBoundaries() public override {
        // Test zero size allocation
        vm.expectRevert("TransientAllocator: Size must be positive");
        helper.tryTransientAllocate(0);

        // Test valid allocation
        bytes32 pointer = TransientAllocator.allocate(1);
        assertTrue(pointer != bytes32(0));

        // Test max value storage
        TransientAllocator.store(pointer, type(uint256).max);
        assertEq(TransientAllocator.load(pointer), type(uint256).max);
    }
}
