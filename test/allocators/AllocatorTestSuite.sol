// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../../src/allocators/AllocatorFactory.sol";
import "../../src/allocators/ArenaAllocator.sol";
import "../../src/allocators/TransientAllocator.sol";
import "../../src/allocators/StorageAllocator.sol";
import "../../src/allocators/MemoryAllocator.sol";

abstract contract AllocatorTestSuite is Test {
    function testAllocate() public virtual;
    function testStoreAndLoad() public virtual;
    function testFree() public virtual;
    function testMultipleAllocations() public virtual;
    function testLargeValues() public virtual;
    function testBoundaries() public virtual;
}
