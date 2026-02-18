---
name: simplicity-rules
description: Function and file size limits, decomposition patterns
---

# Simplicity Rules

## Size Limits

| Metric | Limit | Action |
|--------|-------|--------|
| Function body | 40 lines | Extract helper method |
| File | 300 lines | Extract new type/file |
| Cyclomatic complexity | 10 branches | Simplify or decompose |

## Current File Sizes (reference)

- `MatrixConfig.swift` — ~131 lines (config namespace, could grow)
- `MatrixColumn.swift` — ~94 lines (model, well-scoped)
- `IntroSequence.swift` — ~212 lines (state machine, moderate)
- `MatrixDigitalRainView.swift` — ~242 lines (view, moderate)

## Decomposition Patterns for This Project

### Extract a config section
If `MatrixConfig` grows too large, group related constants into nested types:
```swift
enum MatrixConfig {
    enum Rain {
        static let fontSize: CGFloat = 20
        // ...
    }
    enum Intro {
        static let typingSpeed: Double = 0.1
        // ...
    }
}
```

### Extract a drawing helper
If `draw(_:)` in `MatrixDigitalRainView` grows, extract rendering into focused methods:
```swift
private func drawColumn(_ column: MatrixColumn, in context: CGContext) { ... }
private func drawScanlines(in context: CGContext) { ... }  // already done
```

### Extract a new model type
If `MatrixColumn` gains complex sub-behaviors, extract them:
```swift
// e.g., if trail rendering gets complex
struct TrailRenderer { ... }
```

## Complexity Guidelines

- Prefer `guard` for early returns over nested `if` blocks
- Use `switch` with associated values for state machines (see `IntroSequence.Phase`)
- Avoid deeply nested closures — extract into named methods
- Keep the animation loop (`animateOneFrame`) thin — delegate to model objects
