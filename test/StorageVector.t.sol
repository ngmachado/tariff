// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./data-structures/TVectorTestSuite.sol";

contract StorageVectorTest is TVectorTestSuite {
    using TVector for TVector.Vector;

    function setUp() public override {
        super.setUp();
        allocatorType = AllocatorFactory.AllocatorType.Storage;
    }

    function testOutOfBoundsReverts() public override {
        TVector.Vector memory vector = TVector.newVector(allocatorType, 4);

        vm.expectRevert(TVector.TVectorOutOfBounds.selector);
        helper.tryAt(vector, 0);

        vector.push(42);

        vm.expectRevert(TVector.TVectorOutOfBounds.selector);
        helper.tryAt(vector, 1);
    }

    function testPopEmptyReverts() public override {
        TVector.Vector memory vector = TVector.newVector(allocatorType, 4);

        vm.expectRevert(TVector.TVectorEmpty.selector);
        helper.tryPop(vector);
    }

    // Storage-specific test
    function testVectorPersistenceBetweenCalls() public {
        TVector.Vector memory vector = TVector.newVector(allocatorType, 2);

        vector.push(42);
        uint256 len = vector.length();
        bytes32 basePointer = vector.basePointer;

        // Simulate another call by creating new vector instance with same state
        TVector.Vector memory vector2;
        vector2.allocator = vector.allocator;
        vector2.basePointer = basePointer;
        vector2.capacity = vector.capacity;
        vector2._length = len;

        assertEq(vector2.at(0), 42);
        vector2.push(43);
        assertEq(vector2.at(1), 43);
    }
}
