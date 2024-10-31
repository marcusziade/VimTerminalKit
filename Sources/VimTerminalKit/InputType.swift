import Foundation

extension VimTerminalKit {
    /// Represents different types of input that can be received from the terminal.
    ///
    /// This enum provides a type-safe way to handle both Vim-style and conventional
    /// terminal inputs.
    public enum InputType {
        /// A Vim-style navigation input (hjkl keys)
        case vim(Direction)
        /// An arrow key navigation input
        case arrow(Direction)
        /// The Enter key
        case enter
        /// The Space key
        case space
        /// The Backspace key
        case backspace
        /// The quit command (q or Q)
        case quit
        /// An unrecognized or unsupported input
        case unknown
    }
}
