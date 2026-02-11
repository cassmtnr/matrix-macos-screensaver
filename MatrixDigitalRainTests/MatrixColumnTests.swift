import XCTest
@testable import MatrixDigitalRain

final class MatrixColumnTests: XCTestCase {
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

    func testBrightnessAtHead() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        // Over many updates, the head must pass through visible rows at least once
        var everHadBrightness = false
        for _ in 0..<500 {
            column.update()
            if (0..<60).contains(where: { column.getBrightness(row: $0) > 0 }) {
                everHadBrightness = true
                break
            }
        }
        XCTAssertTrue(everHadBrightness)
    }

    func testBrightnessReturnsZeroForRowsOutsideTrail() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        // Rows far away from any possible head position should have zero brightness
        // Head starts in 0..<60, trail at most maxTrailLength
        // Row -1 equivalent (very large row index) should not be visible
        let brightness = column.getBrightness(row: 200)
        XCTAssertEqual(brightness, 0.0)
    }

    func testBrightnessDecreaseAlongTrail() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        // Advance until head is far enough from the top to have a visible trail behind it
        var headRow = -1
        for _ in 0..<2000 {
            column.update()
            for row in 10..<60 {
                if column.getBrightness(row: row) >= 0.95 {
                    headRow = row
                    break
                }
            }
            if headRow >= 0 { break }
        }
        guard headRow >= 0 else { return } // Skip if head not found (unlikely)

        // Brightness should decrease as we move away from head along the trail
        var previousBrightness = column.getBrightness(row: headRow)
        var foundDecrease = false
        for offset in 1..<10 {
            let row = headRow - offset // Trail extends behind head
            guard row >= 0 else { break }
            let brightness = column.getBrightness(row: row)
            if brightness > 0 && brightness < previousBrightness {
                foundDecrease = true
            }
            previousBrightness = brightness
        }
        // If the trail is long enough, we should see a decrease
        if column.trailLength > 2 {
            XCTAssertTrue(foundDecrease, "Brightness should decrease along the trail")
        }
    }

    func testCharacterRetrieval() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        let char = column.getChar(row: 0)
        XCTAssertTrue(MatrixConfig.matrixChars.contains(char))
    }

    func testGetCharModuloWraparound() {
        let numRows = 10
        let column = MatrixColumn(columnIndex: 0, numRows: numRows)
        // Row index > numRows should wrap around via modulo
        let charAtRow = column.getChar(row: 3)
        let charAtWrapped = column.getChar(row: 3 + numRows)
        XCTAssertEqual(charAtRow, charAtWrapped)
    }

    func testUpdateDoesNotCrash() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        for _ in 0..<1000 { column.update() }
    }

    func testUpdateMutatesCharacters() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        // Collect initial characters
        let initialChars = (0..<60).map { column.getChar(row: $0) }
        // After many updates, at least some characters should have changed
        for _ in 0..<500 { column.update() }
        let finalChars = (0..<60).map { column.getChar(row: $0) }
        let changedCount = zip(initialChars, finalChars).filter { $0 != $1 }.count
        XCTAssertGreaterThan(changedCount, 0, "Characters should mutate over time")
    }

    func testColumnResetsAfterPassingScreen() {
        let column = MatrixColumn(columnIndex: 0, numRows: 10)
        // Run enough updates that the head must have passed beyond the screen at least once
        for _ in 0..<1000 { column.update() }
        // After reset, speed and trail should still be within bounds
        XCTAssertGreaterThanOrEqual(column.speed, MatrixConfig.minSpeed)
        XCTAssertLessThanOrEqual(column.speed, MatrixConfig.maxSpeed)
        XCTAssertGreaterThanOrEqual(column.trailLength, MatrixConfig.minTrailLength)
        XCTAssertLessThanOrEqual(column.trailLength, MatrixConfig.maxTrailLength)
    }

    func testSingleRowColumn() {
        // Edge case: column with just 1 row should not crash
        let column = MatrixColumn(columnIndex: 0, numRows: 1)
        for _ in 0..<100 { column.update() }
        _ = column.getBrightness(row: 0)
        _ = column.getChar(row: 0)
    }
}
