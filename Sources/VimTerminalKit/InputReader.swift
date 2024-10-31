import Foundation

extension VimTerminalKit {
    /// Provides functionality for reading and interpreting terminal input.
    ///
    /// `InputReader` handles both Vim-style navigation keys and conventional
    /// terminal inputs, converting raw byte input into semantic `InputType` values.
    public struct InputReader {
        /// Reads and interprets a single input from the terminal.
        ///
        /// This method blocks until input is available and returns an `InputType`
        /// representing the semantic meaning of the input.
        ///
        /// - Returns: An `InputType` value representing the input received
        ///
        /// Example:
        /// ```swift
        /// while true {
        ///     switch InputReader.getInput() {
        ///     case .vim(.up):
        ///         print("Vim up key (k) pressed")
        ///     case .arrow(.down):
        ///         print("Down arrow key pressed")
        ///     case .quit:
        ///         return
        ///     default:
        ///         break
        ///     }
        /// }
        /// ```
        public static func getInput() -> InputType {
            let byte = Terminal.readByte()

            switch byte {
            case 0x1B:  // Escape sequence for arrow keys
                let _ = Terminal.readByte()  // Skip [
                switch Terminal.readByte() {
                case 0x41: return .arrow(.up)
                case 0x42: return .arrow(.down)
                case 0x43: return .arrow(.right)
                case 0x44: return .arrow(.left)
                default: return .unknown
                }
            case 0x6B: return .vim(.up)  // k
            case 0x6A: return .vim(.down)  // j
            case 0x6C: return .vim(.right)  // l
            case 0x68: return .vim(.left)  // h
            case 0x0A, 0x0D: return .enter
            case 0x20: return .space
            case 0x71, 0x51: return .quit  // q or Q
            default: return .unknown
            }
        }
    }
}
