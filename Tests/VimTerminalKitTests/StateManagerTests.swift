import XCTest

@testable import VimTerminalKit

final class StateManagerTests: XCTestCase {
    var stateManager: VimTerminalKit.StateManager!
    var updateCount: Int!
    var lastLoadingMessage: String!

    override func setUp() {
        super.setUp()
        updateCount = 0
        lastLoadingMessage = ""
        stateManager = VimTerminalKit.StateManager { [weak self] in
            self?.updateCount += 1
            self?.lastLoadingMessage = self?.stateManager.loadingMessage
        }
    }

    func testUIUpdates() async throws {
        // Create an expectation for async updates
        let expectation = XCTestExpectation(description: "Loading updates")

        // Start loading and wait for updates
        stateManager.startLoading(message: "Test loading")

        // Wait a short time for animation frames to process
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Verify that updates occurred
        XCTAssertTrue(stateManager.isLoading)
        XCTAssertNotEqual(lastLoadingMessage, "Test loading", "Loading message should include animation frame")
        XCTAssertGreaterThan(updateCount, 0, "UI should have been updated multiple times")

        // Stop loading and verify final state
        stateManager.stopLoading()
        XCTAssertFalse(stateManager.isLoading)

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testLoadingMessageUpdates() {
        stateManager.startLoading(message: "Initial message")
        XCTAssertTrue(stateManager.isLoading)

        stateManager.updateLoadingMessage("Updated message")
        XCTAssertEqual(stateManager.loadingMessage, "Updated message")
        XCTAssertGreaterThan(updateCount, 0)

        stateManager.stopLoading()
        XCTAssertFalse(stateManager.isLoading)
    }

    func testWithLoadingWrapper() async throws {
        var operationExecuted = false

        try await stateManager.withLoading(message: "Test operation") {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            operationExecuted = true
        }

        XCTAssertTrue(operationExecuted)
        XCTAssertFalse(stateManager.isLoading)
        XCTAssertGreaterThan(updateCount, 0)
    }
}

