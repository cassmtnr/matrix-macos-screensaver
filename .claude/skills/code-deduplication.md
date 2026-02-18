---
name: code-deduplication
description: Check-before-write principle and search checklist
---

# Code Deduplication

## Check-Before-Write Principle

Before writing any new code, search the existing codebase to see if the functionality already exists.

## Search Checklist

### 1. Search source files for existing implementations
```
# Search all Swift source files
grep -rn "keyword" MatrixDigitalRain/*.swift

# Search for a specific function or type
grep -rn "func methodName\|class TypeName" MatrixDigitalRain/*.swift
```

### 2. Check MatrixConfig for existing constants
```
grep -n "static let\|static func\|static var" MatrixDigitalRain/MatrixConfig.swift
```
All tunable constants live in `MatrixConfig`. Before adding a new constant, verify it doesn't already exist under a different name.

### 3. Check test files for prior coverage
```
grep -rn "func test" MatrixDigitalRainTests/*.swift
```

### 4. Check scripts for utility code
```
grep -rn "keyword" preview.swift generate_preview.swift
```

## Where to Put New Code

| What | Where |
|------|-------|
| New constant | `MatrixDigitalRain/MatrixConfig.swift` — add to appropriate `// MARK:` section |
| New column behavior | `MatrixDigitalRain/MatrixColumn.swift` — new method or modify `update()` |
| New intro behavior | `MatrixDigitalRain/IntroSequence.swift` — new phase or modify state machine |
| New rendering | `MatrixDigitalRain/MatrixDigitalRainView.swift` — new draw method |
| New test | `MatrixDigitalRainTests/{ClassName}Tests.swift` |

## Common Duplication Risks

- **Scanline drawing** — Both `IntroSequence.drawScanlines()` and `MatrixDigitalRainView.drawScanlines()` draw scanlines independently. This is intentional — the intro and rain have different rendering contexts.
- **Color creation** — Colors should use the pre-computed `greenPalette` (256 entries). Don't create new `CGColor` objects per-frame.
- **Random character generation** — Always use `MatrixConfig.randomChar()`. Don't create your own random character logic.
- **Font loading** — Use the cached `ctFont` property. Don't call `NSFont(name:size:)` or `CTFontCreateWithName` outside of initialization.
