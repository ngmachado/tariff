// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../allocators/AllocatorFactory.sol";

/**
 * @title TBytesVector
 * @notice A transient storage-based dynamic array optimized for bytes data.
 */
library TBytesVector {
    using AllocatorFactory for AllocatorFactory.AllocatorType;

    error TBytesVectorOutOfBounds();
    error TBytesVectorOverflow();
    error TBytesVectorCapacityTooLarge();
    error TBytesVectorInvalidData();

    // Counter for generating unique nonces
    uint256 private constant NONCE_SLOT =
        0xaa8959192d6857c6a3c773dc74cdc9dac58b573011494b8f3fc2917c93f61b8e;

    struct Vector {
        AllocatorFactory.AllocatorType allocator;
        bytes32 basePointer;
        uint256 capacity;
        uint256 _length;
    }

    struct BytesData {
        uint256 length;
        bytes data;
    }

    function _getNextNonce() private returns (uint256 nonce) {
        assembly {
            nonce := add(sload(NONCE_SLOT), 1)
            sstore(NONCE_SLOT, nonce)
        }
    }

    /**
     * @notice Creates a new bytes vector
     * @param allocatorType The storage type (Transient, Memory, Storage)
     * @param initialCapacity The starting capacity
     */
    function newVector(
        AllocatorFactory.AllocatorType allocatorType,
        uint256 initialCapacity
    ) internal returns (Vector memory vector) {
        if (initialCapacity == 0 || initialCapacity > type(uint256).max / 2)
            revert TBytesVectorCapacityTooLarge();

        vector.allocator = allocatorType;
        bytes32 slot = keccak256(
            abi.encodePacked(
                "TBytesVector",
                msg.sender,
                address(this),
                _getNextNonce()
            )
        );
        vector.basePointer = allocatorType.allocate(slot, initialCapacity);
        vector.capacity = initialCapacity;
        vector._length = 0;
        return vector;
    }

    /**
     * @notice Pushes bytes data to the vector
     */
    function push(Vector memory vector, bytes memory data) internal {
        if (vector._length >= vector.capacity) {
            _resize(vector, vector.capacity * 2);
        }
        _setAt(vector, vector._length, data);
        vector._length++;
    }

    /**
     * @notice Gets bytes data at an index
     */
    function at(
        Vector memory vector,
        uint256 index
    ) internal view returns (bytes memory) {
        if (index >= vector._length) revert TBytesVectorOutOfBounds();
        return _getAt(vector, index);
    }

    /**
     * @notice Sets bytes data at an index
     */
    function set(
        Vector memory vector,
        uint256 index,
        bytes memory data
    ) internal {
        if (index >= vector._length) revert TBytesVectorOutOfBounds();
        _setAt(vector, index, data);
    }

    /**
     * @notice Gets the current length of the vector
     */
    function length(Vector memory vector) internal pure returns (uint256) {
        return vector._length;
    }

    // Internal helpers
    function _setAt(
        Vector memory vector,
        uint256 index,
        bytes memory data
    ) private {
        bytes32 slot = keccak256(abi.encodePacked(vector.basePointer, index));

        // Store length and data separately
        vector.allocator.store(slot, data.length);

        uint256 numSlots = (data.length + 31) / 32;
        for (uint256 i = 0; i < numSlots; i++) {
            bytes32 dataSlot = keccak256(abi.encodePacked(slot, "data", i));
            bytes32 value;
            assembly {
                value := mload(add(add(data, 32), mul(i, 32)))
            }
            vector.allocator.store(dataSlot, uint256(value));
        }
    }

    function _getAt(
        Vector memory vector,
        uint256 index
    ) private view returns (bytes memory) {
        bytes32 slot = keccak256(abi.encodePacked(vector.basePointer, index));

        // Load length
        uint256 length = vector.allocator.load(slot);
        if (length == 0) return "";

        // Allocate memory and load data
        bytes memory result = new bytes(length);
        uint256 numSlots = (length + 31) / 32;

        for (uint256 i = 0; i < numSlots; i++) {
            bytes32 dataSlot = keccak256(abi.encodePacked(slot, "data", i));
            uint256 value = vector.allocator.load(dataSlot);
            assembly {
                mstore(add(add(result, 32), mul(i, 32)), value)
            }
        }

        return result;
    }

    function _resize(Vector memory vector, uint256 newCapacity) private {
        if (newCapacity <= vector.capacity) revert TBytesVectorOverflow();
        if (newCapacity > type(uint256).max / 2)
            revert TBytesVectorCapacityTooLarge();

        bytes32 newPointer = vector.allocator.allocate(
            keccak256(
                abi.encodePacked(vector.basePointer, "resize", _getNextNonce())
            ),
            newCapacity
        );

        Vector memory newVector = Vector({
            allocator: vector.allocator,
            basePointer: newPointer,
            capacity: newCapacity,
            _length: vector._length
        });

        // Copy existing data to new location
        for (uint256 i = 0; i < vector._length; i++) {
            bytes memory data = _getAt(vector, i);
            _setAt(newVector, i, data);
        }

        vector.allocator.free(vector.basePointer);
        vector.basePointer = newPointer;
        vector.capacity = newCapacity;
    }
}
