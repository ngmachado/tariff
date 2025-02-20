// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./data-structures/TVectorTestSuite.sol";

contract TVectorTest is TVectorTestSuite {
    function setUp() public override {
        super.setUp();
        allocatorType = AllocatorFactory.AllocatorType.Transient;
    }

    function testInvalidCapacity() public {
        vm.expectRevert(TVector.TVectorInvalidCapacity.selector);
        helper.tryNewVector(allocatorType, 0);
    }

    function testCapacityTooLarge() public {
        vm.expectRevert(TVector.TVectorCapacityTooLarge.selector);
        helper.tryNewVector(allocatorType, type(uint256).max);
    }
}
