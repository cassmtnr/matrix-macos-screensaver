# Matrix Digital Rain Screensaver

> A Matrix-style screensaver for macOS featuring a personalized "Wake up, Neo..." intro sequence and real-time falling green characters.

## Overview

This is a native macOS screensaver bundle (`.saver`) built with Swift and the ScreenSaver framework. It displays a personalized typing intro sequence ("Wake up, \<your name\>...") followed by falling Matrix digital rain using a custom 57-glyph font. The screensaver is frame-rate independent, scales to any display resolution, and ships as a single `.saver` bundle users install via System Settings.

## Architecture

The project follows a simple layered architecture with clear separation of concerns:

- **Config layer** (`MatrixConfig`) — Caseless enum acting as a namespace for all tunable constants
- **Model layer** (`MatrixColumn`) — Individual falling column logic with position, speed, trail, and character mutation
- **State machine** (`IntroSequence`) — Drives the "Wake up, Neo..." typing animation through phases: `initialDelay → typing → pause → done`
- **View layer** (`MatrixDigitalRainView`) — `ScreenSaverView` subclass that orchestrates intro and rain, handles font registration, glyph caching, and Core Graphics rendering

### Directory Structure

```
matrix-savescreen/
├── MatrixDigitalRain/                  # Source code (screensaver bundle target)
│   ├── MatrixConfig.swift              # All tunable constants (caseless enum namespace)
│   ├── MatrixColumn.swift              # Single falling column model
│   ├── IntroSequence.swift             # "Wake up..." intro state machine
│   ├── MatrixDigitalRainView.swift     # Main ScreenSaverView subclass
│   ├── Matrix-Code.ttf                 # Custom font (57 glyphs)
│   └── Info.plist                      # Bundle metadata
├── MatrixDigitalRainTests/             # XCTest unit tests
│   ├── MatrixConfigTests.swift         # Config value validation
│   ├── MatrixColumnTests.swift         # Column behavior tests
│   ├── IntroSequenceTests.swift        # Intro state machine tests
│   └── MatrixDigitalRainViewTests.swift # View lifecycle smoke tests
├── MatrixDigitalRain.xcodeproj/        # Xcode project (two targets: bundle + tests)
├── docs/                               # GitHub Pages site + preview GIF
├── preview.swift                       # Standalone preview runner (Cmd+Q to quit)
├── generate_preview.swift              # Headless GIF generator (requires ffmpeg)
├── .github/workflows/
│   ├── ci.yml                          # Build + test on push to develop / PR to main
│   └── release.yml                     # Build + test + release + GIF gen on push to main
└── .claude/                            # Claude Code configuration
```

### Data Flow

1. macOS ScreenSaver framework instantiates `MatrixDigitalRainView` and calls `startAnimation()`
2. `animateOneFrame()` is called at ~30fps by the framework
3. During intro: `IntroSequence.update()` advances a wall-clock-based state machine through typing phases
4. Once intro completes (`isComplete == true`): each `MatrixColumn.update(deltaTime:)` advances column positions using real elapsed time
5. `draw(_:)` renders either the intro (CRT-style text with scanlines and glow) or the rain (glyph-cached characters with a pre-computed 256-color green palette and phosphor glow via transparency layers)

### Key Files

| File | Purpose |
|------|---------|
| `MatrixDigitalRain/MatrixConfig.swift` | All constants — change behavior here first |
| `MatrixDigitalRain/MatrixDigitalRainView.swift` | Entry point: font registration, column layout, animation loop, drawing |
| `MatrixDigitalRain/IntroSequence.swift` | Intro state machine with wall-clock timing |
| `MatrixDigitalRain/MatrixColumn.swift` | Column model: position, speed, trail, mutation |
| `MatrixDigitalRain/Info.plist` | Bundle config — `NSPrincipalClass` must be `MatrixDigitalRainView` |
| `preview.swift` | Run screensaver in a window for development |
| `generate_preview.swift` | Headless GIF capture for README/releases |

## Tech Stack

| Category | Technology | Notes |
|----------|-----------|-------|
| Language | Swift 5.0 | No Swift concurrency or async/await; pure synchronous code |
| Framework | ScreenSaver (AppKit) | Subclass of `ScreenSaverView`; `animateOneFrame()` driven by framework |
| Rendering | Core Graphics + CoreText | Direct `CGContext` drawing; `CTFontDrawGlyphs` for fast glyph rendering |
| Font | Matrix-Code.ttf | Custom 57-glyph font registered at runtime via `CTFontManagerRegisterFontsForURL` |
| Build System | Xcode / xcodebuild | `.xcodeproj` with two targets: bundle + unit tests |
| Testing | XCTest | Unit tests for config, column, intro, and view |
| CI/CD | GitHub Actions | `ci.yml` (develop/PR) and `release.yml` (main) |
| Deployment Target | macOS 11.0+ | Set in Xcode project build settings |
| Bundle ID | `com.cassmtnr.matrixdigitalrain` | Produces `MatrixDigitalRain.saver` |
| License | MIT | |

## Development Setup

### Prerequisites

- macOS 11.0+
- Xcode 15+ (for building)
- ffmpeg (optional, for GIF generation: `brew install ffmpeg`)

### Getting Started

```bash
# Build the screensaver bundle
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Release \
  -derivedDataPath build \
  build

# Preview in a window (Cmd+Q to quit)
swift preview.swift

# Install the built screensaver
open build/Build/Products/Release/MatrixDigitalRain.saver
```

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `MATRIX_INTRO_NAME` | Override the intro name (defaults to system user's first name, then "Neo") | `Neo` |

## Common Commands

```bash
# Build (Release)
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Release \
  -derivedDataPath build build

# Run tests (Debug)
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug \
  -derivedDataPath build test

# Preview in fullscreen window
swift preview.swift

# Preview with auto-quit after N seconds
swift preview.swift --duration 30

# Generate preview GIF (requires ffmpeg + built bundle)
swift generate_preview.swift --output docs/matrix_preview.gif

# Install screensaver
open build/Build/Products/Release/MatrixDigitalRain.saver
```

## Code Conventions

### Naming

- **Files**: PascalCase matching the primary type (`MatrixColumn.swift` for `class MatrixColumn`)
- **Types**: PascalCase (`MatrixColumn`, `IntroSequence`, `MatrixConfig`)
- **Functions/Properties**: camelCase (`animateOneFrame()`, `headBrightnessThreshold`)
- **Constants**: camelCase static properties on `MatrixConfig` enum (`MatrixConfig.fontSize`)
- **Tests**: `{ClassName}Tests.swift` with `test{Behavior}()` method names

### Patterns to Follow

- **Constants as caseless enum namespace** — All tunable values live in `MatrixConfig` as static properties. Never scatter magic numbers in other files. See `MatrixConfig.swift:8`.
- **`// MARK: -` sections** — Every file organizes code with MARK comments: Properties, Initialization, Update, Draw, etc. See `MatrixColumn.swift:12` and `MatrixDigitalRainView.swift:19`.
- **Wall-clock timing for intro, delta-time for rain** — The intro uses `Date()` for consistent real-world speed. The rain uses elapsed-time deltas passed to `update(deltaTime:)`. See `IntroSequence.swift:57` and `MatrixColumn.swift:43`.
- **Pre-computed resources** — Font glyphs are cached at init (`buildGlyphCache()`), colors are pre-computed into a 256-entry palette (`buildGreenPalette()`). Never allocate per-frame. See `MatrixDigitalRainView.swift:86-104`.
- **`///` documentation comments** — All public types and methods have `///` documentation comments explaining purpose and behavior.

### Anti-Patterns to Avoid

- **Frame-count-based timing** — Never count frames to time events. The ScreenSaver framework provides variable frame rates. Use `Date()` or delta-time.
- **Per-frame allocations** — Never create `CGColor`, `CTFont`, or glyph lookups inside the draw loop. Pre-compute and cache at initialization.
- **Magic numbers in drawing code** — All constants belong in `MatrixConfig`. The rendering code should reference config values, not inline numbers.
- **Modifying `Info.plist` NSPrincipalClass** — Must remain `MatrixDigitalRainView` (without module prefix) for the ScreenSaver framework to load it. The `@objc(MatrixDigitalRainView)` annotation on the class must match.

## Testing

### Running Tests

```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Debug \
  -derivedDataPath build \
  test
```

### Writing Tests

- Tests live in `MatrixDigitalRainTests/` with one file per source file
- Import the module with `@testable import MatrixDigitalRain`
- Follow existing patterns: `final class {Name}Tests: XCTestCase` with `func test{Behavior}()`
- For stateful objects (columns, intro), advance state in loops and check invariants
- Intro tests use wall-clock deadlines (up to 60s) since `IntroSequence` uses `Date()`
- View tests create views with `MatrixDigitalRainView(frame:isPreview:)` — always use `isPreview: true` in tests
- Draw smoke tests create a `CGContext` and call `draw(in:bounds:)` — success = no crash

## Git Workflow

- **`develop` branch** — Active development; CI runs on push
- **`main` branch** — Stable releases; CI runs on PR, release workflow runs on push
- **Release process** — Pushing to `main` triggers automatic version bump (patch), GitHub Release creation with `.saver.zip`, and preview GIF regeneration
- **Conventional commits** — Use `feat:`, `fix:`, `chore:`, etc. prefixes

## Gotchas & Important Notes

1. **The `.saver` bundle is not code-signed** — Users must run `xattr -cr` to remove quarantine after downloading from GitHub Releases. Building from source avoids this.
2. **`@objc(MatrixDigitalRainView)` is required** — The ScreenSaver framework loads the principal class by name from `Info.plist`. The `@objc` annotation ensures the class is visible to Objective-C runtime with the exact name `MatrixDigitalRainView` (no module prefix).
3. **Font registration is process-scoped** — `CTFontManagerRegisterFontsForURL` with `.process` scope means the Matrix-Code font is only available within the screensaver process. It's guarded by a static `fontRegistered` flag to register only once.
4. **`preview.swift` requires a built bundle** — It loads `build/Build/Products/Release/MatrixDigitalRain.saver` at runtime. You must build first with xcodebuild.
5. **Tests include source files directly** — The test target compiles all source files (not just test files) because the screensaver is a bundle, not a framework. The `@testable import` works because `ENABLE_TESTABILITY = YES` in Debug config.
6. **CRT effects (glow, scanlines) are rendered on both intro and rain** — The intro draws its own scanlines and glow via `IntroSequence.draw()`. The rain draws scanlines via `MatrixDigitalRainView.drawScanlines()` and glow via a transparency layer with shadow blur.
7. **`generate_preview.swift` sets `MATRIX_INTRO_NAME=Neo`** — This ensures the public preview GIF shows "Neo" instead of the developer's real name.
8. **The green palette has 256 entries indexed by brightness** — `greenPalette[Int(brightness * 255)]` avoids per-cell color allocation. Brightness below `trailBrightnessCutoff` (0.15) is not rendered.
9. **No configuration sheet** — `hasConfigureSheet` returns `false`. There are no user-facing settings; all behavior is controlled by `MatrixConfig` constants.

## Rules

1. **Read before writing** — Understand existing patterns before adding code
2. **All constants in MatrixConfig** — Never hardcode rendering values in other files
3. **Test everything** — Write tests, run existing tests after changes
4. **Pre-compute, never per-frame** — Cache fonts, glyphs, colors at init time
5. **Use MARK sections** — Organize code with `// MARK: -` comments matching existing structure
6. **Match the `///` doc comment style** — Document all public types and methods
7. **Keep frame-rate independence** — Use `Date()` or delta-time, never frame counts
