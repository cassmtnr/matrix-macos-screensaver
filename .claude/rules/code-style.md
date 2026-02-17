---
description: Code style conventions for the Matrix Digital Rain screensaver
---

# Code Style

## Formatting

This project has no automated formatter or linter. Follow the existing style manually:

- **Indentation**: 4 spaces (Xcode default)
- **Line length**: ~100 characters soft limit, wrap at natural break points
- **Braces**: Opening brace on same line as declaration
- **Blank lines**: One blank line between methods, two blank lines are not used

## Comments

- Use `///` documentation comments on all public types and methods
- Use `// MARK: -` to organize file sections (Properties, Initialization, Update, Draw, etc.)
- Comments explain "why", not "what" — the code should be self-explanatory
- Keep comments current — update them when changing the code they describe

## Error Handling

- Use `guard` for early returns on invalid state
- Provide graceful fallbacks (e.g., `NSFont.monospacedSystemFont` if custom font fails)
- Use `fatalError()` only for truly impossible states (e.g., empty character set)
- Never use `try!` in production code (scripts like `generate_preview.swift` are exceptions)

## Import Ordering

Follow the convention found in the source files:
1. System frameworks (`import Foundation`, `import Cocoa`, `import ScreenSaver`, `import CoreText`)
2. No third-party dependencies exist in this project

## Git Commit Messages

Use conventional commit format:
```
<type>: <description>
```

Types: `feat`, `fix`, `refactor`, `perf`, `test`, `chore`, `docs`

## Constants

All tunable values go in `MatrixConfig.swift` as `static let` properties. Group them with `// MARK: -` sections. Add a `///` comment explaining what each constant controls.
