import XCTest
@testable import MatrixDigitalRain

final class MatrixColumnTests: XCTestCase {

    // MARK: - Initialization

    func testInitialization() {
        let column = MatrixColumn(columnIndex: 5, numRows: 60)
        XCTAssertEqual(column.columnIndex, 5)
    }

    func testInitializationSpeedWithinBounds() {
        for _ in 0..<50 {
            let column = MatrixColumn(columnIndex: 0, numRows: 60)
            XCTAssertGreaterThanOrEqual(column.speed, MatrixConfig.minSpeed)
            XCTAssertLessThanOrEqual(column.speed, MatrixConfig.maxSpeed)
        }
    }

    func testInitializationTrailLengthWithinBounds() {
        for _ in 0..<50 {
            let column = MatrixColumn(columnIndex: 0, numRows: 60)
            XCTAssertGreaterThanOrEqual(column.trailLength, MatrixConfig.minTrailLength)
            XCTAssertLessThanOrEqual(column.trailLength, MatrixConfig.maxTrailLength)
        }
    }

    // MARK: - Brightness

    func testBrightnessAtHead() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        // Over many updates, the head must pass through visible rows at least once
        var everHadBrightness = false
        for _ in 0..<500 {
            column.update()
            if (0..<60).contains(where: { column.brightness(atRow: $0) > 0 }) {
                everHadBrightness = true
                break
            }
        }
        XCTAssertTrue(everHadBrightness)
    }

    func testBrightnessReturnsZeroForRowsOutsideTrail() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        let brightness = column.brightness(atRow: 200)
        XCTAssertEqual(brightness, 0.0)
    }

    func testBrightnessDecreaseAlongTrail() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        // Advance until head is far enough from the top to have a visible trail
        var headRow = -1
        for _ in 0..<2000 {
            column.update()
            for row in 10..<60 {
                if column.brightness(atRow: row) >= 0.95 {
                    headRow = row
                    break
                }
            }
            if headRow >= 0 { break }
        }
        guard headRow >= 0 else { return }

        // Brightness should decrease as we move away from head along the trail
        var previousBrightness = column.brightness(atRow: headRow)
        var foundDecrease = false
        for offset in 1..<10 {
            let row = headRow - offset
            guard row >= 0 else { break }
            let brightness = column.brightness(atRow: row)
            if brightness > 0 && brightness < previousBrightness {
                foundDecrease = true
            }
            previousBrightness = brightness
        }
        if column.trailLength > 2 {
            XCTAssertTrue(foundDecrease, "Brightness should decrease along the trail")
        }
    }

    // MARK: - Characters

    func testCharacterRetrieval() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        let char = column.character(atRow: 0)
        XCTAssertTrue(MatrixConfig.matrixChars.contains(char))
    }

    func testCharacterModuloWraparound() {
        let numRows = 10
        let column = MatrixColumn(columnIndex: 0, numRows: numRows)
        let charAtRow = column.character(atRow: 3)
        let charAtWrapped = column.character(atRow: 3 + numRows)
        XCTAssertEqual(charAtRow, charAtWrapped)
    }

    // MARK: - Update behavior

    func testUpdateDoesNotCrash() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        for _ in 0..<1000 { column.update() }
    }

    func testUpdateMutatesCharacters() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        let initialChars = (0..<60).map { column.character(atRow: $0) }
        for _ in 0..<500 { column.update() }
        let finalChars = (0..<60).map { column.character(atRow: $0) }
        let changedCount = zip(initialChars, finalChars).filter { $0 != $1 }.count
        XCTAssertGreaterThan(changedCount, 0, "Characters should mutate over time")
    }

    func testColumnResetsAfterPassingScreen() {
        let column = MatrixColumn(columnIndex: 0, numRows: 10)
        for _ in 0..<1000 { column.update() }
        // After reset, speed and trail should still be within bounds
        XCTAssertGreaterThanOrEqual(column.speed, MatrixConfig.minSpeed)
        XCTAssertLessThanOrEqual(column.speed, MatrixConfig.maxSpeed)
        XCTAssertGreaterThanOrEqual(column.trailLength, MatrixConfig.minTrailLength)
        XCTAssertLessThanOrEqual(column.trailLength, MatrixConfig.maxTrailLength)
    }

    func testSingleRowColumn() {
        let column = MatrixColumn(columnIndex: 0, numRows: 1)
        for _ in 0..<100 { column.update() }
        _ = column.brightness(atRow: 0)
        _ = column.character(atRow: 0)
    }
}
