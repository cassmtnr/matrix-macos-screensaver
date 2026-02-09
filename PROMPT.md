# Matrix Digital Rain - Project Overhaul Specification

Complete overhaul of the Matrix Digital Rain macOS screensaver to bring it to open-source production quality: minimalistic, functional, zero loose ends.

---

## Project Identity

- **Name**: Matrix Digital Rain
- **Type**: Native macOS screensaver (.saver bundle)
- **Language**: 100% Swift
- **Rendering**: Real-time Core Graphics + Core Text (no video files)
- **Target**: macOS 11.0 (Big Sur) and later
- **License**: MIT
- **Repository**: https://github.com/cassmtnr/matrix-macos-screensaver
- **GitHub Pages**: https://cassmtnr.github.io/matrix-macos-screensaver/
- **Support**: https://buymeacoffee.com/cassmtnr

---

## CRITICAL CONSTRAINT: NO SPACES IN PRODUCT_NAME

```
PRODUCT_NAME = MatrixDigitalRain;       // CORRECT - the ONLY valid format
PRODUCT_NAME = "Matrix Digital Rain";   // WRONG - breaks the screensaver
```

Spaces in PRODUCT_NAME create a Swift module name with underscores (`Matrix_Digital_Rain`), which breaks Objective-C class lookup and causes black screen or crash. **Verify after EVERY change to the Xcode project.**

---

## Phase 1: Asset Recovery

### Recover `matrix_preview.gif` from Git History

The preview GIF was deleted during the Swift rewrite but still exists in git history. Recover it:

```bash
git show 0e0ef17:matrix_preview.gif > docs/matrix_preview.gif
```

This ~4MB GIF is needed by:
- `README.md` - `![Matrix Rain Preview](docs/matrix_preview.gif)`
- `docs/index.html` - OpenGraph/Twitter Card image meta tags reference it
- GitHub Pages landing page - currently shows a `[ MATRIX RAIN PREVIEW ]` placeholder div

### Update `docs/index.html` Preview Section

Replace the placeholder div with the actual preview image:

```html
<!-- REPLACE THIS: -->
<div class="preview-placeholder">
    [ MATRIX RAIN PREVIEW ]
</div>

<!-- WITH THIS: -->
<img src="matrix_preview.gif" alt="Matrix Digital Rain screensaver preview showing falling green characters on black background" loading="lazy">
```

---

## Phase 2: Dead Code & Loose Ends Audit

### Files to Inspect

| File | Check For |
|------|-----------|
| `MatrixDigitalRainView.swift` | Empty `stopAnimation()` override - remove if it only calls `super` with no custom cleanup |
| `MatrixColumn.swift` | Verify staged changes (headY initialization for thumbnail preview) are correct and committed |
| `MatrixConfig.swift` | Ensure no unused config values exist |
| `Info.plist` | Copyright year should say 2025+ or just "MIT License" |
| `.gitignore` | Clean up - remove entries for tools not used (e.g., `.idea/`, `.vscode/` if not needed) |
| `project.pbxproj` | No stale file references, no old build settings |
| `docs/index.html` | Remove the `.preview-placeholder` CSS class after replacing with `<img>` |

### Consistency Checks

1. **README.md vs actual project** - Ensure README accurately reflects the current Swift project (not the old Node.js/TypeScript version)
2. **PROMPT.md vs actual files** - This spec should describe desired state, not duplicate source code
3. **CI workflows vs build output** - Both `ci.yml` and `release.yml` must use `MatrixDigitalRain.saver` (no spaces). The actual workflow files are already correct but verify
4. **No orphaned files** - Check for `default.profraw`, build artifacts, or temp files that shouldn't be tracked

### Remove `default.profraw`

If `default.profraw` exists in the working directory, add it to `.gitignore` and remove it from tracking:

```bash
echo "default.profraw" >> .gitignore
git rm --cached default.profraw 2>/dev/null
```

---

## Phase 3: Test Coverage Improvement

### Current State

Only 2 test files exist:
- `MatrixColumnTests.swift` - 4 tests (initialization, brightness, character retrieval, update stability)
- `MatrixConfigTests.swift` - 3 tests (random char, character set, config values)

### Missing Coverage

**MatrixColumn** needs additional tests:
- `getBrightness()` returns 0.0 for rows outside the trail
- `getBrightness()` returns 1.0 for the head position (distanceFromHead < 1)
- `getBrightness()` returns decreasing values along the trail (fade effect)
- `getChar()` handles modulo wraparound for row indices > numRows
- `update()` resets column when head moves past the screen
- `update()` mutates characters probabilistically (run many iterations, verify chars changed)
- Speed and trail length are within configured bounds after initialization
- Speed and trail length are within configured bounds after reset

**MatrixConfig** needs additional tests:
- `matrixChars` contains characters from all expected scripts (katakana, latin, cyrillic, korean, greek, digits, symbols)
- `columnWidth` equals `fontSize` (current design assumes 1:1 ratio)
- All config values are positive / within valid ranges
- `charChangeProb` is between 0 and 1
- `hue` is a valid degree value (0-360)
- `fps` is reasonable (> 0, <= 120)

**MatrixDigitalRainView** - Create `MatrixDigitalRainViewTests.swift`:
- NOTE: ScreenSaverView tests require careful setup since the view depends on AppKit. Test what's testable:
  - `hasConfigureSheet` returns `false`
  - `configureSheet` returns `nil`
  - Initialization with a valid frame succeeds
  - `animationTimeInterval` is set to `1.0 / MatrixConfig.fps` after setup
  - `animateOneFrame()` initializes columns when bounds are valid and columns are empty
  - `draw()` doesn't crash with empty columns
  - `draw()` doesn't crash with initialized columns
  - Column count matches expected value based on frame width and `MatrixConfig.columnWidth`
  - Row count matches expected value based on frame height and `MatrixConfig.fontSize` (plus buffer)

### Test Quality Standards

- Every test should have a clear name describing the behavior being tested
- Use `@testable import MatrixDigitalRain` in all test files
- No flaky tests - avoid assertions that depend on random state being a specific value
- Test boundary conditions (0 rows, 1 row, very large values)
- Tests must pass in CI (GitHub Actions `macos-latest`)

---

## Phase 4: Code Quality Polish

### Swift Best Practices

- Use `final` on classes that won't be subclassed (`MatrixColumn`)
- Use `private(set)` where external read access is needed but writes should be internal
- Consider making `MatrixColumn` a struct if reference semantics aren't required (the array of columns in the view would still work with value types since they're in a `var` array)
- Ensure all force-unwraps (`!`) are justified or replaced with safe alternatives (e.g., `matrixFont!` in the view's `draw()`)
- Use `[Character]` initializer efficiently - verify the character string concatenation doesn't create unnecessary intermediate strings

### Performance Considerations

- The `draw()` method creates `NSAttributedString` attributes dictionary on every frame for every character. Consider caching attribute dictionaries per brightness level
- The character mutation loop in `update()` iterates every character every frame. This is fine for the current scale but document why

### Architecture

The current 3-file architecture is already minimal and clean:
- `MatrixConfig.swift` - Pure data, no dependencies
- `MatrixColumn.swift` - Logic layer, depends only on MatrixConfig
- `MatrixDigitalRainView.swift` - Presentation layer, depends on both

**Do NOT over-engineer.** This is a screensaver, not a framework. No protocols, no dependency injection, no abstractions beyond what exists. Keep it simple.

---

## Phase 5: README & Documentation

### README.md Requirements

The README should be concise and scannable. Include:

1. **Badges**: CI status, License (MIT), Platform (macOS 11+), Swift version
2. **One-line description**: What it is
3. **Preview GIF**: `![Matrix Rain Preview](docs/matrix_preview.gif)` - must render on GitHub
4. **Features list**: Brief, no emojis (minimalistic open-source style)
5. **Installation**:
   - Download from Releases (recommended path)
   - Build from source (developer path)
6. **Requirements**: macOS 11.0+
7. **Development**: Project structure, build/test commands
8. **Contributing**: Brief section welcoming contributions (it's open source)
9. **License**: MIT

### Things to Remove from README

- Emojis in feature list (keep it clean and professional)
- References to old Node.js/TypeScript project structure
- "Buy me a coffee" link - keep it only on the GitHub Pages site, not the README (optional, up to taste)

---

## Phase 6: GitHub Pages Site

### Current State

`docs/index.html` is a well-designed Matrix-themed landing page with:
- SEO optimization (OpenGraph, Twitter Card, JSON-LD, sitemap, robots.txt)
- Animated matrix rain background (canvas JavaScript)
- CRT scanline overlay effect

### Required Changes

1. **Add preview GIF** - Replace placeholder div with actual `<img>` tag (see Phase 1)
2. **Remove unused CSS** - Delete `.preview-placeholder` styles after replacing with `<img>`
3. **Verify all links work** - Download button, GitHub link, Buy Me a Coffee link
4. **Update version info** if needed in the download section
5. **Verify `sitemap.xml` lastmod date** is recent

---

## Phase 7: CI/CD Verification

### Verify Workflows Match Reality

Both workflows should already be correct (fixed in commit `4c620d6`), but verify:

**ci.yml** must:
- Trigger on push to main/develop and PRs to main
- Build Release configuration
- Run tests in Debug configuration
- Package `MatrixDigitalRain.saver` (NO spaces)
- Upload artifact

**release.yml** must:
- Trigger on release creation
- Build Release configuration
- Zip `MatrixDigitalRain.saver` (NO spaces)
- Upload zip to GitHub release

### Test Locally Before Pushing

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
  -derivedDataPath build \
  test

# Clean
xcodebuild -project MatrixDigitalRain.xcodeproj clean
rm -rf build/
```

---

## Verification Checklist

Run ALL of these before marking the overhaul complete:

### 1. PRODUCT_NAME (Critical)
```bash
grep "PRODUCT_NAME" MatrixDigitalRain.xcodeproj/project.pbxproj
```
Expected: `PRODUCT_NAME = MatrixDigitalRain;` - NO spaces, NO quotes

### 2. NSPrincipalClass
```bash
grep -A1 "NSPrincipalClass" MatrixDigitalRain/Info.plist
```
Expected: `<string>MatrixDigitalRainView</string>`

### 3. @objc Annotation
```bash
grep "@objc" MatrixDigitalRain/MatrixDigitalRainView.swift
```
Expected: `@objc(MatrixDigitalRainView)`

### 4. Preview GIF Exists
```bash
ls -la docs/matrix_preview.gif
```
Expected: File exists, ~4MB

### 5. No Placeholder in HTML
```bash
grep "preview-placeholder" docs/index.html
```
Expected: No matches (placeholder replaced with actual image)

### 6. All Tests Pass
```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Debug \
  -derivedDataPath build \
  test
```
Expected: All tests pass, including new coverage tests

### 7. No Dead Files
```bash
# Should NOT exist:
ls default.profraw 2>/dev/null && echo "REMOVE THIS"
```

### 8. Build Succeeds
```bash
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Release \
  -derivedDataPath build \
  build
```

### 9. Git Status Clean
```bash
git status
```
All changes should be intentional and committed.

---

## Success Criteria

- [ ] `matrix_preview.gif` recovered and in `docs/`
- [ ] `docs/index.html` shows actual preview image, no placeholder
- [ ] No dead code, no empty overrides, no unused CSS
- [ ] Test coverage expanded: MatrixColumn, MatrixConfig, and MatrixDigitalRainView all tested
- [ ] All tests pass locally
- [ ] README is clean, professional, and accurate
- [ ] CI/CD workflows are correct (no space-in-filename bugs)
- [ ] `.gitignore` is clean, no tracked artifacts
- [ ] Build succeeds in Release mode
- [ ] PRODUCT_NAME verified: `MatrixDigitalRain` with no spaces
- [ ] Code follows Swift best practices (final classes, safe unwrapping, etc.)

---

## Links

- **Repository**: https://github.com/cassmtnr/matrix-macos-screensaver
- **GitHub Pages**: https://cassmtnr.github.io/matrix-macos-screensaver/
- **Buy Me a Coffee**: https://buymeacoffee.com/cassmtnr
