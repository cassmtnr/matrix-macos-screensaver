import XCTest
@testable import MatrixDigitalRain

final class IntroSequenceTests: XCTestCase {

    func testStartsNotComplete() {
        let intro = IntroSequence()
        XCTAssertFalse(intro.isComplete)
    }

    func testCompletesAfterEnoughUpdates() {
        let intro = IntroSequence()

        // Run enough frames to complete the intro (generous upper bound)
        for _ in 0..<3000 {
            intro.update()
            if intro.isComplete { break }
        }

        XCTAssertTrue(intro.isComplete)
    }

    func testDoesNotCompleteImmediately() {
        let intro = IntroSequence()

        // A few frames should not be enough
        for _ in 0..<5 {
            intro.update()
        }

        XCTAssertFalse(intro.isComplete)
    }

    func testTotalFrameCountIsReasonable() {
        let intro = IntroSequence()
        var totalFrames = 0

        for i in 0..<3000 {
            intro.update()
            totalFrames = i + 1
            if intro.isComplete { break }
        }

        // At 30fps, ~37 seconds = ~1110 frames. Allow range 900-1400 for jitter.
        XCTAssertGreaterThan(totalFrames, 900, "Intro completed too quickly")
        XCTAssertLessThan(totalFrames, 1400, "Intro took too long")
    }

    func testResetAllowsReplay() {
        let intro = IntroSequence()

        // Complete the intro
        for _ in 0..<3000 {
            intro.update()
            if intro.isComplete { break }
        }
        XCTAssertTrue(intro.isComplete)

        // Reset and verify it starts over
        intro.reset()
        XCTAssertFalse(intro.isComplete)

        // Should complete again
        for _ in 0..<3000 {
            intro.update()
            if intro.isComplete { break }
        }
        XCTAssertTrue(intro.isComplete)
    }

    func testNoUpdatesAfterComplete() {
        let intro = IntroSequence()

        // Complete the intro
        for _ in 0..<3000 {
            intro.update()
            if intro.isComplete { break }
        }
        XCTAssertTrue(intro.isComplete)

        // Additional updates should keep it complete (no crash, no state change)
        intro.update()
        intro.update()
        XCTAssertTrue(intro.isComplete)
    }
}
