import XCTest
@testable import MatrixDigitalRain

final class MatrixConfigTests: XCTestCase {
    func testRandomCharReturnsValidCharacter() {
        for _ in 0..<100 {
            let char = MatrixConfig.randomChar()
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char))
        }
    }

    func testCharacterSetNotEmpty() {
        XCTAssertFalse(MatrixConfig.matrixChars.isEmpty)
        XCTAssertEqual(MatrixConfig.matrixChars.count, 57)
    }

    func testCharacterSetContainsMatrixGlyphs() {
        let expected = "モエヤキオカケサスヨタワネヌナヒホアウセミラリツテニハソコシマムメー"
        for char in expected {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing glyph: \(char)")
        }
    }

    func testCharacterSetContainsDigits() {
        let digits = "01234579"
        for char in digits {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing digit: \(char)")
        }
    }

    func testCharacterSetContainsSymbols() {
        let symbols = ":<>*+|"
        for char in symbols {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing symbol: \(char)")
        }
    }

    func testConfigValues() {
        XCTAssertEqual(MatrixConfig.fontSize, 30)
        XCTAssertEqual(MatrixConfig.fps, 30)
        XCTAssertLessThan(MatrixConfig.minSpeed, MatrixConfig.maxSpeed)
        XCTAssertLessThan(MatrixConfig.minTrailLength, MatrixConfig.maxTrailLength)
    }

    func testColumnWidthSmallerThanOrEqualToFontSize() {
        XCTAssertLessThanOrEqual(MatrixConfig.columnWidth, MatrixConfig.fontSize)
    }

    func testAllConfigValuesPositive() {
        XCTAssertGreaterThan(MatrixConfig.fontSize, 0)
        XCTAssertGreaterThan(MatrixConfig.columnWidth, 0)
        XCTAssertGreaterThan(MatrixConfig.fps, 0)
        XCTAssertGreaterThan(MatrixConfig.minSpeed, 0)
        XCTAssertGreaterThan(MatrixConfig.maxSpeed, 0)
        XCTAssertGreaterThan(MatrixConfig.minTrailLength, 0)
        XCTAssertGreaterThan(MatrixConfig.maxTrailLength, 0)
    }

    func testCharChangeProbIsValid() {
        XCTAssertGreaterThanOrEqual(MatrixConfig.charChangeProb, 0)
        XCTAssertLessThanOrEqual(MatrixConfig.charChangeProb, 1)
    }

    func testFpsIsReasonable() {
        XCTAssertGreaterThan(MatrixConfig.fps, 0)
        XCTAssertLessThanOrEqual(MatrixConfig.fps, 120)
    }
}
