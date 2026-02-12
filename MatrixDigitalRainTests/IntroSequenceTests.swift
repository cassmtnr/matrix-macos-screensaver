import XCTest
@testable import MatrixDigitalRain

final class IntroSequenceTests: XCTestCase {

    // MARK: - State transitions

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

        // Tight loop calling update(). Wall-clock advances naturally.
        // Total intro is ~16s; we allow up to 60s as a generous deadline.
        let deadline = Date().addingTimeInterval(60)
        while !intro.isComplete && Date() < deadline {
            intro.update()
        }

        XCTAssertTrue(intro.isComplete, "Intro should complete within 60s")
    }

    func testResetAllowsReplay() {
        let intro = IntroSequence()

        let deadline1 = Date().addingTimeInterval(60)
        while !intro.isComplete && Date() < deadline1 {
            intro.update()
        }
        XCTAssertTrue(intro.isComplete)

        // Reset and verify it starts over
        intro.reset()
        XCTAssertFalse(intro.isComplete)

        let deadline2 = Date().addingTimeInterval(60)
        while !intro.isComplete && Date() < deadline2 {
            intro.update()
        }
        XCTAssertTrue(intro.isComplete)
    }

    func testNoUpdatesAfterComplete() {
        let intro = IntroSequence()

        let deadline = Date().addingTimeInterval(60)
        while !intro.isComplete && Date() < deadline {
            intro.update()
        }
        XCTAssertTrue(intro.isComplete)

        // Additional updates should not crash or change state
        intro.update()
        intro.update()
        XCTAssertTrue(intro.isComplete)
    }

    // MARK: - Draw smoke test

    func testDrawDoesNotCrash() {
        let intro = IntroSequence()
        intro.update()

        // Create a small bitmap context and draw into it
        let width = 320, height = 240
        guard let ctx = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            XCTFail("Failed to create CGContext")
            return
        }

        let bounds = NSRect(x: 0, y: 0, width: width, height: height)
        intro.draw(in: ctx, bounds: bounds)
        // No crash = success
    }
}
