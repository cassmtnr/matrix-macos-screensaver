import XCTest

final class MatrixConfigTests: XCTestCase {
    func testRandomCharReturnsValidCharacter() {
        for _ in 0..<100 {
            let char = MatrixConfig.randomChar()
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char))
        }
    }

    func testCharacterSetNotEmpty() {
        XCTAssertFalse(MatrixConfig.matrixChars.isEmpty)
        XCTAssertGreaterThan(MatrixConfig.matrixChars.count, 100)
    }

    func testConfigValues() {
        XCTAssertEqual(MatrixConfig.fontSize, 18)
        XCTAssertEqual(MatrixConfig.fps, 30)
        XCTAssertEqual(MatrixConfig.hue, 120)
        XCTAssertLessThan(MatrixConfig.minSpeed, MatrixConfig.maxSpeed)
        XCTAssertLessThan(MatrixConfig.minTrailLength, MatrixConfig.maxTrailLength)
    }
}
