import XCTest
@testable import MatrixDigitalRain

final class IntroSequenceTests: XCTestCase {

    func testStartsNotComplete() {
        let intro = IntroSequence()
        XCTAssertFalse(intro.isComplete)
    }

    func testDoesNotCompleteImmediately() {
        let intro = IntroSequence()
        intro.update()
        intro.update()
        XCTAssertFalse(intro.isComplete)
    }

    func testCompletesAfterEnoughTime() {
        let intro = IntroSequence()

        // Simulate updates over enough wall-clock time for the intro to complete.
        // Total intro ~28s. We call update in a tight loop — wall-clock advances naturally.
        let deadline = Date().addingTimeInterval(60)
        while !intro.isComplete && Date() < deadline {
            intro.update()
        }

        XCTAssertTrue(intro.isComplete, "Intro should complete within 60s")
    }

    func testResetAllowsReplay() {
        let intro = IntroSequence()

        // Complete the intro
        let deadline1 = Date().addingTimeInterval(60)
        while !intro.isComplete && Date() < deadline1 {
            intro.update()
        }
        XCTAssertTrue(intro.isComplete)

        // Reset and verify it starts over
        intro.reset()
        XCTAssertFalse(intro.isComplete)

        // Should complete again
        let deadline2 = Date().addingTimeInterval(60)
        while !intro.isComplete && Date() < deadline2 {
            intro.update()
        }
        XCTAssertTrue(intro.isComplete)
    }

    func testNoUpdatesAfterComplete() {
        let intro = IntroSequence()

        // Complete the intro
        let deadline = Date().addingTimeInterval(60)
        while !intro.isComplete && Date() < deadline {
            intro.update()
        }
        XCTAssertTrue(intro.isComplete)

        // Additional updates should keep it complete (no crash, no state change)
        intro.update()
        intro.update()
        XCTAssertTrue(intro.isComplete)
    }
}
