# TSet

## Overview
A unique value set implementation supporting different allocator types, providing efficient membership testing and unique value storage.

## Core Components

### Types
- `Set`: Main struct containing
  - `allocator`: Storage type (Transient/Memory/Storage)
  - `basePointer`: Base address for element storage

### Functions
1. `newTSet(AllocatorType) → Set`
   - Creates new set instance
   - Generates unique base pointer
   - Initializes with allocator type

2. `Element Operations`
   - `add(Set, bytes32)`: Add value to set
   - `remove(Set, bytes32)`: Remove value from set
   - `contains(Set, bytes32) → bool`: Check membership

## Requirements
1. Set Properties
   - Unique elements
   - Efficient membership testing
   - Safe element removal

2. Storage Safety
   - Collision-free element slots
   - Proper pointer management
   - Safe memory operations

3. Gas Optimization
   - Efficient element hashing
   - Minimal storage operations
   - Optimized membership checks 