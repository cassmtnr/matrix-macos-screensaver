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
        XCTAssertGreaterThan(MatrixConfig.matrixChars.count, 100)
    }

    func testCharacterSetContainsKatakana() {
        let katakana = "アイウエオ"
        for char in katakana {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing katakana: \(char)")
        }
    }

    func testCharacterSetContainsLatin() {
        let latin = "ABCXYZ"
        for char in latin {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing latin: \(char)")
        }
    }

    func testCharacterSetContainsCyrillic() {
        let cyrillic = "АБВ"
        for char in cyrillic {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing cyrillic: \(char)")
        }
    }

    func testCharacterSetContainsKorean() {
        let korean = "가나다"
        for char in korean {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing korean: \(char)")
        }
    }

    func testCharacterSetContainsGreek() {
        let greek = "ΑΒΓ"
        for char in greek {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing greek: \(char)")
        }
    }

    func testCharacterSetContainsDigits() {
        let digits = "0123456789"
        for char in digits {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing digit: \(char)")
        }
    }

    func testCharacterSetContainsSymbols() {
        let symbols = ":<>*+-"
        for char in symbols {
            XCTAssertTrue(MatrixConfig.matrixChars.contains(char), "Missing symbol: \(char)")
        }
    }

    func testConfigValues() {
        XCTAssertEqual(MatrixConfig.fontSize, 18)
        XCTAssertEqual(MatrixConfig.fps, 30)
        XCTAssertEqual(MatrixConfig.hue, 120)
        XCTAssertLessThan(MatrixConfig.minSpeed, MatrixConfig.maxSpeed)
        XCTAssertLessThan(MatrixConfig.minTrailLength, MatrixConfig.maxTrailLength)
    }

    func testColumnWidthEqualsFontSize() {
        XCTAssertEqual(MatrixConfig.columnWidth, MatrixConfig.fontSize)
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

    func testHueIsValidDegree() {
        XCTAssertGreaterThanOrEqual(MatrixConfig.hue, 0)
        XCTAssertLessThanOrEqual(MatrixConfig.hue, 360)
    }

    func testFpsIsReasonable() {
        XCTAssertGreaterThan(MatrixConfig.fps, 0)
        XCTAssertLessThanOrEqual(MatrixConfig.fps, 120)
    }
}
