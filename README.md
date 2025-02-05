# Tariff

Tariff is a Solidity library that provides efficient data structures through a unified allocator system. It supports multiple storage strategies including transient storage (`tstore`/`tload`), permanent storage (`sstore`/`sload`), and memory operations. The library is designed to optimize gas costs and memory usage in smart contracts by allowing developers to choose the most appropriate storage strategy for their use case.

## Core Concepts

### Allocator System
The library is built around the concept of allocators - abstractions that manage different types of storage:

1. **TransientAllocator**
   - Uses transient storage for temporary data within transactions
   - Ideal for temporary computations and state that doesn't need to persist
   - Most gas efficient for temporary storage

2. **StorageAllocator**
   - Uses permanent storage for persistent data
   - Suitable for state that needs to survive between transactions
   - Higher gas cost but provides persistence

3. **MemoryAllocator**
   - Uses Solidity's memory for temporary data
   - Best for short-lived data within a single function call
   - Automatically cleaned up after function execution

4. **HeapAllocator**
   - Advanced memory management using transient storage
   - Provides manual memory management capabilities
   - Supports allocation, deallocation, and defragmentation
   - Useful for complex data structures with dynamic lifetimes

5. **ArenaAllocator**
   - Region-based memory management
   - Efficient bulk allocation and deallocation
   - Perfect for temporary data with same lifetime

### Data Structures
Built on top of the allocator system:

- **TVector**: Dynamic array with automatic resizing
- **TMap**: Key-value mapping structure
- **TSet**: Unique value set implementation

Each data structure can work with any allocator type, allowing flexible storage strategies.

## Usage Examples

### Creating a Vector with Different Allocators

```solidity
// Transient Storage Vector (temporary)
TVector.Vector memory vector1 = TVector.newVector(
    AllocatorFactory.AllocatorType.Transient,
    initialCapacity
);

// Permanent Storage Vector (persistent)
TVector.Vector memory vector2 = TVector.newVector(
    AllocatorFactory.AllocatorType.Storage,
    initialCapacity
);

// Memory Vector (function scope)
TVector.Vector memory vector3 = TVector.newVector(
    AllocatorFactory.AllocatorType.Memory,
    initialCapacity
);
```

### Using Arena Allocator for Bulk Operations
```solidity
// Initialize arena
ArenaAllocator.Arena memory arena;
arena.initialize(slot, capacity);

// Efficient bulk allocations
bytes32[] memory pointers = new bytes32[](100);
for (uint256 i = 0; i < 100; i++) {
    pointers[i] = arena.allocate(32);
    ArenaAllocator.store(pointers[i], i);
}

// Single operation cleanup
arena.reset();
```

### Using Heap Allocator for Dynamic Memory
```solidity
// Initialize heap
HeapAllocator.Heap memory heap = HeapAllocator.initialize(1024);

// Dynamic allocations
bytes32 ptr1 = heap.allocate(64);
bytes32 ptr2 = heap.allocate(128);

// Use memory
TransientAllocator.store(ptr1, value1);
TransientAllocator.store(ptr2, value2);

// Free individual allocations
heap.free(ptr1);
heap.free(ptr2);
```

## Key Benefits

### Storage Flexibility
- Choose between transient, permanent, or memory storage
- Switch storage strategies without changing business logic
- Optimize gas costs based on storage needs

### Memory Management
- Structured memory management patterns
- Efficient allocation and deallocation
- Prevention of memory leaks and fragmentation

### Gas Optimization
- Use transient storage for temporary data
- Minimize permanent storage operations
- Efficient memory reuse strategies

### Safety
- Type-safe operations
- Bounds checking
- Memory safety guarantees
- Comprehensive test coverage

## Architecture

The project follows a layered architecture:

1. **Base Layer: Allocators**
   - Raw storage access (transient/permanent/memory)
   - Memory management primitives
   - Storage pattern implementations

2. **Middle Layer: Memory Management**
   - HeapAllocator for manual memory management
   - ArenaAllocator for region-based allocation
   - Memory safety and optimization

3. **Top Layer: Data Structures**
   - High-level data structures
   - Allocator-agnostic implementations
   - Automatic memory management

## Installation

```bash
forge install tariffs
```

## Testing

```bash
forge test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License

## Note

This project includes experimental features and advanced memory management patterns. Ensure your environment supports all required operations (`tstore`/`tload`) and thoroughly test in your specific use case.
