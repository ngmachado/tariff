// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./TransientAllocator.sol";

/**
 * @title HeapAllocator
 * @notice Implements a heap-based memory allocator using transient storage
 */
library HeapAllocator {
    struct BlockHeader {
        uint256 size; // Size of the block (including header)
        bool used; // Whether block is allocated
        uint256 prevOffset; // Offset to previous block
        uint256 nextOffset; // Offset to next block
    }

    struct Heap {
        bytes32 basePointer; // Start of heap memory
        uint256 totalSize; // Total heap size
        uint256 freeList; // Offset to first free block
    }

    error OutOfMemory();
    error InvalidPointer();
    error InvalidSize();

    function initialize(uint256 size) internal returns (Heap memory heap) {
        require(size > 64, "HeapAllocator: Size too small");

        heap.totalSize = size;
        heap.freeList = 0;

        // Allocate base memory in transient storage
        bytes32 slot = keccak256(abi.encodePacked("HeapAllocator", size));
        heap.basePointer = TransientAllocator.allocate(slot, size);

        // Initialize first block header
        BlockHeader memory firstBlock = BlockHeader({
            size: size,
            used: false,
            prevOffset: 0,
            nextOffset: 0
        });

        _writeBlockHeader(heap, 0, firstBlock);
    }

    /**
     * @notice Allocate memory from heap
     * @param heap The heap to allocate from
     * @param size Requested size in bytes
     */
    function allocate(
        Heap memory heap,
        uint256 size
    ) internal returns (bytes32) {
        require(size > 0, "HeapAllocator: Invalid size");

        uint256 alignedSize = ((size + 31) / 32) * 32; // Align to 32 bytes
        uint256 blockSize = alignedSize + 128; // Add header size
        uint256 currentOffset = heap.freeList;

        while (currentOffset < heap.totalSize) {
            BlockHeader memory header = _readBlockHeader(heap, currentOffset);

            if (!header.used && header.size >= blockSize) {
                // Split block if there's enough space for another block
                if (header.size >= blockSize + 128) {
                    uint256 newBlockOffset = currentOffset + blockSize;
                    BlockHeader memory newBlock = BlockHeader({
                        size: header.size - blockSize,
                        used: false,
                        prevOffset: currentOffset,
                        nextOffset: header.nextOffset
                    });
                    _writeBlockHeader(heap, newBlockOffset, newBlock);

                    header.size = blockSize;
                    header.nextOffset = newBlockOffset;
                }

                header.used = true;
                _writeBlockHeader(heap, currentOffset, header);

                return bytes32(uint256(heap.basePointer) + currentOffset + 128);
            }
            currentOffset = header.nextOffset;
            if (currentOffset == 0) break;
        }

        revert OutOfMemory();
    }

    /**
     * @notice Free allocated memory
     * @param heap The heap containing the allocation
     * @param pointer Pointer to allocated memory
     */
    function free(Heap memory heap, bytes32 pointer) internal {
        uint256 offset = uint256(pointer) - uint256(heap.basePointer) - 128;
        BlockHeader memory header = _readBlockHeader(heap, offset);

        require(header.used, "HeapAllocator: Double free");

        header.used = false;

        // Coalesce with next block if free
        if (header.nextOffset != 0) {
            BlockHeader memory nextHeader = _readBlockHeader(
                heap,
                header.nextOffset
            );
            if (!nextHeader.used) {
                header.size += nextHeader.size;
                header.nextOffset = nextHeader.nextOffset;
            }
        }

        // Coalesce with previous block if free
        if (header.prevOffset != 0) {
            BlockHeader memory prevHeader = _readBlockHeader(
                heap,
                header.prevOffset
            );
            if (!prevHeader.used) {
                prevHeader.size += header.size;
                prevHeader.nextOffset = header.nextOffset;
                header = prevHeader;
                offset = header.prevOffset;
            }
        }

        _writeBlockHeader(heap, offset, header);

        // Update free list if necessary
        if (offset < heap.freeList) {
            heap.freeList = offset;
        }
    }

    // Internal helper functions
    function _writeBlockHeader(
        Heap memory heap,
        uint256 offset,
        BlockHeader memory header
    ) private {
        bytes32 slot = keccak256(abi.encodePacked(heap.basePointer, offset));
        TransientAllocator.store(slot, header.size);
        TransientAllocator.store(
            bytes32(uint256(slot) + 1),
            header.used ? 1 : 0
        );
        TransientAllocator.store(bytes32(uint256(slot) + 2), header.prevOffset);
        TransientAllocator.store(bytes32(uint256(slot) + 3), header.nextOffset);
    }

    function _readBlockHeader(
        Heap memory heap,
        uint256 offset
    ) private view returns (BlockHeader memory header) {
        bytes32 slot = keccak256(abi.encodePacked(heap.basePointer, offset));
        header.size = TransientAllocator.load(slot);
        header.used = TransientAllocator.load(bytes32(uint256(slot) + 1)) == 1;
        header.prevOffset = TransientAllocator.load(bytes32(uint256(slot) + 2));
        header.nextOffset = TransientAllocator.load(bytes32(uint256(slot) + 3));
    }
}
