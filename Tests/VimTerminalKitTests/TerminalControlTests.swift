import XCTest

@testable import VimTerminalKit

final class TerminalControlTests: XCTestCase {
    func testControlSequences() {
        XCTAssertEqual(VimTerminalKit.Terminal.Control.up, "\u{1B}[A")
        XCTAssertEqual(VimTerminalKit.Terminal.Control.down, "\u{1B}[B")
        XCTAssertEqual(VimTerminalKit.Terminal.Control.right, "\u{1B}[C")
        XCTAssertEqual(VimTerminalKit.Terminal.Control.left, "\u{1B}[D")
        XCTAssertEqual(VimTerminalKit.Terminal.Control.clearLine, "\u{1B}[2K")
        XCTAssertEqual(VimTerminalKit.Terminal.Control.clearScreen, "\u{1B}[2J\u{1B}[H")
        XCTAssertEqual(VimTerminalKit.Terminal.Control.hideCursor, "\u{1B}[?25l")
        XCTAssertEqual(VimTerminalKit.Terminal.Control.showCursor, "\u{1B}[?25h")
    }
}
