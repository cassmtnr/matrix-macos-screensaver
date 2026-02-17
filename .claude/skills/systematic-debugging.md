---
name: systematic-debugging
description: 4-phase debugging methodology — Reproduce, Locate, Diagnose, Fix
---

# Systematic Debugging

Follow this 4-phase methodology for every bug. Do not skip phases.

## Phase 1: Reproduce

Reproduce the issue reliably before attempting any fix.

### For visual/rendering bugs:
```bash
# Build the screensaver
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Release \
  -derivedDataPath build build

# Preview in a window to observe the bug
swift preview.swift --duration 30
```

### For logic bugs:
```bash
# Run existing tests to see what passes/fails
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug \
  -derivedDataPath build test
```

### For timing bugs:
- The intro uses wall-clock `Date()` — bugs may only appear at specific frame rates
- The rain uses delta-time — bugs may appear when `deltaTime` varies significantly
- Test with both normal and extreme `deltaTime` values

## Phase 2: Locate

Narrow down the source of the bug:

1. **Which layer?** Config (`MatrixConfig`), Model (`MatrixColumn`), State Machine (`IntroSequence`), or View (`MatrixDigitalRainView`)?
2. **Which phase?** Intro sequence or rain animation? Check `intro.isComplete` to distinguish.
3. **Which lifecycle method?** `init`, `startAnimation`, `animateOneFrame`, or `draw`?

Key files to check:
- `MatrixDigitalRain/MatrixConfig.swift` — Are constants correct?
- `MatrixDigitalRain/MatrixColumn.swift:43` — Is `update(deltaTime:)` correct?
- `MatrixDigitalRain/IntroSequence.swift:57` — Is `update()` advancing phases correctly?
- `MatrixDigitalRain/MatrixDigitalRainView.swift:147` — Is `animateOneFrame()` delegating correctly?

## Phase 3: Diagnose

Understand the root cause:

- **Timing issues**: Check if code uses frame counts instead of wall-clock time
- **Rendering issues**: Check if resources are being allocated per-frame instead of cached
- **State issues**: Check `IntroSequence.Phase` transitions — missing case? Wrong guard?
- **Layout issues**: Check `initializeColumns()` — does it handle zero/negative bounds?
- **Font issues**: Check `registerMatrixFont()` — is the font URL found? Is `buildGlyphCache()` mapping all characters?

## Phase 4: Fix

1. Make the minimal change that fixes the root cause
2. Add constants to `MatrixConfig` if introducing new tunable values
3. Write a test that would have caught the bug
4. Run all tests to verify no regressions:
```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug \
  -derivedDataPath build test
```
5. Build and visually verify the fix:
```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Release \
  -derivedDataPath build build
swift preview.swift --duration 20
```
