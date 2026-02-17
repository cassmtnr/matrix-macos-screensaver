---
name: pattern-discovery
description: Analyze codebase to discover and document patterns
---

# Pattern Discovery

Search the codebase to discover, verify, and document coding patterns before writing new code.

## Search Strategy

1. **Source files**: Search `MatrixDigitalRain/*.swift` for implementation patterns
2. **Test files**: Search `MatrixDigitalRainTests/*.swift` for testing patterns
3. **Config**: Check `MatrixDigitalRain/MatrixConfig.swift` for constant organization
4. **Scripts**: Check `preview.swift` and `generate_preview.swift` for standalone Swift patterns

## Key Patterns to Look For

### Architecture Patterns
- Caseless enum namespaces for constants (`MatrixConfig`)
- State machines with enum phases (`IntroSequence.Phase`)
- `ScreenSaverView` subclass lifecycle (`init`, `startAnimation`, `animateOneFrame`, `draw`)
- Pre-computed resource caching at initialization

### Code Organization
- `// MARK: -` sections in every file (Properties, Initialization, Update, Draw, etc.)
- `///` documentation comments on all public types and methods
- One primary type per file, PascalCase filename matching type name

### Rendering Patterns
- Direct `CGContext` drawing (no SwiftUI, no storyboards)
- `CTFontDrawGlyphs` for glyph rendering
- Transparency layers with shadow for glow effects
- Pre-computed color palettes indexed by brightness

### Timing Patterns
- Wall-clock `Date()` for intro timing
- Delta-time (`deltaTime: Double`) for rain animation
- Never frame-count-based timing

## How to Search

```
# Find all MARK sections to understand code organization
grep -n "MARK:" MatrixDigitalRain/*.swift

# Find all public API surfaces
grep -n "func \|var \|let " MatrixDigitalRain/*.swift | grep -v private

# Find all MatrixConfig references to understand constant usage
grep -rn "MatrixConfig\." MatrixDigitalRain/*.swift

# Find test patterns
grep -n "func test" MatrixDigitalRainTests/*.swift
```

## Documentation

When documenting a discovered pattern, include:
1. The file and line where the pattern is defined
2. Example usage from the codebase
3. Why the pattern exists (performance, correctness, framework requirement)
