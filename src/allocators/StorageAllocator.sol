// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library StorageAllocator {
    function allocate(
        bytes32 slot,
        uint256 size
    ) internal pure returns (bytes32 pointer) {
        require(size > 0, "StorageAllocator: Size must be positive");
        pointer = keccak256(abi.encode(slot, size));
    }

    function allocate(uint256 size) internal view returns (bytes32 pointer) {
        require(size > 0, "StorageAllocator: Size must be positive");
        pointer = keccak256(abi.encodePacked("StorageAllocator", size));
        assembly {
            if iszero(iszero(sload(pointer))) {
                revert(0, 0)
            }
        }
    }

    function store(bytes32 pointer, uint256 value) internal {
        assembly {
            sstore(pointer, value)
        }
    }

    function load(bytes32 pointer) internal view returns (uint256 value) {
        assembly {
            value := sload(pointer)
        }
    }

    function free(bytes32 pointer) internal {
        assembly {
            sstore(pointer, 0)
        }
    }
}
