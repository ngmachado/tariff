# AllocatorFactory

## Overview
A unified memory allocation system that provides a common interface for managing different types of storage in Ethereum: transient storage (tstore), memory, and permanent storage.

## Core Components

### Types
- `AllocatorType`: Enum for storage types (Transient, Memory, Storage)
- `Allocator`: Struct containing allocator type and pointer

### Functions
1. `allocate(AllocatorType, bytes32, uint256) → bytes32`
   - Allocates memory of specified size
   - Returns pointer to allocated space

2. `store(AllocatorType, bytes32, uint256)`
   - Stores value at pointer location
   - Must use valid, allocated pointer

3. `load(AllocatorType, bytes32) → uint256`
   - Retrieves value from pointer location
   - Must use valid, allocated pointer

4. `free(AllocatorType, bytes32)`
   - Deallocates memory at pointer
   - Cleans up based on allocator type

## Requirements
1. Memory Safety
   - No pointer reuse until freed
   - No cross-allocator interference

2. Gas Efficiency
   - Optimize for respective storage type
   - Minimize unnecessary operations

3. Error Handling
   - Revert on invalid operations
   - Prevent double-free scenarios
