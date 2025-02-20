// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../../src/data-structures/TMap.sol";
import "../../src/allocators/AllocatorFactory.sol";

contract TMapTest is Test {
    using TMap for TMap.Map;

    TMap.Map private map;

    function setUp() public {
        // Initialize with transient storage
        map = TMap.newTMap(AllocatorFactory.AllocatorType.Transient);
    }

    function testSetAndGet() public {
        bytes32 key = bytes32(uint256(1));
        uint256 value = 100;

        map.set(key, value);
        assertEq(map.get(key), value, "Value not correctly stored");
    }

    function testContains() public {
        bytes32 key = bytes32(uint256(1));

        assertFalse(map.contains(key), "Should not contain key initially");

        map.set(key, 100);
        assertTrue(map.contains(key), "Should contain key after setting");
    }

    function testRemove() public {
        bytes32 key = bytes32(uint256(1));
        uint256 value = 100;

        map.set(key, value);
        assertTrue(map.contains(key), "Should contain key");

        map.remove(key);
        assertFalse(map.contains(key), "Should not contain key after removal");
        assertEq(map.get(key), 0, "Value should be 0 after removal");
    }

    function testMultipleStorageTypes() public {
        // Test each storage type separately
        bytes32 key = bytes32(uint256(1));
        uint256 value = 100;

        // Test Memory allocator
        TMap.Map memory memoryMap = TMap.newTMap(AllocatorFactory.AllocatorType.Memory);

        // Test setting
        memoryMap.set(key, value);

        // Test getting
        uint256 retrieved = memoryMap.get(key);
        assertEq(retrieved, value, "Memory map value mismatch");

        /*
        // Test Storage allocator commented out for now
        */
    }

    function testOverwrite() public {
        bytes32 key = bytes32(uint256(1));

        map.set(key, 100);
        assertEq(map.get(key), 100, "Initial value not set");

        map.set(key, 200);
        assertEq(map.get(key), 200, "Value not overwritten");
    }

    function testMultipleKeys() public {
        bytes32[] memory keys = new bytes32[](3);
        keys[0] = bytes32(uint256(1));
        keys[1] = bytes32(uint256(2));
        keys[2] = bytes32(uint256(3));

        for (uint256 i = 0; i < keys.length; i++) {
            map.set(keys[i], i + 100);
        }

        for (uint256 i = 0; i < keys.length; i++) {
            assertEq(map.get(keys[i]), i + 100, "Incorrect value for key");
        }
    }
}
