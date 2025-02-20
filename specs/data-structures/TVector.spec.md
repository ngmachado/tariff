# TVector

## Overview
A dynamic array implementation supporting different allocator types with automatic resizing capabilities and optimized memory operations.

## Core Components

### Types
- `Vector`: Main struct containing
  - `allocator`: Storage type (Transient/Memory/Storage)
  - `basePointer`: Base address for array storage
  - `capacity`: Total allocated slots
  - `_length`: Current number of elements

### Functions
1. `newVector(AllocatorType, uint256) → Vector`
   - Creates vector with initial capacity
   - Generates unique nonce-based pointer
   - Validates capacity constraints

2. `Array Operations`
   - `push(Vector, uint256)`: Add element to end
   - `pop(Vector)`: Remove last element
   - `at(Vector, uint256) → uint256`: Get element at index
   - `set(Vector, uint256, uint256)`: Update element at index
   - `length(Vector) → uint256`: Get current length

3. `Memory Management`
   - `_resize(Vector)`: Double capacity when full
   - `load(AllocatorType, uint256, bytes32) → Vector`: Load existing vector

### Error Cases
- `TVectorOutOfBounds`: Index access beyond length
- `TVectorOverflow`: Capacity overflow on resize
- `TVectorInvalidCapacity`: Zero or invalid capacity
- `TVectorCapacityTooLarge`: Exceeds maximum safe size
- `TVectorEmpty`: Pop from empty vector

## Requirements
1. Data Safety
   - Bounds checking on all accesses
   - Safe capacity management
   - Proper error handling

2. Memory Management
   - Efficient resizing strategy
   - Safe memory copying
   - Proper cleanup on operations

3. Gas Optimization
   - Optimized memory vs storage operations
   - Efficient resizing
   - Minimal storage operations 