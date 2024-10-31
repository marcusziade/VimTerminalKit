import Foundation

// Sources/VimTerminalKit/State/StateManager.swift

public extension VimTerminalKit {
    /// Manages state and loading indicators for terminal interfaces.
    ///
    /// The `StateManager` class provides centralized management of loading states,
    /// messages, and UI updates. It handles loading animations and provides convenient
    /// methods for running async operations with loading indicators.
    ///
    /// Example usage:
    /// ```swift
    /// let stateManager = StateManager {
    ///     // Update your UI here
    ///     clearScreen()
    ///     printInterface()
    /// }
    ///
    /// // Use with async operations
    /// try await stateManager.withLoading(message: "Loading data...") {
    ///     try await fetchData()
    /// }
    /// ```
    final class StateManager {
        /// The current loading message being displayed.
        public private(set) var loadingMessage: String = ""

        /// Indicates whether the interface is in a loading state.
        public private(set) var isLoading: Bool = false

        /// The loading animator instance handling the animation.
        private var loadingAnimator: LoadingAnimator?

        /// Closure called when the UI needs to be updated.
        private let updateUI: () -> Void

        /// Creates a new state manager instance.
        ///
        /// - Parameter updateUI: A closure that will be called whenever the UI needs to be updated
        public init(updateUI: @escaping () -> Void) {
            self.updateUI = updateUI
        }

        /// Starts a loading state with the specified message.
        ///
        /// - Parameter message: The message to display during loading
        public func startLoading(message: String) {
            isLoading = true
            loadingMessage = message

            loadingAnimator = LoadingAnimator(initialMessage: message) { [weak self] newMessage in
                self?.loadingMessage = newMessage
                self?.updateUI()
            }
            loadingAnimator?.start()
        }

        /// Updates the current loading message.
        ///
        /// - Parameter message: The new message to display
        public func updateLoadingMessage(_ message: String) {
            loadingMessage = message
            updateUI()
        }

        /// Stops the current loading state.
        public func stopLoading() {
            isLoading = false
            loadingAnimator?.stop()
            loadingAnimator = nil
            updateUI()
        }

        /// Executes an async operation while showing a loading indicator.
        ///
        /// - Parameters:
        ///   - message: The message to display during loading
        ///   - operation: The async operation to perform
        /// - Returns: The result of the operation
        /// - Throws: Any error thrown by the operation
        public func withLoading<T>(message: String, operation: @escaping () async throws -> T) async throws -> T {
            startLoading(message: message)
            defer { stopLoading() }
            return try await operation()
        }
    }
}
