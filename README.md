# VimTerminalKit

![VimTerminalKit-logo-small](https://github.com/user-attachments/assets/7b5ab343-2fae-44c8-868a-95633fae7ac3)


A Swift package that brings Vim-style navigation and powerful terminal UI capabilities to your command-line applications.

## Features

- 🎮 Vim-style (hjkl) and arrow key navigation
- 📊 Multi-column menu navigation
- 🔄 Loading animations and state management
- ⌨️ Raw terminal mode handling
- 🎨 Terminal control sequences
- 🔧 Async operation support
- 📱 Clean, SwiftUI-like API

## Installation

### Swift Package Manager

Add VimTerminalKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/VimTerminalKit.git", from: "1.0.0")
]
```

## Quick Start

Here's a complete example of a terminal application using VimTerminalKit:

```swift
import VimTerminalKit

struct ExampleTerminalApp {
    private let navigator: VimTerminalKit.Navigator
    private let stateManager: VimTerminalKit.StateManager
    private var isRunning = true
    
    // Menu items for our example
    private let menuItems = [
        "View Users",
        "Create User",
        "Edit User",
        "Delete User",
        "View Settings",
        "Edit Settings",
        "Export Data",
        "Import Data",
        "View Logs",
        "Clear Logs"
    ]
    
    init() {
        // Initialize navigator with our menu item count
        navigator = .init(itemCount: menuItems.count)
        
        // Initialize state manager with UI update callback
        stateManager = .init { [self] in
            clearScreen()
            printInterface()
        }
    }
    
    mutating func start() {
        // Set up terminal and ensure cleanup
        VimTerminalKit.setup()
        defer { VimTerminalKit.cleanup() }
        
        while isRunning {
            clearScreen()
            printInterface()
            handleInput()
        }
    }
    
    private func clearScreen() {
        print(VimTerminalKit.Terminal.Control.clearScreen, terminator: "")
    }
    
    private func printInterface() {
        print("Example Terminal App")
        print("===================\n")
        
        if stateManager.isLoading {
            print(stateManager.loadingMessage)
            return
        }
        
        // Print menu items in two columns
        let midpoint = (menuItems.count + 1) / 2
        for i in 0..<midpoint {
            var line = ""
            
            // First column
            if i == navigator.selectedIndex && navigator.selectedColumn == 0 {
                line += "➤ "
            } else {
                line += "  "
            }
            line += menuItems[i].padRight(30)
            
            // Second column if available
            if i + midpoint < menuItems.count {
                if i + midpoint == navigator.selectedIndex && navigator.selectedColumn == 1 {
                    line += "➤ "
                } else {
                    line += "  "
                }
                line += menuItems[i + midpoint]
            }
            
            print(line)
        }
        
        print("\nUse hjkl or arrow keys to navigate, Enter to select, q to quit")
    }
    
    private mutating func handleInput() {
        switch VimTerminalKit.InputReader.getInput() {
        case .vim(let direction), .arrow(let direction):
            navigator.navigate(.arrow(direction))
            
        case .enter:
            Task {
                try await stateManager.withLoading(message: "Processing \(menuItems[navigator.selectedIndex])...") {
                    // Simulate some work
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                }
            }
            
        case .quit:
            isRunning = false
            
        default:
            break
        }
    }
}

extension String {
    func padRight(_ length: Int) -> String {
        if count < length {
            return self + String(repeating: " ", count: length - count)
        }
        return self
    }
}

// Run the app
ExampleTerminalApp().start()
```

## Advanced Usage

### Custom Loading Animations

```swift
let stateManager = VimTerminalKit.StateManager { 
    // Update UI
}

// Simple loading
await stateManager.withLoading(message: "Loading...") {
    try await someAsyncWork()
}

// Update loading message
stateManager.startLoading(message: "Step 1")
// do work
stateManager.updateLoadingMessage("Step 2")
// do more work
stateManager.stopLoading()
```

### Multi-Column Navigation

```swift
// Create a navigator with custom columns
let navigator = VimTerminalKit.Navigator(
    itemCount: items.count,
    columnsCount: 3,  // Default is 2
    initialIndex: 0,
    initialColumn: 0
)

// Navigation happens automatically based on your column count
navigator.navigate(.arrow(.right))  // Moves to next column
```

### Raw Terminal Control

```swift
// Manual terminal control
print(VimTerminalKit.Terminal.Control.clearScreen)
print(VimTerminalKit.Terminal.Control.hideCursor)

// Move cursor
print(VimTerminalKit.Terminal.Control.up)
print(VimTerminalKit.Terminal.Control.right)
```

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) first.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
