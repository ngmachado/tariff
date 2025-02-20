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
        if (initialCapacity == 0) revert TBytesVectorCapacityTooLarge();
        if (initialCapacity > type(uint256).max / 32)
            revert TBytesVectorCapacityTooLarge();

        vector.allocator = allocatorType;
        vector.capacity = initialCapacity;
        vector._length = 0;

        // Allocate space for the vector data
        bytes32 slot = keccak256(
            abi.encodePacked(
                "TBytesVector",
                msg.sender,
                address(this),
                _getNextNonce()
            )
        );
        vector.basePointer = AllocatorFactory.allocate(
            allocatorType,
            slot,
            initialCapacity * 32
        );

        return vector;
    }

    /**
     * @notice Pushes bytes data to the vector
     */
    function push(Vector memory vector, bytes memory data) internal {
        if (data.length == 0) revert TBytesVectorInvalidData();

        // Resize if needed
        if (vector._length == vector.capacity) {
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
        bytes32 dataPointer = _getDataPointer(vector, index);

        // Store length
        AllocatorFactory.store(vector.allocator, dataPointer, data.length);

        // Store content
        bytes32 contentPointer = bytes32(uint256(dataPointer) + 1);
        for (uint256 i = 0; i < (data.length + 31) / 32; i++) {
            uint256 word;
            assembly {
                word := mload(add(add(data, 32), mul(i, 32)))
            }
            AllocatorFactory.store(
                vector.allocator,
                bytes32(uint256(contentPointer) + i * 32),
                word
            );
        }
    }

    function _getAt(
        Vector memory vector,
        uint256 index
    ) private view returns (bytes memory) {
        bytes32 dataPointer = _getDataPointer(vector, index);
        uint256 length = AllocatorFactory.load(vector.allocator, dataPointer);

        bytes memory result = new bytes(length);
        bytes32 contentPointer = bytes32(uint256(dataPointer) + 1);

        for (uint256 i = 0; i < (length + 31) / 32; i++) {
            uint256 word = AllocatorFactory.load(
                vector.allocator,
                bytes32(uint256(contentPointer) + i * 32)
            );
            assembly {
                mstore(add(add(result, 32), mul(i, 32)), word)
            }
        }

        return result;
    }

    function _resize(Vector memory vector, uint256 newCapacity) private {
        bytes32 slot = keccak256(
            abi.encodePacked(
                "TBytesVector_resize",
                vector.basePointer,
                _getNextNonce()
            )
        );
        bytes32 newPointer = AllocatorFactory.allocate(
            vector.allocator,
            slot,
            newCapacity * 32
        );

        // Copy existing data
        for (uint256 i = 0; i < vector._length; i++) {
            bytes memory data = _getAt(vector, i);
            _setAtPointer(vector.allocator, newPointer, i, data);
        }

        // Free old allocation if possible
        if (vector.basePointer != bytes32(0)) {
            AllocatorFactory.free(vector.allocator, vector.basePointer);
        }

        vector.basePointer = newPointer;
        vector.capacity = newCapacity;
    }

    function _setAtPointer(
        AllocatorFactory.AllocatorType allocator,
        bytes32 basePointer,
        uint256 index,
        bytes memory data
    ) private {
        bytes32 dataPointer = bytes32(
            uint256(basePointer) + index * 32 * ((data.length + 31) / 32 + 1)
        );

        // Store length
        AllocatorFactory.store(allocator, dataPointer, data.length);

        // Store content
        bytes32 contentPointer = bytes32(uint256(dataPointer) + 1);
        for (uint256 i = 0; i < (data.length + 31) / 32; i++) {
            uint256 word;
            assembly {
                word := mload(add(add(data, 32), mul(i, 32)))
            }
            AllocatorFactory.store(
                allocator,
                bytes32(uint256(contentPointer) + i * 32),
                word
            );
        }
    }

    function _getDataPointer(
        Vector memory vector,
        uint256 index
    ) private pure returns (bytes32) {
        // Calculate slots needed for each element (1 for length + 1 for data = 2 slots)
        uint256 slotsPerElement = 2;
        return
            bytes32(uint256(vector.basePointer) + index * 32 * slotsPerElement);
    }

    /**
     * @notice Reads bytes data directly from an allocator given a base pointer and index
     * @param allocatorType The storage type (Transient, Memory, Storage)
     * @param basePointer The base storage pointer of the vector
     * @param index The index to read from
     * @return The bytes data at the specified location
     */
    function readFrom(
        AllocatorFactory.AllocatorType allocatorType,
        bytes32 basePointer,
        uint256 index
    ) internal view returns (bytes memory) {
        bytes32 slot = keccak256(abi.encodePacked(basePointer, index));

        // Load length
        uint256 dataLength = allocatorType.load(slot);
        if (dataLength == 0) return "";

        // Allocate memory and load data
        bytes memory result = new bytes(dataLength);
        uint256 numSlots = (dataLength + 31) / 32;
        uint256 lastSlotBytes = dataLength % 32;

        for (uint256 i = 0; i < numSlots; i++) {
            bytes32 dataSlot = keccak256(abi.encodePacked(slot, "data", i));
            uint256 value = allocatorType.load(dataSlot);

            // For the last slot, mask out any extra bytes
            if (i == numSlots - 1 && lastSlotBytes != 0) {
                uint256 mask = (1 << (lastSlotBytes * 8)) - 1;
                value = value & mask;
            }

            assembly {
                mstore(add(add(result, 32), mul(i, 32)), value)
            }
        }

        return result;
    }
}
