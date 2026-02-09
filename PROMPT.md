# Matrix Digital Rain - macOS Screensaver

Build a Matrix-style "digital rain" screensaver for macOS from scratch.

---

## ⛔ CRITICAL: NO SPACES IN PRODUCT_NAME

**PRODUCT_NAME must be `MatrixDigitalRain` - NEVER use spaces.**

```
❌ WRONG:  PRODUCT_NAME = "Matrix Digital Rain";   // BREAKS THE SCREENSAVER
❌ WRONG:  PRODUCT_NAME = Matrix Digital Rain;     // BREAKS THE SCREENSAVER
✅ CORRECT: PRODUCT_NAME = MatrixDigitalRain;       // THIS IS THE ONLY VALID FORMAT
```

Spaces in PRODUCT_NAME create a module name with underscores (`Matrix_Digital_Rain`), which breaks class lookup and causes the screensaver to show a black screen or crash.

---

## Project Overview

Create a native macOS screensaver (.saver bundle) that renders the iconic falling green characters effect from The Matrix movie. The screensaver must render in real-time using Core Graphics (no video files).

### Key Requirements

- **100% Swift** - Native macOS screensaver using ScreenSaverView
- **Real-time rendering** - Use Core Graphics/Core Text, no pre-rendered video
- **Lightweight** - Final bundle should be < 500KB
- **Compatible** - macOS 11.0 (Big Sur) and later
- **Both install modes work** - "Install for This User Only" AND "Install for All Users"

## Part 1: Xcode Project Setup

### Create Screen Saver Project

1. Create a new Xcode project using the **Screen Saver** template:
   - Product Name: `MatrixDigitalRain` (**NO SPACES** - this becomes the Swift module name)
   - Bundle Identifier: `com.cassmtnr.matrixdigitalrain`
   - Language: Swift
   - Deployment Target: macOS 11.0

2. The template creates a `MatrixDigitalRainView.swift` file - this is the main screensaver view.

### Naming Requirements Checklist

| Setting | Value | Notes |
|---------|-------|-------|
| PRODUCT_NAME | `MatrixDigitalRain` | **NO SPACES, NO QUOTES** |
| NSPrincipalClass | `MatrixDigitalRainView` | Simple class name |
| @objc annotation | `@objc(MatrixDigitalRainView)` | On the main view class |
| Bundle Identifier | `com.cassmtnr.matrixdigitalrain` | Lowercase, dots only |

**The main view class MUST include the @objc annotation:**
```swift
@objc(MatrixDigitalRainView)
class MatrixDigitalRainView: ScreenSaverView {
```

This exposes the class to Objective-C runtime with a predictable name that matches NSPrincipalClass.

### Project Structure

```
MatrixDigitalRain/
├── MatrixDigitalRain.xcodeproj/
├── MatrixDigitalRain/
│   ├── MatrixConfig.swift       # Configuration constants
│   ├── MatrixColumn.swift       # Falling column logic
│   ├── MatrixDigitalRainView.swift  # Main screensaver view (from template)
│   └── Info.plist               # Bundle metadata
├── MatrixDigitalRainTests/      # Unit tests
│   ├── MatrixColumnTests.swift
│   └── MatrixConfigTests.swift
├── docs/                        # GitHub Pages website
├── .github/workflows/           # CI/CD
├── README.md
└── PROMPT.md
```

## Part 2: Swift Implementation

### MatrixConfig.swift

Configuration constants for the Matrix effect:

```swift
import Foundation
import AppKit

struct MatrixConfig {
    static let fontSize: CGFloat = 18
    static let columnWidth: CGFloat = 18
    static let charChangeProb: Double = 0.02
    static let hue: CGFloat = 120  // Matrix green (degrees)
    static let fps: Double = 30
    static let minTrailLength: Int = 10
    static let maxTrailLength: Int = 31
    static let minSpeed: Double = 0.3
    static let maxSpeed: Double = 1.0

    // Character set: Katakana, Latin, Cyrillic, Korean, Greek, digits, symbols
    static let matrixChars: [Character] = Array(
        "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン" +
        "ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ" +
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
        "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ" +
        "가나다라마바사아자차카타파하" +
        "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ" +
        "0123456789" +
        ":<>*+=-@#$%&[?]{!}"
    )

    static func randomChar() -> Character {
        matrixChars[Int.random(in: 0..<matrixChars.count)]
    }
}
```

### MatrixColumn.swift

Represents a single falling column of characters:

```swift
import Foundation

class MatrixColumn {
    let columnIndex: Int
    private let numRows: Int
    private var chars: [Character]
    private var headY: Double
    private var speed: Double
    private var trailLength: Int

    init(columnIndex: Int, numRows: Int) {
        self.columnIndex = columnIndex
        self.numRows = numRows
        self.chars = (0..<numRows).map { _ in MatrixConfig.randomChar() }
        self.headY = Double.random(in: Double(-numRows)...0)
        self.speed = Double.random(in: MatrixConfig.minSpeed..<MatrixConfig.maxSpeed)
        self.trailLength = Int.random(in: MatrixConfig.minTrailLength..<MatrixConfig.maxTrailLength)
    }

    func update() {
        headY += speed

        // Reset when off screen
        if headY - Double(trailLength) > Double(numRows) {
            headY = Double.random(in: Double(-trailLength * 2)..<Double(-trailLength))
            speed = Double.random(in: MatrixConfig.minSpeed..<MatrixConfig.maxSpeed)
            trailLength = Int.random(in: MatrixConfig.minTrailLength..<MatrixConfig.maxTrailLength)
        }

        // Randomly mutate characters (glitch effect)
        for i in 0..<chars.count {
            if Double.random(in: 0..<1) < MatrixConfig.charChangeProb {
                chars[i] = MatrixConfig.randomChar()
            }
        }
    }

    func getBrightness(row: Int) -> Double {
        let distanceFromHead = headY - Double(row)
        if distanceFromHead < 0 || distanceFromHead > Double(trailLength) {
            return 0.0
        }
        if distanceFromHead < 1 {
            return 1.0  // Head is brightest (white)
        }
        return max(0, 1.0 - distanceFromHead / Double(trailLength))
    }

    func getChar(row: Int) -> Character {
        chars[row % chars.count]
    }
}
```

### MatrixDigitalRainView.swift

Main screensaver view - replace the template content:

```swift
import ScreenSaver

@objc(MatrixDigitalRainView)
class MatrixDigitalRainView: ScreenSaverView {
    private var columns: [MatrixColumn] = []
    private var numColumns: Int = 0
    private var numRows: Int = 0
    private var matrixFont: NSFont!

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        animationTimeInterval = 1.0 / MatrixConfig.fps
        matrixFont = NSFont.monospacedSystemFont(ofSize: MatrixConfig.fontSize, weight: .medium)
    }

    private func initializeColumns() {
        guard bounds.width > 0 && bounds.height > 0 else { return }
        numColumns = max(1, Int(bounds.width / MatrixConfig.columnWidth))
        numRows = max(1, Int(bounds.height / MatrixConfig.fontSize) + 5)
        columns = (0..<numColumns).map { MatrixColumn(columnIndex: $0, numRows: numRows) }
    }

    override func startAnimation() {
        super.startAnimation()
        if columns.isEmpty { initializeColumns() }
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    override func animateOneFrame() {
        if columns.isEmpty && bounds.width > 0 { initializeColumns() }
        for column in columns { column.update() }
        needsDisplay = true
    }

    override func draw(_ rect: NSRect) {
        // Black background
        NSColor.black.setFill()
        bounds.fill()

        guard !columns.isEmpty else { return }

        for column in columns {
            let x = CGFloat(column.columnIndex) * MatrixConfig.columnWidth

            for row in 0..<numRows {
                let brightness = column.getBrightness(row: row)
                guard brightness > 0 else { continue }

                let char = column.getChar(row: row)
                let y = bounds.height - CGFloat(row + 1) * MatrixConfig.fontSize

                let color: NSColor = brightness >= 0.95
                    ? .white
                    : NSColor(hue: MatrixConfig.hue / 360.0, saturation: 0.85, brightness: CGFloat(brightness), alpha: 1.0)

                let attributes: [NSAttributedString.Key: Any] = [.font: matrixFont!, .foregroundColor: color]
                String(char).draw(at: NSPoint(x: x, y: y), withAttributes: attributes)
            }
        }
    }

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
```

### Info.plist Requirements

Ensure Info.plist contains:

- `NSPrincipalClass`: `MatrixDigitalRainView` (simple class name - NOT module-qualified, because the class uses `@objc(MatrixDigitalRainView)`)
- `CFBundleIdentifier`: `com.cassmtnr.matrixdigitalrain`
- `LSMinimumSystemVersion`: `11.0`

## Part 3: Unit Tests

### MatrixColumnTests.swift

```swift
import XCTest
@testable import MatrixDigitalRain

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
```

### MatrixConfigTests.swift

```swift
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

    func testConfigValues() {
        XCTAssertEqual(MatrixConfig.fontSize, 18)
        XCTAssertEqual(MatrixConfig.fps, 30)
        XCTAssertEqual(MatrixConfig.hue, 120)
        XCTAssertLessThan(MatrixConfig.minSpeed, MatrixConfig.maxSpeed)
        XCTAssertLessThan(MatrixConfig.minTrailLength, MatrixConfig.maxTrailLength)
    }
}
```

## Part 4: GitHub Actions CI/CD

### .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    name: Build and Test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app

      - name: Build
        run: |
          xcodebuild -project MatrixDigitalRain.xcodeproj \
            -scheme MatrixDigitalRain \
            -configuration Release \
            -derivedDataPath build \
            build

      - name: Run Tests
        run: |
          xcodebuild -project MatrixDigitalRain.xcodeproj \
            -scheme MatrixDigitalRain \
            -configuration Debug \
            -derivedDataPath build \
            test

      - name: Package artifact
        run: |
          mkdir -p artifact
          cp -R "build/Build/Products/Release/Matrix Digital Rain.saver" artifact/

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: MatrixDigitalRain.saver
          path: artifact/
```

### .github/workflows/release.yml

```yaml
name: Release

on:
  release:
    types: [created]

jobs:
  build-and-upload:
    name: Build and Upload Release
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app

      - name: Build
        run: |
          xcodebuild -project MatrixDigitalRain.xcodeproj \
            -scheme MatrixDigitalRain \
            -configuration Release \
            -derivedDataPath build \
            build

      - name: Create zip
        run: |
          cd "build/Build/Products/Release"
          zip -r "MatrixDigitalRain.saver.zip" "Matrix Digital Rain.saver"
          mv "MatrixDigitalRain.saver.zip" "$GITHUB_WORKSPACE/"

      - name: Upload to Release
        uses: softprops/action-gh-release@v1
        with:
          files: MatrixDigitalRain.saver.zip
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Part 5: README.md

Create a comprehensive README with:

```markdown
# Matrix Digital Rain Screensaver

[![CI](https://github.com/cassmtnr/matrix-macos-screensaver/actions/workflows/ci.yml/badge.svg)](https://github.com/cassmtnr/matrix-macos-screensaver/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS_11+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)

A Matrix-style "digital rain" screensaver for macOS featuring real-time rendered falling green characters.

![Matrix Rain Preview](docs/matrix_preview.gif)

## Features

- 🎬 **Authentic Matrix effect** - Falling characters with glowing heads and fading trails
- 🌏 **Multi-script characters** - Japanese katakana, Latin, Cyrillic, Korean, Greek, symbols
- ⚡ **Real-time rendering** - Core Graphics powered, no video files
- 📦 **Lightweight** - ~300KB bundle size
- 🖥️ **Adaptive** - Automatically scales to any screen resolution
- ♾️ **Infinite duration** - No looping, runs forever

## Installation

### Download (Recommended)

1. Download `MatrixDigitalRain.saver.zip` from [Releases](https://github.com/cassmtnr/matrix-macos-screensaver/releases/latest)
2. Unzip and double-click `Matrix Digital Rain.saver`
3. Choose **Install for This User Only** or **Install for All Users**
4. Open **System Settings** → **Screen Saver** and select **Matrix Digital Rain**

### Build from Source

\`\`\`bash
git clone https://github.com/cassmtnr/matrix-macos-screensaver.git
cd matrix-macos-screensaver

xcodebuild -project MatrixDigitalRain.xcodeproj \
 -scheme MatrixDigitalRain \
 -configuration Release \
 -derivedDataPath build \
 build

# Install

open "build/Build/Products/Release/Matrix Digital Rain.saver"
\`\`\`

## Requirements

- macOS 11.0 (Big Sur) or later

## Support

If you enjoy this screensaver, consider [buying me a coffee](https://buymeacoffee.com/cassmtnr) ☕

## License

MIT License - feel free to use, modify, and distribute.
```

## Part 6: GitHub Pages (docs/)

### docs/index.html

Create a stylish landing page with:

1. **SEO optimization**:
   - Title: "Matrix Screensaver for macOS - Free Digital Rain Screen Saver"
   - Meta description targeting: matrix screensaver, macos screensaver, digital rain, free screensaver
   - Open Graph and Twitter card meta tags
   - JSON-LD structured data (SoftwareApplication schema)
   - Canonical URL

2. **Design**:
   - Black background with Matrix green (#00ff41) accents
   - Monospace font (JetBrains Mono)
   - Animated Matrix rain effect in background (canvas-based JavaScript)
   - CRT scanline overlay effect

3. **Content sections**:
   - Header with "MATRIX" title and "screensaver // macOS" tagline
   - Preview GIF
   - Download button linking to GitHub releases
   - Installation steps
   - Features grid
   - "Buy me a coffee" support link
   - Footer with GitHub link and MIT license

4. **Additional files**:
   - `docs/robots.txt` - Allow all crawlers
   - `docs/sitemap.xml` - Include main page URL
   - `docs/matrix_preview.gif` - Animated preview (create/capture separately)

### SEO JSON-LD Schema

```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Matrix Screensaver",
  "operatingSystem": "macOS",
  "applicationCategory": "UtilitiesApplication",
  "offers": { "@type": "Offer", "price": "0", "priceCurrency": "USD" },
  "description": "Free Matrix-style digital rain screensaver for macOS",
  "downloadUrl": "https://github.com/cassmtnr/matrix-macos-screensaver/releases/latest",
  "fileSize": "300KB",
  "softwareRequirements": "macOS 11.0 or later"
}
```

## Part 7: Additional Files

### .gitignore

```
# macOS
.DS_Store

# Xcode
build/
DerivedData/
*.xcuserstate
xcuserdata/

# Built bundles
*.saver

# IDE
.idea/
.vscode/
```

### LICENSE

MIT License (standard template)

## Build & Test Commands

```bash
# Build Release
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Release \
  -derivedDataPath build \
  build

# Run Tests
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Debug \
  test

# Clean
xcodebuild -project MatrixDigitalRain.xcodeproj clean
rm -rf build/
```

## Links

- **GitHub Repository**: https://github.com/cassmtnr/matrix-macos-screensaver
- **GitHub Pages**: https://cassmtnr.github.io/matrix-macos-screensaver/
- **Buy Me a Coffee**: https://buymeacoffee.com/cassmtnr

## Success Criteria

1. ✅ Screensaver builds without errors
2. ✅ Works with "Install for This User Only"
3. ✅ Works with "Install for All Users"
4. ✅ Thumbnail preview works in System Settings
5. ✅ Full screensaver animation works
6. ✅ All unit tests pass
7. ✅ CI pipeline passes
8. ✅ GitHub Pages site is live and SEO-optimized
9. ✅ Release workflow creates downloadable zip

---

## ⚠️ Verification Checklist (MUST RUN BEFORE COMPLETION)

**Do NOT just restore files from git. Always verify the following:**

### 1. PRODUCT_NAME Check
```bash
grep "PRODUCT_NAME" MatrixDigitalRain.xcodeproj/project.pbxproj
```
**Expected output:** `PRODUCT_NAME = MatrixDigitalRain;` (NO spaces, NO quotes around value)

If you see `"Matrix Digital Rain"` or any spaces, FIX IT IMMEDIATELY.

### 2. NSPrincipalClass Check
```bash
grep -A1 "NSPrincipalClass" MatrixDigitalRain/Info.plist
```
**Expected output:** `<string>MatrixDigitalRainView</string>`

### 3. @objc Annotation Check
```bash
grep "@objc" MatrixDigitalRain/MatrixDigitalRainView.swift
```
**Expected output:** `@objc(MatrixDigitalRainView)`

### 4. Build and Verify Module Name
```bash
xcodebuild -scheme MatrixDigitalRain -configuration Release build
nm build/Build/Products/Release/*.saver/Contents/MacOS/* | grep "OBJC_CLASS.*MatrixDigitalRainView"
```
**Expected output:** `_OBJC_CLASS_$_MatrixDigitalRainView` (no underscores in class name except the prefix)

### 5. Clean Old Builds
Remove any old builds with spaces in the name:
```bash
rm -rf "build/Build/Products/Release/Matrix Digital Rain.saver"*
rm -rf "build/Build/Products/Debug/Matrix Digital Rain.saver"*
```

### 6. Run Tests
```bash
xcodebuild -scheme MatrixDigitalRain test
```
All tests must pass.

**Only mark the task complete after ALL verifications pass.**
