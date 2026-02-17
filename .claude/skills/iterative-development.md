---
name: iterative-development
description: TDD workflow with project-specific test and build commands
---

# Iterative Development

## TDD Loop

### 1. Write a failing test
Add the test to the appropriate file in `MatrixDigitalRainTests/`:
- Config tests → `MatrixConfigTests.swift`
- Column tests → `MatrixColumnTests.swift`
- Intro tests → `IntroSequenceTests.swift`
- View tests → `MatrixDigitalRainViewTests.swift`

### 2. Run tests — confirm it fails
```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug \
  -derivedDataPath build test
```

### 3. Write the minimal implementation
- New constants go in `MatrixConfig.swift`
- New column behavior goes in `MatrixColumn.swift`
- New intro behavior goes in `IntroSequence.swift`
- New rendering goes in `MatrixDigitalRainView.swift`

### 4. Run tests — confirm it passes
```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug \
  -derivedDataPath build test
```

### 5. Build and visually verify
```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Release \
  -derivedDataPath build build

swift preview.swift --duration 20
```

### 6. Refactor if needed
- Move magic numbers to `MatrixConfig`
- Extract methods if a function exceeds ~40 lines
- Add `// MARK: -` sections for new code groups
- Add `///` documentation comments

## Verification Checklist

Before considering a change complete:

- [ ] All existing tests pass
- [ ] New tests added for new behavior
- [ ] Constants are in `MatrixConfig`, not hardcoded
- [ ] Code uses `// MARK: -` sections
- [ ] Public API has `///` doc comments
- [ ] No per-frame allocations in draw/update loops
- [ ] Timing uses `Date()` or delta-time, not frame counts
- [ ] Visual preview looks correct (`swift preview.swift`)
