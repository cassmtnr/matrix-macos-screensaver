---
name: commit-hygiene
description: Atomic commits, conventional format, size thresholds
---

# Commit Hygiene

## Conventional Commit Format

This project uses conventional commits:

```
<type>: <description>

[optional body]
```

### Types
- `feat:` — New feature or behavior
- `fix:` — Bug fix
- `refactor:` — Code change that neither fixes a bug nor adds a feature
- `perf:` — Performance improvement
- `test:` — Adding or updating tests
- `chore:` — Build process, CI, documentation, dependencies
- `docs:` — Documentation-only changes

### Examples from this project
```
feat: Add Matrix Digital Rain screensaver and related documentation
chore: update preview GIF [skip ci]
```

## Size Thresholds

- **Target**: ±300 lines per commit
- **Maximum**: ±500 lines — split into multiple commits if larger
- **Exceptions**: Initial scaffolding, large refactors with approval

## When to Commit

Commit after each of these triggers:
1. A new feature or behavior is working and tested
2. A bug is fixed and verified with a test
3. A refactor is complete and tests still pass
4. Config values are tuned and the visual result is verified

## Atomic Commit Rules

1. Each commit should be independently buildable and testable
2. Don't mix feature work with refactoring in the same commit
3. Don't mix source changes with unrelated config/CI changes
4. Test files can be in the same commit as the code they test

## Pre-Commit Verification

Before committing, verify:
```bash
# Tests pass
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug \
  -derivedDataPath build test

# Build succeeds
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Release \
  -derivedDataPath build build
```
