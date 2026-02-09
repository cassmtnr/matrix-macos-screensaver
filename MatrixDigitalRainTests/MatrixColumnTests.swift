import XCTest

final class MatrixColumnTests: XCTestCase {
    func testInitialization() {
        let column = MatrixColumn(columnIndex: 5, numRows: 60)
        XCTAssertEqual(column.columnIndex, 5)
    }

    func testBrightnessAtHead() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        // After many updates, head should be visible somewhere
        for _ in 0..<100 { column.update() }
        // At least one row should have brightness > 0
        let hasBrightness = (0..<60).contains { column.getBrightness(row: $0) > 0 }
        XCTAssertTrue(hasBrightness)
    }

    func testCharacterRetrieval() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        let char = column.getChar(row: 0)
        XCTAssertTrue(MatrixConfig.matrixChars.contains(char))
    }

    func testUpdateDoesNotCrash() {
        let column = MatrixColumn(columnIndex: 0, numRows: 60)
        for _ in 0..<1000 { column.update() }
    }
}
