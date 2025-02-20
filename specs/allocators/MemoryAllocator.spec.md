# MemoryAllocator

## Overview
A low-level memory allocator that manages Solidity's memory space using raw memory pointers and assembly operations.

## Core Components

### Types
- `ArrayData`: Internal struct for array operations
  - `capacity`: Maximum array size
  - `length`: Current number of elements

### Functions
1. `allocate(bytes32, uint256) → bytes32`
   - Allocates memory space with given slot and size
   - Size must be positive and <= 0x1000
   - Returns unique pointer based on slot

2. `store/load Operations`
   - `store(bytes32, uint256)`: Stores single value
   - `load(bytes32) → uint256`: Loads single value
   - `storeAtIndex(bytes32, uint256, uint256)`: Array-like storage
   - `loadAtIndex(bytes32, uint256) → uint256`: Array-like loading

3. `Array Management`
   - `initArray(bytes32, uint256)`: Initialize array metadata
   - `getArrayLength(bytes32) → uint256`: Get current length
   - `getArrayCapacity(bytes32) → uint256`: Get maximum capacity

## Requirements
1. Memory Safety
   - Proper pointer arithmetic
   - No out-of-bounds access
   - Size constraints enforced

2. Gas Optimization
   - Efficient assembly operations
   - Minimal memory expansion
   - Compact array metadata

3. Data Integrity
   - Unique pointer generation
   - Preserved array metadata
   - Safe memory layout
