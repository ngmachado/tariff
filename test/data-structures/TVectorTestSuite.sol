// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../../src/data-structures/TVector.sol";
import "../../src/allocators/AllocatorFactory.sol";
import "../helpers/VectorRevertHelper.sol";

abstract contract TVectorTestSuite is Test {
    using TVector for TVector.Vector;

    AllocatorFactory.AllocatorType internal allocatorType;
    VectorRevertHelper internal helper;

    function setUp() public virtual {
        helper = new VectorRevertHelper();
        // Child contracts must set allocatorType
    }

    function testBasicOperations() public virtual {
        TVector.Vector memory vector = TVector.newVector(allocatorType, 4);

        vector.push(1);
        vector.push(2);

        assertEq(vector.length(), 2);
        assertEq(vector.at(0), 1);
        assertEq(vector.at(1), 2);
    }

    function testResize() public virtual {
        TVector.Vector memory vector = TVector.newVector(allocatorType, 2);

        vector.push(1);
        vector.push(2);
        vector.push(3); // Should trigger resize

        assertEq(vector.capacity, 4);
        assertEq(vector.length(), 3);
        assertEq(vector.at(2), 3);
    }

    function testOutOfBoundsReverts() public virtual {
        TVector.Vector memory vector = TVector.newVector(allocatorType, 4);

        vm.expectRevert(TVector.TVectorOutOfBounds.selector);
        helper.tryAt(vector, 0);

        vector.push(42);

        vm.expectRevert(TVector.TVectorOutOfBounds.selector);
        helper.tryAt(vector, 1);
    }

    function testPopEmptyReverts() public virtual {
        TVector.Vector memory vector = TVector.newVector(allocatorType, 4);

        vm.expectRevert(TVector.TVectorEmpty.selector);
        helper.tryPop(vector);
    }

    function testFuzz(uint256[] memory values) public {
        vm.assume(values.length > 0 && values.length <= 100);

        TVector.Vector memory vector = TVector.newVector(allocatorType, 4);

        for (uint256 i = 0; i < values.length; i++) {
            vector.push(values[i]);
            assertEq(vector.at(i), values[i]);
        }
    }

    // Add more common test cases...
}
