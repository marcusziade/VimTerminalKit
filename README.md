# VimTerminalKit

![VimTerminalKit-logo-small](https://github.com/user-attachments/assets/7b5ab343-2fae-44c8-868a-95633fae7ac3)

A Swift package that brings Vim-style navigation and powerful terminal UI capabilities to your command-line applications. Create interactive terminal UIs with ease, supporting both single-column layouts (like file explorers) and multi-column layouts (like menus).

## Features

- 🎮 Vim-style (hjkl) and arrow key navigation
- 📊 Flexible single and multi-column layouts
- 🔄 Loading animations and state management
- ⌨️ Raw terminal mode handling
- 🎨 Terminal control sequences
- 🔧 Async operation support

## Installation

### Swift Package Manager

Add VimTerminalKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/marcusziade/VimTerminalKit.git", from: "1.0.0")
]
```

Then import it in your source files:

```swift
import VimTerminalKit
```

## Layout Types

### Single-Column Layout (File Explorer)
Best for:
- File explorers
- Linear lists
- Command logs
- Vertical menus

Required setup:
```swift
let navigator = VimTerminalKit.Navigator(
    itemCount: items.count,
    columnsCount: 1  // Must be 1 for vertical lists
)
```

### Multi-Column Layout (Grid Menu)
Best for:
- Dashboard layouts
- Option grids
- Category selections
- Side-by-side views

Required setup:
```swift
let navigator = VimTerminalKit.Navigator(
    itemCount: items.count,
    columnsCount: 2  // 2 or more for grid layouts
)
```

## Core Concepts

### 1. Proper Initialization

The correct initialization pattern is crucial for avoiding compiler errors and runtime issues:

```swift
final class MyApp {
    private let navigator: VimTerminalKit.Navigator
    private let stateManager: VimTerminalKit.StateManager
    private var items: [String] = []
    
    init() {
        // 1. Initialize basic properties first
        self.items = []
        // 2. Set up navigator with initial state
        self.navigator = .init(itemCount: 1, columnsCount: 1)
        // 3. Initialize stateManager with empty closure
        self.stateManager = .init { }
        // 4. Set up callbacks after initialization
        setupStateManager()
    }
    
    private func setupStateManager() {
        stateManager = .init { [weak self] in
            self?.updateUI()
        }
    }
}
```

### 2. State Management

The StateManager handles UI updates and loading states:

```swift
// Initialize with UI update callback
let stateManager = VimTerminalKit.StateManager { 
    // Update UI here
}

// Show loading state
await stateManager.withLoading(message: "Loading...") {
    try await someAsyncWork()
}
```

### 3. Navigation Control

Handle navigation inputs:

```swift
switch VimTerminalKit.InputReader.getInput() {
case .vim(let direction), .arrow(let direction):
    navigator.navigate(.arrow(direction))
case .enter:
    // Handle selection
case .quit:
    isRunning = false
default:
    break
}
```

## Complete Examples

### 1. **See** a full CLI app example named 'FileExplorer' under `/Sources`

### 2. File Explorer Implementation

```swift
final class Explorer {
    private let fileManager = FileManager.default
    private var currentPath: String
    private var items: [FileItem] = []
    private var navigator: VimTerminalKit.Navigator
    private var stateManager: VimTerminalKit.StateManager
    private var isRunning = true
    private var pathHistory: [String] = []

    init() {
        // IMPORTANT: Order matters for initialization
        self.currentPath = fileManager.currentDirectoryPath
        self.navigator = .init(itemCount: 1, columnsCount: 1)
        self.stateManager = .init { }
        setupStateManager()
    }

    private func setupStateManager() {
        stateManager = .init { [weak self] in
            self?.clearScreen()
            self?.printInterface()
        }
    }

    private func loadCurrentDirectory() {
        Task { [weak self] in
            guard let self else { return }
            try await self.stateManager.withLoading(message: "Loading...") {
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.currentPath)
                self.items = // ... process contents ...
                let totalItems = self.currentPath == "/" ? items.count : items.count + 1
                self.navigator = .init(itemCount: totalItems, columnsCount: 1)
            }
        }
    }

    func start() {
        VimTerminalKit.setup()
        defer { VimTerminalKit.cleanup() }
        
        loadCurrentDirectory()
        
        while isRunning {
            clearScreen()
            printInterface()
            handleInput()
        }
    }
}
```

### 3. Menu Implementation

```swift
struct MenuApp {
    private let navigator: VimTerminalKit.Navigator
    private let stateManager: VimTerminalKit.StateManager
    private var isRunning = true
    private let menuItems = ["Option 1", "Option 2", "Option 3", "Option 4"]
    
    init() {
        self.navigator = .init(itemCount: menuItems.count, columnsCount: 2)
        self.stateManager = .init { }
        setupStateManager()
    }
    
    private func setupStateManager() {
        stateManager = .init { [weak self] in
            self?.redrawInterface()
        }
    }
    
    func start() {
        VimTerminalKit.setup()
        defer { VimTerminalKit.cleanup() }
        
        while isRunning {
            redrawInterface()
            handleInput()
        }
    }
    
    private func redrawInterface() {
        // ... draw menu interface ...
    }
}
```

## Common Pitfalls

### Initialization Issues
- ❌ Don't use `self` in property initializers
- ❌ Don't set up callbacks directly in property initialization
- ❌ Don't access properties before they're initialized
- ✅ Initialize properties first, then set up callbacks
- ✅ Use proper initialization order
- ✅ Set up complex logic in separate setup methods

### Navigation Issues
- ❌ Don't forget to update navigator when items change
- ❌ Don't mix column counts (stick to either 1 or 2+)
- ✅ Always update navigator item count when content changes
- ✅ Use columnsCount: 1 for file explorers
- ✅ Use columnsCount: 2+ for grid layouts

## Advanced Features

### Terminal Control

```swift
// Screen control
print(VimTerminalKit.Terminal.Control.clearScreen)

// Cursor control
print(VimTerminalKit.Terminal.Control.hideCursor)
print(VimTerminalKit.Terminal.Control.showCursor)

// Movement
print(VimTerminalKit.Terminal.Control.up)
print(VimTerminalKit.Terminal.Control.down)
```

### State Management

```swift
// Progress indication
stateManager.startLoading(message: "Step 1")
// ... work ...
stateManager.updateLoadingMessage("Step 2")
// ... work ...
stateManager.stopLoading()

// Async operations
await stateManager.withLoading(message: "Processing...") {
    try await someAsyncWork()
}
```

## Best Practices

1. **Setup and Cleanup**
   - Always call `VimTerminalKit.setup()` before starting
   - Always use `defer { VimTerminalKit.cleanup() }` after setup

2. **Memory Management**
   - Use `[weak self]` in closures
   - Clean up resources when app terminates

3. **Error Handling**
   - Handle all async operations appropriately
   - Provide user feedback during errors

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by Vim's navigation system
- Built with Swift's modern concurrency features