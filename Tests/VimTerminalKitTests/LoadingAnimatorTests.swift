import XCTest

@testable import VimTerminalKit

final class LoadingAnimatorTests: XCTestCase {
    func testAnimatorUpdates() async throws {
        var updateCount = 0
        var messages: [String] = []

        let animator = VimTerminalKit.LoadingAnimator(initialMessage: "Loading") { message in
            updateCount += 1
            messages.append(message)
        }

        animator.start()

        // Wait for a few animation frames
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        animator.stop()

        XCTAssertGreaterThan(updateCount, 0, "Animator should have triggered updates")
        XCTAssertGreaterThan(messages.count, 0, "Should have received multiple messages")

        // Verify that messages include animation frames
        XCTAssertTrue(messages.allSatisfy { $0.hasPrefix("Loading") })
        XCTAssertTrue(messages.contains { VimTerminalKit.LoadingAnimation.frames.contains(String($0.suffix(1))) })
    }
}
