// Tests/VimTerminalKitTests/NavigatorTests.swift
import XCTest

@testable import VimTerminalKit

final class NavigatorTests: XCTestCase {
    var navigator: VimTerminalKit.Navigator!

    override func setUp() {
        super.setUp()
        // Create a navigator with 6 items in 2 columns (3 rows per column)
        navigator = VimTerminalKit.Navigator(itemCount: 6, columnsCount: 2)
    }

    func testInitialState() {
        XCTAssertEqual(navigator.selectedIndex, 0)
        XCTAssertEqual(navigator.selectedColumn, 0)
    }

    func testCustomInitialState() {
        let customNavigator = VimTerminalKit.Navigator(
            itemCount: 6,
            columnsCount: 2,
            initialIndex: 2,
            initialColumn: 1
        )
        XCTAssertEqual(customNavigator.selectedIndex, 2)
        XCTAssertEqual(customNavigator.selectedColumn, 1)
    }

    func testDownNavigation() {
        // First column navigation
        navigator.navigate(.vim(.down))
        XCTAssertEqual(navigator.selectedIndex, 1)

        navigator.navigate(.arrow(.down))
        XCTAssertEqual(navigator.selectedIndex, 2)

        // Wrapping to top
        navigator.navigate(.vim(.down))
        XCTAssertEqual(navigator.selectedIndex, 0)
    }

    func testUpNavigation() {
        // Start from bottom
        navigator.navigate(.vim(.down))
        navigator.navigate(.vim(.down))
        XCTAssertEqual(navigator.selectedIndex, 2)

        // Navigate up
        navigator.navigate(.vim(.up))
        XCTAssertEqual(navigator.selectedIndex, 1)

        // Wrap to bottom
        navigator.navigate(.vim(.up))
        navigator.navigate(.vim(.up))
        XCTAssertEqual(navigator.selectedIndex, 2)
    }

    func testColumnNavigation() {
        // Move to second column
        navigator.navigate(.vim(.right))
        XCTAssertEqual(navigator.selectedColumn, 1)
        XCTAssertEqual(navigator.selectedIndex, 3)

        // Move back to first column
        navigator.navigate(.vim(.left))
        XCTAssertEqual(navigator.selectedColumn, 0)
        XCTAssertEqual(navigator.selectedIndex, 0)
    }

    func testBoundaryConditions() {
        // Test single column
        let singleColumnNav = VimTerminalKit.Navigator(itemCount: 3, columnsCount: 1)
        singleColumnNav.navigate(.vim(.right))
        XCTAssertEqual(singleColumnNav.selectedColumn, 0)

        // Test empty navigator
        let emptyNav = VimTerminalKit.Navigator(itemCount: 0)
        emptyNav.navigate(.vim(.down))
        XCTAssertEqual(emptyNav.selectedIndex, 0)
    }
}
