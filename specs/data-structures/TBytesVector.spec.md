# TBytesVector

## Overview
A dynamic bytes vector implementation that supports different allocator types (Transient, Memory, Storage) for flexible storage strategies.

## Core Components

### Types
- Uses `AllocatorFactory.Allocator` for storage management
- Internal metadata tracking length and capacity

### Functions
1. `initialize(Allocator, uint256)`
   - Sets up vector with initial capacity
   - Configures allocator type

2. `push/pop Operations`
   - `push(bytes memory)`: Appends bytes to end
   - `pop()`: Removes and returns last element
   - Auto-resizing on push if needed

3. `Access Operations`
   - `at(uint256) → bytes`: Get element at index
   - `length() → uint256`: Current number of elements
   - `capacity() → uint256`: Maximum elements before resize

4. `Memory Management`
   - `resize(uint256)`: Change vector capacity
   - `clear()`: Remove all elements
   - `destroy()`: Free allocated memory

## Requirements
1. Data Integrity
   - Bounds checking
   - Safe resizing
   - Proper bytes handling

2. Memory Safety
   - No overflow in calculations
   - Proper memory cleanup
   - Safe allocation/deallocation

3. Gas Optimization
   - Efficient resizing strategy
   - Minimal copying operations
   - Optimized storage access 