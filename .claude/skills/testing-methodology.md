---
name: testing-methodology
description: AAA testing pattern with XCTest framework syntax
globs: ["**/*Tests.swift"]
---

# Testing Methodology

## Framework

This project uses **XCTest** with `@testable import MatrixDigitalRain`.

## Test File Conventions

- One test file per source file: `{ClassName}Tests.swift`
- Class: `final class {Name}Tests: XCTestCase`
- Methods: `func test{Behavior}()`
- Organize with `// MARK: -` sections matching the source file's structure

## AAA Pattern (Arrange, Act, Assert)

```swift
func testBrightnessReturnsZeroForRowsOutsideTrail() {
    // Arrange
    let column = MatrixColumn(columnIndex: 0, numRows: 60)

    // Act
    let brightness = column.brightness(atRow: 200)

    // Assert
    XCTAssertEqual(brightness, 0.0)
}
```

## Testing Patterns Found in This Codebase

### Config validation (MatrixConfigTests.swift)
Test that config values are within valid ranges:
```swift
func testPerCellMutationChanceIsValid() {
    XCTAssertGreaterThanOrEqual(MatrixConfig.perCellMutationChance, 0)
    XCTAssertLessThanOrEqual(MatrixConfig.perCellMutationChance, 1)
}
```

### Stateful objects with loop-based advancement (MatrixColumnTests.swift)
Advance state in loops and check invariants:
```swift
func testUpdateDoesNotCrash() {
    let column = MatrixColumn(columnIndex: 0, numRows: 60)
    for _ in 0..<1000 { column.update() }
}
```

### Wall-clock timing tests (IntroSequenceTests.swift)
Use deadlines for time-based state machines:
```swift
func testCompletesAfterEnoughTime() {
    let intro = IntroSequence()
    let deadline = Date().addingTimeInterval(60)
    while !intro.isComplete && Date() < deadline {
        intro.update()
    }
    XCTAssertTrue(intro.isComplete, "Intro should complete within 60s")
}
```

### View smoke tests (MatrixDigitalRainViewTests.swift)
Create views with `isPreview: true` and exercise lifecycle:
```swift
func testAnimateOneFrameDoesNotCrash() {
    guard let view = MatrixDigitalRainView(
        frame: NSRect(x: 0, y: 0, width: 1920, height: 1080),
        isPreview: true
    ) else {
        XCTFail("Failed to create view")
        return
    }
    view.startAnimation()
    for _ in 0..<100 { view.animateOneFrame() }
    view.stopAnimation()
}
```

### Draw smoke tests (IntroSequenceTests.swift)
Create a `CGContext` and call draw — success = no crash:
```swift
func testDrawDoesNotCrash() {
    let intro = IntroSequence()
    intro.update()
    guard let ctx = CGContext(
        data: nil, width: 320, height: 240,
        bitsPerComponent: 8, bytesPerRow: 320 * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
    ) else {
        XCTFail("Failed to create CGContext")
        return
    }
    let bounds = NSRect(x: 0, y: 0, width: 320, height: 240)
    intro.draw(in: ctx, bounds: bounds)
}
```

## Running Tests

```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug \
  -derivedDataPath build test
```

## Edge Cases to Cover

- Zero/negative bounds for views and columns
- Single-row columns (`numRows: 1`)
- Extreme delta-time values (very small, very large)
- Multiple reset cycles for stateful objects
- All 57 characters in the Matrix character set
- Boundary values for brightness (0.0, cutoff, threshold, 1.0)
