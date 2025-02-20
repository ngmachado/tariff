# ArenaAllocator

## Overview
An arena-based allocation strategy built on top of TransientAllocator, allowing for efficient memory management within defined memory regions (arenas).

## Core Components

### Types
- `Arena`: Struct containing
  - `arenaKey`: Unique arena identifier
  - `offset`: Current allocation position
  - `capacity`: Total arena size

### Functions
1. `initialize(Arena, bytes32, uint256)`
   - Sets up new arena with given slot and size
   - Requires positive size

2. `allocate(...) → bytes32`
   Three variants:
   - `(bytes32, uint256)`: Allocates with specific slot
   - `(uint256)`: Allocates with auto-generated slot
   - `(Arena, uint256)`: Allocates within arena bounds

3. `store(bytes32, uint256)`
   - Stores value at pointer location
   - Delegates to TransientAllocator

4. `load(bytes32) → uint256`
   - Retrieves value from pointer
   - Delegates to TransientAllocator

5. `reset(Arena)`
   - Resets arena to initial state
   - Maintains arena capacity

## Requirements
1. Arena Management
   - No allocations beyond capacity
   - Unique arena keys
   - Sequential allocations within arena

2. Memory Safety
   - Valid pointer operations
   - No overflow in offset tracking

3. Gas Optimization
   - Efficient space reuse after reset
   - Minimal storage operations
