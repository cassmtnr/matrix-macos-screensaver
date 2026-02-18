---
paths: ["**/*.swift"]
description: Swift conventions for the Matrix Digital Rain screensaver
---

# Swift Conventions

## Language Version

Swift 5.0. No async/await, no Swift concurrency, no actors. Pure synchronous code.

## Access Control

- `private` for internal state and helper methods (default for most things)
- `private(set)` for properties that are read externally but set internally (e.g., `MatrixColumn.headY`)
- No explicit `internal` — it's the default and omitted
- `@objc(MatrixDigitalRainView)` on the main view class for Objective-C runtime visibility

## Type Patterns

- **Caseless enum for namespaces**: `enum MatrixConfig` with only `static` members — prevents instantiation. See `MatrixConfig.swift:8`.
- **`final class` for models**: `final class MatrixColumn`, `final class IntroSequence` — no inheritance needed, allows compiler optimizations.
- **`class` for the view**: `class MatrixDigitalRainView: ScreenSaverView` — must be a class to subclass `ScreenSaverView`.

## Naming

- Types: PascalCase (`MatrixColumn`, `IntroSequence`)
- Functions/methods: camelCase (`animateOneFrame()`, `buildGlyphCache()`)
- Properties: camelCase (`headY`, `trailLength`, `greenPalette`)
- Constants: camelCase static `let` on `MatrixConfig` (`MatrixConfig.fontSize`)
- Enum cases: camelCase (`case initialDelay`, `case typing(lineIndex: Int)`)

## Optionals

- Use `guard let` for early unwrapping with meaningful error handling
- Use `??` for fallback values (e.g., `NSFont(name:) ?? NSFont.monospacedSystemFont(...)`)
- Avoid force-unwrapping (`!`) except where failure is impossible or in test code

## Closures & Functional Patterns

- Use trailing closure syntax for single-closure parameters
- Use `map`, `filter`, `contains` where natural (see `MatrixConfig.matrixChars`)
- Prefer `for...in` loops for imperative mutation (see `MatrixColumn.update()`)

## CoreGraphics & CoreText

- Use `CGContext` directly, not `NSGraphicsContext` wrapper (except when bridging)
- Use `CTFontDrawGlyphs` for glyph rendering (not `NSAttributedString.draw`)
- Pre-compute `CGColor` objects — never allocate inside draw loops
- Use `CGColorSpaceCreateDeviceRGB()` — cached as a property, not per-frame

## Testing

- `@testable import MatrixDigitalRain` to access internal members
- `final class {Name}Tests: XCTestCase`
- `func test{Behavior}()` — descriptive names, no parameters
- Use `XCTAssert*` family, not `assert` or `precondition`
