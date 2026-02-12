import XCTest
@testable import MatrixDigitalRain

final class MatrixConfigTests: XCTestCase {

    // MARK: - Character set

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

    // MARK: - Rain config values

    func testConfigValues() {
        XCTAssertEqual(MatrixConfig.fontSize, 20)
        XCTAssertEqual(MatrixConfig.fps, 30)
        XCTAssertLessThan(MatrixConfig.minSpeed, MatrixConfig.maxSpeed)
        XCTAssertLessThan(MatrixConfig.minTrailLength, MatrixConfig.maxTrailLength)
        XCTAssertGreaterThan(MatrixConfig.maxColumnStaggerDelay, 0)
    }

    func testColumnWidthGreaterThanOrEqualToFontSize() {
        XCTAssertGreaterThanOrEqual(MatrixConfig.columnWidth, MatrixConfig.fontSize)
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

    func testPerCellMutationChanceIsValid() {
        XCTAssertGreaterThanOrEqual(MatrixConfig.perCellMutationChance, 0)
        XCTAssertLessThanOrEqual(MatrixConfig.perCellMutationChance, 1)
    }

    func testHeadBrightnessThresholdIsValid() {
        XCTAssertGreaterThan(MatrixConfig.headBrightnessThreshold, 0)
        XCTAssertLessThanOrEqual(MatrixConfig.headBrightnessThreshold, 1)
    }

    func testFpsIsReasonable() {
        XCTAssertGreaterThan(MatrixConfig.fps, 0)
        XCTAssertLessThanOrEqual(MatrixConfig.fps, 120)
    }

    // MARK: - Intro config values

    func testIntroConfigValues() {
        // Lines are non-empty
        XCTAssertFalse(MatrixConfig.introLines.isEmpty)
        for line in MatrixConfig.introLines {
            XCTAssertFalse(line.text.isEmpty, "Intro line text should not be empty")
            XCTAssertGreaterThan(line.pauseDuration, 0, "Pause duration should be positive")
        }

        // Timing values are positive
        XCTAssertGreaterThan(MatrixConfig.introInitialDelay, 0)
        XCTAssertGreaterThan(MatrixConfig.introTypingSpeed, 0)
        XCTAssertGreaterThanOrEqual(MatrixConfig.introTypingJitter, 0)
        XCTAssertGreaterThan(MatrixConfig.introCursorBlinkRate, 0)

        // Layout values are positive
        XCTAssertGreaterThan(MatrixConfig.introPadding, 0)
        XCTAssertGreaterThan(MatrixConfig.introLineHeightMultiplier, 0)

        // Font size is reasonable
        XCTAssertGreaterThan(MatrixConfig.introFontSize, 0)
        XCTAssertLessThanOrEqual(MatrixConfig.introFontSize, 48)
    }

    func testIntroLinesContainAtLeastOneInstantLine() {
        let hasInstant = MatrixConfig.introLines.contains { $0.appearsInstantly }
        XCTAssertTrue(hasInstant, "At least one intro line should appear instantly")
    }
}
