// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../../src/data-structures/TSet.sol";
import "../../src/allocators/AllocatorFactory.sol";

contract TSetTest is Test {
    using TSet for TSet.Set;

    TSet.Set private set;

    function setUp() public {
        // Initialize with transient storage
        set = TSet.newTSet(AllocatorFactory.AllocatorType.Transient);
    }

    function testAddAndContains() public {
        bytes32 value = bytes32(uint256(1));

        assertFalse(set.contains(value), "Should not contain value initially");

        set.add(value);
        assertTrue(set.contains(value), "Should contain value after adding");
    }

    function testRemove() public {
        bytes32 value = bytes32(uint256(1));

        set.add(value);
        assertTrue(set.contains(value), "Should contain value");

        set.remove(value);
        assertFalse(set.contains(value), "Should not contain value after removal");
    }

    function ftestMultipleStorageTypes() public {
        bytes32 value = bytes32(uint256(1));

        // Test Memory allocator
        TSet.Set memory memorySet = TSet.newTSet(AllocatorFactory.AllocatorType.Memory);
        memorySet.add(value);
        assertTrue(memorySet.contains(value), "Memory set should contain value");

        // Test Storage allocator
        TSet.Set memory storageSet = TSet.newTSet(AllocatorFactory.AllocatorType.Storage);
        storageSet.add(value);
        assertTrue(storageSet.contains(value), "Storage set should contain value");
    }

    function testMultipleValues() public {
        bytes32[] memory values = new bytes32[](3);
        values[0] = bytes32(uint256(1));
        values[1] = bytes32(uint256(2));
        values[2] = bytes32(uint256(3));

        for (uint256 i = 0; i < values.length; i++) {
            set.add(values[i]);
        }

        for (uint256 i = 0; i < values.length; i++) {
            assertTrue(set.contains(values[i]), "Set should contain value");
        }
    }

    function testAddDuplicate() public {
        bytes32 value = bytes32(uint256(1));

        set.add(value);
        set.add(value); // Adding same value again

        assertTrue(set.contains(value), "Should still contain value");

        set.remove(value);
        assertFalse(set.contains(value), "Should not contain value after removal");
    }

    function testRemoveNonexistent() public {
        bytes32 value = bytes32(uint256(1));

        set.remove(value); // Should not revert
        assertFalse(set.contains(value), "Should not contain value");
    }
}
