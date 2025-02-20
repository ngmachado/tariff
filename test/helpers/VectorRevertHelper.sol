// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../../src/data-structures/TVector.sol";
import "../../src/allocators/ArenaAllocator.sol";
import "../../src/allocators/TransientAllocator.sol";
import "../../src/data-structures/TBytesVector.sol";
import "../../src/allocators/AllocatorFactory.sol";

contract VectorRevertHelper {
    using TVector for TVector.Vector;
    using ArenaAllocator for ArenaAllocator.Arena;
    using TransientAllocator for bytes32;
    using TBytesVector for TBytesVector.Vector;

    // TVector helpers
    function tryAt(
        TVector.Vector memory vector,
        uint256 index
    ) external view returns (uint256) {
        return vector.at(index);
    }

    function tryPush(TVector.Vector memory vector, uint256 value) external {
        vector.push(value);
    }

    function tryPop(TVector.Vector memory vector) external {
        vector.pop();
    }

    function tryNewVector(
        AllocatorFactory.AllocatorType allocatorType,
        uint256 initialCapacity
    ) external returns (TVector.Vector memory) {
        return TVector.newVector(allocatorType, initialCapacity);
    }

    // Arena helpers
    function tryInitialize(
        ArenaAllocator.Arena memory arena,
        bytes32 slot,
        uint256 size
    ) external {
        arena.initialize(slot, size);
    }

    function tryAllocate(
        ArenaAllocator.Arena memory arena,
        uint256 size
    ) external returns (bytes32) {
        return arena.allocate(size);
    }

    // TransientAllocator helpers
    function tryTransientAllocate(
        uint256 size
    ) external pure returns (bytes32) {
        require(size > 0, "TransientAllocator: Size must be positive");
        return keccak256(abi.encodePacked("TransientAllocator", size));
    }

    // TBytesVector helpers
    function tryBytesAt(
        TBytesVector.Vector memory vector,
        uint256 index
    ) external view returns (bytes memory) {
        return vector.at(index);
    }

    function tryBytesPush(
        TBytesVector.Vector memory vector,
        bytes memory data
    ) external {
        vector.push(data);
    }

    function tryNewBytesVector(
        AllocatorFactory.AllocatorType allocatorType,
        uint256 initialCapacity
    ) external returns (TBytesVector.Vector memory) {
        return TBytesVector.newVector(allocatorType, initialCapacity);
    }
}
