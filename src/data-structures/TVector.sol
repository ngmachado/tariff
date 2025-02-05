// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../allocators/AllocatorFactory.sol";
import "forge-std/console.sol";
import "../allocators/MemoryAllocator.sol";

/**
 * @title TVector
 * @notice A transient storage-based dynamic array.
 */
library TVector {
    using AllocatorFactory for AllocatorFactory.AllocatorType;

    // Counter for generating unique nonces
    uint256 private constant NONCE_SLOT =
        0x9e5c4c1c31af3f65441d4490ada3aa4d8bd45ea9f03b5d7a46de41832c457b35;

    struct Vector {
        AllocatorFactory.AllocatorType allocator; // Determines storage type
        bytes32 basePointer; // Base memory/storage pointer
        uint256 capacity; // Allocated slots
        uint256 _length; // Used slots
    }

    /**
     * @notice Gets the next nonce for unique allocation
     */
    function _getNextNonce() private returns (uint256 nonce) {
        assembly {
            nonce := add(sload(NONCE_SLOT), 1)
            sstore(NONCE_SLOT, nonce)
        }
    }

    /**
     * @notice Creates a new transient vector
     * @param allocatorType The storage type (Transient, Memory, Storage)
     * @param initialCapacity The starting capacity of the vector
     */
    function newVector(
        AllocatorFactory.AllocatorType allocatorType,
        uint256 initialCapacity
    ) internal returns (Vector memory vector) {
        vector.allocator = allocatorType;
        bytes32 slot = keccak256(
            abi.encodePacked(
                "TVector",
                msg.sender,
                address(this),
                bytes32(uint256(_getNextNonce()))
            )
        );
        console.logBytes32(slot);
        vector.basePointer = allocatorType.allocate(slot, initialCapacity); // Pass both slot and size
        vector.capacity = initialCapacity;
        vector._length = 0;
    }

    /**
     * @notice Pushes a new element into the vector
     * @param vector The vector instance
     * @param value The value to store
     */
    function push(Vector memory vector, uint256 value) internal {
        if (vector._length == vector.capacity) {
            console.log("resize");
            _resize(vector);
        }

        if (vector.allocator == AllocatorFactory.AllocatorType.Memory) {
            MemoryAllocator.storeAtIndex(
                vector.basePointer,
                vector._length,
                value
            );
        } else {
            console.log("StorageAllocator or TransientAllocator");
            bytes32 slot = keccak256(
                abi.encodePacked(vector.basePointer, vector._length)
            );
            vector.allocator.store(slot, value);
        }

        vector._length++;
        console.log("length", vector._length);
    }

    /**
     * @notice Pops the last element from the vector
     * @param vector The vector instance
     */
    function pop(Vector memory vector) internal {
        require(vector._length > 0, "TVector: Empty vector");
        vector._length--;
        bytes32 slot = keccak256(
            abi.encodePacked(vector.basePointer, vector._length)
        );
        vector.allocator.free(slot);
    }

    /**
     * @notice Reads an element from the vector
     * @param vector The vector instance
     * @param index The index of the element
     */
    function at(
        Vector memory vector,
        uint256 index
    ) internal view returns (uint256) {
        require(index < vector._length, "TVector: Index out of bounds");

        if (vector.allocator == AllocatorFactory.AllocatorType.Memory) {
            return MemoryAllocator.loadAtIndex(vector.basePointer, index);
        } else {
            bytes32 slot = keccak256(
                abi.encodePacked(vector.basePointer, index)
            );
            return vector.allocator.load(slot);
        }
    }

    /**
     * @notice Gets the length of the vector
     * @param vector The vector instance
     */
    function length(Vector memory vector) internal pure returns (uint256) {
        return vector._length;
    }

    /**
     * @notice Resizes the vector when capacity is exceeded
     * @param vector The vector instance
     */
    function _resize(Vector memory vector) private {
        require(vector.capacity > 0, "Invalid capacity");
        uint256 newCapacity = vector.capacity * 2;
        require(newCapacity > vector.capacity, "Overflow");
        require(newCapacity <= type(uint256).max / 32, "Capacity too large");

        if (vector.allocator == AllocatorFactory.AllocatorType.Memory) {
            // For memory allocator, allocate new space and copy directly
            bytes32 newPointer = MemoryAllocator.allocate(
                bytes32(uint256(vector.basePointer)),
                newCapacity
            );

            // Copy old data using memory operations
            for (uint256 i = 0; i < vector._length; i++) {
                uint256 value = MemoryAllocator.loadAtIndex(
                    vector.basePointer,
                    i
                );
                MemoryAllocator.storeAtIndex(newPointer, i, value);
            }

            vector.basePointer = newPointer;
            vector.capacity = newCapacity;
        } else {
            bytes32 slot = keccak256(
                abi.encodePacked(
                    "TVector_resize",
                    vector.basePointer,
                    newCapacity
                )
            );
            bytes32 newPointer = vector.allocator.allocate(slot, newCapacity);

            for (uint256 i = 0; i < vector._length; i++) {
                bytes32 oldSlot = keccak256(
                    abi.encodePacked(vector.basePointer, i)
                );
                bytes32 newSlot = keccak256(abi.encodePacked(newPointer, i));
                vector.allocator.store(newSlot, vector.allocator.load(oldSlot));
            }

            vector.allocator.free(vector.basePointer);
            vector.basePointer = newPointer;
            vector.capacity = newCapacity;
        }
    }
}
