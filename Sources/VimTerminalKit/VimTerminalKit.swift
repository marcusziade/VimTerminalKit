/// A Swift package that provides Vim-style navigation and terminal UI utilities for building
/// command-line applications.
///
/// VimTerminalKit offers a comprehensive set of tools for creating terminal user interfaces,
/// including:
/// - Vim-style (hjkl) and arrow key navigation
/// - Terminal state management
/// - Loading animations
/// - Raw mode handling
/// - Terminal control sequences
///
/// Example usage:
/// ```swift
/// import VimTerminalKit
///
/// class MyTerminalApp {
///     private let navigator = VimTerminalKit.Navigator(itemCount: 10)
///     private let stateManager: VimTerminalKit.StateManager
///
///     init() {
///         stateManager = .init { [weak self] in
///             self?.updateUI()
///         }
///     }
///
///     func start() {
///         VimTerminalKit.setup()
///         defer { VimTerminalKit.cleanup() }
///
///         while true {
///             switch VimTerminalKit.InputReader.getInput() {
///                 case .vim(let direction), .arrow(let direction):
///                     navigator.navigate(.arrow(direction))
///                 case .quit:
///                     return
///                 default:
///                     break
///             }
///         }
///     }
/// }
/// ```
public struct VimTerminalKit {
    /// Sets up the terminal for interactive use.
    ///
    /// This method:
    /// - Enables raw mode for immediate character input
    /// - Hides the cursor
    /// - Configures the terminal for optimal interaction
    ///
    /// - Important: Always call `cleanup()` when you're done, typically in a `defer` block.
    public static func setup() {
        Terminal.RawMode.enable()
    }

    /// Restores the terminal to its original state.
    ///
    /// This method:
    /// - Disables raw mode
    /// - Shows the cursor
    /// - Restores normal terminal operation
    public static func cleanup() {
        Terminal.RawMode.disable()
    }
}
