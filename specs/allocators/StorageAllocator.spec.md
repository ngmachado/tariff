# StorageAllocator

## Overview
A permanent storage allocator that manages Ethereum's storage space using keccak256-based pointer generation.

## Core Components

### Functions
1. `allocate(...) → bytes32`
   Two variants:
   - `(bytes32, uint256)`: Allocates with specific slot
   - `(uint256)`: Allocates with auto-generated slot
   - Both require positive size

2. `store/load Operations`
   - `store(bytes32, uint256)`: Stores value using sstore
   - `load(bytes32) → uint256`: Loads value using sload
   - `free(bytes32)`: Zeros out storage slot

## Requirements
1. Storage Safety
   - Unique pointer generation
   - Collision prevention
   - Non-zero size validation

2. Gas Optimization
   - Efficient storage operations
   - Minimal storage writes

3. Data Integrity
   - Permanent storage persistence
   - Safe storage clearing
