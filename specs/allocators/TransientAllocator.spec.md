# TransientAllocator

## Overview
A transient storage allocator utilizing EVM's transient storage (tstore/tload) for temporary data storage that persists within a transaction.

## Core Components

### Functions
1. `allocate(...) → bytes32`
   Two variants:
   - `(bytes32, uint256)`: Allocates with specific slot
   - `(uint256)`: Allocates with auto-generated slot
   - Both require valid inputs

2. `store/load Operations`
   - `store(bytes32, uint256)`: Stores using tstore
   - `load(bytes32) → uint256`: Loads using tload
   - `free(bytes32)`: Clears transient storage

## Requirements
1. Transient Safety
   - Valid slot validation
   - Positive size requirement
   - Unique pointer generation

2. Gas Optimization
   - Efficient transient operations
   - Temporary storage benefits

3. Data Lifecycle
   - Transaction-scoped persistence
   - Proper cleanup after use
