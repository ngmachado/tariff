# TMap

## Overview
A key-value mapping implementation that supports different allocator types, providing flexible storage options for mapping data structures.

## Core Components

### Types
- `Map`: Main struct containing
  - `allocator`: Storage type (Transient/Memory/Storage)
  - `basePointer`: Base address for key-value storage
- `MapEntry`: Entry struct with
  - `exists`: Boolean flag
  - `value`: Stored value

### Functions
1. `newTMap(AllocatorType) → Map`
   - Creates new map instance
   - Generates unique base pointer
   - Initializes with allocator type

2. `Key-Value Operations`
   - `set(Map, bytes32, uint256)`: Store value for key
   - `get(Map, bytes32) → uint256`: Retrieve value by key
   - `remove(Map, bytes32)`: Delete key-value pair

3. `Query Operations`
   - `contains(Map, bytes32) → bool`: Check key existence

## Requirements
1. Data Integrity
   - Unique key handling
   - Safe value storage/retrieval
   - Proper deletion

2. Storage Safety
   - Collision-free key slots
   - Proper pointer management
   - Safe memory operations

3. Gas Optimization
   - Efficient key hashing
   - Minimal storage operations 