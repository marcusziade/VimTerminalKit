import Foundation

// Sources/VimTerminalKit/Models/Direction.swift

extension VimTerminalKit {
    /// Represents a directional movement in the terminal interface.
    ///
    /// Used to indicate the direction of navigation when handling both
    /// Vim-style (hjkl) and arrow key inputs.
    public enum Direction {
        /// Represents upward movement (k in Vim)
        case up

        /// Represents downward movement (j in Vim)
        case down

        /// Represents leftward movement (h in Vim)
        case left

        /// Represents rightward movement (l in Vim)
        case right
    }
}
