import Foundation

// Sources/VimTerminalKit/Loading/LoadingAnimation.swift

public extension VimTerminalKit {
    /// Provides predefined animation frames for terminal loading indicators.
    struct LoadingAnimation {
        /// A collection of braille-based spinner frames for smooth terminal animations.
        ///
        /// These frames create a rotating animation when displayed in sequence:
        /// ```
        /// ⠋ → ⠙ → ⠹ → ⠸ → ⠼ → ⠴ → ⠦ → ⠧ → ⠇ → ⠏
        /// ```
        public static let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    }

    /// A class that manages animated loading indicators in the terminal.
    ///
    /// `LoadingAnimator` provides a way to display animated loading spinners alongside
    /// custom messages. It handles animation timing and frame updates automatically.
    ///
    /// Example usage:
    /// ```swift
    /// let animator = LoadingAnimator(initialMessage: "Loading data...") { message in
    ///     print("\r\(message)", terminator: "")
    /// }
    ///
    /// animator.start()
    /// // ... perform work ...
    /// animator.stop()
    /// ```
    final class LoadingAnimator {
        /// The collection of animation frames to cycle through.
        private let frames: [String]

        /// The current frame index in the animation sequence.
        private var animationFrame: Int

        /// The base message to display alongside the animation.
        public let initialMessage: String

        /// Callback that's called with updated messages during animation.
        public let onUpdate: (String) -> Void

        /// Indicates whether the animation is currently running.
        public private(set) var isRunning: Bool

        /// Queue used for running the animation.
        private var animationQueue: DispatchQueue?

        /// Creates a new loading animator.
        ///
        /// - Parameters:
        ///   - initialMessage: The message to display alongside the animation
        ///   - onUpdate: A closure that will be called with each frame update
        public init(initialMessage: String, onUpdate: @escaping (String) -> Void) {
            self.frames = LoadingAnimation.frames
            self.animationFrame = 0
            self.initialMessage = initialMessage
            self.onUpdate = onUpdate
            self.isRunning = false
        }

        /// Starts the loading animation.
        ///
        /// The animation will continue running until `stop()` is called. If the animation
        /// is already running, this method has no effect.
        public func start() {
            guard !isRunning else { return }
            isRunning = true

            animationQueue = DispatchQueue(label: "com.vimterminalkit.loading")
            animationQueue?.async { [weak self] in
                guard let self = self else { return }
                while self.isRunning {
                    let newMessage = "\(self.initialMessage) \(self.frames[self.animationFrame])"
                    self.onUpdate(newMessage)
                    Thread.sleep(forTimeInterval: 0.1)
                    self.animationFrame = (self.animationFrame + 1) % self.frames.count
                }
            }
        }

        /// Stops the loading animation.
        ///
        /// Once stopped, the animation can be restarted by calling `start()`.
        public func stop() {
            isRunning = false
        }
    }
}

