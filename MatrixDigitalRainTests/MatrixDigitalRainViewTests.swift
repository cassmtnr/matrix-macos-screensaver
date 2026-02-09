import XCTest
import ScreenSaver
@testable import MatrixDigitalRain

final class MatrixDigitalRainViewTests: XCTestCase {
    private func makeView(width: CGFloat = 1920, height: CGFloat = 1080) -> MatrixDigitalRainView? {
        let frame = NSRect(x: 0, y: 0, width: width, height: height)
        return MatrixDigitalRainView(frame: frame, isPreview: true)
    }

    func testInitializationSucceeds() {
        let view = makeView()
        XCTAssertNotNil(view)
    }

    func testAnimationTimeInterval() {
        let view = makeView()
        XCTAssertNotNil(view)
        let expected = 1.0 / MatrixConfig.fps
        XCTAssertEqual(view!.animationTimeInterval, expected, accuracy: 0.001)
    }

    func testHasConfigureSheetReturnsFalse() {
        let view = makeView()
        XCTAssertNotNil(view)
        XCTAssertFalse(view!.hasConfigureSheet)
    }

    func testConfigureSheetReturnsNil() {
        let view = makeView()
        XCTAssertNotNil(view)
        XCTAssertNil(view!.configureSheet)
    }

    func testInitializationWithVariousFrameSizes() {
        // Small frame
        let small = makeView(width: 100, height: 100)
        XCTAssertNotNil(small)

        // Large frame
        let large = makeView(width: 3840, height: 2160)
        XCTAssertNotNil(large)

        // Standard 1080p
        let standard = makeView(width: 1920, height: 1080)
        XCTAssertNotNil(standard)
    }

    func testIsPreviewFlag() {
        let view = makeView()
        XCTAssertNotNil(view)
        XCTAssertTrue(view!.isPreview)
    }
}
