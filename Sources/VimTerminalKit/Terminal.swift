import Foundation

extension VimTerminalKit {
    /// Provides terminal control and manipulation functionality.
    public enum Terminal {
        /// ANSI escape sequences for terminal control.
        public struct Control {
            /// Moves the cursor up one line
            public static let up = "\u{1B}[A"

            /// Moves the cursor down one line
            public static let down = "\u{1B}[B"

            /// Moves the cursor right one column
            public static let right = "\u{1B}[C"

            /// Moves the cursor left one column
            public static let left = "\u{1B}[D"

            /// Clears the current line
            public static let clearLine = "\u{1B}[2K"

            /// Clears the entire screen and moves cursor to home position
            public static let clearScreen = "\u{1B}[2J\u{1B}[H"

            /// Hides the terminal cursor
            public static let hideCursor = "\u{1B}[?25l"

            /// Shows the terminal cursor
            public static let showCursor = "\u{1B}[?25h"
        }

        /// Manages the terminal's raw mode state.
        public struct RawMode {
            /// Enables raw mode for immediate character input.
            ///
            /// In raw mode, input is processed immediately without waiting for Enter,
            /// and special characters (like Ctrl+C) are passed through uninterpreted.
            public static func enable() {
                var raw = termios()
                tcgetattr(STDIN_FILENO, &raw)
                raw.c_lflag &= ~UInt(ECHO | ICANON)
                tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
                print(Control.hideCursor)
            }

            /// Restores the terminal to its normal (cooked) mode.
            public static func disable() {
                var raw = termios()
                tcgetattr(STDIN_FILENO, &raw)
                raw.c_lflag |= UInt(ECHO | ICANON)
                tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
                print(Control.showCursor)
            }
        }

        /// Reads a single byte from standard input.
        ///
        /// - Returns: The byte read from input
        public static func readByte() -> UInt8 {
            var byte: UInt8 = 0
            _ = read(STDIN_FILENO, &byte, 1)
            return byte
        }
    }
}
