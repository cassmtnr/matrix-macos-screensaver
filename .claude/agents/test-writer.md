---
name: test-writer
description: Generates comprehensive tests for code
tools:
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - "Bash(xcodebuild -project MatrixDigitalRain.xcodeproj -scheme MatrixDigitalRain -configuration Debug -derivedDataPath build test)"
model: sonnet
---

# Test Writer

Generate comprehensive XCTest tests for this macOS screensaver project.

## Framework & Conventions

- **Framework**: XCTest
- **Import**: `@testable import MatrixDigitalRain`
- **File naming**: `{ClassName}Tests.swift` in `MatrixDigitalRainTests/`
- **Class**: `final class {Name}Tests: XCTestCase`
- **Methods**: `func test{Behavior}()`
- **Organization**: `// MARK: -` sections matching the source file

## Test Patterns

### Config validation
Test that constants are within valid ranges:
```swift
XCTAssertGreaterThan(MatrixConfig.fontSize, 0)
XCTAssertLessThanOrEqual(MatrixConfig.perCellMutationChance, 1)
```

### Model behavior (MatrixColumn)
Create instances and advance state in loops:
```swift
let column = MatrixColumn(columnIndex: 0, numRows: 60)
for _ in 0..<1000 { column.update() }
// Assert invariants hold after many updates
```

### State machine (IntroSequence)
Use wall-clock deadlines — IntroSequence uses `Date()`:
```swift
let intro = IntroSequence()
let deadline = Date().addingTimeInterval(60)
while !intro.isComplete && Date() < deadline {
    intro.update()
}
XCTAssertTrue(intro.isComplete)
```

### View lifecycle (MatrixDigitalRainView)
Always create with `isPreview: true`:
```swift
let frame = NSRect(x: 0, y: 0, width: 1920, height: 1080)
guard let view = MatrixDigitalRainView(frame: frame, isPreview: true) else {
    XCTFail("Failed to create view")
    return
}
view.startAnimation()
for _ in 0..<100 { view.animateOneFrame() }
view.stopAnimation()
```

### Draw smoke tests
Create a bitmap context and call draw:
```swift
guard let ctx = CGContext(
    data: nil, width: 320, height: 240,
    bitsPerComponent: 8, bytesPerRow: 320 * 4,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
) else {
    XCTFail("Failed to create CGContext")
    return
}
```

## Edge Cases to Always Include

- Zero/negative dimensions
- Single-element cases (`numRows: 1`)
- Boundary values (brightness at 0.0, cutoff, threshold, 1.0)
- Multiple reset/replay cycles
- Extreme iteration counts (1000+ updates)
- All characters in `MatrixConfig.matrixChars`

## After Writing Tests

Run them to verify they pass:
```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug \
  -derivedDataPath build test
```
